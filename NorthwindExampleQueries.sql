--Northwind Example Queries

--Show how many customer have fax number?
SELECT COUNT(Fax )FROM Customers

--Show most cheapest product?
SELECT MIN(UnitPrice)FROM Products

--What is our products avarage price in db?
 SELECT AVG(UnitPrice)FROM Products

--Show how many customers do we have in which country?
SELECT Country,COUNT(CustomerID) 'Customer number'
FROM Customers 
GROUP BY Country

--Show how many customer do we have in which country and which city?
SELECT Country,City, COUNT(CustomerID) 'Customer number'
FROM Customers 
GROUP BY Country,City
Order BY Country, City

--Show categories name and all products which in those categories            
SELECT Categories.CategoryName, Products.ProductName
FROM Categories LEFT JOIN Products ON Categories.CategoryID=Products.CategoryID

--with aliases
SELECT C.CategoryName, P.ProductName
FROM Categories C LEFT JOIN Products P ON C.CategoryID=P.CategoryID

--Show all products and their categories name  
SELECT C.CategoryName, P.ProductName
FROM Categories C JOIN Products P ON C.CategoryID=P.CategoryID

--Show categories which have not any product
SELECT  CategoryName
FROM Categories c LEFT JOIN Products p ON c.CategoryID=p.CategoryID
WHERE p.CategoryID IS NULL

--Show products which have not any categories
SELECT  ProductName
FROM Categories c RIGHT JOIN Products p ON C.CategoryID=P.CategoryID
WHERE c.CategoryID IS NULL

--Show how much was ordered from which category?
SELECT c.CategoryName, SUM(od.Quantity*od.UnitPrice) 'Total Order'
FROM Categories c LEFT JOIN Products p ON c.CategoryID=p.CategoryID
INNER JOIN [Order Details] od ON p.ProductID=od.ProductID
GROUP BY c.CategoryName

--Show all categories and all products
SELECT  c.CategoryName, p.ProductName
FROM Categories c FULL OUTER JOIN Products p ON c.CategoryID=p.CategoryID

--Show categories without product and products without categories
SELECT c.CategoryName, p.ProductName
FROM Categories c FULL OUTER JOIN Products p ON c.CategoryID=p.CategoryID
WHERE p.CategoryID IS NULL 

--Show emplyoees who makes sales, sales quantities
SELECT (E.FirstName +' '+E.LastName)  'Personel', SUM(OD.Quantity) 'Order Quantities'
FROM Employees E INNER JOIN Orders O ON E.EmployeeID=O.EmployeeID 
INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
GROUP BY (E.FirstName+' '+E.LastName)

--Show  emplyoees who makes sales, total sales amount
SELECT (E.FirstName +' '+E.LastName)  'Personel', SUM(OD.Quantity*OD.UnitPrice) 'Total Sales Amount'
FROM Employees E INNER JOIN Orders O ON E.EmployeeID=O.EmployeeID 
INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
GROUP BY (E.FirstName+' '+E.LastName)

--Show ALL employees total sales amount
SELECT (E.FirstName +' '+E.LastName)  'Personel', SUM(OD.Quantity*OD.UnitPrice) 'Total Sales Amount'
FROM Employees E LEFT JOIN Orders O ON E.EmployeeID=O.EmployeeID 
LEFT JOIN [Order Details] OD ON O.OrderID=OD.OrderID
GROUP BY (E.FirstName+' '+E.LastName)

--Show how much ordered which categories
SELECT C.CategoryName, SUM(O.Quantity*O.UnitPrice) 'Total Order Amount'
FROM Categories C LEFT JOIN Products P ON C.CategoryID=P.CategoryID 
INNER JOIN [Order Details]O ON O.ProductID=P.ProductID
GROUP BY c.CategoryName

--Show which customers ordered how much?
SELECT C.CompanyName , SUM(OD.UnitPrice*OD.Quantity)  'Total Order Amount'
FROM Customers C INNER JOIN Orders O ON C.CustomerID=O.CustomerID
INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
GROUP BY C.CompanyName

--Show which customer ordered in which categories?
SELECT C.CompanyName,CA.CategoryName
FROM Customers C INNER JOIN Orders O ON C.CustomerID=O.CustomerID
INNER JOIN [Order Details] OD ON O.OrderID=OD.OrderID
INNER JOIN Products P ON P.ProductID=OD.ProductID
INNER JOIN Categories CA ON CA.CategoryID=P.CategoryID
GROUP BY C.CompanyName, CA.CategoryName


--Show bestseller products supplier
SELECT TOP 1  ProductName, SUM(OD.Quantity) as 'Quantity', S.CompanyName
FROM Products P INNER JOIN [Order Details] OD ON P.ProductID=OD.ProductID 
INNER JOIN Orders O ON O.OrderID=OD.OrderID
LEFT JOIN Suppliers S ON P.SupplierID=S.SupplierID
GROUP BY ProductName, S.CompanyName
ORDER BY Quantity DESC


--How much of which product was sold?
SELECT ProductName, SUM(OD.Quantity) as 'Quantity'
FROM Products P INNER JOIN [Order Details] OD ON P.ProductID=OD.ProductID 
INNER JOIN Orders O ON O.OrderID=OD.OrderID
GROUP BY ProductName
ORDER BY Quantity DESC

--Show stock quantities under 20 products
SELECT ProductName, P.UnitsInStock,S.CompanyName
FROM Products P INNER JOIN Suppliers S ON P.SupplierID=S.SupplierID
WHERE P.UnitsInStock<20
ORDER BY P.UnitsInStock 
