DROP DATABASE IF EXISTS crm_dtu;
CREATE DATABASE crm_dtu;
USE crm_dtu;

CREATE TABLE Customer (
    id                  INT AUTO_INCREMENT PRIMARY KEY,
    name                VARCHAR(100) NOT NULL,
    email               VARCHAR(100) UNIQUE NOT NULL,
    phone               VARCHAR(20),
    address             TEXT,
    registration_date   DATE NOT NULL DEFAULT (CURDATE()),
    last_interaction_at DATETIME DEFAULT NULL
);

CREATE TABLE Employee (
    id      INT AUTO_INCREMENT PRIMARY KEY,
    name    VARCHAR(100) NOT NULL,
    email   VARCHAR(100) UNIQUE NOT NULL,
    role    ENUM('Sales', 'Support', 'Manager') NOT NULL DEFAULT 'Support'
);

CREATE TABLE Leads(
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    name                 VARCHAR(100) NOT NULL,
    email                VARCHAR(100) UNIQUE,
    phone                VARCHAR(20),
    source               ENUM('Website', 'Referral', 'Social', 'Email', 'Event') NOT NULL DEFAULT 'Website',
    status               ENUM('New', 'Contacted', 'Qualified', 'Lost', 'Converted') NOT NULL DEFAULT 'New',
    assigned_employee_id INT DEFAULT NULL,
    created_at           DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_lead_employee FOREIGN KEY (assigned_employee_id)
        REFERENCES Employee(id) ON DELETE SET NULL
);

CREATE TABLE Opportunity (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    title                VARCHAR(150) NOT NULL,
    customer_id          INT DEFAULT NULL,
    lead_id              INT DEFAULT NULL,
    owner_employee_id    INT DEFAULT NULL,
    stage                ENUM('Prospecting', 'Proposal', 'Negotiation', 'Won', 'Lost') NOT NULL DEFAULT 'Prospecting',
    estimated_value      DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    expected_close_date  DATE,
    created_at           DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_opp_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(id) ON DELETE SET NULL,
    CONSTRAINT fk_opp_lead FOREIGN KEY (lead_id)
        REFERENCES Leads(id) ON DELETE SET NULL,
    CONSTRAINT fk_opp_owner FOREIGN KEY (owner_employee_id)
        REFERENCES Employee(id) ON DELETE SET NULL
);

