-- Dropping

DROP TABLE IF EXISTS loan;
DROP TABLE IF EXISTS copy;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS book;

DROP VIEW IF EXISTS CMP_students;

DROP PROCEDURE IF EXISTS new_loan;

DROP TABLE IF EXISTS audit_trail;
DROP TRIGGER IF EXISTS new_loan;

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


-- Create View Statements

-- CREATE VIEW CMP_students AS
-- SELECT `no`, `name`, school, embargo FROM student 
-- WHERE school = 'CMP' WITH CHECK OPTION;
-- INSERT INTO CMP_Students(`no`, `name`, school, embargo) VALUES
--    (2005, 'Lucy', 'BUE', 0);
    
    
-- Create Procedure Statements

DELIMITER $$

CREATE PROCEDURE new_loan(IN book_isbn CHAR(17), IN student_no INT)
BEGIN

DECLARE book_copy, loan_test INT;
DECLARE issued, test_complete BOOLEAN;
DECLARE due_date DATE;
DECLARE copy_duration TINYINT;
DECLARE student_embargo BIT(1) DEFAULT b'1';

DECLARE  copy_cursor CURSOR FOR SELECT `code`
FROM copy WHERE isbn = book_isbn;
DECLARE CONTINUE HANDLER FOR NOT FOUND	
SET test_complete = TRUE;
OPEN copy_cursor;

SET student_embargo = 
(SELECT embargo FROM student WHERE `no` = student_no);
SELECT student_embargo;
		
IF (embargo_status = b'1') THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Student unable to loan';	
END IF;	
SET issued = FALSE;
SET book_copy = 0;

ypoolloopy : LOOP

FETCH NEXT FROM copy_cursor INTO book_copy;
IF(test_complete)THEN LEAVE ypoolloopy;
END IF;

SET loan_test =
(SELECT `code` FROM loan WHERE (`code` = book_copy) AND (`return` IS NULL));
IF(loan_test IS NULL) THEN 
SET copy_duration = 
(SELECT duration FROM copy WHERE `code` = book_copy);
SET due_date = DATE_ADD(CURRENT_DATE, INTERVAL copy_duration DAY);
                
INSERT INTO loan (`code`, `no`, taken, due,`return`)
VALUES (book_copy, student_no, CURRENT_DATE, due_date, null);
SET issued = TRUE;

LEAVE ypoolloopy;
END IF;
END LOOP;
	
CLOSE copy_cursor;	

IF(issued = FALSE) THEN SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Book not found';
END IF;

END$$	
DELIMITER ;


-- Create Trigger Statements

CREATE TABLE audit_trail (
`code` int NOT NULL,
`no` INT NOT NULL,
taken DATE NOT NULL,
due DATE NOT NULL,
`return` DATE NULL);

DELIMITER $$

CREATE TRIGGER new_loan AFTER
UPDATE ON loan FOR EACH ROW
BEGIN 

IF(OLD.`return` IS NULL) AND (CURRENT_DATE() > OLD.due) THEN 
INSERT INTO audit_trail (`code`, `no`, taken, due, `return`) 
VALUES (NEW.`code`, NEW.`no`, NEW.taken, NEW.due, NEW.`return`); 

END IF;

END$$
DELIMITER ;


-- DML Statements
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
SELECT book.title, COUNT(book.title) AS 'Loan Frequency' FROM book INNER JOIN copy
ON book.isbn = copy.isbn
INNER JOIN loan ON copy.code = loan.code
GROUP BY book.title HAVING COUNT(book.title) >= 2;