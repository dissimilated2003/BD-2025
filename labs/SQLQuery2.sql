USE [Option 3]

-- клиент
CREATE TABLE Client (
	id_client INT IDENTITY(1,1) NOT NULL,
	last_name NVARCHAR(100) NOT NULL, -- фамили€ 
	first_name NVARCHAR(100) NOT NULL, -- им€ 
	middle_name NVARCHAR(100) NOT NULL, -- отчество
	phone_number NVARCHAR(20) NOT NULL,
	email NVARCHAR(255) NOT NULL,
	gender NVARCHAR(255) NOT NULL,

	CONSTRAINT PK_Client_id_client PRIMARY KEY (id_client),
);

-- тур. организаци€
CREATE TABLE TourOrganization (
	id_organization INT IDENTITY(1,1) NOT NULL,
	organization_name NVARCHAR(100) NOT NULL,
	organization_address NVARCHAR(255) NOT NULL,
	phone_number NVARCHAR(20) NOT NULL,
	email NVARCHAR(255) NOT NULL,

	CONSTRAINT PK_TourOrganization_id_organization PRIMARY KEY (id_organization),
);

-- CONSTRAINT PK/FK_<текуща€ таблица>_<id элемента который объ€вл€етс€ CONSTRAINT>
-- сотрудник
CREATE TABLE Employee (
	id_employee INT IDENTITY(1,1) NOT NULL,
	last_name NVARCHAR(100) NOT NULL, -- фамили€ 
	first_name NVARCHAR(100) NOT NULL, -- им€ 
	middle_name NVARCHAR(100) NOT NULL, -- отчество
	salary INT NOT NULL,
	phone_number NVARCHAR(20) NOT NULL,
	email NVARCHAR(255) NOT NULL,

	id_organization INT NOT NULL,
	CONSTRAINT PK_Employee_id_employee PRIMARY KEY (id_employee),
	CONSTRAINT FK_Employee_id_organization 
		FOREIGN KEY (id_organization) REFERENCES TourOrganization(id_organization),
);

-- туристический маршрут
CREATE TABLE TourRoute (
	id_route INT IDENTITY(1,1) NOT NULL,
	route_name NVARCHAR(255) NOT NULL,
	[start_point] NVARCHAR(255) NOT NULL,
	[end_point] NVARCHAR(255) NOT NULL,
	persons_quantity INT NOT NULL,

	CONSTRAINT PK_TourRoute_id_route PRIMARY KEY (id_route),
);

-- путевка
CREATE TABLE TravelPackage (
	id_travel_package INT IDENTITY(1,1) NOT NULL,
	tour_name NVARCHAR(255) NOT NULL,
	[start_date] DATETIME NOT NULL,
	[end_date] DATETIME NOT NULL,
	tour_cost INT NOT NULL,

	id_route INT NOT NULL,
	CONSTRAINT PK_TravelPackage_id_travel_package PRIMARY KEY (id_travel_package),
	CONSTRAINT FK_TravelPackage_id_route
		FOREIGN KEY (id_route) REFERENCES TourRoute(id_route),
);

-- покупка путевки
CREATE TABLE Purchase (
	id_purchase INT IDENTITY(1,1) NOT NULL,
	purchase_date DATETIME NOT NULL,
	purchase_status NVARCHAR(30) NOT NULL,

	id_travel_package INT NOT NULL,
	id_client INT NOT NULL,
	id_employee INT NOT NULL,
	CONSTRAINT PK_Purchase_id_purchase PRIMARY KEY (id_purchase),
	CONSTRAINT FK_Purchase_id_travel_package 
		FOREIGN KEY (id_travel_package) REFERENCES TravelPackage(id_travel_package),
	CONSTRAINT FK_Purchase_id_client
		FOREIGN KEY (id_client) REFERENCES Client(id_client),
	CONSTRAINT FK_Purchase_id_employee
		FOREIGN KEY (id_employee) REFERENCES Employee(id_employee),
);