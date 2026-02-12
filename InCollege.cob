       IDENTIFICATION DIVISION.
       PROGRAM-ID. INCOLLEGE.
       AUTHOR. DEVELOPER-2-DM.
      *================================================================*
      * InCollege - Login System Alpha Version
      * 
      * DEVELOPER 2 (DM) TASKS IMPLEMENTED:
      *   USF2-118: Input from predefined file
      *   USF2-119: Output displayed on screen
      *   USF2-120: Output written to file
      *   USF2-123: Account persistence (save/load)
      *   USF2-127: Unlimited login attempts
      *   USF2-131: Skills submenu with 5 skills
      *   USF2-132: Return to previous menu option
      *   USF2-133: Logout terminates program
      *
      * DEVELOPER 1 (TM) TASKS - PLACEHOLDERS MARKED WITH "TM-TODO":
      *   USF2-121: 5 account limit
      *   USF2-122: Password validation
      *   USF2-124: "Too many accounts" message
      *   USF2-125: Successful login message
      *   USF2-126: Failed login message
      *   USF2-128: Post-login menu
      *   USF2-129: Job search under construction
      *   USF2-130: Find someone under construction
      *================================================================*

       ENVIRONMENT DIVISION.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
      *    Input file - all user input read from here (USF2-118)
           SELECT INPUT-FILE ASSIGN TO "data/InCollege-Input.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-INPUT-STATUS.
       
      *    Output file - all output written here too (USF2-120)
           SELECT OUTPUT-FILE ASSIGN TO "data/InCollege-Output.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-OUTPUT-STATUS.
       
      *    Accounts file - persistence (USF2-123)
           SELECT ACCOUNTS-FILE ASSIGN TO "data/accounts.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-ACCOUNTS-STATUS.

       DATA DIVISION.
       
       FILE SECTION.
       
       FD INPUT-FILE.
       01 INPUT-RECORD                    PIC X(100).
       
       FD OUTPUT-FILE.
       01 OUTPUT-RECORD                   PIC X(100).
       
       FD ACCOUNTS-FILE.
       01 ACCOUNT-RECORD.
           05 AR-USERNAME                 PIC X(20).
           05 AR-PASSWORD                 PIC X(12).
       
       WORKING-STORAGE SECTION.
       
      *    File status variables
       01 WS-INPUT-STATUS                 PIC XX VALUE SPACES.
       01 WS-OUTPUT-STATUS                PIC XX VALUE SPACES.
       01 WS-ACCOUNTS-STATUS              PIC XX VALUE SPACES.
       
      *    Program control flags
       01 WS-EOF-FLAG                     PIC 9 VALUE 0.
           88 END-OF-INPUT                VALUE 1.
       01 WS-PROGRAM-EXIT                 PIC 9 VALUE 0.
           88 EXIT-PROGRAM                VALUE 1.
       01 WS-LOGGED-IN                    PIC 9 VALUE 0.
           88 USER-LOGGED-IN              VALUE 1.
       01 WS-LOGIN-SUCCESS                PIC 9 VALUE 0.
           88 LOGIN-SUCCESSFUL            VALUE 1.
       
      *    Account storage - up to 5 accounts (USF2-121 limit)
       01 WS-ACCOUNT-COUNT                PIC 9 VALUE 0.
       01 WS-MAX-ACCOUNTS                 PIC 9 VALUE 5.
       01 WS-ACCOUNTS-TABLE.
           05 WS-ACCOUNT OCCURS 5 TIMES.
               10 WS-ACCT-USERNAME        PIC X(20).
               10 WS-ACCT-PASSWORD        PIC X(12).
       
      *    Current user input
       01 WS-USER-INPUT                   PIC X(100) VALUE SPACES.
       01 WS-MENU-CHOICE                  PIC X(1) VALUE SPACES.
       01 WS-SKILL-CHOICE                 PIC X(1) VALUE SPACES.
       
      *    Login/Registration working variables
       01 WS-INPUT-USERNAME               PIC X(20) VALUE SPACES.
       01 WS-INPUT-PASSWORD               PIC X(12) VALUE SPACES.
       01 WS-CURRENT-USER                 PIC X(20) VALUE SPACES.
       
      *    Loop counters
       01 WS-INDEX                        PIC 9 VALUE 0.
       
      *    Password validation flags (TM-TODO: USF2-122)
       01 WS-PASSWORD-VALID               PIC 9 VALUE 0.
           88 PASSWORD-IS-VALID           VALUE 1.
       01 WS-PASSWORD-LENGTH              PIC 99 VALUE 0.
       01 WS-HAS-CAPITAL                  PIC 9 VALUE 0.
       01 WS-HAS-DIGIT                    PIC 9 VALUE 0.
       01 WS-HAS-SPECIAL                  PIC 9 VALUE 0.
       
      *    Output line for dual output
       01 WS-OUTPUT-LINE                  PIC X(100) VALUE SPACES.

       PROCEDURE DIVISION.
       
       MAIN-PROGRAM.
           PERFORM INITIALIZE-PROGRAM
           PERFORM LOAD-ACCOUNTS
           PERFORM MAIN-MENU-LOOP UNTIL EXIT-PROGRAM
           PERFORM CLEANUP-PROGRAM
           STOP RUN.

      *================================================================*
      * INITIALIZATION AND CLEANUP
      *================================================================*
       
       INITIALIZE-PROGRAM.
      *    Open input file (USF2-118)
           OPEN INPUT INPUT-FILE
           IF WS-INPUT-STATUS NOT = "00"
               DISPLAY "Error opening input file: " WS-INPUT-STATUS
               MOVE 1 TO WS-PROGRAM-EXIT
           END-IF
           
      *    Open output file (USF2-120)
           OPEN OUTPUT OUTPUT-FILE
           IF WS-OUTPUT-STATUS NOT = "00"
               DISPLAY "Error opening output file: " WS-OUTPUT-STATUS
               MOVE 1 TO WS-PROGRAM-EXIT
           END-IF.
       
       CLEANUP-PROGRAM.
           CLOSE INPUT-FILE
           CLOSE OUTPUT-FILE
           PERFORM SAVE-ACCOUNTS.

      *================================================================*
      * DUAL OUTPUT HELPER - Screen + File (USF2-119, USF2-120)
      *================================================================*
       
       WRITE-OUTPUT.
      *    Display to screen (USF2-119)
           DISPLAY WS-OUTPUT-LINE
      *    Write to file (USF2-120)
           WRITE OUTPUT-RECORD FROM WS-OUTPUT-LINE
           MOVE SPACES TO WS-OUTPUT-LINE.
       
       WRITE-BLANK-LINE.
           MOVE SPACES TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT.

      *================================================================*
      * INPUT HELPER - Read from file (USF2-118)
      *================================================================*
       
       READ-USER-INPUT.
           READ INPUT-FILE INTO WS-USER-INPUT
               AT END
                   MOVE 1 TO WS-EOF-FLAG
                   MOVE 1 TO WS-PROGRAM-EXIT
               NOT AT END
      *            Echo input to output file (per spec requirement)
                   MOVE WS-USER-INPUT TO WS-OUTPUT-LINE
                   PERFORM WRITE-OUTPUT
           END-READ.

      *================================================================*
      * ACCOUNT PERSISTENCE - Load/Save (USF2-123)
      *================================================================*
       
       LOAD-ACCOUNTS.
           OPEN INPUT ACCOUNTS-FILE
           IF WS-ACCOUNTS-STATUS = "00"
               MOVE 0 TO WS-ACCOUNT-COUNT
               PERFORM UNTIL WS-ACCOUNTS-STATUS NOT = "00"
                   READ ACCOUNTS-FILE INTO ACCOUNT-RECORD
                       AT END
                           EXIT PERFORM
                       NOT AT END
                           ADD 1 TO WS-ACCOUNT-COUNT
                           MOVE AR-USERNAME TO 
                               WS-ACCT-USERNAME(WS-ACCOUNT-COUNT)
                           MOVE AR-PASSWORD TO 
                               WS-ACCT-PASSWORD(WS-ACCOUNT-COUNT)
                   END-READ
               END-PERFORM
               CLOSE ACCOUNTS-FILE
           ELSE
      *        File doesn't exist yet - that's okay for first run
               MOVE 0 TO WS-ACCOUNT-COUNT
           END-IF.
       
       SAVE-ACCOUNTS.
           OPEN OUTPUT ACCOUNTS-FILE
           IF WS-ACCOUNTS-STATUS = "00"
               PERFORM VARYING WS-INDEX FROM 1 BY 1 
                   UNTIL WS-INDEX > WS-ACCOUNT-COUNT
                   MOVE WS-ACCT-USERNAME(WS-INDEX) TO AR-USERNAME
                   MOVE WS-ACCT-PASSWORD(WS-INDEX) TO AR-PASSWORD
                   WRITE ACCOUNT-RECORD
               END-PERFORM
               CLOSE ACCOUNTS-FILE
           END-IF.

      *================================================================*
      * MAIN MENU LOOP
      *================================================================*
       
       MAIN-MENU-LOOP.
           IF EXIT-PROGRAM
               EXIT PARAGRAPH
           END-IF
           
           PERFORM DISPLAY-WELCOME-MENU
           PERFORM READ-USER-INPUT
           
           IF EXIT-PROGRAM
               EXIT PARAGRAPH
           END-IF
           
           EVALUATE TRUE
               WHEN WS-USER-INPUT(1:1) = "1"
                   PERFORM LOGIN-PROCESS
               WHEN WS-USER-INPUT(1:1) = "2"
                   PERFORM REGISTRATION-PROCESS
               WHEN WS-USER-INPUT(1:1) = "9"
                   MOVE "--- END_OF_PROGRAM_EXECUTION ---" 
                       TO WS-OUTPUT-LINE
                   PERFORM WRITE-OUTPUT
                   MOVE 1 TO WS-PROGRAM-EXIT
               WHEN OTHER
                   MOVE "Invalid choice. Please try again." 
                       TO WS-OUTPUT-LINE
                   PERFORM WRITE-OUTPUT
           END-EVALUATE.
       
       DISPLAY-WELCOME-MENU.
           MOVE "Welcome to InCollege!" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "1. Log In" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "2. Create New Account" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "9. Exit" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "Enter your choice: " TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT.

      *================================================================*
      * LOGIN PROCESS (USF2-127: Unlimited attempts)
      *================================================================*
       
       LOGIN-PROCESS.
           MOVE 0 TO WS-LOGIN-SUCCESS
      *    Loop until successful login or EOF (USF2-127: unlimited)
           PERFORM UNTIL LOGIN-SUCCESSFUL OR EXIT-PROGRAM
               PERFORM GET-LOGIN-CREDENTIALS
               IF NOT EXIT-PROGRAM
                   PERFORM VALIDATE-LOGIN
               END-IF
           END-PERFORM
           
           IF LOGIN-SUCCESSFUL
               MOVE WS-INPUT-USERNAME TO WS-CURRENT-USER
               PERFORM POST-LOGIN-MENU
           END-IF.
       
       GET-LOGIN-CREDENTIALS.
           MOVE "Please enter your username: " TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           PERFORM READ-USER-INPUT
           IF NOT EXIT-PROGRAM
               MOVE FUNCTION TRIM(WS-USER-INPUT) TO WS-INPUT-USERNAME
           END-IF
           
           IF NOT EXIT-PROGRAM
               MOVE "Please enter your password: " TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
               PERFORM READ-USER-INPUT
               IF NOT EXIT-PROGRAM
                   MOVE FUNCTION TRIM(WS-USER-INPUT) 
                       TO WS-INPUT-PASSWORD
               END-IF
           END-IF.
       
       VALIDATE-LOGIN.
      *    Check credentials against stored accounts
           MOVE 0 TO WS-LOGIN-SUCCESS
           PERFORM VARYING WS-INDEX FROM 1 BY 1 
               UNTIL WS-INDEX > WS-ACCOUNT-COUNT OR LOGIN-SUCCESSFUL
               IF WS-INPUT-USERNAME = WS-ACCT-USERNAME(WS-INDEX) AND
                  WS-INPUT-PASSWORD = WS-ACCT-PASSWORD(WS-INDEX)
                   MOVE 1 TO WS-LOGIN-SUCCESS
      *            TM-TODO (USF2-125): Success message
                   MOVE "You have successfully logged in." 
                       TO WS-OUTPUT-LINE
                   PERFORM WRITE-OUTPUT
               END-IF
           END-PERFORM
           
           IF NOT LOGIN-SUCCESSFUL
      *        TM-TODO (USF2-126): Failed login message
               MOVE "Incorrect username/password, please try again"
                   TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
           END-IF.

      *================================================================*
      * REGISTRATION PROCESS
      * TM-TODO: USF2-121 (5 limit), USF2-122 (password validation),
      *          USF2-124 (too many accounts message)
      *================================================================*
       
       REGISTRATION-PROCESS.
      *    TM-TODO (USF2-121, USF2-124): Check account limit
           IF WS-ACCOUNT-COUNT >= WS-MAX-ACCOUNTS
               MOVE "All permitted accounts have been created, please c
      -            "ome back later" TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
               EXIT PARAGRAPH
           END-IF
           
           MOVE "Please enter your username: " TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           PERFORM READ-USER-INPUT
           IF EXIT-PROGRAM
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION TRIM(WS-USER-INPUT) TO WS-INPUT-USERNAME
           
      *    Check for duplicate username
           PERFORM VARYING WS-INDEX FROM 1 BY 1 
               UNTIL WS-INDEX > WS-ACCOUNT-COUNT
               IF WS-INPUT-USERNAME = WS-ACCT-USERNAME(WS-INDEX)
                   MOVE "Username already exists. Please try another."
                       TO WS-OUTPUT-LINE
                   PERFORM WRITE-OUTPUT
                   EXIT PARAGRAPH
               END-IF
           END-PERFORM
           
           MOVE "Please enter your password: " TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           PERFORM READ-USER-INPUT
           IF EXIT-PROGRAM
               EXIT PARAGRAPH
           END-IF
           MOVE FUNCTION TRIM(WS-USER-INPUT) TO WS-INPUT-PASSWORD
           
      *    TM-TODO (USF2-122): Validate password requirements
           PERFORM VALIDATE-PASSWORD
           IF NOT PASSWORD-IS-VALID
               EXIT PARAGRAPH
           END-IF
           
      *    Add new account
           ADD 1 TO WS-ACCOUNT-COUNT
           MOVE WS-INPUT-USERNAME TO 
               WS-ACCT-USERNAME(WS-ACCOUNT-COUNT)
           MOVE WS-INPUT-PASSWORD TO 
               WS-ACCT-PASSWORD(WS-ACCOUNT-COUNT)
           
           MOVE "Account created successfully!" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT.

      *================================================================*
      * PASSWORD VALIDATION (TM-TODO: USF2-122)
      * Requirements: 8-12 chars, 1 capital, 1 digit, 1 special
      *================================================================*
       
       VALIDATE-PASSWORD.
           MOVE 1 TO WS-PASSWORD-VALID
           MOVE 0 TO WS-HAS-CAPITAL
           MOVE 0 TO WS-HAS-DIGIT
           MOVE 0 TO WS-HAS-SPECIAL
           
           MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT-PASSWORD))
               TO WS-PASSWORD-LENGTH
           
      *    Check length (8-12 characters)
           IF WS-PASSWORD-LENGTH < 8
               MOVE "Password must be at least 8 characters."
                   TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
               MOVE 0 TO WS-PASSWORD-VALID
               EXIT PARAGRAPH
           END-IF
           
           IF WS-PASSWORD-LENGTH > 12
               MOVE "Password must be no more than 12 characters."
                   TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
               MOVE 0 TO WS-PASSWORD-VALID
               EXIT PARAGRAPH
           END-IF
           
      *    TM-TODO: Check for capital letter, digit, special char
      *    This is a simplified check - Twinkle should implement full
           INSPECT WS-INPUT-PASSWORD TALLYING WS-HAS-CAPITAL
               FOR ALL "A" "B" "C" "D" "E" "F" "G" "H" "I" "J"
                       "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T"
                       "U" "V" "W" "X" "Y" "Z"
           
           IF WS-HAS-CAPITAL = 0
               MOVE "Password must contain at least one capital letter."
                   TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
               MOVE 0 TO WS-PASSWORD-VALID
               EXIT PARAGRAPH
           END-IF
           
           INSPECT WS-INPUT-PASSWORD TALLYING WS-HAS-DIGIT
               FOR ALL "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"
           
           IF WS-HAS-DIGIT = 0
               MOVE "Password must contain at least one digit."
                   TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
               MOVE 0 TO WS-PASSWORD-VALID
               EXIT PARAGRAPH
           END-IF
           
           INSPECT WS-INPUT-PASSWORD TALLYING WS-HAS-SPECIAL
               FOR ALL "!" "@" "#" "$" "%" "^" "&" "*" "(" ")"
                       "-" "_" "=" "+" "[" "]" "{" "}" "|" "\"
                       ";" ":" "'" '"' "," "." "<" ">" "/" "?"
           
           IF WS-HAS-SPECIAL = 0
               MOVE "Password must contain at least one special char."
                   TO WS-OUTPUT-LINE
               PERFORM WRITE-OUTPUT
               MOVE 0 TO WS-PASSWORD-VALID
           END-IF.

      *================================================================*
      * POST-LOGIN MENU
      * TM-TODO: USF2-128 (menu), USF2-129 (job), USF2-130 (find)
      * DM TASKS: USF2-131 (skills), USF2-132 (return), USF2-133 (logout)
      *================================================================*
       
       POST-LOGIN-MENU.
           MOVE 1 TO WS-LOGGED-IN
           MOVE SPACES TO WS-OUTPUT-LINE
           STRING "Welcome, " DELIMITED SIZE
                  FUNCTION TRIM(WS-CURRENT-USER) DELIMITED SPACE
                  "!" DELIMITED SIZE
                  INTO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           PERFORM UNTIL NOT USER-LOGGED-IN OR EXIT-PROGRAM
               PERFORM DISPLAY-POST-LOGIN-OPTIONS
               PERFORM READ-USER-INPUT
               
               IF EXIT-PROGRAM
                   EXIT PERFORM
               END-IF
               
               EVALUATE TRUE
                   WHEN WS-USER-INPUT(1:1) = "1"
      *                TM-TODO (USF2-129): Job search
                       MOVE "Job search/internship is under construction
      -                    "." TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
                   WHEN WS-USER-INPUT(1:1) = "2"
      *                TM-TODO (USF2-130): Find someone
                       MOVE "Find someone you know is under construction
      -                    "." TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
                   WHEN WS-USER-INPUT(1:1) = "3"
      *                DM (USF2-131): Learn a new skill
                       PERFORM SKILLS-MENU
                   WHEN WS-USER-INPUT(1:1) = "4"
      *                DM (USF2-133): Logout
                       PERFORM LOGOUT-PROCESS
                   WHEN OTHER
                       MOVE "Invalid choice. Please try again."
                           TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
               END-EVALUATE
           END-PERFORM.
       
       DISPLAY-POST-LOGIN-OPTIONS.
      *    TM-TODO (USF2-128): Post-login menu display
           MOVE "1. Search for a job" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "2. Find someone you know" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "3. Learn a new skill" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "4. Logout" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "Enter your choice: " TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT.

      *================================================================*
      * SKILLS MENU (DM: USF2-131, USF2-132)
      *================================================================*
       
       SKILLS-MENU.
           PERFORM UNTIL EXIT-PROGRAM
               PERFORM DISPLAY-SKILLS-OPTIONS
               PERFORM READ-USER-INPUT
               
               IF EXIT-PROGRAM
                   EXIT PERFORM
               END-IF
               
               EVALUATE TRUE
                   WHEN WS-USER-INPUT(1:1) = "1"
                       MOVE "Python Programming is under construction."
                           TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
                   WHEN WS-USER-INPUT(1:1) = "2"
                       MOVE "Data Analysis is under construction."
                           TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
                   WHEN WS-USER-INPUT(1:1) = "3"
                       MOVE "Machine Learning is under construction."
                           TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
                   WHEN WS-USER-INPUT(1:1) = "4"
                       MOVE "Web Development is under construction."
                           TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
                   WHEN WS-USER-INPUT(1:1) = "5"
                       MOVE "Database Management is under construction."
                           TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
                   WHEN WS-USER-INPUT(1:1) = "6"
      *                DM (USF2-132): Return to previous menu
                       EXIT PERFORM
                   WHEN OTHER
                       MOVE "Invalid choice. Please try again."
                           TO WS-OUTPUT-LINE
                       PERFORM WRITE-OUTPUT
               END-EVALUATE
           END-PERFORM.
       
       DISPLAY-SKILLS-OPTIONS.
      *    DM (USF2-131): Display 5 skills
           MOVE "Learn a New Skill:" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "1. Python Programming" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "2. Data Analysis" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "3. Machine Learning" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "4. Web Development" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "5. Database Management" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
      *    DM (USF2-132): Option to go back
           MOVE "6. Go Back" TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE "Enter your choice: " TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT.

      *================================================================*
      * LOGOUT (DM: USF2-133)
      *================================================================*
       
       LOGOUT-PROCESS.
      *    DM (USF2-133): Logout returns to main menu
           MOVE "Logging out..." TO WS-OUTPUT-LINE
           PERFORM WRITE-OUTPUT
           MOVE 0 TO WS-LOGGED-IN.

