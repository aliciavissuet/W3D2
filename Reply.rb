require_relative "QuestionsDatabase"

class Reply
  attr_reader :id, :question_id, :parent_reply_id, :user_id
  attr_accessor :body

  def self.all
    data = QuestionsDBConnection.instance.execute('SELECT * FROM replies')
    data.map { |datum| Reply.new(datum) }
  end

  def self.find_by_id(id)
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      *
    FROM
      replies
    WHERE
      id = #{id}
    SQL
    Reply.new(data[0])
  end

  def self.find_by_user_id(user_id)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      *
    FROM 
      replies
    WHERE
      replies.user_id = #{user_id}
    SQL
    data.each { |reply| result << Reply.new(reply) }
    result
  end

  def self.find_by_question_id(question_id)
    result = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      *
    FROM 
      replies
    WHERE
      replies.question_id = #{question_id}
    SQL
    data.each { |reply| result << Reply.new(reply) }
    result
  end  

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_reply_id = options['parent_reply_id']
    @user_id = options['user_id']
    @body = options['body']
  end

  def create
    raise "#{self} in DB" if @id
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id, @body)
    INSERT INTO
      replies(question_id, parent_reply_id, user_id, body)
    VALUES
      (?, ?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in db" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @question_id, @parent_reply_id, @user_id, @body)
    UPDATE
      replies
    SET
      question_id = ?, parent_reply_id = ?, user_id = ?, body = ?
    WHERE
      id = ?
    SQL
  end

end

