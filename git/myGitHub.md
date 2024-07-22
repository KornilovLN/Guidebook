## Сервер Git в вашей домашней сети

Если вам нужен собственный репозиторий Git в вашей домашней сети,
вы можете настроить его локально на вашем сервере или любой машине в вашей сети.
Вот несколько вариантов:

### Вариант 1: Настройка простого Git-сервера

**1. Установите Git на сервере:**

```
sudo apt-get update
sudo apt-get install git
```

**2. Создайте каталог для репозитория:**

```
mkdir -p /path/to/repo.git
cd /path/to/repo.git
git init --bare
```

**3. Настройка доступа по SSH:**

    Убедитесь, что SSH сервер запущен:
```
sudo systemctl status ssh
```

    Добавьте публичный ключ вашего локального пользователя
    в файл 
    ~/.ssh/authorized_keys на сервере.

**4. Клонирование репозитория с другого компьютера:**

```
git clone ssh://username@hostname:/path/to/repo.git
```

### Вариант 2: Использование GitLab CE (Community Edition)

    GitLab CE — это полноценная платформа для управления репозиториями Git
                с множеством функций, аналогичных GitHub и GitLab.

**1. Установка GitLab CE:**

    Следуйте инструкциям для вашей операционной системы на официальном сайте GitLab.

**2. Для Ubuntu/Debian:**

```
sudo apt-get update
sudo apt-get install -y curl openssh-server ca-certificates
sudo apt-get install -y postfix
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
sudo EXTERNAL_URL="http://gitlab.example.com" apt-get install gitlab-ce
```
    
**3. Настройка GitLab:**

    После установки откройте браузер и перейдите по адресу, который вы указали в EXTERNAL_URL 
    (например, http://gitlab.example.com).
    Настройте аккаунт администратора и создайте новые проекты.

### Вариант 3: Использование Gitea

    Gitea — легковесная, самообслуживаемая платформа для размещения Git-репозиториев.

**1. Установка Gitea:**

    Следуйте инструкциям на официальном сайте Gitea.

**2. Для Ubuntu/Debian:**

```
wget -O gitea https://dl.gitea.io/gitea/1.15.6/gitea-1.15.6-linux-amd64
chmod +x gitea
sudo mv gitea /usr/local/bin/
```

**3. Создание пользователя и директории для Gitea:**

```
sudo adduser --system --shell /bin/bash --gecos 'Git Version Control' --group --disabled-password --home /home/git git
sudo mkdir -p /var/lib/gitea/{custom,data,log}
sudo chown -R git:git /var/lib/gitea/
sudo chmod -R 750 /var/lib/gitea/
sudo mkdir /etc/gitea
sudo chown root:git /etc/gitea
sudo chmod 770 /etc/gitea
```

**4. Настройка системного сервиса:**

    Создайте файл сервиса для Gitea:

```
sudo nano /etc/systemd/system/gitea.service
```

**5. Добавьте следующее содержимое:**

```
ini

[Unit]
Description=Gitea
After=syslog.target
After=network.target
After=mariadb.service
After=mysqld.service
After=postgresql.service
After=memcached.service
After=redis.service

[Service]
RestartSec=2s
Type=simple
User=git
Group=git
WorkingDirectory=/var/lib/gitea/
ExecStart=/usr/local/bin/gitea web --config /etc/gitea/app.ini
Restart=always
Environment=USER=git HOME=/home/git GITEA_WORK_DIR=/var/lib/gitea

[Install]
WantedBy=multi-user.target
```

**6. Запустите и активируйте сервис:**

```
sudo systemctl daemon-reload
sudo systemctl enable gitea
sudo systemctl start gitea
```

**7. Настройка Gitea через веб-интерфейс:**

    Откройте браузер и перейдите по адресу вашего сервера (например, http://hostname:3000).
    Следуйте инструкциям для завершения настройки.

### Теперь у вас будет:
    
    собственный репозиторий Git в вашей домашней сети,
    доступный по вашему локальному IP-адресу.
