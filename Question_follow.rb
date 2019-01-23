require_relative 'QuestionsDatabase'
require_relative 'Question'
require_relative 'Reply'

class Question_follow

  def self.all
    data = QuestionsDBConnection.instance.execute('SELECT * FROM replies')
    data.map { |datum| Reply.new(datum) }
  end

  def self.followed_questions_for_user_id(user_id)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      questions.*
    FROM
      questions
    JOIN
      question_follows ON question_follows.questions_id = questions.id
    WHERE
      question_follows.user_id = #{user_id}
    SQL
    data.each { |question| result << Question.new(question) }
    result
  end

  def self.followers_for_question_id(question_id)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      users.*
    FROM
      users
    JOIN
      question_follows ON question_follows.user_id = users.id
    WHERE
      question_follows.questions_id = #{question_id}
    SQL
    data.each { |user| result << User.new(user) }
    result
  end

  def self.most_followed_questions(n)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      questions.*
    FROM
      questions
    JOIN 
      question_follows
      ON question_follows.questions_id = questions.id
    GROUP BY
      questions.id
    HAVING
      COUNT(questions.id) >= #{n}
    SQL
    
  end

  def initialize(options)
    @user_id = options['user_id']
    @questions_id = options['questions_id']
  end

   def create
    raise 'already following' if @user_id && @questions_id
    QuestionsDBConnection.instance.execute(<<-SQL, @user_id, @questions_id)
      INSERT INTO
        question_follows(user_id, questions_id)
      VALUES
        (?, ?)
    SQL
  end

  def update
    QuestionsDBConnection.instance.execute(<<-SQL, @user_id, @questions_id)
      UPDATE
        question_follows
      SET
        user_id = ?, questions_id = ?
    SQL
  end



end