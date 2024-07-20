# Установка и использование Docker в Ubuntu 20.04 #
Published on May 23, 2024

    Ubuntu 20.04
    Docker

На основе документа:  Brian Hogan "Установка и использование Docker в Ubuntu 20.04"

## <<< --- Введение --- >>> ##

Docker — это приложение, упрощающее процесс управления процессами приложения в контейнерах. Контейнеры позволяют запускать приложения в процессах с изолированными ресурсами. Они похожи на виртуальные машины, но более портативные, более эффективно расходуют ресурсы и в большей степени зависят от операционной системы хоста.

Подробное описание различных компонентов контейнера Docker см. в статье Экосистема Docker: знакомство с базовыми компонентами.

В этом обучающем модуле мы установим и начнем использовать Docker Community Edition (CE) на сервере Ubuntu 20.04. Вы самостоятельно установите Docker, поработаете с контейнерами и образами и разместите образ в репозитории Docker.
Предварительные требования

Для выполнения этого руководства вам потребуется следующее:

    Один сервер Ubuntu 20.04, настроенный в соответствии с руководством по начальной настройке сервера Ubuntu 20.04, включая пользователя non-root user с привилегиями sudo и брандмауэр.
    Учетная запись на Docker Hub, если вы хотите создавать собственные образы и загружать их на Docker Hub, как показано в шагах 7 и 8.

## <<< --- Шаг 1 — Установка Docker --- >>> ##

Пакет установки Docker, доступный в официальном репозитории Ubuntu, может содержать не самую последнюю версию. Чтобы точно использовать самую актуальную версию, мы будем устанавливать Docker из официального репозитория Docker. Для этого мы добавим новый источник пакета, ключ GPG от Docker, чтобы гарантировать загрузку рабочих файлов, а затем установим пакет.

Первым делом обновите существующий список пакетов:

    sudo apt update

Затем установите несколько необходимых пакетов, которые позволяют apt использовать пакеты через HTTPS:

    sudo apt install apt-transport-https ca-certificates curl software-properties-common

Добавьте ключ GPG для официального репозитория Docker в вашу систему:

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

Добавьте репозиторий Docker в источники APT:

    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

Потом обновите базу данных пакетов и добавьте в нее пакеты Docker из недавно добавленного репозитория:

    sudo apt update

Убедитесь, что установка будет выполняться из репозитория Docker, а не из репозитория Ubuntu по умолчанию:

    apt-cache policy docker-ce

Вы должны получить следующий вывод, хотя номер версии Docker может отличаться:
Output of apt-cache policy docker-ce

docker-ce:
  Installed: (none)
  Candidate: 5:19.03.9~3-0~ubuntu-focal
  Version table:
     5:19.03.9~3-0~ubuntu-focal 500
        500 https://download.docker.com/linux/ubuntu focal/stable amd64 Packages

Обратите внимание, что docker-ce не установлен, но является кандидатом на установку из репозитория Docker для Ubuntu 20.04 (версия focal).

Установите Docker:

    sudo apt install docker-ce

Docker должен быть установлен, демон-процесс запущен, а для процесса активирован запуск при загрузке. Проверьте, что он запущен:

    sudo systemctl status docker

Вывод должен выглядеть примерно следующим образом, указывая, что служба активна и запущена:

Output
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2020-05-19 17:00:41 UTC; 17s ago
TriggeredBy: ● docker.socket
       Docs: https://docs.docker.com
   Main PID: 24321 (dockerd)
      Tasks: 8
     Memory: 46.4M
     CGroup: /system.slice/docker.service
             └─24321 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

После установки Docker у вас будет доступ не только к службе Docker (демон-процесс), но и к утилите командной строки docker или клиенту Docker. Мы узнаем, как использовать команду docker позже в этом обучающем руководстве.

## <<< --- Шаг 2 — Настройка команды Docker без sudo (необязательно) --- >>> ##

По умолчанию команда docker может быть запущена только пользователем root или пользователем из группы docker, которая автоматически создается при установке Docker. Если вы попытаетесь запустить команду docker без префикса sudo или с помощью пользователя, который не находится в группе docker, то получите следующий вывод:

Output
docker: Cannot connect to the Docker daemon. Is the docker daemon running on this host?.
See 'docker run --help'.

