-- ==========================================
-- 1. INDEPENDENT / CORE LOOKUP TABLES
-- ==========================================

-- Table for tracking raw student data ingestion/imports
CREATE TABLE raw_student_import (
    raw_row_id VARCHAR(50) PRIMARY KEY,
    roll_number VARCHAR(50),
    full_name VARCHAR(255),
    email VARCHAR(255),
    batch_code VARCHAR(50),
    admission_date DATE,
    import_status VARCHAR(50), -- e.g., 'new', 'validated', 'rejected'
    import_notes TEXT
);

-- Table for system operational logs and administrative requests
CREATE TABLE operation_requests (
    operation_id VARCHAR(50) PRIMARY KEY,
    requested_by VARCHAR(255),
    operation_type VARCHAR(50), -- e.g., 'MERGE', 'UPDATE', 'DELETE', 'INSERT', 'DROP'
    target_table VARCHAR(100),
    target_record_id VARCHAR(50),
    requested_at TIMESTAMP,
    reason TEXT,
    approval_status VARCHAR(50), -- e.g., 'pending', 'approved', 'rejected'
    executed_at TIMESTAMP
);

-- Table for managing student accounts
CREATE TABLE students (
    student_id VARCHAR(50) PRIMARY KEY,
    roll_number VARCHAR(50) UNIQUE,
    full_name VARCHAR(255),
    email VARCHAR(255),
    batch_id VARCHAR(50),
    admission_date DATE,
    enrollment_status VARCHAR(50), -- e.g., 'active', 'inactive', 'dropped'
    graduation_year INT
);

-- Table for tracking available academic courses
CREATE TABLE courses (
    course_id VARCHAR(50) PRIMARY KEY,
    course_code VARCHAR(50) UNIQUE,
    course_title VARCHAR(255),
    course_status VARCHAR(50), -- e.g., 'active', 'archived', 'draft'
    credit_hours INT
);

-- ==========================================
-- 2. COURSE MANAGEMENT & RELATIONSHIPS
-- ==========================================

-- Many-to-Many relationship table linking students to courses
CREATE TABLE enrollments (
    enrollment_id VARCHAR(50) PRIMARY KEY,
    student_id VARCHAR(50) REFERENCES students(student_id),
    course_id VARCHAR(50) REFERENCES courses(course_id),
    enrolled_on DATE,
    enrollment_status VARCHAR(50), -- e.g., 'active', 'completed', 'dropped'
    final_grade VARCHAR(10)        -- e.g., 'A', 'B', 'C', 'D', 'F'
);

-- Table for active academic sessions, lectures, or labs
CREATE TABLE sessions (
    session_id VARCHAR(50) PRIMARY KEY,
    course_id VARCHAR(50) REFERENCES courses(course_id),
    session_title VARCHAR(255),
    session_date DATE,
    session_type VARCHAR(50) -- e.g., 'lab', 'lecture', 'tutorial', 'workshop'
);

-- Table for coding problems mapped to specific courses
CREATE TABLE problems (
    problem_id VARCHAR(50) PRIMARY KEY,
    course_id VARCHAR(50) REFERENCES courses(course_id),
    problem_code VARCHAR(100) UNIQUE,
    title VARCHAR(255),
    difficulty VARCHAR(50), -- e.g., 'Easy', 'Medium', 'Hard'
    max_score INT,
    created_at DATE,
    is_active INT -- 1 for active, 0 for inactive
);

-- Table for assessment or evaluation contests
CREATE TABLE contests (
    contest_id VARCHAR(50) PRIMARY KEY,
    course_id VARCHAR(50) REFERENCES courses(course_id),
    contest_title VARCHAR(255),
    start_time TIMESTAMP,
    end_time TIMESTAMP,
    contest_status VARCHAR(50) -- e.g., 'published', 'completed'
);

-- Many-to-Many relationship table linking contests and problems
CREATE TABLE contest_problems (
    contest_id VARCHAR(50) REFERENCES contests(contest_id),
    problem_id VARCHAR(50) REFERENCES problems(problem_id),
    problem_order INT,
    PRIMARY KEY (contest_id, problem_id)
);

-- ==========================================
-- 3. EVALUATION, TEST CASES, & SUBMISSIONS
-- ==========================================

-- Table specifying individual validation tests for each problem
CREATE TABLE test_cases (
    test_case_id VARCHAR(50) PRIMARY KEY,
    problem_id VARCHAR(50) REFERENCES problems(problem_id),
    case_no INT,
    input_label VARCHAR(100),
    expected_output_label VARCHAR(100),
    points INT,
    is_hidden INT -- 1 for hidden/private test case, 0 for public
);

-- Table for keeping track of all student code submissions
CREATE TABLE submissions (
    submission_id VARCHAR(50) PRIMARY KEY,
    student_id VARCHAR(50) REFERENCES students(student_id),
    problem_id VARCHAR(50) REFERENCES problems(problem_id),
    contest_id VARCHAR(50) REFERENCES contests(contest_id),
    language VARCHAR(50), -- e.g., 'Python', 'Java', 'C++', 'Go', 'JavaScript'
    submitted_at TIMESTAMP,
    status VARCHAR(100), -- e.g., 'Accepted', 'Wrong Answer', 'Runtime Error', 'Compilation Error'
    score INT,
    runtime_ms INT
);

-- Table for granular execution result per submission test case
CREATE TABLE test_results (
    result_id VARCHAR(50) PRIMARY KEY,
    submission_id VARCHAR(50) REFERENCES submissions(submission_id),
    test_case_id VARCHAR(50) REFERENCES test_cases(test_case_id),
    result_status VARCHAR(100), -- e.g., 'Passed', 'Failed', 'Runtime Error', 'Time Limit Exceeded'
    runtime_ms INT,
    memory_kb INT,
    awarded_points INT
);

-- ==========================================
-- 4. DEPENDENT / AUDIT TABLES
-- ==========================================

-- Table for plagiarism monitoring flags on submissions
CREATE TABLE plagiarism_flags (
    flag_id VARCHAR(50) PRIMARY KEY,
    submission_id VARCHAR(50) REFERENCES submissions(submission_id),
    matched_submission_id VARCHAR(50) REFERENCES submissions(submission_id),
    similarity_score NUMERIC(5, 2),
    flag_status VARCHAR(50), -- e.g., 'new', 'confirmed', 'cleared', 'reviewing'
    created_at TIMESTAMP
);

-- Table for student-initiated grading dispute workflows
CREATE TABLE regrade_requests (
    request_id VARCHAR(50) PRIMARY KEY,
    submission_id VARCHAR(50) REFERENCES submissions(submission_id),
    student_id VARCHAR(50) REFERENCES students(student_id),
    requested_at TIMESTAMP,
    reason TEXT, -- e.g., 'Score mismatch', 'Runtime issue'
    request_status VARCHAR(50), -- e.g., 'open', 'approved', 'rejected', 'closed'
    resolved_at TIMESTAMP
);
