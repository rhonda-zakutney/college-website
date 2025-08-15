from flask import Flask, session, render_template, redirect, url_for, request
import mysql.connector
from datetime import timedelta, datetime

app = Flask('app')
app.secret_key = "classified"
app.permanent_session_lifetime = timedelta(minutes=5)

mydb = mysql.connector.connect( 
    host="apps7.cbguogqvf5db.us-east-1.rds.amazonaws.com",
    user="admin",
    password="groupsev",
    database="university"
)

@app.route('/', methods=['GET', 'POST'])
def login():
  # Login and create session variables
  if request.method == 'POST':
    email = request.form["email"]
    password = request.form.get("password")
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT * FROM users")
    users = cur.fetchall()

    for user in users:
      if user['email'] == email and user['password'] == password:
        session['email'] = email
        session['password'] = password
        session['type'] = user['type']
        return redirect('/home')
      
    #if you are a recommender
    email = request.form["email"]
    cur.execute("SELECT email FROM recs")
    recs = cur.fetchall()
    for rec in recs:
      if rec['email'] == email:
        session['email'] = email
        #check if already sent email
        cur.execute("SELECT message FROM recs WHERE email = (%s)", (session['email'],))
        msg = cur.fetchone()
        if msg:
          msg = msg['message']
        #gather applicant info
        cur.execute("SELECT uid FROM recs WHERE email = (%s)", (session['email'],))
        uid = cur.fetchone()['uid']
        cur.execute("SELECT fname, lname FROM users WHERE uid = (%s)", (uid,))
        name = cur.fetchone()
        return render_template('writeletter.html', email=email, msg=msg, name=name)

    return redirect('/')
  return render_template('login.html')

#Create account 
@app.route('/create_account', methods=['GET', 'POST'])
def create_account():
  user_types = ['Admin', 'Applicant', 'GS', 'CAC', 'Reviewer']
  #enter into database
  if request.method == 'POST':
    email = request.form['email']
    passw = request.form['password']
    fname = request.form['firstname']
    lname = request.form['lastname']
    address = request.form['address']
    ssn = request.form['ssn']
    is_type = request.form.get('user_type') 
    if not is_type:
      is_type = 'Applicant'
    cur = mydb.cursor(dictionary=True)
    #dup protection
    cur.execute("SELECT email FROM users")
    e = cur.fetchall()
    for em in e:
      if em['email'] == email:
        return render_template('create_account.html', error='Email in use')
    cur.execute("SELECT ssn FROM users")
    s = cur.fetchall()
    for sn in s:
      if sn['ssn'] == ssn:
        return render_template('create_account.html', error='SSN in use')
    cur.execute("INSERT INTO users (fname, lname, email, password, address, ssn, type) VALUES (%s,%s,%s,%s,%s,%s,%s)", (fname, lname, email, passw, address, ssn, is_type,))
    mydb.commit()
    return render_template('login.html')
  
  return render_template('create_account.html', user_types=user_types)

@app.route('/home', methods=['GET', 'POST'])
def home():
  if not session or len(session) == 1:
    return redirect('/')
  #Specific homepage for user type
  #if applicant, gather if it has a past application
  if session['type'] == 'Applicant':
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT uid FROM users WHERE email = (%s)", (session['email'],))
    uid = cur.fetchone()['uid']
    cur.execute("SELECT * FROM applications WHERE uid = (%s)", (uid,))
    app = cur.fetchone()
    cur.execute("SELECT message FROM recs WHERE uid = (%s)", (uid,))
    sent = cur.fetchone()
    if sent:
      sent = sent['message']
    return render_template("home.html", app=app, sent=sent)
  #if admin
  if session['type'] == 'Admin':
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT * FROM users")
    cur_users = cur.fetchall()
    return render_template("home.html", cur_users=cur_users)
  #if GS
  if session['type'] == "GS":
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT uid FROM users WHERE email = %s", (session['email'],))
    uid = cur.fetchone()['uid']
    cur.execute("SELECT * FROM applications")
    app = cur.fetchall()
    return render_template("home.html", app=app)
 #if CAC
  if session['type'] == "CAC":
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT * FROM applications WHERE review > 0 and status = 'complete'")
    app = cur.fetchall()
    return render_template("home.html", app=app)
  #if reviewer
  if session['type'] == "Reviewer":
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT * FROM applications left join users on users.uid = applications.uid WHERE status = 'complete' ORDER BY users.ssn")
    apps = cur.fetchall()
    validapp = []
    
    cur.execute("SELECT uid FROM users WHERE email = (%s)", (session['email'],))
    uid = cur.fetchone()['uid']
    #print(uid)
    for app in apps:
      cur.execute("Select * from reviews where reviewer_id=(%s) and uid=(%s)", (str(uid), str(app["uid"])))
      row = cur.fetchone()
      if row:
        continue
      validapp.append(app)
    #print(apps)
    return render_template("home.html", app=validapp)
  return redirect('/')

