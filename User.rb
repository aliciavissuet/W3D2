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

end