       IDENTIFICATION DIVISION.
       PROGRAM-ID. GR3PRG24.
       AUTHOR. GRUPO3.
      *HECHO EL 03 DE NOVIEMBRE DEL 2011.
      *PROGRAMA QUE GENERA LINEA DE BALANCE ENTRE MOVIMIENTOS Y CUENTAS
      *PUC.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *----ARCHIVO DE ENTRADA1 (MOVIMIENTOS CONSOLIDADOS)
           SELECT ENTRADA1  ASSIGN  ENTRADA1
           FILE STATUS IS VAR-ESTADO.
      *----ARCHIVO DE ENTRADA2 (CUENTAS PUC)
           SELECT ENTRADA2  ASSIGN  ENTRADA2
           FILE STATUS IS VAR-ESTADO.
      *----ARCHIVO DE SALIDA1 (ARCHIVO OK)
           SELECT SALIDA1   ASSIGN  SALIDA1
           FILE STATUS IS VAR-ESTADO.
       DATA DIVISION.
       FILE SECTION.
       FD  ENTRADA1 LABEL RECORD IS STANDARD
           BLOCK CONTAINS 0 RECORDS.
       01  REG-ENTRADA1.
           02 AE1-COD-CTA          PIC 9(10).
           02 AE1-CAN-MOV          PIC 9(07).
           02 AE1-VAL-DEB          PIC 9(13)V99.
           02 AE1-VAL-CRE          PIC 9(13)V99.

       FD  ENTRADA2 LABEL RECORD IS STANDARD
           BLOCK CONTAINS 0 RECORDS.
       01  REG-ENTRADA2.
            02 AE2-COD-CTA          PIC 9(10).
            02 AE2-NOM-CTA          PIC X(20).
            02 AE2-NAT-CTA          PIC X(01).

       FD  SALIDA1 LABEL RECORD IS STANDARD
           BLOCK CONTAINS 0 RECORDS.
       01  REG-SALIDA1.
           02 AS1-COD-CTA          PIC 9(10).
           02 AS1-SEP-001          PIC X(01).
           02 AS1-NOM-CTA          PIC X(20).
           02 AS1-SEP-002          PIC X(01).
           02 AS1-CAN-MOV          PIC 9(07).
           02 AS1-SEP-003          PIC X(01).
           02 AS1-VAL-DEB          PIC 9(14).99.
           02 AS1-SEP-004          PIC X(01).
           02 AS1-VAL-CRE          PIC 9(14).99.
           02 AS1-SEP-005          PIC X(01).
           02 AS1-VAL-SAL          PIC +9(14).99.

       WORKING-STORAGE SECTION.
       01   WS-CON-LEI-E1         PIC 9(8)  VALUE ZEROS.
       01   WS-CON-LEI-E2         PIC 9(8)  VALUE ZEROS.
       01   WS-CON-GRA-S1         PIC 9(8)  VALUE ZEROS.
       01   VAR-ESTADO            PIC XX    VALUE SPACES.
       01   LLAVE-1.
            02  LLAV1-CTA         PIC 9(10).
       01   LLAVE-2.
            02  LLAV2-CTA         PIC 9(10).

       01   WS-FDA-E1             PIC 9(1)  VALUE ZEROS.
       01   WS-FDA-E2             PIC 9(1)  VALUE ZEROS.
       01   WS-SALDO              PIC S9(14)V99   VALUE ZEROS.

       PROCEDURE  DIVISION.
       INICIO.
            PERFORM 01-INICIO
            PERFORM 02-PROCESO UNTIL WS-FDA-E1 = 1
                                  OR WS-FDA-E2 = 1
            PERFORM 03-FINALIZAR
            STOP RUN.

       01-INICIO.
            OPEN   INPUT   ENTRADA1
            IF  VAR-ESTADO  NOT = '00'
                DISPLAY 'ERROR AL ABRIR ARCHIVO ENTRADA1 ' VAR-ESTADO
                MOVE  12    TO  RETURN-CODE
                STOP   RUN
            END-IF

            OPEN   INPUT   ENTRADA2
            IF  VAR-ESTADO  NOT = '00'
                DISPLAY 'ERROR AL ABRIR ARCHIVO ENTRADA2 ' VAR-ESTADO
                MOVE  12    TO  RETURN-CODE
                STOP   RUN
            END-IF

            OPEN   OUTPUT  SALIDA1
            IF  VAR-ESTADO  NOT = '00'
                DISPLAY 'ERROR AL ABRIR ARCHIVO SALIDA1  ' VAR-ESTADO
                MOVE  12    TO  RETURN-CODE
                STOP   RUN
            END-IF

            PERFORM  01-01-LEER-ENTRADA1
            PERFORM  01-02-LEER-ENTRADA2.

      ******************************************************************
      *LEE EL ARCHIVO DE ENTRADA1 (SUBPARTES) Y CARGA LA LLAVE1.
      ******************************************************************
       01-01-LEER-ENTRADA1.
           READ  ENTRADA1  AT  END   MOVE 1 TO WS-FDA-E1
                     NOT   AT  END   PERFORM 01-01-01-CARGA-LLAVE1
                                     ADD  1 TO WS-CON-LEI-E1
           END-READ.

       01-01-01-CARGA-LLAVE1.
            MOVE  AE1-COD-CTA      TO   LLAV1-CTA.

      ******************************************************************
      *LEE EL ARCHIVO DE ENTRADA2 (PARTES) Y CARGA LA LLAVE2.
      ******************************************************************
       01-02-LEER-ENTRADA2.
           READ  ENTRADA2  AT  END   MOVE 1 TO WS-FDA-E2
                     NOT   AT  END   PERFORM 01-02-01-CARGA-LLAVE2
                                     ADD  1 TO WS-CON-LEI-E2
           END-READ.

       01-02-01-CARGA-LLAVE2.
            MOVE  AE2-COD-CTA      TO   LLAV2-CTA.

       02-PROCESO.
           IF LLAVE-1  >  LLAVE-2
              PERFORM  01-02-LEER-ENTRADA2
           ELSE
              IF LLAVE-1  <  LLAVE-2
                 CONTINUE
              ELSE
                 PERFORM 02-01-IGUALES
              END-IF
           END-IF.

       02-01-IGUALES.
           INITIALIZE   REG-SALIDA1

           MOVE    AE1-COD-CTA    TO     AS1-COD-CTA
           MOVE    AE2-NOM-CTA    TO     AS1-NOM-CTA
           MOVE    AE1-CAN-MOV    TO     AS1-CAN-MOV
           MOVE    AE1-VAL-DEB    TO     AS1-VAL-DEB
           MOVE    AE1-VAL-CRE    TO     AS1-VAL-CRE
           SUBTRACT  AE1-VAL-CRE  FROM   AE1-VAL-DEB  GIVING WS-SALDO
           MOVE    WS-SALDO       TO     AS1-VAL-SAL
           MOVE    ';'            TO     AS1-SEP-001  AS1-SEP-002
                                         AS1-SEP-003  AS1-SEP-004
                                         AS1-SEP-005
           WRITE   REG-SALIDA1  END-WRITE
           ADD     1              TO      WS-CON-GRA-S1
           PERFORM  01-01-LEER-ENTRADA1
           PERFORM  01-02-LEER-ENTRADA2.

       03-FINALIZAR.
             DISPLAY 'DATOS ESTADISTICOS PROGRAMA GR3PRG24 '
             DISPLAY 'REGISTROS ENTRADA1 ..............'  WS-CON-LEI-E1
             DISPLAY 'REGISTROS ENTRADA2 ..............'  WS-CON-LEI-E2
             DISPLAY 'REGISTROS GRABADOS OK ...........'  WS-CON-GRA-S1
             DISPLAY '........ F I N ..................'
             CLOSE   ENTRADA1 ENTRADA2  SALIDA1.