@app.route('/logout', methods=['GET', 'POST'])
def logout():
  if not session or len(session) == 1:
    return redirect('/')
  # Log the user out and redirect them to the login page
  session.clear()
  return redirect('/')

@app.route('/remove_user/<id>', methods=['GET', 'POST'])
def remove_user(id):
  cur = mydb.cursor(dictionary=True)
  cur.execute("DELETE FROM applications WHERE uid = (%s)", (id,))
  cur.execute("DELETE FROM degrees WHERE uid = (%s)", (id,))
  cur.execute("DELETE FROM gres WHERE uid = (%s)", (id,))
  cur.execute("DELETE FROM recs WHERE uid = (%s)", (id,))
  cur.execute("DELETE FROM reviews WHERE uid = (%s)", (id,))
  cur.execute("DELETE FROM users WHERE uid = (%s)", (id,))
  mydb.commit()
  return redirect('/home')

@app.route('/user_page/<id>', methods=['GET', 'POST'])
def user_page(id):
  if not session or len(session) == 1:
    return redirect('/')
  user_types = ['Admin', 'Applicant', 'GS', 'CAC', 'Reviewer']
  cur = mydb.cursor(dictionary=True)
  cur.execute("SELECT * FROM users WHERE uid = (%s)", (id,))
  cur_user = cur.fetchone()
  if request.method == 'POST':
    cur = mydb.cursor(dictionary=True)
    email = request.form['email']
    passw = request.form['password']
    fname = request.form['firstname']
    lname = request.form['lastname']
    address = request.form['address']
    ssn = request.form['ssn']
    is_type = request.form.get('user_type') 
    remove = request.form['remove']
    cur = mydb.cursor(dictionary=True)
    if email != '':
      cur.execute("UPDATE users SET email = (%s) WHERE uid = (%s)", (email, id,))
      mydb.commit()
    elif passw != '':
      cur.execute("UPDATE users SET password = (%s) WHERE uid = (%s)", (passw, id,))
      mydb.commit()
    elif fname != '':
      cur.execute("UPDATE users SET fname = (%s) WHERE uid = (%s)", (fname, id,))
      mydb.commit()
    elif lname != '':
      cur.execute("UPDATE users SET lname = (%s) WHERE uid = (%s)", (lname, id,))
      mydb.commit()
    elif address != '':
      cur.execute("UPDATE users SET address = (%s) WHERE uid = (%s)", (address, id,))
      mydb.commit()
    elif ssn != '':
      cur.execute("UPDATE users SET ssn = (%s) WHERE uid = (%s)", (ssn, id,))
      mydb.commit()
    '''elif is_type != '':
      cur.execute("UPDATE users SET type = (%s) WHERE uid = (%s)", (is_type, id,))'''
    mydb.commit()
    return redirect('/home')

  return render_template("user_page.html", user_types=user_types, cur_user=cur_user, id=id)

