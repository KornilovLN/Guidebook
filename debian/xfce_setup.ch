## XFCE setup in Debian
# **_https://linuxthebest.net/yak-vstanoviti-xfce-na-debian-12-11-10/_**

#### Установка

sudo apt update && sudo apt upgrade
sudo apt install task-xfce-desktop
sudo reboot

sudo apt update && sudo apt upgrade


# Переключение менеджеров отображения по умолчанию
```sudo dpkg-reconfigure lightdm```
# Не забудьте перезагрузить систему при переключении между окружениями рабочего стола

# Удаление XFCE из Debian Linux
```sudo apt autoremove '^xfce' task-xfce-desktop --purge```

# Если вы хотите переустановить среду рабочего стола GNOME после удаления
```
sudo apt update
sudo apt install gnome gdm3 task-gnome-desktop --reinstall
```

# Перед перезагрузкой системы убедитесь, что GDM включен.
# Если вы забудете это сделать, вы можете загрузиться в терминал или сервер.
# Если это произойдет, вы можете вернуть вход в рабочий стол GNOME:
```
sudo systemctl enable gdm --now
sudo reboot
```




