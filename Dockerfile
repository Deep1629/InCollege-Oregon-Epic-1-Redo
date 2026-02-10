FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install GnuCOBOL and utilities
RUN apt-get update && apt-get install -y \
    gnucobol \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy all project files
COPY . .

# Create directories for data files if they don't exist
RUN mkdir -p /app/data

# Compile the COBOL program
RUN cobc -x -o incollege InCollege.cob

# Default command: run the program
CMD ["./incollege"]