CREATE TABLE Product (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(120) NOT NULL,
    sku         VARCHAR(40) UNIQUE NOT NULL,
    category    VARCHAR(80),
    unit_price  DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE SalesOrder (
    id            INT AUTO_INCREMENT PRIMARY KEY,
    customer_id   INT NOT NULL,
    employee_id   INT DEFAULT NULL,
    order_date    DATETIME NOT NULL DEFAULT NOW(),
    status        ENUM('Draft', 'Confirmed', 'Shipped', 'Completed', 'Cancelled') NOT NULL DEFAULT 'Draft',
    total_amount  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_employee FOREIGN KEY (employee_id)
        REFERENCES Employee(id) ON DELETE SET NULL
);

CREATE TABLE SalesOrderItem (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    order_id    INT NOT NULL,
    product_id  INT NOT NULL,
    quantity    INT NOT NULL DEFAULT 1,
    unit_price  DECIMAL(10,2) NOT NULL,
    line_total  DECIMAL(12,2) NOT NULL,
    CONSTRAINT fk_order_item_order FOREIGN KEY (order_id)
        REFERENCES SalesOrder(id) ON DELETE CASCADE,
    CONSTRAINT fk_order_item_product FOREIGN KEY (product_id)
        REFERENCES Product(id) ON DELETE RESTRICT
);


CREATE TABLE Payment (
    id               INT AUTO_INCREMENT PRIMARY KEY,
    order_id         INT NOT NULL,
    method           ENUM('Cash', 'Card', 'UPI', 'Bank Transfer') NOT NULL DEFAULT 'UPI',
    status           ENUM('Pending', 'Completed', 'Failed', 'Refunded') NOT NULL DEFAULT 'Pending',
    amount           DECIMAL(12,2) NOT NULL,
    paid_at          DATETIME DEFAULT NULL,
    transaction_ref  VARCHAR(100) UNIQUE,
    CONSTRAINT fk_payment_order FOREIGN KEY (order_id)
        REFERENCES SalesOrder(id) ON DELETE CASCADE
);


CREATE TABLE Interaction (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT DEFAULT NULL,
    date        DATETIME NOT NULL DEFAULT NOW(),
    type        ENUM('Call', 'Email', 'Meeting', 'Chat') NOT NULL,
    notes       TEXT,
    CONSTRAINT fk_inter_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(id) ON DELETE CASCADE,
    CONSTRAINT fk_inter_employee FOREIGN KEY (employee_id)
        REFERENCES Employee(id) ON DELETE SET NULL
);


CREATE TABLE SupportTicket (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT DEFAULT NULL,
    status      ENUM('Open', 'In Progress', 'Resolved', 'Closed') NOT NULL DEFAULT 'Open',
    priority    ENUM('Low', 'Medium', 'High', 'Critical') NOT NULL DEFAULT 'Medium',
    created_at  DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_ticket_customer FOREIGN KEY (customer_id)
        REFERENCES Customer(id) ON DELETE CASCADE,
    CONSTRAINT fk_ticket_employee FOREIGN KEY (employee_id)
        REFERENCES Employee(id) ON DELETE SET NULL
);


DELIMITER $$

CREATE TRIGGER trg_update_last_interaction
AFTER INSERT ON Interaction
FOR EACH ROW
BEGIN
    UPDATE Customer
    SET last_interaction_at = NEW.date
    WHERE id = NEW.customer_id;
END$$

DELIMITER ;

CREATE VIEW vw_interaction_details AS
SELECT
    i.id AS interaction_id,
    c.name AS customer_name,
    c.email AS customer_email,
    e.name AS handled_by,
    e.role AS employee_role,
    i.type AS interaction_type,
    i.date AS interaction_date,
    i.notes
FROM Interaction i
JOIN Customer c ON c.id = i.customer_id
LEFT JOIN Employee e ON e.id = i.employee_id
ORDER BY i.date DESC;

INSERT INTO Employee (name, email, role) VALUES
('Aarav Sharma', 'aarav@crm.com', 'Sales'),
('Riya Mehta', 'riya@crm.com', 'Support'),
('Kabir Singh', 'kabir@crm.com', 'Manager');

INSERT INTO Customer (name, email, phone, address) VALUES
('Rahul Verma', 'rahul@gmail.com', '9876543210', 'Delhi'),
('Sneha Kapoor', 'sneha@gmail.com', '9123456780', 'Mumbai'),
('Aditya Jain', 'aditya@gmail.com', '9988776655', 'Bangalore');

INSERT INTO Leads (name, email, phone, source, status, assigned_employee_id) VALUES
('Kunal Gupta', 'kunal@gmail.com', '9811111111', 'Website', 'Contacted', 1),
('Neha Arora', 'neha@gmail.com', '9822222222', 'Referral', 'Qualified', 2);

INSERT INTO Opportunity 
(title, customer_id, lead_id, owner_employee_id, stage, estimated_value, expected_close_date)
VALUES
('Enterprise Deal', 1, NULL, 1, 'Proposal', 150000, '2026-06-30'),
('Startup Plan', NULL, 2, 2, 'Negotiation', 50000, '2026-05-15');

INSERT INTO Product (name, sku, category, unit_price, is_active) VALUES
('CRM Software', 'CRM001', 'Software', 4999, TRUE),
('Analytics Tool', 'ANA002', 'Software', 2999, TRUE);

INSERT INTO SalesOrder (customer_id, employee_id, status, total_amount) VALUES
(1, 1, 'Confirmed', 4999),
(2, 2, 'Completed', 2999);

INSERT INTO SalesOrderItem (order_id, product_id, quantity, unit_price, line_total) VALUES
(1, 1, 1, 4999, 4999),
(2, 2, 1, 2999, 2999);

INSERT INTO Payment (order_id, method, status, amount, paid_at, transaction_ref) VALUES
(1, 'UPI', 'Completed', 4999, NOW(), 'TXN12345'),
(2, 'Card', 'Completed', 2999, NOW(), 'TXN67890');

INSERT INTO Interaction (customer_id, employee_id, type, notes) VALUES
(1, 1, 'Call', 'Discussed pricing'),
(2, 2, 'Email', 'Sent proposal');

INSERT INTO SupportTicket (customer_id, employee_id, status, priority) VALUES
(1, 2, 'Open', 'High'),
(2, 1, 'Resolved', 'Medium');


-- CREATE VIEW vw_sales_summary AS
-- SELECT 
--     s.id,
--     c.name AS customer_name,
--     e.name AS employee_name,
--     s.total_amount,
--     s.status
-- FROM SalesOrder s
-- JOIN Customer c ON c.id = s.customer_id
-- LEFT JOIN Employee e ON e.id = s.employee_id;

-- CREATE VIEW vw_lead_status AS
-- SELECT 
--     l.id,
--     l.name,
--     l.status,
--     e.name AS assigned_employee
-- FROM Leads l
-- LEFT JOIN Employee e ON e.id = l.assigned_employee_id;

-- CREATE VIEW vw_payment_summary AS
-- SELECT 
--     p.id,
--     s.id AS order_id,
--     p.amount,
--     p.status,
--     p.method
-- FROM Payment p
-- JOIN SalesOrder s ON s.id = p.order_id;


-- DELIMITER $$

-- CREATE TRIGGER trg_calculate_line_total
-- BEFORE INSERT ON SalesOrderItem
-- FOR EACH ROW
-- BEGIN
--     SET NEW.line_total = NEW.quantity * NEW.unit_price;
-- END$$

-- DELIMITER ;

-- DELIMITER $$

-- CREATE TRIGGER trg_update_order_total
-- AFTER INSERT ON SalesOrderItem
-- FOR EACH ROW
-- BEGIN
--     UPDATE SalesOrder
--     SET total_amount = total_amount + NEW.line_total
--     WHERE id = NEW.order_id;
-- END$$

-- DELIMITER ;

-- DELIMITER $$

-- CREATE TRIGGER trg_payment_complete
-- AFTER UPDATE ON Payment
-- FOR EACH ROW
-- BEGIN
--     IF NEW.status = 'Completed' THEN
--         UPDATE SalesOrder
--         SET status = 'Completed'
--         WHERE id = NEW.order_id;
--     END IF;
-- END$$

-- DELIMITER ;

-- -- USERS
-- DROP USER IF EXISTS 'sales_user'@'localhost';
-- DROP USER IF EXISTS 'support_user'@'localhost';

-- CREATE USER 'sales_user'@'localhost' IDENTIFIED BY 'sales123';
-- CREATE USER 'support_user'@'localhost' IDENTIFIED BY 'support123';

-- -- GRANTS
-- GRANT SELECT, INSERT, UPDATE ON crm_dtu.Customer TO 'sales_user'@'localhost';
-- GRANT SELECT, INSERT, UPDATE ON crm_dtu.Leads TO 'sales_user'@'localhost';
-- GRANT SELECT, INSERT, UPDATE ON crm_dtu.Opportunity TO 'sales_user'@'localhost';

-- GRANT SELECT, INSERT, UPDATE ON crm_dtu.SupportTicket TO 'support_user'@'localhost';
-- GRANT SELECT ON crm_dtu.Customer TO 'support_user'@'localhost';

-- FLUSH PRIVILEGES;

-- -- REVOKE
-- REVOKE INSERT ON crm_dtu.SupportTicket FROM 'support_user'@'localhost';
