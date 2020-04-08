# Описание  
Скрипты предназначены для выгрузки идентификторов и удаления запущенных процессов Alfresco вместе с ассоциированными c ними задачами:
1) `generate-file-with-ids-of-active-wf.sh`   
Формирует файл, содержащий идентификаторы всех активных процессов в формате `activiti$id`.  
2) `remove-wf-with-ids-in-file.sh`   
Удаляет процессы с идентификаторами, перечисленными в выбранном файле. Может быть применен для активных (незваершенных) и завершенных процессов.   

Протестировано в Alfresco Enterprise Edition 5.1.3.3.  

**Рекомендуется использовать только на тестовых серверах с большой осторожностью.**

# Руководство по использованию

## Формирование файла с идентификаторами активных процессов

1.Скопируйте файл скрипта на тестовый сервер Alfresco.  
2.Установите бит выполнения:  
```bash
chmod +x generate-file-with-ids-of-active-wf.sh
```
3.Запустите скрипт:
```bash
./generate-file-with-ids-of-active-wf.sh $admin_account $admin_pass $file
```
где:  
`admin_account` - имя учетной записи администратора  
`admin_pass` - пароль учетной записи администратора  
 `file` - путь к выгружаемому файлу  
Пример:
```bash
 ./generate-file-with-ids-of-active-wf.sh admin SomePassword ~/proc_id.txt
cat ~/proc_id.txt
activiti$95
activiti$102
activiti$102
```

## Удаление процессов Alfresco с указанными идентификаторами в файле

1. Скопируйте файл скрипта на тестовый сервер Alfresco.  
2. Установите бит выполнения:  
```bash
chmod +x remove-wf-with-ids-in-file.sh
```
3. Запустите скрипт:
```bash
./remove-wf-with-ids-in-file.sh $admin_account $admin_pass $file
```
где:  
`admin_account` - имя учетной записи администратора  
`admin_pass` - пароль учетной записи администратора  
 `file` - путь к файлу с индентификаторами  
Пример:
```bash
 ./remove-wf-with-ids-in-file.sh admin SomePassword ~/proc_id.txt
Warning! Alfresco workflows instances with ids in file /home/user/proc_id.txt will be removed on ALFRESCO-SERVER
Press ENTER to to continue or Ctrl+c for cancel
```

## Получение идентификаторов завершенных процессов Alfresco в SQL

Сформировать список завершенных процессов в SQL (можно скопировать вывод в текстовый файл):
```sql
SELECT DISTINCT 'activiti$' + [PROC_INST_ID_]
FROM [DB_NAME].[dbo].[ACT_HI_PROCINST]
```
По аналогии использовать скрипт `remove-wf-with-ids-in-file.sh` для их удаления.