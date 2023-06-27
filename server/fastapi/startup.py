import configparser;
import pymongo;
import sys
from models import User
import bcrypt;

import datetime;

dblink = None

def getdatabaseconfig():
    config = configparser.ConfigParser()
    config.read('app.config')  
    host = config.get('database', 'host')
    db = config.get('database', 'db')
    port = config.get('database', 'port')
    username = config.get('database', 'username')
    password = config.get('database', 'password')
    return host,db,port,username,password


def dbconnection():
    try:
        host,db,port,username,password = getdatabaseconfig()
        print("Succesfully read database configurations.")

        # Establish a connection to the MongoDB server
        client = pymongo.MongoClient("mongodb://" + host +":" + port +"/")
        print("Succesfully established database connection.")

        # Access a database
        global dblink 
        dblink = client[db]
        
        print("Succesfully connected to database " + db + ".")
        print(dblink)
    
    except Exception as e:
        # print an error message if an exception occurs in the finally block
        print("Something went wrong when trying to connect to the database.")
        print("Error in finally block:", e)
        print("Shuting down the API")
        sys.exit() 

def createadminuser():
    # Check if an admin user already exists in the database
    admin_user = dblink["users"].find_one({"username": "admin"})
    if not admin_user:
        # If no admin user exists, create a new one and insert it into the database
        admin_password = "admin123" # You should generate a strong password here
        hashed_password = bcrypt.hashpw(admin_password.encode('utf-8'), bcrypt.gensalt())
        admin_user = User(username="admin", email="admin@securepath.pt", password=hashed_password.decode('utf-8'), display_name="Administrador", status="Active",last_login= datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        result = dblink["users"].insert_one(admin_user.dict())
        print("Created admin user.")

def initialize():
    dbconnection()
    createadminuser()
    
    
    