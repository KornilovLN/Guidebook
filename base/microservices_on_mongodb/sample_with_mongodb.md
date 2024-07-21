## Настроить микросервисную архитектуру с использованием Docker для MongoDB:

_Включает генератор данных, базу данных и потребителя данных._

### Шаги

1. **Создание Docker-сетей**

Создайте две пользовательские Docker-сети для изолирования взаимодействия контейнеров:
```
sh

docker network create net_gen_db
docker network create net_db_user
``

2. **Создание контейнера MongoDB**

Запустите контейнер MongoDB и подключите его к обеим сетям:
```
sh

docker run --name my_mongo --network net_gen_db --network-alias mongo_gen --network net_db_user --network-alias mongo_user -d mongo:latest
```

3. **Создание генератора данных**

Создайте Dockerfile для генератора данных:
```
Dockerfile

# DataGenerator/Dockerfile
FROM python:3.9-alpine

RUN pip install pymongo

COPY data_generator.py /data_generator.py

CMD ["python", "/data_generator.py"]
```

4. **Создайте скрипт генерации данных:**
```
python

# DataGenerator/data_generator.py
import pymongo
import time
from datetime import datetime
import random

def generate_data():
    client = pymongo.MongoClient("mongodb://mongo_gen:27017/")
    db = client["mydatabase"]
    collection = db["mycollection"]
    while True:
        x_value = random.randint(1, 100)
        y_value = x_value * 2  # Example computation
        data = {
            "x": x_value,
            "y": y_value,
            "timestamp": datetime.utcnow()
        }
        collection.insert_one(data)
        print(f"Inserted data: {data}")
        time.sleep(5)

if __name__ == "__main__":
    time.sleep(10)  # Wait for MongoDB to be ready
    generate_data()
```

5. **Соберите и запустите контейнер:**
```
sh

cd DataGenerator
docker build -t data_generator .
docker run --name data_generator --network net_gen_db data_generator
```

6. **Создание потребителя данных**

Создайте Dockerfile для потребителя данных:
```
Dockerfile

# DataUser/Dockerfile
FROM python:3.9-alpine

RUN pip install pymongo

COPY data_user.py /data_user.py

CMD ["python", "/data_user.py"]
```

7. **Создайте скрипт потребления данных:**
```
python

# DataUser/data_user.py
import pymongo
import time

def fetch_data():
    client = pymongo.MongoClient("mongodb://mongo_user:27017/")
    db = client["mydatabase"]
    collection = db["mycollection"]
    while True:
        for record in collection.find().sort("timestamp"):
            print(record)
        time.sleep(3)

if __name__ == "__main__":
    time.sleep(10)  # Wait for MongoDB to be ready
    fetch_data()
```

8. **Соберите и запустите контейнер:**
```
sh

cd DataUser
docker build -t data_user .
docker run --name data_user --network net_db_user data_user
```

9. **Вывод**

В результате выполнения вышеуказанных шагов,
контейнер data_generator будет генерировать данные каждые 5 секунд и отправлять их в MongoDB.
Контейнер data_user будет считывать данные из MongoDB каждые 3 секунды и выводить их в терминал.

MongoDB, благодаря своей гибкости и простоте использования, особенно в сценариях с JSON-подобными данными,
действительно может быть удобным выбором для такой задачи.
Docker позволяет легко управлять сетью и изоляцией контейнеров,
что упрощает настройку и поддержку таких микросервисов.
