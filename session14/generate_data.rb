require 'csv'
require 'date'

# Configuration
RECORD_COUNT = 1000
RESIGN_COUNT = 70

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

male_names = ["James", "Robert", "John", "Michael", "David", "William", "Richard", "Joseph", "Thomas", "Christopher", "Charles", "Daniel", "Matthew", "Anthony", "Mark", "Donald", "Steven", "Paul", "Andrew", "Joshua", "Kevin", "Brian", "George", "Edward", "Ronald"]
female_names = ["Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", "Karen", "Lisa", "Nancy", "Betty", "Sandra", "Margaret", "Ashley", "Kimberly", "Emily", "Donna", "Michelle", "Dorothy", "Carol", "Amanda", "Melissa", "Deborah"]
last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts"]

# 1. Generate Job Titles CSV
CSV.open("job_titles.csv", "wb") do |csv|
  csv << ["id", "title", "department", "base_salary"]
  job_titles_list.each do |job|
    csv << [job[:id], job[:title], job[:department], job[:base_salary]]
  end
end

# Select 70 random employee IDs to resign
resigned_indices = (0...RECORD_COUNT).to_a.sample(RESIGN_COUNT)

# 2. Generate Employees CSV (including department and resign_date)
CSV.open("employees.csv", "wb") do |csv|
  csv << ["id", "first_name", "last_name", "email", "gender", "birth_date", "job_title_id", "department", "salary", "hire_date", "resign_date"]

  RECORD_COUNT.times do |i|
    gender = ["Male", "Female"].sample
    first_name = gender == "Male" ? male_names.sample : female_names.sample
    last_name = last_names.sample
    email = "#{first_name.downcase}.#{last_name.downcase}.#{i + 1}@example-corp.com"
    
    birth_date = Date.today - (20 * 365 + rand(45 * 365))
    
    job = job_titles_list.sample
    variance = (job[:base_salary] * 0.2 * (rand - 0.5)).to_i
    salary = job[:base_salary] + variance
    
    hire_date = Date.today - (1 + rand(365 * 10))
    
    resign_date = nil
    if resigned_indices.include?(i)
      # Resign date must be after hire date and before today
      days_worked = (Date.today - hire_date).to_i
      resign_date = hire_date + rand(days_worked)
    end

    csv << [i + 1, first_name, last_name, email, gender, birth_date, job[:id], job[:department], salary, hire_date, resign_date]
  end
end

puts "Successfully updated data generator with department and resign_date (70 records)."
