## Начало работы с Docker. Часть четвертая
#### Заимствовано:         https://tokmakov.msk.ru/blog/item/488    18.03.2020


Когда контейнер под названием app запускается, docker-compose автоматически связывает порты, указанные в директиве ports. Вместо того, чтобы указывать опцию -p 8080:80 в командной строке, как мы делали ранее, теперь указываем директиву ports в файле конфигурации и docker-compose делает это за нас.

С docker-compose.yml мы переносим все параметры, ранее записываемые в командной строке при запуске контейнера в конфигурационный YAML файл. Сделаем так, чтобы вместо перестроения образа при изменении файлов проекта, мы сможем изменять файлы на основной системе. А контейнер будет видеть эти изменения и сразу реагировать на них. Для этого примонтируем нашу рабочую директорию в контейнер.
```
$ nano Dockerfile  
```
```
#Образ с DockerHub, включает Apache и PHP
FROM php:7.2-apache
#Сообщаем, какие порты контейнера слушать
EXPOSE 80
```
```  
$ nano docker-compose.yml  
```
```
version: '3'
services:
  app:
    build:
      context: .
    ports:
      - 8080:80
    volumes:
      - .:/var/www/html  
```

Теперь выполним две команды:
```
$ docker-compose stop # остановить контейнеры
Stopping www_app_1 ... done
$ docker-compose rm # удалить контейнеры
Going to remove www_app_1
Are you sure? [yN] y
Removing www_app_1 ... done  
```

Эти команды остановят и удалят все контейнеры, описанные в файле docker-compose.yml. Вместо двух команд можно использовать одну:
```
$ docker-compose down # остановить и удалить контейнеры, удалить сеть
Stopping www_app_1 ... done
Removing www_app_1 ... done
Removing network www_default  
```

Собираем проект заново, поскольку мы отредактировали файлы Dockerfile и docker-compose.yml:
```
$ docker-compose build  
```

И заново запустим:
```
$ docker-compose up  
```

И опять, по адресу http://localhost:8080 поднимется наш сервер. Но теперь мы можем редактировать файл index.php и сразу видеть изменения:
```
$ nano index.php 
```
``` 
<pre>
<?php
$n = $i = empty($_GET['count']) ? 5 : $_GET['count'];
while ($i--) {
    echo str_repeat(' ', $i).str_repeat('* ', $n - $i)."\n";
}
?>
</pre>  
```

Docker-compose, так же как и Docker, предоставляет возможность для выполнения команд внутри контейнера:
```
$ docker-compose exec служба команда  
```

Давайте остановим наши службы (точнее, нашу единственную службу), потом запустим их снова в режиме демона, а потом выполним команду внутри контейнера:
```
$ docker-compose down
Stopping www_app_1 ... done
Removing www_app_1 ... done
Removing network www_default  
```
```
$ docker-compose up -d # службы должны работать в режиме демона
Creating network "www_default" with the default driver
Creating www_app_1 ... done  
```
```
$ docker-compose exec app apache2 -v # app — это название службы из docker-compose.yml
Server version: Apache/2.4.38 (Debian)
Server built:   2019-10-15T19:53:42  
```

И опять остановим наши службы:
```
$ docker-compose down
Stopping www_app_1 ... done
Removing www_app_1 ... done
Removing network www_default  
```

Две службы: Apache+PHP и MySQL
Давайте удалим все из директории www домашнего каталога и создадим более сложный проект. Он будет запускать две службы: Apache и MySQL. Структура каталогов будет такой:
```
[www]
    [apache]
        [html]
        [logs]
            access.log
            error.log
        httpd.conf
        php.ini
        Dockerfile
    [mysql]
        [data]
        [logs]
            mysql.log
            error.log
        mysql.cnf
        Dockerfile
    docker-compose.yml  
```

Нам нужно выполнить шаги:

* Скачать образ Apache+PHP (как модуль) в качестве базового
* Создать Dockerfile для построения нашего образа Apache+PHP
* Создать файл конфигурации Apache и смонтировать внутрь контейнера Apache+PHP
* Создать файл конфигурации PHP и смонтировать внутрь контейнера Apache+PHP
* Создать файлы логов Apache и смонтировать их внутрь контейнера Apache+PHP
* Скачать образ MySQL в качестве базового
* Создать Dockerfile для создания нашего образа MySQL
* Создать файл конфигурации MySQL и смонтировать внутрь контейнера MySQL
* Создать файлы логов MySQL и смонтировать их внутрь контейнера MySQL
* Создать директорию баз данных и смонтировать ее внутрь контейнера MySQL
* Создаем файл ~/www/apache/html/index.php:

