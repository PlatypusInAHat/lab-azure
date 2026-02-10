-- =============================================================================
-- Azure SQL Database - Hồ sơ người dùng
-- =============================================================================
-- Tạo bảng Users nếu chưa tồn tại
IF NOT EXISTS (
    SELECT *
    FROM sys.tables
    WHERE name = 'Users'
) BEGIN CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1, 1),
    Name NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100),
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(500),
    ProfilePicturePath NVARCHAR(500),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);
-- Thêm dữ liệu mẫu
INSERT INTO Users (
        Name,
        Email,
        PhoneNumber,
        Address,
        ProfilePicturePath
    )
VALUES (
        N 'Nguyễn Văn An',
        'an.nguyen@email.com',
        '0901234567',
        N'123 Đường Lê Lợi, Quận 1, TP.HCM',
        'user-pictures/images.jpg'
    ),
    (
        N'Trần Thị Bình',
        'binh.tran@email.com',
        '0912345678',
        N '456 Đường Nguyễn Huệ, Quận 1, TP.HCM',
        'user-pictures/images (1).jpg'
    ),
    (
        N'Lê Hoàng Cường',
        'cuong.le@email.com',
        '0923456789',
        N'789 Đường Hai Bà Trưng, Quận 3, TP.HCM',
        'user-pictures/images (7).jpg'
    );
END