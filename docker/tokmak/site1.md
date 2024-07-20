## Начало работы с Docker. Часть первая
#### Заимствовано:         https://tokmakov.msk.ru/blog/item/485    18.03.2020

Docker — это система управления процессами приложения в контейнерах. Все процессы выполняются в изолированном пространстве, но в то же время на одном ядре, что позволяет экономить ресурсы основной системы. Docker не реализует собственную систему контейнеров, он использует LXC и выступает в качестве оболочки.

### Установка Docker

Дистрибутив Docker, доступный в официальном репозитории Ubuntu, не всегда является последней версией программы. Лучше установить последнюю версию, загрузив ее из официального репозитория Docker.

Сначала обновляем существующий перечень пакетов:
```
$ sudo apt update 
```

Затем устанавливаем пакеты, которые позволяют apt использовать протокол HTTPS:
```
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common 
```

Затем добавляем в свою систему ключ GPG официального репозитория Docker:
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
```

Добавляем репозиторий Docker в список источников пакетов apt:
```
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable" 
```

Затем обновим базу данных пакетов информацией о пакетах репозитория Docker:
```
$ sudo apt update 
```

Следует убедиться, что мы устанавливаем Docker из репозитория Docker, а не из репозитория по умолчанию Ubuntu:
```
$ apt-cache policy docker-ce
docker-ce:
  Установлен: (отсутствует)
  Кандидат:   5:19.03.8~3-0~ubuntu-bionic
  Таблица версий:
     5:19.03.8~3-0~ubuntu-bionic 500
        500 https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
     5:19.03.7~3-0~ubuntu-bionic 500
        500 https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
     5:19.03.6~3-0~ubuntu-bionic 500
        500 https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
     5:19.03.5~3-0~ubuntu-bionic 500
        500 https://download.docker.com/linux/ubuntu bionic/stable amd64 Packages
     .......... 
```

Далее устанавливаем Docker:
```
$ sudo apt install docker-ce 
```

Теперь Docker установлен, демон запущен, и процесс будет запускаться при загрузке системы.
```
$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: e
   Active: active (running) since Wed 2020-03-18 11:46:37 MSK; 1min 59s ago
     Docs: https://docs.docker.com
 Main PID: 3656 (dockerd)
    Tasks: 8
   CGroup: /system.slice/docker.service
           └─3656 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/contain 
```

При установке Docker мы получаем не только сервис docker, но и утилиту командной строки docker (клиент Docker).


### Использование команды docker без sudo

По умолчанию, запуск команды docker требует привилегий пользователя root или пользователя группы docker, которая автоматически создается при установке Docker. Чтобы не вводить sudo каждый раз при запуске команды docker, добавим себя в группу docker:
```
$ sudo usermod -aG docker ${USER} 
```

Для применения этих изменений необходимо выполнить команду:
```
$ su - ${USER} 
```


### Использование команды docker

Команда docker позволяет использовать различные опции и команды с аргументами. Синтаксис выглядит следующим образом:
```
$ docker [опции] команда [аргументы] # старый синтаксис 
$ docker [опции] [группа] команда [аргументы] # новый синтаксис 
```

Пример старого и нового синтаксиса:
```
$ docker run hello-world # старый синтаксис
$ docker container run hello-world # новый синтаксис 
```

Для просмотра всех доступных команд:
```
$ docker

Usage:  docker [OPTIONS] COMMAND

A self-sufficient runtime for containers

Options:
      --config string      Location of client config files (default "/home/evgeniy/.docker")
  -c, --context string     Name of the context to use to connect to the daemon (overrides DOCKER_HOST env var and default context set with "docker context use")
  -D, --debug              Enable debug mode
  -H, --host list          Daemon socket(s) to connect to
  -l, --log-level string   Set the logging level ("debug"|"info"|"warn"|"error"|"fatal") (default "info")
      --tls                Use TLS; implied by --tlsverify
      --tlscacert string   Trust certs signed only by this CA (default "/home/evgeniy/.docker/ca.pem")
      --tlscert string     Path to TLS certificate file (default "/home/evgeniy/.docker/cert.pem")
      --tlskey string      Path to TLS key file (default "/home/evgeniy/.docker/key.pem")
      --tlsverify          Use TLS and verify the remote
  -v, --version            Print version information and quit

