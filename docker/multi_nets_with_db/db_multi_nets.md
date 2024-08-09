## Организация доступа к QuestDB из разных сетей

#### Создание сетей QuestDB и приложений
<br>Приложения могут иметь доступ к QuestDB через разные сети.
<br>Для этого создайте сети QuestDB и приложений
<br>и привяжите их к контейнерам QuestDB и приложений.
<br>Возможен доступ из 1-го приложения к нескольким сетям QuestDB.

#### Пример конфигурации в Docker Compose
```
version: '3.8'

services:
  questdb:
    image: questdb/questdb:latest
    container_name: questdb
    networks:
      - qstdb_network1
      - qstdb_network2
      - qstdb_network3
    ports:
      - "8812:8812"         # Port for QuestDB SQL API
      - "9000:9000"         # Port for QuestDB Web Console
    volumes:
      - questdb_data:/root/.questdb/db

  app1: #--- Application 1: доступ к QuestDB через qstdb_network1
    image: application1:latest
    environment:
      - DATABASE_URL=postgresql://admin:quest@questdb:8812/questdb
    depends_on:
      - questdb
    networks:
      - qstdb_network1
    ports:
      - "8001:8000"        # Port for Application 1

  app2: #--- Application 2: доступ к QuestDB через qstdb_network2
    image: application2:latest
    environment:
      - DATABASE_URL=postgresql://admin:quest@questdb:8812/questdb
    depends_on:
      - questdb    
    networks:
      - qstdb_network2
    ports:
      - "8002:8000"        # Port for Application 2      

  app3: #--- Application 3: доступ к QuestDB через qstdb_network3
    image: application3:latest
    environment:
      - DATABASE_URL=postgresql://admin:quest@questdb:8812/questdb
    depends_on:
      - questdb  
    networks:
      - qstdb_network3
    ports:
      - "8003:8000"        # Port for Application 3

  app4: #--- Application 4: доступ к QuestDB через qstdb_network(1,3)
    image: application4:latest
    environment:
      - DATABASE_URL=postgresql://admin:quest@questdb:8812/questdb
    depends_on:
      - questdb
    networks:
      - qstdb_network1
      - qstdb_network3      
    ports:
      - "8004:8000"        # Port for Application 4

networks:
  qstdb_network1:
  qstdb_network2:
  qstdb_network3:

volumes:
  questdb_data:
```  

#### При этом пусть база расположена по адресу 192.168.1.100
<br>и доступ к ней осуществляется из 3-х приложений.
<br>Приложения могут иметь доступ к QuestDB через разные сети.
<br>И еще можно настроить hosts в файле /etc/hosts в приложении

```
192.168.1.100       questdb
```

- посредством записи *.yml файла
```
version: '3.8'

services:
  ...
  ...
  app3:
    image: application3:latest
    extra_hosts:
      - "questdb:192.168.1.100"
    networks:
      - qstdb_network1
      - qstdb_network3     
  ...
  ...
```

- посредством записи в Doockerfile
```
# Dockerfile

# Используем базовый образ Python 3.9-slim
FROM python:3.9-slim

# Добавляем запись в /etc/hosts
RUN echo "192.168.1.100 questdb" >> /etc/hosts

WORKDIR /app

# Остальные команды для сборки образа
COPY . .

CMD ["python", "app.py"]
```

**_Как использовать обращение к базе из приложения:_**
```
# python
import requests

#--- Запрос на создание таблицы в базе данных QuestDB
response = requests.get("http://192.168.1.100:8812/exec?query=CREATE TABLE my_table (timestamp TIMESTAMP, x DOUBLE, y DOUBLE)")
print(response.text)
```

**_Можно и так:_**  
```
import requests

#--- Запрос на создание таблицы в базе данных QuestDB
response = requests.get("http://www.server.querstdb.on_remoot:8812/exec?query=CREATE TABLE my_table (timestamp TIMESTAMP, x DOUBLE, y DOUBLE)")
print(response.text)

```


