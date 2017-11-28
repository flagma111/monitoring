
&НаКлиенте
Процедура Отпарсить(Команда)
	
	Если ПроверкаСоответствия() = 1 Тогда
		ПарсингФиксов();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция ПроверкаСоответствия()
	
	Если Объект.ВидСоответствия = Перечисления.ВидыСоответствийНоменклатуры.ФиксПрайс Тогда 
		Возврат 1;
	Иначе 
		Возврат 0;	
	КонецЕсли;
	
КонецФункции	

&НаСервере
Процедура ПолучитьГородаПарсинга()
	
	Объект.Города.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СоответствиеГородов.Город,
	|	СоответствиеГородов.КодКонкурента,
	|	СоответствиеГородов.Конкурент
	|ИЗ
	|	РегистрСведений.СоответствиеГородов КАК СоответствиеГородов
	|ГДЕ
	|	СоответствиеГородов.ВидСоответствия = &ВидСоответствия";
	Запрос.УстановитьПараметр("ВидСоответствия", Объект.ВидСоответствия);
	ТЗ = Запрос.Выполнить().Выгрузить();
	Объект.Города.Загрузить(ТЗ);
	
КонецПроцедуры	

&НаСервере
Функция ПолучитьНоменклатуру(АртикулТовара)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СоответствиеНоменклатуры.Номенклатура
	|ИЗ
	|	РегистрСведений.СоответствиеНоменклатуры КАК СоответствиеНоменклатуры
	|ГДЕ
	|	СоответствиеНоменклатуры.ВидСоответствия = &ВидСоответствия
	|	И СоответствиеНоменклатуры.КодКонкурента = &КодКонкурента";
	Запрос.УстановитьПараметр("ВидСоответствия", Объект.ВидСоответствия);
	Запрос.УстановитьПараметр("КодКонкурента", СокрЛП(АртикулТовара));
	Результат = Запрос.Выполнить().Выбрать();
	Если Результат.Следующий() Тогда
		Номенклатура = Результат.Номенклатура;
	Иначе
		Номенклатура = "";
	КонецЕсли;
	
	Возврат Номенклатура;
	
КонецФункции

&НаСервере
Функция ПолучитьКоэффициентПересчета(АртикулТовара)
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СоответствиеНоменклатуры.КоэффициентПересчета
	|ИЗ
	|	РегистрСведений.СоответствиеНоменклатуры КАК СоответствиеНоменклатуры
	|ГДЕ
	|	СоответствиеНоменклатуры.ВидСоответствия = &ВидСоответствия
	|	И СоответствиеНоменклатуры.КодКонкурента = &КодКонкурента";
	Запрос.УстановитьПараметр("ВидСоответствия", Объект.ВидСоответствия);
	Запрос.УстановитьПараметр("КодКонкурента", СокрЛП(АртикулТовара));
	Результат = Запрос.Выполнить().Выбрать();
	Если Результат.Следующий() Тогда
		КоэффициентПересчета = Результат.КоэффициентПересчета;
	Иначе
		КоэффициентПересчета = 0;
	КонецЕсли;
	
	Возврат КоэффициентПересчета;
	
КонецФункции


