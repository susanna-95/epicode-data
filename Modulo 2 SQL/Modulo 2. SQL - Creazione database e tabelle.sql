# Modulo 2. SQL

# Task 2: Creazione del database
CREATE DATABASE ToysGroup;

# Selezione del database
USE ToysGroup;

# Creazione tabelle

CREATE TABLE Category (
CategoryID INT AUTO_INCREMENT PRIMARY KEY,
CategoryName VARCHAR(100) );

CREATE TABLE Product (
ProductID INT AUTO_INCREMENT PRIMARY KEY,
ProductName VARCHAR(100),
CategoryID INT,
RecommendedAge INT,
Brand VARCHAR(100),
CONSTRAINT FK_Product_CategoryID FOREIGN KEY(CategoryID) REFERENCES Category(CategoryID));

CREATE TABLE Region (
RegionID INT AUTO_INCREMENT PRIMARY KEY,
RegionName VARCHAR(100));

CREATE TABLE State (
StateID INT AUTO_INCREMENT PRIMARY KEY,
StateName VARCHAR(100),
RegionID INT,
CONSTRAINT FK_State_RegionID FOREIGN KEY(RegionID) REFERENCES Region(RegionID));

CREATE TABLE SalesOrderHeader (
SalesOrderHeaderID INT AUTO_INCREMENT PRIMARY KEY,
OrderDate DATE,
StateID INT,
CONSTRAINT FK_SalesOrderHeader_StateID FOREIGN KEY(StateID) REFERENCES State(StateID));

CREATE TABLE SalesOrderDetail (
SalesOrderDetailID INT AUTO_INCREMENT,
SalesOrderHeaderID INT,
ProductID INT,
Quantity INT,
UnitPrice DECIMAL(6,2),
TotalAmount DECIMAL(6,2),
PRIMARY KEY (SalesOrderDetailID,SalesOrderHeaderID),
CONSTRAINT FK_SalesOrderDetail_SalesOrderHeaderID FOREIGN KEY(SalesOrderHeaderID) REFERENCES SalesOrderHeader(SalesOrderHeaderID),
CONSTRAINT FK_SalesOrderDetail_ProductID FOREIGN KEY(ProductID) REFERENCES Product(ProductID)); 