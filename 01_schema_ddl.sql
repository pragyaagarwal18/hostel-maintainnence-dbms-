-- ============================================================================
-- DATABASE SYSTEMS LAB (BCSE302P) - LAB INTERNAL ASSESSMENT 8, 9 & 10
-- TOPIC: HOSTEL MAINTENANCE AND COMPLAINT MANAGEMENT SYSTEM
-- AUTHORS: PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)
-- FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26
-- FILE: 01_schema_ddl.sql - Complete Relational DDL (3NF Normalized)
-- ============================================================================

CREATE DATABASE IF NOT EXISTS hostel_maintenance_db;
USE hostel_maintenance_db;

-- Drop tables in reverse order of foreign key dependencies
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS complaint_feedback;
DROP TABLE IF EXISTS maintenance_work_logs;
DROP TABLE IF EXISTS maintenance_assignments;
DROP TABLE IF EXISTS complaints;
DROP TABLE IF EXISTS complaint_categories;
DROP TABLE IF EXISTS student_allocations;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS hostel_blocks;
DROP TABLE IF EXISTS users;

-- ----------------------------------------------------------------------------
-- TABLE 1: users (SINGLE USERS TABLE WITH ROLE-BASED ACCESS CONTROL)
-- Strict Requirement: No separate tables for Admin, Student, Technician
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    reg_no VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('STUDENT', 'WARDEN_ADMIN', 'TECHNICIAN') NOT NULL DEFAULT 'STUDENT',
    phone_number VARCHAR(20),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT chk_users_email CHECK (email LIKE '%_@__%.__%')
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_reg_no ON users(reg_no);

