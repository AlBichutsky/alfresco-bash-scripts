#!/usr/bin/env bash

# Скрипт формирует отчет об использованных лицензиях Alfresco в html-формате и отправляет на почту 

file_json=people.json       # имя файла json 
file_csv=people.csv         # имя csv-файла
file_html=report.html       # имя html-файла (файл репорта)

date=$(date +"%d.%m.%Y")             # формат даты в репорте
name_company='ООО "Имя компании"'    # название компании в репорте 
count_total_lic=200                  # кол-во приобретенных лицензий
count_used_lic=0                     # кол-во использованных лицензий (инкрементируемый порядковый номер авторизованного пользователя)

# Настройка отправки писем

# Для отправки писем через smtp-сервер gmail требуется перейти в аккаунт google => безопасность: 
# 1. отключить 2-х факторную аутентификацию;
# 2. разрешить ненадежным приложениям доступ к аккаунту.
#
# Далее создаем новый сертификат и БД ключей:
# mkdir ~/.certs
# certutil -N -d ~/.certs
# извлекаем сертфикат с gmail и импортируем cert-файл в новую БД:
# echo -n | openssl s_client -connect smtp.gmail.com:465 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ~/.certs/gmail.crt
# certutil -A -n "Google Internet Authority" -t "C,," -d ~/.certs -i ~/.certs/gmail.crt 

sender="from_mail@gmail.com"              # e-mail отправителя
receiver="to_mail@domain.com"             # e-mail получателя основной
receiver_copy="to_mail_copy80@domain.ru"  # e-mail получателя в копии  
mail_subject="Cтатистика использования лицензий Alfresco в $name_company"  # тема письма
mail_text="См. отчет во вложении"         # текст письма
auth_login="mailname@domainl.com"         # логин
auth_password="MyMailPassword"            # пароль
cert_dir="~/.certs/"                      # каталог с сертификатом gmail

# Проверяем наличие старых исходных файлов перед формированием репорта и удаляем их
if [ -f $file_json ]; then rm -f $file_json; fi
if [ -f $file_csv ]; then rm -f $file_csv; fi
if [ -f $file_html ]; then rm -f $file_html; fi

# формируем исходный json-файл с информацией о пользователях
curl -u admin:admin "http://localhost:8080/alfresco/s/api/people" > $file_json

# определяем общее кол-во контейнеров с пользователями в файле json (значение ключа pagin.totalItems)
total_count=$(jq '.paging.totalItems' $file_json)

### Формирование csv-файла из json-файла ###

# рекурсивно парсим значения для указанных ключей в каждом контейнере 
 for count in $(seq 0 $total_count)
    do
        userName=$(jq .people[$count].userName $file_json | tr -d '"')    # имя учетной записи
	firstName=$(jq .people[$count].firstName $file_json | tr -d '"')  # имя пользователя 
	lastName=$(jq .people[$count].lastName $file_json | tr -d '"')    # фамилия пользователя
	email=$(jq .people[$count].email $file_json | tr -d '"')          # e-mail
        enabled=$(jq .people[$count].enabled $file_json | tr -d '"')      # включен?
        isDeleted=$(jq .people[$count].isDeleted $file_json | tr -d '"')  # удален?
	authorizationStatus=$(jq .people[$count].authorizationStatus $file_json | tr -d '"') # статус авторизации 

	# 2-й способ фильтрации записей json без grep (ищем все userName, у которых authorizationStatus=AUTHORIZED)
        # userName=$(jq '.people[$count] | select(.authorizationStatus=="AUTHORIZED") | .userName' $file)

        # если в контейнере находится авторизованный пользователь, инкрементируем его порядковый номер  
        if [[ $authorizationStatus = "AUTHORIZED" ]];then ((count_used_lic++)); fi

        # формируем в .csv набор записей, фильтруя по статусу авторизации = AUTHORIZED
        echo -n "$count_used_lic;$userName;$firstName;$lastName;$email;$enabled;$isDeleted;$authorizationStatus" | grep -w "AUTHORIZED" >> $file_csv
   done

# определяем кол-во доступных лицензий
count_free_lic=$(($count_total_lic-$count_used_lic))

### Формирование html-репорта ###

cat >$file_html<<EOF
<html>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<title>Отчет: статистика использования лицензий Alfresco в $name_company</title>
</head>
<body>
<font color="#696969">Дата формирования: $date</font><BR>
<font color="#696969">Имя сервера: $HOSTNAME</font><BR>
<font color="#696969">Организация: $name_company</font><BR>
<H3>Статистика использования лицензий Alfresco</H3>
Количество лицензий:<BR>
<table border="1" style="border-collapse: collapse; bording-spacing: 0; border: 1px solid #87CEFA;">
<tr style="background-color: #87CEFA; font-weight: bold">
<td>Всего</td>
<td>Использовано</td>
<td>Доступно</td>
</tr>
<td>$count_total_lic</td>
<td>$count_used_lic</td>
<td>$count_free_lic</td>
</table>
<BR>
Список авторизованных пользователей:<BR>
<table border="1" style="border-collapse: collapse; bording-spacing: 0; border: 1px solid #87CEFA;">
<tr style="background-color: #87CEFA; font-weight: bold">
<td>№</td>
<td>Учетная запись</td>
<td>Имя</td>
<td>Фамилия</td>
<td>E-MAIL</td>
<td>Включена?</td>
<td>Удалена?</td>
<td>Статус авторизации</td>
</tr>
EOF

# добавляем в репорт ячейки таблицы с записями из .csv-файла 
while read INPUT ; do
echo "<tr><td>${INPUT//;/</td><td>}</td></tr>" >> $file_html ;
done < $file_csv ;

cat >>$file_html<<EOF
</table>
</body>
</html>
EOF

# Отправляем репорт на почту
echo "$mail_text" | mailx -v \
-b "$receiver_copy" \
-s "$mail_subject" \
-a $file_html \
-S smtp-use-starttls \
-S ssl-verify=ignore \
-S smtp-auth=login \
-S smtp=smtp://smtp.gmail.com:587 \
-S from="$sender" \
-S smtp-auth-user="$auth_login" \
-S smtp-auth-password="$auth_password" \
-S nss-config-dir=$cert_dir \
-S ssl-verify=ignore \
"$receiver"