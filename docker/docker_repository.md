0. Общая информация о Docker:
<br>Чтобы получить полную информацию о вашей Docker установке,
<br>включая расположение различных компонентов:
```
docker info
```

1. Образы (Images):
   <br>Docker образы обычно хранятся в директории /var/lib/docker/image на Linux системах.
   <br>Однако, точная информация о расположении образов:
```   
docker info | grep "Docker Root Dir"
```
- Ответ:
``` 
WARNING: No swap limit support
Docker Root Dir: /mnt/poligon/docker-data
``` 

2. Контейнеры (Containers):
<br>Файлы контейнеров обычно находятся в /var/lib/docker/containers.
<br>Точная информация о конкретном контейнере, включая его расположение:
```
docker inspect <container_id_or_name> 
```

3. Тома (Volumes):
<br>Docker тома по умолчанию хранятся в /var/lib/docker/volumes.
<br>Чтобы получить информацию о конкретном томе:
```
docker volume inspect <volume_name>
```

4. Сети (Networks):
<br>Информация о Docker сетях хранится в /var/lib/docker/network.
<br>Для получения подробностей о конкретной сети:
```
docker network inspect <network_name>
```

5. Конфигурационный файл Docker:
<br>Основной конфигурационный файл Docker обычно находится в /etc/docker/daemon.json.
<br>Он может содержать информацию о настройках хранения.

6. Списки:
```
docker images
docker image ls

docker ps
docker ps -a
```

7. Конфигурационный файл Docker:
```
cat /etc/docker/daemon.json
# ответ: Пока тут только адрес репозитория

{
  "data-root": "/mnt/poligon/docker-data"
}
```

8. Проверка логов Docker:
```
journalctl -u docker.service
# ответ:

Hint: You are currently not seeing messages from other users and the system.
      Users in groups 'adm', 'systemd-journal' can see all messages.
      Pass -q to turn off this notice.
-- Logs begin at Sat 2024-07-06 09:33:21 EEST, end at Mon 2024-09-09 18:36:02 EEST. --
-- No entries --
```

9. Настройка автозапуска Docker:
```
sudo systemctl enable docker
# ответ:
[sudo] пароль для leon:          
Synchronizing state of docker.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable docker
```


