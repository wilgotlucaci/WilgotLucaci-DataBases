USE master;

GO

DROP DATABASE IF EXISTS Bokhandel1DB;

GO

CREATE DATABASE Bokhandel1DB;

GO

USE Bokhandel1DB;

GO

DROP VIEW IF EXISTS TitlarPerFörfattare;

GO

DROP TABLE IF EXISTS LagerSaldo;
DROP TABLE IF EXISTS Böcker;
DROP TABLE IF EXISTS Butiker;
DROP TABLE IF EXISTS Förlag;
DROP TABLE IF EXISTS Kategorier;
DROP TABLE IF EXISTS Författare;

GO

CREATE TABLE Författare (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Förnamn NVARCHAR(50) NOT NULL,
    Efternamn NVARCHAR(50) NOT NULL,
    Födelsedatum DATE NOT NULL
);

GO

CREATE TABLE Förlag (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Namn NVARCHAR(100) NOT NULL,
    Stad NVARCHAR(50)
);

GO

CREATE TABLE Kategorier (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Namn NVARCHAR(50) NOT NULL
);

GO

CREATE TABLE Butiker (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    Butiksnamn NVARCHAR(100) NOT NULL,
    Gatuadress NVARCHAR(100) NOT NULL,
    Postnummer CHAR(5) NOT NULL,
    Stad NVARCHAR(50) NOT NULL
);

GO

CREATE TABLE Böcker (
    ISBN13 CHAR(13) PRIMARY KEY,
    Titel NVARCHAR(150) NOT NULL,
    Språk NVARCHAR(30) NOT NULL,
    Pris DECIMAL(10,2) NOT NULL CHECK (Pris >= 0),
    Utgivningsdatum DATE NOT NULL,
    FörfattareID INT NOT NULL,
    FörlagID INT NOT NULL,
    KategoriID INT NOT NULL,

    CONSTRAINT CK_Böcker_ISBN13 CHECK (ISBN13 NOT LIKE '%[^0-9]%'),

    FOREIGN KEY (FörfattareID)
        REFERENCES Författare(ID),

    FOREIGN KEY (FörlagID)
        REFERENCES Förlag(ID),

    FOREIGN KEY (KategoriID)
        REFERENCES Kategorier(ID)
);

GO

CREATE TABLE LagerSaldo (
    ButikID INT NOT NULL,
    ISBN CHAR(13) NOT NULL,
    Antal INT NOT NULL CHECK (Antal >= 0),

    PRIMARY KEY (ButikID, ISBN),

    FOREIGN KEY (ButikID)
        REFERENCES Butiker(ID),

    FOREIGN KEY (ISBN)
        REFERENCES Böcker(ISBN13)
);

GO

INSERT INTO Författare (Förnamn, Efternamn, Födelsedatum)
VALUES
('Astrid', 'Lindgren', '1907-11-14'),
('Selma', 'Lagerlöf', '1858-11-20'),
('Vilhelm', 'Moberg', '1898-08-20'),
('Fredrik', 'Backman', '1981-06-02');

GO

INSERT INTO Förlag (Namn, Stad)
VALUES
('Bonniers', 'Stockholm'),
('Norstedts', 'Stockholm'),
('Forum', 'Stockholm');

GO

INSERT INTO Kategorier (Namn)
VALUES
('Barn'),
('Roman'),
('Historia'),
('Drama');

GO

INSERT INTO Butiker (Butiksnamn, Gatuadress, Postnummer, Stad)
VALUES
('Bokhörnan', 'Storgatan 1', '11111', 'Stockholm'),
('Läs & Lär', 'Kungsgatan 5', '22222', 'Göteborg'),
('Bokpalatset', 'Torget 10', '33333', 'Malmö');

GO

INSERT INTO Böcker 
(ISBN13, Titel, Språk, Pris, Utgivningsdatum, FörfattareID, FörlagID, KategoriID)
VALUES
('9789129688313', 'Pippi Långstrump', 'Svenska', 149.00, '1945-11-01', 1, 1, 1),
('9789129704242', 'Ronja Rövardotter', 'Svenska', 159.00, '1981-01-01', 1, 1, 1),
('9789129697056', 'Bröderna Lejonhjärta', 'Svenska', 169.00, '1973-01-01', 1, 1, 1),
('9789174292425', 'Gösta Berlings saga', 'Svenska', 129.00, '1891-01-01', 2, 2, 2),
('9789174292432', 'Nils Holgerssons underbara resa', 'Svenska', 139.00, '1906-01-01', 2, 2, 1),
('9789100124519', 'Utvandrarna', 'Svenska', 179.00, '1949-01-01', 3, 1, 3),
('9789100124526', 'Invandrarna', 'Svenska', 179.00, '1952-01-01', 3, 1, 3),
('9789175031740', 'En man som heter Ove', 'Svenska', 159.00, '2012-01-01', 4, 3, 2),
('9789175034697', 'Britt-Marie var här', 'Svenska', 159.00, '2014-01-01', 4, 3, 2),
('9789175039449', 'Folk med ångest', 'Svenska', 169.00, '2019-01-01', 4, 3, 2);

GO

INSERT INTO LagerSaldo (ButikID, ISBN, Antal)
VALUES
(1, '9789129688313', 12),
(1, '9789129704242', 8),
(1, '9789129697056', 6),
(1, '9789174292425', 4),
(1, '9789174292432', 7),
(1, '9789100124519', 5),
(1, '9789100124526', 5),
(1, '9789175031740', 10),
(1, '9789175034697', 8),
(1, '9789175039449', 9),
(2, '9789129688313', 10),
(2, '9789129704242', 6),
(2, '9789129697056', 4),
(2, '9789174292425', 3),
(2, '9789174292432', 5),
(2, '9789100124519', 8),
(2, '9789100124526', 6),
(2, '9789175031740', 12),
(2, '9789175034697', 7),
(2, '9789175039449', 11),
(3, '9789129688313', 15),
(3, '9789129704242', 10),
(3, '9789129697056', 8),
(3, '9789174292425', 6),
(3, '9789174292432', 4),
(3, '9789100124519', 9),
(3, '9789100124526', 7),
(3, '9789175031740', 14),
(3, '9789175034697', 9),
(3, '9789175039449', 13);

GO

CREATE OR ALTER VIEW TitlarPerFörfattare AS
SELECT
    f.Förnamn + ' ' + f.Efternamn AS [Namn],
    DATEDIFF(YEAR, f.Födelsedatum, GETDATE()) AS [Ålder],
    COUNT(DISTINCT b.ISBN13) AS [Titlar],
    SUM(b.Pris * ls.Antal) AS [Lagervärde]
FROM Författare f
LEFT JOIN Böcker b
    ON f.ID = b.FörfattareID
LEFT JOIN LagerSaldo ls
    ON b.ISBN13 = ls.ISBN
GROUP BY
    f.ID,
    f.Förnamn,
    f.Efternamn,
    f.Födelsedatum;

GO

SELECT *
FROM TitlarPerFörfattare;

GO
