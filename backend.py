from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sqlalchemy import create_engine, Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import openai
import datetime

# Initialize FastAPI and Database
app = FastAPI()
DATABASE_URL = "sqlite:///./test.db"  # Example database URL; use PostgreSQL for production
engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Define the interaction table schema
class Interaction(Base):
    __tablename__ = "interactions"
    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    question_id = Column(String, index=True)
    response = Column(String)

Base.metadata.create_all(bind=engine)

# Input models for grading and logging interactions
class GradeRequest(BaseModel):
    question_text: str
    marking_criteria: str
    marks_allocation: int
    student_response: str

@app.post("/gradeAnswer")
async def grade_answer(request: GradeRequest):
    try:
        # Define ChatGPT prompt
        prompt = f"""
        You are an expert teacher who is marking student answers...
        Question: {request.question_text}
        Number of marks: {request.marks_allocation}
        The student has provided the following answer: {request.student_response}
        The following marking guide has been used: {request.marking_criteria}
        """
        
        # ChatGPT API call
        response = openai.Completion.create(
            model="text-davinci-003",
            prompt=prompt,
            max_tokens=200,
            temperature=0.5
        )
        
        # Parse response and return
        grading_feedback = response.choices[0].text.strip()
        return {"feedback": grading_feedback}
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/storeInteraction")
async def store_interaction(question_id: str, response: str):
    db = SessionLocal()
    new_interaction = Interaction(question_id=question_id, response=response)
    db.add(new_interaction)
    db.commit()
    db.refresh(new_interaction)
    return {"interaction_id": new_interaction.id}