Если вы не хотите каждый раз вводить sudo при запуске команды docker, добавьте свое имя пользователя в группу docker:

    sudo usermod -aG docker ${USER}

Чтобы применить добавление нового члена группы, выйдите и войдите на сервер или введите следующее:

    su - ${USER}

Вы должны будете ввести пароль вашего пользователя, чтобы продолжить.

Проверьте, что ваш пользователь добавлен в группу docker, введя следующее:

    id -nG

Output
sammy sudo docker

Если вам нужно добавить пользователя в группу docker, для которой вы не выполнили вход, объявите имя пользователя явно, используя следующую команду:

    sudo usermod -aG docker username

В дальнейшем в статье подразумевается, что вы запускаете команду docker от имени пользователя в группе docker. В обратном случае вам необходимо добавлять к командам префикс sudo.

Давайте перейдем к знакомству с командой docker.

## <<< --- Шаг 3 — Использование команды Docker --- >>> ##

Использование docker подразумевает передачу ему цепочки опций и команд, за которыми следуют аргументы. Синтаксис имеет следующую форму:

    docker [option] [command] [arguments]

Чтобы просмотреть все доступные субкоманды, введите:

    docker

Для 19-й версии Docker полный список субкоманд выглядит следующим образом:

Output  
```
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
```

Чтобы просмотреть параметры, доступные для конкретной команды, введите:

    docker docker-subcommand --help

Чтобы просмотреть общесистемную информацию о Docker, введите следующее:

    docker info

Давайте изучим некоторые из этих команд. Сейчас мы начнем работать с образами.

## <<< --- Шаг 4 — Работа с образами Docker --- >>> ##

Контейнеры Docker получают из образов Docker. По умолчанию Docker загружает эти образы из Docker Hub, реестр Docker, контролируемые Docker, т.е. компанией, реализующей проект Docker. Любой может размещать свои образы Docker на Docker Hub, поэтому большинство приложений и дистрибутивов Linux, которые вам потребуется, хранят там свои образы.

Чтобы проверить, можно ли получить доступ к образам из Docker Hub и загрузить их, введите следующую команду:

    docker run hello-world

Данный вывод говорит о том, что Docker работает корректно:

Output
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
0e03bdcc26d7: Pull complete
Digest: sha256:6a65f928fb91fcfbc963f7aa6d57c8eeb426ad9a20c7ee045538ef34847f44f1
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

...

Docker первоначально не смог найти локальный образ hello-world, поэтому он загрузил образ из Docker Hub, который является репозиторием по умолчанию. После того как образ был загружен, Docker создал контейнер из образа, а приложение внутри контейнера было исполнено, отобразив сообщение.

Вы можете выполнять поиск доступных на Docker Hub с помощью команды docker с субкомандой search. Например, чтобы найти образ Ubuntu, введите:

    docker search ubuntu

Скрипт пробежится по Docker Hub и вернет список всех образов с именами, совпадающими со строкой запроса. В данном случае вывод будет выглядеть примерно следующим образом:

Output
NAME                                                      DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
ubuntu                                                    Ubuntu is a Debian-based Linux operating sys…   10908               [OK]
dorowu/ubuntu-desktop-lxde-vnc                            Docker image to provide HTML5 VNC interface …   428                                     [OK]
rastasheep/ubuntu-sshd                                    Dockerized SSH service, built on top of offi…   244                                     [OK]
consol/ubuntu-xfce-vnc                                    Ubuntu container with "headless" VNC session…   218                                     [OK]
ubuntu-upstart                                            Upstart is an event-based replacement for th…   108                 [OK]
ansible/ubuntu14.04-ansible                               Ubuntu 14.04 LTS with
...

В столбце OFFICIAL OK указывает на образ, созданный и поддерживаемый компанией, реализующей проект. После того как вы определили образ, который хотели бы использовать, вы можете загрузить его на свой компьютер с помощью субкоманды pull.

Запустите следующую команду, чтобы загрузить официальный образ ubuntu на свой компьютер:

    docker pull ubuntu

Вывод должен выглядеть следующим образом:

Output
Using default tag: latest
latest: Pulling from library/ubuntu
d51af753c3d3: Pull complete
fc878cd0a91c: Pull complete
6154df8ff988: Pull complete
fee5db0ff82f: Pull complete
Digest: sha256:747d2dbbaaee995098c9792d99bd333c6783ce56150d1b11e333bbceed5c54d7
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest

