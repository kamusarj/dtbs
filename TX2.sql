USE tempdb;
GO
DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'QLXUAT')
BEGIN
    SET @SQL = N'USE [QLXUAT]
				 ALTER DATABASE QLXUAT SET SINGLE_USER WITH ROLLBACK IMMEDIATE
                 USE [tempdb]
				 DROP DATABASE QLXUAT'
    EXEC (@SQL)
END
USE [master]
GO
--Tạo cơ sở dữ liệu
CREATE DATABASE QLXUAT
ON PRIMARY (NAME = 'QLXUAT', FILENAME = 'C:\Users\01232\OneDrive\Máy tính\HTCSDL\QLXUAT.mdf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)
LOG ON (NAME = 'QLXUAT_log', FILENAME = 'C:\Users\01232\OneDrive\Máy tính\HTCSDL\QLXUAT_log.ldf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)

GO
USE [QLXUAT]
GO

CREATE TABLE CongTy ( MaCT NCHAR(10) NOT NULL CONSTRAINT PK_CongTy PRIMARY KEY, 
					   TenCT NVARCHAR(30),
					   DiaChi NVARCHAR(20))

CREATE TABLE SanPham ( MaSanPham NCHAR(10) NOT NULL CONSTRAINT PK_SanPham PRIMARY KEY, 
					   TenSanPham NVARCHAR(30),
					   Mau NVARCHAR(15),
					   SoLuong INT,
					   GiaBan MONEY)

CREATE TABLE CungUng ( MaCT NCHAR(10) NOT NULL ,
					   MaSanPham NCHAR(10) NOT NULL ,
					   PRIMARY KEY( MaCT,MaSanPham),
					   SoLuongCungUng INT,
					   NgayCungUng DATE,
					   CONSTRAINT FK_CungUng_SanPham FOREIGN KEY(MaSanPham) REFERENCES SanPham(MaSanPham),
					   CONSTRAINT FK_CungUng_CongTy FOREIGN KEY(MaCT) REFERENCES CongTy(MaCT))

INSERT INTO CongTy VALUES (N'CT05',N'Sanyo',N'Hà Nội'),
						  (N'CT06',N'LG',N'Hải Phòng'),
						  (N'CT07',N'TCL',N'Hà Nam'),
						  (N'CT08',N'Foxcom',N'Bắc Giang')

INSERT INTO SanPham VALUES (N'SP01',N'Máy giặt',N'Trắng',1500,8000000),
						   (N'SP02',N'Tủ lạnh',N'Xanh',2800,5000000),
						   (N'SP03',N'Điều hoà',N'Trắng',830,9000000),
						   (N'SP04',N'Máy sấy',N'Nâu',920,18000000)

INSERT INTO CungUng VALUES (N'CT05',N'SP04',5,'12/2/2023'),
						   (N'CT05',N'SP03',15,'12/2/2020'),
						   (N'CT08',N'SP03',20,'2/9/2023'),
						   (N'CT07',N'SP03',100,'2/9/2022'),
						   (N'CT07',N'SP01',20,'2/9/2021')

SELECT * FROM CongTy
SELECT * FROM SanPham
SELECT * FROM CungUng

UPDATE CongTy
SET DiaChi = N'Thái Nguyên'
Where DiaChi = N'Hà Nam'
SELECT * FROM CongTy

--a. Lấy ra từ cơ sở dữ liệu tên các công ty có địa chỉ bắt đầu bằng từ “Hà”.
SELECT TenCT AS N'Tên công ty' from CongTy
WHERE DiaChi LIKE N'%Hà%'


--b. Lấy ra tên các công ty cung ứng sản phẩm năm 2022 với số lượng dưới 200
INSERT INTO CungUng VALUES (N'CT05',N'SP01',5,'12/2/2022')
SELECT CongTy.TenCT
FROM CungUng 
JOIN CongTy ON CongTy.MaCT = CungUng.MaCT
WHERE YEAR(CungUng.NgayCungUng) = 2022 AND CungUng.SoLuongCungUng < 200

--c. Lấy ra tên công ty, tên sản phẩm đã cung ứng sau năm 2021.
SELECT CongTy.TenCT AS N'Tên công ty', SanPham.TenSanPham AS N'Tên sản phẩm'
FROM CungUng
JOIN CongTy ON CungUng.MaCT = CongTy.MaCT
JOIN SanPham ON CungUng.MaSanPham = SanPham.MaSanPham
WHERE YEAR(CungUng.NgayCungUng) > 2021

--d. Lấy ra mã công ty và số sản phẩm cung ứng sản phẩm.
SELECT CungUng.MaCT, SUM(CungUng.SoLuongCungUng) AS N'Số sản phẩm cung ứng'
FROM CungUng 
GROUP BY CungUng.MaCT

--e. Lấy ra mã và tên các sản phẩm đã cung ứng 3 lần.
SELECT SanPham.MaSanPham AS N'Mã sản phẩm', SanPham.TenSanPham AS N'Tên sản phẩm'
FROM CungUng
JOIN SanPham ON CungUng.MaSanPham = SanPham.MaSanPham
GROUP BY SanPham.MaSanPham,SanPham.TenSanPham  
HAVING COUNT(CungUng.MaSanPham) = 3

--f. Lấy ra tên, địa chỉ công ty chưa cung ứng sản phẩm nào.
SELECT CongTy.TenCT AS N'Tên công ty', CongTy.DiaChi AS N'Địa chỉ'
FROM CongTy
LEFT JOIN CungUng ON CongTy.MaCT = CungUng.MaCT
WHERE CungUng.MaCT IS NULL