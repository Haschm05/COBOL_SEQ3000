       IDENTIFICATION DIVISION.

       PROGRAM-ID.  SEQ3000.

       ENVIRONMENT DIVISION.

       INPUT-OUTPUT SECTION.

       FILE-CONTROL.

           SELECT EMPTRAN   ASSIGN TO EMPTRAN.
           SELECT OLDEMP    ASSIGN TO OLDEMP.
           SELECT NEWEMP    ASSIGN TO NEWEMP
                            FILE STATUS IS NEWEMP-FILE-STATUS.
           SELECT ERRTRAN   ASSIGN TO ERRTRAN
                            FILE STATUS IS ERRTRAN-FILE-STATUS.

       DATA DIVISION.

       FILE SECTION.

       FD  EMPTRAN.
       01  TRANSACTION-RECORD      PIC X(50).

       FD  OLDEMP.
       01  OLD-MASTER-RECORD       PIC X(57).

       FD  NEWEMP.
       01  NEW-MASTER-RECORD.
           05 NM-EMPLOYEE-ID       PIC X(5).
           05 NM-EMPLOYEE-NAME     PIC X(30).         
           05 NM-DEPARTMENT-CODE   PIC X(5).
           05 NM-JOB-CLASS         PIC X(2).
           05 NM-ANNUAL-SALARY     PIC S9(5)V99.
           05 NM-VACATION-HOURS    PIC S9(3).
           05 NM-SICK-HOURS        PIC S9(3)V99.

       FD  ERRTRAN3.
       01  ERROR-TRANSACTION       PIC X(50).

       WORKING-STORAGE SECTION.

       01  SWITCHES.
           05  ALL-RECORDS-PROCESSED-SWITCH    PIC X   VALUE "N".
               88  ALL-RECORDS-PROCESSED               VALUE "Y".
           05  NEED-TRANSACTION-SWITCH         PIC X   VALUE "Y".
               88  NEED-TRANSACTION                    VALUE "Y".
           05  NEED-MASTER-SWITCH              PIC X   VALUE "Y".
               88  NEED-MASTER                         VALUE "Y".
           05  WRITE-MASTER-SWITCH             PIC X   VALUE "N".
               88  WRITE-MASTER                        VALUE "Y".

       01  FILE-STATUS-FIELDS.
           05  NEWEMP-FILE-STATUS      PIC XX.
               88  NEWEMP-SUCCESSFUL           VALUE "00".
           05  ERRTRAN-FILE-STATUS     PIC XX.
               88  ERRTRAN-SUCCESSFUL          VALUE "00".

       01  EMPLOYEE-TRANSACTION.
           05  ET-TRANSACTION-CODE     PIC X.
               88  ADD-RECORD                  VALUE "A".
               88  CHANGE-RECORD               VALUE "C".
               88  DELETE-RECORD               VALUE "D".
           05  ET-MASTER-DATA.
               05 ET-EMPLOYEE-ID       PIC X(5).
               05 ET-EMPLOYEE-NAME     PIC X(30).         
               05 ET-DEPARTMENT-CODE   PIC X(5).
               05 ET-JOB-CLASS         PIC X(2).
               05 ET-ANNUAL-SALARY     PIC S9(5)V99.
          

       01  EMPLOYEE-MASTER-RECORD.
               05 EM-EMPLOYEE-ID       PIC X(5).
               05 EM-EMPLOYEE-NAME     PIC X(30).         
               05 EM-DEPARTMENT-CODE   PIC X(5).
               05 EM-JOB-CLASS         PIC X(2).
               05 EM-ANNUAL-SALARY     PIC S9(5)V99.
               05 EM-VACATION-HOURS    PIC S9(3).
               05 EM-SICK-HOURS        PIC S9(3)V99.

       PROCEDURE DIVISION.

       000-MAINTAIN-INVENTORY-FILE.

           OPEN INPUT  OLDEMP
                       EMPTRAN
                OUTPUT NEWEMP
                       ERRTRAN.
           PERFORM 300-MAINTAIN-EMPLOYEE-RECORD
               UNTIL ALL-RECORDS-PROCESSED.
           CLOSE MNTTRAN
                 OLDEMP
                 NEWEMP
                 ERRTRAN.
           STOP RUN.

       300-MAINTAIN-EMPLOYEE-RECORD.

           IF NEED-TRANSACTION
               PERFORM 310-READ-INVENTORY-TRANSACTION
               MOVE "N" TO NEED-TRANSACTION-SWITCH.
           IF NEED-MASTER
               PERFORM 320-READ-OLD-MASTER
               MOVE "N" TO NEED-MASTER-SWITCH.
           PERFORM 330-MATCH-MASTER-TRAN.
           IF WRITE-MASTER
               PERFORM 340-WRITE-NEW-MASTER
               MOVE "N" TO WRITE-MASTER-SWITCH.

       310-READ-INVENTORY-TRANSACTION.

           READ MNTTRAN INTO EMPLOYEE-TRANSACTION
               AT END
                   MOVE HIGH-VALUE TO ET-ITEM-NO.

       320-READ-OLD-MASTER.

           READ OLDEMP INTO INVENTORY-MASTER-RECORD
               AT END
                   MOVE HIGH-VALUE TO IM-ITEM-NO.

       330-MATCH-MASTER-TRAN.

           IF IM-ITEM-NO > ET-ITEM-NO
               PERFORM 350-PROCESS-HI-MASTER
           ELSE IF IM-ITEM-NO < ET-ITEM-NO
               PERFORM 360-PROCESS-LO-MASTER
           ELSE
               PERFORM 370-PROCESS-MAST-TRAN-EQUAL.

       340-WRITE-NEW-MASTER.

           WRITE NEW-MASTER-RECORD.
           IF NOT NEWEMP-SUCCESSFUL
               DISPLAY "WRITE ERROR ON NEWEMP FOR ITEM NUMBER "
                   IM-ITEM-NO
               DISPLAY "FILE STATUS CODE IS " NEWEMP-FILE-STATUS
               SET ALL-RECORDS-PROCESSED TO TRUE.

       350-PROCESS-HI-MASTER.

           IF ADD-RECORD
               PERFORM 380-APPLY-ADD-TRANSACTION
           ELSE
               PERFORM 390-WRITE-ERROR-TRANSACTION.

       360-PROCESS-LO-MASTER.

           MOVE INVENTORY-MASTER-RECORD TO NEW-MASTER-RECORD.
           SET WRITE-MASTER TO TRUE.
           SET NEED-MASTER TO TRUE.

       370-PROCESS-MAST-TRAN-EQUAL.

           IF IM-ITEM-NO = HIGH-VALUES
               SET ALL-RECORDS-PROCESSED TO TRUE
           ELSE
               IF DELETE-RECORD
                   PERFORM 400-APPLY-DELETE-TRANSACTION
               ELSE
                   IF CHANGE-RECORD
                       PERFORM 410-APPLY-CHANGE-TRANSACTION
                   ELSE
                       PERFORM 390-WRITE-ERROR-TRANSACTION.

       380-APPLY-ADD-TRANSACTION.

           MOVE ET-ITEM-NO TO NM-ITEM-NO.
           MOVE ET-ITEM-DESC TO NM-ITEM-DESC.
           MOVE ET-UNIT-COST TO NM-UNIT-COST.
           MOVE ET-UNIT-PRICE TO NM-UNIT-PRICE.
           MOVE ET-REORDER-POINT TO NM-REORDER-POINT.
           MOVE ZERO TO NM-ON-HAND
                        NM-ON-ORDER.
           SET WRITE-MASTER TO TRUE.
           SET NEED-TRANSACTION TO TRUE.

       390-WRITE-ERROR-TRANSACTION.

           WRITE ERROR-TRANSACTION FROM EMPLOYEE-TRANSACTION.
           IF NOT ERRTRAN-SUCCESSFUL
               DISPLAY "WRITE ERROR ON ERRTRAN FOR ITEM NUMBER "
                   ET-ITEM-NO
               DISPLAY "FILE STATUS CODE IS " ERRTRAN-FILE-STATUS
               SET ALL-RECORDS-PROCESSED TO TRUE
           ELSE
               SET NEED-TRANSACTION TO TRUE.

       400-APPLY-DELETE-TRANSACTION.

           SET NEED-MASTER TO TRUE.
           SET NEED-TRANSACTION TO TRUE.


       410-APPLY-CHANGE-TRANSACTION.

           IF ET-ITEM-DESC NOT = SPACE
               MOVE ET-ITEM-DESC TO IM-ITEM-DESC.
           IF ET-UNIT-COST NOT = ZERO
               MOVE ET-UNIT-COST TO IM-UNIT-COST.
           IF ET-UNIT-PRICE NOT = ZERO
               MOVE ET-UNIT-PRICE TO IM-UNIT-PRICE.
           IF ET-REORDER-POINT NOT = ZERO
               MOVE ET-REORDER-POINT TO IM-REORDER-POINT.
           SET NEED-TRANSACTION TO TRUE.
