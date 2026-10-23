-- ============================================================================
-- DATABASE SYSTEMS LAB (BCSE302P) - LAB INTERNAL ASSESSMENT 8, 9 & 10
-- TOPIC: HOSTEL MAINTENANCE AND COMPLAINT MANAGEMENT SYSTEM
-- AUTHORS: PRAGYA AGARWAL (24BCI0280) & SUHANI SINGH (24BCI0006)
-- FACULTY: Dr. V. SIVAKUMAR | SLOT: L25+L26
-- FILE: 04_stored_procedures.sql - Stored Procedures with ACID Transactions
-- ============================================================================

USE hostel_maintenance_db;

DELIMITER //

-- ----------------------------------------------------------------------------
-- PROCEDURE 1: sp_pragya24bci0280_assign_technician
-- Implements ACID Transaction for atomically assigning a technician to a complaint
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_pragya24bci0280_assign_technician //

CREATE PROCEDURE sp_pragya24bci0280_assign_technician(
    IN p_complaint_id INT,
    IN p_technician_id INT,
    IN p_assigned_by INT,
    IN p_expected_hours INT,
    IN p_notes TEXT,
    OUT p_status_code INT,
    OUT p_status_message VARCHAR(255)
)
proc_label: BEGIN
    DECLARE v_complaint_status VARCHAR(50);
    DECLARE v_tech_role VARCHAR(50);
    DECLARE v_warden_role VARCHAR(50);
    DECLARE v_expected_date TIMESTAMP;

    -- Exception handler with automated transaction rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_code = 500;
        SET p_status_message = 'Transaction Failed: SQLEXCEPTION encountered during assignment. Rolled back.';
    END;

    -- 1. Validate complaint existence & status
    SELECT status INTO v_complaint_status 
    FROM complaints 
    WHERE complaint_id = p_complaint_id;

    IF v_complaint_status IS NULL THEN
        SET p_status_code = 404;
        SET p_status_message = 'Error [24BCI0280]: Complaint ticket does not exist.';
        LEAVE proc_label;
    END IF;

    IF v_complaint_status IN ('RESOLVED', 'CLOSED', 'REJECTED') THEN
        SET p_status_code = 400;
        SET p_status_message = CONCAT('Error: Cannot assign complaint with status ', v_complaint_status);
        LEAVE proc_label;
    END IF;

    -- 2. Validate technician role
    SELECT role INTO v_tech_role 
    FROM users 
    WHERE user_id = p_technician_id AND is_active = TRUE;

    IF v_tech_role IS NULL OR v_tech_role <> 'TECHNICIAN' THEN
        SET p_status_code = 400;
        SET p_status_message = 'Error: The assigned user must be an active TECHNICIAN.';
        LEAVE proc_label;
    END IF;

    -- 3. Validate warden assigner role
    SELECT role INTO v_warden_role 
    FROM users 
    WHERE user_id = p_assigned_by;

    IF v_warden_role IS NULL OR v_warden_role <> 'WARDEN_ADMIN' THEN
        SET p_status_code = 403;
        SET p_status_message = 'Error: Only WARDEN_ADMIN can assign maintenance work.';
        LEAVE proc_label;
    END IF;

    -- 4. Calculate SLA expected completion timestamp
    SET v_expected_date = DATE_ADD(NOW(), INTERVAL IFNULL(p_expected_hours, 24) HOUR);

    -- 5. Execute ACID Transaction
    START TRANSACTION;

        -- Deactivate any prior active assignment for this complaint
        UPDATE maintenance_assignments
        SET assignment_status = 'REASSIGNED'
        WHERE complaint_id = p_complaint_id AND assignment_status = 'ACTIVE';

        -- Insert new maintenance assignment record
        INSERT INTO maintenance_assignments (
            complaint_id,
            technician_id,
            assigned_by,
            assigned_at,
            expected_completion,
            work_notes,
            assignment_status
        ) VALUES (
            p_complaint_id,
            p_technician_id,
            p_assigned_by,
            NOW(),
            v_expected_date,
            p_notes,
            'ACTIVE'
        );

        -- Update complaint ticket status to ASSIGNED
        UPDATE complaints
        SET status = 'ASSIGNED'
        WHERE complaint_id = p_complaint_id;

        -- Record system audit log entry
        INSERT INTO audit_logs (
            entity_name,
            entity_id,
            action_type,
            performed_by,
            old_state,
            new_state,
            created_at
        ) VALUES (
            'maintenance_assignments',
            p_complaint_id,
            'ASSIGN_TECHNICIAN',
            p_assigned_by,
            CONCAT('Previous status: ', v_complaint_status),
            CONCAT('Assigned to TechID: ', p_technician_id, ' by WardenID: ', p_assigned_by),
            NOW()
        );

    COMMIT;

    SET p_status_code = 200;
    SET p_status_message = 'Success [Pragya 24BCI0280]: Technician successfully assigned and status updated.';
