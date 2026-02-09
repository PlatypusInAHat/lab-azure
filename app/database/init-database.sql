-- =============================================================================
-- Azure SQL Database Schema for User Profile Application
-- =============================================================================
-- Create Users table
IF NOT EXISTS (
    SELECT *
    FROM sys.tables
    WHERE name = 'Users'
) BEGIN CREATE TABLE Users (
    Id INT PRIMARY KEY IDENTITY(1, 1),
    Name NVARCHAR(100) NOT NULL,
    Age INT NOT NULL,
    PhoneNumber NVARCHAR(20),
    Address NVARCHAR(500),
    ProfilePicturePath NVARCHAR(500),
    -- Path to blob storage (e.g., 'user-pictures/user1.jpg')
    Email NVARCHAR(100),
    CreatedAt DATETIME2 DEFAULT GETDATE(),
    UpdatedAt DATETIME2 DEFAULT GETDATE()
);
END
GO -- Insert sample data
INSERT INTO Users (
        Name,
        Age,
        PhoneNumber,
        Address,
        ProfilePicturePath,
        Email
    )
VALUES (
        N'Nguyễn Văn An',
        28,
        '0901234567',
        N'123 Đường Lê Lợi, Quận 1, TP.HCM',
        'user-pictures/user1.jpg',
        'an.nguyen@email.com'
    ),
    (
        N'Trần Thị Bình',
        32,
        '0912345678',
        N'456 Đường Nguyễn Huệ, Quận 1, TP.HCM',
        'user-pictures/user2.jpg',
        'binh.tran@email.com'
    ),
    (
        N'Lê Hoàng Cường',
        25,
        '0923456789',
        N'789 Đường Hai Bà Trưng, Quận 3, TP.HCM',
        'user-pictures/user3.jpg',
        'cuong.le@email.com'
    ),
    (
        N'Phạm Minh Dũng',
        35,
        '0934567890',
        N'101 Đường Võ Văn Tần, Quận 3, TP.HCM',
        'user-pictures/user4.jpg',
        'dung.pham@email.com'
    ),
    (
        N'Hoàng Thị Em',
        29,
        '0945678901',
        N'202 Đường Điện Biên Phủ, Quận Bình Thạnh, TP.HCM',
        'user-pictures/user5.jpg',
        'em.hoang@email.com'
    );
GO -- Verify data
SELECT *
FROM Users;
GO