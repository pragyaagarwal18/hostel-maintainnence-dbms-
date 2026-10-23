-- ============================================================================
-- DATABASE SYSTEMS LAB (BCSE302P) - LAB INTERNAL ASSESSMENT 8, 9 & 10
-- TOPIC: HOSTEL MAINTENANCE AND COMPLAINT MANAGEMENT SYSTEM
-- AUTHORS: PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)
-- FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26
-- FILE: 05_seed_data.sql - Comprehensive Seed Dataset (Expanded Roster)
-- ============================================================================

USE hostel_maintenance_db;

-- ----------------------------------------------------------------------------
-- 1. SEED USERS: SINGLE USERS TABLE WITH ROLE-BASED ACCESS CONTROL
-- (Strict compliance: No separate tables for Admin/Student/Technician)
-- ----------------------------------------------------------------------------
INSERT INTO users (user_id, reg_no, full_name, email, password_hash, role, phone_number, is_active) VALUES
-- Students
(1, '24BCI0006', 'Suhani Singh', 'suhani.24bci0006@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'STUDENT', '+91 9876543211', TRUE),
(2, '24BCI0112', 'Rahul Menon', 'rahul.menon@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'STUDENT', '+91 9876543231', TRUE),
(3, '24BCI0145', 'Ananya Sen', 'ananya.sen@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'STUDENT', '+91 9876543232', TRUE),
(4, '24BCI0189', 'Rohan Verma', 'rohan.verma@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'STUDENT', '+91 9876543233', TRUE),
(5, '24BCI0210', 'Priya Sharma', 'priya.sharma@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'STUDENT', '+91 9876543234', TRUE),
(6, '24BCI0235', 'Aryan Patel', 'aryan.patel@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'STUDENT', '+91 9876543235', TRUE),
(7, '24BCI0301', 'Sneha Reddy', 'sneha.reddy@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'STUDENT', '+91 9876543236', TRUE),

-- Wardens & Administrators
(10, '24BCI0280', 'Pragya Agarwal', 'pragya.24bci0280@vitstudent.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'WARDEN_ADMIN', '+91 9876543210', TRUE),
(11, 'FAC104025', 'Dr. V. Sivakumar', 'vsivakumar@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'WARDEN_ADMIN', '+91 9876543212', TRUE),
(12, 'FAC102140', 'Prof. Radhika Raman', 'rraman@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'WARDEN_ADMIN', '+91 9876543213', TRUE),
(13, 'FAC103550', 'Mr. K. Sundar', 'ksundar@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'WARDEN_ADMIN', '+91 9876543214', TRUE),

-- Maintenance Technicians
(20, 'TECH001', 'Ramesh Kumar', 'ramesh.tech@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'TECHNICIAN', '+91 9876543220', TRUE),
(21, 'TECH002', 'Suresh Sharma', 'suresh.tech@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'TECHNICIAN', '+91 9876543221', TRUE),
(22, 'TECH003', 'Amit Patel', 'amit.tech@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'TECHNICIAN', '+91 9876543222', TRUE),
(23, 'TECH004', 'Rajesh Varma', 'rajesh.tech@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'TECHNICIAN', '+91 9876543223', TRUE),
(24, 'TECH005', 'Manoj Tiwari', 'manoj.tech@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'TECHNICIAN', '+91 9876543224', TRUE),
(25, 'TECH006', 'Deepak Das', 'deepak.tech@vit.ac.in', '$2b$10$z8mY9wH7p6V3y0Dq1kQx.OqNn7qP1uQ2wE3r4t5y6u7i8o9p0a1s2', 'TECHNICIAN', '+91 9876543225', TRUE);

-- ----------------------------------------------------------------------------
-- 2. SEED HOSTEL BLOCKS
-- ----------------------------------------------------------------------------
INSERT INTO hostel_blocks (block_id, block_name, gender_type, total_floors, warden_id) VALUES
(1, 'Block-A (Sarojini)', 'FEMALE', 6, 10),
(2, 'Block-B (Tagore)', 'MALE', 7, 11),
(3, 'Block-C (Ramanujan)', 'CO-ED', 8, 12),
(4, 'Block-D (Deluxe)', 'CO-ED', 5, 13);

-- ----------------------------------------------------------------------------
-- 3. SEED ROOMS
-- ----------------------------------------------------------------------------
INSERT INTO rooms (room_id, block_id, room_number, floor_no, capacity, current_occupancy, room_type, status) VALUES
(1, 1, 'A-101', 1, 2, 2, '2-BED-AC', 'OCCUPIED'),
(2, 1, 'A-102', 1, 2, 1, '2-BED-AC', 'OCCUPIED'),
(3, 1, 'A-201', 2, 3, 3, '3-BED-NON-AC', 'OCCUPIED'),
(4, 2, 'B-101', 1, 2, 2, '2-BED-AC', 'OCCUPIED'),
(5, 2, 'B-205', 2, 2, 1, '2-BED-AC', 'UNDER_MAINTENANCE'),
(6, 2, 'B-302', 3, 4, 0, '4-BED-NON-AC', 'AVAILABLE'),
(7, 3, 'C-101', 1, 1, 1, 'SINGLE-DELUXE', 'OCCUPIED'),
(8, 4, 'D-105', 1, 2, 2, '2-BED-AC', 'OCCUPIED');

-- ----------------------------------------------------------------------------
-- 4. SEED COMPLAINT CATEGORIES
-- ----------------------------------------------------------------------------
INSERT INTO complaint_categories (category_id, category_name, sla_resolution_hours, priority_default, description) VALUES
(1, 'Electrical & Wiring', 24, 'MEDIUM', 'Ceiling fan, switchboard, lights, power socket issues'),
(2, 'Plumbing & Sanitation', 12, 'HIGH', 'Water leakage, pipe burst, flush repair, faucet damage'),
(3, 'Air Conditioning & HVAC', 24, 'MEDIUM', 'AC cooling malfunction, noise, water leakage'),
(4, 'Wi-Fi & LAN Network', 6, 'HIGH', 'Access point offline, slow connectivity, ethernet port damage'),
(5, 'Carpentry & Furniture', 48, 'LOW', 'Wardrobe doors, study table repair, cot alignment'),
(6, 'Civil & Pest Control', 72, 'LOW', 'Wall dampness, paint peeling, termite inspection');

-- ----------------------------------------------------------------------------
-- 5. SEED COMPLAINTS
-- ----------------------------------------------------------------------------
INSERT INTO complaints (complaint_id, ticket_number, student_id, room_id, category_id, title, description, priority, status, created_at, resolved_at) VALUES
(1, 'TKT-2026-001', 1, 1, 1, 'Ceiling fan regulator sparking and speed not changing', 'The speed controller sparks when turned past speed 2. Potential short circuit risk.', 'HIGH', 'ASSIGNED', '2026-10-18 10:30:00', NULL),
(2, 'TKT-2026-002', 1, 1, 3, 'Split AC blowing room temperature air instead of cool air', 'AC unit is humming but no cooling in the room since yesterday afternoon.', 'MEDIUM', 'RESOLVED', '2026-10-15 09:00:00', '2026-10-16 11:20:00'),
(3, 'TKT-2026-003', 2, 4, 2, 'Continuous water leakage under bathroom wash basin', 'Waste pipe joint is loose and causing water accumulation on floor.', 'HIGH', 'IN_PROGRESS', '2026-10-19 14:15:00', NULL),
(4, 'TKT-2026-004', 3, 2, 4, 'Wi-Fi SSID not broadcasting in A-102', 'Unable to connect to VIT-Hostel Wi-Fi network; error connecting to gateway.', 'MEDIUM', 'SUBMITTED', '2026-10-20 18:00:00', NULL),
(5, 'TKT-2026-005', 4, 4, 5, 'Study table drawer lock broken', 'The study drawer handle and lock mechanism came off.', 'LOW', 'SUBMITTED', '2026-10-20 19:45:00', NULL),
(6, 'TKT-2026-006', 6, 5, 2, 'Emergency main supply valve pipe cracked in B-205', 'Water gushing from main bathroom inlet valve.', 'EMERGENCY', 'ASSIGNED', '2026-10-20 20:00:00', NULL),
(7, 'TKT-2026-007', 5, 7, 3, 'Water dripping from indoor split AC unit', 'Condensation drain pipe blocked.', 'HIGH', 'ASSIGNED', '2026-10-20 21:00:00', NULL),
(8, 'TKT-2026-008', 7, 3, 6, 'Window latch loose causing rainwater seep', 'Latch needs tightening.', 'LOW', 'RESOLVED', '2026-10-17 11:20:00', '2026-10-18 16:00:00');

-- ----------------------------------------------------------------------------
-- 6. SEED MAINTENANCE ASSIGNMENTS
-- ----------------------------------------------------------------------------
INSERT INTO maintenance_assignments (assignment_id, complaint_id, technician_id, assigned_by, assigned_at, expected_completion, work_notes, assignment_status) VALUES
(1, 1, 20, 10, '2026-10-18 11:00:00', '2026-10-19 11:00:00', 'Assigned to Ramesh. Replace rotary switch.', 'ACTIVE'),
(2, 2, 22, 10, '2026-10-15 09:30:00', '2026-10-16 09:30:00', 'Check refrigerant gas levels.', 'COMPLETED'),
(3, 3, 21, 11, '2026-10-19 15:00:00', '2026-10-20 03:00:00', 'Carry PVC joint cement.', 'ACTIVE'),
(4, 6, 21, 11, '2026-10-20 20:15:00', '2026-10-21 00:00:00', 'Emergency water pipeline repair assigned.', 'ACTIVE'),
(5, 7, 22, 12, '2026-10-20 21:15:00', '2026-10-21 21:15:00', 'Clear drain pipe.', 'ACTIVE'),
(6, 8, 25, 10, '2026-10-17 12:00:00', '2026-10-18 12:00:00', 'Fix window frame latch.', 'COMPLETED');

-- ----------------------------------------------------------------------------
-- 7. SEED WORK LOGS & FEEDBACK
-- ----------------------------------------------------------------------------
INSERT INTO maintenance_work_logs (log_id, assignment_id, technician_id, action_taken, parts_replaced, cost_incurred, logged_at) VALUES
(1, 2, 22, 'Replaced 45uF starting capacitor and cleaned filters.', 'Capacitor 45uF', 450.00, '2026-10-16 11:15:00'),
(2, 6, 25, 'Tightened brass latch screws and added seal gasket.', 'Brass Latch Screws', 80.00, '2026-10-18 15:45:00');

INSERT INTO complaint_feedback (feedback_id, complaint_id, student_id, rating, feedback_comments, submitted_at) VALUES
(1, 2, 1, 5, 'Very quick resolution! The AC works perfectly now. Thank you maintenance team.', '2026-10-16 14:00:00'),
(2, 8, 7, 4, 'Window latch fixed properly before heavy rain.', '2026-10-18 17:00:00');
