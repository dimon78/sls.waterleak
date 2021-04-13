данная реализация основана на базе sls, реле двухзонное и датчиках протечки от aqara 

time - время работы крана октрыть/закрыть, в данном примере 10 сек

wl - список реле и датчиков FriendlyName

в примере три зоны защиты от протечки, в кажой из которых свои датчики

{['wl_relay_1'] = {'wl_sensor_1', 'wl_sensor_2'}, ['wl_relay_2'] = {'sensor_3', 's4', 's5'}, ['wl_relay_3'] = {'s6'}}

wl_relay_1 - первая зона, в неё входят два датчика от протечки wl_sensor_1 и wl_sensor_2

wl_relay_2 - вторая зона, в неё входят три датчика от протечки sensor_3, s4 и s5

wl_relay_3 - третья зона, в ней всего один датчик от протечки s6

auto - режим снятия аварии (открытие крана) после протечки. true - автоматически после высыхания датчиков протечки, false - ручное (master), после высыхания датчиков и закрытия/открытия кранов

объекты:

master - ручное перекрытие всех кранов, по кнопке или любому другому событию пишем в объект os.time()

service - режим защиты от закипания кранов, по дефолту раз в сутки каждые 86400 сек. или пишем в него время в unixtime формате когда произвести данную операцию

имя_реле_leak	- false - нет протечки в даноой зоне, true - есть протечка	

имя_реле_open - true - кран открыт, false - кран закрыт

для отработки собыйти от датчиков протечки, sb rule (на прмере датчика aqara в параметр water_leak пишем имя реле (FriendlyName). последние прошивки поддерживают прямую запись состояния в объекты

содержимое скрипта waterleak.lua помещаем непосредственно в секундный таймер onsectimer.lua, или добавляем туда вызов скрипта dofile("/int/waterleak.lua")

при инициализации реле переводятся в режим триггера, через параметр "interlock", "TRUE". сделано это для дополнительной защиты, чтобы предотвратить одновременное включение двух пар контактов на реле. не все краны имеют встроенную защиту, когда на него можно подать управляющее напряжение сразу но оба входа - открыть/закрыть
