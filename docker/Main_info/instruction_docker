#---------------------------------------------------------
#--- Instruction docker: Предполагает работу в shell
#---------------------------------------------------------

#--- Предположим, надо создать автономную от ОС программу
#--- понадобится рабочая директория ~/{path}/prj1

#--- создаю рабочую директорию проекта и захожу в нее
№--- Тут будут файлы проекта (prg.py,...) и Dockerfile
$ mkdir ~/work/docker/prj1
$ cd ~/work/docker/prj1

#--- тут будут логи работы проекта 
$ mkdir ~/work/docker/prj1/logs

#--- скачиваю последнюю версию ubuntu докером !!!
#--- Опционально для случая, когда python:3.8 не использ.
#--- $ docker pull ubuntu
#--- а надо просто поработать через bash в ubuntu !!!

#--- пишу рабочую программу для докера и сохраняю в этой
#--- директории под именем prg.py

#--- создаю Dockerfile с инструкциями для сборки ту же

```
#--- Dockerfile ---------------------------------
# официальный образ Python как базовый
FROM python:3.8

#--- Уст. авторство
LABEL maintainer ln.Kornilovstar@gmail.com

#--- Если работаем с кодом из GitHub:
#--- Клонировать код из GitHub если надо
# RUN git clone -q https://github.com/docker-in-practice/todo.git
#--- Перейти в директорию клонированного кода
# WORKDIR todo

#--- Иначе, указываем рабочую директорию, где находимся
# Уст. рабочую директорию в контейнере
WORKDIR /home

# Создать дир. логов, если надо: /home/logs
RUN mkdir logs

# Скопировать файлы prg.py,... в рабочую директорию
COPY prg.py .

# Запустить prg.py при запуске контейнера
CMD [ "python", "./prg.py" ]
#------------------------------------------------
```

#--- создаю image для своего контейнера img_prg
$ docker build -t img_prg . 

#--- запускаю контейнер cont_prg с образом img_prg
$ docker run -d --name cont_prg img_prg

#--- слежу за логами работы prg.py в консоли 
$ docker logs cont_prg



#--- Для остановки контейнера использовать команду
$ docker stop cont_prg

#--- Для перезапуска контейнера
$ docker start cont_prg

#--- для подключения к контейнеру через bash
$ docker exec -it cont_prg /bin/bash

#--- для подробного просмотра контейнера
$ docker inspect cont_prg



#--- Сохранить образ в файл для отправки:
$ docker save -o img_prg.tar img_prg

#--- Сжать файл, если большой слишком, в img_prg.tar.gz 
$ gzip img_prg.tar

#--- После получения не сжатого или сжатого файла:
$ docker load -i img_prg.tar
#--- или:
$ gunzip -c img_prg.tar.gz | docker load

#--- после этого файл можно запускать докером получателя
$ docker run -d --name cont_prg img_prg 

#---и наблюдать за логами
$ docker logs cont_prg


#-------------------------------------------------------------------------
#--- Копирование образа и томов на удаленный компьютер и запуск приложения
#--- ssh str_mrk@gitlab.ivl.ua pwd
#-------------------------------------------------------------------------

Для отправки контейнера с приложением и внешними томами на удаленный компьютер
по SSH и его запуска там, выполните следующие шаги:


1. Сохраните образ контейнера в файл:

docker save myapp:latest > myapp.tar



2. Отправьте файл образа и файлы внешних томов на удаленный компьютер:

scp myapp.tar user@remote:/path/to/destination/
scp -r /path/to/volumes user@remote:/path/to/destination/



3. Подключитесь к удаленному компьютеру по SSH:

ssh user@remote



4. На удаленном компьютере загрузите образ из файла:

docker load < /path/to/destination/myapp.tar



5. Запустите контейнер, монтируя внешние тома:

docker run -d -v /path/to/destination/volumes:/app/data myapp:latest

#---------------------------------------------------------------------------
#--- 
#---------------------------------------------------------------------------