```
$ nano ~/www/apache/html/index.php  
```
```
<?php phpinfo(); ?>  
```

### Скачиваем образы Apache и MySQL

Скачаем два образа
```
$ docker pull php:7.4-apache
$ docker pull mysql:latest  
```

Создаем файлы конфигурации
Теперь возьмем из образа php:7.4-apache файл конфигурации Apache2 и файл конфигурации PHP (который работает как модуль Apache):
```
$ cd ~/www/apache
$ docker run --rm php:7.4-apache cat /etc/apache2/apache2.conf > httpd.conf
$ docker run --rm php:7.4-apache cat /usr/local/etc/php/php.ini-development > php.ini-development
$ docker run --rm php:7.4-apache cat /usr/local/etc/php/php.ini-production > php.ini-production
$ cp php.ini-development php.ini  
```

Команда docker run запускает контейнер (и удаляет при завершении), выполняют внутри контейнера команду cat и записывает содержимое файла конфигурации из контейнера в файл конфигурации на хосте. Этот файл конфигурации мы будем монтировать внутрь контейнера, чтобы иметь возможность редактировать его на хосте, а не внутри контейнера.
Из образа mysql:latest возьмем файл конфигурации MySQL /etc/mysql/mysql.cnf:
```
$ cd ~/www/mysql/
$ docker run --rm mysql:latest cat /etc/mysql/my.cnf > mysql.cnf  
```

Создаем файлы Dockerfile
Создаем файл ~/www/apache/Dockerfile:
```
$ nano ~/www/apache/Dockerfile  
```
```
#Образ с DockerHub, включает Apache и PHP 7.4
FROM php:7.4-apache
#Обновляем и устанавливаем пакеты, устанавливаем расширения
RUN apt-get update && apt-get install -y \
        curl \
        wget \
    && docker-php-ext-install -j$(nproc) mysqli pdo_mysql
#Сообщаем, какие порты контейнера слушать
EXPOSE 80
```
  
Создаем файл ~/www/mysql/Dockerfile:
```
$ nano ~/www/mysql/Dockerfile  
```
```
#Образ с DockerHub, последняя версия MySQL
FROM mysql:latest
#Пароль пользователя root базы данных
ENV MYSQL_ROOT_PASSWORD=qwerty
#Сообщаем, какие порты контейнера слушать
EXPOSE 3306  
```

Создаем файлы логов Apache и MySQL
Создаем файлы логов Apache:
```
$ touch ~/www/apache/logs/access.log
$ touch ~/www/apache/logs/error.log  
```

Создаем файлы логов MySQL:
```
$ touch ~/www/mysql/logs/mysql.log
$ touch ~/www/mysql/logs/error.log  
```

Добавляем в файл конфигурации MySQL запись логов:
```
$ nano ~/www/mysql/mysql.cnf  
```
```
general_log_file = /var/log/mysql/mysql.log
general_log      = 1
log_error        = /var/log/mysql/error.log  
```

С файлом логов mysql.log надо быть осторожным — сервер MySQL будет записывать в него все запросы, так что размер этого файла будет расти очень быстро.

