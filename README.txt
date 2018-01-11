#ПОДГОТОВКА:
Программный комплекс разрабатывался и тестировался на python версии 3.5.2
Поддержка более старых версий не гарантируется.

Python модули:

$> sudo pip3 install pycparser CppHeaderParser jinja2


#IOTACE:
Для генерации интерфейса используется файл "iotace.py" с различными входными данными.

Основные аргументы:
-header  -> полный путь к заголовочному файлу

-out     -> допустимые значения:
            duktape[,civetweb]
            nodejs[,nodered]

-sources -> полный путь к объектному файлу

Все возможные флаги можно посмотреть командой:

$> python3 iotace.py -h


По умолчанию, реузльтирующий код будет располагаться в папке "build/"

#Метаданные
Метаданные необходимо задавать в заголовчном файле, путем добавления комментариев перед функцией.
Например:
/**
 * \param array [in, array[int array_len]]
*/
int put_array(int *array, int array_len);

Первый параметр - in | out | in/out
Все параметры, указанные как out или in/out будут возвращены JS функцией в виде объекта.

Второй параметр - array[size]
Данный параметр является необязательным. Он указывается на то, что переменная является массивом размером size.


Генерация кода будет производиться на пример EApi.
В папке "tests/EAPI/" уже содержится заголовочный файл eapi.h с прописанными метаданными.


#DUKTAPE + CIVETWEB:
Сгенерировать код для данной связки можно следующей командой:

$> sh scripts/build_duktape_civetweb.sh

Далее переходим в папку "build/", выполняем сборку и запуск:

$> cd build/ 
$> make 
$> ./main

Сервер будет доступен по адресу: 
http://127.0.0.1:8888


#NODEJS + NODERED:
=========================================================
Сгенерировать код для данной связки можно следующей командой:
$> ./scripts/build_nodejs_nodered.sh

Для запуска кода необходимо иметь следующую утилиту:
$> sudo npm install -g node-gyp

$> npm install eapi
$> npm install node-red_eapi
$> nodejs node_modules/node-red/red.js

go to http://localhost:1880/

or use eapi without node-red:
--------------------------------
$> npm install eapi
$> nodejs
> var eapi=require('eapi')
undefined
> eapi.EApiLibInitialize()
{ EApiLibInitialize: 0 }
> eapi.EApiBoardGetStringA(0,255)
{ EApiBoardGetStringA: 0, pBuffer: 'Kontron AG', pBufLen: 11 }











