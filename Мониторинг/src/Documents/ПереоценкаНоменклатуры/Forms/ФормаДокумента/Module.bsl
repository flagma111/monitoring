
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Не ЗначениеЗаполнено(Объект.Ссылка) Тогда 
		Объект.Ответственный = ОбщегоНазначения.ТекущийПользователь();
	КонецЕсли;
КонецПроцедуры
