require_relative 'QuestionsDatabase'

class Question
  attr_accessor :title, :body, :user_id
  attr_reader :id
  
  def self.all
    data = QuestionsDBConnection.instance.execute('SELECT * FROM questions')
    data.map {|datum| Question.new(datum)}
  end

  def self.find_by_id(id)
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      *
    FROM
      questions
    WHERE
      id = #{id}
    SQL
    Question.new(data[0])
  end

  def self.find_by_author(user_id)
    ques = []
    data = QuestionsDBConnection.instance.execute <<-SQL
    SELECT
      *
    FROM
      questions 
    WHERE
      questions.user_id = #{user_id}
    SQL
    data.each do |hsh|
      ques << Question.new(hsh)
    end
    ques
  end

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def create
    raise "#{self} already in db" if @id 
    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id)
    INSERT INTO
      questions(title, body, user_id)
    VALUES
      (?, ?, ?)
    SQL
    @id = QuestionsDBConnection.instance.last_insert_row_id
  end

  def update
    raise "#{self} not in db" unless @id
    QuestionsDBConnection.instance.execute(<<-SQL, @title, @body, @user_id, @id)
    UPDATE
      questions
    SET
      title = ?, body = ?, user_id = ?
    WHERE
      id = ?
    SQL
  end

  def replies
    Reply.find_by_question_id(self.id)
  end
  
end