### Копирование файлов

    1. Копирование одного файла в указанную директорию.:
```
    cp /path/to/source/file.txt /path/to/destination/
```

    2. Копирование файла с переименованием:
```
    cp /path/to/source/file.txt /path/to/destination/newfile.txt
```

### Копирование папок

    Копирование директории с содержимым:
```
    cp -r /path/to/source/directory /path/to/destination/
```
    Опция -r (рекурсивная) необходима для копирования папок и их содержимого.


### Полезные опции команды cp

    #### -i (interactive): Спрашивает подтверждение перед перезаписью существующих файлов.
```
    cp -i /path/to/source/file.txt /path/to/destination/
```

    #### -u (update): Копирует в случае, если исходный новее или отсутствует в директории назначения.
```
    cp -u /path/to/source/file.txt /path/to/destination/
```

    #### -v (verbose): Показывает файлы по мере их копирования.
```
    cp -v /path/to/source/file.txt /path/to/destination/
```

### Примеры

    #### Копирование нескольких файлов в одну директорию:
```
    cp /path/to/source/file1.txt /path/to/source/file2.txt /path/to/destination/
```

    #### Копирование всех файлов из одной директории в другую:
```
    cp /path/to/source/* /path/to/destination/
```

    #### Копирование всех файлов с определённым расширением:
```
    cp /path/to/source/*.txt /path/to/destination/
```

    #### Копирование папки с содержимым с подтверждением и отображением процесса:
```
    cp -irv /path/to/source/directory /path/to/destination/
```
