
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПриОткрытииНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПриОткрытииНаСервере()
	Изображение =  "<html>
			        |<body> <div align = center>
			        |<img width = auto height = 100% src='"+ Константы.КаталогФото.Получить() + СокрЛП(Объект.Фотография) + ".jpg" +"'/> </div>
			        |</body>
			        |</html>";
КонецПроцедуры
