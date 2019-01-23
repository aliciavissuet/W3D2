require_relative 'QuestionsDatabase'
require_relative 'Question'
require_relative 'Reply'
require_relative 'Question_follow'
require_relative 'Question_like'

class User
  attr_accessor :fname, :lname
  attr_reader :id

  def self.all
    data = QuestionsDBConnection.instance.execute("SELECT * FROM users")
    data.map { |datum| User.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDBConnection.instance.execute <<-SQL
      SELECT
        *
      FROM 
        users
      WHERE
        users.id = #{id}
    SQL
    User.new(data[0])
  end

  def self.find_by_name(fname, lname)
    data = QuestionsDBConnection.instance.execute <<-SQL
      SELECT
        *
      FROM
        users
      WHERE
        fname = fname AND lname = lname
    SQL
    User.new(data[0])
  end

  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def create
    raise "#{self} in DB" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname)
      INSERT INTO
        users(fname, lname)
      VALUES
        (?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id  

  end

  def update
    raise "#{self} not in DB" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @fname, @lname, @id)
      UPDATE
        users
      SET
        fname = ?, lname = ?
      WHERE
        id = ?
    SQL
  end

  def authored_questions
    Question.find_by_author(self.id)
  end

  def followed_questions
    Question_follow.followed_questions_for_user_id(self.id)
  end

  def liked_questions
    Question_like.liked_questions_for_user_id(self.id)
  end

  def avg_karma
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      COUNT(question_likes.id) / CAST(COUNT (DISTINCT questions.id) AS FLOAT) 
    FROM  
      questions
    JOIN
      question_likes ON questions.id = question_likes.id
    WHERE
      questions.user_id = #{self.id}
    SQL
    data
  end

end