Создаем файл docker-compose.yml
Создаем файл ~/www/docker-compose.yml:
```
$ nano ~/www/docker-compose.yml  
version: '3'
services:
  apache:
    build: # инструкции для создания образа
      # контекст (путь к каталогу, содержащему Dockerfile)
      context: ./apache/
      # это необязательно, потому что контекст уже задан
      dockerfile: Dockerfile
    ports:
      # контейнер будет доступен на порту 80 основной системы
      - 80:80
    volumes: # путь указывается от директории, где расположен docker-compose.yml
      # монтируем директорию с php-скриптом внутрь контейнера
      - ./apache/html/:/var/www/html/
      # монтируем файл конфигурации php.ini внутрь контейнера
      - ./apache/php.ini:/usr/local/etc/php/php.ini
      # монтируем файл конфигурации Apache2 внутрь контейнера
      - ./apache/httpd.conf:/etc/apache2/apache2.conf
      # монтируем файл логов доступа Apache2 внутрь контейнера
      - ./apache/logs/access.log:/var/log/apache2/access.log
      # монтируем файл логов ошибок Apache2 внутрь контейнера
      - ./apache/logs/error.log:/var/log/apache2/error.log
  mysql:
    build: # инструкции для создания образа
      # контекст (путь к каталогу, содержащему Dockerfile)
      context: ./mysql/
      # это необязательно, потому что контекст уже задан
      dockerfile: Dockerfile
    environment:
      # пароль пользователя root
      MYSQL_ROOT_PASSWORD: qwerty
    ports:
      - 3306:3306
    volumes: # путь указывается от директории, где расположен docker-compose.yml
      # монтируем файл конфигурации MySQL внутрь контейнера
      - ./mysql/mysql.cnf:/etc/mysql/my.cnf
      # монтируем директорию с базами данных внутрь контейнера
      - ./mysql/data/:/var/lib/mysql/
      # монтируем директорию с логами MySQL внутрь контейнера
      - ./mysql/logs/:/var/log/mysql/  
```

Создаем образы и запускаем службы
При выполнении команды docker-compose up:

Создается сеть с именем www_default
Создается контейнер, используя конфигурацию из секции apache. Он присоединяется к сети www_default как хост apache
Создается контейнер, используя конфигурацию из секции mysql. Он присоединяется к сети www_default как хост mysql
```
$ cd ~/www/
$ docker-compose up -d
```
```
Creating network "www_default" with the default driver
Creating www_mysql_1  ... done
Creating www_apache_1 ... done  
```

Открываем браузер и набираем в адресной строке http://localhost:


```
$ docker-compose down
```
```
Stopping www_apache_1 ... done
Stopping www_mysql_1  ... done
Removing www_apache_1 ... done
Removing www_mysql_1  ... done
Removing network www_default  
```

Логи Apache и MySQL
Мы смонтировали файлы логов внутрь контейнера и теперь можем их смотреть в основной системе:
```
$ cat ~/www/apache/logs/access.log
```
```
172.18.0.1 - - [25/Mar/2020:13:36:05 +0000] "GET / HTTP/1.1" 200 390 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0"
172.18.0.1 - - [25/Mar/2020:13:36:30 +0000] "GET / HTTP/1.1" 200 390 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0"
172.18.0.1 - - [25/Mar/2020:13:36:31 +0000] "GET / HTTP/1.1" 200 389 "-" "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0"  
```
```
$ cat ~/www/apache/logs/error.log
```
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 172.18.0.3. Set the...
[Wed Mar 25 13:35:36.840470 2020] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.38 (Debian) PHP/7.4.4 configured...
[Wed Mar 25 13:35:36.840524 2020] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'  
```
```
$ tail -5 ~/www/mysql/logs/mysql.log 
```
```
2020-03-30T07:47:07.572115Z   21 Query  SELECT `SCHEMA_NAME` FROM `INFORMATION_SCHEMA`.`SCHEMATA`
2020-03-30T07:47:07.580739Z   21 Query  SET collation_connection = 'utf8mb4_unicode_ci'
2020-03-30T07:47:07.581694Z   21 Query  SELECT `SCHEMA_NAME` FROM `INFORMATION_SCHEMA`.`SCHEMATA`  
```
```
$ cat ~/www/mysql/logs/error.log 
```
```
2020-03-29T09:30:30.661026Z 0 [Warning] [MY-011070] [Server] Disabling symbolic links using --skip-symbolic-links (or equivalent) is the...
2020-03-29T09:30:30.661262Z 0 [System] [MY-013169] [Server] /usr/sbin/mysqld (mysqld 8.0.19) initializing of server in progress as process...
2020-03-29T09:30:38.268817Z 5 [Warning] [MY-010453] [Server] root@localhost is created with an empty password ! Please consider switching...  
```

```
Начало работы с Docker. Часть пятая
Начало работы с Docker. Часть шестая
Начало работы с Docker. Часть третья
Начало работы с Docker. Часть вторая
Начало работы с Docker. Часть первая
Установка модулей PHP под Ubuntu
Создание SSH-туннеля. Часть 2 из 4
```