Management Commands:
  builder     Manage builds
  config      Manage Docker configs
  container   Manage containers
  context     Manage contexts
  engine      Manage the docker engine
  image       Manage images
  network     Manage networks
  node        Manage Swarm nodes
  plugin      Manage plugins
  secret      Manage Docker secrets
  service     Manage services
  stack       Manage Docker stacks
  swarm       Manage Swarm
  system      Manage Docker
  trust       Manage trust on Docker images
  volume      Manage volumes

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  events      Get real time events from the server
  exec        Run a command in a running container
  export      Export a container's filesystem as a tar archive
  history     Show the history of an image
  images      List images
  import      Import the contents from a tarball to create a filesystem image
  info        Display system-wide information
  inspect     Return low-level information on Docker objects
  kill        Kill one or more running containers
  load        Load an image from a tar archive or STDIN
  login       Log in to a Docker registry
  logout      Log out from a Docker registry
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  ps          List containers
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  run         Run a command in a new container
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  version     Show the Docker version information
  wait        Block until one or more containers stop, then print their exit codes

Run 'docker COMMAND --help' for more information on a command. 
```

Для просмотра опций использования определенной команды:
```
$ docker search --help

Usage:  docker search [OPTIONS] TERM

Search the Docker Hub for images

Options:
  -f, --filter filter   Filter output based on conditions provided
      --format string   Pretty-print search using a Go template
      --limit int       Max number of search results (default 25)
      --no-trunc        Don't truncate output 
