//EMPIND1 JOB (KC03HE8),'CREATE EMPMAST1',REGION=0M,CLASS=A,
//             MSGCLASS=H,NOTIFY=&SYSUID,MSGLEVEL=(1,1)
//*
//*------------------------------------------------------------*
//* STEP 1: DELETE CLUSTER IF IT EXISTS (IGNORE IF NOT FOUND) *
//* IDCAMS stands for Integrated Data Cluster Access Method Services.
//* It is the IBM utility program used to manage VSAM files.
//*------------------------------------------------------------*
//STEP1     EXEC PGM=IDCAMS
//SYSPRINT  DD  SYSOUT=*
//SYSIN     DD  *
  DELETE KC03HE8.INVMASTI.KSDS CLUSTER PURGE
  SET MAXCC = 0
/*
//*
//*------------------------------------------------------------*
//* STEP 2: DEFINE THE VSAM KSDS CLUSTER FOR EMPMASTI
//* 1000 primary space and 500 each time it fills
//*------------------------------------------------------------*
//STEP2     EXEC PGM=IDCAMS
//SYSPRINT  DD  SYSOUT=*
//SYSIN     DD  *
  DEFINE CLUSTER                        -
    (NAME(KC03HE8.EMPMASTI.KSDS)           -
     RECORDS(1000 500)                  -
     RECORDSIZE(57 57)                  -
     KEYS(5 0)                          -
     INDEXED                            -
     REUSE)                             -
    DATA                                -
      (NAME(KC03HE8.EMPMASTI.KSDS.DATA))   -
    INDEX                               -
      (NAME(KC03HE8.EMPMASTI.KSDS.INDEX))
/*
//*
//*------------------------------------------------------------*
//* STEP 3: RUN EMPIND1 TO LOAD EMPLOYEE RECORDS FROM OLDSEMP        *
//*------------------------------------------------------------*
//*-----------------------------------------------------------*
//* BASIC COMPILE, LINK, AND GO JCL
//*-----------------------------------------------------------*
//COBOL1   EXEC IGYWCLG,REGION=0M,
//         PARM.COBOL='TEST,RENT,APOST,OBJECT,NODYNAM'
//COBOL.STEPLIB DD DSN=IGY640.SIGYCOMP,DISP=SHR
//COBOL.SYSIN   DD DISP=SHR,DSN=KC03HE8.CIS352.COBOL(EMPIND1)
//GO.OLDEMP  DD DISP=SHR,DSN=KC03HE8.CIS352.OLDEMP
//GO.EMPMASTI   DD DISP=OLD,DSN=KC03HE8.EMPMASTI.KSDS