&НаКлиенте
Процедура ПарсингФиксов()
	
	//Очищаем предыдущие результаты
	Объект.Товары.Очистить();
	
	sURL = "https://fix-price.ru"; 
	XMLHTTP = GetCOMObject("", "Microsoft.XMLHTTP");
	
	//Запрашиваем количество страниц
	XMLHTTP.Open("GET", sURL, Ложь);
	XMLHTTP.Open("GET", sURL + "/buyers/catalog/", 0);
	XMLHTTP.Send();
	ИскомаяСтрока = XMLHTTP.ResponseText;	
	Начало = Найти(ИскомаяСтрока, "no-first-cufon-init");
	СтрокаПоиска = Сред(ИскомаяСтрока, Начало  + 14, 200);
	КолВоСтр = Число(ТолькоЦифры(СтрокаПоиска));
	
	//Проходим по каждому найденному городу
	Для Каждого Город Из Объект.Города Цикл
		Если Город.ФлагВыбора = Истина Тогда
			Попытка
				sURL = "https://fix-price.ru"; 
				XMLHTTP = GetCOMObject("", "Microsoft.XMLHTTP");
				
				//Устанавливаем город, заголовки эмуляции AJAX
				XMLHTTP.Open("POST", sURL + "/ajax/setcity.php", False);
				XMLHTTP.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
				XMLHTTP.setRequestHeader("X-Requested-With", "XMLHttpRequest");
				XMLHTTP.Send("city=" + СокрЛП(Строка(Город.КодКонкурента)));
				
				//Получаем страницы с товаром
				Для НСтр = 1 По КолВоСтр Цикл
					
					Состояние("Город: " + Строка(Город.Город) + " Страница: " + Строка(НСтр) + " из " + Строка(КолВоСтр));
					
					XMLHTTP.Open("GET", sURL + "/buyers/catalog/page-" + Строка(НСтр) + "/", False);
					XMLHTTP.Send();
					ИскомаяСтрока = XMLHTTP.ResponseText;
					
					Флаг = 0; ОткрывающийСимволОбщий = 1;
					
					Пока Флаг = 0 Цикл
						//Ищем вхождения товара с флагов выхода
						СимволПоиска = СтрНайти(ИскомаяСтрока, "<a class=""favorite"" href=""#"" item=", , ОткрывающийСимволОбщий);
						Если СимволПоиска = 0 Тогда
							Флаг = 1;
						Иначе
							//Выбираем все, что касается товара
							ОткрывающийСимволОбщий = СимволПоиска + 34;
							ЗакрывающийСимвол = СтрНайти(ИскомаяСтрока, "</i></em>", , ОткрывающийСимволОбщий);
							ПодстрокаТовара = (Сред(ИскомаяСтрока, ОткрывающийСимволОбщий, ЗакрывающийСимвол - ОткрывающийСимволОбщий + 9));
							
							//Ищем Артикул
							ЗакрывающийСимвол = СтрНайти(ПодстрокаТовара, "data-reveal-id=""form-favorite-start""></a>");
							АртикулТовара = (Сред(ПодстрокаТовара, 2, ЗакрывающийСимвол - 4));
							
							//Ищем наименование товара
							ОткрывающийСимвол = СтрНайти(ПодстрокаТовара, "title: '");
							ЗакрывающийСимвол = СтрНайти(ПодстрокаТовара, "link: ");
							НаименованиеТовара = (Сред(ПодстрокаТовара, ОткрывающийСимвол + 8, ЗакрывающийСимвол - ОткрывающийСимвол - 27));
							
							//Ищем картинку товара
							ОткрывающийСимвол = СтрНайти(ПодстрокаТовара, "image:""");
							ЗакрывающийСимвол = СтрНайти(ПодстрокаТовара, "title: '");
							КартинкаТовара = (Сред(ПодстрокаТовара, ОткрывающийСимвол + 7, ЗакрывающийСимвол - ОткрывающийСимвол - 26));
							
							//Ищем цену товара
							ОткрывающийСимвол = СтрНайти(ПодстрокаТовара, "<em class=""price_label"">");
							ЗакрывающийСимвол = СтрНайти(ПодстрокаТовара, "<i>руб</i></em>");
							ЦенаТовара = (Сред(ПодстрокаТовара, ОткрывающийСимвол + 24, ЗакрывающийСимвол - ОткрывающийСимвол - 24));
							
							//Ищем соответствие номенклатуры конкурента
							Номенклатура = ПолучитьНоменклатуру(АртикулТовара);
							КоэффициентПересчета = ПолучитьКоэффициентПересчета(АртикулТовара);
							
							//Добавляем результаты в табличную часть
							Если Не Номенклатура = "" Тогда
								СтрТовары = Объект.Товары.Добавить();
								СтрТовары.Город						= Город.Город;
								СтрТовары.Конкурент					= Город.Конкурент;
								СтрТовары.Номенклатура				= Номенклатура;
								СтрТовары.КоэффициентПересчета		= ?(КоэффициентПересчета = 0, 1, КоэффициентПересчета);
								СтрТовары.КодКонкурента				= АртикулТовара;
								СтрТовары.НаименованиеКонкурента	= НаименованиеТовара;
								СтрТовары.Цена						= ЦенаТовара;
								СтрТовары.Картинки					= КартинкаТовара;
							КонецЕсли;	
						КонецЕсли;
						
					КонецЦикла;
					
				КонецЦикла;
				
			Исключение
				Сообщить("Город: " + Строка(Город.Город) + " ошибка парсинга");
			КонецПопытки;
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Функция ТолькоЦифры(Знач СтрокаСЦифрамиИСимволами)
	
	Ограничитель = Лев(СтрокаСЦифрамиИСимволами, 6);
    ПервыйСимвол = Лев(СтрокаСЦифрамиИСимволами, 1);
    Если ПервыйСимвол = "" ИЛИ Ограничитель = "class=" Тогда
        Возврат ""; 
    ИначеЕсли ЭтоЧисло(ПервыйСимвол) Тогда
        Возврат ПервыйСимвол + ТолькоЦифры(Сред(СтрокаСЦифрамиИСимволами, 2));
    Иначе
        Возврат ТолькоЦифры(Сред(СтрокаСЦифрамиИСимволами, 2));
    КонецЕсли;
    
КонецФункции

&НаКлиенте
Функция ЭтоЧисло(Символ)
	
	Если Символ = "0" ИЛИ
		Символ = "1" ИЛИ
		Символ = "2" ИЛИ
		Символ = "3" ИЛИ
		Символ = "4" ИЛИ
		Символ = "5" ИЛИ
		Символ = "6" ИЛИ
		Символ = "7" ИЛИ
		Символ = "8" ИЛИ
		Символ = "9" Тогда
		Возврат Истина
	Иначе
		Возврат Ложь
	КонецЕсли;
	
