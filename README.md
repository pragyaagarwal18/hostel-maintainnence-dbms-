# Hostel Maintenance and Complaint Management System

**Vellore Institute of Technology (SCOPE)**  
**BCSE302P – Database Systems Lab | Assessment 8, 9 & 10**  
**Slot:** L25+L26 &bull; **Class Nbr:** VL2026270104025 &bull; **Faculty:** Dr. V. SIVAKUMAR  

---

### Project Authors
- **Pragya Agarwal** – `24BCI0280`
- **Suhani Singh** – `24BCI0006`

---

## 1. Project Description
Hostel Maintenance and Complaint Management System is an enterprise-grade relational database application designed to automate, track, and resolve residential facility maintenance issues within student hostels. 

The application facilitates end-to-end service level agreement (SLA) lifecycle management:
- **Students** log categorized complaint tickets with priority and track real-time resolution progress.
- **Warden / Administrators** review tickets, enforce room allocations, and execute atomic ACID stored procedures to assign maintenance staff.
- **Technicians** update progress, record replaced parts and labor costs, and resolve tickets.
- **Automated Triggers** maintain strict data integrity, audit logs, and trigger room maintenance statuses.
- **Materialized Views & Aggregates** calculate technician workloads and block-wise maintenance analytics.

---

## 2. Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Frontend** | HTML5, CSS3, JavaScript (Vanilla SPA) | Responsive Dashboard, Role Switcher, Modals |
| **Backend Framework** | Node.js with Express.js | RESTful API Engine, Exception Handlers |
| **Database** | MySQL 8.0 / MariaDB | Relational Engine (3NF Normalized, InnoDB) |
| **ORM** | Prisma ORM | SQL Injection Prevention, Relational Modeling |
| **Security & Auth** | BCrypt.js & JSON Web Tokens (JWT) | Password Hashing (10 rounds) & RBAC |
| **Database Routines** | Stored Procedures, Triggers, Views | ACID Atomic Assignments, Work Logs & Audits |
| **Containerization** | Docker & Docker Compose | Multi-container deployment (App + MySQL) |
| **CI/CD** | GitHub Actions | Automated build, schema verification & testing |

---

## 3. Database Architecture & Key Features

### 3.1 Single Users Table Rule Compliance
As mandated by the evaluation rubrics, all users (Students, Wardens, Technicians) are stored in a **single `users` table** using a `role` ENUM column (`STUDENT`, `WARDEN_ADMIN`, `TECHNICIAN`), avoiding anti-pattern role-split tables.

### 3.2 10 Normalized Database Tables (3NF)
1. `users`: Stores all system actors with hashed credentials and roles.
2. `hostel_blocks`: Stores residential buildings, floor counts, and assigned warden.
3. `rooms`: Stores room numbers, floor, capacity, occupancy, and maintenance status.
4. `student_allocations`: Room allotment ledger with active/vacated states.
5. `complaint_categories`: Maintenance classifications with predefined SLA hours.
6. `complaints`: Core ticket entity with title, priority, status, and timestamps.
7. `maintenance_assignments`: Junction table tracking assigned technician and warden.
8. `maintenance_work_logs`: Detailed actions, replaced parts, and repair costs.
9. `complaint_feedback`: Student service evaluation (1-5 star ratings & comments).
10. `audit_logs`: Immutable security ledger tracking all state mutations.

### 3.3 Advanced Database Routines
- **Stored Procedure 1 (`sp_pragya24bci0280_assign_technician`)**: Executes an ACID transaction to validate warden authorization, deactivate prior assignments, create new assignment, and transition complaint status to `ASSIGNED`.
- **Stored Procedure 2 (`sp_suhani24bci0006_resolve_complaint_with_worklog`)**: Records technician actions, logs parts costs, transitions ticket to `RESOLVED`, and restores room status.
- **Trigger 1 (`trg_before_complaint_insert_prevent_duplicate`)**: Enforces data integrity by preventing duplicate unresolved tickets for the same room and category.
- **Trigger 2 (`trg_after_complaint_status_update`)**: Automatically records audit trails upon status mutations and sets `resolved_at` timestamps.
- **3 Analytical Views**:
  - `view_active_complaints_summary`
  - `view_technician_workload_metrics`
  - `view_blockwise_resolution_analytics`

---

## 4. Installation & Setup Instructions

### Prerequisites
- Node.js (v18.x or v20.x)
- MySQL Server (v8.0+) or Docker Desktop
- Git

### Step 1: Clone Repository & Install Dependencies
```bash
git clone <repository-url>
cd DBMS
npm install
```

### Step 2: Environment Configuration
Copy the template environment file:
```bash
cp .env.example .env
```
Ensure `.env` contains your MySQL credentials:
```ini
PORT=5000
NODE_ENV=development
DATABASE_URL="mysql://root:yourpassword@localhost:3306/hostel_maintenance_db"
JWT_SECRET="pragya_24bci0280_suhani_24bci0006_jwt_secret_key_2026_super_secure"
JWT_EXPIRES_IN="24h"
```

### Step 3: Database Initialization
Run the SQL scripts in order via MySQL Workbench or command line:
```bash
mysql -u root -p < database/01_schema_ddl.sql
mysql -u root -p < database/02_views.sql
mysql -u root -p < database/03_triggers.sql
mysql -u root -p < database/04_stored_procedures.sql
mysql -u root -p < database/05_seed_data.sql
```

Alternatively, push schema via Prisma:
```bash
npx prisma generate
npx prisma db push
```

### Step 4: Run Application
```bash
npm start
```
The server will start at: `http://localhost:5000`

---

## 5. Docker Deployment
To launch the complete application stack (Node.js App + MySQL 8.0) using Docker Compose:
```bash
docker-compose up --build -d
```
Access the application at `http://localhost:5000`.

---

## 6. Native Database Backup & Recovery

### Backup (`mysqldump`)
Run the provided batch script:
```cmd
database\backup_db.bat
```
Or raw command:
```bash
mysqldump -u root -p --routines --triggers --views hostel_maintenance_db > backup.sql
```

### Restore (`mysql`)
Run the restore script:
```cmd
database\restore_db.bat
```
Or raw command:
```bash
mysql -u root -p hostel_maintenance_db < backup.sql
```

---

## 7. Version Control Strategy (GitHub)
- **Branching Model**:
  - `main`: Production-ready release branch.
  - `dev`: Active development and feature integration branch.
- **Commit History**: Progressively organized across milestones (Design, DDL, Views, Stored Procs, Express API, Auth/RBAC, Frontend, Docker & CI/CD).
