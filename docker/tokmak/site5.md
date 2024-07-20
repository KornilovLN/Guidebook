## Начало работы с Docker. Часть пятая
#### Заимствовано:         https://tokmakov.msk.ru/blog/item/489    18.03.2020


### Взаимодействие служб apache и mysql

Хорошо, наши две службы запускаются, но пока непонятно, могут ли они общаться между собой. И установились ли расширения mysqli и pdo_mysql для работы из PHP с базой данных MySQL. Давайте для начала заглянем внутрь контейнера apache, чтобы проверить расширения для работы с базой данных. Для этого запустим службы в работу и подключимся к контейнеру apache.

Сначала выясним из вывода phpinfo(), где расположены ini-файлы:

|-----------------------------------------|--------------------------------------------------------|
| Configuration File (php.ini) Path	      | /usr/local/etc/php                                     |
| Loaded Configuration File	              | /usr/local/etc/php/php.ini                             |
| Scan this dir for additional .ini files |	/usr/local/etc/php/conf.d                              |
| Additional .ini files parsed	          | /usr/local/etc/php/conf.d/docker-php-ext-mysqli.ini,   |
|                                         | /usr/local/etc/php/conf.d/docker-php-ext-pdo_mysql.ini,|
|                                         | /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini    |
|-----------------------------------------|--------------------------------------------------------|

Теперь запускаем наши службы
```
$ docker-compose up -d
Creating network "www_default" with the default driver
Creating www_apache_1 ... done
Creating www_mysql_1  ... done  
```

И смотрим ini-файлы внутри контейнера
```
$ docker-compose exec apache /bin/bash
# cd /usr/local/etc/php/conf.d/
# ls
docker-php-ext-mysqli.ini  docker-php-ext-pdo_mysql.ini  docker-php-ext-sodium.ini
# cat docker-php-ext-mysqli.ini
extension=mysqli.so
# cat docker-php-ext-pdo_mysql.ini 
extension=pdo_mysql.so
# exit
```
  
Вроде все в порядке, так что можем поработать из php-скрипта с базой данныx:
```
$ nano ~/www/apache/html/index.php  
```
```
<?php
// открываем новое соединение
$mysqli = new mysqli(
    'mysql',  // хост в сети
    'root',   // пользователь
    'qwerty', // пароль
    'mysql'   // база данных
);
// если произошла ошибка
if ($mysqli->connect_error) {
    die('Error : ('. $mysqli->connect_errno .') '. $mysqli->connect_error);
}

// выполняем запрос к БД
$results = $mysqli->query("SELECT `User`, `Host` FROM `user` WHERE 1");
// выводим результат запроса
echo '<table border="1">';
while($row = $results->fetch_assoc()) {
    echo '<tr>';
    echo '<td>'.$row['User'].'</td>';
    echo '<td>'.$row['Host'].'</td>';
    echo '</tr>';
}
echo '</table>';

// освобождаем память
$results->free();
// закрываем соединение
$mysqli->close();
```
  

Обратите внимание, что в качестве хоста для соединения с сервером БД мы указываем mysql — это имя службы в файле docker-compose.yml.


### Три службы: Apache+PHP, MySQL и phpMyAdmin

Давайте отредактируем файл ~/www/docker-compose.yml и добавим еще один контейнер:
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
  pma:
    # используем готовый образ phpmyadmin
    image: phpmyadmin/phpmyadmin
    ports:
      - 8080:80
    environment:
      # название хоста в сети www_default
      PMA_HOST: mysql
      MYSQL_USERNAME: root
      MYSQL_ROOT_PASSWORD: qwerty  
