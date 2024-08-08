# SQL-запросы
<br>для ключ-значение и документо-ориентированных СУБД

## 1. Ключ-значение (Key-Value) СУБД

* Redis
* Cassandra (может выступать как ключ-значение)
* Riak
* DynamoDB (Amazon)

### **_Redis_**
<br>Redis — это популярная in-memory key-value СУБД,
<br>поддерживающая структуры: строки, списки, множества и хеши.

**_Установка ключа:_**
```
# shell
SET mykey "Hello"
```

**_Получение значения по ключу:_**
```
# shell
GET mykey
```

**_Удаление ключа:_**
```
# shell
DEL mykey
```

**_Работа с хешами (ключ-значение внутри хеша):_**
```
# shell
HSET user:1000 name "John Doe"
HGET user:1000 name
```

### **_Cassandra (в режиме ключ-значение)_**
<br>Cassandra может использоваться как key-value store,
<br>используя таблицы с одним партиционным ключом.

**_Создание таблицы:_**
```
-- sql
CREATE TABLE kv_store (
    key TEXT PRIMARY KEY,
    value TEXT
);
```

**_Вставка значения:_**
```
-- sql
INSERT INTO kv_store (key, value) VALUES ('mykey', 'Hello');
```

**_Получение значения по ключу:_**
```
-- sql
SELECT value FROM kv_store WHERE key = 'mykey';
```

**_Удаление значения по ключу:_**
```
-- sql
DELETE FROM kv_store WHERE key = 'mykey';
```

## 2. Документо-ориентированные СУБД

* MongoDB
* CouchDB
* RethinkDB
* Couchbase

### **_MongoDB_**
<br>MongoDB — это документо-ориентированная СУБД,
<br>использующая JSON-подобные документы для хранения данных.

**_Создание документа (вставка данных):_**
```
/*javascript*/
db.collection_name.insertOne({
    "name": "John Doe",
    "age": 30,
    "address": {
        "street": "123 Main St",
        "city": "Anytown"
    }
});
```

**_Поиск документа:_**
```
/*javascript*/
db.collection_name.findOne({ "name": "John Doe" });
```

**_Обновление документа:_**
```
/*javascript*/
db.collection_name.updateOne(
    { "name": "John Doe" },
    { $set: { "age": 31 } }
);
```

**_Удаление документа:_**
```
/*javascript*/
db.collection_name.deleteOne({ "name": "John Doe" });
```

**_Создание индекса:_**
```
/*javascript*/
db.collection_name.createIndex({ "name": 1 });
```

### **_CouchDB_**
<br>CouchDB также является документо-ориентированной СУБД,
<br>использующей JSON для хранения данных и HTTP для взаимодействия с базой данных.

**_Создание базы данных:_**
```
# shell
curl -X PUT http://localhost:5984/database_name
```

**_Создание документа:_**
```
# shell
curl -X POST http://localhost:5984/database_name -d '{
    "name": "John Doe",
    "age": 30
}'
```

**_Получение документа по ID:_**
```
# shell
curl http://localhost:5984/database_name/document_id
```

**_Обновление документа:_**
```
# shell
curl -X PUT http://localhost:5984/database_name/document_id -d '{
    "_rev": "revision_id",
    "name": "John Doe",
    "age": 31
}'
```

**_Удаление документа:_**
```
# shell
curl -X DELETE http://localhost:5984/database_name/document_id?rev=revision_id
```

### **_RethinkDB_**
<br>RethinkDB — это документо-ориентированная СУБД с фокусом на реальном времени.

**_Вставка документа:_**
```
/*javascript*/
r.db('test').table('users').insert({
    "name": "John Doe",
    "age": 30
}).run(conn);
```

**_Поиск документа:_**
```
/*javascript*/
r.db('test').table('users').get('document_id').run(conn);
```

**_Обновление документа:_**
```
/*javascript*/
r.db('test').table('users').get('document_id').update({
    "age": 31
}).run(conn);
```

**_Удаление документа:_**
```
/*javascript*/
r.db('test').table('users').get('document_id').delete().run(conn);
```

## Где найти информацию в сжатой форме:
```
    Redis:
        Redis Documentation
        Redis Quick Start           https://redis.io/docs/latest/develop/get-started/

    MongoDB:
        MongoDB Documentation       https://www.mongodb.com/docs/
        MongoDB Quick Start         https://www.mongodb.com/docs/manual/tutorial/getting-started/

    CouchDB:
        CouchDB Documentation       https://couchdb.apache.org/
        CouchDB Quick Start         https://www.tutorialspoint.com/couchdb/couchdb_quick_guide.htm

    RethinkDB:
        RethinkDB Documentation     https://rethinkdb.com/docs
        RethinkDB Quick Start       https://rethinkdb.com/docs/quickstart
```
