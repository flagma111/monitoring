
Процедура ПриКомпоновкеРезультата(ДокументРезультат, ДанныеРасшифровки, СтандартнаяОбработка)
	
	СтандартнаяОбработка = Ложь;

	ДокументРезультат.Очистить();
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	Макет = КомпоновщикМакета.Выполнить(ЭтотОбъект.СхемаКомпоновкиДанных, ЭтотОбъект.КомпоновщикНастроек.ПолучитьНастройки(), ДанныеРасшифровки);
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(Макет, , ДанныеРасшифровки);
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВТабличныйДокумент;
	ПроцессорВывода.УстановитьДокумент(ДокументРезультат);
	
	ПутьККаталогуКартинок = Константы.ПутьККаталогуКартинок.Получить();
	ПолеПоКоторомуНеобходимоПолучитьЗначение = "ИменаКартинок";
	ПроцессорВывода.НачатьВывод();
	Пока истина Цикл
		ЭлементРезультата = ПроцессорКомпоновки.Следующий();
		
		Если ЭлементРезультата = Неопределено Тогда
			прервать;
		КонецЕсли;	
		ПроцессорВывода.ВывестиЭлемент(ЭлементРезультата);
		Если ЭлементРезультата.ЗначенияПараметров.Количество() > 0 Тогда
			
			ЗначениеВыводимыхДанных = Неопределено;
			Для каждого ЗначениеПараметра из ЭлементРезультата.ЗначенияПараметров Цикл
				Если ТипЗнч(ЗначениеПараметра.Значение) = Тип("ИдентификаторРасшифровкиКомпоновкиДанных") Тогда
					ПоляРасшифровки = ДанныеРасшифровки.Элементы[ЗначениеПараметра.Значение].ПолучитьПоля();
					Для Каждого ПолеРасшифровки из ПоляРасшифровки Цикл
						Если ПолеРасшифровки.Поле = ПолеПоКоторомуНеобходимоПолучитьЗначение Тогда
							ЗначениеВыводимыхДанных = ПолеРасшифровки.Значение;
						ИначеЕсли ПолеРасшифровки.Поле = "Наименование" Тогда
							Номенклатура = ПолеРасшифровки.Значение;	
						КонецЕсли;	
					КонецЦикла;	
				КонецЕсли;	
			КонецЦикла;
			
			Если ЗначениеЗаполнено(ЗначениеВыводимыхДанных) Тогда
				Рис1 = ДокументРезультат.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Картинка);
				Рис1.РазмерКартинки = РазмерКартинки.Пропорционально;
				Индекс1 = ДокументРезультат.Рисунки.Индекс(Рис1);
				
				Рис2 = ДокументРезультат.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Картинка);
				Рис2.РазмерКартинки = РазмерКартинки.Пропорционально;
				Индекс2 = ДокументРезультат.Рисунки.Индекс(Рис2);
				
				Рис3 = ДокументРезультат.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Картинка);
				Рис3.РазмерКартинки = РазмерКартинки.Пропорционально;
				Индекс3 = ДокументРезультат.Рисунки.Индекс(Рис3);
				
				//Разбор картинок
				СтрокиИменКартинок = СтрЗаменить(ЗначениеВыводимыхДанных, ",", Символы.ПС);
				ЧислоКартинок = СтрЧислоСтрок(СтрокиИменКартинок);
				Для н = 1 По 3 Цикл
					СтрокаКартинка = СтрПолучитьСтроку(СтрокиИменКартинок, н);
					Если ЗначениеЗаполнено(СтрокаКартинка) Тогда
						Если Не СтрНайти(СтрокаКартинка, "http") = 0 Тогда
							
							Если Не СтрНайти(СтрокаКартинка, "fix-price.ru") = 0 Тогда
								СтрокаКартинка = СтрЗаменить(СтрокаКартинка, "http://fix-price.ru", "");
								Соединение = Новый HTTPСоединение("fix-price.ru",,,,,,Новый ЗащищенноеСоединениеOpenSSL());
								Соединение.Получить(СтрокаКартинка, КаталогВременныхФайлов() + "Photo.png");
								Картинка = Новый Картинка(КаталогВременныхФайлов() + "Photo.png");
								СтрокаКартинка = КаталогВременныхФайлов() + "Photo.png";
							Иначе
								СтрокаКартинка = "";
							КонецЕсли;
						Иначе
							СтрокаКартинка = ПутьККаталогуКартинок + СтрокаКартинка;
						КонецЕсли;
						СсылкаНаФото = СтрокаКартинка;
					Иначе
						СтрокаКартинка = "";
						СсылкаНаФото = "";
					КонецЕсли;
					
					Если Не СсылкаНаФото = "" Тогда
						Файл = Новый Картинка(СсылкаНаФото);
					Иначе	
						Файл = Новый Картинка();
					КонецЕсли;	
					Хранилище = Новый ХранилищеЗначения(Файл, Новый СжатиеДанных(9));
					Картинка = Хранилище.Получить();
					
					
					Если н = 1 Тогда
						ДокументРезультат.Рисунки[Индекс1].Картинка = Картинка;
					ИначеЕсли н = 2 Тогда
						ДокументРезультат.Рисунки[Индекс2].Картинка = Картинка;
					ИначеЕсли н = 3 Тогда
						ДокументРезультат.Рисунки[Индекс3].Картинка = Картинка;
					КонецЕсли;
					
					ВысотаТабДок = ДокументРезультат.ВысотаТаблицы;
					Если н = 1 Тогда
						ОбластьДляКартинки1 = ДокументРезультат.НайтиТекст("%ФотографияКонкурента1%");
					ИначеЕсли н = 2 Тогда
						ОбластьДляКартинки2 = ДокументРезультат.НайтиТекст("%ФотографияКонкурента2%");
					ИначеЕсли н = 3 Тогда
						ОбластьДляКартинки3 = ДокументРезультат.НайтиТекст("%ФотографияКонкурента3%");
					КонецЕсли;	

						Если н = 1 Тогда
							ДокументРезультат.Рисунки[Индекс1].Расположить(ОбластьДляКартинки1);
							ОбластьДляКартинки1.Текст = "";
						ИначеЕсли н = 2 Тогда
							ДокументРезультат.Рисунки[Индекс2].Расположить(ОбластьДляКартинки2);
							ОбластьДляКартинки2.Текст = "";
						ИначеЕсли н = 3 Тогда
							ДокументРезультат.Рисунки[Индекс3].Расположить(ОбластьДляКартинки3);
							ОбластьДляКартинки3.Текст = "";
						КонецЕсли;
						
					
				КонецЦикла;	
				//Конец разбора картинок
				
				//Вставляем собственную картинку
				
				Рис = ДокументРезультат.Рисунки.Добавить(ТипРисункаТабличногоДокумента.Картинка);
				Рис.РазмерКартинки = РазмерКартинки.Пропорционально;
				Индекс = ДокументРезультат.Рисунки.Индекс(Рис);
				
				СсылкаНаФото = Константы.КаталогФото.Получить() + СокрЛП(Номенклатура.Фотография) + ".jpg";
				Если Не СтрНайти(СсылкаНаФото, "http") = 0 Тогда
					НоваяСсылкаНаФото = КаталогВременныхФайлов() + "Photo.jpg";
					КопироватьФайл(СсылкаНаФото, НоваяСсылкаНаФото);
					СсылкаНаФото = НоваяСсылкаНаФото;
				КонецЕсли;
				
				Файл = Новый Картинка(СсылкаНаФото);
				Хранилище = Новый ХранилищеЗначения(Файл, Новый СжатиеДанных(9));
				Картинка = Хранилище.Получить();
				
				ДокументРезультат.Рисунки[Индекс].Картинка = Картинка;
				
				ВысотаТабДок = ДокументРезультат.ВысотаТаблицы;
				ОбластьДляКартинки = ДокументРезультат.НайтиТекст("%НашаФотография%");
				Если ОбластьДляКартинки <> Неопределено Тогда
					ДокументРезультат.Рисунки[Индекс].Расположить(ОбластьДляКартинки);	
					ОбластьДляКартинки.Текст = "";
				КонецЕсли;
				
				//Конец вставки собственной картинки
				
			КонецЕсли;
			
		КонецЕсли;	
	КонецЦикла;
	ПроцессорВывода.ЗакончитьВывод();
	
КонецПроцедуры
	
