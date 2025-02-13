--10.2.a
SELECT *
FROM SanPham
WHERE MauSac = N'Đỏ'
--10.2.b
SELECT TOP 2 *
FROM SanPham
ORDER BY GiaBan DESC
--10.2.c
SELECT *
FROM PNhap
WHERE YEAR(NgayNhap) = 2021
--10.2.d
SELECT DISTINCT DiaChi
FROM NhanVien
--10.2.e
SELECT TOP 3 *
FROM SanPham
WHERE MauSac = N'Xanh'
ORDER BY SoLuong
--10.2.f
SELECT *
FROM NhanVien
WHERE TenPhong = N'Kế toán'
--10.2.g
SELECT *
FROM SanPham
WHERE GiaBan BETWEEN 1000000 AND 10000000
--10.2.h
SELECT MaNV, TenNV AS N'Họ và tên', SUBSTRING(TenNV, 1, LEN(TenNV) - CHARINDEX(' ', REVERSE(TenNV))) AS N'Họ và đệm', SUBSTRING(TenNV, LEN(TenNV) - CHARINDEX(' ', REVERSE(TenNV)) + 2, CHARINDEX(' ', REVERSE(TenNV)) + 1) AS N'Tên', GioiTinh, DiaChi, SoDT, Email, TenPhong
FROM NhanVien
--10.2.i
SELECT SoHDN, DAY(NgayNhap) AS N'Ngày nhập', MONTH(NgayNhap) AS N'Tháng nhập', YEAR(NgayNhap) AS N'Năm nhập'
FROM PNhap
--10.2.j
SELECT SoHDX, DAY(NgayXuat) AS N'Ngày xuất', MONTH(NgayXuat) AS N'Tháng xuất', YEAR(NgayXuat) AS N'Năm xuất'
FROM PXuat
--10.2.k
--10.2.l
SELECT *
FROM SanPham
WHERE TenSP LIKE '%Plus%'
--10.2.m
SELECT *
FROM SanPham
ORDER BY GiaBan DESC, SoLuong
--10.2.n
SELECT N'Mã sản phẩm: ' + MaSP + N', Tên sản phẩm: ' + TenSP + N', Số lượng: ' + CONVERT(NVARCHAR(10), SoLuong) AS N'Thông tin sản phẩm'
FROM SanPham
--10.2.o
--Cách 1
SELECT TOP 1 WITH TIES *
FROM SanPham
ORDER BY SoLuong DESC
--Cách 2
SELECT *
FROM SanPham
WHERE SoLuong = (SELECT MAX(SoLuong) FROM SanPham)