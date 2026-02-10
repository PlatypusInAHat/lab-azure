-- =============================================================================
-- Azure SQL Database - User Profiles
-- =============================================================================
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
INSERT INTO Users (
        Name,
        Email,
        PhoneNumber,
        Address,
        ProfilePicturePath
    )
VALUES (
        N 'Nguyen Van An',
        N'an.nguyen@email.com',
        N'0901234567',
        N'123 Le Loi, Quan 1, TP.HCM',
        N'user-pictures/images.jpg'
    ),
    (
        N'Tran Thi Binh',
        N'binh.tran@email.com',
        N'0912345678',
        N '456 Nguyen Hue, Quan 1, TP.HCM',
        N'user-pictures/images (1).jpg'
    ),
    (
        N'Le Hoang Cuong',
        N'cuong.le@email.com',
        N'0923456789',
        N'789 Hai Ba Trung, Quan 3, TP.HCM',
        N'user-pictures/images (7).jpg'
    );
END