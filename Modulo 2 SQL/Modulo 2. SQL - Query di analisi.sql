# Modulo 2. SQL

#Task 4

# Task 4.1: Dimostrazione che i campi definiti come PK siano univoci. 

# Per verificare che ogni campo definito come Primary Key (PK) sia davvero univoco, 
# si controlla quante volte ciascun valore compare nella tabella corrispondente,
# andando a raggruppare i valori della PK e eseguendo un conteggio degli stessi.
# Se la query restituisce 0 righe, allora è confermato che le PK siano univoche. 
# Se restituisce una o più righe, significa che alcuni valori si ripetono e quindi si perde l'unviocità caratteristica della PK

# es. la PK di Categoria è 'CategoryID', quindi si conta il numero di volte in cui compare nella tabella Categoria. 
# La query restituisce 0 righe, allora è confermato che la PK è univoca.

# Categoria
SELECT CategoryID,
COUNT(CategoryID) AS CountCategoryID
FROM Category
GROUP BY CategoryID HAVING COUNT(CategoryID)>1;

# Product
SELECT ProductID, COUNT(ProductID) AS CountProductID
FROM Product
GROUP BY ProductID HAVING COUNT(ProductID)>1;

# Region
SELECT RegionID, COUNT(RegionID) AS CountRegionID
FROM Region
GROUP BY RegionID HAVING COUNT(RegionID)>1;

# State
SELECT StateID, COUNT(StateID) AS CountStateID 
FROM State
GROUP BY StateID HAVING COUNT(StateID)>1;

# SalesOrderHeader
SELECT SalesOrderHeaderID, COUNT(SalesOrderHeaderID) AS CountSalesOrderHeaderID
FROM SalesOrderHeader
GROUP BY SalesOrderHeaderID HAVING COUNT(SalesOrderHeaderID)>1;

# SalesOrderDetail
SELECT SalesOrderDetailID, COUNT(SalesOrderDetailID) AS CountSalesOrderDetailID
FROM SalesOrderDetail
GROUP BY SalesOrderDetailID HAVING COUNT(SalesOrderDetailID)>1;

# Task 4.2: Esporre l’elenco delle transazioni indicando nel result set 
			# il codice documento, la data, il nome del prodotto, la categoria del prodotto, il nome dello stato, 
			# il nome della regione di vendita e un campo booleano valorizzato in base alla condizione che siano passati 
			# più di 180 giorni dalla data vendita o meno (>180 -> True, <= 180 -> False)

SELECT
SalesOrderHeader.SalesOrderHeaderID AS OrderHeaderID,
OrderDate,
Product.ProductName AS ProductName,
Category.CategoryName AS CategoryName,
State.StateName AS State,
Region.RegionName AS Region,
DATEDIFF(CURDATE(),OrderDate) >180 AS OlderThan180Days
FROM SalesOrderHeader
INNER JOIN SalesOrderDetail ON SalesOrderHeader.SalesOrderHeaderID = SalesOrderDetail.SalesOrderHeaderID
INNER JOIN Product ON SalesOrderDetail.ProductID = Product.ProductID
INNER JOIN Category ON Product.CategoryID = Category.CategoryID
INNER JOIN State ON SalesOrderHeader.StateID = State.StateID
INNER JOIN Region ON State.RegionID = Region.RegionID


# Task 4.3: Esporre l’elenco dei prodotti che hanno venduto, in totale, una quantità maggiore della media delle vendite 
			# realizzate nell’ultimo anno censito. (ogni valore della condizione deve risultare da una query e non deve essere inserito a mano)
			# Nel result set devono comparire solo il codice prodotto e il totale venduto

SELECT
ProductID,
SUM(Quantity) AS TotalQuantitySold
FROM SalesOrderDetail
INNER JOIN SalesOrderHeader ON SalesOrderHeader.SalesOrderHeaderID = SalesOrderDetail.SalesOrderHeaderID
WHERE YEAR(SalesOrderHeader.OrderDate) = (
			SELECT MAX(YEAR(OrderDate)) 
			FROM SalesOrderHeader)
GROUP BY ProductID 
	HAVING SUM(Quantity) > (
		SELECT AVG(Quantity) 
        FROM SalesOrderDetail 
		INNER JOIN SalesOrderHeader ON SalesOrderHeader.SalesOrderHeaderID = SalesOrderDetail.SalesOrderHeaderID
        WHERE YEAR(SalesOrderHeader.OrderDate) = (
			SELECT MAX(YEAR(OrderDate)) 
			FROM SalesOrderHeader))
ORDER BY TotalQuantitySold DESC 


# Task 4.4: Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno

SELECT
SalesOrderDetail.ProductID,
YEAR(OrderDate) AS Year,
SUM(TotalAmount) AS TotalRevenue
FROM SalesOrderDetail
INNER JOIN SalesOrderHeader ON SalesOrderHeader.SalesOrderHeaderID = SalesOrderDetail.SalesOrderHeaderID
GROUP BY ProductID, YEAR(OrderDate)

# Task 4.5: Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente.

SELECT
State.StateName AS State,
YEAR(OrderDate) AS OrderYear,
SUM(SalesOrderDetail.TotalAmount) AS TotalRevenue
FROM SalesOrderDetail
INNER JOIN SalesOrderHeader ON SalesOrderHeader.SalesOrderHeaderID = SalesOrderDetail.SalesOrderHeaderID
LEFT JOIN  State ON SalesOrderHeader.StateID = State.StateID
GROUP BY State.StateName, OrderDate
ORDER BY YEAR(OrderDate) DESC, TotalRevenue DESC 

# Task 4.6: Indicare la categoria di articoli maggiormente richiesta dal mercato

SELECT
Category.CategoryID,
SUM(SalesOrderDetail.Quantity) AS MostRequestedCategory
FROM SalesOrderDetail
INNER JOIN Product ON SalesOrderDetail.ProductID = Product.ProductID
LEFT JOIN  Category ON Product.CategoryID = Category.CategoryID
GROUP BY CategoryID
ORDER BY MostRequestedCategory DESC
# volendo ricavare solo la più richiesta, quindi la prima: LIMIT 1


# Task 4.7: Indicare i prodotti invenduti con due approcci

	# Approccio 1
    
SELECT
Product.ProductID 
FROM Product
LEFT JOIN SalesOrderDetail ON SalesOrderDetail.ProductID = Product.ProductID
WHERE SalesOrderDetail.ProductID IS NULL 
ORDER BY Product.ProductID 

	# Approccio 2
    
SELECT ProductID
FROM Product
WHERE ProductID NOT IN (
    SELECT DISTINCT ProductID FROM SalesOrderDetail
)
ORDER BY ProductID ;

# Task 4.8: Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” delle informazioni utili 
			# (codice prodotto, nome prodotto, nome categoria)

CREATE VIEW ListProductCategory AS (
SELECT
Product.ProductID, 
Product.ProductName,
Category.CategoryName
FROM Product
LEFT JOIN Category ON Product.CategoryID = Category.CategoryID);

SELECT * FROM toysgroup.listproductcategory;

# Task 4.9:	Creare una vista per le informazioni geograficheù

CREATE VIEW Geography AS (
SELECT
State.StateID AS StateID,
Region.RegionID AS RegionID,
StateName AS State,
Region.RegionName AS Region
FROM State
INNER JOIN Region ON State.RegionID = Region.RegionID); 

SELECT * FROM toysgroup.geography;

