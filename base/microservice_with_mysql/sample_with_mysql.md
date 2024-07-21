## Пример работы с MySQL в микросервисах

Рассмотрим пример микросервисной архитектуры с использованием Docker и MySQL, аналогичный предыдущему примеру с PostgreSQL.

1. **Создание Docker-сети**

Создайте пользовательскую Docker-сеть для взаимодействия контейнеров:
```
sh

docker network create my_network
```

2. **Создание контейнера MySQL**

Запустите контейнер MySQL:
```
sh

docker run --name my_mysql --network my_network -e MYSQL_ROOT_PASSWORD=mysecretpassword -e MYSQL_DATABASE=mydatabase -d mysql:8.0
```

3. **Создание генератора данных**

Создайте Dockerfile для генератора данных:
```
Dockerfile

# DataGenerator/Dockerfile
FROM python:3.9-alpine

RUN pip install mysql-connector-python

COPY data_generator.py /data_generator.py

CMD ["python", "/data_generator.py"]
```

4. **Создайте скрипт генерации данных:**
```
python

# DataGenerator/data_generator.py
import mysql.connector
import time

def create_table():
    conn = mysql.connector.connect(
        host="my_mysql",
        user="root",
        password="mysecretpassword",
        database="mydatabase"
    )
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS mytable (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100),
            age INT
        );
    """)
    conn.commit()
    cursor.close()
    conn.close()

def insert_data():
    conn = mysql.connector.connect(
        host="my_mysql",
        user="root",
        password="mysecretpassword",
        database="mydatabase"
    )
    cursor = conn.cursor()
    cursor.execute("INSERT INTO mytable (name, age) VALUES ('Alice', 30);")
    cursor.execute("INSERT INTO mytable (name, age) VALUES ('Bob', 25);")
    conn.commit()
    cursor.close()
    conn.close()

if __name__ == "__main__":
    time.sleep(10)  # Wait for MySQL to be ready
    create_table()
    insert_data()
```

5. **Соберите и запустите контейнер:**
```
sh

cd DataGenerator
docker build -t data_generator .
docker run --name data_generator --network my_network data_generator
```

4. **Создание пользователя базы данных**

Создайте Dockerfile для пользователя базы данных:
```
Dockerfile

# DataUser/Dockerfile
FROM python:3.9-alpine

RUN pip install mysql-connector-python

COPY data_user.py /data_user.py

CMD ["python", "/data_user.py"]
```

5. **Создайте скрипт пользователя базы данных:**
```
python

# DataUser/data_user.py
import mysql.connector
import time

def fetch_data():
    conn = mysql.connector.connect(
        host="my_mysql",
        user="root",
        password="mysecretpassword",
        database="mydatabase"
    )
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM mytable;")
    rows = cursor.fetchall()
    for row in rows:
        print(row)
    cursor.close()
    conn.close()

if __name__ == "__main__":
    time.sleep(10)  # Wait for MySQL to be ready
    fetch_data()
```

6. **Соберите и запустите контейнер:**
```
sh

cd DataUser
docker build -t data_user .
docker run --name data_user --network my_network data_user
```

7. **Вывод**

MySQL и PostgreSQL имеют свои преимущества и недостатки. MySQL может быть проще в настройке и использоваться в случаях, где важна скорость чтения данных. PostgreSQL предлагает более мощные функции и лучше подходит для сложных операций с данными. Выбор между ними зависит от конкретных требований вашего проекта и задач, которые нужно решать.

В представленном примере показано, как использовать MySQL в микросервисной архитектуре с Docker, что аналогично работе с PostgreSQL. Вы можете выбрать базу данных в зависимости от своих предпочтений и требований к проекту.

