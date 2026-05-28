The original flat/unstructured database design suffers from three major anomalies:

### 1. Insertion Anomaly

New records cannot be inserted independently.
Example: A new course like **Distributed Systems (C010)** cannot be added unless a student enrollment row also exists, because student-related primary key fields are required.

### 2. Deletion Anomaly

Deleting one transactional row can accidentally remove important master data.
Example: Removing the only enrollment for course **C004** deletes the course information itself from the database.

### 3. Update (Modification) Anomaly

Redundant duplicated data causes inconsistency during updates.
Example: If course code **CS301** appears in hundreds of rows, changing it requires updating every occurrence. Missing even one row creates inconsistent data.

---

# Main Structural Improvements

To eliminate redundancy and anomalies, the schema was decomposed into specialized tables:

* **courses** → stores course metadata once
* **problems** → stores assignment/problem definitions
* **test_cases** → stores static test vectors
* **submissions** → stores student submission transactions
* **test_results** → stores execution outcomes for each test case

This separation creates clean **One-to-Many relationships** and avoids repeated storage of static information.

---

# Dependency Analysis

## Partial Dependency (Violates 2NF)

In a composite-key execution log:

[
(submission_id, test_case_id) \rightarrow result_status
]

But:

[
test_case_id \rightarrow points
]

Here, `points` depends only on part of the composite key (`test_case_id`), creating a **partial dependency**.

---

## Transitive Dependency (Violates 3NF)

Within student-related data:

[
student_id \rightarrow batch_id
]

[
batch_id \rightarrow batch_code
]

Thus:

[
student_id \rightarrow batch_code
]

This indirect dependency is a **transitive dependency** and violates 3NF.

---

# Normal Form Evaluation

## Current State

* Satisfies **1NF**

  * Atomic values
  * Unique rows
  * No repeating groups

## Problems

* Violates **2NF**

  * Due to partial dependencies
* Violates **3NF**

  * Due to transitive dependencies

---

# Final Normalized Architecture (3NF)

The redesigned schema separates entities into independent tables:

1. **courses**
2. **problems**
3. **test_cases**
4. **submissions**
5. **test_results**

This design ensures:

* Every non-key attribute depends:

  * on the primary key,
  * the whole primary key,
  * and nothing but the primary key.

---

# Key Design Decisions

### Surrogate Primary Keys

`test_results` uses a dedicated `result_id` instead of a composite primary key for better indexing and future scalability.

### Nullable contest_id

`contest_id` in `submissions` is nullable because submissions may occur:

* inside contests/assignments, or
* independently during practice sessions.

---

# Final Outcome

The normalized 3NF schema:

* Eliminates redundancy
* Prevents insertion, deletion, and update anomalies
* Reduces storage overhead
* Improves consistency and maintainability
* Supports scalable transactional operations efficiently