КонецФункции	

&НаКлиенте
Процедура ТоварыПриАктивизацииСтроки(Элемент)
	
	Попытка
		ТекСтрока = Элемент.ТекущиеДанные.Картинки;
	Исключение
		ТекСтрока = "";
	КонецПопытки;
	
	Если ЗначениеЗаполнено(ТекСтрока) Тогда 
		Фото = "<html>
				|<body> <div align = center>
				|<img height = 100% src='"+ТекСтрока+"'/></div>
				|</body>
				|</html>";
	Иначе
		Фото = "";		
	КонецЕсли;

КонецПроцедуры

&НаСервере
Процедура СоздатьМониторингНаСервере()
	
	Город = Справочники.Города.ПустаяСсылка();
	
	Если Объект.Товары.Количество() > 0 Тогда
		
		Для Каждого Стр Из Объект.Товары Цикл
			Если Не Стр.Номенклатура = Справочники.Номенклатура.ПустаяСсылка() Тогда
				Если Не Город = Стр.Город Тогда
					Док = Документы.ЗагрузкаРезультатовМониторинга.СоздатьДокумент();
					Док.Дата = ТекущаяДата();
					Город = Стр.Город;
					Док.Комментарий = Город;
					
					//Ищем конкурента
					Конкурент = Стр.Конкурент;
					//Справочники.Конкуренты.НайтиПоНаименованию("Парсинг " + Стр.Город.Наименование);
					//Если Конкурент = Справочники.Конкуренты.ПустаяСсылка() Тогда
					//	Конкурент = Справочники.Конкуренты.СоздатьЭлемент();
					//	Конкурент.Наименование = "Парсинг " + Стр.Город.Наименование;
					//	Конкурент.Записать();
					//	Док.Конкурент = Конкурент.Ссылка;
					//Иначе	
						Док.Конкурент = Конкурент;
					//КонецЕсли;
					
					
					//Ищем ТипМониторинга
					ТипМониторинга = Справочники.ТипМониторинга.НайтиПоНаименованию("Парсинг " + Объект.ВидСоответствия);
					Если ТипМониторинга = Справочники.ТипМониторинга.ПустаяСсылка() Тогда
						ТипМониторинга = Справочники.ТипМониторинга.СоздатьЭлемент();
						ТипМониторинга.Наименование = "Парсинг " + Объект.ВидСоответствия;
						ТипМониторинга.Записать();
						Док.ТипМониторинга = ТипМониторинга.Ссылка;
					Иначе
						Док.ТипМониторинга = ТипМониторинга;
					КонецЕсли;
					
					
					//Ищем магазин исполнитель
					ИсполнительМагазин = Справочники.Магазины.НайтиПоНаименованию("Парсинг " + Стр.Город.Наименование);
					Если ИсполнительМагазин = Справочники.Магазины.ПустаяСсылка() Тогда
						ИсполнительМагазин = Справочники.Магазины.СоздатьЭлемент();
						ИсполнительМагазин.Наименование = "Парсинг " + Стр.Город.Наименование;
						ИсполнительМагазин.Записать();
						Док.ИсполнительМагазин = ИсполнительМагазин.Ссылка;
					Иначе
						Док.ИсполнительМагазин = ИсполнительМагазин;
					КонецЕсли;
					
					
					Док.ВремяНачала = ТекущаяДата();
					Док.ВремяЗавершения = ТекущаяДата();
					
				КонецЕсли;	
				
				СтрД = Док.РезультатыМониторинга.Добавить();
				СтрД.Номенклатура		= Стр.Номенклатура;
				СтрД.ЦенаКонкурента		= Стр.Цена * Стр.КоэффициентПересчета;
				СтрД.ИменаКартинок		= Стр.Картинки;
				
				Док.Записать();
			КонецЕсли;
		КонецЦикла;	
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура СоздатьМониторинг(Команда)
	СоздатьМониторингНаСервере();
КонецПроцедуры

&НаСервере
Процедура ВыбратьВсеГородаНаСервере()
	Для Каждого Стр Из Объект.Города Цикл
		Стр.ФлагВыбора = Истина;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьВсеГорода(Команда)
	ВыбратьВсеГородаНаСервере();
КонецПроцедуры

&НаСервере
Процедура СнятьВсеГородаНаСервере()
	Для Каждого Стр Из Объект.Города Цикл
		Стр.ФлагВыбора = Ложь;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура СнятьВсеГорода(Команда)
	СнятьВсеГородаНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВидСоответствияПриИзменении(Элемент)
	ПолучитьГородаПарсинга();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	//Закрыть();
КонецПроцедуры
