// ============================================================
//  CRM BACKEND — FINAL (MATCHES YOUR SCHEMA)
// ============================================================

const express = require('express');
const mysql   = require('mysql2/promise');
const cors    = require('cors');

const app  = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.static(__dirname));

// ============================================================
// DATABASE
// ============================================================
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'Sarthak2006@2028',
    database: 'crm_dtu',
    waitForConnections: true,
    connectionLimit: 10
});

// ============================================================
// HELPERS
// ============================================================
const ok  = (res, data) => res.json({ success: true, data });
const err = (res, e)    => res.status(500).json({ success: false, error: e.message });

// ============================================================
// CUSTOMERS
// ============================================================
app.get('/api/customers', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Customer ORDER BY registration_date DESC');
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/customers', async (req, res) => {
    const { name, email, phone, address } = req.body;
    try {
        const [r] = await pool.query(
            'INSERT INTO Customer (name,email,phone,address) VALUES (?,?,?,?)',
            [name,email,phone,address]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/customers/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Customer WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

// ============================================================
// EMPLOYEES
// ============================================================
app.get('/api/employees', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Employee ORDER BY name');
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/employees', async (req, res) => {
    const { name,email,role } = req.body;
    try {
        const [r] = await pool.query(
            'INSERT INTO Employee (name,email,role) VALUES (?,?,?)',
            [name,email,role]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/employees/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Employee WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

// ============================================================
// LEADS (TABLE = Leads)
// ============================================================
app.get('/api/leads', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT l.*, e.name AS assigned_to
            FROM Leads l
            LEFT JOIN Employee e ON e.id = l.assigned_employee_id
            ORDER BY l.created_at DESC
        `);
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/leads', async (req, res) => {
    const { name,email,phone,source,status,assigned_employee_id } = req.body;
    try {
        const [r] = await pool.query(
            `INSERT INTO Leads (name,email,phone,source,status,assigned_employee_id)
             VALUES (?,?,?,?,?,?)`,
            [name,email,phone,source,status,assigned_employee_id || null]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/leads/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Leads WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

// ============================================================
// OPPORTUNITIES
// ============================================================
app.get('/api/opportunities', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                o.*, 
                c.name AS customer_name,
                l.name AS lead_name,
                e.name AS owner_name
            FROM Opportunity o
            LEFT JOIN Customer c ON c.id=o.customer_id
            LEFT JOIN Leads l ON l.id=o.lead_id
            LEFT JOIN Employee e ON e.id=o.owner_employee_id
            ORDER BY o.created_at DESC
        `);
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/opportunities', async (req, res) => {
    const { title, customer_id, lead_id, owner_employee_id, stage, estimated_value, expected_close_date } = req.body;
    try {
        const [r] = await pool.query(
            `INSERT INTO Opportunity 
            (title,customer_id,lead_id,owner_employee_id,stage,estimated_value,expected_close_date)
            VALUES (?,?,?,?,?,?,?)`,
            [title,customer_id,lead_id,owner_employee_id,stage,estimated_value,expected_close_date]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/opportunities/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Opportunity WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

app.get('/api/products', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Product ORDER BY id DESC');
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/products', async (req, res) => {
    const { name, sku, category, unit_price, is_active } = req.body;
    try {
        const [r] = await pool.query(
            `INSERT INTO Product (name,sku,category,unit_price,is_active)
             VALUES (?,?,?,?,?)`,
            [name,sku,category,unit_price,is_active ?? true]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/products/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Product WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

app.get('/api/salesorders', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT 
                s.id, s.order_date, s.status, s.total_amount,
                c.name AS customer_name,
                e.name AS employee_name
            FROM SalesOrder s
            JOIN Customer c ON c.id=s.customer_id
            LEFT JOIN Employee e ON e.id=s.employee_id
            ORDER BY s.order_date DESC
        `);
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/salesorders', async (req, res) => {
    const { customer_id, employee_id, status, total_amount } = req.body;
    try {
        const [r] = await pool.query(
            `INSERT INTO SalesOrder (customer_id,employee_id,status,total_amount)
             VALUES (?,?,?,?)`,
            [customer_id,employee_id,status,total_amount]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/salesorders/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM SalesOrder WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

app.get('/api/interactions', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM vw_interaction_details');
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/interactions', async (req, res) => {
    const { customer_id, employee_id, type, notes } = req.body;
    try {
        const [r] = await pool.query(
            `INSERT INTO Interaction (customer_id,employee_id,type,notes)
             VALUES (?,?,?,?)`,
            [customer_id,employee_id,type,notes]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/interactions/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM Interaction WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

app.get('/api/tickets', async (req, res) => {
    try {
        const [rows] = await pool.query(`
            SELECT t.*, c.name AS customer_name, e.name AS assigned_to
            FROM SupportTicket t
            JOIN Customer c ON c.id=t.customer_id
            LEFT JOIN Employee e ON e.id=t.employee_id
        `);
        ok(res, rows);
    } catch (e) { err(res, e); }
});

app.post('/api/tickets', async (req, res) => {
    const { customer_id, employee_id, status, priority } = req.body;
    try {
        const [r] = await pool.query(
            `INSERT INTO SupportTicket (customer_id,employee_id,status,priority)
             VALUES (?,?,?,?)`,
            [customer_id,employee_id,status,priority]
        );
        ok(res, { id: r.insertId });
    } catch (e) { err(res, e); }
});

app.delete('/api/tickets/:id', async (req, res) => {
    try {
        await pool.query('DELETE FROM SupportTicket WHERE id=?',[req.params.id]);
        ok(res, { deleted: req.params.id });
    } catch (e) { err(res, e); }
});

app.listen(PORT, () => {
    console.log(`Server running: http://localhost:${PORT}`);
});
