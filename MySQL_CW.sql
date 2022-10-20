CREATE TABLE book (
     isbn CHAR(17) NOT NULL, 
     title VARCHAR(50) NOT NULL,
     author VARCHAR(30) NOT NULL,
CONSTRAINT pri_course PRIMARY KEY(isbn));