#!/bin/bash

echo "Найти путь к neqn:" 
path_neqn=$(which neqn)
echo "Вывести найденный путь к neqn -> $path_neqn"

echo "распечатать найденный neqn    :"
cat $path_neqn

echo " "

echo "или так    :"
cat $(which neqn)
