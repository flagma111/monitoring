
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ТЧ_В_ДеревоНаСервере();
	ОО = РеквизитФормыВЗначение("Объект"); 
	СКД = ОО.ПолучитьМакет("Макет");
	URLСКД = ПоместитьВоВременноеХранилище(СКД, Новый УникальныйИдентификатор());
	Отбор.Инициализировать(Новый ИсточникДоступныхНастроекКомпоновкиДанных(URLСКД));
	НастройкиПоУмолчанию = СКД.НастройкиПоУмолчанию;
	Отбор.ЗагрузитьНастройки(НастройкиПоУмолчанию);
	СохраненныеНастройки = ОО.ОтборХранилище.Получить();
	Если НЕ СохраненныеНастройки = Неопределено Тогда 
		Отбор.ЗагрузитьНастройки(СохраненныеНастройки);
	КонецЕсли;
	
	ПутьККаталогуКартинок = Константы.ПутьККаталогуКартинок.Получить();
	КаталогФото = Константы.КаталогФото.Получить();
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда 
		Объект.Ответственный = ОбщегоНазначения.ТекущийПользователь();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ТЧ_В_ДеревоНаСервере()
	
	ДеревоЗначенийИзТЧ = РеквизитФормыВЗначение("ДеревоИНТ");
	ДеревоЗначенийИзТЧ.Строки.Очистить();
	текТовар = Неопределено;
	текКонкурент = Неопределено;
	Если НЕ Объект.ТЧ_Согласование.Количество() Тогда 
		Возврат;
	КонецЕсли;
	ТаблицаДопДанных = ПолучитьТЗЦЕН(Объект.ТЧ_Согласование.Выгрузить(,"Конкурент, Исполнитель, ЦенаКонкурента, Номенклатура"), Объект.Дата);
	
	Для Каждого строкаТЧ Из Объект.ТЧ_Согласование Цикл 
		Если НЕ текТовар = строкаТЧ.Номенклатура Тогда 
			текТовар = строкаТЧ.Номенклатура;
			СтрУр1 = ДеревоЗначенийИзТЧ.Строки.Добавить();
			СтрУр1.Уровень = 1;
			СтрУр1.НоменклатураКонкурентМагазин = текТовар;
			СтрУр1.КодТипКонкурентаФормат = текТовар.Код;
			текКонкурент = Неопределено;
		КонецЕсли;
		Если НЕ текКонкурент = строкаТЧ.Конкурент Тогда 
			текКонкурент = строкаТЧ.Конкурент;
			СтрУр2 = СтрУр1.Строки.Добавить();
			СтрУр2.НоменклатураКонкурентМагазин = текКонкурент;
			СтрУр2.КодТипКонкурентаФормат = текКонкурент.ТипКонкурента;
			СтрУр2.Уровень = 2;
			СтруктураПоиска = Новый Структура("Конкурент, Номенклатура", текКонкурент, текТовар);
			СтрокиПоиска = ТаблицаДопДанных.НайтиСтроки(СтруктураПоиска);
			СтрУр2.КатегорияПрошлыйМониторингКомментарий = "тек: " + Формат(строкаТЧ.ДатаМониторинга, "ДФ=dd.MM.yyyy");
			Если СтрокиПоиска.Количество() Тогда 
				СтрУр2.ПрошлаяЦенаСебестоимость = СтрокиПоиска[0].ПредпоследняяЦенаКонкурента;
				ДатаПрошлогоМониторинга = СтрокиПоиска[0].ДатаПредпоследнегоМонитринга;
				Если ЗначениеЗаполнено(ДатаПрошлогоМониторинга) Тогда 
					СтрУр2.КатегорияПрошлыйМониторингКомментарий = СтрУр2.КатегорияПрошлыйМониторингКомментарий + ", пред: " + Формат(ДатаПрошлогоМониторинга, "ДФ=dd.MM.yyyy") + "(" + Окр(((Объект.Дата - ДатаПрошлогоМониторинга)/86400)) + " дн.)";
				КонецЕсли;
			КонецЕсли;
			СтрУр2.ТекущаяЦена = строкаТЧ.Ценаконкурента;
			СтрУр2.ИменаКартинок = строкаТЧ.ИменаКартинок;
			СтрУр2.РасчетнаяЦена = строкаТЧ.Ценаконкурента;
			СтрУр2.НоваяЦена = строкаТЧ.Ценаконкурента;
			СтрУр2.ТекущаяНаценка = ?(СтрУр2.ТекущаяЦена = 0 ИЛИ СтрУр2.ПрошлаяЦенаСебестоимость = 0, 0, (СтрУр2.ТекущаяЦена/СтрУр2.ПрошлаяЦенаСебестоимость-1)*100);
			СтрУр2.НоваяНаценка = СтрУр2.ТекущаяНаценка;
			СтрУр2.ЦенаИсполнителя = СтрУр2.ТекущаяЦена;
			СтрУр2.НаценкаИсполнителя = СтрУр2.ТекущаяНаценка;
			СтрУр2.КомментарийКНоменклатуре = строкаТЧ.КомментарийКНоменклатуре;
		КонецЕсли;
		СтрУр3 = СтрУр2.Строки.Добавить();
		СтрУр3.НоменклатураКонкурентМагазин = строкаТЧ.Исполнитель;
		СтрУр3.КодТипКонкурентаФормат = строкаТЧ.Исполнитель.Формат;
		СтрУр3.Уровень = 3;
		СтрУр3.НомерСтрокиТЧ = строкаТЧ.НомерСтроки;
		СтруктураПоиска = Новый Структура("Конкурент, Номенклатура, Магазин", текКонкурент, текТовар, строкаТЧ.Исполнитель);
		СтрокиПоиска = ТаблицаДопДанных.НайтиСтроки(СтруктураПоиска);
		ОшибкаРасчета = "";
		Если СтрокиПоиска.Количество() Тогда 
			СтрУр3.ПрошлаяЦенаСебестоимость = СтрокиПоиска[0].Себестоимость;
			СтрУр3.ТекущаяЦена = СтрокиПоиска[0].ТекущаяЦенаМагазина;
			СтрУр3.КатегорияЦены = СтрокиПоиска[0].КатегорияНоменклатуры;
			СтрокаРасчета = СтрокиПоиска[0].АлгоритмРасчетаНовойЦены;
			Если ЗначениеЗаполнено(СтрокаРасчета) Тогда 
				Данные = Новый Структура;
				Данные.Вставить("ЦенаМагазинаТекущая", СтрУр3.ТекущаяЦена);
				Данные.Вставить("ЦенаКонкурентаТекущая", строкаТЧ.Ценаконкурента);
				Данные.Вставить("ЦенаМагазинаНовая", 0);
				РасчитатьЦену(Данные, СтрокаРасчета);
				СтрУр3.РасчетнаяЦена = Данные.ЦенаМагазинаНовая;
				Если Данные.ЦенаМагазинаНовая = 0 Тогда 
					ОшибкаРасчета = "Ошибка в формуле расчета новой цены!" 
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		СтрУр3.ЦенаИсполнителя = строкаТЧ.ЦенаИсполнителя;
		СтрУр3.НаценкаИсполнителя = ?(СтрУр3.ЦенаИсполнителя = 0 ИЛИ СтрУр3.ПрошлаяЦенаСебестоимость = 0, 0, (СтрУр3.ЦенаИсполнителя/СтрУр3.ПрошлаяЦенаСебестоимость-1)*100);
		СтрУр3.НоваяЦена = ?(ЗначениеЗаполнено(строкаТЧ.НоваяЦена), строкаТЧ.НоваяЦена, СтрУр3.ЦенаИсполнителя);
		СтрУр3.ТекущаяНаценка = ?(СтрУр3.ТекущаяЦена = 0 ИЛИ СтрУр3.ПрошлаяЦенаСебестоимость = 0, 0, (СтрУр3.ТекущаяЦена/СтрУр3.ПрошлаяЦенаСебестоимость-1)*100);
		СтрУр3.НоваяНаценка = ?(СтрУр3.ТекущаяЦена = 0 ИЛИ СтрУр3.ПрошлаяЦенаСебестоимость = 0, 0, (СтрУр3.НоваяЦена/СтрУр3.ПрошлаяЦенаСебестоимость-1)*100);
		СтрУр3.КатегорияПрошлыйМониторингКомментарий = ?(ЗначениеЗаполнено(строкаТЧ.Комментарий), строкаТЧ.Комментарий, ОшибкаРасчета); 
		СтрУр3.СтатусПереоценки = строкаТЧ.СтатусПереоценки;
		СтрУр3.КомментарийКНоменклатуре = строкаТЧ.КомментарийКНоменклатуре;
		СтрУр3.КомментарийРуководителя = строкаТЧ.КомменатрийРуководителя;
		СтрУр3.НоваяКатегорияЦены = СтрокаТЧ.НоваяКатегорияЦены;
	КонецЦикла;
	ЗначениеВРеквизитФормы(ДеревоЗначенийИзТЧ,"ДеревоИНТ");
