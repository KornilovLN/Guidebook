## Пример использования Docker для создания взаимодействующих сервисов

Ниже представлен пример создания двух Docker-контейнеров: 
    * один для генерации данных и записи их в базу данных PostgreSQL,
    * Второй для чтения данных из базы и вывода их в консоль.

Шаги

### 1 Создание Docker-сети

   Создайте пользовательскую Docker-сеть для взаимодействия контейнеров:
```
    sh

docker network create my_network
```

### 2  Создание контейнера PostgreSQL

    Запустите контейнер PostgreSQL:
```
sh

docker run --name my_postgres --network my_network -e POSTGRES_PASSWORD=mysecretpassword -d postgres:alpine
```

### 3 Создание генератора данных

    Создайте Dockerfile для генератора данных:
```
Dockerfile

# DataGenerator/Dockerfile
FROM python:3.9-alpine

RUN pip install psycopg2-binary

COPY data_generator.py /data_generator.py

CMD ["python", "/data_generator.py"]
```

### 4 Создайте скрипт генерации данных:
```
python

# DataGenerator/data_generator.py
import psycopg2
import time

def create_table():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="mysecretpassword",
        host="my_postgres"
    )
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS mytable (
            id SERIAL PRIMARY KEY,
            name VARCHAR(100),
            age INT
        );
    """)
    conn.commit()
    cur.close()
    conn.close()

def insert_data():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="mysecretpassword",
        host="my_postgres"
    )
    cur = conn.cursor()
    cur.execute("INSERT INTO mytable (name, age) VALUES ('Alice', 30);")
    cur.execute("INSERT INTO mytable (name, age) VALUES ('Bob', 25);")
    conn.commit()
    cur.close()
    conn.close()

if __name__ == "__main__":
    time.sleep(10)  # Wait for PostgreSQL to be ready
    create_table()
    insert_data()
```

### 5 Соберите и запустите контейнер:
```
sh

cd DataGenerator
docker build -t data_generator .
docker run --name data_generator --network my_network data_generator
```

### 6 Создание пользователя базы данных

    Создайте Dockerfile для пользователя базы данных:
```
Dockerfile

# DataUser/Dockerfile
FROM python:3.9-alpine

RUN pip install psycopg2-binary

COPY data_user.py /data_user.py

CMD ["python", "/data_user.py"]
```

### 7 Создайте скрипт пользователя базы данных:
```
python

# DataUser/data_user.py
import psycopg2
import time

def fetch_data():
    conn = psycopg2.connect(
        dbname="postgres",
        user="postgres",
        password="mysecretpassword",
        host="my_postgres"
    )
    cur = conn.cursor()
    cur.execute("SELECT * FROM mytable;")
    rows = cur.fetchall()
    for row in rows:
        print(row)
    cur.close()
    conn.close()

if __name__ == "__main__":
    time.sleep(10)  # Wait for PostgreSQL to be ready
    fetch_data()
```

### 8 Соберите и запустите контейнер:
```
sh

    cd DataUser
    docker build -t data_user .
    docker run --name data_user --network my_network data_user
```

### 9 Результат

В результате выполнения вышеуказанных шагов, контейнер data_generator создаст таблицу в базе данных и добавит несколько записей.
Контейнер data_user подключится к базе данных, прочитает данные из таблицы и выведет их в консоль.

### 10 Примечание

    Убедитесь, что вы установили Docker на своей машине.
    Вы можете настроить более сложные сценарии
    с использованием Docker Compose для упрощения управления контейнерами и их взаимодействиями.

    Этот пример демонстрирует базовые принципы работы с Docker для создания и взаимодействия
    сервисов, используя легковесные контейнеры PostgreSQL.
