## Создать автоматизированную загрузку и запуск ряда скриптов при старте linux системы

#### Прямой способ запуска 2-х скриптов при старте системы**
**_Создайте файл автозапуска:_**
* Перейдите в ~/.config/autostart
```
cd ~/.config/autostart
```
* Создайте новый .desktop файл, например start_scripts.desktop.
```
mkdir start_scripts.desktop
```
* Отредактируйте файл:
```
[Desktop Entry]
Type=Application
Exec=gnome-terminal -- bash -c "cd $HOME/virt/work_place && ./menu_work.py; bash" & gnome-terminal -- bash -c "cd $HOME/virt/work_place && ./starter.py; bash"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Start Scripts
Name=Start Scripts
Comment[en_US]=Launches scripts in terminal windows
Comment=Launches scripts in terminal windows
```$HOME/virt/work_place/access_cloud_vital/

#### Запуск n скриптов при старте системы**
**_Создайте файл start_scripts.sh:_**
* Перейдите в ~/.config/autostart
```
cd ~/.config/autostart
nano start_scripts.sh
```
* Отредактируйте start_scripts.sh:
```
#!/bin/bash

scripts=(
    "$HOME/virt/work_place/menu_work.py"
    "$HOME/virt/work_place/starter.py"
    # Добавьте сюда столько скриптов, сколько нужно
)

for script in "${scripts[@]}"; do
    gnome-terminal -- bash -c "cd $(dirname "$script") && $(basename "$script"); bash"
done
```
* Сделайте этот файл исполняемым:
```
chmod +x start_scripts.sh
```
* Создайте файл автозапуска ~/.config/autostart/start_scripts.desktop:

[Desktop Entry]
Type=Application
Exec=~/.config/autostart/start_scripts.sh
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_US]=Start Scripts
Name=Start Scripts
Comment[en_US]=Launches multiple scripts in terminal windows
Comment=Launches multiple scripts in terminal windows

