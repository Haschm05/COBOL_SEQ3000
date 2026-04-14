       IDENTIFICATION DIVISION.                                                 
                                                                                
       PROGRAM-ID.  SEQ2000.
                                                                                
       ENVIRONMENT DIVISION.                                                    
                                                                                
       INPUT-OUTPUT SECTION.                                                    
                                                                                
       FILE-CONTROL.                                                            
      
           SELECT MNTTRAN  ASSIGN TO MNTTRAN.
           SELECT OLDMAST  ASSIGN TO OLDMAST.
           SELECT NEWMAST  ASSIGN TO NEWMAST
                           FILE STATUS IS NEWMAST-FILE-STATUS.
           SELECT ERRTRAN  ASSIGN TO ERRTRAN
                           FILE STATUS IS ERRTRAN-FILE-STATUS.
                                                                                
       DATA DIVISION.                                                           
                                                                                
       FILE SECTION.                                                            
                                                                                
       FD  MNTTRAN.
                                                                                
       01  TRANSACTION-RECORD      PIC X(61).
                                                                                
       FD  OLDMAST.
                                                                                
       01  OLD-MASTER-RECORD       PIC X(70).
                                                                                
       FD  NEWMAST.
                                                                                
       01  NEW-MASTER-RECORD.
       
           05  NM-ITEM-NO              PIC X(5).
           05  NM-DESCRIPTIVE-DATA.
               10  NM-ITEM-DESC        PIC X(40).
               10  NM-UNIT-COST        PIC S9(3)V99.
               10  NM-UNIT-PRICE       PIC S9(3)V99.
           05  NM-INVENTORY-DATA.
               10  NM-REORDER-POINT    PIC S9(5).
               10  NM-ON-HAND          PIC S9(5).
               10  NM-ON-ORDER         PIC S9(5).
                                                                                
       FD  ERRTRAN.
                                                                                
       01  ERROR-TRANSACTION       PIC X(61).
                                                                                
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
           05  NEWMAST-FILE-STATUS     PIC XX.
               88  NEWMAST-SUCCESSFUL          VALUE "00".
           05  ERRTRAN-FILE-STATUS     PIC XX.
               88  ERRTRAN-SUCCESSFUL          VALUE "00".
       
       01  MAINTENANCE-TRANSACTION.
           05  MT-TRANSACTION-CODE     PIC X.
               88  DELETE-RECORD               VALUE "1".
               88  ADD-RECORD                  VALUE "2".
               88  CHANGE-RECORD               VALUE "3".
           05  MT-MASTER-DATA.
               10  MT-ITEM-NO          PIC X(5).
               10  MT-ITEM-DESC        PIC X(40).
               10  MT-UNIT-COST        PIC S9(3)V99.
               10  MT-UNIT-PRICE       PIC S9(3)V99.
               10  MT-REORDER-POINT    PIC S9(5).
                                                                                
       01  INVENTORY-MASTER-RECORD.
           05  IM-ITEM-NO              PIC X(5).
           05  IM-DESCRIPTIVE-DATA.
               10  IM-ITEM-DESC        PIC X(40).
               10  IM-UNIT-COST        PIC S9(3)V99.
               10  IM-UNIT-PRICE       PIC S9(3)V99.
           05  IM-INVENTORY-DATA.
               10  IM-REORDER-POINT    PIC S9(5).
               10  IM-ON-HAND          PIC S9(5).
               10  IM-ON-ORDER         PIC S9(5).
       
       PROCEDURE DIVISION.                                                      
                                                                                
       000-MAINTAIN-INVENTORY-FILE.
                                                                                
           OPEN INPUT  OLDMAST
                       MNTTRAN
                OUTPUT NEWMAST
                       ERRTRAN.
           PERFORM 300-MAINTAIN-INVENTORY-RECORD
               UNTIL ALL-RECORDS-PROCESSED.                                     
           CLOSE MNTTRAN
                 OLDMAST
                 NEWMAST
                 ERRTRAN.
           STOP RUN.                                                            
                                                                                
       300-MAINTAIN-INVENTORY-RECORD.
                                                                                
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
       
           READ MNTTRAN INTO MAINTENANCE-TRANSACTION
               AT END
                   MOVE HIGH-VALUE TO MT-ITEM-NO.
       
       320-READ-OLD-MASTER.
       
           READ OLDMAST INTO INVENTORY-MASTER-RECORD
               AT END
                   MOVE HIGH-VALUE TO IM-ITEM-NO.
       
       330-MATCH-MASTER-TRAN.
       
           IF IM-ITEM-NO > MT-ITEM-NO
               PERFORM 350-PROCESS-HI-MASTER
           ELSE IF IM-ITEM-NO < MT-ITEM-NO
               PERFORM 360-PROCESS-LO-MASTER
           ELSE
               PERFORM 370-PROCESS-MAST-TRAN-EQUAL.

       340-WRITE-NEW-MASTER.
       
           WRITE NEW-MASTER-RECORD.
           IF NOT NEWMAST-SUCCESSFUL
               DISPLAY "WRITE ERROR ON NEWMAST FOR ITEM NUMBER "
                   IM-ITEM-NO
               DISPLAY "FILE STATUS CODE IS " NEWMAST-FILE-STATUS
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
       
           MOVE MT-ITEM-NO TO NM-ITEM-NO.
           MOVE MT-ITEM-DESC TO NM-ITEM-DESC.
           MOVE MT-UNIT-COST TO NM-UNIT-COST.
           MOVE MT-UNIT-PRICE TO NM-UNIT-PRICE.
           MOVE MT-REORDER-POINT TO NM-REORDER-POINT.
           MOVE ZERO TO NM-ON-HAND
                        NM-ON-ORDER.
           SET WRITE-MASTER TO TRUE.
           SET NEED-TRANSACTION TO TRUE.
       
       390-WRITE-ERROR-TRANSACTION.
       
           WRITE ERROR-TRANSACTION FROM MAINTENANCE-TRANSACTION.
           IF NOT ERRTRAN-SUCCESSFUL
               DISPLAY "WRITE ERROR ON ERRTRAN FOR ITEM NUMBER "
                   MT-ITEM-NO
               DISPLAY "FILE STATUS CODE IS " ERRTRAN-FILE-STATUS
               SET ALL-RECORDS-PROCESSED TO TRUE
           ELSE
               SET NEED-TRANSACTION TO TRUE.
       
       400-APPLY-DELETE-TRANSACTION.
       
           SET NEED-MASTER TO TRUE.
           SET NEED-TRANSACTION TO TRUE.

       
       410-APPLY-CHANGE-TRANSACTION.
       
           IF MT-ITEM-DESC NOT = SPACE
               MOVE MT-ITEM-DESC TO IM-ITEM-DESC.
           IF MT-UNIT-COST NOT = ZERO
               MOVE MT-UNIT-COST TO IM-UNIT-COST.
           IF MT-UNIT-PRICE NOT = ZERO
               MOVE MT-UNIT-PRICE TO IM-UNIT-PRICE.
           IF MT-REORDER-POINT NOT = ZERO
               MOVE MT-REORDER-POINT TO IM-REORDER-POINT.
           SET NEED-TRANSACTION TO TRUE.
