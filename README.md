# InCollege - COBOL Login System

A console-based COBOL application for user authentication and navigation.

## Team Information

- **Epic**: Epic 1 - Log In, Part 1
- **Developer 1 (TM)**: Account management, password validation, login messages
- **Developer 2 (DM)**: File I/O infrastructure, persistence, skills menu, logout

## Quick Start (Docker - Recommended)

### Prerequisites
- Docker installed on your machine
- Docker Compose (usually included with Docker Desktop)

### Build and Run

```bash
# Build the Docker image
docker-compose build

# Run the program with the sample input file
docker-compose up

# Or run interactively (for manual input)
docker run -it --rm -v $(pwd)/data:/app/data incollege-app ./incollege
```

### Viewing Output
After running, check `data/InCollege-Output.txt` for the program output.

---

## Manual Setup (Without Docker)

### Prerequisites
- GnuCOBOL compiler (`cobc`)

### Install GnuCOBOL

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install gnucobol
```

**macOS (Homebrew):**
```bash
brew install gnu-cobol
```

**Windows:**
Use WSL2 with Ubuntu, or install GnuCOBOL for Windows.

### Compile and Run

```bash
# Compile
cobc -x -o incollege InCollege.cob

# Run with input file
./incollege < data/InCollege-Input.txt | tee data/InCollege-Output.txt

# Or run interactively
./incollege
```

---

## File Structure

```
incollege/
├── InCollege.cob           # Main COBOL source code
├── Dockerfile              # Docker build configuration
├── docker-compose.yml      # Docker Compose configuration
├── README.md               # This file
└── data/
    ├── InCollege-Input.txt   # Input file (user commands)
    ├── InCollege-Output.txt  # Output file (generated)
    └── accounts.dat          # Persistent account storage
```

## Input File Format

The input file contains one command per line, simulating user input:

```
2                    <- Menu choice: Create Account
myusername           <- Username
MyPass@123           <- Password (8-12 chars, 1 capital, 1 digit, 1 special)
1                    <- Menu choice: Login
myusername           <- Username
MyPass@123           <- Password
1                    <- Post-login: Search for job
3                    <- Post-login: Learn skill
1                    <- Skill menu: Select skill 1
6                    <- Skill menu: Go back
4                    <- Post-login: Logout
```

## Features Implemented

### Developer 2 (DM) Tasks
| Ticket | Description | Status |
|--------|-------------|--------|
| USF2-118 | Input from predefined file | ✅ Done |
| USF2-119 | Output displayed on screen | ✅ Done |
| USF2-120 | Output written to file | ✅ Done |
| USF2-123 | Account persistence | ✅ Done |
| USF2-127 | Unlimited login attempts | ✅ Done |
| USF2-131 | Skills submenu (5 skills) | ✅ Done |
| USF2-132 | Return to previous menu | ✅ Done |
| USF2-133 | Logout terminates program | ✅ Done |

### Developer 1 (TM) Tasks
| Ticket | Description | Status |
|--------|-------------|--------|
| USF2-121 | 5 account limit | 🔧 Implemented (verify) |
| USF2-122 | Password validation | 🔧 Implemented (verify) |
| USF2-124 | "Too many accounts" message | 🔧 Implemented (verify) |
| USF2-125 | Successful login message | 🔧 Implemented (verify) |
| USF2-126 | Failed login message | 🔧 Implemented (verify) |
| USF2-128 | Post-login menu display | 🔧 Implemented (verify) |
| USF2-129 | Job search - under construction | 🔧 Implemented (verify) |
| USF2-130 | Find someone - under construction | 🔧 Implemented (verify) |

> **Note**: TM tasks are implemented with basic functionality. TM should review and adjust as needed.

## Password Requirements

- Minimum 8 characters
- Maximum 12 characters
- At least 1 capital letter (A-Z)
- At least 1 digit (0-9)
- At least 1 special character (!@#$%^&*etc.)

## Testing

Create test input files in `data/` directory and run:

```bash
# Using Docker
docker-compose run incollege sh -c "./incollege < data/your-test-input.txt | tee data/your-test-output.txt"

# Without Docker
./incollege < data/your-test-input.txt | tee data/your-test-output.txt
```

## Troubleshooting

**"Error opening input file"**
- Ensure `data/InCollege-Input.txt` exists
- Check file permissions

**"accounts.dat" errors**
- This file is created automatically on first account creation
- Delete it to reset all accounts

**Docker build fails**
- Ensure Docker daemon is running
- Try `docker-compose build --no-cache`
