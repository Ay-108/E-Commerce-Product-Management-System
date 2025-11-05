--Create_Table.sql
CREATE DATABASE IF NOT EXISTS ecommerce;
USE ecommerce;

CREATE TABLE IF NOT EXISTS Customer (
  CustomerID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL,
  Email VARCHAR(150) UNIQUE,
  Phone VARCHAR(20),
  Address VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS Category (
  CategoryID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(100) NOT NULL UNIQUE,
  Description TEXT
);

CREATE TABLE IF NOT EXISTS Product (
  ProductID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(150) NOT NULL,
  CategoryID INT NOT NULL,
  SKU VARCHAR(50) NOT NULL UNIQUE,
  Description TEXT,
  Price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE IF NOT EXISTS Inventory (
  InventoryID INT AUTO_INCREMENT PRIMARY KEY,
  ProductID INT NOT NULL UNIQUE,
  Quantity INT DEFAULT 0,
  ReorderLevel INT DEFAULT 10,
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Supplier (
  SupplierID INT AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(150) NOT NULL,
  Contact VARCHAR(100),
  Email VARCHAR(150)
);

CREATE TABLE IF NOT EXISTS Purchase (
  PurchaseID INT AUTO_INCREMENT PRIMARY KEY,
  SupplierID INT NOT NULL,
  ProductID INT NOT NULL,
  PurchaseDate DATE NOT NULL,
  Quantity INT NOT NULL,
  UnitCost DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (SupplierID) REFERENCES Supplier(SupplierID),
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE IF NOT EXISTS OrderHeader (
  OrderID INT AUTO_INCREMENT PRIMARY KEY,
  CustomerID INT NOT NULL,
  OrderDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  Status ENUM('Placed','Processing','Shipped','Delivered','Cancelled') DEFAULT 'Placed',
  TotalAmount DECIMAL(12,2) DEFAULT 0,
  FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE IF NOT EXISTS OrderItem (
  OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT NOT NULL,
  ProductID INT NOT NULL,
  Quantity INT NOT NULL,
  UnitPrice DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (OrderID) REFERENCES OrderHeader(OrderID) ON DELETE CASCADE,
  FOREIGN KEY (ProductID) REFERENCES Product(ProductID)
);

CREATE TABLE IF NOT EXISTS Payment (
  PaymentID INT AUTO_INCREMENT PRIMARY KEY,
  OrderID INT UNIQUE,
  PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  Amount DECIMAL(12,2) NOT NULL,
  Method ENUM('Card','UPI','NetBanking','COD') NOT NULL,
  Status ENUM('Pending','Completed','Failed') DEFAULT 'Pending',
  FOREIGN KEY (OrderID) REFERENCES OrderHeader(OrderID) ON DELETE CASCADE
);

--Queries.sql
USE ecommerce;

-- Display all customers
SELECT * FROM Customer;

-- List all products with stock levels
SELECT * FROM vw_ProductInventory;

-- Show daily sales summary
SELECT * FROM vw_DailySales ORDER BY SaleDate DESC;

-- Find products below reorder level
SELECT ProductName, Quantity, ReorderLevel FROM vw_ProductInventory WHERE StockStatus='REORDER';

-- Top selling products
SELECT p.Name, SUM(oi.Quantity) AS TotalSold
FROM OrderItem oi
JOIN Product p ON oi.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY TotalSold DESC;


--Sample_data.sql
USE ecommerce;

INSERT INTO Category (Name, Description) VALUES
('Electronics','Gadgets and devices'),
('Apparel','Clothing and fashion'),
('Home','Home and kitchen');

INSERT INTO Product (Name, CategoryID, SKU, Description, Price) VALUES
('Wireless Mouse',1,'SKU-MOUSE-001','Optical wireless mouse',299.00),
('Mechanical Keyboard',1,'SKU-KEY-001','Compact keyboard',2499.00),
('Plain T-Shirt',2,'SKU-TS-001','Cotton Tee',499.00),
('Ceramic Mug',3,'SKU-MUG-001','350ml mug',199.00),
('LED Desk Lamp',3,'SKU-LAMP-001','Adjustable lamp',1299.00);

INSERT INTO Inventory (ProductID,Quantity,ReorderLevel) VALUES
(1,150,20),(2,80,10),(3,200,30),(4,120,15),(5,60,10);

INSERT INTO Customer (Name,Email,Phone,Address) VALUES
('Arjun Kumar','arjun.k@example.com','9876543210','Mumbai'),
('Priya Singh','priya.s@example.com','9123456780','Delhi'),
('Rohan Mehta','rohan.m@example.com','9988776655','Bengaluru');

INSERT INTO Supplier (Name,Contact,Email) VALUES
('Global Supplies','Raj','raj@supplier.com'),
('Home Goods Co','Sita','sita@homegoods.com');

INSERT INTO Purchase (SupplierID,ProductID,PurchaseDate,Quantity,UnitCost) VALUES
(1,1,'2025-09-01',200,180.00),
(1,2,'2025-09-02',100,1200.00),
(2,4,'2025-09-05',150,90.00);

INSERT INTO OrderHeader (CustomerID, OrderDate, Status, TotalAmount) VALUES
(1,'2025-10-01 10:15:00','Placed',798.00),
(2,'2025-10-02 14:30:00','Placed',1299.00);

INSERT INTO OrderItem (OrderID,ProductID,Quantity,UnitPrice) VALUES
(1,1,1,299.00),(1,3,1,499.00),(2,5,1,1299.00);

INSERT INTO Payment (OrderID,PaymentDate,Amount,Method,Status) VALUES
(1,'2025-10-01 10:20:00',798.00,'Card','Completed'),
(2,'2025-10-02 14:35:00',1299.00,'UPI','Completed');


--Triggers.sql
USE ecommerce;

DELIMITER $$
CREATE TRIGGER trg_orderitem_before_insert
BEFORE INSERT ON OrderItem
FOR EACH ROW
BEGIN
  DECLARE available INT;
  SELECT Quantity INTO available FROM Inventory WHERE ProductID = NEW.ProductID FOR UPDATE;
  IF available IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Inventory record missing';
  END IF;
  IF available < NEW.Quantity THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT='Insufficient stock';
  END IF;
END$$

CREATE TRIGGER trg_orderitem_after_insert
AFTER INSERT ON OrderItem
FOR EACH ROW
BEGIN
  UPDATE Inventory SET Quantity = Quantity - NEW.Quantity WHERE ProductID = NEW.ProductID;
END$$
DELIMITER ;


--Views.sql
USE ecommerce;

CREATE OR REPLACE VIEW vw_ProductInventory AS
SELECT p.ProductID, p.Name AS ProductName, p.SKU, p.Price, i.Quantity, i.ReorderLevel,
       CASE WHEN i.Quantity <= i.ReorderLevel THEN 'REORDER' ELSE 'OK' END AS StockStatus
FROM Product p JOIN Inventory i ON p.ProductID = i.ProductID;

CREATE OR REPLACE VIEW vw_DailySales AS
SELECT DATE(oh.OrderDate) AS SaleDate,
       SUM(oi.Quantity * oi.UnitPrice) AS DayRevenue,
       SUM(oi.Quantity) AS UnitsSold
FROM OrderHeader oh
JOIN OrderItem oi ON oh.OrderID = oi.OrderID
WHERE oh.Status <> 'Cancelled'
GROUP BY DATE(oh.OrderDate);