@app.route('/view_apps/<id>', methods=['GET', 'POST'])
def view_apps(id):
  if not session or len(session) == 1:
    return redirect('/')
  cur = mydb.cursor(dictionary=True)
  cur.execute("SELECT * FROM applications WHERE uid = (%s)", (id,))
  app = cur.fetchone()
  cur.execute("SELECT * FROM recs WHERE uid = (%s)", (id,))
  rec = cur.fetchone()
  cur.execute("SELECT * FROM degrees WHERE uid = (%s)", (id,))
  deg = cur.fetchall()
  past_d1 = deg[0]
  past_d2 = None
  if len(deg) > 1:
    past_d2 = deg[1]
  status_types = ['incomplete', 'complete', 'admitted', 'denied']
  transcript_types = ['F', 'T']
  if request.method == 'POST':
    is_type = request.form.get('status_type')
    if not is_type:
      is_type = 'incomplete'
    transcript_type = request.form.get('transcript_type')
    cur.execute("UPDATE applications SET status = (%s) WHERE uid= (%s)", (is_type, id,))
    cur.execute("UPDATE applications SET transcript = (%s) WHERE uid = (%s)", (transcript_type, id,))
    mydb.commit()
    return redirect('/home')
  return render_template("view_apps.html", past_d1=past_d1, past_d2=past_d2, rec=rec, app=app, status_types=status_types, transcript_types=transcript_types)

#application
@app.route('/application', methods=['GET', 'POST'])
def application():
  if not session or len(session) == 1:
    return redirect('/')
  if request.method == 'POST':
    if session['type'] == 'Reviewer':
      cur = mydb.cursor(dictionary=True)
      userid = request.form.get('reviewapp')
      cur.execute("SELECT * FROM users WHERE uid=(%s)", (userid,))
      user = cur.fetchone()

      cur.execute("SELECT * FROM applications WHERE uid=(%s)", (userid, ))
      app = cur.fetchone()

      cur.execute("SELECT * FROM degrees WHERE degid=(%s)", (app['past_d1'], ))
      degrees = []
      degree1 = cur.fetchone()
      degrees.append(degree1)

      if app['past_d2']:
        cur.execute("SELECT * FROM degrees WHERE degid=(%s)", (app['past_d2'],))
        degree2 = cur.fetchone()
        degrees.append(degree2)

      cur.execute("SELECT * FROM gres WHERE greid=(%s)", (app['gre'],))
      gre = cur.fetchone()

      cur.execute("Select * From recs WHERE recid = (%s)", (app['letter'],))
      recs = cur.fetchall()
      # letterids = []
      # if app['letter_1']:
      #   letterids.append(app['letter_1'])
      # if app['letter_2']:
      #   letterids.append(app['letter_2'])
      # if app['letter_3']:
      #   letterids.append(app['letter_3'])
      # letters = []
      # for letterid in letterids:
      #   cur.execute("SELECT * FROM recs WHERE recid=(%s)", (letterid,))
      #   letters.append(cur.fetchone())
      return render_template("application.html", form="review", user=user, app=app, degrees=degrees, gre=gre, recs = recs )
    if session['type'] == 'CAC':
      cur = mydb.cursor(dictionary=True)
      userid = request.form.get('decideapp')
      cur.execute("SELECT * FROM reviews WHERE uid=(%s)", (userid,))
      reviews = cur.fetchall()
      cur.execute("SELECT * FROM applications WHERE uid=(%s)", (userid,))
      app = cur.fetchone()
      cur.execute("SELECT * FROM users WHERE uid=(%s)", (userid,))
      user = cur.fetchone()
      cur.execute("SELECT AVG(rating) as review_avg FROM reviews WHERE uid=(%s)", (userid,))
      review_avg = cur.fetchone()['review_avg']
      return render_template("decide_cac.html", reviews=reviews, app=app, user=user, review_avg=review_avg)
    cur = mydb.cursor(dictionary=True)
    create = request.form.get('createapp') 
    view = request.form.get('viewapp') 
    send = request.form.get('sendrec')
    cur.execute("SELECT uid FROM users WHERE email = (%s)", (session['email'],))
    uid = cur.fetchone()['uid']
    #create application
    if create:
      cur.execute("SELECT * FROM users WHERE email = (%s)", (session['email'],))
      data = cur.fetchone()
      return render_template('application.html', form=create, data=data, year=datetime.now().year)

    #view application
    elif view:
      cur.execute("SELECT * FROM applications WHERE uid = (%s)", (uid,))
      app = cur.fetchone()
      cur.execute("SELECT * FROM gres WHERE uid = (%s)", (uid,))
      gre = cur.fetchone()
      cur.execute("SELECT writer, message FROM recs WHERE uid = (%s)", (uid,))
      rec = cur.fetchone()
      return render_template('application.html', form=view, app=app, gre=gre, rec=rec)
    
    elif send:
      cur.execute("SELECT writer, email FROM recs WHERE uid = (%s)", (uid,))
      rec = cur.fetchone()
      return render_template('application.html', form=send, rec=rec)

  return render_template('application.html')

