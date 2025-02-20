USE tempdb;
GO
DECLARE @SQL nvarchar(1000);
IF EXISTS (SELECT 1 FROM sys.databases WHERE [name] = N'QLNV')
BEGIN
    SET @SQL = N'USE [QLNV]
				 ALTER DATABASE QLBanHang SET SINGLE_USER WITH ROLLBACK IMMEDIATE
                 USE [tempdb]
				 DROP DATABASE QLNV'
    EXEC (@SQL)
END
USE [master]
GO
--Tạo cơ sở dữ liệu
CREATE DATABASE QLNV
ON PRIMARY (NAME = 'QLNV', FILENAME = 'D:\QLNV.mdf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)
LOG ON (NAME = 'QLNV_log', FILENAME = 'D:\QLNV_log.ldf', SIZE = 8, MAXSIZE = UNLIMITED, FILEGROWTH = 64)

GO
USE [QLNV]
GO

CREATE TABLE NhanVien( MaNV NCHAR(10) NOT NULL CONSTRAINT PK_NhanVien PRIMARY KEY, 
					   TenNV NVARCHAR(30),
					   NgaySinh DATE,
					   TrinhDo NVARCHAR(20),
					   ChucVu NVARCHAR(20))

CREATE TABLE KhoaHoc(  MaKH NCHAR(10) NOT NULL CONSTRAINT PK_KhoaHoc PRIMARY KEY, 
					   TenKH NVARCHAR(30),
					   DiaDiem NVARCHAR(20))

CREATE TABLE ThamGia(  MaNV NCHAR(10) NOT NULL ,
					   MaKH NCHAR(10) NOT NULL ,
					   PRIMARY KEY( MaNV,MaKH),
					   SoBuoiNghi INT,
					   KetQua NVARCHAR(15),
					   CONSTRAINT FK_ThamGia_NhanVien FOREIGN KEY(MaNV) REFERENCES NhanVien(MaNV),
					   CONSTRAINT FK_ThamGia_KhoaHoc FOREIGN KEY(MaKH) REFERENCES KhoaHoc(MaKH))

INSERT INTO NhanVien VALUES	(N'NV01',N'Trần Văn Ước','12/5/1988',N'Đại học', N'Nhân viên'), 
						    (N'NV02',N'Hoàng Văn Huy','12/17/2000',N'Đại học', N'Trưởng phòng'), 
							(N'NV03',N'Nguyễn Thị Chinh','2/5/1982',N'Cao đẳng', N'Nhân viên')

INSERT INTO KhoaHoc VALUES (N'KH01',N'Giao tiếp cơ bản',N'Hà Nội'),
						   (N'KH02',N'Giao tiếp nâng cao',N'Hà Nội'),
						   (N'KH03',N'Phân tích số liệu',N'Hồ Chí Minh')

INSERT INTO ThamGia VALUES (N'NV01',N'KH01',1,N'Khá'),
						   (N'NV01',N'KH02',2,N'Khá'),
						   (N'NV02',N'KH01',0,N'Giỏi'),
						   (N'NV02',N'KH02',1,N'Khá'),
						   (N'NV02',N'KH03',1,N'Trung bình'),
						   (N'NV03',N'KH01',4,N'Trung bình')
					
SELECT * from NhanVien
SELECT * from KhoaHoc
SELECT * from ThamGia

--a. Lấy ra từ cơ sở dữ liệu tên các nhân viên có trình độ đại học.
SELECT * FROM NhanVien 
Where TrinhDo = N'Đại học'
--b. Đưa ra thông tin các nhân viên họ ‘Trần’ sinh năm 2000
INSERT INTO NhanVien VALUES	(N'NV04',N'Trần Văn Thắng','12/5/2000',N'Đại học', N'Nhân viên')
SELECT * FROM NhanVien
WHERE TenNV LIKE N'%Trần%' AND YEAR(NgaySinh) = 2000
--c. Lấy ra tên các nhân viên tham gia khóa học Giao tiếp nâng cao có kết quả Khá
SELECT NhanVien.TenNV 
FROM ThamGia
JOIN KhoaHoc ON ThamGia.MaKH = KhoaHoc.MaKH
JOIN NhanVien ON ThamGia.MaNV = NhanVien.MaNV
WHERE KhoaHoc.TenKH = N'Giao tiếp nâng cao' AND ThamGia.KetQua = N'Khá';
--d. Đưa ra thông tin câc nhân viên tham gia các khóa học ở Hà Nội có số buổi nghị học nhiều hơn 2
SELECT NhanVien.* from NhanVien
JOIN ThamGia ON NhanVien.MaNV = ThamGia.MaNV
JOIN KhoaHoc ON ThamGia.MaKH = KhoaHoc.MaKH
WHERE KhoaHoc.DiaDiem = N'Hà Nội' AND ThamGia.SoBuoiNghi > 2
--e. Lấy ra mã nhân viên, tên nhân viên, số buổi nghỉ và kết quả của các nhân viên tham gia các khóa học về giao tiếp
SELECT NV.MaNV, NV.TenNV, TG.SoBuoiNghi, TG.KetQua
FROM NhanVien NV
JOIN ThamGia TG ON NV.MaNV = TG.MaNV
JOIN KhoaHoc KH ON TG.MaKH = KH.MaKH
WHERE KH.TenKH LIKE N'Giao tiếp%'
--f. Đưa ra danh sách mã khóa học, tên khóa học, số người tham gia kết quả giỏi trong mỗi khóa
SELECT KH.MaKH, KH.TenKH, COUNT(*) AS SoNguoiGioi
FROM ThamGia TG
JOIN KhoaHoc KH ON TG.MaKH = KH.MaKH
WHERE TG.KetQua = N'Giỏi'
GROUP BY KH.MaKH, KH.TenKH;
--g. Lấy ra mã nhân viên và số khóa học nhân viên đó đã tham gia.
SELECT TG.MaNV, COUNT(TG.MaKH) AS SoKhoaHocThamGia
FROM ThamGia TG
GROUP BY TG.MaNV;
--h. Lấy ra mã và tên các khóa học có từ 2 nhân viên trở lên tham gia học.
SELECT KH.MaKH, KH.TenKH
FROM ThamGia TG
JOIN KhoaHoc KH ON TG.MaKH = KH.MaKH
GROUP BY KH.MaKH, KH.TenKH
HAVING COUNT(TG.MaNV) >= 2;
--i. Đưa ra thông tin nhiều tuổi nhất khóa học ‘Phân tích số liệu’
SELECT TOP 1 NV.*
FROM NhanVien NV
JOIN ThamGia TG ON NV.MaNV = TG.MaNV
JOIN KhoaHoc KH ON TG.MaKH = KH.MaKH
WHERE KH.TenKH = N'Phân tích số liệu'
ORDER BY NV.NgaySinh ASC;
--j. Lấy ra mã và tên nhân viên đã tham gia tất cả các khóa học
SELECT NV.MaNV, NV.TenNV
FROM NhanVien NV
JOIN ThamGia TG ON NV.MaNV = TG.MaNV
GROUP BY NV.MaNV, NV.TenNV
HAVING COUNT(DISTINCT TG.MaKH) = (SELECT COUNT(*) FROM KhoaHoc);
--k. Đưa ra nhân viên không tham gia khóa học nào
--cách 1
SELECT NV.MaNV, NV.TenNV
FROM NhanVien NV
LEFT JOIN ThamGia TG ON NV.MaNV = TG.MaNV
WHERE TG.MaKH IS NULL;
--cách 2
SELECT NV.MaNV, NV.TenNV
FROM NhanVien NV 
WHERE NV.MaNV not in (SELECT MaNV from ThamGia)
--l. Đưa ra nhân viên tham gia nhiều khóa học nhất
SELECT TOP 1 NV.MaNV, NV.TenNV, COUNT(TG.MaKH) AS SoKhoaHoc
FROM NhanVien NV
JOIN ThamGia TG ON NV.MaNV = TG.MaNV
GROUP BY NV.MaNV, NV.TenNV
ORDER BY SoKhoaHoc DESC;
--m. Đưa ra khóa học không có học viên nào học lực ‘Kém’
SELECT KH.MaKH, KH.TenKH
FROM KhoaHoc KH
WHERE KH.MaKH NOT IN (SELECT TG.MaKH FROM ThamGia TG WHERE TG.KetQua = N'Kém');
--n. Đưa ra nhân viên có số buổi nghỉ học nhiều nhất
SELECT TOP 1 NV.MaNV, NV.TenNV, SUM(TG.SoBuoiNghi) AS TongSoBuoiNghi
FROM NhanVien NV
JOIN ThamGia TG ON NV.MaNV = TG.MaNV
GROUP BY NV.MaNV, NV.TenNV
ORDER BY TongSoBuoiNghi DESC;	