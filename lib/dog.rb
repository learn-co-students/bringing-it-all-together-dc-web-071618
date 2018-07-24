require 'pry'

class Dog
  attr_accessor :name, :breed, :id

  def initialize(props={})
    @id = props[:id]
    @name = props[:name]
    @breed = props[:breed]
  end

  def self.create_table
    sql =  <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT   last_insert_rowid() FROM dogs")[0][0]
    end
    return self
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name=?, breed=? WHERE  id=?;
        )
        SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  # def self.create(name:, breed:)
    # dog = Dog.new(name: name, breed: breed)
    def self.create(hash)
      dog = Dog.new(hash)
      dog.save
      dog
    end

    def self.find_by_name(name)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE name = ?
        SQL

        DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
      end.first
    end

    def self.find_by_id(id)
      sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE id = ?
        SQL

        DB[:conn].execute(sql, id).map do |row|
          self.new_from_db(row)
      end.first
    end

    def self.find_or_create_by(name: name, breed: breed)
      dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
          dog_data = dog[0]
          dog = Dog.new(id:dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
          dog = self.create(name: name, breed: breed)
        end
        dog
    end

    # def self.new_from_db(row)
    #   new_dog = Dog.new(id: id, name: name, breed: breed)
    #   new_dog.id = array[0]
    #   new_dog.name = array[1]
    #   new_dog.breed = array[2]
    # end


    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      breed = row[2]
      self.new(id: id, name: name, breed: breed)
    end
  # binding.pry


end
