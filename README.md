# CRM Database Project
# CRM Management System

## Overview

This project is a full-stack Customer Relationship Management (CRM) system developed using Node.js, Express, MySQL, and a modern frontend interface. It is designed to manage customer data, leads, opportunities, sales orders, interactions, and support tickets in an organized and efficient manner.

The system demonstrates key database concepts such as normalization, foreign key relationships, views, triggers, and role-based access control using GRANT and REVOKE.

---

## Features

### Core Functionalities

* Customer management with interaction tracking
* Lead and opportunity management
* Sales order and product handling
* Support ticket system
* Payment tracking

### Database Features

* Well-structured relational schema
* Foreign key constraints for data integrity
* Views for simplified and meaningful data representation
* Triggers for automation and consistency
* Role-based access control using GRANT and REVOKE

### Frontend

* Clean dashboard interface
* Tab-based navigation for different modules
* Data display directly from backend APIs
* Read-only mode for demonstration purposes

---

## Tech Stack

### Backend

* Node.js
* Express.js
* MySQL (mysql2)

### Frontend

* HTML
* Tailwind CSS
* JavaScript (Vanilla)

---

## Database Design

The system includes the following main tables:

* Customer
* Employee
* Leads
* Opportunity
* Product
* SalesOrder
* SalesOrderItem
* Payment
* Interaction
* SupportTicket

### Advanced Components

#### Views

Views are used to simplify complex joins and provide meaningful data to the frontend.

Example:

* vw_interaction_details: Combines customer, employee, and interaction data

#### Triggers

Triggers automate important updates.

Examples:

* Automatically update customer's last interaction timestamp
* Automatically calculate order totals
* Update order status based on payment completion

#### Access Control

* Sales users can manage customers, leads, and opportunities
* Support users can manage tickets and view customer data

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repo-url>
cd crm-project
```

### 2. Setup Database

* Open MySQL
* Run the provided SQL file:

```bash
mysql -u root -p < crm_full.sql
```

This will:

* Create the database
* Create all tables
* Insert sample data
* Add views, triggers, and users

---

### 3. Configure Backend

Update database credentials in `server.js`:

```js
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: 'your_password',
    database: 'crm_dtu'
});
```

---

### 4. Run Server

```bash
node server.js
```

Server will start at:

```
http://localhost:3000
```

---

### 5. Open Frontend

Open the `index.html` file in your browser.

---

## API Endpoints

| Module        | Endpoint           |
| ------------- | ------------------ |
| Customers     | /api/customers     |
| Employees     | /api/employees     |
| Leads         | /api/leads         |
| Opportunities | /api/opportunities |
| Products      | /api/products      |
| Sales Orders  | /api/salesorders   |
| Interactions  | /api/interactions  |
| Tickets       | /api/tickets       |

---

## Project Highlights

* Demonstrates strong understanding of DBMS concepts
* Clean separation between frontend, backend, and database
* Real-world CRM structure and workflows
* Use of views and triggers to reduce application complexity
* Scalable and modular design

---

## Future Enhancements

* Add authentication and user login system
* Implement edit and update functionality
* Add search and filtering features
* Integrate dashboard analytics and charts
* Deploy using cloud services

---

## Conclusion

This project showcases a complete CRM system integrating frontend, backend, and database layers. It emphasizes practical implementation of database concepts along with a usable interface, making it suitable for academic submission and portfolio demonstration.