После того как образ будет загружен, вы сможете запустить контейнер с помощью загруженного образа с помощью субкоманды run. Как вы уже видели на примере hello-world, если образ не был загружен, когда docker выполняется с субкомандой run, клиент Docker сначала загружает образ, а затем запускает контейнер с этим образом.

Чтобы просмотреть образы, которые были загружены на ваш компьютер, введите:

    docker images

Вывод команды должен выглядеть примерно следующим образом:

Output
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              1d622ef86b13        3 weeks ago         73.9MB
hello-world         latest              bf756fb1ae65        4 months ago        13.3kB

Как вы увидите далее в этом обучающем руководстве, образы, которые вы используете для запуска контейнеров, можно изменить и использовать для создания новых образов, которые затем могут быть загружены (помещены) на Docker Hub или другие реестры Docker.

Давайте более подробно рассмотрим, как запускаются контейнеры.

## <<< --- Шаг 5 — Запуск контейнеров Docker --- >>> ##

Контейнер hello-world, который вы запустили на предыдущем шаге, служит примером контейнера, который запускается и завершает работу после отправки тестового сообщения. Контейнеры могут быть гораздо более полезными, чем в примере выше, а также могут быть интерактивными. В конечном счете они очень похожи на виртуальные машины, но более бережно расходуют ресурсы.

В качестве примера мы запустим контейнер с самым последним образом образ Ubuntu. Сочетание переключателей -i и -t предоставляет вам доступ к интерактивной командной оболочке внутри контейнера:

    docker run -it ubuntu

Необходимо изменить приглашение к вводу команды, чтобы отразить тот факт, что вы работаете внутри контейнера, и должны иметь следующую форму:

Output
root@d9b100f2f636:/#

Обратите внимание на идентификатор контейнер в запросе команды. В данном примере это d9b100f2f636. Вам потребуется этот идентификатор для определения контейнера, когда вы захотите его удалить.

Теперь вы можете запустить любую команду внутри контейнера. Например, сейчас мы обновим базу данных пакетов внутри контейнера. Вам не потребуется начинать любую команду с sudo, потому что вы работаете внутри контейнера как root-пользователь:

    apt update

После этого вы можете установите любое приложение внутри контейнера. Давайте установим Node.js:

    apt install nodejs

Эта команда устанавливает Node.js внутри контейнера из официального репозитория Ubuntu. После завершения установки проверьте, что Node.js был установлен успешно:

    node -v

Вы увидите номер версии, отображаемый в терминале:

Output
v10.19.0

Любые изменения, которые вы вносите внутри контейнера, применяются только к контейнеру.

Чтобы выйти из контейнера, введите exit.

Далее мы рассмотрим управление контейнерами в нашей системе.

## <<< --- Шаг 6 — Управление контейнерами Docker --- >>> ##

После использования Docker в течение определенного времени, у вас будет много активных (запущенных) и неактивных контейнеров на компьютере. Чтобы просмотреть активные, используйте следующую команду:

    docker ps

Вывод будет выглядеть примерно следующим образом:

Output
CONTAINER ID        IMAGE               COMMAND             CREATED             

В этом обучающем руководстве вы запустили два контейнера: один из образа hello-world и другой из образа ubuntu. Оба контейнера больше не запущены, но все еще существуют в вашей системе.

Чтобы просмотреть все контейнеры — активные и неактивные, воспользуйтесь командой docker ps с переключателем -a:

    docker ps -a

Вывод будет выглядеть следующим образом:

1c08a7a0d0e4        ubuntu              "/bin/bash"         2 minutes ago       Exited (0) 8 seconds ago                       quizzical_mcnulty
a707221a5f6c        hello-world         "/hello"            6 minutes ago       Exited (0) 6 minutes ago                       youthful_curie

Чтобы просмотреть последний созданный вами контейнер, передайте переключатель -l:

    docker ps -l

    CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
    1c08a7a0d0e4        ubuntu              "/bin/bash"         2 minutes ago       Exited (0) 40 seconds ago                       quizzical_mcnulty

Чтобы запустить остановленный контейнер, воспользуйтесь docker start с идентификатором контейнера или именем контейнера. Давайте запустим контейнер на базе Ubuntu с идентификатором 1c08a7a0d0e4:

    docker start 1c08a7a0d0e4

