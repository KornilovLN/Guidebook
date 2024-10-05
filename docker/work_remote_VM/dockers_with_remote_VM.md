## Два способа использования образов
<br>с сервера vavilon
<br>на новом сервере 192.168.88.105,
<br>управляя процессом с вашей хост-машины.

#### Способ 1: Перенос образов на новый сервер

**_Для этого способа мы создадим скрипт, который будет копировать образы с сервера vavilon на новый сервер_**
<br>transfer_images.sh
<br>скрипт:
* Определяет список образов для переноса.
* Создает функцию transfer_image, которая сохраняет образ на сервере vavilon и загружает его на новый сервер.
* Проходит по списку образов и переносит каждый из них.

```
#!/bin/bash

# Список образов для переноса
images=(
    "weaveworks/weave:2.3.0"
    "registry.master.cns/master/traefik:1.7.9"
    "registry.master.cns/netra:4.5.33"
    "registry.master.cns/st2:4.5.33"
    "registry.master.cns/apt_cacher:19.03.20"
    "registry.master.cns/pki:4.5.0"
    "registry.master.cns/devpi:19.03.20"
    "registry.master.cns/frontend:4.5.11"
    "registry.master.cns/virtuoso:7.2.5.1"
    "registry.master.cns/rtdb:4.5.11"
    "registry.master.cns/brama:4.5.33"
    "registry.master.cns/postgres:10-19.03.20"
    "registry.master.cns/registry:2.7.1"
    "registry.master.cns/mongodb:3.4.15"
    "registry.master.cns/rabbitmq:3.7.13"
)

# Функция для переноса образа
transfer_image() {
    local image=$1
    echo "Перенос образа: $image"
    ssh starmark@vavilon "docker save $image" | ssh starmark@192.168.88.105 "docker load"
}

# Перенос каждого образа
for image in "${images[@]}"; do
    transfer_image "$image"
done

echo "Перенос образов завершен"
```



#### Способ 2: Работа с удаленными ресурсами

**_Для этого способа мы создадим Docker Compose файл, который будет использовать образы напрямую с сервера vavilon_**
<br>docker-compose.yml
<br>Этот Docker Compose файл:
* Определяет сервисы, соответствующие контейнерам из вашего списка.
* Использует образы напрямую с сервера vavilon, указывая полный путь к образу.
* Настраивает команды запуска и порты для каждого сервиса.

```
version: '3.8'

services:
  weave:
    image: starmark@vavilon:weaveworks/weave:2.3.0
    command: ["/home/weave/weaver", "--port", "6783", "--nickname", "vavilon.office.ivl.ua", "--host-root=/host", "--docker-bridge", "docker0", "--weave-bridge", "weave", "--datapath", "datapath", "--ipalloc-range", "10.32.0.0/12", "--dns-listen-address", "172.17.0.1:53", "--ht$"]

  proxy:
    image: starmark@vavilon:registry.master.cns/master/traefik:1.7.9
    command: ["/usr/bin/dumb-init", "--", "/traefik"]
    ports:
      - "80:80"
      - "443:443"
      - "8080:8080"

  route_dc:
    image: starmark@vavilon:registry.master.cns/netra:4.5.33
    command: ["/usr/bin/dumb-init", "--", "socat", "-d", "TCP-LISTEN:80,bind=0.0.0.0,fork,reuseaddr", "tcp:dc.cns:80,end-close,shut-none"]

  # Добавьте остальные сервисы аналогичным образом
```

**_Для автоматизации работы с этими способами, создадим управляющий скрипт:_**
<br>manage_project.sh
<br>Этот скрипт позволяет:
* Копировать необходимые файлы на новый сервер.
* Запускать процесс переноса образов (для способа 1).
* Запускать Docker Compose для работы с удаленными образами (для способа 2).


```
#!/bin/bash

# Путь к проекту на новом сервере
PROJECT_PATH="/home/starmark/spd"

# Функция для копирования файлов на новый сервер
copy_files() {
    scp transfer_images.sh docker-compose.yml starmark@192.168.88.105:$PROJECT_PATH/
}

# Функция для запуска переноса образов
transfer_images() {
    ssh starmark@192.168.88.105 "bash $PROJECT_PATH/transfer_images.sh"
}

# Функция для запуска Docker Compose
run_compose() {
    ssh starmark@192.168.88.105 "cd $PROJECT_PATH && docker-compose up -d"
}

# Основной процесс
case "$1" in
    "copy")
        copy_files
        ;;
    "transfer")
        transfer_images
        ;;
    "run")
        run_compose
        ;;
    *)
        echo "Использование: $0 {copy|transfer|run}"
        exit 1
        ;;
esac

echo "Операция завершена"
```