```
```
$ docker-compose up -d
Creating network "www_default" with the default driver
Creating www_mysql_1 ... done
Creating www_apache_1 ... done
Creating www_pma_1    ... done  
```

Открываем браузер и набираем в адресной строке http://localhost:8080:


```
$ docker-compose down
Stopping www_apache_1 ... done
Stopping www_mysql_1  ... done
Stopping www_pma_1    ... done
Removing www_apache_1 ... done
Removing www_mysql_1  ... done
Removing www_pma_1    ... done
Removing network www_default  
```

### Взаимодействие контейнеров по сети

Сеть Docker построена на Container Network Model (CNM), которая позволяет любому желающему создать свой собственный сетевой драйвер. Таким образом, у контейнеров есть доступ к разным типам сетей и они могут подключаться к нескольким сетям одновременно. Помимо различных сторонних сетевых драйверов, у самого Docker-а есть 4 встроенных:

* bridge: в этой сети контейнеры запускаются по умолчанию. Связь устанавливается через bridge-интерфейс на хосте. У контейнеров, которые используют одинаковую сеть, есть своя собственная подсеть, и они могут передавать данные друг другу по умолчанию.
* host: этот драйвер дает контейнеру доступ к собственному пространству хоста (контейнер будет видеть и использовать тот же интерфейс, что и хост).
* overlay: этот драйвер позволяет строить сети на нескольких хостах с Docker (обычно на Docker Swarm кластере). У контейнеров также есть свои адреса сети и подсети, и они могут напрямую обмениваться данными, даже если они располагаются физически на разных хостах.
* none: это сетевой драйвер, который умеет отключать всю сеть для контейнеров. Обычно используется в сочетании с пользовательским сетевым драйвером.

#### Сети типа мост (bridge)

По умолчанию для контейнеров используется bridge. При первом запуске контейнера Docker создает дефолтную bridge-сеть. Эту сеть можно увидеть в общем списке по команде
```
$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
4db4885e345c        bridge              bridge              local
1a425e4362b4        host                host                local
9246f826508b        none                null                local  
```

Чтобы проинспектировать ее свойства, запустим команду
```
$ docker network inspect bridge  
[
    {
        "Name": "bridge",
        "Id": "4db4885e345cbad5662da7cc0fe753e2f323a84fd2ba01947067cb1cca2b70c5",
        "Created": "2020-03-30T08:56:17.5621013+03:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {},
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]  
```

Также можно создать свои собственные bridge-сети при помощи команды
```
$ docker network create --driver bridge --subnet 192.168.100.0/24 --ip-range 192.168.100.0/24 custom-bridge-network 
```
 
#### Bridge-интерфейсы хоста

Каждая bridge-сеть имеет свое представление в виде интерфейса на хосте. С сетью bridge, которая существует по умолчанию, обычно ассоциируется интерфейс docker0. Для каждой новой сети, которая создается при помощи команды docker network create, будет ассоциироваться свой собственный новый интерфейс.
```
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:e0:4c:36:01:db brd ff:ff:ff:ff:ff:ff
    inet 192.168.110.14/24 brd 192.168.110.255 scope global dynamic enp2s0
       valid_lft 15789sec preferred_lft 15789sec
    inet6 fe80::2e0:4cff:fe36:1db/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 02:42:3f:50:59:fd brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:3fff:fe50:59fd/64 scope link 
       valid_lft forever preferred_lft forever  
```

Можно получить больше данных о статусе моста при помощи утилиты brctl (должен быть установлен пакет bridge-utils):
```
$ brctl show docker0
bridge name    bridge id            STP enabled    interfaces
docker0        8000.02423f5059fd    no  
```

Как только мы запустим контейнеры и привяжем их к этой сети, интерфейс каждого из этих контейнеров будет выведен в списке в отдельной колонке. А если включить захват трафика в bridge-интерфейсе, то можно увидеть, как передаются данные между контейнерами в одной подсети.

#### Виртуальные интерфейсы Linux

Container Networking Model дает каждому контейнеру свое собственное сетевое пространство. Если запустить команду ip addr внутри контейнера, то можно увидеть его интерфейсы такими, какими их видит сам контейнер:
```
$ docker run -it ubuntu:latest
# apt update
# apt install iproute2 -y
# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
48: eth0@if49: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever  
```

Интерфейс eth0, который представлен в этом примере, можно увидеть только изнутри контейнера, а снаружи, на хосте, Docker создает соответствующую копию виртуального интерфейса if49, которая служит связью с внешним миром. Запустим еще один терминал на хосте и выполним команду
```
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:e0:4c:36:01:db brd ff:ff:ff:ff:ff:ff
    inet 192.168.110.14/24 brd 192.168.110.255 scope global dynamic enp2s0
       valid_lft 13634sec preferred_lft 13634sec
    inet6 fe80::2e0:4cff:fe36:1db/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:3f:50:59:fd brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:3fff:fe50:59fd/64 scope link 
       valid_lft forever preferred_lft forever
49: veth59134c1@if48: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether ba:52:36:4d:82:41 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::b852:36ff:fe4d:8241/64 scope link 
       valid_lft forever preferred_lft forever  
```
```
$ brctl show docker0
bridge name    bridge id            STP enabled    interfaces
docker0        8000.02423f5059fd    no             veth59134c1  
```
Откроем еще один терминал на хосте и запустим контейнер:
```
$ docker run -it ubuntu:latest
# apt update
# apt install iproute2 -y
# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
50: eth0@if51: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
       valid_lft forever preferred_lft forever  
```

Теперь опять выполним на хосте команды
```
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp2s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:e0:4c:36:01:db brd ff:ff:ff:ff:ff:ff
    inet 192.168.110.14/24 brd 192.168.110.255 scope global dynamic enp2s0
       valid_lft 13136sec preferred_lft 13136sec
    inet6 fe80::2e0:4cff:fe36:1db/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default 
    link/ether 02:42:3f:50:59:fd brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:3fff:fe50:59fd/64 scope link 
       valid_lft forever preferred_lft forever
49: veth59134c1@if48: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether ba:52:36:4d:82:41 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::b852:36ff:fe4d:8241/64 scope link 
       valid_lft forever preferred_lft forever
51: veth48f087e@if50: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default 
    link/ether fa:62:a1:e8:46:fc brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::f862:a1ff:fee8:46fc/64 scope link 
       valid_lft forever preferred_lft forever  
$ brctl show docker0
bridge name    bridge id            STP enabled    interfaces
docker0        8000.02423f5059fd    no             veth48f087e
                                                   veth59134c1  
```

Сразу стало видно, что два интерфейса присоединены к bridge-интерфейсу docker0 (по одному на каждый контейнер).

                        | Интефейс внутри контейнера | Интерфейс снаружи контейнера
-----------------------------------------------------------------------------------
Первый контейнер Ubuntu | Имя eth0, номер 48         | Имя veth59134c1, номер 49
Второй контейнер Ubuntu | Имя eth0, номер 50         | Имя veth48f087e, номер 51  

#### Дополнительно

* Репозиторий DockerHub: страница PHP
* Образы PHP разных версий (Debian и Alpine)
* Репозиторий DockerHub: страница MySQL
* Образы MySQL разных версий (5.6, 5.7, 8.0)
* Репозиторий DockerHub: страница Apache
* Образы Apache разных версий (Debian и Alpine)

```
Начало работы с Docker. Часть четвертая
Начало работы с Docker. Часть шестая
Начало работы с Docker. Часть третья
Начало работы с Docker. Часть вторая
Начало работы с Docker. Часть первая
Создание SSH-туннеля. Часть 2 из 4
Установка модулей PHP под Ubuntu
```