-- ----------------------------------------------------------------------------
-- TABLE 2: hostel_blocks
-- ----------------------------------------------------------------------------
CREATE TABLE hostel_blocks (
    block_id INT AUTO_INCREMENT PRIMARY KEY,
    block_name VARCHAR(50) NOT NULL UNIQUE,
    gender_type ENUM('MALE', 'FEMALE', 'CO-ED') NOT NULL DEFAULT 'MALE',
    total_floors INT NOT NULL DEFAULT 5,
    warden_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_blocks_floors CHECK (total_floors > 0),
    CONSTRAINT fk_blocks_warden FOREIGN KEY (warden_id) 
        REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- TABLE 3: rooms
-- ----------------------------------------------------------------------------
CREATE TABLE rooms (
    room_id INT AUTO_INCREMENT PRIMARY KEY,
    block_id INT NOT NULL,
    room_number VARCHAR(20) NOT NULL,
    floor_no INT NOT NULL,
    capacity INT NOT NULL DEFAULT 2,
    current_occupancy INT NOT NULL DEFAULT 0,
    room_type VARCHAR(20) NOT NULL DEFAULT 'AC',
    status ENUM('AVAILABLE', 'OCCUPIED', 'UNDER_MAINTENANCE') NOT NULL DEFAULT 'AVAILABLE',
    CONSTRAINT unq_block_room UNIQUE (block_id, room_number),
    CONSTRAINT chk_room_capacity CHECK (capacity >= 1),
    CONSTRAINT chk_room_occupancy CHECK (current_occupancy >= 0 AND current_occupancy <= capacity),
    CONSTRAINT fk_rooms_block FOREIGN KEY (block_id) 
        REFERENCES hostel_blocks(block_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_rooms_block ON rooms(block_id);
CREATE INDEX idx_rooms_status ON rooms(status);

-- ----------------------------------------------------------------------------
-- TABLE 4: student_allocations
-- ----------------------------------------------------------------------------
CREATE TABLE student_allocations (
    allocation_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    room_id INT NOT NULL,
    academic_year VARCHAR(20) NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NULL,
    status ENUM('ACTIVE', 'TRANSFERRED', 'VACATED') NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_alloc_student FOREIGN KEY (student_id) 
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_alloc_room FOREIGN KEY (room_id) 
        REFERENCES rooms(room_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_alloc_student ON student_allocations(student_id);
CREATE INDEX idx_alloc_room ON student_allocations(room_id);

-- ----------------------------------------------------------------------------
-- TABLE 5: complaint_categories
-- ----------------------------------------------------------------------------
CREATE TABLE complaint_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    sla_resolution_hours INT NOT NULL DEFAULT 24,
    priority_default ENUM('LOW', 'MEDIUM', 'HIGH', 'EMERGENCY') NOT NULL DEFAULT 'MEDIUM',
    description TEXT,
    CONSTRAINT chk_sla_hours CHECK (sla_resolution_hours > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- TABLE 6: complaints
-- ----------------------------------------------------------------------------
CREATE TABLE complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(50) NOT NULL UNIQUE,
    student_id INT NOT NULL,
    room_id INT NOT NULL,
    category_id INT NOT NULL,
    title VARCHAR(150) NOT NULL,
    description TEXT NOT NULL,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'EMERGENCY') NOT NULL DEFAULT 'MEDIUM',
    status ENUM('SUBMITTED', 'ASSIGNED', 'IN_PROGRESS', 'RESOLVED', 'CLOSED', 'REJECTED') NOT NULL DEFAULT 'SUBMITTED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    CONSTRAINT fk_complaints_student FOREIGN KEY (student_id) 
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_complaints_room FOREIGN KEY (room_id) 
        REFERENCES rooms(room_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_complaints_category FOREIGN KEY (category_id) 
        REFERENCES complaint_categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_complaints_student ON complaints(student_id);
CREATE INDEX idx_complaints_status ON complaints(status);
CREATE INDEX idx_complaints_room ON complaints(room_id);
CREATE INDEX idx_complaints_created ON complaints(created_at);

-- ----------------------------------------------------------------------------
-- TABLE 7: maintenance_assignments
-- ----------------------------------------------------------------------------
CREATE TABLE maintenance_assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    technician_id INT NOT NULL,
    assigned_by INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_completion TIMESTAMP NULL,
    work_notes TEXT NULL,
    assignment_status ENUM('ACTIVE', 'COMPLETED', 'REASSIGNED') NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_assign_complaint FOREIGN KEY (complaint_id) 
        REFERENCES complaints(complaint_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_assign_tech FOREIGN KEY (technician_id) 
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_assign_warden FOREIGN KEY (assigned_by) 
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_assign_tech ON maintenance_assignments(technician_id);
CREATE INDEX idx_assign_complaint ON maintenance_assignments(complaint_id);

-- ----------------------------------------------------------------------------
-- TABLE 8: maintenance_work_logs
-- ----------------------------------------------------------------------------
CREATE TABLE maintenance_work_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    assignment_id INT NOT NULL,
    technician_id INT NOT NULL,
    action_taken TEXT NOT NULL,
    parts_replaced VARCHAR(255) NULL,
    cost_incurred DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_cost_non_negative CHECK (cost_incurred >= 0),
    CONSTRAINT fk_worklog_assign FOREIGN KEY (assignment_id) 
        REFERENCES maintenance_assignments(assignment_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_worklog_tech FOREIGN KEY (technician_id) 
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- TABLE 9: complaint_feedback
-- ----------------------------------------------------------------------------
CREATE TABLE complaint_feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL UNIQUE,
    student_id INT NOT NULL,
    rating INT NOT NULL,
    feedback_comments TEXT NULL,
    submitted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_rating_range CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT fk_feedback_complaint FOREIGN KEY (complaint_id) 
        REFERENCES complaints(complaint_id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_feedback_student FOREIGN KEY (student_id) 
        REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------------------------------------------------------
-- TABLE 10: audit_logs (SYSTEM AUDIT & SECURITY TRAIL)
-- ----------------------------------------------------------------------------
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    entity_name VARCHAR(50) NOT NULL,
    entity_id INT NOT NULL,
    action_type VARCHAR(20) NOT NULL,
    performed_by INT NULL,
    old_state TEXT NULL,
    new_state TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (performed_by) 
        REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE INDEX idx_audit_entity ON audit_logs(entity_name, entity_id);
