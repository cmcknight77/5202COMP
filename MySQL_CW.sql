-- Dropping all tables

DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS copy;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS book;

-- Creating table statements

CREATE TABLE book (
	isbn CHAR(17) NOT NULL, 
	title VARCHAR(50) NOT NULL,
	author VARCHAR(30) NOT NULL,
CONSTRAINT pri_book PRIMARY KEY(isbn));

CREATE TABLE copy (
	`code` int NOT NULL,
	isbn CHAR(17) NOT NULL,
	duration TINYINT NOT NULL,
CONSTRAINT pri_copy PRIMARY KEY(`code`),
CONSTRAINT foreign_copy FOREIGN KEY(isbn)
REFERENCES book(isbn) ON UPDATE CASCADE); 

CREATE TABLE loan (
	`code` int NOT NULL,
	`no` INT NOT NULL,
	taken DATE NOT NULL,
	due DATE NOT NULL,
	`return` DATE NULL,
CONSTRAINT pri_loan PRIMARY KEY(taken));

CREATE TABLE student (
	`no` int NOT NULL,
	`name` VARCHAR(30) NOT NULL,
	school CHAR(3) NOT NULL,
	embargo BIT DEFAULT FALSE,
CONSTRAINT pri_student PRIMARY KEY(`no`));

-- Create View Statements

-- Inserting data to the tables

INSERT INTO book(isbn, title, author) VALUES
	('111-2-33-444444-5', 'Pro JavaFX', 'Dave Smith'),
    ('222-3-44-555555-6', 'Oracle Systems', 'Kate Roberts'),
    ('333-4-55-666666-7', 'Expert jQuery', 'Mike Smith');
    
INSERT INTO copy(`code`, isbn, duration) VALUES
	(1011, '111-2-33-444444-5', 21),
    (1012, '111-2-33-444444-5', 14),
    (1013, '111-2-33-444444-5', 7),  
    (2011, '222-3-44-555555-6', 21), 
    (3011, '333-4-55-666666-7', 7), 
    (3012, '333-4-55-666666-7', 14); 
    
INSERT INTO loan(`code`, `no`, taken, due, `return`) VALUES
	(1011, 2002, '2022-01-10', '2022-01-31', '2022-01-31'),
    (1011, 2002, '2022-02-05', '2022-02-26', '2022-02-23'),
    (1011, 2003, '2022-05-10', '2022-05-31', NULL),
    (1013, 2003, '2021-03-02', '2021-03-16', '2021-03-10'),
    (1013, 2002, '2021-08-02', '2021-08-16', '2021-08-16'),
    (2011, 2004, '2020-02-01', '2020-02-22', '2020-02-20'),
    (3011, 2002, '2022-07-03', '2022-07-10', NULL),
    (3011, 2005, '2021-10-10', '2021-10-17', '2021-10-20');
    
INSERT INTO student(`no`, `name`, school, embargo) VALUES
	(2001, 'Mike', 'CMP', 0),
    (2002, 'Andy', 'CMP', 1),
    (2003, 'Sarah', 'ENG', 0),  
    (2004, 'Karen', 'ENG', 1), 
    (2005, 'Lucy', 'BUE', 0); 


-- DML 1
SELECT isbn, title, author FROM book;

-- DML 2
SELECT `no`, `name`, school FROM student
ORDER BY school DESC;

-- DML 3
SELECT isbn, title FROM book
WHERE author LIKE '%Smith%';

-- DML 4
SELECT MAX(due) FROM loan;

-- DML 5
SELECT `no` FROM loan 
WHERE due IN (SELECT MAX(due) FROM loan);

-- DML 6
SELECT `no`, `name` FROM STUDENT 
WHERE `no` IN (SELECT `no` FROM loan
WHERE due IN (SELECT MAX(due) FROM loan));

-- DML 7
SELECT `no`, `code`, due FROM loan
WHERE year(due) = year(CURRENT_DATE()) AND (`return` IS NULL);

-- DML 8
SELECT DISTINCT student.`no`, student.`name`, book.isbn, book.title FROM copy INNER JOIN loan
ON copy.`code` = loan.`code` INNER JOIN student
ON student.`no` = loan.`no` INNER JOIN book
ON copy.isbn = book.isbn WHERE copy.duration = 7;

-- DML 9
SELECT DISTINCT student.`no`, student.`name` FROM student INNER JOIN loan
ON student.`no` = loan.`no`
WHERE  loan.due = (SELECT MAX(due) FROM loan);

-- DML 10
SELECT book.title, COUNT(book.title) AS 'Loan Frequency' FROM book INNER JOIN copy
ON book.isbn = copy.isbn INNER JOIN loan
ON copy.`code`  = loan.`code` GROUP BY book.title;

-- DML 11