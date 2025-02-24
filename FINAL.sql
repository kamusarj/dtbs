--ĐỀ 1
USE tempdb;
GO
DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'QLKH')
BEGIN
    SET @SQL = N'USE [QLKH]
				 ALTER DATABASE QLKH SET SINGLE_USER WITH ROLLBACK IMMEDIATE
                 USE [tempdb]
				 DROP DATABASE QLKH'
    EXEC (@SQL)
END
USE [master]
GO
--Tạo cơ sở dữ liệu
CREATE DATABASE QLKH
ON PRIMARY (NAME = 'QLKH', FILENAME = 'D:\QLKH.mdf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)
LOG ON (NAME = 'QLKH_log', FILENAME = 'D:\QLKH_log.ldf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)

GO
USE [QLKH]
GO

--Tạo cấu trúc bảng và các ràng buộc
CREATE TABLE KH ( MaKH NCHAR(10) NOT NULL CONSTRAINT PK_KHACHHANG PRIMARY KEY,
						 Ho NVARCHAR(10),
						 Ten NVARCHAR(20),
						 DiaChi NVARCHAR(20))

CREATE TABLE HANG ( MaH NCHAR(10) NOT NULL CONSTRAINT PK_HANG PRIMARY KEY,
					TenH NVARCHAR(20),
					DonGia MONEY)

CREATE TABLE DH ( SoDH NCHAR(10) NOT NULL CONSTRAINT PK_DONHANG PRIMARY KEY,
				  Ngay DATE,
				  MaKH NCHAR(10) CONSTRAINT FK_DH_KH FOREIGN KEY(MaKH) REFERENCES KH(MaKH))

CREATE TABLE CTDH ( SoDH NCHAR(10) NOT NULL,
					MaH NCHAR(10) NOT NULL,
					PRIMARY KEY(SoDH,MaH),
					SL INT,
					CONSTRAINT FK_CTDH_DH FOREIGN KEY(SoDH) REFERENCES DH(SoDH),
					CONSTRAINT FK_CTDH_HANG FOREIGN KEY(MaH) REFERENCES HANG(MaH))

INSERT INTO KH VALUES (N'K01',N'Bùi',N'Hoàng Linh',N'Hà Giang'),
                      (N'K02',N'Bùi',N'Hoàng Long',N'Hà Giang'),
					  (N'K03',N'Hoàng',N'Tuấn Anh',N'Thái Bình'),
					  (N'K04',N'Nguyễn',N'Thành Lân',N'Thái Bình'),
					  (N'K05',N'Trần',N'Văn Thắng',N'Hà Nội')

INSERT INTO HANG VALUES (N'H01',N'Điện thoại',10000000),
						(N'H02',N'Máy tính bảng',15000000),
						(N'H03',N'Máy tính xách tay',25000000),
						(N'H04',N'Đồng hồ thông minh',5000000),
						(N'H05',N'Màn hình',5000000)

INSERT INTO DH VALUES (N'D01','4/7/2020',N'K01'),
					  (N'D02','2/2/2022',N'K01'),
					  (N'D03','2/4/2025',N'K03'),
					  (N'D04','2/15/2025',N'K04'),
					  (N'D05','12/2/2023',N'K05'),
					  (N'D06','7/9/2025',N'K05')

INSERT INTO CTDH VALUES (N'D01',N'H01',10),
						(N'D01',N'H02',5),
						(N'D01',N'H03',4),
						(N'D01',N'H04',2),
						(N'D02',N'H04',4),
						(N'D03',N'H05',7),
						(N'D04',N'H03',15),
						(N'D05',N'H02',3),
						(N'D06',N'H03',8),
						(N'D06',N'H01',20)

SELECT * FROM KH
SELECT * FROM HANG
SELECT * FROM DH
SELECT * FROM CTDH

--a. Lấy ra mã hàng và số lượng hàng đã được đặt trong đơn hàng có mã số là D30.
INSERT INTO DH VALUES (N'D30','12/9/2025',N'K01')
INSERT INTO CTDH VALUES (N'D30',N'H01',10),
						(N'D30',N'H02',5),
						(N'D30',N'H03',2)
SELECT MaH, SL
FROM CTDH
WHERE SoDH = N'D30'

--b. Lấy ra tên và giá các mặt hàng mà khách có mã là K24 đã đặt với số lượng là 500.
INSERT INTO KH VALUES (N'K24',N'Bùi',N'Hoàng Linh',N'Hà Giang')
INSERT INTO DH VALUES (N'D07','4/7/2020',N'K24')
INSERT INTO CTDH VALUES (N'D07',N'H01',500),
						(N'D07',N'H03',500),
						(N'D07',N'H04',500),
						(N'D07',N'H05',500)

SELECT HANG.TenH, HANG.DonGia
FROM CTDH 
JOIN HANG ON HANG.MaH = CTDH.MaH
JOIN DH ON DH.SoDH = CTDH.SoDH
WHERE DH.MaKH = N'K24' AND CTDH.SL = 500

--c. Lấy ra tên các khách hàng bắt đầu bằng chữ ‘Ng’ đã đặt các mặt hàng trước 1/5/2024.
INSERT INTO KH VALUES (N'K06',N'Đàm',N'Nguyên',N'Hà Giang')
INSERT INTO DH VALUES (N'D08','4/7/2020',N'K06')
INSERT INTO CTDH VALUES (N'D08',N'H01',500),
						(N'D08',N'H03',500),
						(N'D08',N'H04',500)
SELECT KH.Ten 
FROM DH
JOIN KH ON DH.MaKH = KH.MaKH
WHERE KH.Ten LIKE N'Ng%' AND DH.Ngay < '2024-05-01';

--d. Lấy ra mã và tên mặt hàng có đơn giá nhỏ nhất
SELECT MaH, TenH, DonGia
FROM HANG
WHERE DonGia = (SELECT MIN(DonGia) FROM HANG);

--e. Lấy ra mã hàng và số khách hàng đã đặt mua mặt hàng đó.
INSERT INTO CTDH VALUES (N'D02',N'H01',10)
SELECT CTDH.MaH, COUNT(DISTINCT DH.MaKH) AS N'Số khách hàng đặt mua'
FROM CTDH
JOIN DH ON CTDH.SoDH = DH.SoDH
GROUP BY CTDH.MaH

--f. Lấy ra mã mặt hàng đã được trên 5 khách hàng đặt mua.
INSERT INTO CTDH VALUES (N'D02',N'H03',10),
						(N'D03',N'H03',10),
						(N'D05',N'H03',10)
SELECT CTDH.MaH 
FROM CTDH
JOIN DH ON CTDH.SoDH = DH.SoDH
GROUP BY CTDH.MaH
HAVING COUNT(DISTINCT DH.MaKH)>5
--ĐỀ 1


--ĐỀ 2
USE tempdb;
GO
DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'QLCT')
BEGIN
    SET @SQL = N'USE [QLCT]
				 ALTER DATABASE QLCT SET SINGLE_USER WITH ROLLBACK IMMEDIATE
                 USE [tempdb]
				 DROP DATABASE QLCT'
    EXEC (@SQL)
END
USE [master]
GO
--Tạo cơ sở dữ liệu
CREATE DATABASE QLCT
ON PRIMARY (NAME = 'QLCT', FILENAME = 'D:\QLCT.mdf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)
LOG ON (NAME = 'QLCT_log', FILENAME = 'D:\QLCT_log.ldf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)

GO
USE [QLCT]
GO

CREATE TABLE NV( MaNV NCHAR(10) NOT NULL CONSTRAINT PK_NHANVIEN PRIMARY KEY,
				 Ho NVARCHAR(15),
				 Ten NVARCHAR(15),
				 DiaChi NVARCHAR(20))

CREATE TABLE CT( MaCT NCHAR(10) NOT NULL CONSTRAINT PK_CONGTRINH PRIMARY KEY,
				 TenCT NVARCHAR(30),
				 NganSach MONEY)

CREATE TABLE PC ( MaNV NCHAR(10) NOT NULL,
				  MaCT NCHAR(10) NOT NULL,
				  PRIMARY KEY(MaNV,MaCT),
				  NhiemVu NVARCHAR(20),
				  NgayBD DATE,
				  CONSTRAINT FK_PC_NV FOREIGN KEY (MaNV) REFERENCES NV(MaNV),
				  CONSTRAINT FK_PC_CT FOREIGN KEY (MaCT) REFERENCES CT(MaCT))

INSERT INTO NV VALUES (N'K01',N'Bùi',N'Hoàng Linh',N'Hà Giang'),
                      (N'K02',N'Bùi',N'Hoàng Long',N'Hà Giang'),
					  (N'K03',N'Hoàng',N'Tuấn Anh',N'Thái Bình'),
					  (N'K04',N'Nguyễn',N'Thành Lân',N'Thái Bình'),
					  (N'K05',N'Trần',N'Văn Thắng',N'Hà Nội')

INSERT INTO CT VALUES (N'CT01',N'Nhà ở thông minh',1000),
					  (N'CT02',N'Trí tuệ',500),
					  (N'CT03',N'Nhà chung cư',2000),
					  (N'CT04',N'Nhà mặt đất',400),
					  (N'CT05',N'Nhà hàng',1500),
					  (N'CT06',N'Khách sạn cao cấp',5000)

INSERT INTO PC VALUES (N'K01',N'CT01',N'Khảo sát','12/25/2021'),
					  (N'K02',N'CT01',N'Quản lý','12/25/2024'),
					  (N'K03',N'CT02',N'Khảo sát','7/22/2023'),
					  (N'K04',N'CT03',N'Xây dựng','1/30/2025'),
					  (N'K05',N'CT04',N'Giám sát','4/2/2022'),
					  (N'K01',N'CT03',N'Khảo sát','10/15/2023'),
					  (N'K03',N'CT05',N'Giám sát','12/25/2021')

SELECT * FROM NV
SELECT * FROM CT
SELECT * FROM PC

--a. Lấy ra mã và tên các công trình ngân sách từ 500 đến 1000.
SELECT MaCT,TenCT
FROM CT
WHERE NganSach BETWEEN 500 AND 1000

--b. Lấy ra tên và địa chỉ của nhân viên bắt đầu tham gia công trình ‘Nhà ở thông minh’ vào tháng 10 năm 2021
INSERT INTO PC VALUES (N'K03',N'CT01',N'Khảo sát','10/25/2021')
SELECT NV.Ten, NV.DiaChi
FROM PC
JOIN NV ON PC.MaNV = NV.MaNV
JOIN CT ON PC.MaCT = CT.MaCT
WHERE CT.TenCT = N'Nhà ở thông minh' AND YEAR(PC.NgayBD) = 2021 AND MONTH(PC.NgayBD) = 10

--c. Lấy ra mã, tên và ngân sách các công trình có tên bắt đầu bằng ‘Trí tuệ’ mà nhân viên có mã là K15 đã tham gia.
INSERT INTO NV VALUES (N'K15',N'Bùi',N'Hoàng Linh',N'Thái Bình')
INSERT INTO CT VALUES (N'CT07',N'Trí tuệ nhân tạo',300)
INSERT INTO PC VALUES (N'K15',N'CT02',N'Khảo sát','1/25/2025'),
					  (N'K15',N'CT07',N'Khảo sát','1/25/2025')
SELECT CT.MaCT,CT.TenCT,CT.NganSach 
FROM PC
JOIN NV ON PC.MaNV = NV.MaNV
JOIN CT ON PC.MaCT = CT.MaCT
WHERE CT.TenCT LIKE N'Trí tuệ%' AND NV.MaNV = N'K15'

--d. Lấy ra tên nhân viên chưa tham gia công trình nào.
INSERT INTO NV VALUES (N'K10',N'Trần',N'Hà Linh',N'Thái Bình')
SELECT NV.Ten
FROM NV
LEFT JOIN PC ON NV.MaNV = PC.MaNV
WHERE PC.MaNV IS NULL

--e. Lấy ra mã công trình và số nhân viên đã tham gia công trình đó trước ngày 25/12/2021
SELECT PC.MaCT, COUNT(PC.MaNV) AS N'Số nhân viên đã tham gia công trình trước ngày 25/12/2021'
FROM PC 
JOIN NV ON PC.MaNV = NV.MaNV
WHERE PC.NgayBD < '12/25/2021'
GROUP BY PC.MaCT
--f. Lấy ra mã công trình có hơn 100 nhân viên tham gia đã kết thúc vào tháng 12 năm 2021.
SELECT PC.MaCT 
FROM PC
JOIN CT ON PC.MaCT = CT.MaCT
WHERE YEAR(PC.NgayBD) = 2021 AND MONTH(PC.NgayBD) = 12
GROUP BY PC.MaCT
HAVING COUNT(DISTINCT PC.MaNV) > 100
--ĐỀ 2

--ĐỀ 3
USE tempdb;
GO
DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'QLKho')
BEGIN
    SET @SQL = N'USE [QLKho]
				 ALTER DATABASE QLKho SET SINGLE_USER WITH ROLLBACK IMMEDIATE
                 USE [tempdb]
				 DROP DATABASE QLKho'
    EXEC (@SQL)
END
USE [master]
GO
--Tạo cơ sở dữ liệu
CREATE DATABASE QLKho
ON PRIMARY (NAME = 'QLKho', FILENAME = 'D:\QLKho.mdf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)
LOG ON (NAME = 'QLKho_log', FILENAME = 'D:\QLKho_log.ldf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)

GO
USE [QLKho]
GO


CREATE TABLE NCC (MaNCC NCHAR(10) NOT NULL CONSTRAINT PK_MANCC PRIMARY KEY,
				  Ho NVARCHAR(15),
				  Ten NVARCHAR(20),
				  DiaChi NVARCHAR(20))

CREATE TABLE SP ( MaSP NCHAR(10) NOT NULL CONSTRAINT PK_SanPham PRIMARY KEY,
					   TenSP NVARCHAR(20),
					   Gia MONEY)

CREATE TABLE PG ( SoPG NCHAR(10) NOT NULL CONSTRAINT PK_PhieuGiao PRIMARY KEY,
						 Ngay DATE,
						 MaNCC NCHAR(10) NOT NULL CONSTRAINT FP_PhieuGiao_NCC FOREIGN KEY (MaNCC) REFERENCES NCC(MaNCC))

CREATE TABLE CTPG ( SoPG NCHAR(10) NOT NULL,
					MaSP NCHAR(10) NOT NULL,
					PRIMARY KEY(SoPG,MaSP),
					SL INT,
					CONSTRAINT FP_CTPG_PG FOREIGN KEY (SoPG) REFERENCES PG(SoPG),
					CONSTRAINT FP_CTPG_SP FOREIGN KEY (MaSP) REFERENCES SP(MaSP))

INSERT INTO NCC VALUES (N'NCC1',N'Đỗ',N'Hường',N'Tuyên Quang'),
					   (N'NCC2',N'Đỗ',N'Quang',N'Thái Bình'),
					   (N'NCC3',N'Bùi',N'Linh',N'Hà Giang'),
					   (N'NCC4',N'Bùi',N'Long',N'Hà Giang'),
					   (N'NCC5',N'Nguyễn',N'Lan',N'Bắc Giang')

INSERT INTO SP VALUES (N'SP01',N'Nồi cơm điện',500000),
					  (N'SP02',N'Camera điện tử',600000),
					  (N'SP03',N'Quạt điện tử',300000),
					  (N'SP04',N'TiVi',5000000),
					  (N'SP05',N'Điều hoà',6000000)

INSERT INTO PG VALUES (N'P01','12/25/2025',N'NCC1'),
				      (N'P02','10/10/2025',N'NCC1'),
					  (N'P03','7/20/2025',N'NCC2'),
					  (N'P04','9/30/2025',N'NCC3'),
					  (N'P05','12/25/2025',N'NCC4')

INSERT INTO CTPG VALUES (N'P01',N'SP01',10),
						(N'P01',N'SP02',100),
						(N'P01',N'SP03',10),
						(N'P02',N'SP04',10),
						(N'P03',N'SP05',10),
						(N'P04',N'SP04',10),
						(N'P05',N'SP04',10),
						(N'P05',N'SP03',100)

SELECT * FROM NCC
SELECT * FROM SP
SELECT * FROM PG
SELECT * FROM CTPG

--a. Lấy ra tên và địa chỉ các nhà cung cấp họ Đỗ.
SELECT Ten,DiaChi
FROM NCC
WHERE Ho = N'Đỗ'

--b. Lấy ra mã nhà cung cấp, tên sản phẩm và giá các sản phẩm mà nhà cung cấp đó đã giao với số lượng dưới 1500
SELECT NCC.MaNCC, SP.TenSP, SP.Gia
FROM CTPG
JOIN SP ON CTPG.MaSP = SP.MaSP
JOIN PG ON CTPG.SoPG = PG.SoPG
JOIN NCC ON NCC.MaNCC = PG.MaNCC
WHERE CTPG.SL < 1500

--c. Lấy ra tên các sản phẩm kết thúc bằng từ ‘điện tử’ được giao với số lượng 100.
INSERT INTO CTPG VALUES (N'P02',N'SP02',100)
SELECT DISTINCT SP.TenSP 
FROM CTPG
JOIN SP ON CTPG.MaSP = SP.MaSP
WHERE SP.TenSP LIKE N'%điện tử' AND CTPG.SL = 100

--d. Lấy ra tên sản phẩm có giá lớn nhất.
SELECT TenSP
FROM SP
WHERE Gia = ( SELECT MAX(Gia) FROM SP)

--e. Lấy ra mã nhà cung cấp và số sản phẩm mà nhà cung cấp đó đã giao.
SELECT PG.MaNCC, COUNT(CTPG.MaSP) AS N'Số sản phẩm đã giao'
FROM CTPG
JOIN PG ON CTPG.SoPG = PG.SoPG
GROUP BY PG.MaNCC
-- Lấy ra mã nhà cung cấp và số lượng sản phẩm mà nhà cung cấp đó đã giao.
SELECT PG.MaNCC, SUM(CTPG.SL) AS N'Số lượng sản phẩm đã giao'
FROM CTPG
JOIN PG ON CTPG.SoPG = PG.SoPG
GROUP BY PG.MaNCC
--f. Lấy ra mã nhà cung cấp đã giao từ 10 sản phẩm trở lên.
SELECT PG.MaNCC
FROM CTPG
JOIN PG ON CTPG.SoPG = PG.SoPG
GROUP BY PG.MaNCC
HAVING COUNT(CTPG.MaSP) > 10
--ĐỀ 3