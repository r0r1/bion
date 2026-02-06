require 'sqlite3'
require 'csv'

db_file = "company.db"

# Remove existing DB if it exists
File.delete(db_file) if File.exist?(db_file)

# Connect to SQLite
db = SQLite3::Database.new(db_file)

puts "Creating tables..."

# Create job_titles table
db.execute <<-SQL
  CREATE TABLE job_titles (
    id INTEGER PRIMARY KEY,
    title TEXT,
    department TEXT,
    base_salary INTEGER
  );
SQL

# Create employees table
db.execute <<-SQL
  CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    job_title_id INTEGER,
    salary INTEGER,
    hire_date DATE,
    FOREIGN KEY (job_title_id) REFERENCES job_titles(id)
  );
SQL

puts "Importing job titles..."
CSV.foreach("job_titles.csv", headers: true) do |row|
  db.execute("INSERT INTO job_titles (id, title, department, base_salary) VALUES (?, ?, ?, ?)",
             [row['id'], row['title'], row['department'], row['base_salary']])
end

puts "Importing employees..."
CSV.foreach("employees.csv", headers: true) do |row|
  db.execute("INSERT INTO employees (id, first_name, last_name, email, job_title_id, salary, hire_date) VALUES (?, ?, ?, ?, ?, ?, ?)",
             [row['id'], row['first_name'], row['last_name'], row['email'], row['job_title_id'], row['salary'], row['hire_date']])
end

# Verify
count = db.get_first_value("SELECT COUNT(*) FROM employees")
puts "Successfully imported #{count} employees into #{db_file}."

db.close
