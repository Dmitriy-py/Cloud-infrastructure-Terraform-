FROM python:3.9 AS builder
 HEAD

WORKDIR /app

WORKDIR /app
bcf78197abceb08d5c70ffc1fc592f3180689d28
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*
 HEAD

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

FROM python:3.9-slim

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages


COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
bcf78197abceb08d5c70ffc1fc592f3180689d28
COPY app.py .

EXPOSE 5000
HEAD

CMD ["python", "app.py"]
CMD ["python", "app.py"]
bcf78197abceb08d5c70ffc1fc592f3180689d28