END //

-- ----------------------------------------------------------------------------
-- PROCEDURE 2: sp_suhani24bci0006_resolve_complaint_with_worklog
-- Implements ACID Transaction for logging technician work and marking complaint RESOLVED
-- ----------------------------------------------------------------------------
DROP PROCEDURE IF EXISTS sp_suhani24bci0006_resolve_complaint_with_worklog //

CREATE PROCEDURE sp_suhani24bci0006_resolve_complaint_with_worklog(
    IN p_assignment_id INT,
    IN p_technician_id INT,
    IN p_action_taken TEXT,
    IN p_parts_replaced VARCHAR(255),
    IN p_cost DECIMAL(10, 2),
    OUT p_status_code INT,
    OUT p_status_message VARCHAR(255)
)
proc_label: BEGIN
    DECLARE v_complaint_id INT;
    DECLARE v_room_id INT;
    DECLARE v_assignment_tech INT;

    -- Exception handler with automated rollback
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_status_code = 500;
        SET p_status_message = 'Transaction Failed: SQLEXCEPTION encountered during resolution. Rolled back.';
    END;

    -- Validate assignment and technician authorization
    SELECT complaint_id, technician_id INTO v_complaint_id, v_assignment_tech
    FROM maintenance_assignments
    WHERE assignment_id = p_assignment_id AND assignment_status = 'ACTIVE';

    IF v_complaint_id IS NULL THEN
        SET p_status_code = 404;
        SET p_status_message = 'Error [24BCI0006]: Active assignment not found.';
        LEAVE proc_label;
    END IF;

    IF v_assignment_tech <> p_technician_id THEN
        SET p_status_code = 403;
        SET p_status_message = 'Error: Unauthorized. Only assigned technician can log resolution.';
        LEAVE proc_label;
    END IF;

    SELECT room_id INTO v_room_id FROM complaints WHERE complaint_id = v_complaint_id;

    -- Execute ACID Transaction
    START TRANSACTION;

        -- 1. Insert Work Log
        INSERT INTO maintenance_work_logs (
            assignment_id,
            technician_id,
            action_taken,
            parts_replaced,
            cost_incurred,
            logged_at
        ) VALUES (
            p_assignment_id,
            p_technician_id,
            p_action_taken,
            p_parts_replaced,
            IFNULL(p_cost, 0.00),
            NOW()
        );

        -- 2. Complete Assignment
        UPDATE maintenance_assignments
        SET assignment_status = 'COMPLETED'
        WHERE assignment_id = p_assignment_id;

        -- 3. Resolve Complaint
        UPDATE complaints
        SET status = 'RESOLVED',
            resolved_at = NOW()
        WHERE complaint_id = v_complaint_id;

        -- 4. Restore Room status if under maintenance
        UPDATE rooms
        SET status = 'OCCUPIED'
        WHERE room_id = v_room_id AND status = 'UNDER_MAINTENANCE';

        -- 5. Audit Log
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
            v_complaint_id,
            'RESOLVE_WITH_WORKLOG',
            p_technician_id,
            'Status: ASSIGNED / IN_PROGRESS',
            CONCAT('Status: RESOLVED | Parts: ', IFNULL(p_parts_replaced, 'None'), ' | Cost: ₹', IFNULL(p_cost, 0.00)),
            NOW()
        );

    COMMIT;

    SET p_status_code = 200;
    SET p_status_message = 'Success [Suhani 24BCI0006]: Maintenance logged and complaint resolved.';
END //

DELIMITER ;