@app.route('/review_application', methods=['POST'])
def review_application():
  if not session or len(session) == 1:
    return redirect('/')
  uid = request.form.get("user_id")
  rating = request.form.get("review_rating")
  deficiency = request.form.get("review_deficiency")
  reason = request.form.get("review_reason")
  advisor = request.form.get("review_advisor")
  comments = request.form.get("review_comments")

  cur = mydb.cursor(dictionary=True)
  cur.execute("SELECT email FROM users WHERE NOT type = (%s)", ('Applicant',))
  e = cur.fetchall()

  x = None
  for a in e:
    if a['email'] == advisor:
      x = 'yes'
  if not x:
    return render_template("application.html", error='incorrect advisor email')

  cur.execute("SELECT uid FROM users WHERE email = (%s)", (session['email'],))
  review_id = cur.fetchone()['uid']
  cur.execute("INSERT INTO reviews (uid, rating, deficiency, reason, advisor, comments, reviewer_id) VALUES ((%s),(%s),(%s),(%s),(%s),(%s),(%s))",
              (uid, rating, deficiency, reason, advisor, comments, review_id))
  insertId = cur.lastrowid
  # cur.execute("SELECT review FROM applications WHERE uid = (%s)", (str(uid), ))
  # reiview_cnt = cur.fetchone()['review']
  # if not reiview_cnt:
  #   reiview_cnt = 1
  # else:
  #   reiview_cnt += 1
  cur.execute("update applications set review = " + str(insertId) + " where uid = (%s)", (str(uid), ))

  mydb.commit()
  #add recs table
  appid = request.form.get("app_id")
  cur.execute("SELECT uid From recs where uid = (%s)", (str(uid), ))
  curApp = cur.fetchone()['uid']
  rec_r = request.form.get("rec_rating_1")
  rec_g = request.form.get("rec_generic_1")
  rec_c = request.form.get("rec_credible_1")
  cur.execute("update recs set rating=(%s), generic=(%s),credible=(%s) where uid = (%s)", (str(rec_r),rec_g,rec_c,str(uid)))
  mydb.commit()
  return redirect(url_for('home'))

@app.route('/decide_application', methods=['POST'])
def decide_final():
  if not session or len(session) == 1:
    return redirect('/')
  status = request.form.get("decide_final")
  appid = request.form.get("app_id")
  cur = mydb.cursor(dictionary=True)
  cur.execute("update applications set status = (%s) where appid = (%s)", (status, appid,))
  mydb.commit()
  return redirect(url_for('home'))


