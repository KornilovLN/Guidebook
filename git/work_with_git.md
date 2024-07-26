## Кратко об инициализации проекта с помощью git и отправки на github 

**_Создание локального git репозитория:_**
```
git init
```

**_Создание файла .gitignore:_**
```
echo "sunpp/" > .gitignore
echo "new_folder/" >> .gitignore
echo "sunpp/" >> .gitignore
```

**_Добавление всех файлов, кроме игнорируемых:_**
```
git add .
```

**_Создание первого коммита:_**
```
git commit -m "Initial commit"
```

**_Создание репозитория на GitHub:_**

- 1 Перейдите на GitHub и войдите в свой аккаунт
- 2 Нажмите "+" в верхнем правом углу и выберите "New repository"
- 3 Введите имя репозитория и другие настройки
- 4 Не инициализируйте репозиторий с README, .gitignore или лицензией
- 5 Нажмите "Create repository"

**_Связывание локального репозитория с удаленным_**
    (замените YOUR_USERNAME и YOUR_REPO_NAME):
```
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
```

**_Отправка (push) локального репозитория на GitHub:_**
```
git push -u origin master
```

**_Если вы используете аутентификацию по SSH вместо HTTPS,_**
```
замените URL в шаге 6 на SSH-версию.
```
