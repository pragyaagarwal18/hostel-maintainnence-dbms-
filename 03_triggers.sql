-- ============================================================================
-- DATABASE SYSTEMS LAB (BCSE302P) - LAB INTERNAL ASSESSMENT 8, 9 & 10
-- TOPIC: HOSTEL MAINTENANCE AND COMPLAINT MANAGEMENT SYSTEM
-- AUTHORS: PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)
-- FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26
-- FILE: 03_triggers.sql - Triggers for Data Integrity, Timestamps & Audit Trail
-- ============================================================================

USE hostel_maintenance_db;

DELIMITER //

-- ----------------------------------------------------------------------------
-- TRIGGER 1: trg_before_complaint_insert_prevent_duplicate
-- Purpose: Data integrity check - prevents duplicate unresolved complaints
-- for the exact same room and category.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_before_complaint_insert_prevent_duplicate //

CREATE TRIGGER trg_before_complaint_insert_prevent_duplicate
BEFORE INSERT ON complaints
FOR EACH ROW
BEGIN
    DECLARE v_duplicate_count INT DEFAULT 0;

    SELECT COUNT(*) INTO v_duplicate_count
    FROM complaints
    WHERE room_id = NEW.room_id
      AND category_id = NEW.category_id
      AND status IN ('SUBMITTED', 'ASSIGNED', 'IN_PROGRESS');

    IF v_duplicate_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Integrity Error [24BCI0280 & 24BCI0006]: An active complaint already exists for this room and category.';
    END IF;
END //

-- ----------------------------------------------------------------------------
-- TRIGGER 2: trg_after_complaint_status_update
-- Purpose:
-- 1. Automatically records state transition into the audit_logs table.
-- 2. Automatically updates resolved_at timestamp when status becomes 'RESOLVED'.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_after_complaint_status_update //

CREATE TRIGGER trg_after_complaint_status_update
AFTER UPDATE ON complaints
FOR EACH ROW
BEGIN
    -- Only log and process if the status has actually changed
    IF OLD.status <> NEW.status THEN
        INSERT INTO audit_logs (
            entity_name,
            entity_id,
            action_type,
            performed_by,
            old_state,
            new_state,
            created_at
        ) VALUES (
            'complaints',
            NEW.complaint_id,
            'STATUS_CHANGE',
            NEW.student_id,
            CONCAT('Status was: ', OLD.status, ' | ResolvedAt: ', IFNULL(OLD.resolved_at, 'NULL')),
            CONCAT('Status became: ', NEW.status, ' | Priority: ', NEW.priority),
            NOW()
        );
    END IF;
END //

-- ----------------------------------------------------------------------------
-- TRIGGER 3: trg_before_complaint_update_timestamp
-- Purpose: Ensures resolved_at is timestamped when complaint is resolved
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_before_complaint_update_timestamp //

CREATE TRIGGER trg_before_complaint_update_timestamp
BEFORE UPDATE ON complaints
FOR EACH ROW
BEGIN
    IF NEW.status = 'RESOLVED' AND (OLD.status <> 'RESOLVED' OR OLD.resolved_at IS NULL) THEN
        SET NEW.resolved_at = NOW();
    END IF;
END //

-- ----------------------------------------------------------------------------
-- TRIGGER 4: trg_after_room_maintenance_status
-- Purpose: When a complaint of EMERGENCY priority is lodged, update room status
-- to UNDER_MAINTENANCE automatically.
-- ----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_after_complaint_emergency_room_status //

CREATE TRIGGER trg_after_complaint_emergency_room_status
AFTER INSERT ON complaints
FOR EACH ROW
BEGIN
    IF NEW.priority = 'EMERGENCY' THEN
        UPDATE rooms
        SET status = 'UNDER_MAINTENANCE'
        WHERE room_id = NEW.room_id;

        INSERT INTO audit_logs (
            entity_name,
            entity_id,
            action_type,
            performed_by,
            old_state,
            new_state,
            created_at
        ) VALUES (
            'rooms',
            NEW.room_id,
            'AUTO_MAINTENANCE',
            NEW.student_id,
            'Status: OCCUPIED/AVAILABLE',
            'Status: UNDER_MAINTENANCE due to EMERGENCY complaint ticket',
            NOW()
        );
    END IF;
END //

DELIMITER ;
