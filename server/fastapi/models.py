from pydantic import BaseModel

class FAQ(BaseModel):
    title: str = None
    content: str = None
    keywords: str = None
    status: str = None
    createdat: str = None
    createdby: str = None
    lastupdatedat: str = None
    lastupdatedby: str = None

class User(BaseModel):
    username: str
    password: str
    display_name: str
    email: str
    status: str
    last_login: str

class UserInput(BaseModel):
    username: str = None
    password: str = None
    password_confirm: str = None
    display_name: str = None
    email: str = None
    status: str = None
    