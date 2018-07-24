class Dog
  attr_accessor :id, :name, :breed

  def initialize(dog_props = {})
    @id = dog_props[:id]
   @name = dog_props[:name]
    @breed = dog_props[:breed]
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
      SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
      DB[:conn].execute("DROP TABLE dogs;")
  end

  def persisted?
    !!id
  end

  def save
    if persisted?
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?);
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      saved_dog_data = DB[:conn].execute("SELECT * FROM dogs WHERE id = last_insert_rowid()")
      self.id = saved_dog_data[0][0]
    end
    self
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.new_from_db(row)
    new_dog = Dog.new(name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog

  end


  def self.find_by_id(id)
    DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).map do |row|
      self.new_from_db(row)
    end.first
  end

  def update
    DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?;", self.name, self.breed, self.id)
  end

  def self.find_by_name(name)
    DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).map do |row|
      self.new_from_db(row)
    end.first
  end

  def self.find_or_create_by(name: name, breed: breed)
    dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
    binding.pry
    if !dog.empty?
      dog_data = dog[0]
      dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
    else
      dog = self.create(name: name, breed: breed)
    end
    dog

  end

end
