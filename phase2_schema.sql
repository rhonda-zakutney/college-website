-- Active: 1683144494144@@phase2-group10-2.cowwwnz3vubj.us-east-1.rds.amazonaws.com@3306@university

DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS degrees;
DROP TABLE IF EXISTS c_schedule;
DROP TABLE IF EXISTS c_history;
DROP TABLE IF EXISTS c_catalogue;
DROP TABLE IF EXISTS recs;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS gres;
DROP TABLE IF EXISTS applications;
DROP TABLE IF EXISTS form1answer;
DROP TABLE IF EXISTS degree_requirements;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS student_advisors;
DROP TABLE IF EXISTS grad_application;
DROP TABLE IF EXISTS need_advisor;
DROP TABLE IF EXISTS alumni;
DROP TABLE IF EXISTS student_status;
DROP TABLE IF EXISTS phd_req;
DROP TABLE IF EXISTS applied_grad;
DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS degrees_only;
CREATE TABLE degrees_only (
	degree_id int(2) not null PRIMARY KEY,
	degree_name  varchar(50) not null
);

DROP TABLE IF EXISTS user_type;
CREATE TABLE user_type (
  id int(1) NOT NULL PRIMARY KEY,
  name varchar(50) NOT NULL
);

-- make user_type a view
-- create view user_type as select uid as id , type as name from users;
-- consider using foreign keys
DROP TABLE IF EXISTS suspension_check;
CREATE TABLE suspension_check (
  grade_check varchar(50) not null
);

CREATE TABLE users (
    uid         int(10) AUTO_INCREMENT NOT NULL UNIQUE,
    fname       varchar(50) NOT NULL,
    lname       varchar(50) NOT NULL,
    email       varchar(50) NOT NULL UNIQUE,
    password    varchar(50) NOT NULL,
    address     varchar(100) NOT NULL,
    ssn         char(10) NOT NULL UNIQUE,
    type        int(1) NOT NULL,
	program VARCHAR(10),
	username varchar(50) NOT NULL,
	phone varchar(50),
    PRIMARY KEY (uid)
);

CREATE TABLE degrees (
    degid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(10) NOT NULL,
    type        enum('BS/BA', 'MS', 'PhD') NOT NULL,
    gpa         decimal(3,2) NOT NULL, 
    major       varchar(50) NOT NULL,
    college     varchar(50) NOT NULL,
    year        int(4) NOT NULL,
    PRIMARY KEY (degid),
    FOREIGN KEY (uid) REFERENCES users(uid)
);

CREATE TABLE
c_catalogue  (
        cid INT(8) not null,
        dept varchar(10), 
        cnum INT(4) , 
        title VARCHAR(100), 
        sem VARCHAR(20), 
        year VARCHAR(4), 
        cred INT(8), 
        prone VARCHAR(10), 
        prtwo VARCHAR(10), 
        cap INT(8) , 
        loc VARCHAR(50), 
        snum INT(10) not null,
        PRIMARY KEY(cid),
        FOREIGN KEY(snum) REFERENCES users(uid) 
    );

create or replace view courses AS
   SELECT cid as id, dept as dept_name, cnum as course_num, title as course_name, cred as credit_hours from c_catalogue;

CREATE TABLE
    c_schedule (
        cid INT(8) not null,
        day varchar(5) not null,
        time varchar(50) not null,
        FOREIGN KEY(cid) REFERENCES c_catalogue(cid)
    );

CREATE TABLE c_history (
    uid INT(10) not null,
    cid INT(8) not null,
    fgrade VARCHAR(8),
    sem VARCHAR(10) not null,
    year VARCHAR(4),
    snum INT(10) not null,

    FOREIGN KEY(uid) REFERENCES users(uid),
    FOREIGN KEY(cid) REFERENCES c_catalogue(cid),
    FOREIGN KEY(snum) REFERENCES users(uid)
);
create or replace view student_courses AS
    select cid as course_id, uid as student_id, fgrade as grade from c_history;
    
