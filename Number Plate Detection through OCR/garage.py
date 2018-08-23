import MySQLdb
from interpret import txt
if txt:
    db = MySQLdb.connect(host="localhost",    # your host, usually localhost
                     user="root",         # your username
                     passwd="",  # your password
                     db="garage")
    cur = db.cursor()
    cur.execute("select customer_id from vehicle where car_no=%s",(txt,))
    row =cur.fetchall();
    if row:
        try:
            cur.execute("insert into works_on_vehicle(customer_id,car_no) values(%s, %s)",(row[0][0],txt,))
            print('Successfully registered complaint')
        except (MySQLdb.Error) as e:
            print(e)
    else:
        try:
            cur.execute("insert into vehicle(car_no) values(%s)",(txt,))
            print('Record registered, please specify customer id in datbase')
        except (MySQLdb.Error) as e:
            print(e)
    db.commit()
    db.close()
else:
    print('Can''t detect number, please insert manually')
    
