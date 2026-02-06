require 'csv'
require 'date'

# Configuration
RECORD_COUNT = 1000
RESIGN_COUNT = 70

# 1. Departments Hierarchy
departments_list = [
  { id: 1, name: "Engineering" },
  { id: 2, name: "Product" },
  { id: 3, name: "Data Science" },
  { id: 4, name: "Human Resources" },
  { id: 5, name: "Sales" },
  { id: 6, name: "Marketing" },
  { id: 7, name: "Finance" },
  { id: 8, name: "Design" },
  { id: 9, name: "Infrastructure" },
  { id: 10, name: "Operations" },
  { id: 11, name: "Executive" },
  { id: 12, name: "Administration" }
]

# 2. Education Degrees
education_list = [
  { id: 1, degree: "High School" },
  { id: 2, degree: "Associate's Degree" },
  { id: 3, degree: "Bachelor's Degree" },
  { id: 4, degree: "Master's Degree" },
  { id: 5, degree: "Doctorate (PhD)" }
]

# 3. Job Titles
job_titles_list = [
  { id: 1, title: "Junior Software Engineer", dept_id: 1, base_salary: 60000 },
  { id: 2, title: "Senior Software Engineer", dept_id: 1, base_salary: 120000 },
  { id: 3, title: "Product Manager", dept_id: 2, base_salary: 100000 },
  { id: 4, title: "Data Scientist", dept_id: 3, base_salary: 110000 },
  { id: 5, title: "HR Business Partner", dept_id: 4, base_salary: 80000 },
  { id: 6, title: "Sales Executive", dept_id: 5, base_salary: 50000 },
  { id: 7, title: "Marketing Coordinator", dept_id: 6, base_salary: 55000 },
  { id: 8, title: "Financial Controller", dept_id: 7, base_salary: 95000 },
  { id: 9, title: "UX/UI Designer", dept_id: 8, base_salary: 85000 },
  { id: 10, title: "DevOps Engineer", dept_id: 9, base_salary: 115000 },
  { id: 11, title: "Customer Success Manager", dept_id: 10, base_salary: 70000 },
  { id: 12, title: "CTO", dept_id: 11, base_salary: 200000 },
  { id: 13, title: "CFO", dept_id: 11, base_salary: 190000 },
  { id: 14, title: "Office Manager", dept_id: 12, base_salary: 50000 }
]

male_names = ["James", "Robert", "John", "Michael", "David", "William", "Richard", "Joseph", "Thomas", "Christopher", "Charles", "Daniel", "Matthew", "Anthony", "Mark", "Donald", "Steven", "Paul", "Andrew", "Joshua", "Kevin", "Brian", "George", "Edward", "Ronald"]
female_names = ["Mary", "Patricia", "Jennifer", "Linda", "Elizabeth", "Barbara", "Susan", "Jessica", "Sarah", "Karen", "Lisa", "Nancy", "Betty", "Sandra", "Margaret", "Ashley", "Kimberly", "Emily", "Donna", "Michelle", "Dorothy", "Carol", "Amanda", "Melissa", "Deborah"]
last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones", "Garcia", "Miller", "Davis", "Rodriguez", "Martinez", "Hernandez", "Lopez", "Gonzalez", "Wilson", "Anderson", "Thomas", "Taylor", "Moore", "Jackson", "Martin", "Lee", "Perez", "Thompson", "White", "Harris", "Sanchez", "Clark", "Ramirez", "Lewis", "Robinson", "Walker", "Young", "Allen", "King", "Wright", "Scott", "Torres", "Nguyen", "Hill", "Flores", "Green", "Adams", "Nelson", "Baker", "Hall", "Rivera", "Campbell", "Mitchell", "Carter", "Roberts"]

# Export Lookup Tables
CSV.open("departments.csv", "wb") { |csv| csv << ["id", "name"]; departments_list.each { |d| csv << [d[:id], d[:name]] } }
CSV.open("education.csv", "wb") { |csv| csv << ["id", "degree"]; education_list.each { |e| csv << [e[:id], e[:degree]] } }
CSV.open("job_titles.csv", "wb") { |csv| csv << ["id", "title", "department_id", "base_salary"]; job_titles_list.each { |j| csv << [j[:id], j[:title], j[:dept_id], j[:base_salary]] } }

# Generate Employees and Satisfaction Data
resigned_indices = (0...RECORD_COUNT).to_a.sample(RESIGN_COUNT)

CSV.open("employees.csv", "wb") do |csv_emp|
  CSV.open("satisfaction.csv", "wb") do |csv_sat|
    csv_emp << ["id", "first_name", "last_name", "email", "gender", "birth_date", "job_title_id", "education_id", "salary", "hire_date", "resign_date"]
    csv_sat << ["employee_id", "score", "survey_date", "feedback"]

    RECORD_COUNT.times do |i|
      emp_id = i + 1
      gender = ["Male", "Female"].sample
      first_name = gender == "Male" ? male_names.sample : female_names.sample
      last_name = last_names.sample
      email = "#{first_name.downcase}.#{last_name.downcase}.#{emp_id}@example-corp.com"
      birth_date = Date.today - (20 * 365 + rand(45 * 365))
      
      job = job_titles_list.sample
      education = education_list.sample
      
      edu_bonus = case education[:id]
                  when 5 then 1.10
                  when 4 then 1.05
                  when 1 then 0.95
                  else 1.0
                  end
      
      variance = (job[:base_salary] * edu_bonus * 0.15 * (rand - 0.5)).to_i
      salary = (job[:base_salary] * edu_bonus).to_i + variance
      
      hire_date = Date.today - (1 + rand(365 * 10))
      resign_date = resigned_indices.include?(i) ? hire_date + rand((Date.today - hire_date).to_i) : nil

      csv_emp << [emp_id, first_name, last_name, email, gender, birth_date, job[:id], education[:id], salary, hire_date, resign_date]

      # Satisfaction score (NPS: 0-10)
      # Skew slightly positive, but detractors exist
      score = [rand(11), rand(7..10), rand(8..10)].sample 
      survey_date = Date.today - rand(30) # Surveyed in last month
      feedback = ["Great company!", "Love the culture", "Need better coffee", "Growth opportunities are good", "Work-life balance is okay", "Excellent benefits"].sample

      csv_sat << [emp_id, score, survey_date, feedback]
    end
  end
end

puts "Successfully generated normalized data and satisfaction surveys (NPS Ready)."
