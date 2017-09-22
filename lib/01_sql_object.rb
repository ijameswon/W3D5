require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns

    columns = DBConnection.execute2(<<-SQL).first
      SELECT * FROM #{self.table_name} LIMIT 0
    SQL

    columns.map!(&:to_sym)
    @columns = columns
  end

  def self.finalize!
    self.columns.each do |col|
      define_method(col) do
        self.attributes[col]
      end

      define_method("#{col}=") do |value|
        self.attributes[col] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name || self.name.underscore.pluralize
  end

  def self.all
    all_results = DBConnection.execute(<<-SQL)
      SELECT * FROM #{self.table_name}
    SQL

    parse_all(all_results)
  end

  def self.parse_all(results)
    results_arr = []
    results.each do |obj|
      results_arr << self .new(obj)
    end
    results_arr
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT * FROM #{table_name} WHERE id = ?
    SQL
    parse_all(results).first
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      attr_name = attr_name.to_sym
      if self.class.columns.include?(attr_name)
        self.send("#{attr_name}=", val)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    @attributes ||= {}


  end

  def attribute_values

  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
