USE [lw3 option 4]

-- доп. сущность: поставщик
CREATE TABLE Supplier (
    id_supplier INT IDENTITY(1,1) NOT NULL,
    supplier_name NVARCHAR(100) NOT NULL,
    contact_person NVARCHAR(100) NOT NULL,
    phone_number NVARCHAR(20) NOT NULL,
    email NVARCHAR(255) NOT NULL,
    [address] NVARCHAR(255) NOT NULL,

    CONSTRAINT PK_Supplier_id_supplier PRIMARY KEY (id_supplier)
);

-- доп. сущность: склад
CREATE TABLE Warehouse (
    id_warehouse INT IDENTITY(1,1) NOT NULL,
    warehouse_name NVARCHAR(100) NOT NULL,
    [address] NVARCHAR(255) NOT NULL,
    capacity INT NOT NULL, -- объем в м^3
    manager_name NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Warehouse_id_warehouse PRIMARY KEY (id_warehouse),
    CONSTRAINT CHK_Warehouse_capacity CHECK (capacity > 0)
);

-- товар
CREATE TABLE [Product] (
    id_product INT IDENTITY(1,1) NOT NULL,
    product_name NVARCHAR(100) NOT NULL,
    [description] NVARCHAR(255) NOT NULL,
    unit NVARCHAR(20) NOT NULL, -- штуки, кг, литры и т.д.
    unit_price DECIMAL(10,2) NOT NULL,
    category NVARCHAR(50) NOT NULL,

    id_supplier INT NOT NULL,
    CONSTRAINT PK_Product_id_product PRIMARY KEY (id_product),
    CONSTRAINT FK_Product_id_supplier FOREIGN KEY (id_supplier) 
        REFERENCES Supplier(id_supplier),
    CONSTRAINT CHK_Product_price CHECK (unit_price > 0)
);

-- накладная
CREATE TABLE Invoice (
    id_invoice INT IDENTITY(1,1) NOT NULL,
    invoice_number NVARCHAR(50) NOT NULL,
    invoice_date DATE NOT NULL,
    total_amount DECIMAL(12,2) NOT NULL,
    [status] NVARCHAR(20) NOT NULL, -- ожидает, доставлено, отменено

    id_warehouse INT NOT NULL,
    id_supplier INT NOT NULL,
    CONSTRAINT PK_Invoice_id_invoice PRIMARY KEY (id_invoice),
    CONSTRAINT FK_Invoice_id_warehouse FOREIGN KEY (id_warehouse) 
        REFERENCES Warehouse(id_warehouse),
    CONSTRAINT FK_Invoice_id_supplier FOREIGN KEY (id_supplier) 
        REFERENCES Supplier(id_supplier),
    CONSTRAINT UQ_Invoice_number UNIQUE (invoice_number),
    CONSTRAINT CHK_Invoice_amount CHECK (total_amount >= 0)
);

-- товары в накладной
CREATE TABLE InvoiceProduct (
    id_invoice_product INT IDENTITY(1,1) NOT NULL,
    quantity DECIMAL(10,3) NOT NULL,
    price_per_unit DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,

    id_invoice INT NOT NULL,
    id_product INT NOT NULL,
    CONSTRAINT PK_InvoiceProduct_id_invoice_product PRIMARY KEY (id_invoice_product),
    CONSTRAINT FK_InvoiceProduct_id_invoice FOREIGN KEY (id_invoice) 
        REFERENCES Invoice(id_invoice),
    CONSTRAINT FK_InvoiceProduct_id_product FOREIGN KEY (id_product) 
        REFERENCES [Product](id_product),
    CONSTRAINT CHK_InvoiceProduct_quantity CHECK (quantity > 0),
    CONSTRAINT CHK_InvoiceProduct_price CHECK (price_per_unit > 0),
    CONSTRAINT UQ_InvoiceProduct_invoice_product UNIQUE (id_invoice, id_product)
);