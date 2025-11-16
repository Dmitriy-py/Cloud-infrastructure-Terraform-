from flask import Flask
import os
import pymysql

app = Flask(__name__)

DB_HOST = os.environ.get('DB_HOST', 'localhost')
DB_USER = os.environ.get('DB_USER', 'app_user')
DB_PASSWORD = os.environ.get('DB_PASSWORD', 'password')
DB_NAME = os.environ.get('DB_NAME', 'app_database')

@app.route('/')
def index():
    try:
        conn = pymysql.connect(host=DB_HOST, user=DB_USER, password=DB_PASSWORD, database=DB_NAME)
        conn.close()
        status = "Успешно подключено к MySQL!"
    except Exception as e:
        status = f"Ошибка подключения к MySQL: {e}"
    
    return f"<h1>Статус приложения: Запущено</h1><p>{status}</p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)