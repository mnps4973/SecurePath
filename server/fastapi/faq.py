from fastapi import APIRouter,HTTPException, Response
from startup import dblink;
from typing import List
from pymongo import ASCENDING, TEXT
from bson import ObjectId
from bson.json_util import dumps
from fastapi.responses import JSONResponse
import datetime
from models import FAQ

faq_router = APIRouter()

dblink = None

def initialize_faq(dblinkin):
     global dblink
     dblink=dblinkin
     print("Initialize FAQ Module")
     #create text index on content
 

#faq
@faq_router.get("/", tags=["FAQ"])
async def read_faqs():
    faqs = dblink["faqs"].find()

    json_str = dumps(faqs)
    response = JSONResponse(content=json_str)
    return response

@faq_router.get("/{id}", tags=["FAQ"])
async def read_faq(id: str):
    user = dblink["faqs"].find_one({'_id': ObjectId(id)})
    if user:
        return FAQ(**user)
    else:
        raise HTTPException(status_code=404, detail="FAQ not found")
    
@faq_router.post("/", tags=["FAQ"])
async def create_faq(FAQ_in: FAQ):
    
        if FAQ_in.status == 'Active' or FAQ_in.status == 'Inactive':

                faq_db = FAQ(title=FAQ_in.title, keywords=FAQ_in.keywords,status=FAQ_in.status, content=FAQ_in.content,createdby= FAQ_in.createdby,lastupdatedby=FAQ_in.lastupdatedby, lastupdatedat = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S") ,createdat= datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
                dblink["faqs"].insert_one(faq_db.dict())
                return JSONResponse(content={"message": "Success"}, status_code=200)

        else:
            raise HTTPException(status_code=401, detail="Status value is invalid.")

@faq_router.post("/search", tags=["FAQ"])
async def get_faqs_by_keywords(query: list):
    query = query[0]
    #full text search to see if query matches the content
    print(query)
    faqs_found = dblink["faqs"].find({"$text": {"$search": query}})

    faqs = [x for x in faqs_found]

    # Convert the BSON ObjectIds to strings
    for faq in faqs:
        print("now yeah I'm here")
        faq["_id"] = str(faq["_id"])


    # # Sort the FAQs based on their relevance to the provided keywords
    # faqs = sorted(faqs, key=lambda faq: len(set(keywords).intersection(faq["keywords"].split(";"))), reverse=True)

    # # Convert the BSON ObjectIds to strings
    # for faq in faqs:
    #     faq["_id"] = str(faq["_id"])

    # Return the sorted FAQs as a list
    return list(faqs)




@faq_router.put("/{id}", tags=["FAQ"])
async def update_faq(id: str, faq: FAQ):
    # Check if user exists  
            update_query = {}
            if faq.title:
                update_query['title'] = faq.title
            if faq.keywords:
                update_query['keywords'] = faq.keywords
            if faq.content:
                update_query['content'] = faq.content
            if faq.status:
                update_query['status'] = faq.status
                if faq.status != 'Active' and faq.status != 'Inactive':
                    raise HTTPException(status_code=401, detail="Status value is invalid.")
    
            update_query['lastupdatedby'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            result = dblink["faqs"].update_one(
            {'_id': ObjectId(id)},
            {"$set": update_query})

            if result.modified_count == 1:
                return JSONResponse(content={"message": "FAQ updated successfully."}, status_code=200)
            else:
                return {"message": "unable to update FAQ"}
    

@faq_router.delete("/{id}", tags=["FAQ"])
async def delete_faq(id: str):
    # check if user exists
    if dblink["faqs"].count_documents({'_id': ObjectId(id)}) == 0:
        return {"error": "User not found"}

    # delete user
    result = dblink["faqs"].delete_one({'_id': ObjectId(id)})
    if result.deleted_count == 1:
        return {"message": "FAQ deleted successfully"}
    else:
        return {"error": "Failed to delete FAQ"}
    

