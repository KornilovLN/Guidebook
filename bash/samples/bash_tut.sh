#!/bin/bash

#--- cmd: echo
echo "Hi, 'bash_tut'!"

echo $PATH
#-> /home/leon/anaconda3/bin:/home/leon/anaconda3/condabin:/home/leon/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/leon/.local/share/JetBrains/Toolbox/scripts

echo $HOME
#-> /home/leon

#--- Для работы создать каталог bash
cd /home/leon/work/dev
mkdir bash
cd bash

#--- Текущий каталог
pwd
#-> /home/leon/work/dev/bash

#--- cmd: which rustup rustc cargo rustdoc ...
which rustup rustc cargo rustdoc
#-> /home/leon/.cargo/bin/rustup
#-> /home/leon/.cargo/bin/rustc
#-> /home/leon/.cargo/bin/cargo
#-> /home/leon/.cargo/bin/rustdoc

which echo
#-> /user/bin/echo

#----------------------------------------------------------------------------------------------

#--- Создадим командный файл intro в папке со скриптами /home/leon/work/dev/bash

#!/bin/bash
#echo "Найти путь к neqn:" 
#path_neqn=$(which neqn)
#echo "Вывести найденный путь к neqn -> $path_neqn"
#echo "распечатать найденный neqn    :"
#cat $path_neqn
#echo " "
#echo "или так    :"
#cat $(which neqn)

#--- Укажем путь к папке с нашими скриптами в файле .bashrc с пом редактора ZB: xed
...
export PATH="$PATH:/home/leon/work/dev/bash"
...
#--- Сохраним .bashrc и перезапустим терминал

#--- Разрешим скрипту intro исполняться
chmod +x intro

#--- Теперь можно запускать, тк файл прописан в PATH и имеет разрешение на запуск

#----------------------------------------------------------------------------------------------

#--- Как распечатать часть строки
var="something wicked this way comes..."
echo ${var:10}
#-> wicked this way comes...
echo ${var:10:6}
#-> wicked