### Чтобы увидеть сайт с вашего хоста, нужно настроить проброс портов через SSH:

    1. На вашем локальном компьютере выполните команду:
```
ssh -L 8089:localhost:8089 starmark@gitlab.ivl.ua 
```

    что позволит зайти в удаленный сервер так, чтобы связать локалхост порты

    2. Измените запуск контейнера, чтобы он слушал на всех интерфейсах:
```
Замените 
    -p 8089:80 на
    -p 0.0.0.0:8089:80
```

    3. Теперь вы сможете открыть в браузере
```
http://localhost:8089
```
    и увидеть сайт, запущенный на удаленном сервере.

    4. Если нужно изменить порт, просто замените 8089 на желаемый порт в обеих командах.

    5. Для облегчения работ создайте скрипт и пусть он будет на удаленном сервере
```
#!/bin/bash

# run_cont.sh  
# Сделать его исполняемым и отправить на сервер вместе с проектом
# Проект разархивировать и загрузить
# Потом запустить скрипт
# А уже на хосте запустить браузер как: localhost:8089
# Страница запущенная на сервере будет видна на хосте 

IMAGENAME="my-flask-img:latest"
CONTAINERNAME="my-flask-cont"
VOLUMENAME="ekatra_flask_data"
VOLUMEPATH="/home/leon/work/docker/ekatra_flask/"
APPPATH="/app"
DATAPATH="/data"

#PORTHOST=8089
PORTHOST=0.0.0.0:8089

PORTDOCK=80

# Если был запущен, то надо остановить перед перегрузкой 
docker stop $CONTAINERNAME

sleep 2

# Создаем том для контекста, создаваемого приложением
docker volume create $VOLUMENAME


# После останова самоуничтожится
docker run  --rm \
            --name $CONTAINERNAME \
            -p $PORTHOST:$PORTDOCK \
            # -v $VOLUMEPATH:$APPPATH \
            -v $VOLUMENAME:$DATAPATH \
            $IMAGENAME
```

    6. При этом Dockerfile проекта такой:
```
#---------------------------------------------------------------------
# образ Docker с тегом my-image, содержащий базовый python:3.12-slim
# Nginx, Git и Midnight Commander.
# Файлы приложения Flask в директории app/
#---------------------------------------------------------------------
# docker build -t my-flask-img .        #--- сборка my-flask-img
# docker run -p 8089:80 my-flask-img    #--- запустить контейнер
# переделать следующую команду
# docker run --rm --name my-flask-cont -p 8089:80 -v /home/leon/work/docker/ekatra_flask/:/app my-flask-img
# на команду запуска контейнера с пробросом локалхост портов так:
# docker run --rm --name my-flask-cont -p 0.0.0.0:8089:80 -v /home/leon/work/docker/ekatra_flask/:/app my-flask-img
#---------------------------------------------------------------------
# Используем базовый образ Python 3.12
FROM python:3.12-slim

# Обновляем список пакетов и устанавливаем необходимые пакеты
RUN apt-get update && \
    apt-get install -y nginx docker.io git mc && \
    rm -rf /var/lib/apt/lists/*

# Копируем файл requirements.txt
COPY requirements.txt /app/requirements.txt

# Обновляем pip, setuptools и wheel
RUN pip install --upgrade pip setuptools wheel

# Устанавливаем зависимости Python через pip
RUN pip install -r /app/requirements.txt

# Копируем файлы приложения в контейнер
# Если заглушить, то будут использоваться из подключенного тома 
# какой надо будет указать в скрипте запуска контейнера
# Например так: -v ekatra_flask_data:/data
COPY . /app/  

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем конфигурационный файл Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Открываем порт для Nginx
EXPOSE 80

# Запускаем Nginx и Flask приложение при старте контейнера
CMD ["sh", "-c", "nginx && gunicorn -b 0.0.0.0:5000 app:app"]
```


