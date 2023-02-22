class Dog
    attr_accessor :name, :breed, :id
    def initialize(attributes)
     attributes.each {|key, value| self.send("#{key}=", value) }
     self.id ||=nil
    end
def self.create_table
    DB[:conn].execute("CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name TEXT, breed TEXT)")
end
def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
end
    def save
        sql = <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?)
        SQL
    
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    
      end
      def self.create(name:, breed:)
        dog = self.new(name: name, breed: breed)
        dog.save
        dog
      end
      def self.new_from_db(row)
        self.new(name: row[1], breed: row[2], id: row[0])
      end
      def self.all
        sql = <<-SQL
          SELECT *
          FROM dogs
        SQL
    
        DB[:conn].execute(sql).map do |row|
          self.new_from_db(row)
        end
    end
    def self.find_by_name(name)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          LIMIT 1
        SQL
    
        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
        end.first
      end
def self.find(id)
    sql = <<-SQL
    SELECT *
    FROM dogs
    WHERE id = ?
    LIMIT 1
  SQL

  DB[:conn].execute(sql, id).map do |row|
    self.new_from_db(row)
  end.first
end
def self.find_or_create_by(name:, breed:)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL

    dog = DB[:conn].execute(sql, name, breed)

    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new_from_db(dog_data)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end
  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end
end
