**Requirements:
1.Environment Setup
2.Install Docker on your system

**Simple Python Flask application using Docker
1.This application is Python based.
2.Dockeried this application in EC2 Environment.
3.This is a simple Python Flask application 
4.This application displays:
Hello from Docker - Devops Task-8

Flask-app/
|
|--app.py
|--Requirements.txt
|--Dockerfile
|--README.md

- Language:Python
- Framework: Flask
- Containeried using Docker
- Exposes port:5000

**Docker
1.FROM python:3.10-slim
this pulls the base image from dockerhub, it having all dependencies of python , is used to run the Flask application

2.WORKDIR /app
this sets the working directory inside the container

3.COPY requrements.txt .
it copies the dependencies from local Requirements to container working directory app/

4.RUN  pip install --no-cache-dir -r requirements.txt
this command install the dependencies which we have in requirement.txt

5.COPY app.py .
its a source file which we have to display,  copy to app/

6.EXPOSE 5000
This command is used to expose this container by using port 5000

7.CMD ["python", "app.py]"
this command runs when container starts, and runs python app.py 

