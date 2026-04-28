# SEQ_COBOL

# SEQ3000 – Sequential Employee File Maintenance System

## Course Information

**Course:** CIS352 – Intro to Enterprise Computing

**Assignment:** Chapter 13 – Sequential File Processing, Chapter 14 - Indexed Files, Chapter 16 - Sort/Merge

**Date:** April 27, 2026

---

## Table of Contents

* [Project Overview](#project-overview)
* [Features](#features)
* [Key Concepts](#key-concepts-implemented)
* [Workflow](#program-workflow)
* [Input & Output Files](#input--output-files)
* [Author](#author)

---

## Project Overview

The **SEQ3000 program** is a COBOL-based file maintenance system that processes employee data using **sequential files**.

The program updates an existing **Employee Master File (OLDEMP)** by applying changes from a **Personnel Transaction File (EMPTRAN)** to produce:

* A new updated **Employee Master File (NEWEMP)**
* An **Error Transaction File (ERRTRAN)** for invalid records

---

## Features

* Sequential file processing 
* Supports three HR transaction types:

  * **Add (A)** – Hire new employee
  * **Delete (D)** – Terminate employee
  * **Change (C)** – Update employee details
 
* Automatic generation of:
  * Updated master file (NEWEMP)
  * Error file for invalid transactions (ERRTRAN)

---

## Key Concepts Implemented

### Chapter 13

* Sequential file reading and writing
* Balanced-line processing 
* File sorting assumptions
* Multi-file input/output handling

### Chapter 14 

* Introduction to indexed files (VSAM)
* Converting sequential master file to indexed structure
* Random access using keys

### Chapter 16 

* Sorting and merging datasets
* Preparing files for batch processing

---

## Program Workflow

1. Open all input and output files
2. Read first record from:
   * Old Master file (OLDEMP)
   * Transaction file (EMPTRAN)

3. Compare Employee IDs using balanced-line logic
4. Process based on conditions:
   **Condition A: Master ID < Transaction ID**
   * No transaction exists
   * Write master record unchanged to NEWEMP

   **Condition B: Master ID = Transaction ID**
   * Evaluate Action Code:
     * **D (Delete):** Skip record
     * **C (Change):** Update only non-blank/non-zero fields
     * **A (Add):** Error → write to ERRTRAN

   **Condition C: Master ID > Transaction ID**
   * Evaluate Action Code:
     * **A (Add):** Create new employee record
     * **D or C:** Error → write to ERRTRAN

5. Continue until all records are processed

6. Close all files

---

## Input & Output Files

### Input Files

**OLDEMP**

* 57-byte fixed-length records
* Sorted by Employee ID
* Contains current employee data

**EMPTRAN**

* 50-byte fixed-length records
* Sorted by Employee ID
* Contains HR actions (A, D, C)

---

### Output Files

**NEWEMP (New Employee Master File)**

* Updated employee records
* Same layout as OLDEMP

**ERRTRAN (Error Transaction File)**

* Contains invalid or unprocessable transactions
* Same layout as EMPTRAN

---

## Output
<img width="651" height="148" alt="image" src="https://github.com/user-attachments/assets/074d52e8-6513-4665-9464-5686964e9358" />
<img width="500" height="93" alt="image" src="https://github.com/user-attachments/assets/16ec0f62-cc10-4efe-b573-df6fd01411a3" />


---

## Author
  
**Hayden Schmidt**

- **GitHub**: [Haschm05](https://github.com/Haschm05)
  
- **Email**: [haschm05@wsc.edu]
