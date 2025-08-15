# college-website
In our group project, I led the development of the applications module for the simulated college website, focusing on user management, data organization, and secure interactions. This involved designing and implementing features to handle diverse user roles and ensure robust, compliant functionality. Below is a detailed breakdown of my contributions:
User Role Creation and Data Organization

Defined and Implemented User Roles: I created distinct user roles to support the application's workflow, including:

Applicants: Users submitting college applications, with access to form filling, document uploads, and status tracking.
Recommenders: External users (e.g., teachers or mentors) providing letters of recommendation, with secure, role-specific upload and submission interfaces.
Faculty Reviewers: Academic staff responsible for evaluating applications, granted read/write access to review forms and applicant data.
CAC (Committee for Admissions Coordination): Administrative users overseeing the overall process, with elevated permissions for monitoring, approvals, and reporting.


SQL Database Design and Organization: To manage user data efficiently, I structured the database using SQL (MySQL). This included creating normalized tables for each role, with relationships to separate and link user information (e.g., via foreign keys for applicants linking to recommenders and reviewers). Key tables included users (for core info like ID, name, email), applications (for submission details), degrees (for program specifics), and reviews (for feedback). This setup ensured data integrity, prevented redundancy, and facilitated queries for role-based access control.

Form Validation, Account Creation, and Security Measures

Form Validation for Applications: I implemented comprehensive client-side and server-side validation for application forms using JavaScript (for frontend checks like required fields, email formats, and length limits) and Python Flask (for backend verification to prevent invalid data submission). This included regex patterns for inputs (e.g., phone numbers, dates) and error handling to provide user-friendly feedback, reducing submission errors by ensuring data quality before database entry.
Account Creation Functionality: Developed a secure registration system with role-specific signup flows. Users select their role during signup, triggering automated email verification and password hashing (using libraries like bcrypt). Integrated with SQL to store user profiles in the users table, assigning unique IDs and role enums for authentication.
Security Measures and Bypass Prevention: To safeguard against vulnerabilities, I incorporated measures such as:

Input sanitization and CSRF protection via Flask-WTF.
Role-based access control (RBAC) using session management to prevent unauthorized actions (e.g., applicants can't access reviewer forms).
Bypass prevention through prepared SQL statements to avoid SQL injection, rate limiting on login attempts, and HTTPS enforcement for data transmission.
Additional checks like CAPTCHA for high-risk forms and logging for audit trails.



Review Forms for Faculty Reviewers

Custom Review Forms: Designed and built tailored forms for faculty reviewers, integrated with the applications database. Each form pulled applicant data dynamically (e.g., via SQL joins on applications and reviews tables) and allowed input for ratings, comments, and decisions. Used React for interactive UI elements (e.g., dropdowns for scores, text areas for feedback) and Flask for backend processing, ensuring submissions updated the database securely.
Workflow Integration: Forms included validation (e.g., required fields, score ranges) and notifications (e.g., email alerts to CAC upon completion). This module supported multi-reviewer collaboration, with aggregate scoring logic to compute final recommendations.

This module was crucial for the project's real-time functionalities, demonstrating my skills in full-stack development, database design, and secure application architecture. For the SQL schema diagram, see SQL Table Diagram.

![SQL](https://github.com/user-attachments/assets/74a1e28f-fcdd-4cdf-a442-4e4da00f373f)


To view samples of js code navigate to APPS folder and open static folder
To view samples of html code navigate to APPS folder and open templates folder
To view samples of python code navigate to APPS folder and open main.py file