CREATE TABLE recs (
    recid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(10) NOT NULL,
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

CREATE TABLE reviews (
    revid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(10) NOT NULL,
    rating      ENUM('0','1','2','3') NOT NULL,
    deficiency  varchar(100),
    reason      char(1) NOT NULL,
    advisor     varchar(30),
    comments    varchar(40),
    reviewer_id int(10) NOT NULL,
    PRIMARY KEY (revid),
    FOREIGN KEY (uid) REFERENCES users(uid),
    FOREIGN KEY (reviewer_id) REFERENCES users(uid)
);


CREATE TABLE gres (
    greid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(10) NOT NULL UNIQUE,
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


CREATE TABLE applications (
    appid       int(5) AUTO_INCREMENT NOT NULL UNIQUE,
    uid         int(10) NOT NULL UNIQUE,
	--reviewer/gs id -- 
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

CREATE TABLE degree_requirements (
  degree_type int(4) not null,
  course_req varchar(50) not null, 
  GPA_req varchar(3) not null, 
  credit_hours int(3) not null, 
  other_req varchar(50) not null
);


CREATE TABLE student_advisors (
	studentID int(10) not NULL,
	advisorID int(10) not NULL,
	FOREIGN KEY (studentID) REFERENCES users(uid),
 	FOREIGN KEY (advisorID) REFERENCES users(uid)
);

CREATE TABLE alumni (
	student_id int(10) NOT NULL,
	degree_id int(2) NOT NULL,
	grad_year int(4) NOT NULL,
	FOREIGN KEY (student_id) REFERENCES users(uid)
);


CREATE TABLE students (
	student_id int(10) NOT NULL,
	degree_id int(2) NOT NULL,
  FOREIGN KEY (student_id) REFERENCES users(uid)
);
-- needs a primary key maybe student degree ? 



CREATE TABLE grad_application (
	gs_id  varchar(50) NOT NULL,
	app_status  varchar(50) NOT NULL,
	student_id int(10) NOT NULL,
	remarks varchar(50),
	FOREIGN KEY (student_id) REFERENCES users(uid)
);


CREATE TABLE student_status (
	student_id int(10) NOT NULL,
  	status varchar(50) NOT NULL,
   FOREIGN KEY (student_id) REFERENCES users(uid)
);


CREATE TABLE phd_req (
	student_id int(10) NOT NULL PRIMARY KEY,
	thesisapproved varchar(5) NOT NULL
);

CREATE TABLE need_advisor (
	student_id int(10) NOT NULL
);

CREATE TABLE applied_grad (
	student_id int(10) NOT NULL,
	dtype int(2) NOT NULL
);


CREATE TABLE form1answer (
  student_id int(10) NOT NULL,
  courseID int(3) NOT NULL
);
insert into degrees_only values (20000, 'MS Degree');
insert into degrees_only values (21000, 'PhD Degree');

insert into user_type values (0, 'Systems Administrator');

insert into user_type values (1, 'Faculty Advisor');

insert into user_type values (2, 'Alumni');

insert into user_type values (3, 'Graduate Secretary');

insert into user_type values (4, 'MS Graduate Student');

insert into user_type values (5, 'PhD Student');

INSERT INTO user_type values (6, "CAC");
INSERT INTO user_type values (7, "Faculty Reviewer");
INSERT INTO user_type values (8, "Faculty Instructor");
INSERT INTO user_type values (9, "Applicant");

insert into degree_requirements values (20, 'completed the courses: CSCI 6212, CSCI 6221, and CSCI 6461', '3.0', 30, 'Taken at most 2 courses outside the CS department as part of the 30 credit hours of coursework
&	No more than 2 grades below B');
insert into degree_requirements values (21, 'no required core courses', '3.5', 36, 'Taken at least 30 credits in CS, Not more than one grade below B & Pass thesis defense – approved by the advisor');

insert into suspension_check values ('can not have three grades below B');



#Users
INSERT INTO users VALUES (1, "Test", "Admin", "admin@gmail.com", "testpass", "Test Street", "0000000000", 0, null, "admin", "0000000001");
INSERT INTO users VALUES (10000001, "Test", "Applicant", "app@gmail.com", "testpass", "Test Street", "0000000001", 9, null, "app", "0000000002");
INSERT INTO users VALUES (10000002, "Test", "PHD Student", "gradstudent@gmail.com", "testpass", "Test Street", "0000000002", 5, "PHD", "testuser1", "0000000003");
INSERT INTO users VALUES (10000003, "Test", "Instructor", "instructor@gmail.com", "testpass", "Test Street", "0000000003",8, null, "instructor", "0000000004");
INSERT INTO users VALUES (10000005, "Test", "Reviewer", "reviewer@gmail.com", "testpass", "Test Street", "0000000005", 7, null, "reviewer", "0000000005" );
INSERT INTO users VALUES (10000006, "Test", "ApplicantTest", "applicant@gmail.com", "testpass", "Test Street", "0000000006", 9, null, "applicant", "0000000006" );
INSERT INTO users VALUES (10000007, "Test", "CAC", "cac@gmail.com", "testpass", "Test Street", "0000000007", 6, null, "cac", "0000000007" );
INSERT INTO users VALUES (10000008, "Test", "Advisor", "advisor@gmail.com", "testpass", "Test Street", "0000000008", 1, null, "advisor", "0000000008" );
INSERT INTO users VALUES (10000009, "Test", "GS", "gs@gmail.com", "testpass", "Test Street", "0000000009", 3, null, "gs", "0000000009" );
INSERT INTO users VALUES (10000010, "Test", "Alumni", "alumni@gmail.com", "testpass", "Test Street", "0000000010", 2, null, "alumni", "0000000010" );
INSERT INTO users VALUES (10000011, "Test", "MS", "ms@gmail.com", "testpass", "Test Street", "0000000011", 4, null, "masters", "0000000011" );

#ADS starting data
insert into users values (00000000, 'Systems', 'Administrator', "administrator@gmail.com", "testpass", "Test Street", "0000000012", 0, null, "administrator", "0000000012");
insert into users values (55555555, 'Paul', 'McCartney', 'pcartney@gmail.com', 'tfaghk015', '2001 G St NW, Washington, DC 20052', '1234567890' , 4, 'Masters', 'pcartney', '2029951001');

insert into users values (66666666, 'George', 'Harrison', 'gharrison@gmail.com', 'ptlhik990', '2003 K St NW, Washington, DC 20052', '9873234540', 4, 'Masters', 'gharrison','2029551100');

insert into users values (99999999, 'Ringo', 'Starr', 'rstarr@gmail.com', 'tplgik245', '2002 H St NW, Washington, DC 20052', '2221111110', 5, 'PhD', 'rstarr', '2029551000');

insert into users values (77777777, 'Eric', 'Clapton', 'eclapton@gmail.com', 'jkjfd098', '2031 G St NW, Washington, DC 20052', '3331212320', 2, null, 'eclapton', '2022221000' );

insert into users values(33333338, 'Emilia', 'Schmidt', 'semilia@gmail.com', 'jkoplkfd03', '1290 U St NW, Washington, DC 20052','1248698340', 3, null, 'semilia', '2022221000');

insert into users values (11111114,'Bhagirath', 'Narahari', 'bhagi@gmail.com', 'jkjfd098', '2031 G St NW, Washington, DC 20052','3422392330', 1, null, 'bhagi', '2022221000');

insert into users values (11111112,'Professor', 'Choi', 'choi@gmail.com', 'testpass', '2031 G St NW, Washington, DC 20052','3422392334', 8, null, 'choi', '2022221000');

insert into users values (22222224, 'Gabriel', 'Parmer', 'gparmer@gmail.com', 'uofd0932', '2033 L St NW, Washington, DC 20052', '2313423430', 1, null, 'gparmer', '2022221000' );

insert into users values (88888888, 'Billie', 'Holiday', 'bholiday@gmail.com', 'testpass', '2033 L St NW, Washington, DC 20052', '2313423431', 4, "Masters", 'bholiday', '2022221000' );

insert into users values (99999998, 'Diana', 'Krall', 'dkrall@gmail.com', 'testpass', '2033 L St NW, Washington, DC 20052', '2313423432', 4, "Masters", 'dkrall', '2022221000' );

insert into users values (12312312, 'John', 'Lennon', 'johnlennon@gmail.com', 'testpass', '2033 L St NW, Washington, DC 20052', '111111111', 9, null, 'johnlennon', '2022221001' );

insert into users values (123456789, 'Ringo2', 'Starr', 'ringo2@gmail.com', 'testpass', '2033 L St NW, Washington, DC 20052', '222111111', 9, null, 'ringo2', '2022221003' );
insert into users values (98374098, 'Heller', 'Wood', 'heller@gmail.com', 'testpass', '2033 L St NW, Washington, DC 20052', '98374098', 7, null, 'heller', '2022221008' );
INSERT INTO users VALUES (102938475, "Narahari2", "Reviewer", "narahari2@gmail.com", "testpass", "Test Street", "102938475", 7, null, "narahari2", "2028374950" );
insert into students values (55555555, 20000);
insert into students values (55555555, 20000);
insert into students values (66666666, 20000);
insert into students values (99999999, 21000);
insert into students values (66666666, 20000);

-- REGS DATA
insert into students values (88888888, 20000);
insert into students values (99999998, 20000);

insert into phd_req values(99999999, 'False');


-- REGS DATA
insert into student_advisors values(88888888, 11111114);
insert into student_advisors values(99999998, 11111114);


insert into student_advisors values(55555555, 11111114);
insert into student_advisors values(66666666, 22222224);
insert into student_advisors values(99999999, 22222224);
INSERT INTO c_catalogue
VALUES (1, 'CSCI', 6221, "SW Paradigms", "F", "2023", 3, null, null,50,"GEL",10000003);
INSERT INTO c_catalogue
VALUES (2,'CSCI',6461,"Computer Architecture", "F", "2023", 3, null, null, 50, "TOMP",10000003 );
INSERT INTO c_catalogue
VALUES (3,'CSCI',6212,"Algorithms","F","2023",3,null,null,50,"GEL",11111112);
INSERT INTO c_catalogue
VALUES (4,'CSCI',6220,"Machine Learning","F","2023",3,null,null,50,"TOMP",10000003);
INSERT INTO c_catalogue
VALUES (5,'CSCI',6232,"Networks 1","F","2023",3,null,null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (6,'CSCI',6233,"Networks 2","F","2023",3,"CSCI 6232",null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (7,'CSCI',6241,"Database 1","F","2023",3,null,null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (8,'CSCI',6242,"Database 2","F","2023",3,"CSCI 6241",null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (9,'CSCI',6246,"Compilers","F","2023",3,"CSCI 6461","CSCI 6212",50,"TOMP",10000003);
INSERT INTO c_catalogue
VALUES (10,'CSCI',6260,"Multimedia","F","2023",3,null,null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (11,'CSCI',6251,"Cloud Computing","F","2023",3,"CSCI 6461",null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (12,'CSCI',6254,"SW Engineering","F","2023",3,"CSCI 6221",null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (13,'CSCI',6262,"Graphics 1","F","2023",3,null,null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (14,'CSCI',6283,"Security 1","F","2023",3,"CSCI 6212",null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (15,'CSCI',6284,"Cryptography","F","2023",3,"CSCI 6212",null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (16,'CSCI',6286,"Network Security","F","2023",3,"CSCI 6283","CSCI 6232",50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (17,'CSCI',6325,"Algorithms 2","F","2023",3,"CSCI 6212",null,50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (18,'CSCI',6461,"Embedded Systems","F","2023",3,"CSCI 6461","CSCI 6212",50,"SEH",10000003);
INSERT INTO c_catalogue
VALUES (19,'CSCI',6384,"Cryptography 2","F","2023",3,"CSCI 6241",null,50,"TOMP",10000003);
INSERT INTO c_catalogue
VALUES (20,'ECE',6241,"Communication Theory","F","2023",3,null,null,50,"TOMP",10000003);
INSERT INTO c_catalogue
VALUES (21,'ECE',6242,"Information Theory","F","2023",3,null,null,50,"GEL",10000003);
INSERT INTO c_catalogue
VALUES (22,'MATH',6210,"Logic","F","2023",3,null,null,50,"GEL",10000003);


INSERT INTO c_schedule VALUES ( 1, 'M', "1500-1730" );
INSERT INTO c_schedule VALUES ( 2, 'T', "1500-1730" );
INSERT INTO c_schedule VALUES ( 3, 'W', "1500-1730" );
INSERT INTO c_schedule VALUES ( 4, 'M', "1800-2030" );
INSERT INTO c_schedule VALUES ( 5, 'T', "1800-2030" );
INSERT INTO c_schedule VALUES ( 6, 'W', "1800-2030" );
INSERT INTO c_schedule VALUES ( 7, 'W', "1800-2030" );
INSERT INTO c_schedule VALUES ( 8, 'R', "1800-2030" );
INSERT INTO c_schedule VALUES ( 9, 'T', "1500-1730" );
INSERT INTO c_schedule VALUES ( 10, 'M', "1800-2030" );
INSERT INTO c_schedule VALUES ( 11, 'M', "1530-1800" );
INSERT INTO c_schedule VALUES ( 12, 'R', "1800-2030" );
INSERT INTO c_schedule VALUES ( 13, 'W', "1800-2030" );
INSERT INTO c_schedule VALUES ( 14, 'T', "1800-2030" );
INSERT INTO c_schedule VALUES ( 15, 'M', "1800-2030" );
INSERT INTO c_schedule VALUES ( 16, 'W', "1800-2030" );
INSERT INTO c_schedule VALUES ( 17, 'W', "1500-1730" );
INSERT INTO c_schedule VALUES ( 18, 'M', "1800-2030" );
INSERT INTO c_schedule VALUES ( 19, 'T', "1800-2030" );
INSERT INTO c_schedule VALUES ( 20, 'W', "1800-2030" );
INSERT INTO c_schedule VALUES ( 21, 'R', "1600-1830" );
INSERT INTO c_schedule VALUES ( 22, 'T', "1600-1830" );

insert into c_history values(55555555, 1, 'A', "F","2023", 10000003);
insert into c_history values(55555555, 3, 'A', "F","2023", 11111112);
insert into c_history values(55555555, 2 , 'A', "F","2023", 10000003 );
insert into c_history values(55555555, 5, 'A', "F","2023", 10000003);
insert into c_history values(55555555, 6, 'A', "F","2023", 10000003);
insert into c_history values(55555555, 7, 'B', "F","2023", 10000003);
insert into c_history values(55555555, 9, 'B', "F","2023", 10000003);
insert into c_history values(55555555, 13, 'B', "F","2023", 10000003);
insert into c_history values(55555555, 14, 'B', "F","2023", 10000003);
insert into c_history values(55555555, 8, 'B', "F","2023", 10000003);

insert into c_history values(66666666, 21, 'C', "F","2023", 10000003);
insert into c_history values(66666666, 1, 'B', "F","2023", 10000003);
insert into c_history values(66666666, 2, 'B', "F","2023", 10000003 );
insert into c_history values(66666666, 3, 'B', "F","2023", 11111112);
insert into c_history values(66666666, 5, 'B', "F","2023", 10000003);
insert into c_history values(66666666, 6, 'B', "F","2023", 10000003);
insert into c_history values(66666666, 7, 'B', "F","2023", 10000003);
insert into c_history values(66666666, 8, 'B', "F","2023", 10000003);
insert into c_history values(66666666, 14, 'B', "F","2023", 10000003);
insert into c_history values(66666666, 15, 'B', "F","2023", 10000003);

insert into c_history values(99999999, 1, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 3, 'A', "F","2023", 11111112);
insert into c_history values(99999999, 4, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 6, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 7, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 8, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 11, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 12, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 13, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 16, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 17, 'A', "F","2023", 10000003);
insert into c_history values(99999999, 18, 'A', "F","2023", 10000003);

insert into c_history values(77777777, 1, 'B', "F","2023", 10000003);
insert into c_history values(77777777, 3, 'B', "F","2023", 11111112);
insert into c_history values(77777777, 2, 'B', "F","2023", 10000003 );
insert into c_history values(77777777, 5, 'B', "F","2023", 10000003);
insert into c_history values(77777777, 6, 'B', "F","2023", 10000003);
insert into c_history values(77777777, 7, 'B', "F","2023", 10000003);
insert into c_history values(77777777, 8, 'B', "F","2023", 10000003);
insert into c_history values(77777777, 14, 'A', "F","2023", 10000003);
insert into c_history values(77777777, 15, 'A', "F","2023", 10000003);
insert into c_history values(77777777, 16, 'A', "F","2023", 10000003);

-- REGS DATA
insert into c_history values(88888888, 2, 'IP', "F","2023", 10000003);
insert into c_history values(88888888, 3, 'IP', "F","2023", 11111112);