КонецПроцедуры

&НаКлиентеНаСервереБезКонтекста
Процедура РасчитатьЦену(Данные, СтрокаРасчета)

	Попытка
		Выполнить(СтрокаРасчета);
	Исключение
		Данные.ЦенаМагазинаНовая = 0;
	КонецПопытки;

КонецПроцедуры // ()


&НаСервереБезКонтекста
Функция ПолучитьТЗЦЕН(ТЧ_Документа, ДатаДокумента)

	Запрос = Новый Запрос;
Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныВМониторинге.Номенклатура КАК Номенклатура,
		|	ЦеныВМониторинге.Конкурент КАК Конкурент,
		|	ЦеныВМониторинге.ЦенаКонкурента КАК Цена,
		|	ВЫРАЗИТЬ(ЦеныВМониторинге.Исполнитель КАК Справочник.Магазины) КАК Магазин
		|ПОМЕСТИТЬ ВТ_ЦеныИзМониторинга
		|ИЗ
		|	&ЦеныВМониторинге КАК ЦеныВМониторинге
		|
		|ИНДЕКСИРОВАТЬ ПО
		|	Номенклатура,
		|	Конкурент,
		|	Магазин
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ВТ_ЦеныИзМониторинга.Номенклатура,
		|	ВТ_ЦеныИзМониторинга.Конкурент,
		|	ВТ_ЦеныИзМониторинга.Магазин,
		|	ВТ_ЦеныИзМониторинга.Цена КАК ПоследняяЦенаКонкурента,
		|	ЕСТЬNULL(СебестоимостьНоменклатурыСрезПоследних.Цена, 0) КАК Себестоимость,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.Цена, 0) КАК ТекущаяЦенаМагазина,
		|	ЕСТЬNULL(ЦеныНоменклатурыСрезПоследних.КатегорияНоменклатуры, """") КАК КатегорияНоменклатуры,
		|	ЦеныКонкурентовСрезПоследних.Период КАК ДатаПоследнегоМониторинга,
		|	ВТ_ЦеныИзМониторинга.Магазин.АлгоритмРасчетаНовойЦены КАК АлгоритмРасчетаНовойЦены,
		|	ЦеныКонкурентовСрезПоследних.ПрошлаяЦена КАК ПредпоследняяЦенаКонкурента,
		|	ЦеныКонкурентовСрезПоследних.ДатаПрошлойЦены КАК ДатаПредпоследнегоМонитринга
		|ИЗ
		|	ВТ_ЦеныИзМониторинга КАК ВТ_ЦеныИзМониторинга
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныНоменклатуры.СрезПоследних КАК ЦеныНоменклатурыСрезПоследних
		|		ПО ВТ_ЦеныИзМониторинга.Номенклатура = ЦеныНоменклатурыСрезПоследних.Номенклатура
		|			И ВТ_ЦеныИзМониторинга.Магазин = ЦеныНоменклатурыСрезПоследних.Магазин
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ЦеныКонкурентов.СрезПоследних(&ДатаСрезаПрошлыхЦен, ) КАК ЦеныКонкурентовСрезПоследних
		|		ПО ВТ_ЦеныИзМониторинга.Номенклатура = ЦеныКонкурентовСрезПоследних.Номенклатура
		|			И ВТ_ЦеныИзМониторинга.Конкурент = ЦеныКонкурентовСрезПоследних.Конкурент
		|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СебестоимостьНоменклатуры.СрезПоследних КАК СебестоимостьНоменклатурыСрезПоследних
		|		ПО ВТ_ЦеныИзМониторинга.Номенклатура = СебестоимостьНоменклатурыСрезПоследних.Номенклатура";
// Кириллов А.Н. (в регистре пока что нет записей с заполненным полем "Магазин")		
//		|			И ВТ_ЦеныИзМониторинга.Магазин = СебестоимостьНоменклатурыСрезПоследних.Магазин";

	
	Запрос.УстановитьПараметр("ЦеныВМониторинге", ТЧ_Документа);
	Запрос.УстановитьПараметр("ДатаСрезаПрошлыхЦен", ДатаДокумента-1);
	
	ТЗ_Результат = Запрос.Выполнить().Выгрузить();
	ТЗ_Результат.Индексы.Добавить("Номенклатура, Конкурент, Магазин");
	
	Возврат ТЗ_Результат;

КонецФункции // ПолучитьТЗЦЕН()

&НаКлиенте
Процедура ДеревоИНТНоваяЦенаПриИзменении(Элемент)
	ТекСтр = Элементы.ДеревоИНТ.ТекущиеДанные;
	ТекСтр.НоваяНаценка = ?(ТекСтр.ПрошлаяЦенаСебестоимость = 0 ИЛИ ТекСтр.НоваяЦена = 0, 0, (ТекСтр.НоваяЦена/ТекСтр.ПрошлаяЦенаСебестоимость-1)*100);
	Если ТекСтр.НоваяЦена = 0 Тогда 
		ТекСтр.СтатусПереоценки = 0;
	ИначеЕсли ТекСтр.НоваяЦена < ТекСтр.РасчетнаяЦена Тогда 
		ТекСтр.СтатусПереоценки = 1;
	ИначеЕсли ТекСтр.НоваяЦена = ТекСтр.РасчетнаяЦена Тогда 
		ТекСтр.СтатусПереоценки = 2;
	ИначеЕсли ТекСтр.НоваяЦена > ТекСтр.РасчетнаяЦена Тогда 
		ТекСтр.СтатусПереоценки = 3;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ДеревоИНТВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	текСтрока = Элементы.ДеревоИНТ.ТекущиеДанные;
	Если текСтрока = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	Если текСтрока.Уровень<3 ИЛИ (текСтрока.НоваяЦена = текСтрока.ЦенаИсполнителя И НЕ Поле.Имя = "ДеревоИНТНоваяЦена") Тогда 
		СтандартнаяОбработка = Ложь;
		ПоказатьЗначение(Новый ОписаниеОповещения("ПослеПоказаЗначения", ЭтаФорма),ТекСтрока[стрзаменить(Поле.Имя, "ДеревоИНТ","")]);
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПослеПоказаЗначения(ПараметрыОповещения = Неопределено) Экспорт 

	

КонецПроцедуры // ПослеПоказаЗначения()


&НаСервере
Процедура ПередЗаписьюНаСервере(Отказ, ТекущийОбъект, ПараметрыЗаписи)
	ДеревоВ_ТЧ(ТекущийОбъект);
	ХранилищеНастроекОтбора = Новый ХранилищеЗначения(Отбор.ПолучитьНастройки());
	ТекущийОбъект.ОтборХранилище = ХранилищеНастроекОтбора;
КонецПроцедуры

&НаСервере
Процедура ДеревоВ_ТЧ(ТекущийОбъект)

	ДеревоЗначенийИзТЧ = РеквизитФормыВЗначение("ДеревоИНТ");
	Для Каждого СтрУр1 Из ДеревоЗначенийИзТЧ.Строки Цикл 
		Номенклатура = СтрУр1.НоменклатураКонкурентМагазин;
		Для Каждого СтрУр2 Из СтрУр1.Строки Цикл
			Конкурент = СтрУр2.НоменклатураКонкурентМагазин;
			ЦенаКонкурента = СтрУр2.ТекущаяЦена;
			Для Каждого СтрУр3 Из СтрУр2.Строки Цикл
				СтрокаТЧ = ТекущийОбъект.ТЧ_Согласование[СтрУр3.НомерСтрокиТЧ-1];
				СтрокаТЧ.КомменатрийРуководителя = СтрУр3.КомментарийРуководителя;
				СтрокаТЧ.НоваяЦена = СтрУр3.НоваяЦена;
				СтрокаТЧ.СтатусПереоценки = СтрУр3.СтатусПереоценки;
				СтрокаТЧ.КатегорияНоменклатуры = СтрУр3.КатегорияЦены;
				СтрокаТЧ.НоваяКатегорияЦены = СтрУр3.НоваяКатегорияЦены;
			КонецЦикла;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры // ()

&НаКлиенте
Процедура Фото1ПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	ОткрытьФото(Фото1, Истина);
КонецПроцедуры

&НаКлиенте
Процедура ОткрытьФото(СсылкаНаФото, Наше = Ложь)

	ТекСтрока = Элементы.ДеревоИНТ.ТекущиеДанные;
	СтрокаКонкурент = "";
	Описание = ПоулчитьОписаниеНоменклатуры(ТекНоменклатура);

	Если НЕ Наше И НЕ ТекСтрока = Неопределено Тогда 
		Если ТекСтрока.Уровень = 2 Тогда 
			СтрокаКонкурент = СокрЛП(ТекСтрока.НоменклатураКонкурентМагазин);
		ИначеЕсли ТекСтрока.Уровень = 1 Тогда 
			СтрокаКонкурент = СокрЛП(ТекСтрока.ПолучитьРодителя().НоменклатураКонкурентМагазин);
		КонецЕсли;
		Если ЗначениеЗаполнено(ТекСтрока.КомментарийКНоменклатуре) Тогда 
			СтрокаКонкурент = СтрокаКонкурент + Символы.ПС + ТекСтрока.КомментарийКНоменклатуре;
		КонецЕсли;
	КонецЕсли;
	Если ЗначениеЗаполнено(Описание) Тогда 
		СтрокаКонкурент = Описание + Символы.ПС + СтрокаКонкурент;
	КонецЕсли;

	СтруктураПараметров = Новый Структура;
	СтруктураПараметров.Вставить("Заголовок",""+ТекНоменклатура + Символы.ПС + СтрокаКонкурент); 
	СтруктураПараметров.Вставить("АдресКартинки", СсылкаНаФото);
	СтруктураПараметров.Вставить("ЭтоСсылка", Истина);
	СтруктураПараметров.Вставить("ЗаголовокФормы", "Просмотр фото");
	ОткрытьФорму("ОбщаяФорма.ФормаПросмотраКартинок",Новый Структура("СтрутураПараметров",СтруктураПараметров));

КонецПроцедуры // ОткрытьФото()

&НаСервереБезКонтекста
Функция ПоулчитьОписаниеНоменклатуры(ТекНоменклатура)

	Возврат ТекНоменклатура.Описание;

КонецФункции // ПоулчитьОписаниеНоменклатуры(ТекНоменклатура)()


&НаКлиенте
Процедура Фото2ПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	ОткрытьФото(Фото2);
КонецПроцедуры


&НаКлиенте
Процедура Фото3ПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	ОткрытьФото(Фото3);
КонецПроцедуры


&НаКлиенте
Процедура Фото4ПриНажатии(Элемент, ДанныеСобытия, СтандартнаяОбработка)
	ОткрытьФото(Фото4);
КонецПроцедуры


&НаКлиенте
Процедура ДеревоИНТПриАктивизацииСтроки(Элемент)
	ТекСтрока = Элемент.ТекущиеДанные;
	Если ТекСтрока = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	Если ТекСтрока.Уровень = 1 Тогда 
		ТекНоменклатура = ТекСтрока.НоменклатураКонкурентМагазин;
	ИначеЕсли ТекСтрока.Уровень = 2 Тогда 
		ТекНоменклатура = ТекСтрока.получитьродителя().НоменклатураКонкурентМагазин;
	Иначе 
		ТекНоменклатура = ТекСтрока.получитьродителя().получитьродителя().НоменклатураКонкурентМагазин;
	КонецЕсли;
	
	СтрокаКартинка = ПолучитьСсылкаНаФотоНоменклатуры(ТекНоменклатура, КаталогФото);
	Если ЗначениеЗаполнено(СтрокаКартинка) Тогда 
		Фото1 = "<html>
				|<body> <div align = center>
				|<img height = 100% src='"+СтрокаКартинка+"'/></div>
				|</body>
				|</html>";
	Иначе
		Фото1 = "";
	КонецЕсли;
	
	СтрокиИменКартинок = СтрЗаменить(ТекСтрока.ИменаКартинок, ",", Символы.ПС);
	
	ЧислоКартинок = СтрЧислоСтрок(СтрокиИменКартинок);
	Для н = 1 По 3 Цикл 
		Если н > ЧислоКартинок Тогда 
			СсылкаНаФото = "";
		Иначе 
			СтрокаКартинка = СтрПолучитьСтроку(СтрокиИменКартинок, н);
			Если ЗначениеЗаполнено(СтрокаКартинка) Тогда 
				СтрокаКартинка = ПутьККаталогуКартинок + СтрокаКартинка;
				СсылкаНаФото = "<html>
					|<body> <div align = center>
					|<img height = 100% src='"+СтрокаКартинка+"'/></div>
					|</body>
					|</html>";
			КонецЕсли;

		КонецЕсли;
		
		Выполнить("Фото" + (н+1) + " = СсылкаНаФото;");
			
	КонецЦикла;

КонецПроцедуры

&НаСервереБезКонтекста
Функция ПолучитьСсылкаНаФотоНоменклатуры(Номенклатура, КаталогФото)

	Фото = КаталогФото + Номенклатура.Фотография + ".jpg";
	Возврат Фото;

КонецФункции // ПолучитьСсылкаНаФотоНоменклатуры(()


&НаСервере
Процедура ЗаполнитьТЧНаСервере()
	СКД = РеквизитФормыВЗначение("Объект").ПолучитьМакет("Макет");
	Объект.ТЧ_Согласование.Очистить();
	//Запускаем компоновку
	КомпоновщикМакета = Новый КомпоновщикМакетаКомпоновкиДанных;
	НастройкиОтбора = Отбор.ПолучитьНастройки();
	ЭлементыОтбора = НастройкиОтбора.Отбор.Элементы;
	//Получим и добавим отбор пользователя
	ТекущийПользователь = ОбщегоНазначения.ТекущийПользователь();
	ОтборПользователя = ТекущийПользователь.ОтборХранилище.Получить();
	Если НЕ ОтборПользователя = Неопределено Тогда 
		ЭлементыОтбораПользователя = ОтборПользователя.Отбор.Элементы;
		Для Каждого ЭлементОтбораПользователя Из ЭлементыОтбораПользователя Цикл 
			элементОтбора = ЭлементыОтбора.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
			ЗаполнитьЗначенияСвойств(элементОтбора, ЭлементОтбораПользователя);
		КонецЦикла;
	КонецЕсли;
	
	МакетКомпоновки = КомпоновщикМакета.Выполнить(СКД, НастройкиОтбора,,,Тип("ГенераторМакетаКомпоновкиДанныхДляКоллекцииЗначений"));
	//Создаем процессор компоновки
	ПроцессорКомпоновки = Новый ПроцессорКомпоновкиДанных;
	ПроцессорКомпоновки.Инициализировать(МакетКомпоновки);
	
	//Выводим в таблицу значений
	ПроцессорВывода = Новый ПроцессорВыводаРезультатаКомпоновкиДанныхВКоллекциюЗначений;
	ТЗ = ПроцессорВывода.Вывести(ПроцессорКомпоновки, истина);
	
	Для Каждого СтрокаТЗ Из ТЗ Цикл 
		СтрокаТЧ = Объект.ТЧ_Согласование.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаТЧ, СтрокаТЗ);
	КонецЦикла;
	
	ТЧ_В_ДеревоНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТЧ(Команда)
	ЗаполнитьТЧНаСервере();
	РазвернутьДерево();
КонецПроцедуры

&НаКлиенте
Процедура ПослеПредупреждения(Результат) Экспорт 

	

КонецПроцедуры // ПослеПредупреждения()


&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	РазвернутьДерево();
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьДерево()
	КоллекцияЭлементовДерева = ДеревоИНТ.ПолучитьЭлементы();
	Для Каждого Строка Из КоллекцияЭлементовДерева Цикл    
		ИдентификаторСтроки=Строка.ПолучитьИдентификатор();
		Элементы.ДеревоИНТ.Развернуть(ИдентификаторСтроки);
		Для Каждого Строка2 Из Строка.ПолучитьЭлементы() Цикл    
			ИдентификаторСтроки=Строка2.ПолучитьИдентификатор();
			Элементы.ДеревоИНТ.Развернуть(ИдентификаторСтроки);
		КонецЦикла;
	КонецЦикла;
КонецПроцедуры // ()


