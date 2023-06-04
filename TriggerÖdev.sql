
-------------HAZIRLIK
CREATE TABLE Urun
(
	UrunId INT PRIMARY KEY IDENTITY(1,1),
	UrunAd NVARCHAR(50),
	StokMiktar INT
)
GO
CREATE TABLE Siparis
(
	SiparisId INT PRIMARY KEY IDENTITY(1,1),
	UrunId INT,
	SiparisMiktar INT,
	FOREIGN KEY (UrunId) REFERENCES Urun(UrunId)
)
GO
CREATE TABLE Arsiv
(
	ArsivId INT PRIMARY KEY IDENTITY(1,1),
	UrunId INT,
	UrunAd NVARCHAR(50),
	StokMiktar INT,
	SilindigiTarih DATETIME
)
GO
CREATE TABLE Log
(
	LogId INT PRIMARY KEY IDENTITY(1,1),
	LogDate DATETIME,
	Message NVARCHAR(1024)
)
GO
INSERT INTO Urun VALUES ('Laptop',60),('Telefon',100),('Aksesuar',150)
GO
CREATE TABLE Employeess
(
	EmployeeId INT PRIMARY KEY IDENTITY(1,1),
	Firstname NVARCHAR(50),
	Lastname NVARCHAR(50)
)
GO
INSERT INTO Employeess VALUES ('Ahmet','Bircan'),('Süleyman','Öztürk'),('Ali','Yazýcý'),('Pelin','Özak')
GO

-----Senaryo 1 : Bir urun silindiðinde silindiði an ki tarih ile birlikte arsiv tablosuna kayýt edilsin
CREATE TRIGGER TRG_DeleteItemLogs
ON Urun
AFTER DELETE
AS
	DECLARE @ItemID INT
	DECLARE @ItemName NVARCHAR(50)
	DECLARE @ItemAmount INT
	SELECT @ItemID=UrunID,@ItemName=UrunAd,@ItemAmount=StokMiktar FROM deleted  
	INSERT INTO Arsiv VALUES (@ItemID,@ItemName,@ItemAmount,GETDATE())

DELETE FROM Urun WHERE UrunId = 1

SELECT * FROM Arsiv
-----Senaryo 2 : Sipariþ tablosuna bir sipariþ girilmeden önce ürün tablosuna sipariþ
--adedi kadar stok var mý kontrol edilsin;
--a. stok var ise; sipariþ tablosuna sipariþ girilsin, ürün tablosundan sipariþ
--	adedi kadar stok düþürülsün
--b. stok yok ise; sipariþ tablosuna sipariþ girilmesin. Yeterli stok olmadýðýna 
--	dair log tablosuna kayýt yazýlsýn

CREATE TRIGGER TRG_StokControl
ON Siparis 
INSTEAD OF INSERT 
AS
	DECLARE @itemID INT
	DECLARE @orderAmount INT
	DECLARE @stock INT
	SELECT  @itemID =I.UrunId, @orderAmount = SiparisMiktar, @stock=StokMiktar FROM inserted I JOIN Urun U ON I.UrunId = U.UrunId

IF @stock>=@orderAmount
BEGIN
   		INSERT INTO Siparis VALUES (@itemID,@orderAmount)
        UPDATE Urun SET StokMiktar-=@orderAmount WHERE @itemID=UrunId
END 
ELSE
BEGIN 
        INSERT INTO LOG VALUES(GETDATE(), 'Yetersiz Stok')
		PRINT('Yetersiz Stok!')
END 

INSERT INTO Siparis VALUES (6,150)

------Senaryo 3 : Employees tablosunda bir çalýþan için insert, update veya delete iþlemi gerçekleþirse
--bu iþlem ile ilgili detay bilgiler message pane de gösterilsin
--Örnek Mesajlar :
--INSERT : Mevlüt Tuna isimli çalýþan eklendi
--DELETE : Ahmet Bircan isimli çalýþan silindi
--UPDATE : Mevlüt Tuna isimli çalýþan Mehmet Tunahan olarak güncellendi

ALTER TRIGGER TRG_EmpChangingInfo
ON Employeess 
AFTER INSERT,UPDATE,DELETE
AS
DECLARE @isim NVARCHAR(50)
DECLARE @soyÝsim NVARCHAR(50)
IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
BEGIN 
SELECT @isim=FirstName, @soyÝsim=Lastname FROM Employeess
PRINT ('Yeni personel eklendi. Eklenen personelin Adý: '+@isim +' Soyadý: '+@soyÝsim )
END 
ELSE IF EXISTS (SELECT * FROM deleted)  AND NOT EXISTS (SELECT * FROM inserted)
BEGIN 
SELECT @isim=FirstName, @soyÝsim=Lastname FROM Employeess
PRINT ('Silme iþlemi gerçekleþti. Silinen kiþinin Adý: '+@isim +' Soyadý: '+@soyÝsim )
END 
ELSE IF EXISTS (SELECT * FROM deleted)AND EXISTS (SELECT * FROM inserted)
BEGIN 
 DECLARE @newPersonelName NVARCHAR(50)
 DECLARE @newPersonelSurName NVARCHAR(50)
 SELECT @isim=D.FirstName, @soyÝsim=D.Lastname ,@newPersonelName=I.FirstName,  @newPersonelSurName=I.Lastname FROM deleted D JOIN inserted I ON D.EmployeeId=I.EmployeeId
 PRINT ('Güncelleme iþlemi yapýldý. ' +@isim + ' ' + @soyÝsim + ' ' +'adlý personel'
			+ ' '+@newPersonelName + ' ' +@newPersonelSurName + ' ' + 'adlý personel olarak güncellendi.')
END 

INSERT INTO Employeess VALUES ('Damla','Öztürk')
DELETE FROM Employeess WHERE EmployeeId = 1
UPDATE Employeess SET Firstname = 'Derviþ',Lastname = 'Öztürk' WHERE EmployeeId = 2