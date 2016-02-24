#!/bin/bash
#Подключаем конфиг
source /etc/ddnsy/ddnsy.conf

#Задаём переменные
IP=`curl -s $site` #Получаем значение текущего IP
R_IP=`curl -s $reserve_site` #Запасной сайт для определения IP, пока не использую
OLD_IP=`cat /etc/ddnsy/old-ip` #Получаем значение старого IP из файла

rm $last_log #Чистим ласт лог
exec > $last_log #Пишем в ласт лог выхлоп скрипта

date #Вывод даты для логирования

#Проверяем одинаковые IP или нет
if [[ "$IP" != "$OLD_IP" ]]
then #Если не одинаковые выполняем:
	echo "Получен новый IP адрес"

	echo "Старый IP: $OLD_IP" #Выводим старый IP
	echo "Новый IP: $IP" #Выводим новый IP

	echo "Записываю новый IP в файл"
	echo "$IP" > /etc/ddnsy/old-ip #Изменение старого IP в файле

	echo "Вношу новый IP на NSы"
	curl -H "PddToken: $token" -d "domain=$domain&record_id=$id_record_a&ttl=$ttl&content=$IP" "$y_address" #Изменяем главную А запись на NS
	curl -H "PddToken: $token" -d "domain=$domain&record_id=$id_additional_record&ttl=$ttl&content=$IP" "$y_address" #Изменяем www А запись на NS

	echo "Операция завершена"
else # Если одиноковые выполняем:
	echo "IP адрес не изменился (Старый IP: $OLD_IP)"
fi #Выходим из условия

echo "--------------------" >> $log #Запись в файл прочерков, сделал для того чтоб отделить одну запись от другой
cat $last_log >> $log #Переносим инфу из ласт лога в общий лог
echo "--------------------" >> $log #Те же прочерки
