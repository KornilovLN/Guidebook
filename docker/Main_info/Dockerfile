# Используйте официальный образ Python как базовый
FROM python:3.8

# Установите рабочую директорию в контейнере
WORKDIR /home

# Создайте директорию для логов
RUN mkdir logs

# Скопируйте файл test.py в рабочую директорию
COPY test_cicle.py .

# Запустите test.py при запуске контейнера
CMD [ "python", "./test_cicle.py" ]
