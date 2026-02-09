-- =============================================================================
-- Azure SQL Database Schema for User Profile Application
-- =============================================================================
-- Create Users table if not exists
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
-- Insert sample data only when table is first created
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
        'user-pictures/user1.jpg'
    ),
    (
        N'Trần Thị Bình',
        'binh.tran@email.com',
        '0912345678',
        N '456 Đường Nguyễn Huệ, Quận 1, TP.HCM',
        'user-pictures/user2.jpg'
    ),
    (
        N'Lê Hoàng Cường',
        'cuong.le@email.com',
        '0923456789',
        N'789 Đường Hai Bà Trưng, Quận 3, TP.HCM',
        'user-pictures/user3.jpg'
    ),
    (
        N'Phạm Minh Dũng',
        'dung.pham@email.com',
        '0934567890',
        N'101 Đường Võ Văn Tần, Quận 3, TP.HCM',
        'user-pictures/user4.jpg'
    ),
    (
        N'Hoàng Thị Em',
        'em.hoang@email.com',
        '0945678901',
        N'202 Đường Điện Biên Phủ, Bình Thạnh, TP.HCM',
        'user-pictures/user5.jpg'
    );
END