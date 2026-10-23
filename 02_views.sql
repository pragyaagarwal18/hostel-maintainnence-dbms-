-- ============================================================================
-- DATABASE SYSTEMS LAB (BCSE302P) - LAB INTERNAL ASSESSMENT 8, 9 & 10
-- TOPIC: HOSTEL MAINTENANCE AND COMPLAINT MANAGEMENT SYSTEM
-- AUTHORS: PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)
-- FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26
-- FILE: 02_views.sql - Database Views for Reporting and Dashboard Analytics
-- ============================================================================

USE hostel_maintenance_db;

-- ----------------------------------------------------------------------------
-- VIEW 1: view_active_complaints_summary
-- Joins: complaints, users (student & technician), rooms, hostel_blocks, complaint_categories
-- Purpose: Real-time dashboard view for Warden to monitor pending issues and SLA status
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS view_active_complaints_summary;

CREATE VIEW view_active_complaints_summary AS
SELECT 
    c.complaint_id,
    c.ticket_number,
    c.title,
    c.priority,
    c.status AS complaint_status,
    c.created_at AS reported_at,
    cat.category_name,
    cat.sla_resolution_hours,
    TIMESTAMPDIFF(HOUR, c.created_at, NOW()) AS hours_elapsed,
    CASE 
        WHEN TIMESTAMPDIFF(HOUR, c.created_at, NOW()) > cat.sla_resolution_hours THEN 'SLA_BREACHED'
        WHEN TIMESTAMPDIFF(HOUR, c.created_at, NOW()) >= (cat.sla_resolution_hours * 0.75) THEN 'SLA_WARNING'
        ELSE 'WITHIN_SLA'
    END AS sla_status,
    u_student.reg_no AS student_reg_no,
    u_student.full_name AS student_name,
    u_student.phone_number AS student_contact,
    b.block_name,
    r.room_number,
    u_tech.full_name AS assigned_technician_name,
    u_tech.phone_number AS technician_contact
FROM complaints c
INNER JOIN users u_student ON c.student_id = u_student.user_id
INNER JOIN rooms r ON c.room_id = r.room_id
INNER JOIN hostel_blocks b ON r.block_id = b.block_id
INNER JOIN complaint_categories cat ON c.category_id = cat.category_id
LEFT JOIN maintenance_assignments ma ON c.complaint_id = ma.complaint_id AND ma.assignment_status = 'ACTIVE'
LEFT JOIN users u_tech ON ma.technician_id = u_tech.user_id
WHERE c.status NOT IN ('CLOSED', 'REJECTED');

-- ----------------------------------------------------------------------------
-- VIEW 2: view_technician_workload_metrics
-- Aggregations: COUNT, AVG, conditional counts across technician assignments & feedback
-- Purpose: Evaluate maintenance crew performance and assign tasks based on load
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS view_technician_workload_metrics;

CREATE VIEW view_technician_workload_metrics AS
SELECT 
    u.user_id AS technician_id,
    u.reg_no AS employee_code,
    u.full_name AS technician_name,
    u.email AS technician_email,
    u.phone_number AS contact_number,
    COUNT(DISTINCT ma.assignment_id) AS total_lifetime_assignments,
    COUNT(DISTINCT CASE WHEN c.status IN ('ASSIGNED', 'IN_PROGRESS') THEN c.complaint_id END) AS active_workload,
    COUNT(DISTINCT CASE WHEN c.status = 'RESOLVED' THEN c.complaint_id END) AS completed_tasks,
    ROUND(COALESCE(AVG(cf.rating), 0), 2) AS average_rating,
    COUNT(DISTINCT cf.feedback_id) AS feedback_count,
    COALESCE(SUM(mwl.cost_incurred), 0.00) AS total_parts_cost_handled
FROM users u
LEFT JOIN maintenance_assignments ma ON u.user_id = ma.technician_id
LEFT JOIN complaints c ON ma.complaint_id = c.complaint_id
LEFT JOIN maintenance_work_logs mwl ON ma.assignment_id = mwl.assignment_id
LEFT JOIN complaint_feedback cf ON c.complaint_id = cf.complaint_id
WHERE u.role = 'TECHNICIAN' AND u.is_active = TRUE
GROUP BY u.user_id, u.reg_no, u.full_name, u.email, u.phone_number;

-- ----------------------------------------------------------------------------
-- VIEW 3: view_blockwise_resolution_analytics
-- Purpose: Aggregated hostel building maintenance performance across categories
-- ----------------------------------------------------------------------------
DROP VIEW IF EXISTS view_blockwise_resolution_analytics;

CREATE VIEW view_blockwise_resolution_analytics AS
SELECT 
    b.block_id,
    b.block_name,
    b.gender_type,
    cat.category_name,
    COUNT(c.complaint_id) AS total_complaints,
    SUM(CASE WHEN c.status = 'RESOLVED' THEN 1 ELSE 0 END) AS resolved_complaints,
    SUM(CASE WHEN c.status IN ('SUBMITTED', 'ASSIGNED', 'IN_PROGRESS') THEN 1 ELSE 0 END) AS pending_complaints,
    ROUND(AVG(CASE 
        WHEN c.resolved_at IS NOT NULL 
        THEN TIMESTAMPDIFF(MINUTE, c.created_at, c.resolved_at) / 60.0 
        ELSE NULL 
    END), 2) AS avg_resolution_time_hours,
    ROUND(COALESCE(AVG(cf.rating), 0), 2) AS avg_block_category_rating
FROM hostel_blocks b
INNER JOIN rooms r ON b.block_id = r.block_id
LEFT JOIN complaints c ON r.room_id = c.room_id
LEFT JOIN complaint_categories cat ON c.category_id = cat.category_id
LEFT JOIN complaint_feedback cf ON c.complaint_id = cf.complaint_id
GROUP BY b.block_id, b.block_name, b.gender_type, cat.category_name;
