## Установка PostgreSQL

### 1. Если PostgreSQL еще не установлен, сначала установите его:

Ubuntu / Debian
```
sh

sudo apt update
sudo apt install postgresql postgresql-contrib
```

CentOS / RHEL
```
sh

sudo yum install postgresql-server postgresql-contrib
sudo postgresql-setup initdb
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### 2. Запуск psql

Для работы с PostgreSQL из командной строки используется утилита psql.
Чтобы войти в консоль psql, выполните следующую команду:
```
sh

sudo -u postgres psql
```

### 3. Основные команды psql

3.1 **Создание базы данных**
```
sql

CREATE DATABASE mydatabase;
```

3.2 **Подключение к базе данных**
```
sh

\c mydatabase
```

3.3 **Создание таблицы**
```
sql

CREATE TABLE mytable (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT
);
```

3.4 **Вставка данных в таблицу**
```
sql

INSERT INTO mytable (name, age) VALUES ('Alice', 30);
INSERT INTO mytable (name, age) VALUES ('Bob', 25);
```

3.5 **Чтение данных из таблицы**
```
sql

SELECT * FROM mytable;
```

3.6 **Обновление данных в таблице**
```
sql

UPDATE mytable SET age = 31 WHERE name = 'Alice';
```

3.7 **Удаление данных из таблицы**
```
sql

DELETE FROM mytable WHERE name = 'Bob';
```

3.8 **Удаление таблицы**
```
sql

DROP TABLE mytable;
```

### 4. Дополнительные команды psql

4.1 **Просмотр списка баз данных**
```
sh

\l
```

4.2 **Просмотр списка таблиц**
```
sh

\d
```

4.3 **Просмотр структуры таблицы**
```
sh

\d mytable
```

4.6 **Выход из psql**
```
sh

\q
```

### 5. Полезные советы

    В psql можно использовать команду \? для получения справки по встроенным командам.
    Для выполнения SQL-запроса из файла используйте команду \i filename.sql.
    Используйте стрелки вверх/вниз для навигации по истории команд.

Пример сценария работы

5.1 **Подключитесь к psql:**
```
    sh

sudo -u postgres psql
```

5.2 **Создайте новую базу данных:**
```
sql

CREATE DATABASE testdb;
```

5.3 **Подключитесь к базе данных:**
```
sh

\c testdb
```

5.4 **Создайте таблицу:**
```
sql

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL
);
```

5.5 **Вставьте данные в таблицу:**
```
sql

INSERT INTO users (username, email) VALUES ('user1', 'user1@example.com');
INSERT INTO users (username, email) VALUES ('user2', 'user2@example.com');
```

5.6 **Выполните запрос для получения данных:**
```
sql

    SELECT * FROM users;
```

Эти шаги покрывают основные операции, необходимые для работы с PostgreSQL из командной строки.
