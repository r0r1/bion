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

# Calculate NPS
puts "\nCalculating Net Promoter Score (NPS)..."
total = db.get_first_value("SELECT COUNT(*) FROM employee_satisfaction").to_f
promoters = db.get_first_value("SELECT COUNT(*) FROM employee_satisfaction WHERE score >= 9").to_f
detractors = db.get_first_value("SELECT COUNT(*) FROM employee_satisfaction WHERE score <= 6").to_f

nps = ((promoters / total) * 100) - ((detractors / total) * 100)
puts "Total Responses: #{total.to_i}"
puts "Promoters (9-10): #{promoters.to_i}"
puts "Detractors (0-6): #{detractors.to_i}"
puts "Company NPS Score: #{nps.round(2)}"

db.close
