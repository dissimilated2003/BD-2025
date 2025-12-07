--USE [Option 4]

-- производитель
CREATE TABLE Manufacturer (
    id_manufacturer INT IDENTITY(1,1) NOT NULL,
    manufacturer_name NVARCHAR(100) NOT NULL,
    country NVARCHAR(50) NOT NULL,
    phone_number NVARCHAR(20) NOT NULL,
    email NVARCHAR(255) NOT NULL,

    CONSTRAINT PK_Manufacturer_id_manufacturer PRIMARY KEY (id_manufacturer),
);

-- категория лекарств
CREATE TABLE DrugCategory (
    id_category INT IDENTITY(1,1) NOT NULL,
    category_name NVARCHAR(50) NOT NULL,
    description NVARCHAR(255) NOT NULL,

    CONSTRAINT PK_DrugCategory_id_category PRIMARY KEY (id_category),
);

-- лекарство
CREATE TABLE Drug (
    id_drug INT IDENTITY(1,1) NOT NULL,
    drug_name NVARCHAR(100) NOT NULL,
    active_substance NVARCHAR(100) NOT NULL,
    dosage NVARCHAR(50) NOT NULL,
    form NVARCHAR(50) NOT NULL,
    prescription_required BIT NOT NULL,

    id_manufacturer INT NOT NULL,
    id_category INT NOT NULL,
    CONSTRAINT PK_Drug_id_drug PRIMARY KEY (id_drug),
    CONSTRAINT FK_Drug_id_manufacturer 
        FOREIGN KEY (id_manufacturer) REFERENCES Manufacturer(id_manufacturer),
    CONSTRAINT FK_Drug_id_category
        FOREIGN KEY (id_category) REFERENCES DrugCategory(id_category),
);

-- аптека
CREATE TABLE Pharmacy (
    id_pharmacy INT IDENTITY(1,1) NOT NULL,
    pharmacy_name NVARCHAR(100) NOT NULL,
    address NVARCHAR(255) NOT NULL,
    phone_number NVARCHAR(20) NOT NULL,
    opening_hours NVARCHAR(100) NOT NULL,
    license_number NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_Pharmacy_id_pharmacy PRIMARY KEY (id_pharmacy),
    CONSTRAINT UQ_Pharmacy_license_number UNIQUE (license_number),
);

-- наличие лекарств в аптеке
CREATE TABLE PharmacyDrug (
    id_pharmacy_drug INT IDENTITY(1,1) NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    last_restock_date DATETIME NOT NULL,

    id_pharmacy INT NOT NULL,
    id_drug INT NOT NULL,
    CONSTRAINT PK_PharmacyDrug_id_pharmacy_drug PRIMARY KEY (id_pharmacy_drug),
    CONSTRAINT FK_PharmacyDrug_id_pharmacy 
        FOREIGN KEY (id_pharmacy) REFERENCES Pharmacy(id_pharmacy),
    CONSTRAINT FK_PharmacyDrug_id_drug
        FOREIGN KEY (id_drug) REFERENCES Drug(id_drug),
    CONSTRAINT UQ_PharmacyDrug_pharmacy_drug UNIQUE (id_pharmacy, id_drug),
    CONSTRAINT CHK_PharmacyDrug_quantity CHECK (quantity >= 0),
    CONSTRAINT CHK_PharmacyDrug_price CHECK (price > 0),
);