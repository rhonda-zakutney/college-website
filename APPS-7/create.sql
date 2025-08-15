-- Active: 1681172260948@@apps7.cbguogqvf5db.us-east-1.rds.amazonaws.com@3306@university
CREATE DATABASE university
    DEFAULT CHARACTER SET = 'utf8mb4';

use university;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
    uid         int(8) AUTO_INCREMENT NOT NULL UNIQUE,
    fname       varchar(50) NOT NULL,
    lname       varchar(50) NOT NULL,
    email       varchar(50) NOT NULL UNIQUE,
    password    varchar(50) NOT NULL,
    address     varchar(100) NOT NULL,
    ssn         char(9) NOT NULL UNIQUE,
    type        enum('Admin', 'Applicant', 'GS', 'CAC', 'Reviewer') NOT NULL,
    PRIMARY KEY (uid)
);

DROP TABLE IF EXISTS applications;
CREATE TABLE applications (
    appid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(8) NOT NULL UNIQUE,
    status      enum('incomplete', 'complete', 'admitted', 'denied') NOT NULL,
    transcript  enum('T', 'F') NOT NULL,
    degree      enum('MS', 'PhD') NOT NULL,
    past_d1     int(5) NOT NULL,
    past_d2     int(5) DEFAULT NULL,
    semester    enum('Fall', 'Spring') NOT NULL,
    year        int(4) NOT NULL,
    experience  varchar(300) NOT NULL,
    aoi         varchar(300) NOT NULL,
    letter      int(5) DEFAULT NULL,
    review      int(5) DEFAULT NULL,
    gre         int(5) DEFAULT NULL,
    PRIMARY KEY (appid),
    FOREIGN KEY (past_d1) REFERENCES degrees(degid),
    FOREIGN KEY (past_d2) REFERENCES degrees(degid),
    FOREIGN KEY (letter) REFERENCES recs(recid),
    FOREIGN KEY (review) REFERENCES reviews(revid),
    FOREIGN KEY (gre) REFERENCES gres(greid),
    FOREIGN KEY (uid) REFERENCES users(uid)
);

DROP TABLE IF EXISTS degrees;
CREATE TABLE degrees (
    degid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(8) NOT NULL,
    type        enum('BS/BA', 'MS') NOT NULL,
    gpa         decimal(3,2) NOT NULL, 
    major       varchar(50) NOT NULL,
    college     varchar(50) NOT NULL,
    year        int(4) NOT NULL,
    PRIMARY KEY (degid),
    FOREIGN KEY (uid) REFERENCES users(uid)
);

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews (
    revid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(8) NOT NULL,
    rating      ENUM('0','1','2','3') NOT NULL,
    deficiency  varchar(100),
    reason      char(1) NOT NULL,
    advisor     varchar(30),
    comments    varchar(40),
    reviewer_id int(8) NOT NULL,
    PRIMARY KEY (revid),
    FOREIGN KEY (uid) REFERENCES users(uid),
    FOREIGN KEY (reviewer_id) REFERENCES users(uid)
);

DROP TABLE IF EXISTS recs;
CREATE TABLE recs (
    recid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(8) NOT NULL,
    rating      ENUM('1','2','3','4','5'),
    generic     ENUM("y","n"),
    credible    ENUM("y","n"),
    writer      varchar(30) NOT NULL,
    email       varchar(50) NOT NULL UNIQUE,
    title       varchar(30) NOT NULL,
    affiliation varchar(30) NOT NULL,
    message     varchar(200) DEFAULT NULL,
    PRIMARY KEY (recid),
    FOREIGN KEY(uid) REFERENCES users(uid)
);

DROP TABLE IF EXISTS gres;
CREATE TABLE gres (
    greid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(8) NOT NULL UNIQUE,
    total       int(3) DEFAULT NULL,
    verbal      int(3) DEFAULT NULL,
    quant       int(3) DEFAULT NULL,
    year        int(4) DEFAULT NULL,
    toefl       int(3) DEFAULT NULL,
    score       int(3) DEFAULT NULL,
    subject     varchar(30) DEFAULT NULL,
    date        int(4) DEFAULT NULL,
    PRIMARY KEY (greid),
    FOREIGN KEY (uid) REFERENCES users(uid)
);

SET FOREIGN_KEY_CHECKS = 1;
 
INSERT INTO users VALUES (1,'admin', 'admminlname', 'admin@gmail.com', 'password', '123 abc st', '123456789', 'Admin');
INSERT INTO users VALUES (2,'gs', 'gslname', 'gs@gmail.com', 'password', '123 abc st', '123456788', 'GS');
INSERT INTO users VALUES (3,'cac', 'caclname', 'cac@gmail.com', 'password', '123 abc st', '123456780', 'CAC');
INSERT INTO users VALUES (4,'narahari', 'naraharilname', 'narahari@gmail.com', 'password', '123 abc st', '123456799', 'Reviewer');

INSERT INTO users VALUES (5,'wood', 'woodlname', 'wood@gmail.com', 'password', '123 abc st', '123426799', 'Reviewer');

INSERT INTO users VALUES (6,'heller', 'hellerlname', 'heller@gmail.com', 'password', '123 abc st', '123856799', 'Reviewer');
INSERT INTO users VALUES (12312312,'John', 'Lennon', 'john@gmail.com', 'password', '123 abc st', '111111111', 'Applicant');
INSERT INTO users VALUES (66666666,'Ringo', 'Starr', 'ringo@gmail.com', 'password', '123 abc st', '222111111', 'Applicant');
INSERT INTO degrees VALUES (1, 12312312, 'BS/BA', 3.00, 'CS', 'GWU', '2023');
INSERT INTO recs VALUES (1, 12312312, NULL, NULL, NULL, 'JT', 'jt@gmail.com', 'professor', 'GWU', 'Great student');
INSERT INTO applications VALUES (1, 12312312, 'complete', 'T', 'MS', 1, NULL, 'FALL', 2023, 'CS TA for Python', 'I love snakes', 1, NULL, NULL);
;
INSERT INTO degrees VALUES (2, 66666666, 'BS/BA', 2.50, 'CS', 'GWU', '2023') ;
INSERT INTO recs VALUES (2, 66666666, NULL, NULL, NULL, 'BC', 'bc@gmail.com', 'professor', 'GWU', NULL);
INSERT INTO applications VALUES (2, 66666666, 'incomplete', 'F', 'MS', 2, NULL, 'Spring', 2024, 'I have all the experience', 'I have zero interests', NULL, NULL, NULL);