#### Использование:
1. ./manage_project.sh copy - копирует файлы на новый сервер.
2. ./manage_project.sh transfer - запускает перенос образов (способ 1).
3. ./manage_project.sh run - запускает Docker Compose (способ 2).

<br>Эти скрипты предоставляют автоматизированный способ управления проектом
<br>с хост-машины, позволяя легко переносить образы или работать с удаленными ресурсами.

### Управление docker образами и контейнерами

**_Представленный скрипт выполняет следующие функции:_**
* Определяет список доступных контейнеров.
* Позволяет пользователю выбрать контейнер из списка.
* Предоставляет три основных действия:
> Остановка и удаление контейнера (с подтверждением).
> Удаление образа контейнера (с подтверждением).
> Перезапуск контейнера с возможностью пересборки образа.

**_Для использования скрипта:_**
* Сохраните его на вашей локальной машине, например, как manage_containers.sh.
* Сделайте скрипт исполняемым: chmod +x manage_containers.sh.
* Запустите скрипт: ./manage_containers.sh.

<br>Скрипт будет взаимодействовать с вами, запрашивая необходимую информацию и подтверждения для выполнения операций.

<br>Важно отметить, что этот скрипт предполагает, что на удаленном сервере (192.168.88.105)
<br>установлен Docker и Docker Compose, и
<br>что у вас есть необходимые права доступа для выполнения Docker-команд.

<br>Также, перед использованием скрипта в производственной среде, 
<br>рекомендуется тщательно протестировать его на тестовом окружении,
<br>чтобы убедиться, что все операции выполняются корректно и безопасно.


```
#!/bin/bash

# Список контейнеров
containers=(
    "weave" "proxy" "route_dc" "st2" "backend" "route_znpp" "apt" "pki" "devpi"
    "www" "meta" "rtdb-hub" "brama" "postgres" "registry" "mongo" "mq" "netra"
)

# Функция для вывода списка контейнеров
print_containers() {
    echo "Доступные контейнеры:"
    for i in "${!containers[@]}"; do
        echo "$((i+1)). ${containers[$i]}"
    done
}

# Функция для выбора контейнера
select_container() {
    print_containers
    read -p "Выберите номер контейнера: " choice
    index=$((choice-1))
    if [ "$index" -ge 0 ] && [ "$index" -lt "${#containers[@]}" ]; then
        echo "${containers[$index]}"
    else
        echo "Неверный выбор"
        exit 1
    fi
}

# Функция для остановки и удаления контейнера
stop_and_remove_container() {
    local container=$1
    echo "Останавливаем контейнер $container..."
    ssh starmark@192.168.88.105 "docker stop $container"
    read -p "Вы уверены, что хотите удалить контейнер $container? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        echo "Удаляем контейнер $container..."
        ssh starmark@192.168.88.105 "docker rm $container"
    fi
}

# Функция для удаления образа
remove_image() {
    local container=$1
    local image=$(ssh starmark@192.168.88.105 "docker inspect --format='{{.Config.Image}}' $container")
    read -p "Вы уверены, что хотите удалить образ $image? (y/n): " confirm
    if [ "$confirm" = "y" ]; then
        echo "Удаляем образ $image..."
        ssh starmark@192.168.88.105 "docker rmi $image"
    fi
}

# Функция для перезапуска контейнера
restart_container() {
    local container=$1
    local rebuild=$2
    if [ "$rebuild" = "y" ]; then
        echo "Пересобираем и перезапускаем контейнер $container..."
        ssh starmark@192.168.88.105 "docker-compose up -d --build $container"
    else
        echo "Перезапускаем контейнер $container без пересборки..."
        ssh starmark@192.168.88.105 "docker-compose up -d $container"
    fi
}

# Основной процесс
echo "Выберите действие:"
echo "1. Остановить и удалить контейнер"
echo "2. Удалить образ"
echo "3. Перезапустить контейнер"
read -p "Введите номер действия: " action

case $action in
    1)
        container=$(select_container)
        stop_and_remove_container "$container"
        ;;
    2)
        container=$(select_container)
        remove_image "$container"
        ;;
    3)
        container=$(select_container)
        read -p "Пересобрать образ перед запуском? (y/n): " rebuild
        restart_container "$container" "$rebuild"
        ;;
    *)
        echo "Неверный выбор действия"
        exit 1
        ;;
esac

echo "Операция завершена"
```

