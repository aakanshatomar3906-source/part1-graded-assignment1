
1. students Table

Key Columns:

student_id: The system-generated internal string (e.g., S0001) that serves as the Primary Key. It acts as a lightweight pointer throughout execution transaction logs.

roll_number: The official university registration identifier (e.g., CJ250001). This is an Alternate Key enforced with a UNIQUE constraint to ensure academic accountability.

email: Student's institutional communication address. Note that this field is structurally nullable within the CodeJudge environment because raw ingest files (like student S0005) occasionally lack active emails during early course configuration phases.

Data Integration Links: Connects down to transactional histories via student_id in the enrollments, submissions, and regrade_requests tables.

2. courses Table
What it represents: The curriculum master catalog mapping independent tracking paths (e.g., Data Structures, Operating Systems).

Key Columns:

course_id: The system-generated internal token (e.g., C001) acting as the immutable Primary Key.

course_code: The human-readable department catalog shorthand (e.g., CS301).

Critical Normalization Insight: In the CodeJudge dataset, course_code is NOT unique standalone. For instance, both Web Backend Engineering (C009) and Distributed Systems (C010) share the code CS301. To prevent data corruption, a composite unique key constraint UNIQUE (course_code, course_title) must be established at the DBMS engine layer.

3. problems Table
What it represents: The absolute index of standalone coding exercises designed for student assignments and exams.

Key Columns:

problem_id: The internal surrogate Primary Key uniquely tracking an assignment (e.g., P0001).

course_id: A Foreign Key pointing back to courses(course_id), detailing which academic track owns this evaluation problem.

problem_code: A localized unique string (e.g., CS101_P01) utilized as a candidate system lookup index.

max_score: An integer storing the total points available for perfectly satisfying all test requirements.


4. enrollments Table
What it represents: A classic Many-to-Many Bridge Table mapping the relationships between students and the specific academic courses they are taking.

Key Columns:

enrollment_id: A dedicated surrogate Primary Key identifying each registration transaction line.

student_id & course_id: Dual Foreign Keys tying a specific user to a particular course room.

final_grade: Character grading metric (e.g., 'A', 'B', 'F'). This field must remain nullable because active student tracks do not have an official letter grade posted until the term concludes.

DBMS Integrity Constraint: A critical multi-column composite unique constraint UNIQUE (student_id, course_id) is enforced. This blocks database corruption by preventing a student from being registered into the exact same course section multiple times simultaneously.

5. contests Table
What it represents: Synchronous assessment periods or timed coding competitions configured by instructors.

Key Columns:

contest_id: Internal token (e.g., CT001) acting as the Primary Key.

course_id: Foreign Key ensuring the event scales strictly within the domain boundary of its parent course module.

start_time & end_time: Strict system TIMESTAMP blocks. They are configured as NOT NULL to drive backend job schedulers that automatically lock and close the grading runtime sandbox when the competitive window expires.

6. contest_problems Table
What it represents: A specialized Many-to-Many Resolution Bridge connecting contests and static programming problems. A problem (like Two Sum) can be reused across different midterms over separate semesters, while a single contest contains multiple distinct problems.

Key Columns:

contest_id & problem_id: Combined to form a natural Composite Primary Key PRIMARY KEY (contest_id, problem_id). This eliminates the need for an unnecessary surrogate index while naturally blocking an instructor from attaching the same programming problem to a single test multiple times.

problem_order: An integer tracking UI presentation order (e.g., Question 1 vs. Question 2).

7. test_cases Table
What it represents: The automated evaluation framework. It holds the hidden validation parameters (inputs and expected outputs) used to check student code submissions.

Key Columns:

test_case_id: The Primary Key tracking individual validation configurations.

problem_id: Foreign Key mapping the test asset back to its target coding challenge.

case_no: Sequential integer trackers. The database enforces a composite unique configuration UNIQUE (problem_id, case_no) to prevent execution sequence overlaps.

8. sessions Table
What it represents: The timeline log tracking specific instructional units, lab practices, or workshop dates scheduled under a course timeline.

Key Columns:

session_id: Independent surrogate tracking Primary Key.

course_id: Foreign Key pointing straight up to courses(course_id).


9. submissions Table
What it represents: The core operational log that tracks every instance of code sent by a student to the CodeJudge remote evaluation sandbox.

Key Columns:

submission_id: The transactional Primary Key tracking the lifecycle of an evaluation job (e.g., SUB000001).

student_id & problem_id: Highly indexed Foreign Keys tracking who sent code and which assignment they attempted.

contest_id: A nullable Foreign Key linking the attempt to an active exam. This field is deliberately left optional because students can complete general homework or practice questions outside of an organized contest window.

10. test_results Table
What it represents: The granular execution log of a submission. When a student submits code, it runs against multiple distinct test cases in the sandbox environment. This table logs the outcome of each execution checkpoint.

Key Columns:

result_id: Surrogate ledger tracking Primary Key.

submission_id & test_case_id: Dual Foreign Keys mapping an execution run straight to a specific code submission and test configuration profile.

System Observability Design: A composite unique constraint UNIQUE (submission_id, test_case_id) prevents the database from storing redundant execution logs for the exact same test case run within a single submission window.

11. plagiarism_flags Table
What it represents: The audit engine ledger populated by anti-cheat automated scanning routines (such as MOSS text/structure matching engines).

Key Columns:

flag_id: Administrative surrogate Primary Key.

submission_id & matched_submission_id: Interlinked Foreign Keys pointing back to two distinct source rows in submissions. This tracks the suspect entry against the potential source match.

similarity_score: A precise decimal (NUMERIC(5,2)) capturing the source code similarity percentage.

12. regrade_requests Table
What it represents: The workflow tracking ledger managing student grading disputes (e.g., appealing automated test failures due to compilation environment issues).

Key Columns:

request_id: The Primary Key controlling the workflow row.

submission_id: Foreign Key isolating the disputed submission entry.

request_status: State trackers (e.g., 'open', 'approved', 'rejected') that manage administrative workflows.

D. System Operational Ledger (Administrative Logs)
13. operation_requests Table
What it represents: An audit trail tracking database management actions executed by administrators or mentors (such as database cleanups or record drops).

Key Columns:

operation_id: Surrogate audit Primary Key.

operation_type: Administrative action descriptors (e.g., 'MERGE', 'UPDATE', 'DROP').

target_table & target_record_id: Text metadata blocks mapping which target rows in the production system were touched or modified during data cleanups.
