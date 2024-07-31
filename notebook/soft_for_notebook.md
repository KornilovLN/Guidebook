# ---------------------------------------------------------------
# Список необходимого и дополнительного ПО для работы на notebook
# ---------------------------------------------------------------

## Системный софт:

* Linux Mint 22.04      - установка из соответствующего *.iso 
* mc                    - командой          sudo apt install mc
* git                   - командами:
```
$ udo apt-get update
$ sudo apt-get install git
$ git --version

$ git config --global user.email "ln.KornilovStar@gmail.com"
$ git config --global user.name "KornilovLN"

$ git config -l

{
$ git help
$ git <command> --help
$ git
}
```

* docker                - командами:
<<< https://timeweb.cloud/tutorials/docker/kak-ustanovit-docker-na-ubuntu-22-04 >>>

Сначала обновляем существующий перечень пакетов:
```
$ sudo apt update 
```

Затем устанавливаем пакеты, которые позволяют apt использовать протокол HTTPS:
```
$ sudo apt install curl software-properties-common ca-certificates apt-transport-https -y
```

Затем добавляем в свою систему ключ GPG официального репозитория Docker:
```
$ wget -O- https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | sudo tee /etc/apt/keyrings/docker.gpg > /dev/null
```

Добавляем репозиторий Docker в список источников пакетов apt:
```
$ echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable"| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

Затем обновим базу данных пакетов информацией о пакетах репозитория Docker:
```
$ sudo apt update 
```

Проверяем репозиторий:
```
$ apt-cache policy docker-ce
```

Устанавливаем docker:
```
$ sudo apt install docker-ce -y
```

Проверяем успешность установки:
```
$ sudo systemctl status docker
```

* Установка Docker Compose:
<<< https://timeweb.cloud/tutorials/docker/kak-ustanovit-docker-na-ubuntu-22-04 >>>
<<< Свежие релизы:  https://github.com/docker/compose/releases >>>

```
$ sudo apt-get install docker-compose 
```

* Установка Python3, pip3, flask
```
$ apt install python3 python3-pip python3-venv

$ mkdir myproject
$ cd myproject
$ python3 -m venv venv
$ source venv/bin/activate
 
$ python3 -m pip install Flask
$ python -m flask --version

``` 

Для проверки пишем тест:
```
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'
```

Проверяем:
```
$ export FLASK_APP=app.py
$ export FLASK_ENV=development
$ flask run

``` 

