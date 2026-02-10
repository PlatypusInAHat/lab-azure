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
)
INSERT INTO Users (
        Name,
        Email,
        PhoneNumber,
        Address,
        ProfilePicturePath
    )
VALUES (
        'Nguyen Van An',
        'an.nguyen@email.com',
        '0901234567',
        '123 Le Loi, Quan 1, TP.HCM',
        'user-pictures/images.jpg'
    ),
    (
        'Tran Thi Binh',
        'binh.tran@email.com',
        '0912345678',
        '456 Nguyen Hue, Quan 1, TP.HCM',
        'user-pictures/images (1).jpg'
    ),
    (
        'Le Hoang Cuong',
        'cuong.le@email.com',
        '0923456789',
        '789 Hai Ba Trung, Quan 3, TP.HCM',
        'user-pictures/images (7).jpg'
    )
END