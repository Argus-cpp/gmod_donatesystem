_DUSTCODE_DONATE = _DUSTCODE_DONATE or {}
_DUSTCODE_DONATE.TopDonaters = _DUSTCODE_DONATE.TopDonaters or {}
_DUSTCODE_DONATE.DataSaveType = "sqlite" -- mysqloo или sqlite // тип сохранения данных

if SERVER then return end

_DUSTCODE_DONATE.OpenKey = KEY_F6
_DUSTCODE_DONATE.OpenCmds = {"/donate", "!donate"}
_DUSTCODE_DONATE.MinDonate = 0.9 -- Минимальная сумма пополнения

-- Категории, которые отображаются слева в меню
_DUSTCODE_DONATE.Categories = {
	{
		name = "Оружие",
		category = "weapons",
	},
	{
		name = "Игровая валюта",
		category = "money",
	},
	{
		name = "Привилегии",
		category = "ranks",
	},
	{
		name = "Модели",
		category = "models",
	},
	{
		name = "Способности",
		category = "supers",
	},
	{ -- Не удаляйте данную категорию!
		name = "Другое",
		category = "other",
	},
}

--- Цвета, вы моежете изменить их значение
_DUSTCODE_DONATE.Colors = {
	//
	title = Color(195, 82, 55,100),
	background = Color(15, 22, 24),
	backgroundGradient = Color(30, 30, 30,130),
	//
	closeBtnBg = Color(25, 32, 34, 230),
	closeBtnBgHover = Color(45, 52, 54, 255),
	//
	textEntryBg = Color(10,10,10,250),
	//
	notifyBg = Color(20,20,20,200),
	//
	buyBtn = Color(0, 154, 118,100),
	buyBtnHover = Color(3, 116, 49,255),
	//
	itemOutline = Color(15, 22, 24, 255),
	itemGradient = Color(15, 22, 24),
	itemTitle = Color(15, 22, 24,255),
	itemEquiped = Color(214, 48, 49,255),
	//
	rightMenuGradient = Color(9, 102, 197,90),
	//
	profileBackground = Color(0,0,0,100),
	//
	addBalanceBackground = Color(195, 82, 55,70),
	addBalanceHover = Color(64,104,171,60),
	//
	leftButtonsBackground = Color(9, 102, 197,70),
	leftButtonsHover = Color(64,104,171,60),
}

_DUSTCODE_DONATE.Images = {
	{name="default.png", url="https://img.icons8.com/dotty/80/000000/question-mark.png"}, // Эту картинку удалять нельзя
	{name="qiwi.png", url="https://i.imgur.com/15vONPT.png"}, // Эту картинку удалять нельзя
	{name="anotherwallet.png", url="https://i.imgur.com/QiKVRQh.png"}, // Эту картинку удалять нельзя
	{name="discount.png", url="https://i.imgur.com/RdQVhNP.png"}, // Эту картинку удалять нельзя
	{name="top1.png", url="https://i.imgur.com/SEfjiqU.png"}, // Эту картинку удалять нельзя
	{name="top2.png", url="https://i.imgur.com/8a20BTV.png"}, // Эту картинку удалять нельзя
	{name="top3.png", url="https://i.imgur.com/buAT0ml.png"}, // Эту картинку удалять нельзя
	{name="top4.png", url="https://i.imgur.com/6YvwKrj.png"}, // Эту картинку удалять нельзя
	{name="top5.png", url="https://i.imgur.com/6YvwKrj.png"}, // Эту картинку удалять нельзя
}

surface.CreateFont("DustCode_Small", {font = "Times New Roman", size = 18, weight = 300})
surface.CreateFont("DustCode_SmallStrike", {font = "Times New Roma", size = 20, weight = 500, extended = true, rotary = true, strikeout = true})
surface.CreateFont("DustCode_Normal", {font = "Times New Roma", size = 24, weight = 400})
surface.CreateFont("DustCode_Big", {font = "Times New Roma", size = 32, weight = 500})