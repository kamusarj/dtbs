--10.2.a
SELECT * FROM NhanVien
--10.2.b
SELECT MaSP, TenSP,SoLuong, MauSac, GiaBan, DonViTinh, MoTa
FROM SanPham
ORDER BY GiaBan DESC
--10.2.c
SELECT TOP 2 MaSP, TenSP,SoLuong, MauSac, GiaBan, DonViTinh, MoTa
FROM SanPham
ORDER BY GiaBan
--10.2.d
SELECT *
FROM NhanVien
WHERE GioiTinh = N'Nữ' AND TenPhong = N'Kế toán'
--10.2.e
SELECT *
FROM SanPham
WHERE MauSac = N'Đỏ' AND GiaBan BETWEEN 500000 AND 10000000

