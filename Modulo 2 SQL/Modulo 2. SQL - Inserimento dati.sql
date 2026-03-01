# Modulo 2. SQL

# Task 3: Inserimento dati nelle tabelle

INSERT INTO Category (CategoryName) VALUES 
('Building Sets'), 
('Dolls & Plush'), 
('Board Games');

INSERT INTO Product (ProductName, CategoryID, RecommendedAge, Brand) VALUES 
('Galactic Starship LEGO', 1, 9, 'LEGO'),
('Talking Teddy Bear', 2, 3, 'HuggyTime'),
('Mystery Mansion Clue', 3, 10, 'Hasbro'),
('Space Explorer LEGO', 1, 9, 'LEGO'),     
('Talking Teddy Bear', 2, 3, 'HuggyTime'), 
('Junior Chess Set', 3, 7, 'SmartKids'),   
('RC Racing Car', 1, 8, 'SpeedMasters');   

INSERT INTO Region (RegionName) VALUES 
('WestEurope'), 
('NorthAmerica'), 
('SouthEurope');

INSERT INTO State (StateName, RegionID) VALUES 
('France', 1), 
('USA', 2), 
('Italy', 3);

INSERT INTO SalesOrderHeader (OrderDate, StateID) VALUES 
('2026-02-26', 2),
('2023-02-19', 3),
('2025-06-15', 1),
('2025-11-20', 2),
('2026-01-10', 3),
('2026-02-20', 1);

INSERT INTO SalesOrderDetail (SalesOrderHeaderID, ProductID, Quantity, UnitPrice, TotalAmount) VALUES 
(1, 1, 1, 89.99, 89.99),
(1, 1, 5, 50.00, 250.00), 
(2, 2, 2, 30.00, 60.00);

INSERT INTO SalesOrderDetail (SalesOrderHeaderID, ProductID, Quantity, UnitPrice, TotalAmount) VALUES
(1, 3, 2, 25.00, 50.00),
(3, 1, 10, 50.00, 500.00),
(3, 3, 2, 20.00, 40.00),
(4, 4, 15, 45.00, 675.00);


