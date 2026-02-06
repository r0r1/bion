require 'sqlite3'
require 'csv'

db_file = "company.db"

# Remove existing DB to start fresh with new schema
File.delete(db_file) if File.exist?(db_file)

# Connect to SQLite
db = SQLite3::Database.new(db_file)

puts "Creating tables with new schema..."

# Create job_titles table
db.execute <<-SQL
  CREATE TABLE job_titles (
    id INTEGER PRIMARY KEY,
    title TEXT,
    department TEXT,
    base_salary INTEGER
  );
SQL

# Create employees table with gender, birth_date, department, and resign_date
db.execute <<-SQL
  CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    gender TEXT,
    birth_date DATE,
    job_title_id INTEGER,
    department TEXT,
    salary INTEGER,
    hire_date DATE,
    resign_date DATE,
    FOREIGN KEY (job_title_id) REFERENCES job_titles(id)
  );
SQL

puts "Importing job titles..."
CSV.foreach("job_titles.csv", headers: true) do |row|
  db.execute("INSERT INTO job_titles (id, title, department, base_salary) VALUES (?, ?, ?, ?)",
             [row['id'], row['title'], row['department'], row['base_salary']])
end

puts "Importing employees with resignation data..."
CSV.foreach("employees.csv", headers: true) do |row|
  db.execute("INSERT INTO employees (id, first_name, last_name, email, gender, birth_date, job_title_id, department, salary, hire_date, resign_date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
             [row['id'], row['first_name'], row['last_name'], row['email'], row['gender'], row['birth_date'], row['job_title_id'], row['department'], row['salary'], row['hire_date'], row['resign_date']])
end

# Verify
count = db.get_first_value("SELECT COUNT(*) FROM employees")
resigned_count = db.get_first_value("SELECT COUNT(*) FROM employees WHERE resign_date IS NOT NULL")
sample = db.get_first_row("SELECT * FROM employees WHERE resign_date IS NOT NULL LIMIT 1")

puts "Successfully imported #{count} employees into #{db_file}."
puts "Total Resigned: #{resigned_count}"
puts "Sample Resigned record: #{sample.inspect}"

db.close