@app.route('/thankyou', methods=['GET', 'POST'])
def thankyou():
  if not session or len(session) == 1:
    return redirect('/')
  if request.method == 'POST':
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT uid FROM users WHERE email = (%s)", (session['email'],))
    uid = cur.fetchone()['uid']
    #gre 
    gre = None
    total = request.form.get('total')
    score = request.form.get('score')
    toefl = request.form.get('toefl')
    if total: 
      verbal = int(request.form['verbal'])
      quant = int(request.form['quant'])
      total = int(request.form['total'])
      year = int(request.form['yearexam'])
      cur.execute("SELECT greid FROM gres WHERE uid = (%s)", (uid,))
      gre = cur.fetchone()
      if gre:
        cur.execute("UPDATE gres SET (total, verbal, quant, year) WHERE uid = (%s)", (total, verbal, quant, year, uid))
        mydb.commit()
      else:
        cur.execute("INSERT INTO gres (uid, total, verbal, quant, year) VALUES (%s,%s,%s,%s,%s)", (uid, total, verbal, quant, year))
        mydb.commit()
    if score:
      score = int(request.form['score'])
      subject = request.form['subject']
      cur.execute("SELECT greid FROM gres WHERE uid = (%s)", (uid,))
      gre = cur.fetchone()
      if gre:
        cur.execute("UPDATE gres SET score=(%s), subject=(%s) WHERE uid = (%s)", (score, subject, uid)) 
        mydb.commit()
      else:
        cur.execute("INSERT INTO gres (uid, score, subject) VALUES (%s,%s,%s)", (uid, score, subject,))
        mydb.commit()
    if toefl: 
      toefl = int(request.form['toefl'])
      date = int(request.form['dateexam'])
      cur.execute("SELECT greid FROM gres WHERE uid = (%s)", (uid,))
      gre = cur.fetchone()
      if gre:
        cur.execute("UPDATE gres SET toefl=(%s), date=(%s) WHERE uid = (%s)", (score, date, uid)) 
        mydb.commit()
      else:
        cur.execute("INSERT INTO gres (uid, toefl, date) VALUES (%s,%s,%s)", (uid, score, date,))
        mydb.commit()
    cur.execute("SELECT greid FROM gres WHERE uid = (%s)", (uid,))
    gre = cur.fetchone()
    if gre:
      gre = gre['greid']
    #past degrees
    d_type = request.form.get('ms')
    if d_type:
      gpa = float(request.form['gpa'])
      major = request.form['major']
      college = request.form['university']
      year = int(request.form['pdyear'])
      cur.execute("SELECT greid FROM gres WHERE uid = (%s)", (uid,))
      gre = cur.fetchone()['greid']
      cur.execute("INSERT INTO degrees (uid, type, gpa, major, college, year) VALUES (%s,%s,%s,%s,%s,%s)", (uid, d_type, gpa, major, college, year))
      mydb.commit()
    d_type = request.form['bsba']
    gpa = float(request.form['gpa2'])
    major = request.form['major2']
    college = request.form['university2']
    year = int(request.form['pdyear2'])
    cur.execute("INSERT INTO degrees (uid, type, gpa, major, college, year) VALUES (%s,%s,%s,%s,%s,%s)", (uid, d_type, gpa, major, college, year))
    mydb.commit()
    #letter
    writer = request.form['writer']
    email = request.form['email']
    title = request.form['title']
    affiliation = request.form['affiliation']
    #dup protection
    cur.execute("SELECT email FROM recs")
    e = cur.fetchall()
    for em in e:
      if em['email'] == email:
        return render_template('application.html', error='Recommender email in use')
    cur.execute("INSERT INTO recs (uid, writer, email, title, affiliation) VALUES (%s,%s,%s,%s,%s)", (uid, writer, email, title, affiliation))
    mydb.commit()
    #app
    status = 'incomplete'
    transcript = 'F'
    degree = request.form.get('degree')
    semester = request.form.get('semester')
    year = int(request.form.get('year'))
    experience = request.form['exp']
    aoi = request.form['aoi']
    cur.execute("SELECT degid FROM degrees WHERE uid = (%s)", (uid,))
    pdegrees = cur.fetchall()
    past_d1 = pdegrees[0]['degid']
    past_d2 = None
    if len(pdegrees) > 1:
      past_d2 = pdegrees[1]['degid']
    cur.execute("SELECT recid FROM recs WHERE uid = (%s)", (uid,))
    letter = cur.fetchone()['recid']
    cur.execute("INSERT INTO applications (uid, status, transcript, degree, past_d1, past_d2, semester, year, experience, aoi, letter, gre) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", (uid, status, transcript, degree, past_d1, past_d2, semester, year, experience, aoi, letter, gre))
    mydb.commit()
    return render_template('thankyou.html')
  
  return redirect('/')

