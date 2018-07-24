class Dog
  attr_accessor :name, :breed, :id

  def initialize(props={})
    @name = props[:name]
    @breed = props[:breed]
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

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(sql)
  end

  def self.create(dog_hash)
    dog = self.new(dog_hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL

    row = DB[:conn].execute(sql, id).flatten
    new_from_db(row)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
    SQL

    row = DB[:conn].execute(sql, name).flatten
    new_from_db(row)
  end

  def self.find_or_create_by(dog_hash)
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?
    SQL

    row = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])

    if !row.empty?
      dog_data = row[0]
      new_dog = self.new_from_db(dog_data)
    else
      new_dog = create(name: dog_hash[:name], breed: dog_hash[:breed])
    end
    new_dog
  end

  def self.new_from_db(row)
    new_dog = self.new(name: row[1], breed: row[2])
    new_dog.id = row[0]
    new_dog
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

      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
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
