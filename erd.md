┌────────────────────────┐               ┌────────────────────────┐
      │        students        │               │        courses         │
      ├────────────────────────┤               ├────────────────────────┤
      │ PK  student_id         │               │ PK  course_id          │
      │ UK  roll_number        │               │ UK  (course_code,      │
      │     full_name          │               │      course_title)     │
      │     email              │               │     course_status      │
      │     enrollment_status  │               │     credit_hours       │
      └───────────┬────────────┘               └───────────┬────────────┘
                  │ 1                                      │ 1
                  │                                        ├──────────────────────┐
                  │                                        │ 1                    │ 1
                  │ N                                      │ N                    │ N
      ┌───────────▼────────────┐               ┌───────────▼────────────┐  ┌──────┴─────────────────┐
      │      enrollments       │               │        contests        │  │        problems        │
      ├────────────────────────┤               ├────────────────────────┤  ├────────────────────────┤
      │ PK  enrollment_id      │               │ PK  contest_id         │  │ PK  problem_id         │
      │ FK  student_id ────────┼────────┐      │ FK  course_id          │  │ FK  course_id          │
      │ FK  course_id          │        │      │     contest_title      │  │ UK  problem_code       │
      │     enrollment_status  │        │      │     start_time         │  │     title              │
      │     final_grade        │        │      │     contest_status     │  │     max_score          │
      └────────────────────────┘        │      └───────────┬────────────┘  └──────────┬─────────────┘
                                        │                  │ 1                        │ 1
                                        │                  │                          │
                                        │                  │ N                        │ N
                                        │      ┌───────────▼──────────────────────────▼──────────┐
                                        │      │               contest_problems                  │
                                        │      ├─────────────────────────────────────────────────┤
                                        │      │ PK, FK1  contest_id                             │
                                        │      │ PK, FK2  problem_id                             │
                                        │      │          problem_order                          │
                                        │      └─────────────────────────────────────────────────┘
                                        │
                                        │                                             │ 1
                                        │                                             │
                                        │                                             │ N
                                        │                                  ┌──────────▼─────────────┐
                                        │                                  │       test_cases       │
                                        │                                  ├────────────────────────┤
                                        │                                  │ PK  test_case_id       │
                                        │                                  │ FK  problem_id         │
                                        │                                  │ UK  (problem_id,       │
                                        │                                  │      case_no)          │
                                        │                                  │     points, is_hidden  │
                                        │                                  └──────────┬─────────────┘
                                        │                                             │ 1
                                        │ N                                           │
                        ┌───────────────▼────────────────────────┐                    │
                        │              submissions               │                    │
                        ├────────────────────────────────────────┤                    │
                        │ PK  submission_id                      │                    │
                        │ FK  student_id                         │                    │
                        │ FK  problem_id ────────────────────────┼────────┐           │
                        │ FK  contest_id                         │        │           │
                        │     status, score, language            │        │           │
                        └───────┬───────────────────┬────────────┘        │           │
                                │ 1                 │ 1                   │ N         │ N
                                │                   │                     ┌───────────▼─────────────┐
                                │                   │                     │      test_results       │
                                │                   │                     ├────────────────────────┤
                                │                   │                     │ PK  result_id          │
                                │                   │                     │ FK  submission_id      │
                                │                   │                     │ FK  test_case_id       │
                                │                   │                     │ UK  (submission_id,    │
                                │                   │                     │      test_case_id)     │
                                │                   │                     └────────────────────────┘
                                │ 1                 │ 1
                                │                   │
                                │ 1 (Strict 1:1)    │ 1 (Strict 1:1)
      ┌────────────────────────▼┐               ┌───▼────────────────────┐
      │    plagiarism_flags     │               │    regrade_requests    │
      ├─────────────────────────┤               ├────────────────────────┤
      │ PK  flag_id             │               │ PK  request_id         │
      │ FK  submission_id       │               │ UK  submission_id      │ -- Enforces exactly 1 appeal 
      │ FK  matched_sub_id      │               │ FK  student_id         │    per unique submission.
      │     similarity_score    │               │     request_status     │
      └─────────────────────────┘               └────────────────────────┘