Контейнер будет запущен, а вы сможете использовать docker ps, чтобы просматривать его статус:

Output
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
1c08a7a0d0e4        ubuntu              "/bin/bash"         3 minutes ago       Up 5 seconds                            quizzical_mcnulty

Чтобы остановить запущенный контейнер, используйте docker stop с идентификатором или именем контейнера. На этот раз мы будем использовать имя, которое Docker присвоил контейнеру, т.е. quizzical_mcnulty:

    docker stop quizzical_mcnulty

После того как вы решили, что вам больше не потребуется контейнер, удалите его с помощью команды docker rm, снова добавив идентификатор контейнера или его имя. Используйте команду docker ps -a, чтобы найти идентификатор или имя контейнера, связанного с образом hello-world, и удалить его.

    docker rm youthful_curie

Вы можете запустить новый контейнер и присвоить ему имя с помощью переключателя --name. Вы также можете использовать переключатель ​--rm, чтобы создать контейнер, который удаляется после остановки. Изучите команду docker run help, чтобы получить больше информации об этих и прочих опциях.

Контейнеры можно превратить в образы, которые вы можете использовать для создания новых контейнеров. Давайте посмотрим, как это работает.

## <<< --- Шаг 7 — Внесение изменений в контейнер для образа Docker --- >>> ##

После запуска образа Docker вы можете создавать, изменять и удалять файлы так же, как и с помощью виртуальной машины. Эти изменения будут применяться только к данному контейнеру. Вы можете запускать и останавливать его, но после того как вы уничтожите его с помощью команды docker rm, изменения будут утрачены навсегда.

Данный раздел показывает, как сохранить состояние контейнера в виде нового образа Docker.

После установки Node.js внутри контейнера Ubuntu у вас появился контейнер, запускающий образ, но этот контейнер отличается от образа, который вы использовали для его создания. Но позже вам может снова потребоваться этот контейнер Node.js в качестве основы для новых образов.

Затем внесите изменения в новый экземпляр образа Docker с помощью следующей команды.

    docker commit -m "What you did to the image" -a "Author Name" container_id repository/new_image_name

Переключатель -m используется в качестве сообщения о внесении изменений, которое помогает вам и остальным узнать, какие изменения вы внесли, в то время как -a используется для указания автора. container_id — это тот самый идентификатор, который вы отмечали ранее в этом руководстве, когда запускали интерактивную сессию Docker. Если вы не создавали дополнительные репозитории на Docker Hub, repository, как правило, является вашим именем пользователя на Docker Hub.

Например, для пользователя sammy с идентификатором контейнера d9b100f2f2f6 команда будет выглядеть следующим образом:

    docker commit -m "added Node.js" -a "sammy" d9b100f2f636 sammy/ubuntu-nodejs

Когда вы вносите образ, новый образ сохраняется локально на компьютере. Позже в этом обучающем руководстве вы узнаете, как добавить образ в реестр Docker, например, на Docker Hub, чтобы другие могли получить к нему доступ.

Список образов Docker теперь будет содержать новый образ, а также старый образ, из которого он будет получен:

    docker images

Вывод будет выглядеть следующим образом:

Output
REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
sammy/ubuntu-nodejs   latest              7c1f35226ca6        7 seconds ago       179MB
...

В данном примере ubuntu-nodejs является новым образом, который был получен из образа ubuntu на Docker Hub. Разница в размере отражает внесенные изменения. В данном примере изменение состояло в том, что NodeJS был установлен. В следующий раз, когда вам потребуется запустить контейнер, использующий Ubuntu с предустановленным NodeJS, вы сможете использовать новый образ.

Вы также можете создавать образы из Dockerfile, что позволяет автоматизировать установку программного обеспечения в новом образе. Однако это не относится к предмету данного обучающего руководства.

Теперь мы поделимся новым образом с другими, чтобы они могли создавать из него контейнеры.

## <<< --- Шаг 8 — Загрузка образов Docker в репозиторий Docker --- >>> ##

Следующим логическим шагом после создания нового образа из существующего является предоставление доступа к этому образу нескольким вашим друзьям или всему миру на Docker Hub или в другом реестре Docker, к которому вы имели доступ. Чтобы добавить образ на Docker Hub или любой другой реестр Docker, у вас должна быть там учетная запись.