#Recommender write to applicant
@app.route('/letterwriter', methods=['GET', 'POST'])
def letterwriter():
  if not session or len(session) == 1:
    return redirect('/')
  if request.method == 'POST':
    send = 'sent'
    email = request.form['lettermail']
    message = request.form['lettermessage']
    return render_template('application.html', form=send, msg=message, email=email)

  return redirect('/home')

#Write to recommender
@app.route('/writeletter', methods=['GET', 'POST'])
def writeletter():
  if not session or len(session) > 1:
    return redirect('/')
  if request.method == 'POST':
    #add into database
    message = request.form['lettermsg']
    cur = mydb.cursor(dictionary=True)
    cur.execute("SELECT uid FROM recs WHERE email = (%s)", (session['email'],))
    uid = cur.fetchone()['uid']
    cur.execute("SELECT recid FROM recs WHERE uid = (%s)", (uid,))
    recid = cur.fetchone()['recid']
    cur.execute("UPDATE recs SET message = (%s) WHERE recid = (%s)", (message, recid))
    mydb.commit()
    return render_template('writeletter.html', msg=message)
  
  return render_template('writeletter.html', email=None)
  

@app.route('/reset', methods=['GET', 'POST'])
def reset():
  cur = mydb.cursor(dictionary=True)
  cur.execute("DROP TABLE IF EXISTS applications")
  cur.execute("DROP TABLE IF EXISTS degrees")
  cur.execute("DROP TABLE IF EXISTS reviews")
  cur.execute("DROP TABLE IF EXISTS recs")
  cur.execute("DROP TABLE IF EXISTS gres")
  cur.execute("DROP TABLE IF EXISTS users")
  cur.execute("CREATE TABLE users (uid int(8) AUTO_INCREMENT NOT NULL UNIQUE, fname varchar(50) NOT NULL, lname varchar(50) NOT NULL, email varchar(50) NOT NULL UNIQUE, password varchar(50) NOT NULL, address varchar(100) NOT NULL, ssn char(9) NOT NULL UNIQUE,  type enum('Admin', 'Applicant', 'GS', 'CAC', 'Reviewer') NOT NULL, PRIMARY KEY (uid))")
  cur.execute("CREATE TABLE degrees (degid int(5) AUTO_INCREMENT NOT NULL UNIQUE, uid int(8) NOT NULL, type enum('BS/BA', 'MS') NOT NULL, gpa decimal(3,2) NOT NULL, major varchar(50) NOT NULL, college varchar(50) NOT NULL, year int(4) NOT NULL, PRIMARY KEY (degid), FOREIGN KEY (uid) REFERENCES users(uid))")
  cur.execute("CREATE TABLE reviews (revid int(5) AUTO_INCREMENT NOT NULL UNIQUE, uid int(8) NOT NULL, rating ENUM('0','1','2','3') NOT NULL, deficiency varchar(100), reason char(1) NOT NULL, advisor varchar(30), comments varchar(40), reviewer_id int(8) NOT NULL, PRIMARY KEY (revid), FOREIGN KEY (uid) REFERENCES users(uid), FOREIGN KEY (reviewer_id) REFERENCES users(uid))")
  cur.execute("CREATE TABLE recs (recid int(5) AUTO_INCREMENT NOT NULL UNIQUE, uid int(8) NOT NULL, rating ENUM('1','2','3','4','5'), generic ENUM('y','n'), credible ENUM('y','n'), writer varchar(30) NOT NULL, email varchar(50) NOT NULL UNIQUE, title varchar(30) NOT NULL, affiliation varchar(30) NOT NULL, message varchar(200) DEFAULT NULL, PRIMARY KEY (recid), FOREIGN KEY(uid) REFERENCES users(uid))")
  cur.execute("CREATE TABLE gres (greid int(5) AUTO_INCREMENT NOT NULL UNIQUE, uid int(8) NOT NULL UNIQUE, total int(3) DEFAULT NULL, verbal int(3) DEFAULT NULL, quant int(3) DEFAULT NULL, year int(4) DEFAULT NULL, toefl int(3) DEFAULT NULL, score int(3) DEFAULT NULL, subject varchar(30) DEFAULT NULL, date int(4) DEFAULT NULL, PRIMARY KEY (greid), FOREIGN KEY (uid) REFERENCES users(uid))")
  cur.execute("CREATE TABLE applications (appid int(5) AUTO_INCREMENT NOT NULL UNIQUE, uid int(8) NOT NULL UNIQUE, status enum('incomplete', 'complete', 'admitted', 'denied') NOT NULL, transcript  enum('T', 'F') NOT NULL, degree enum('MS', 'PhD') NOT NULL, past_d1 int(5) NOT NULL, past_d2 int(5) DEFAULT NULL, semester enum('Fall', 'Spring') NOT NULL, year int(4) NOT NULL, experience  varchar(300) NOT NULL, aoi varchar(300) NOT NULL, letter int(5) DEFAULT NULL, review int(5) DEFAULT NULL, gre int(5) DEFAULT NULL, PRIMARY KEY (appid), FOREIGN KEY (past_d1) REFERENCES degrees(degid), FOREIGN KEY (past_d2) REFERENCES degrees(degid), FOREIGN KEY (letter) REFERENCES recs(recid), FOREIGN KEY (review) REFERENCES reviews(revid), FOREIGN KEY (gre) REFERENCES gres(greid), FOREIGN KEY (uid) REFERENCES users(uid))")
  cur.execute("INSERT INTO users VALUES (1,'admin', 'admminlname', 'admin@gmail.com', 'password', '123 abc st', '123456789', 'Admin')")
  cur.execute("INSERT INTO users VALUES (2,'gs', 'gslname', 'gs@gmail.com', 'password', '123 abc st', '123456788', 'GS')")
  cur.execute("INSERT INTO users VALUES (3,'cac', 'caclname', 'cac@gmail.com', 'password', '123 abc st', '123456780', 'CAC')")
  cur.execute("INSERT INTO users VALUES (4,'narahari', 'naraharilname', 'narahari@gmail.com', 'password', '123 abc st', '123456799', 'Reviewer')")
  cur.execute("INSERT INTO users VALUES (5,'wood', 'woodlname', 'wood@gmail.com', 'password', '123 abc st', '123426799', 'Reviewer')")
  cur.execute("INSERT INTO users VALUES (6,'heller', 'hellerlname', 'heller@gmail.com', 'password', '123 abc st', '123856799', 'Reviewer')")
  cur.execute("INSERT INTO users VALUES (12312312,'John', 'Lennon', 'john@gmail.com', 'password', '123 abc st', '111111111', 'Applicant')")
  cur.execute("INSERT INTO users VALUES (66666666,'Ringo', 'Starr', 'ringo@gmail.com', 'password', '123 abc st', '222111111', 'Applicant')")
  cur.execute("INSERT INTO degrees VALUES (1, 12312312, 'BS/BA', 3.00, 'CS', 'GWU', '2023')")
  cur.execute("INSERT INTO recs VALUES (1, 12312312, NULL, NULL, NULL, 'JT', 'jt@gmail.com', 'professor', 'GWU', 'Great student')")
  cur.execute("INSERT INTO applications VALUES (1, 12312312, 'complete', 'T', 'MS', 1, NULL, 'FALL', 2023, 'CS TA for Python', 'I love snakes', 1, NULL, NULL)")
  cur.execute("INSERT INTO degrees VALUES (2, 66666666, 'BS/BA', 2.50, 'CS', 'GWU', '2023')")
  cur.execute("INSERT INTO recs VALUES (2, 66666666, NULL, NULL, NULL, 'BC', 'bc@gmail.com', 'professor', 'GWU', NULL)")
  cur.execute("INSERT INTO applications VALUES (2, 66666666, 'incomplete', 'F', 'MS', 2, NULL, 'Spring', 2024, 'I have all the experience', 'I have zero interests', NULL, NULL, NULL)")

  mydb.commit()
  session.clear()
  return redirect('/')

app.run(host='0.0.0.0', port=3306)