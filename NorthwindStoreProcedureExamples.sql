--Store Procedure Examples with Nortwind db

--Create SP for show all customers
CREATE PROC SP_AllCustomers
AS
BEGIN
SELECT *
FROM Customers

END

EXEC SP_AllCustomers


----Create SP for saving Shippers according to parameters
CREATE PROC SP_SaveShippers
@CompanyName NVARCHAR(40),
@Phone NVARCHAR(24)
AS
BEGIN
INSERT INTO Shippers (CompanyName,Phone) VALUES (@CompanyName,@Phone)
END 

EXEC SP_SaveShippers DAMLA,123456789


--Update SP_SaveShippers 
ALTER PROC SP_UpdateShippers
@ShipperID INT,
@CompanyName NVARCHAR(40),
@Phone NVARCHAR(24)
AS
BEGIN
UPDATE Shippers SET CompanyName=@CompanyName, Phone=@Phone WHERE ShipperID=@ShipperID
END 

EXEC SP_UpdateShippers 5,'xyz','12121212'

--Delete Shippers with parameters from users
ALTER PROC SP_DeleteShippers 
@ShipperID INT
AS
BEGIN
DELETE FROM Shippers  WHERE ShipperID=@ShipperID
END 

EXEC SP_DeleteShippers 5

--Save Shippers with parameters from users but if the phone number already exist dont save.

CREATE PROC SP_ControlPhoneNumberAndSaveShippers
@CompanyName NVARCHAR(40),
@ShipperPhoneNumber  NVARCHAR(24)
AS
BEGIN
  IF EXISTS (SELECT Phone from Shippers WHERE Phone=@ShipperPhoneNumber)
      BEGIN 
       PRINT 'This phone number already exist, please give new number!'
      END
  ELSE 
      BEGIN 
	     INSERT INTO Shippers (CompanyName,Phone) VALUES (@CompanyName,@ShipperPhoneNumber)
      END
END
 
 EXEC SP_ControlPhoneNumberAndSaveShippers 'X transporter Company', '01212313'

 --Show all products ID, Name and CategoryID belongs to CategoryID which coming from users
 CREATE PROC SP_AllProductsBelongsCatID
 @CatID INT
 AS
 BEGIN
  SELECT C.CategoryName, P.ProductName, P.ProductID FROM Products P INNER JOIN Categories C ON C.CategoryID=P.CategoryID
  WHERE C.CategoryID=@CatID
 END 

 EXEC SP_AllProductsBelongsCatID 2

 --Take CustomerID and show Customers Order (Product name and Total Quantity) 
CREATE PROC SP_OrderDetail
 @CustomerID NCHAR(5)
 AS
 BEGIN
 SELECT P.ProductName,SUM(OD.Quantity) AS TotalSale
 FROM Products P INNER JOIN [Order Details] OD ON P.ProductID=OD.ProductID
 INNER JOIN Orders O ON O.OrderID =OD.OrderID
 WHERE O.CustomerID = @CustomerID
 GROUP BY P.ProductName
 END
 EXEC SP_OrderDetail  'DRACD'

 --Show all orders in between dates coming from users 
 CREATE PROC SP_BetweenDates
 @DateBeginnig DATETIME,
 @DateEnding DATETIME 
 AS
 BEGIN 
 SELECT *
 FROM Orders  WHERE  OrderDate between @DateBeginnig and @DateEnding
 END 
 EXEC SP_BetweenDates  @DateBeginnig='01.01.1997' ,@DateEnding='01.01.1998'

--Show ProductName, UnitPrice,Quantity and Discounted price According to OrderID coming from users 
ALTER PROC SP_OrderDetailOrderID
@OrderID INT
AS
BEGIN 
SELECT P.ProductName 'Name' ,P.UnitPrice 'Unit Price', OD.Quantity 'Sale Amount', OD.Discount 'Discount', LastPrice=CONVERT(MONEY,(P.UnitPrice-(P.UnitPrice* OD.Discount))*OD.Quantity)
FROM Products P INNER JOIN [Order Details] OD ON P.ProductID=OD.ProductID INNER JOIN Orders O ON OD.OrderID=O.OrderID  WHERE O.OrderID=@OrderID
END 
 EXEC SP_OrderDetailOrderID 10410

 --Sort the product from the most expensive by the number entered by the user, default number is 10
 CREATE PROC SP_GetExpensiveItems
@Number INT = 10
AS
BEGIN
	SET ROWCOUNT @Number     --Row count (satýr sayýsý)
	SELECT ProductName AS MostExpensiveItems, UnitPrice FROM Products ORDER BY UnitPrice DESC 
END

EXEC SP_GetExpensiveItems 5

--Show Products name, discounted rate and order date between start and end date entered by user 

CREATE PROC SP_GetProductInfoBetweenDate
@BeginnigDate  DATETIME,
@EndingDate DATETIME 
AS
BEGIN 
SELECT P.ProductName, P.Discontinued, O.OrderDate
FROM Products P INNER JOIN [Order Details] OD ON OD.ProductID=P.ProductID  INNER JOIN Orders O ON O.OrderID=OD.OrderID  WHERE O.OrderDate Between @BeginnigDate and @EndingDate
END 

EXEC SP_GetProductInfoBetweenDate  '01.01.1997' , '01.05.1997'