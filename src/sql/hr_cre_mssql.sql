CREATE TABLE  employees (
		employee_id INT IDENTITY(100,1) NOT NULL,
		first_name VARCHAR(20) NOT NULL,
		last_name VARCHAR(20) NOT NULL,
		hire_date DATE NOT NULL,
		manager_id INT,
		PRIMARY KEY (employee_id)
	);



INSERT INTO employees VALUES 
        (  'Gugloo'
        , 'King'
        , CONVERT(DATETIME,'08-05-2021', 103)
        , 100
        );
INSERT INTO employees VALUES 
        (  'Steven'
        , 'King'
        , CONVERT(DATETIME,'25-06-2005', 103)
        , 100
        );
INSERT INTO employees VALUES 
        (  'Neena'
        , 'Kochhar'
        , CONVERT(DATETIME, '21-06-2016', 103)
        , 100
        );
INSERT INTO employees VALUES 
        (  'Lex'
        , 'De Haan'
        , CONVERT(DATETIME, '05-06-2008', 103)
        , 102
        );
INSERT INTO employees VALUES 
        (  'Alexander'
        , 'Hunold'
        , CONVERT(DATETIME, '25-02-2004', 103)
        , 102
        );
INSERT INTO employees VALUES 
        ( 'Bruce'
        , 'Ernst'
        , CONVERT(DATETIME, '15-06-2002', 103)
        , 103
        );
INSERT INTO employees VALUES 
        ( 'David'
        , 'Austin'
        ,  CONVERT(DATETIME, '25-08-2009', 103)
        , 103
        );
INSERT INTO employees VALUES 
        (  'Valli'
        , 'Pataballa'
        , CONVERT(DATETIME, '20-06-2015', 103)
        , 103
        );
GO