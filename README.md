# 🛒 E-Commerce Product Management System (DBMS Project)

## 📘 Overview
A complete **Database Management System** project developed using **MySQL**.  
It demonstrates key DBMS concepts including **Normalization**, **Relationships**, **Triggers**, and **Views**.

## 👤 Author
**Name:** Ayush Anand  
**Roll No:** 24BCD10053  
**Course:** Database Management Systems (DBMS)  
**Database Used:** MySQL

## ⚙️ How to Run
1. Open MySQL Workbench or CLI.  
2. Run the SQL scripts in this order:
   ```sql
   SOURCE sql/create_tables.sql;
   SOURCE sql/sample_data.sql;
   SOURCE sql/triggers.sql;
   SOURCE sql/views.sql;
   SOURCE sql/queries.sql;
   ```
3. Explore tables, run queries, and analyze reports.

## 🧱 Folder Structure
```
E-Commerce-Product-Management-System/
│
├── sql/
│   ├── create_tables.sql      # DDL
│   ├── sample_data.sql        # DML (insert data)
│   ├── triggers.sql           # Inventory automation
│   ├── views.sql              # Analytical views
│   └── queries.sql            # Test and reporting queries
│
├── docs/
│   ├── ER_Diagram.png         # Entity-Relationship diagram
│   └── Project_Report.docx    # Optional report file
│
└── README.md
```

## 🧠 Database Schema
Tables included:
- Customer
- Category
- Product
- Inventory
- Supplier
- Purchase
- OrderHeader
- OrderItem
- Payment

## 🔍 Features
- Auto stock deduction using triggers.  
- Analytical reports via SQL views.  
- Normalized structure up to **3NF**.  
- Referential integrity with foreign keys.  
- Ready for integration with Python/PHP frontend.

## 📊 Views
- `vw_ProductInventory` — Monitors stock levels and reorder alerts.  
- `vw_DailySales` — Summarizes daily sales and revenue.

## 📜 License
This project is open-source under the MIT License.
