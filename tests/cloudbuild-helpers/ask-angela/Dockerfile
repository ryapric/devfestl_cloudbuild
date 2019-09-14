FROM python:3.7-buster

WORKDIR /root

COPY main.py main.py
COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

CMD ["python3", "main.py"]
