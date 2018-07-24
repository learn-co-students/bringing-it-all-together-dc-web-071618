require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(props = {})
    @name = props[:name]
    @breed = props[:breed]
  end

  def self.create(dog_hash)
    new_dog = self.new(dog_hash)
    new_dog.save
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
      SQL
    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
      SQL
    DB[:conn].execute(sql)
  end

  def self.new_from_db(dogos)
    new_dog = self.new({name:dogos[1], breed:dogos[2]})
    new_dog.id = dogos[0]
    new_dog
    # binding.pry
    # puts nil
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?
      SQL
      dogos = DB[:conn].execute(sql, name)[0]
      self.new_from_db(dogos)
  end

# binding.pry
# puts nil

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ?, breed = ?
      SQL
      has_dog = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
      # binding.pry
      # puts nil
      if !has_dog.empty?
        self.new_from_db(has_dog[0])
      else
        self.create(dog_hash)
      end
  end

  def self.find_by_id(dog_id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ?
      SQL
      dogos = DB[:conn].execute(sql, dog_id)[0]
      self.new_from_db(dogos)
  end

  def update
    sql = <<-SQL
      UPDATE dogs set name = ?, breed = ? where id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    # This spec will create and insert a dog, and afterwards, it will change the name of the dog instance and call update. The expectations are that after this operation, there is no dog left in the database with the old name. If we query the database for a dog with the new name, we should find that dog and the ID of that dog should be the same as the original, signifying this is the same dog, they just changed their name.
  end

  def save
    if !self.id
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT id FROM dogs WHERE last_insert_rowid()")[0][0]
        self
    else
      self.update
    end
    # This spec ensures that given an instance of a dog, simply calling save will trigger the correct operation. To implement this, you will have to figure out a way for an instance to determine whether it has been persisted into the DB.
    #
    # In the first test we create an instance, specify, since it has never been saved before, that the instance will receive a method call to insert.
    #
    # In the next test, we create an instance, save it, change its name, and then specify that a call to the save method should trigger an update.
  end

end
