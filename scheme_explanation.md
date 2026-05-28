1. Students 
Why a separate table: It represents the core user entity. Storing student details separately avoids duplicating biographical data (names, emails) across every course enrollment or code submission.

Primary Key: student_id (e.g., S0001) — unique platform-wide internal identifier.

Foreign Keys: None 

Composite Keys: None required.

Unique Columns: roll_number (academic identifier) and email (communication identity).

NOT NULL Columns: student_id, roll_number, full_name, enrollment_status.

2. Courses
Why a separate table: A course acts as an independent structural container for academic subjects. It has its own properties (title, credits) that exist independently of individual students or specific assignments.

Primary Key: course_id (e.g., C001).

Foreign Keys: None.

Composite Keys: None required.

Unique Columns: course_code (e.g., CS101, CS202).

NOT NULL Columns: course_id, course_code, course_title, course_status.

3. Enrollments
Why a separate table: This captures a Many-to-Many relationship between Students and Courses. A student can take multiple courses, and a course has many students. Storing this mapping independently tracks dates and final grades per student-course pairing.

Primary Key: enrollment_id (e.g., E00001).

Foreign Keys: * student_id referencing students(student_id)

course_id referencing courses(course_id)

Composite Keys: You could alternatively use a composite primary key (student_id, course_id) to strictly guarantee a student cannot enroll in the exact same course twice, though a surrogate enrollment_id with a unique constraint on the pair works cleanly.

Unique Columns: The combination of (student_id, course_id).

NOT NULL Columns: enrollment_id, student_id, course_id, enrolled_on, enrollment_status.

4. Problems
Why a separate table: Coding exercises are reusable standalone assets. They hold metadata (problem statements, difficulty levels, maximum scores) that remain static regardless of which student solves them or what contest utilizes them.

Primary Key: problem_id (e.g., P0001).

Foreign Keys: course_id referencing courses(course_id) (maps which course owns the problem).

Composite Keys: None required.

Unique Columns: problem_code (e.g., CS101_P01).

NOT NULL Columns: problem_id, course_id, problem_code, title, difficulty, max_score, is_active.

5. Test Cases
Why a separate table: Every individual programming problem contains multiple testing verification vectors (inputs and expected outputs). Putting them in a distinct table creates a One-to-Many relationship (one problem has many test cases) so problems don't get bloated with unstructured text fields.

Primary Key: test_case_id (e.g., TC00001).

Foreign Keys: problem_id referencing problems(problem_id).

Composite Keys: None required, though a composite unique key can be set on (problem_id, case_no).

Unique Columns: The combination of (problem_id, case_no) to prevent duplicate numbered tests inside a single problem context.

NOT NULL Columns: test_case_id, problem_id, case_no, input_label, expected_output_label, points, is_hidden.

6. Contests ("con / contest")
Why a separate table: Contests represent isolated evaluation events with distinct operational properties like specific open window intervals (start_time, end_time) and status triggers.

Primary Key: contest_id (e.g., CT001).

Foreign Keys: course_id referencing courses(course_id).

Composite Keys: None required.

Unique Columns: None fundamentally required, though contest_title can be made unique if required by business logic.

NOT NULL Columns: contest_id, course_id, contest_title, start_time, end_time, contest_status.

7. Contest Problem Mapping
Why a separate table: This is a Many-to-Many breaking table between Contests and Problems. A single problem can be reused across multiple contests over different semesters, and one contest features multiple problems.

Primary Key: A Composite Key consisting of (contest_id, problem_id).

Foreign Keys:

contest_id referencing contests(contest_id)

problem_id referencing problems(problem_id)

Unique Columns: Handled entirely by the implicit uniqueness of the composite primary key.

NOT NULL Columns: contest_id, problem_id, problem_order.

8. Submissions
Why a separate table: Tracks the dynamic transaction of code execution over time. Submissions grow rapidly and contain specialized metrics (programming language, submission timestamp, code execution verdict status).

Primary Key: submission_id (e.g., SUB000001).

Foreign Keys:

student_id referencing students(student_id)

problem_id referencing problems(problem_id)

contest_id referencing contests(contest_id) (nullable if it's a general practice submission outside a contest context).

Composite Keys: None required.

Unique Columns: None (a student can submit code for the same problem multiple times).

NOT NULL Columns: submission_id, student_id, problem_id, language, submitted_at, status, score.

9. Test Results
Why a separate table: This stores atomic execution checkpoints. When a submission runs, it encounters 5–10 different test cases. Saving the outcome for each test case individually allows students to drill down into precisely where their code failed (e.g., Time Limit Exceeded on Test Case 4).

Primary Key: result_id (e.g., R0000001).

Foreign Keys:

submission_id referencing submissions(submission_id)

test_case_id referencing test_cases(test_case_id)

Composite Keys: A composite unique alternative can be enforced on (submission_id, test_case_id).

Unique Columns: The combination of (submission_id, test_case_id).

NOT NULL Columns: result_id, submission_id, test_case_id, result_status, runtime_ms, memory_kb, awarded_points.

10. Sessions (Attendance logs container)
Why a separate table: Tracks physical or virtual timeline interactions (like specific lab dates, lecture units, or workshops) tied to a course.

Primary Key: session_id (e.g., SES0001).

Foreign Keys: course_id referencing courses(course_id).

Composite Keys: None required.

Unique Columns: None required (multiple sessions can occur on the same date).

NOT NULL Columns: session_id, course_id, session_title, session_date, session_type.

11. Regrade Requests ("regret request")
Why a separate table: Represents a workflow ledger for student grievances. Separating it keeps the highly unstable operational data of disputes (reasons, approval statuses, resolutions timestamps) from polluting core static execution records.

Primary Key: request_id (e.g., RG0001).

Foreign Keys:

submission_id referencing submissions(submission_id)

student_id referencing students(student_id)

Composite Keys: None required.

Unique Columns: submission_id (if business criteria dictates a student can only appeal a particular submission once).

NOT NULL Columns: request_id, submission_id, student_id, requested_at, reason, request_status.

12. Plagiarism Flags ("algorithm flag")
Why a separate table: Generated automatically by anti-cheat comparison algorithms (MOSS/similar tooling). It documents matching criteria between two separate submission sources. Isolating it guarantees fast query execution for audit safety checks.

Primary Key: flag_id (e.g., PF0001).

Foreign Keys:

submission_id referencing submissions(submission_id) (The suspect code)

matched_submission_id referencing submissions(submission_id) (The source code it matches)

Composite Keys: None required.

Unique Columns: The combination of (submission_id, matched_submission_id).

NOT NULL Columns: flag_id, submission_id, matched_submission_id, similarity_score, flag_status, created_at.

13. Raw Student Import ("grow importer")
Why a separate table: Acts as a temporal landing/staging zone area for unvalidated batch CSV bulk uploads. This isolates garbage, malformed data, or incorrect formatting from accidentally corrupting the production-ready Students registry table.

Primary Key: raw_row_id (e.g., RSI0001).

Foreign Keys: None.

Composite Keys: None.

Unique Columns: None (raw file streams can contain duplicate records natively).

NOT NULL Columns: raw_row_id, import_status.

14. Operation Requests
Why a separate table: An administrative transaction history log tracking system modifications (such as table modifications, mass record drops, or sensitive row deletion updates). Keeping this independent preserves clean system observability.

Primary Key: operation_id (e.g., OP0001).

Foreign Keys: None (or references a system user/admin accounts table if available).

Composite Keys: None.

Unique Columns: None.

NOT NULL Columns: operation_id, requested_by, operation_type, target_table, requested_at, approval_status

