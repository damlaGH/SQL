
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
INSERT INTO Employeess VALUES ('Ahmet','Bircan'),('S�leyman','�zt�rk'),('Ali','Yaz�c�'),('Pelin','�zak')
GO

-----Senaryo 1 : Bir urun silindi�inde silindi�i an ki tarih ile birlikte arsiv tablosuna kay�t edilsin
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
-----Senaryo 2 : Sipari� tablosuna bir sipari� girilmeden �nce �r�n tablosuna sipari�
--adedi kadar stok var m� kontrol edilsin;
--a. stok var ise; sipari� tablosuna sipari� girilsin, �r�n tablosundan sipari�
--	adedi kadar stok d���r�ls�n
--b. stok yok ise; sipari� tablosuna sipari� girilmesin. Yeterli stok olmad���na 
--	dair log tablosuna kay�t yaz�ls�n

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

------Senaryo 3 : Employees tablosunda bir �al��an i�in insert, update veya delete i�lemi ger�ekle�irse
--bu i�lem ile ilgili detay bilgiler message pane de g�sterilsin
--�rnek Mesajlar :
--INSERT : Mevl�t Tuna isimli �al��an eklendi
--DELETE : Ahmet Bircan isimli �al��an silindi
--UPDATE : Mevl�t Tuna isimli �al��an Mehmet Tunahan olarak g�ncellendi

ALTER TRIGGER TRG_EmpChangingInfo
ON Employeess 
AFTER INSERT,UPDATE,DELETE
AS
DECLARE @isim NVARCHAR(50)
DECLARE @soy�sim NVARCHAR(50)
IF EXISTS (SELECT * FROM inserted) AND NOT EXISTS (SELECT * FROM deleted)
BEGIN 
SELECT @isim=FirstName, @soy�sim=Lastname FROM Employeess
PRINT ('Yeni personel eklendi. Eklenen personelin Ad�: '+@isim +' Soyad�: '+@soy�sim )
END 
ELSE IF EXISTS (SELECT * FROM deleted)  AND NOT EXISTS (SELECT * FROM inserted)
BEGIN 
SELECT @isim=FirstName, @soy�sim=Lastname FROM Employeess
PRINT ('Silme i�lemi ger�ekle�ti. Silinen ki�inin Ad�: '+@isim +' Soyad�: '+@soy�sim )
END 
ELSE IF EXISTS (SELECT * FROM deleted)AND EXISTS (SELECT * FROM inserted)
BEGIN 
 DECLARE @newPersonelName NVARCHAR(50)
 DECLARE @newPersonelSurName NVARCHAR(50)
 SELECT @isim=D.FirstName, @soy�sim=D.Lastname ,@newPersonelName=I.FirstName,  @newPersonelSurName=I.Lastname FROM deleted D JOIN inserted I ON D.EmployeeId=I.EmployeeId
 PRINT ('G�ncelleme i�lemi yap�ld�. ' +@isim + ' ' + @soy�sim + ' ' +'adl� personel'
			+ ' '+@newPersonelName + ' ' +@newPersonelSurName + ' ' + 'adl� personel olarak g�ncellendi.')
END 

INSERT INTO Employeess VALUES ('Damla','�zt�rk')
DELETE FROM Employeess WHERE EmployeeId = 1
UPDATE Employeess SET Firstname = 'Dervi�',Lastname = '�zt�rk' WHERE EmployeeId = 2