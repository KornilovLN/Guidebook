## Для копирования файлов с локального хоста на удаленный сервер по SSH

1. Использовать команду scp:

**_scp      /path/to/local/file       starmark@gitlab.ivl.ua:/path/to/remote/destination_**


2. Скопировать директорию, добавить флаг -r:

**_scp -r   /path/to/local/directory  starmark@gitlab.ivl.ua:/path/to/remote/destination_**
