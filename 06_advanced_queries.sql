-- ============================================================================
-- DATABASE SYSTEMS LAB (BCSE302P) - LAB INTERNAL ASSESSMENT 8, 9 & 10
-- TOPIC: HOSTEL MAINTENANCE AND COMPLAINT MANAGEMENT SYSTEM
-- AUTHORS: PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)
-- FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26
-- FILE: 06_advanced_queries.sql - Verification, CRUD, Joins, Aggregates & Analytics
-- ============================================================================

USE hostel_maintenance_db;

-- ----------------------------------------------------------------------------
-- 1. MANDATORY PRINT: Verification of Student Authors
-- ----------------------------------------------------------------------------
SELECT 
    'PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)' AS project_authors,
    'BCSE302P Database Systems Lab - Slot L25+L26' AS course_details,
    'Faculty: Dr. V. SIVAKUMAR' AS faculty,
    NOW() AS test_execution_timestamp;

-- ----------------------------------------------------------------------------
-- 2. BASIC CRUD OPERATIONS
-- ----------------------------------------------------------------------------

-- (C) Create: Insert a new complaint ticket lodged by Suhani Singh (24BCI0006)
INSERT INTO complaints (
    ticket_number, student_id, room_id, category_id, title, description, priority, status
) VALUES (
    'TKT-2026-TEST01', 2, 1, 1, 
    'Study lamp socket loose', 
    'The wall socket near bed 1 sparks occasionally when charging laptop.', 
    'HIGH', 'SUBMITTED'
);

-- (R) Read: Fetch newly created complaint details
SELECT complaint_id, ticket_number, title, priority, status, created_at
FROM complaints 
WHERE ticket_number = 'TKT-2026-TEST01';

-- (U) Update: Update complaint priority to EMERGENCY
UPDATE complaints 
SET priority = 'EMERGENCY'
WHERE ticket_number = 'TKT-2026-TEST01';

-- (D) Delete: Remove the test complaint
DELETE FROM complaints 
WHERE ticket_number = 'TKT-2026-TEST01';

-- ----------------------------------------------------------------------------
-- 3. COMPLEX MULTI-TABLE JOINS (5-TABLE RELATIONAL JOIN)
-- Combines Complaints, Students, Rooms, Hostel Blocks, and Categories
-- ----------------------------------------------------------------------------
SELECT 
    c.ticket_number,
    c.title,
    c.priority,
    c.status,
    u.full_name AS student_name,
    u.reg_no AS student_reg_no,
    b.block_name,
    r.room_number,
    cat.category_name,
    cat.sla_resolution_hours,
    c.created_at
FROM complaints c
INNER JOIN users u ON c.student_id = u.user_id
INNER JOIN rooms r ON c.room_id = r.room_id
INNER JOIN hostel_blocks b ON r.block_id = b.block_id
INNER JOIN complaint_categories cat ON c.category_id = cat.category_id
ORDER BY c.created_at DESC;

-- ----------------------------------------------------------------------------
-- 4. AGGREGATE QUERY WITH GROUP BY & HAVING
-- Calculates total complaints, resolved count, and average rating per category,
-- filtering only categories with at least 1 complaint.
-- ----------------------------------------------------------------------------
SELECT 
    cat.category_id,
    cat.category_name,
    COUNT(c.complaint_id) AS total_complaints,
    SUM(CASE WHEN c.status = 'RESOLVED' THEN 1 ELSE 0 END) AS resolved_count,
    SUM(CASE WHEN c.status IN ('SUBMITTED', 'ASSIGNED', 'IN_PROGRESS') THEN 1 ELSE 0 END) AS pending_count,
    ROUND(AVG(COALESCE(cf.rating, 0)), 2) AS avg_student_rating
FROM complaint_categories cat
LEFT JOIN complaints c ON cat.category_id = c.category_id
LEFT JOIN complaint_feedback cf ON c.complaint_id = cf.complaint_id
GROUP BY cat.category_id, cat.category_name
HAVING total_complaints >= 1
ORDER BY total_complaints DESC;

-- ----------------------------------------------------------------------------
-- 5. ADVANCED SUBQUERY: Technicians whose resolution rating is above hostel average
-- ----------------------------------------------------------------------------
SELECT 
    u.user_id,
    u.reg_no,
    u.full_name,
    ROUND(AVG(cf.rating), 2) AS technician_avg_rating
FROM users u
INNER JOIN maintenance_assignments ma ON u.user_id = ma.technician_id
INNER JOIN complaints c ON ma.complaint_id = c.complaint_id
INNER JOIN complaint_feedback cf ON c.complaint_id = cf.complaint_id
WHERE u.role = 'TECHNICIAN'
GROUP BY u.user_id, u.reg_no, u.full_name
HAVING technician_avg_rating > (
    SELECT AVG(rating) FROM complaint_feedback
);

-- ----------------------------------------------------------------------------
-- 6. WINDOW FUNCTION: Ranking complaints by SLA age within each category
-- ----------------------------------------------------------------------------
SELECT 
    c.ticket_number,
    cat.category_name,
    c.priority,
    c.status,
    TIMESTAMPDIFF(HOUR, c.created_at, NOW()) AS age_in_hours,
    DENSE_RANK() OVER (
        PARTITION BY c.category_id 
        ORDER BY c.created_at ASC
    ) AS urgency_rank_in_category
FROM complaints c
JOIN complaint_categories cat ON c.category_id = cat.category_id
WHERE c.status NOT IN ('RESOLVED', 'CLOSED');

-- ----------------------------------------------------------------------------
-- 7. EXECUTION OF DATABASE VIEWS
-- ----------------------------------------------------------------------------
SELECT * FROM view_active_complaints_summary;
SELECT * FROM view_technician_workload_metrics;
SELECT * FROM view_blockwise_resolution_analytics;

-- ----------------------------------------------------------------------------
-- 8. DEMONSTRATION OF STORED PROCEDURE WITH OUT PARAMETERS
-- ----------------------------------------------------------------------------
SET @out_code = 0;
SET @out_msg = '';

-- Test assigning complaint #4 to Technician Ramesh (user_id: 4) by Warden Pragya (user_id: 1)
CALL sp_pragya24bci0280_assign_technician(4, 4, 1, 12, 'High priority network inspection required', @out_code, @out_msg);

SELECT @out_code AS result_code, @out_msg AS result_message;

-- Verify updated status in complaints table
SELECT ticket_number, status FROM complaints WHERE complaint_id = 4;

-- ----------------------------------------------------------------------------
-- 9. AUDIT TRAIL VERIFICATION (Generated via Triggers & Stored Procedure)
-- ----------------------------------------------------------------------------
SELECT 
    log_id,
    entity_name,
    entity_id,
    action_type,
    performed_by,
    old_state,
    new_state,
    created_at
FROM audit_logs
ORDER BY log_id DESC
LIMIT 5;
