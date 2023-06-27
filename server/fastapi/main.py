from fastapi import FastAPI, HTTPException, Response
import startup
import bcrypt;
import logging
from fastapi.middleware.cors import CORSMiddleware
import secrets
import datetime
from user import user_router, initialize_user
from faq import faq_router, initialize_faq

def initializemodules():
    initialize_user(startup.dblink)
    initialize_faq(startup.dblink)

startup.initialize()
initializemodules()
app = FastAPI()



logging.basicConfig(level=logging.DEBUG)
logging.basicConfig(filename='securepath.log', level=logging.DEBUG)
app.include_router(user_router, prefix="/user")
app.include_router(faq_router, prefix="/faq")


# Set up CORS
origins = ["*"]  # Can also set this to a list of allowed origins

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



@app.get("/")
async def root():
    return {"message": "Secure Path is up and running!"}


@app.post("/login/", tags=["Auth"])
async def login(username: str, password: str):
    user = startup.dblink["users"].find_one({"username": username})
    if user:
        # Check if the provided password matches the hashed password in the database
        if bcrypt.checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
            # Generate a secure random token
            session_token = secrets.token_hex(16)

             # Store session token in database or cache
            insertedusername, insertedvaliduntil,insertedsession_token = store_session_token(username, session_token)

            # Return session token in response body
            # response.set_cookie(key="session_token", value=session_token, httponly=True, max_age=1800) # expires in 30 minutes
            
            
            return {"message": "Login successful", "session_token":insertedsession_token, "username":insertedusername, "validuntil": insertedvaliduntil}

    raise HTTPException(status_code=401, detail="Invalid username or password")

def store_session_token(username: str, session_token: str):
    collection = startup.dblink['sessions']
    
    result = collection.insert_one({'username': username, 'session_token': session_token, 'validuntil': (datetime.datetime.now() + datetime.timedelta(days=1)).strftime("%Y-%m-%d %H:%M:%S")})
    insertedDocument =  collection.find_one({ '_id': result.inserted_id })
    return insertedDocument['username'] ,insertedDocument['validuntil'], insertedDocument['session_token'] 

@app.post("/validate_session", tags=["Auth"])
async def protected_resource(username: str , session_token: str):
    if not validate_session_token(username, session_token):
        raise HTTPException(status_code=401, detail="Not authenticated")
    return {"message": "You are authenticated and authorized to access this resource."}

def validate_session_token(username: str, session_token: str) -> bool:
    collection = startup.dblink['sessions']
    document = collection.find_one({'username': username, 'session_token': session_token})
    if document is None:
        return False
    valid_until = datetime.strptime(document['validuntil'], "%Y-%m-%d %H:%M:%S")
    if valid_until < datetime.now():
        collection.delete_one({'_id': document['_id']})
        return False
    return True   

