require 'sqlite3'
require 'csv'

db_file = "company.db"
File.delete(db_file) if File.exist?(db_file)

db = SQLite3::Database.new(db_file)

puts "Creating normalized tables..."

# 1. Departments
db.execute "CREATE TABLE departments (id INTEGER PRIMARY KEY, name TEXT);"

# 2. Education
db.execute "CREATE TABLE education (id INTEGER PRIMARY KEY, degree TEXT);"

# 3. Job Titles
db.execute <<-SQL
  CREATE TABLE job_titles (
    id INTEGER PRIMARY KEY,
    title TEXT,
    department_id INTEGER,
    base_salary INTEGER,
    FOREIGN KEY (department_id) REFERENCES departments(id)
  );
SQL

# 4. Employees
db.execute <<-SQL
  CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    email TEXT,
    gender TEXT,
    birth_date DATE,
    job_title_id INTEGER,
    education_id INTEGER,
    salary INTEGER,
    hire_date DATE,
    resign_date DATE,
    FOREIGN KEY (job_title_id) REFERENCES job_titles(id),
    FOREIGN KEY (education_id) REFERENCES education(id)
  );
SQL

# 5. Employee Satisfaction (NPS)
db.execute <<-SQL
  CREATE TABLE employee_satisfaction (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER,
    score INTEGER,
    survey_date DATE,
    feedback TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
  );
SQL

# 6. Salary History
db.execute <<-SQL
  CREATE TABLE salary_histories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    employee_id INTEGER,
    salary INTEGER,
    effective_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
  );
SQL

# Import Data
puts "Importing lookup tables..."
CSV.foreach("departments.csv", headers: true) { |row| db.execute("INSERT INTO departments VALUES (?,?)", [row['id'], row['name']]) }
CSV.foreach("education.csv", headers: true) { |row| db.execute("INSERT INTO education VALUES (?,?)", [row['id'], row['degree']]) }
CSV.foreach("job_titles.csv", headers: true) { |row| db.execute("INSERT INTO job_titles VALUES (?,?,?,?)", [row['id'], row['title'], row['department_id'], row['base_salary']]) }

puts "Importing employees..."
CSV.foreach("employees.csv", headers: true) do |r|
  db.execute("INSERT INTO employees VALUES (?,?,?,?,?,?,?,?,?,?,?)", 
    [r['id'], r['first_name'], r['last_name'], r['email'], r['gender'], r['birth_date'], r['job_title_id'], r['education_id'], r['salary'], r['hire_date'], r['resign_date']])
end

puts "Importing satisfaction scores..."
CSV.foreach("satisfaction.csv", headers: true) do |r|
  db.execute("INSERT INTO employee_satisfaction (employee_id, score, survey_date, feedback) VALUES (?,?,?,?)", 
    [r['employee_id'], r['score'], r['survey_date'], r['feedback']])
end

puts "Importing salary histories..."
CSV.foreach("salary_history.csv", headers: true) do |r|
  db.execute("INSERT INTO salary_histories (employee_id, salary, effective_date) VALUES (?,?,?)", 
    [r['employee_id'], r['salary'], r['effective_date']])
end

# Verification
count = db.get_first_value("SELECT COUNT(*) FROM salary_histories")
puts "Successfully imported #{count} salary history records."

# Sample query for trend
puts "\nSample Salary Trend for Employee #1:"
db.execute("SELECT salary, effective_date FROM salary_histories WHERE employee_id = 1 ORDER BY effective_date ASC") do |row|
  p row
end

db.close