```


### Работа с образами Docker

Контейнеры Docker создаются и запускаются из образов Docker. По умолчанию Docker получает образы из хаба Docker Hub, представляющего собой реестр образов, который поддерживается компанией Docker.

Скачаем и запустим образ:
```
$ docker container run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete 
Digest: sha256:f9dfddf63636d84ef479d645ab5885156ae030f611a56f3a7ac7f2fdd86d7e4e
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/ 
```

Изначально Docker не смог найти образ hello-world локально, поэтому загрузил образ из Docker Hub, который является репозиторием по умолчанию. После загрузки образа Docker создал из образа контейнер и запустил приложение в контейнере, которое выдало сообщение «Hello from Docker!».

Образы, доступные в Docker Hub, можно искать с помощью команды команды search:
```
$ docker search ubuntu
NAME                              DESCRIPTION                                     STARS  OFFICIAL  AUTOMATED
ubuntu                            Ubuntu is a Debian-based Linux operating sys…   10634  [OK]
dorowu/ubuntu-desktop-lxde-vnc    Docker image to provide HTML5 VNC interface …   405    [OK]
rastasheep/ubuntu-sshd            Dockerized SSH service, built on top of offi…   243    [OK]
consol/ubuntu-xfce-vnc            Ubuntu container with "headless" VNC session…   212    [OK]
ubuntu-upstart                    Upstart is an event-based replacement for th…   107    [OK]
ansible/ubuntu14.04-ansible       Ubuntu 14.04 LTS with ansible                   98     [OK]
.......... 
```

В столбце OFFICIAL строка OK показывает, что образ построен и поддерживается компанией, которая занимается разработкой этого проекта. Когда нужный образ выбран, можно загрузить его себе на компьютер с помощью команды pull:
```
$ docker pull ubuntu
Using default tag: latest
latest: Pulling from library/ubuntu
423ae2b273f4: Pull complete 
de83a2304fa1: Pull complete 
f9a83bce3af0: Pull complete 
b6b53be908de: Pull complete 
Digest: sha256:04d48df82c938587820d7b6006f5071dbbffceb7ca01d2814f81857c631d44df
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest 
```

После загрузки образа можно запустить контейнер с загруженным образом с помощью подкоманды run. Как видно из примера hello-world, если при выполнении команды run образ еще не загружен, клиент Docker сначала загрузит образ, а затем запустит контейнер с этим образом.

Для просмотра загруженных на компьютер образов нужно ввести:

$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              72300a873c2c        3 weeks ago         64.2MB
hello-world         latest              fce289e99eb9        14 months ago       1.84kB 


### Запуск контейнера Docker

Контейнер hello-world, запущенный ранее, является примером контейнера, который запускается и завершает работу после вывода тестового сообщения. Контейнеры могут выполнять и более полезные действия, а также могут быть интерактивными. Контейнеры похожи на виртуальные машины, но являются менее требовательными к ресурсам.

В качестве примера запустим контейнер с последней версией Ubuntu. Комбинация опций -i и -t обеспечивает интерактивный доступ к командному процессору контейнера:
```
$ docker run -it ubuntu:latest 
```

Командная строка должна измениться, показывая, что мы работаем в контейнере. Теперь можно запускать любые команды внутри контейнера. Попробуем, например, обновить базу данных пакета внутри контейнера:
```
# apt update 
```

А после этого установим web-сервер:
```
# apt install apache2 
```

Чтобы выйти из контейнера, вводим команду
```
# exit 
```

Команда run выполняет сразу несколько задач: скачивает образ (если не был скачан ранее), создает новый контейнер, запускает его и выполняет указанную команду (если она задана). Чтобы присвоить контейнеру какое-то осмысленное имя, нужно использовать опцию name:
```
$ docker run --name some-name ubuntu:latest /bin/bash
```
 
Чтобы запустить контейнер в интерактивном режиме — добавляем опции -i и -t:
```
$ docker run -it --name some-name ubuntu:latest /bin/bash 
```

Когда процесс внутри контейнера выполнит свою работу, то Docker-контейнер завершается. Каждый раз при выполнении команды docker run, будет создаваться новый контейнер. Чтобы в системе не накапливалось большое количество контейнеров, команду docker run часто запускают с дополнительной опцией --rm:
```
$ docker run -it --rm ubuntu:latest /bin/bash 
```

Команда docker run является сокращением для docker create, docker start и docker attach (без attach контейнер работает в фоновом режиме).


### Управление контейнерами Docker

Через некоторое время после начала использования Docker на машине будет множество активных (запущенных) и неактивных контейнеров. Для просмотра активных контейнеров:
```
$ docker ps
CONTAINER ID   IMAGE    COMMAND       CREATED          STATUS                        PORTS   NAMES 
```

Для просмотра всех контейнеров:
```
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND       CREATED          STATUS                        PORTS   NAMES
37def446ae84   ubuntu        "/bin/bash"   5 minutes ago    Exited (127) 25 seconds ago           boring_chatterjee
6a278cd2e171   hello-world   "/hello"      10 minutes ago   Exited (0) 10 minutes ago             elegant_euclid 
```

Для запуска остановленного контейнера используем команду start, затем указываем идентификатор контейнера или его имя:
```
$ docker container start 37def446ae84 
```

Для подключения к запущенному контейнеру используем команду attach, затем указываем идентификатор контейнера или его имя:
```
$ docker container attach boring_chatterjee 
```

Если контейнер был запущен с помощью -i и -t, можно отсоединиться от контейнера и оставить его работающим, используя CTRL-p CTRL-q последовательность клавиш.
Чтобы выполнить отдельную команду внутри контейнера, используем команду exec, указываем идентификатор или имя контейнера и задаем команду для выполнения:
```
$ docker container exec boring_chatterjee ls
bin  boot  dev    etc  home  lib    lib64  media  mnt  opt    proc  root  run  sbin  srv  sys  tmp  usr  var 
$ docker container exec -it boring_chatterjee /bin/bash
# ls /
bin  boot  dev    etc  home  lib    lib64  media  mnt  opt    proc  root  run  sbin  srv  sys  tmp  usr  var
# exit
```
 
Для остановки запущенного контейнера используем команду stop, затем указываем идентификатор контейнера или его имя:
```
$ docker container stop boring_chatterjee 
```

Если контейнер больше не нужен, удаляем его командой rm с указанием либо идентификатора, либо имени контейнера:
```
$ docker container rm elegant_euclid 
```

Изменить имя контейнера можно с помощью команды rename:
```
$ docker container rename boring_chatterjee apache2_ubuntu 
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND       CREATED          STATUS                        PORTS   NAMES
37def446ae84   ubuntu        "/bin/bash"   5 minutes ago    Exited (127) 25 seconds ago           apache2_ubuntu 
```


### Сохранение изменений в контейнере в образ Docker

После установки Apache2 в контейнере Ubuntu у нас будет работать запущенный из образа контейнер, но он будет отличаться от образа, использованного для его создания. Однако нам может потребоваться такой контейнер Apache2 как основа для будущих образов.

Давайте сохраним состояние контейнера в виде нового образа Docker:
```
$ docker commit -m "Added web-server Apache2" -a "Evgeniy Tokmakov" 37def446ae84 tokmakov/apache2_ubuntu 
$ docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
tokmakov/apache2_ubuntu   latest              18073a80c28b        27 seconds ago      191MB
ubuntu                    latest              72300a873c2c        3 weeks ago         64.2MB 
```

Образы также могут строиться с помощью файла Dockerfile, который позволяет автоматизировать установку программ в новом образе.

```
Начало работы с Docker. Часть четвертая
Начало работы с Docker. Часть третья
Начало работы с Docker. Часть вторая
Начало работы с Docker. Часть пятая
Начало работы с Docker. Часть шестая
Создание SSH-туннеля. Часть 3 из 4
Установка DHCP-сервера на Ubuntu Server 18.04 LTS
```
