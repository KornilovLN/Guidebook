## Некоторые часто встречающиеся операторы bash
 
#### 1. Условные операторы:
```
if [ $a -eq 1 ]; then
    echo "a равно 1"
elif [ $a -eq 2 ]; then
    echo "a равно 2"
else
    echo "a не равно 1 или 2"
fi
```

```
case $var in
    1) echo "один" ;;
    2) echo "два" ;;
    *) echo "другое" ;;
esac
```


#### 2. Циклы:
```
for i in 1 2 3; do
    echo $i
done

while [ $count -lt 5 ]; do
    echo $count
    ((count++))
done

until [ $count -ge 5 ]; do
    echo $count
    ((count++))
done
```


#### 3. Функции:
```
function greet() {
    echo "Привет, $1!"
}
greet "Мир"
```


#### 4. Переменные:
```
NAME="John"
echo $NAME
```


#### 5. Арифметические операции:
```
let result=5+3
echo $((10 * 2))
sum=$((5 + 3))
```


#### 6. Логические операторы:
```
[ $a -eq 1 ] && echo "a равно 1" || echo "a не равно 1"
```


#### 7. Перенаправление:
```
echo "Hello" > file.txt
cat < file.txt
ls | grep .txt
```


#### 8. Работа с файлами:
```
if [ -f "file.txt" ]; then
    echo "Файл существует"
fi
```


#### 9. Обработка параметров:
```
echo "Первый аргумент: $1"
echo "Все аргументы: $@"
echo "Количество аргументов: $#"
```


#### 10. Подстановка команд:
```
current_date=$(date)
echo "Текущая дата: $current_date"
```
