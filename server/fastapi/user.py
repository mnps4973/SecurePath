from fastapi import APIRouter,HTTPException, Response
from bson.json_util import dumps
from fastapi.responses import JSONResponse
import datetime
from models import User,UserInput

user_router = APIRouter()

dblink = None

def initialize_user(dblinkin):
     global dblink
     dblink=dblinkin
     print("Initialize User Module")

#user
@user_router.get("/", tags=["User"])
async def read_users():
    users = dblink["users"].find()

    json_str = dumps(users)
    response = JSONResponse(content=json_str)
    return response

@user_router.get("/{username}", tags=["User"])
async def read_user(username: str):
    user = dblink["users"].find_one({"username": username})
    if user:
        return User(**user)
    else:
        raise HTTPException(status_code=404, detail="User not found")
    
@user_router.post("/", tags=["User"])
async def create_user(user: UserInput):
    
    existing_user = dblink["users"].find_one({"username": user.username})
    if existing_user:
        raise HTTPException(status_code=403, detail={"message": "Username already taken."})
    else:
        if user.status == 'Active' or user.status == 'Inactive':
            if user.password == user.password_confirm:
                hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
                user.password = hashed_password.decode('utf-8')
                user_db = User(username=user.username, email=user.email, password=user.password, display_name=user.display_name, status=user.status,last_login= datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),createdby= datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),lastupdatedby= datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
                dblink["users"].insert_one(user_db.dict())
                return JSONResponse(content={"message": "Success"}, status_code=200)
            else:
                raise HTTPException(status_code=401, detail="Your passwords don't match.")
        else:
            raise HTTPException(status_code=401, detail="Status value is invalid.")

@user_router.put("/{username}", tags=["User"])
async def update_user(username: str, user: UserInput):
    # Check if user exists  
        print("entered")
        existing_user = dblink["users"].find_one({"username": user.username})
        if existing_user and username != user.username:
            raise HTTPException(status_code=403, detail={"message": "Username already taken."})
        else:
            update_query = {}
            if user.username:
                update_query['username'] = user.username
            if user.email:
                update_query['email'] = user.email
            if user.password:
                if user.password == user.password_confirm:
                    hashed_password = bcrypt.hashpw(user.password.encode('utf-8'), bcrypt.gensalt())
                    user.password = hashed_password.decode('utf-8')
                    update_query['password'] = hashed_password
                else:
                    raise HTTPException(status_code=401, detail="Your passwords don't match.")
            if user.display_name:
                update_query['display_name'] = user.display_name
            if user.status:
                update_query['status'] = user.display_name
                if user.status != 'Active' and user.status != 'Inactive':
                    raise HTTPException(status_code=401, detail="Status value is invalid.")
    
            update_query['lastupdatedby'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            result = dblink["users"].update_one(
            {"username": username},
            {"$set": update_query})

            if result.modified_count == 1:
                return JSONResponse(content={"message": "User updated successfully."}, status_code=200)
            else:
                return {"message": "unable to update user"}
    

@user_router.delete("/{username}", tags=["User"])
async def delete_user(username: str):
    # check if user exists
    if dblink["users"].count_documents({"username": username}) == 0:
        return {"error": "User not found"}

    # delete user
    result = dblink["users"].delete_one({"username": username})
    if result.deleted_count == 1:
        return {"message": "User deleted successfully"}
    else:
        return {"error": "Failed to delete user"}
