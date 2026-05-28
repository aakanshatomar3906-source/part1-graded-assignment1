1. students Table
Primary Key (PK): student_id

DBMS Justification: It acts as the immutable, internal surrogate key. It uses a short, system-generated alphanumeric format (e.g., S0001), which minimizes the storage footprint index when used as a foreign key in massive transaction tables like submissions.

Candidate Keys: student_id, roll_number, email

DBMS Justification: All three attributes uniquely identify a single student across the platform.

Alternate Keys: roll_number, email

DBMS Justification: These are candidate keys not chosen as the primary key. They represent clean business-world unique fields.

Foreign Keys (FK): None (Note: batch_id references an external batches scope entity).

Unique Constraints: UNIQUE(roll_number), UNIQUE(email)

DBMS Justification: Enforcing a unique index on email prevents a student from registering twice, and a unique constraint on roll_number guarantees academic accountability during grade exports.

NOT NULL Constraints: student_id, roll_number, full_name, enrollment_status, graduation_year

DBMS Justification: full_name is critical for identity; enrollment_status prevents logical evaluation bugs when querying active students. (Note: email is left nullable in your dataset, as seen in record S0005, where the email field is blank).

2. courses Table
Primary Key (PK): course_id

DBMS Justification: Provides an independent, surrogate identity block (e.g., C001) to isolate internal row links from external curriculum code updates.

Candidate Keys: course_id, course_code

Alternate Keys: course_code

DBMS Justification: Standard academic course code designations (e.g., CS101, CS102) must be unique but shouldn't serve as the primary key if formatting structures change regionally.

Foreign Keys (FK): None.

Unique Constraints: UNIQUE(course_code)

DBMS Justification: Prevents administrators from creating two distinct course rows for the exact same subject track.

NOT NULL Constraints: course_id, course_code, course_title, course_status, credit_hours

DBMS Justification: A course missing its baseline status, credits, or title renders downstream GPA metrics and grading computations mathematically broken.

3. enrollments Table
Primary Key (PK): enrollment_id

DBMS Justification: A surrogate identifier (e.g., E00001) that simplifies referencing specific transaction state rows for automated system workflows.

Candidate Keys: enrollment_id, (student_id, course_id)

Alternate Keys: (student_id, course_id)

Composite Key / Unique Constraint: UNIQUE(student_id, course_id)

DBMS Justification: This is a critical multi-column composite unique constraint. It prevents a student from being enrolled in the exact same course multiple times concurrently, eliminating data redundancy.

Foreign Keys (FK):

student_id REFERENCES students(student_id)

course_id REFERENCES courses(course_id)

DBMS Justification: Enforces referential integrity. The database will reject any enrollment record tied to a non-existent student or course.

NOT NULL Constraints: enrollment_id, student_id, course_id, enrolled_on, enrollment_status

DBMS Justification: final_grade is left nullable because grades remain blank until a student completes the course syllabus cycle.

4. problems Table
Primary Key (PK): problem_id

DBMS Justification: An internal surrogate system token (e.g., P0001) allowing independent assignment management.

Candidate Keys: problem_id, problem_code

Alternate Keys: problem_code

Unique Constraints: UNIQUE(problem_code)

DBMS Justification: Ensures localized strings (e.g., CS101_P01) cannot be replicated across separate programming exercises.

Foreign Keys (FK): course_id REFERENCES courses(course_id)

DBMS Justification: Ties the code assessment task securely to its parent course silo.

NOT NULL Constraints: problem_id, course_id, problem_code, title, difficulty, max_score, created_at, is_active

DBMS Justification: Parameters like max_score and difficulty must always exist to allow autograders to score submissions and to render UI difficulty filters correctly.

5. test_cases Table
Primary Key (PK): test_case_id

DBMS Justification: System identifier (e.g., TC00001) ensuring distinct atomicity for test configurations.

Candidate Keys: test_case_id, (problem_id, case_no)

Alternate Keys: (problem_id, case_no)

Composite Key / Unique Constraint: UNIQUE(problem_id, case_no)

DBMS Justification: Ensures test cases inside a specific coding challenge follow a predictable sequence (e.g., Problem 1 cannot have two test cases labeled as case_no = 1).

Foreign Keys (FK): problem_id REFERENCES problems(problem_id)

DBMS Justification: Ensures test constraints cannot exist without an active assignment problem.

NOT NULL Constraints: test_case_id, problem_id, case_no, input_label, expected_output_label, points, is_hidden

DBMS Justification: Missing input/output descriptors would cause the code sandbox interpreter to fail during code evaluations.

6. contests Table
Primary Key (PK): contest_id

DBMS Justification: A unique platform tracker (e.g., CT001) handling live tracking event timelines.

Candidate Keys: contest_id

Foreign Keys (FK): course_id REFERENCES courses(course_id)

NOT NULL Constraints: contest_id, course_id, contest_title, start_time, end_time, contest_status

DBMS Justification: Timestamp parameters (start_time, end_time) must be populated to prevent scheduling anomalies, ensuring the testing window closes reliably.

7. contest_problems Table
Primary Key (PK) & Composite Key: PRIMARY KEY (contest_id, problem_id)

DBMS Justification: As an elegant pure Many-to-Many Bridge Table, a separate surrogate ID is unnecessary. The multi-column composite key handles uniqueness naturally, ensuring an assignment cannot be added to the same contest twice.

Foreign Keys (FK):

contest_id REFERENCES contests(contest_id)

problem_id REFERENCES problems(problem_id)

DBMS Justification: Protects the bridge context from referencing phantom contests or problems.

NOT NULL Constraints: contest_id, problem_id, problem_order

DBMS Justification: problem_order is required to display questions in the correct sequence on the contest dashboard (e.g., Question 1, Question 2).

8. submissions Table
Primary Key (PK): submission_id

DBMS Justification: A unique ledger tag tracking transactional records (e.g., SUB000001).

Candidate Keys: submission_id

Foreign Keys (FK):

student_id REFERENCES students(student_id)

problem_id REFERENCES problems(problem_id)

contest_id REFERENCES contests(contest_id) (Nullable)

DBMS Justification: Maintains a clear relationship showing who submitted, what problem they attempted, and where (if part of a contest). contest_id must remain nullable to support casual out-of-contest homework or practice.

NOT NULL Constraints: submission_id, student_id, problem_id, language, submitted_at, status, score, runtime_ms

DBMS Justification: Fields like execution language and score must be non-nullable to prevent gaps in academic performance data and metric tracking.

9. test_results Table
Primary Key (PK): result_id

DBMS Justification: Unique log item identifier (e.g., R0000001) for precise tracking.

Candidate Keys: result_id, (submission_id, test_case_id)

Alternate Keys: (submission_id, test_case_id)

Composite Key / Unique Constraint: UNIQUE(submission_id, test_case_id)

DBMS Justification: Prevents a submission from storing duplicate evaluation rows for the exact same test case.

Foreign Keys (FK):

submission_id REFERENCES submissions(submission_id)

test_case_id REFERENCES test_cases(test_case_id)

DBMS Justification: Protects transactional integrity by linking every test result to an existing submission and test configuration.

NOT NULL Constraints: All columns.

DBMS Justification: If values like result_status (e.g., 'Passed', 'Failed'), runtime_ms, or awarded_points are missing, the student's cumulative grade calculation will fail.