Данный раздел посвящен добавлению образа Docker на Docker Hub. Чтобы узнать, как создать свой собственный частный реестр Docker, ознакомьтесь со статьей Настройка частного реестра Docker на Ubuntu 14.04.

Чтобы загрузить свой образ, выполните вход в Docker Hub.

    docker login -u docker-registry-username

Вам будет предложено использовать для аутентификации пароль Docker Hub. Если вы указали правильный пароль, аутентификация должна быть выполнена успешно.

Примечание. Если ваше имя пользователя в реестре Docker отличается от локального имени пользователя, которое вы использовали при создании образа, вам потребуется пометить ваш образ именем пользователя в реестре. Для примера, приведенного на последнем шаге, вам необходимо ввести следующую команду:

    docker tag sammy/ubuntu-nodejs docker-registry-username/ubuntu-nodejs

Затем вы можете загрузить свой образ с помощью следующей команды:

    docker push docker-registry-username/docker-image-name

Чтобы загрузить образ ubuntu-nodejs в репозиторий sammy, необходимо использовать следующую команду:

    docker push sammy/ubuntu-nodejs

Данный процесс может занять некоторое время, необходимое на загрузку образов, но после завершения вывод будет выглядеть следующим образом:

Output
The push refers to a repository [docker.io/sammy/ubuntu-nodejs]
e3fbbfb44187: Pushed
5f70bf18a086: Pushed
a3b5c80a4eba: Pushed
7f18b442972b: Pushed
3ce512daaf78: Pushed
7aae4540b42d: Pushed

...


После добавления образа в реестр он должен отображаться в панели вашей учетной записи, как на изображении ниже.

Новый образ Docker в Docker Hub

Если при попытке добавления возникает подобная ошибка, вы, скорее всего, не выполнили вход:

Output
The push refers to a repository [docker.io/sammy/ubuntu-nodejs]
e3fbbfb44187: Preparing
5f70bf18a086: Preparing
a3b5c80a4eba: Preparing
7f18b442972b: Preparing
3ce512daaf78: Preparing
7aae4540b42d: Waiting
unauthorized: authentication required

Выполните вход с помощью команды docker login и повторите попытку загрузки. Проверьте, появился ли образ на вашей странице репозитория Docker Hub.

Теперь вы можете использовать docker pull sammy/ubuntu-nodejs, чтобы загрузить образ на новый компьютер и использовать его для запуска нового контейнера.

## <<< --- Удаление 'висячих' образов и неиспользуемых --- >>> ##

Необходимо удалить образы с тегами :.
Эти образы часто называют "висячими" (dangling images) и они обычно являются результатом обновления существующих образов или неудачных сборок.
Они занимают место на диске, но не используются.


Чтобы увидеть список всех "висячих" образов:

    docker images -f "dangling=true"


Чтобы удалить все "висячие" образы одной командой:

    docker image prune


Если вы хотите удалить их без подтверждения:

    docker image prune -f


Для более агрессивной очистки, которая удалит все неиспользуемые образы (не только "висячие"):

    docker image prune -a


Удаление этих образов поможет освободить место на диске и поддерживать чистоту вашей Docker-среды.

## <<< --- Перенос докер-образов в другое хранилище --- >>> ##

Чтобы узнать, где в системе находятся ваши Docker-образы, выполните следующую команду:

    docker info | grep "Docker Root Dir"

Это покажет корневую директорию Docker, где хранятся образы, контейнеры и другие данные.

Для переноса образов в новое место:
Остановите Docker демон:

    sudo systemctl stop docker


Создайте новую директорию для хранения данных Docker:

    sudo mkdir /new/path/docker


Скопируйте существующие данные в новую директорию:

    sudo rsync -avzP /var/lib/docker/ /new/path/docker


Измените конфигурацию Docker, отредактировав файл /etc/docker/daemon.json:

{
  "data-root": "/new/path/docker"
}



Запустите Docker демон:

    sudo systemctl start docker



После этого ваши Docker-образы будут храниться в новом месте.


## <<< --- Заключение --- >>> ##

В этом обучающем руководстве вы установили Docker, поработали с образами и контейнерами, а также добавили измененный образ на Docker Hub. После знакомства с основами, вы можете переходить к другим обучающим руководствам Docker в сообществе.

Thanks for learning with the DigitalOcean Community. Check out our offerings for compute, storage, networking, and managed databases.

Learn more about us

