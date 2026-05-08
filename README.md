# CRLF vs LF CI/CD Failure Simulation

A lightweight DevOps lab project that demonstrates how non-POSIX compliant line endings (`CRLF`) can break deployment automation in Linux-based CI/CD environments.

This simulation recreates a real-world environment drift issue commonly encountered in distributed engineering teams working across Windows and Linux systems.

--- 

# Objective 

The purpose of this project is to simulate:

- CI/CD pipeline failures caused by shell incompatibility
- Environment drift between developer machines and Linux runners
- CRLF (`\r\n`) vs LF (`\n`) line-ending issues 
- Script portability problems in minimal container environments
- Proper remediation using shell standardization and Git normalization

---

# Real-World Scenario

A shell script developed on a Windows workstation is committed with `CRLF` line endings.

The script executes successfully in some local environments but fails inside hardened Linux containers or CI runners with errors such as:

```bash
/bin/sh^M: bad interpreter: No such file or directory
```

or

```bash
syntax error: unexpected carriage return
```

This issue becomes critical in production CI/CD pipelines where bootstrap scripts orchestrate infrastructure provisioning, service initialization, or deployment sequencing.

---

# Technologies Used

- Docker
- Alpine Linux
- POSIX Shell (`/bin/sh`)
- GitHub Actions (optional)
- Git
- Bash / Shell scripting

---

# Project Structure

```text
crlf-ci-cd-simulation/
│
├── scripts/
│   └── bootstrap.sh
│
├── Dockerfile
├── docker-compose.yml
├── .gitattributes
└── README.md
```

---

# How the Failure is Simulated

The shell script is intentionally saved using Windows-style `CRLF` line endings.

When executed inside a lightweight Linux container, the shell interpreter cannot correctly parse the hidden carriage return characters.

This recreates a common CI/CD portability issue between:

- Windows developer environments
- Linux-based CI runners
- Minimal container runtimes

---

# Step 1 — Clone the Repository

```bash
git clone <your-repo-url>
cd crlf-ci-cd-simulation
```

---

# Step 2 — Build the Docker Image

```bash
docker build -t crlf-demo .
```

---

# Step 3 — Run the Container

```bash
docker run --rm crlf-demo
```

Expected failure:

```bash
/bin/sh^M: bad interpreter: No such file or directory
```

---

# Step 4 — Verify Hidden CRLF Characters

Run:

```bash
cat -A scripts/bootstrap.sh
```

Expected output:

```bash
#!/bin/sh^M$
```

The `^M` indicates a carriage return character introduced by Windows-style line endings.

---

# Root Cause Analysis

Linux shells expect POSIX-compliant LF (`\n`) line endings.

Windows environments commonly use CRLF (`\r\n`).

When scripts containing CRLF are executed inside minimal Linux environments, the shell interpreter misreads the script header and fails during execution.

This issue often bypasses local testing and only appears:

- inside CI/CD pipelines,
- container runtimes,
- Kubernetes init containers,
- or hardened production environments.

---

# Fixing the Problem

## Option 1 — Convert CRLF to LF

Install `dos2unix`:

```bash
sudo apt install dos2unix
```

Convert the script:

```bash
dos2unix scripts/bootstrap.sh
```

---

## Option 2 — Enforce LF with Git

Create a `.gitattributes` file:

```text
*.sh text eol=lf
```

This ensures shell scripts are normalized automatically during commits and checkouts.

---

# Recommended Shell Safety Improvements

Update scripts with strict error handling:

```bash
#!/bin/sh

set -eu

echo "Starting bootstrap..."
```

If using Bash:

```bash
set -euo pipefail
```

Benefits:

- immediate failure detection,
- safer automation,
- prevention of silent deployment errors,
- stronger CI/CD resiliency.

---

# CI/CD Integration Example

Example GitHub Actions validation step:

```yaml
- name: Validate shell scripts
  run: |
    apt-get update
    apt-get install -y dos2unix
    dos2unix scripts/*.sh
```

---

# Example Dockerfile

```dockerfile
FROM alpine:latest

WORKDIR /app

COPY scripts/bootstrap.sh /app/bootstrap.sh

RUN chmod +x /app/bootstrap.sh

CMD ["/app/bootstrap.sh"]
```

---

# Example bootstrap.sh

> Save this file intentionally with CRLF line endings for failure simulation.

```bash
#!/bin/sh

echo "Starting bootstrap..."
mkdir -p /app/data
echo "Bootstrap completed"
```

---

# Example docker-compose.yml

```yaml
version: "3.8"

services:
  crlf-demo:
    build: .
    container_name: crlf-demo
```

---

# Key DevOps Takeaways

This project highlights several important engineering principles:

- Reliable automation depends on environment consistency
- Shell portability matters in distributed systems
- Infrastructure failures often originate from low-level OS behavior
- CI/CD pipelines should validate formatting and execution standards early
- Senior DevOps engineering requires understanding both tooling and operating system fundamentals

---

# Suggested Enhancements

You can extend this project by adding:

- GitHub Actions CI pipeline
- Jenkins pipeline simulation
- Kubernetes initContainer bootstrap
- Terraform null_resource execution
- ShellCheck validation
- Pre-commit hooks
- Multi-stage Docker builds
- BusyBox vs Bash compatibility tests

---

# Example Production Impact

In real production environments, issues like this can lead to:

- failed deployments,
- partial service rollouts,
- broken bootstrap orchestration,
- inconsistent infrastructure states,
- delayed recovery operations,
- and cascading microservice failures.

---

# Demo Screenshots to Capture

For your LinkedIn blog or vlog, capture these screenshots:

1. Failed Docker container execution
2. `^M` characters using `cat -A`
3. Failed GitHub Actions pipeline
4. `.gitattributes` fix implementation
5. Successful deployment after normalization

---

# License

MIT License

---

# Author

Jonathan Tambe  
DevOps & Cloud Engineer  
Focused on Cloud Infrastructure, Automation, CI/CD, and Platform Engineering.
