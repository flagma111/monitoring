
&НаКлиенте
Процедура Загрузить(Команда)
	
	ДиалогВыбораФайла = Новый ДиалогВыбораФайла(РежимДиалогаВыбораФайла.Открытие);
	
	ДиалогВыбораФайла.Заголовок = "Прочитать табличный документ из файла";
	ДиалогВыбораФайла.Фильтр    = "Лист Excel (*.xls)";
	Если ДиалогВыбораФайла.Выбрать() Тогда
		ФайлНаДиске = Новый Файл(ДиалогВыбораФайла.ПолноеИмяФайла);
		мПрочитатьТабличныйДокументИзExcel(ДиалогВыбораФайла.ПолноеИмяФайла);
	КонецЕсли;
	
	Сообщить("Загрузка завершена");
	
КонецПроцедуры

&НаКлиенте
Процедура мПрочитатьТабличныйДокументИзExcel(ИмяФайла, НомерЛистаExcel = 1) Экспорт
	
	xlLastCell = 11;
	
	ВыбФайл = Новый Файл(ИмяФайла);
	Если НЕ ВыбФайл.Существует() Тогда
		Сообщить("Файл не существует!");
		Возврат;
	КонецЕсли;
	
	Попытка
		Excel = Новый COMОбъект("Excel.Application");
		Excel.WorkBooks.Open(ИмяФайла);
		Сообщить("Обработка файла Microsoft Excel...");
		ExcelЛист = Excel.Sheets(НомерЛистаExcel);
	Исключение
		Сообщить("Ошибка загрузки из Excel");
		Возврат;
		
	КонецПопытки;
	
	ВсегоСтрок = ExcelЛист.Cells.SpecialCells(xlLastCell).Row;
	
	Для Row = 1 По ВсегоСтрок Цикл
		
		КодНоменклатура			= СокрЛП(ExcelЛист.Cells(Row, ЭтаФорма.НомерКолонкиСобственныйКод).Text);
		КодКонкурента			= СокрЛП(ExcelЛист.Cells(Row, ЭтаФорма.НомерКолонкиКодКонкурента).Text);
		КоэффициентПересчета	= СокрЛП(ExcelЛист.Cells(Row, ЭтаФорма.НомерКолонкиКоэффициентПересчета).Text);
		ВидСоответствия	= ЭтаФорма.ВидСоответствия;
		
		ОбработатьДанные(КодНоменклатура, КодКонкурента, КоэффициентПересчета, ВидСоответствия);
		
	КонецЦикла;
	
	Excel.WorkBooks.Close();
	Excel = 0;

КонецПроцедуры

&НаСервере
Процедура ОбработатьДанные(КодНоменклатура, КодКонкурента, КоэффициентПересчета, ВидСоответствия)
	
	//Ищем собственную номенклатуру по коду
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Код = &Код";
	Запрос.УстановитьПараметр("Код", СокрЛП(КодНоменклатура));
	Результат = Запрос.Выполнить().Выбрать();
	Если Результат.Следующий() Тогда
		
		Номенклатура = Результат.Ссылка;
		
		НаборЗаписей = РегистрыСведений.СоответствиеНоменклатуры.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.Номенклатура.Установить(Номенклатура);
		НоваяЗапись = НаборЗаписей.Добавить();
		
		НоваяЗапись.ВидСоответствия			= ВидСоответствия;
		НоваяЗапись.Номенклатура			= Номенклатура;
		НоваяЗапись.КодКонкурента			= КодКонкурента;
		НоваяЗапись.КоэффициентПересчета	= КоэффициентПересчета;
		
		НаборЗаписей.Записать();
		
	КонецЕсли; 
	
КонецПроцедуры	

