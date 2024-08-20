## Доступ к VPN серверу посредством wireguard

#### Установка и настройка WireGuard VPN client -> Debian Linux

**_Инсталлировать wireguard_**
```
sudo apt update
sudo apt upgrade
sudo apt install wireguard
```

**_Зайти в папку установки_**
```
cd /etc/wireguard
```

**_Сгенерировать ключи:_**
```
sudo wg genkey | tee privatekey | wg pubkey | tee publickey
```

**_Приватный ключ использовать в файле конфигурации:_**
```
sudo cat ./privatekey
```

**_Публичный ключ передать на сервер:_**
```
sudo cat ./publickey
```

**_Создать файл конфигурации:_**
```
sudo touch wg0.conf
```

**_И заполнить его следующими настройками:_**
```
[Interface]
# Private Key of the WireGuard Client
PrivateKey = Подставить-сюда-ранее-сгенерированный-приватный-ключ
# VPN IP Address of the Client
Address = 10.10.10.xxx/24

[Peer]
# Public Key of the WireGuard VPN Server
PublicKey = C7AQPHCyKSdaIPCB189RFWp4xyatEXp2vfHWQLmrfQw=

# White IP Address & port of the WireGuard server
Endpoint = 178.151.114.211:13231

# Allowed IP Addresses
AllowedIPs = 10.10.10.1/32, 192.168.88.0/24
```

**_up интерфейс:_**
```
sudo wg-quick up wg0
```

**_Посмотреть состояние интерфейса:_**
```
sudo wg show
```

**_down интерфейс:_**
```
sudo wg-quick down wg0
```

**_Сделать подключение постоянным:_**
```
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0
```

**_show status интерфейса:_**
```
sudo wg show

[sudo] пароль для leon:          
interface: wg0
  public key: nCzQr5y9jZ3OqrmgmuFdFx9wzyzc8bUk3So2rBuBgk4=
  private key: (hidden)
  listening port: 44755

peer: C7AQPHCyKSdaIPCB189RFWp4xyatEXp2vfHWQLmrfQw=
  endpoint: 178.151.114.211:13231
  allowed ips: 10.10.10.1/32, 192.168.88.0/24
  latest handshake: 1 minute, 11 seconds ago
  transfer: 137.49 MiB received, 2.19 GiB sent
```

#### wireguard #vpn

**_Вход (чебурашки) на сервер VPN через браузер с большой машины_**
```
http://192.168.88.15:8006
6002 (VM2)
6003 (VM3)
user: starmark
pasw: j21C4dR65k@
```

**_Вход (чебурашки) на сервер VPN через браузер с ноутбука_**
```
http://192.168.88.15:8006
6002 (VM2)
6003 (VM3)
user: starmark
pasw: j21C4dR65k@
```
