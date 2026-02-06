require 'csv'
require 'date'

# Configuration
RECORD_COUNT = 1000

# Sample Data
job_titles_list = [
  { id: 1, title: "Junior Software Engineer", department: "Engineering", base_salary: 60000 },
  { id: 2, title: "Senior Software Engineer", department: "Engineering", base_salary: 120000 },
  { id: 3, title: "Product Manager", department: "Product", base_salary: 100000 },
  { id: 4, title: "Data Scientist", department: "Data Science", base_salary: 110000 },
  { id: 5, title: "HR Business Partner", department: "Human Resources", base_salary: 80000 },
  { id: 6, title: "Sales Executive", department: "Sales", base_salary: 50000 },
  { id: 7, title: "Marketing Coordinator", department: "Marketing", base_salary: 55000 },
  { id: 8, title: "Financial Controller", department: "Finance", base_salary: 95000 },
  { id: 9, title: "UX/UI Designer", department: "Design", base_salary: 85000 },
  { id: 10, title: "DevOps Engineer", department: "Infrastructure", base_salary: 115000 },
  { id: 11, title: "Customer Success Manager", department: "Operations", base_salary: 70000 },
  { id: 12, title: "CTO", department: "Executive", base_salary: 200000 },
  { id: 13, title: "CFO", department: "Executive", base_salary: 190000 },
  { id: 14, title: "Office Manager", department: "Administration", base_salary: 50000 }
]

first_names = ["James", "Mary", "Robert", "Patricia", "John", "Jennifer", "Michael", "Linda", "David", "Elizabeth", "William", "Barbara", "Richard", "Susan", "Joseph", "Jessica", "Thomas", "Sarah", "Christopher", "Karen", "Charles", "Lisa", "Daniel", "Nancy", "Matthew", "Betty", "Anthony", "Sandra", "Mark", "Margaret", "Donald", "Ashley", "Steven", "Kimberly", "Paul", "Emily", "Andrew", "Donna", "Joshua", "Michelle", "Kevin", "Dorothy", "Brian", "Carol", "George", "Amanda", "Edward", "Melissa", "Ronald", "Deborah"]
last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts"]

# 1. Generate Job Titles CSV
CSV.open("job_titles.csv", "wb") do |csv|
  csv << ["id", "title", "department", "base_salary"]
  job_titles_list.each do |job|
    csv << [job[:id], job[:title], job[:department], job[:base_salary]]
  end
end

# 2. Generate Employees CSV
CSV.open("employees.csv", "wb") do |csv|
  csv << ["id", "first_name", "last_name", "email", "job_title_id", "salary", "hire_date"]

  RECORD_COUNT.times do |i|
    first_name = first_names.sample
    last_name = last_names.sample
    email = "#{first_name.downcase}.#{last_name.downcase}.#{i + 1}@example-corp.com"
    
    job = job_titles_list.sample
    # Add some variance to salary (+/- 20% of base)
    variance = (job[:base_salary] * 0.2 * (rand - 0.5)).to_i
    salary = job[:base_salary] + variance
    
    hire_date = Date.today - rand(365 * 15) # Hired in last 15 years

    csv << [i + 1, first_name, last_name, email, job[:id], salary, hire_date]
  end
end

puts "Successfully generated:"
puts "- job_titles.csv (14 rows)"
puts "- employees.csv (1000 rows)"
