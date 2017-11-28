
Процедура ОбработкаПроведения(Отказ, РежимПроведения)
	Для Каждого СтрокаТЧ Из ТЧ_Согласование Цикл 
		МенеджерЗаписи = РегистрыСведений.РезультатыМониторингаЦен.СоздатьМенеджерЗаписи();
		ЗаполнитьЗначенияСвойств(МенеджерЗаписи, СтрокаТЧ);
		МенеджерЗаписи.Прочитать();
		Если МенеджерЗаписи.Выбран() И НЕ МенеджерЗаписи.Обработано Тогда 
			МенеджерЗаписи.Обработано = Истина;
			МенеджерЗаписи.Записать(Истина);
		КонецЕсли;
	КонецЦикла;
КонецПроцедуры
