from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
# from fastapi.testclient import TestClient
import requests

# Initialize FastAPI app
app = FastAPI()

# API key and URL for OpenAI (replace "your_api_key" with an actual API key if testing live)
API_KEY = "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"
OPENAI_URL = "https://api.openai.com/v1/chat/completions"

# Define input model
class GradeRequest(BaseModel):
    question_text: str
    marking_criteria: str
    marks_allocation: int
    student_response: str

# Define the API endpoint without database dependency
@app.post("/gradeAnswer")
async def grade_answer(request: GradeRequest):
    try:
        # Prepare the request payload
        payload = {
            "model": "gpt-3.5-turbo",
            "messages": [
                {"role": "system", "content": "You are an expert teacher evaluating student answers."},
                {"role": "user", "content": f"Question: {request.question_text}\nMarks: {request.marks_allocation}\nStudent Answer: {request.student_response}\nMarking Guide: {request.marking_criteria}"}
            ],
            "temperature": 1.0
        }
        
        headers = {
            "Content-Type": "application/json",
            "Authorization": f"Bearer {API_KEY}"
        }

        # Make the API call to OpenAI
        response = requests.post(OPENAI_URL, headers=headers, json=payload)
        print(response.json())
        if response.status_code == 200:
            grading_feedback = response.json()['choices'][0]['message']['content']
            return {"feedback": grading_feedback}
        else:
            raise HTTPException(status_code=response.status_code, detail="Failed to get response from OpenAI API.")
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Testing the API endpoint within the notebook using TestClient
# client = TestClient(app)

# Define a sample request with the specific question and answer
sample_request = {
    "question_text": "Who was the first black president of South Africa?",
    "marking_criteria": "Correct answer: Nelson Mandela",
    "marks_allocation": 1,
    "student_response": "Nelson Mandela"
}

# Send the test request and print the response
# response = client.post("/gradeAnswer", json=sample_request)
# print(response.json())
