require_relative 'QuestionsDatabase'

class Question_like
  attr_reader :id, :user_like_id, :question_id

  def self.all
    data = QuestionsDBConnection.instance.execute('SELECT * FROM questions')
    data.map {|datum| Question.new(datum)}
  end

  def likers_for_question_id(question_id)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      DISTINCT users.*
    FROM
      users
    JOIN
      question_likes ON question_likes.user_like_id = users.id
    JOIN
      questions ON questions.id = question_likes.question_id
    WHERE
      questions.id = #{question_id}
    SQL

    data.each { |user| result << User.new(user) }
    result
  end

  def self.num_likes_for_question_id(question_id)
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      COUNT(user_like_id)
    FROM
      question_likes
    WHERE
      question_likes.question_id = #{question_id}
    SQL
    data
  end

  def self.liked_questions_for_user_id(user_id)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    WHERE
      question_likes.user_like_id = #{user_id}
    SQL
    data.each { |question| result << Question.new(question) }
    result
  end

  def self.most_liked_questions(n)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_likes ON question_likes.question_id = questions.id
    GROUP BY
      questions.id
    HAVING
      COUNT(questions.id) >= #{n}
    SQL
    data.each { |question| result << Question.new(question) }
    result
  end

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @user_like_id = options['user_like_id']
  end

  def create
    #raise 'already following' if @user_like_id
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @user_like_id)
      INSERT INTO
        question_likes(question_id, user_like_id)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in db" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @user_like_id, @id)
      UPDATE
        question_likes
      SET
        user_id = ?, questions_id = ?
      WHERE
        id = ?
    SQL
  end

end