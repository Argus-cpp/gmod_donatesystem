--[[-------------------------------------------------------------------------
						Добавление товаров

Пример со всеми возможнными полями:

/*_DUSTCODE_DONATE:AddItem("test", {
	price = 100, -- Цена
	category = "money",
	once = true, -- Если true, то он будет получен только при активации, если false, то при каждом спавне игрока
	unique_id = "item_weaponpistol_",
	icon = {url = "", name = "test.png"}, -- Икнонка товара, url - путь до картинки, name - уникальное имя картинки, например url = "https://test.ru/icon.png" рекомендуется размер 128x128
	discount = 0, -- Скидка, например 0.3 будет скидка 30%
	description = "Описание товара",
	model = "models/mossman.mdl", -- Если установлена модель, то иконка не будет отображаться
	time = 0, -- Как долго будет действовать товар, указывается в минутах, например 60 = 1 час. 0 - бесконечно
	canBuy = function(ply) -- Данная функция выполняется перед покупкой, например если у игрока закончился какой-то лимит, то он не может больше купить данный товар
		-- return false, "Вы не можете купить данный товар" // false -- запретить покупку, true -- разрешить, через запятую можно написать текст, который выведется игроку
	end,
	onBuy = function(ply) -- В аргумент передается игрок
		// Функция, которая выполнится после покупки товара
	end,
	onEndBuy = function(ply) -- Вызывается когда заканчивается срок товара, например когда нужно у игрока забрать админку

	end
})*/

---------------------------------------------------------------------------]]

--[[-------------------------------------------------------------------------
							Игровые деньги
---------------------------------------------------------------------------]]	

_DUSTCODE_DONATE.Items = {} -- Это трогать не нужно

_DUSTCODE_DONATE:AddItem("+200.000$", {
	category = "money",
	unique_id = "200_000darkrpmoney",
	icon = {url = "https://i.imgur.com/VkKpR1T.png", name = "200money.png"},
	price = 100,
	description = "Выдает вам 200.000$ игровых денег",
	discount = 0.3, -- 30% скидка
	once = true,
	onBuy = function(ply)
		ply:addMoney(200000)
	end
})

_DUSTCODE_DONATE:AddItem("+10.000$", {
	category = "money",
	unique_id = "10_000darkrpmoney",
	icon = {url = "https://i.imgur.com/xz878k2.png", name = "10000money.png"},
	price = 30,
	once = true,
	onBuy = function(ply)
		ply:addMoney(10000)
	end
})

--[[-------------------------------------------------------------------------
									Оружие
---------------------------------------------------------------------------]]	

_DUSTCODE_DONATE:AddItem("Пистолет", {
	category = "weapons",
	unique_id = "donate_pistol",
	icon = {url = "https://i.imgur.com/wAbvIyM.png", name = "pistol.png"},
	price = 500,
	once = false,
	time = 111503,
	onBuy = function(ply)
		ply:Give("weapon_pistol", false)
	end
})

_DUSTCODE_DONATE:AddItem("SMG", {
	category = "weapons",
	unique_id = "donate_smg",
	icon = {url = "https://img.icons8.com/color/96/000000/submachine-gun.png", name = "smg.png"},
	price = 30,
	once = false,
	model = "models/Items/ammoCrate_Rockets.mdl", -- Установлена модель товара, значит иконка будет игнорироваться
	time = 3,
	onBuy = function(ply)
		ply:Give("weapon_smg1", false)
	end
})

--[[-------------------------------------------------------------------------
								Привилегии
---------------------------------------------------------------------------]]

_DUSTCODE_DONATE:AddItem("Админка", {
	category = "ranks",
	unique_id = "donate_admin",
	icon = {url = "https://i.imgur.com/fvhNbps.png", name = "admin.png"},
	price = 500,
	once = true,
	time = 1,
	onBuy = function(ply)
		RunConsoleCommand("fadmin", "setaccess", ply:Nick(), "admin") -- Для FAdmin
		--RunConsoleCommand("ulx", "adduser", ply:Nick(), "admin") -- Для ULX
		--RunConsoleCommand("sam", "setrank", ply:Nick(), "admin") -- Для SAM
	end,
	onEndBuy = function(ply)
		RunConsoleCommand("fadmin", "setaccess", ply:Nick(), "user") -- Для FAdmin
		--RunConsoleCommand("ulx", "adduser", ply:Nick(), "user") -- Для ULX
		--RunConsoleCommand("sam", "setrank", ply:Nick(), "user") -- Для SAM
	end
})

_DUSTCODE_DONATE:AddItem("Модератор", {
	category = "ranks",
	unique_id = "donate_moder",
	icon = {url = "https://i.imgur.com/fvhNbps.png", name = "admin.png"},
	price = 150,
	once = true,
	time = 600,
	onBuy = function(ply)
		RunConsoleCommand("fadmin", "setaccess", ply:Nick(), "moder") -- Для FAdmin
		--RunConsoleCommand("ulx", "adduser", ply:Nick(), "moder") -- Для ULX
		--RunConsoleCommand("sam", "setrank", ply:Nick(), "moder") -- Для SAM
	end,
	onEndBuy = function(ply)
		RunConsoleCommand("fadmin", "setaccess", ply:Nick(), "user") -- Для FAdmin
		--RunConsoleCommand("ulx", "adduser", ply:Nick(), "user") -- Для ULX
		--RunConsoleCommand("sam", "setrank", ply:Nick(), "user") -- Для SAM
	end
})

--[[-------------------------------------------------------------------------
							Супер-способности
---------------------------------------------------------------------------]]	

_DUSTCODE_DONATE:AddItem("+30% к силе прыжка", {
	category = "supers",
	unique_id = "donate_30jumppower",
	icon = {url = "https://i.imgur.com/dYYoNVG.png", name = "jump.png"},
	price = 50,
	once = false,
	time = 2,
	onBuy = function(ply)
		ply.lOldJump = ply.lOldJump or ply:GetJumpPower() -- Сохраняем информацию о стандартном значении прыжка
		ply:SetJumpPower(ply.lOldJump + ply.lOldJump*.3) -- Умножаем на 30%
	end,
	onEndBuy = function(ply)
		ply:SetJumpPower(ply.lOldJump or 10) -- Ставим обратное значение, когда время вышло
	end
})

_DUSTCODE_DONATE:AddItem("+50HP", {
	category = "supers",
	unique_id = "donate_50health",
	icon = {url = "https://i.imgur.com/nUeVJMw.png", name = "50_health.png"},
	price = 50,
	once = false,
	time = 3,
	onBuy = function(ply)
		ply.oldMaxHealth = ply.oldMaxHealth or ply:GetMaxHealth() -- Сохраняем стандартное значние здоровья
		ply:SetMaxHealth(ply.oldMaxHealth + 50) -- Добавляем 50
		ply:SetHealth(ply:GetMaxHealth()) -- Ставим максимально значение здоровья при спавне
	end,
	onEndBuy = function(ply)
		ply:SetMaxHealth(ply.oldMaxHealth) -- Ставим обратное значение, когда время вышло
	end
})

_DUSTCODE_DONATE:AddItem("Скорость бега +30%", {
	category = "supers",
	unique_id = "donate_30runspeed",
	icon = {url = "https://i.imgur.com/lC0ujwE.png", name = "30run.png"},
	price = 50,
	once = false,
	time = 3,
	onBuy = function(ply)
		ply.oldRunSpeed = ply.oldRunSpeed or ply:GetRunSpeed() -- Сохраняем стандартное значние
		ply:SetRunSpeed(ply.oldRunSpeed + ply.oldRunSpeed*.3) -- Добавляем 30%
	end,
	onEndBuy = function(ply)
		ply:SetRunSpeed(ply.oldRunSpeed or ply:GetRunSpeed()) -- Ставим обратное значение, когда время вышло
	end
})

_DUSTCODE_DONATE:AddItem("50% к броне", {
	category = "supers",
	unique_id = "donate_50armor",
	icon = {url = "https://i.imgur.com/MFWR40i.png", name = "50armor.png"},
	price = 50,
	once = false,
	time = 1,
	onBuy = function(ply)
		ply:SetArmor(ply:Armor() + 50)
	end,
	onEndBuy = function(ply)
		-- Тут нечего не делаем, так как у брони нет функции ply:GetMaxArmor() по стандарту
	end
})

--[[-------------------------------------------------------------------------
								Модели
---------------------------------------------------------------------------]]

_DUSTCODE_DONATE:AddItem("G-Man", {
	category = "models",
	unique_id = "donate_gmanmodel",
	icon = {url = "https://i.imgur.com/RbA7ReR.png", name = "modelicon.png"},
	price = 100,
	once = false,
	model = "models/Kleiner.mdl", -- Установлена модель товара, значит иконка будет игнорироваться
	time = 1,
	onBuy = function(ply)
		ply:SetModel("models/player/gman_high.mdl")
	end,
	onEndBuy = function(ply)
		-- Тут нечего не делаем, так как у брони нет функции ply:GetMaxArmor() по стандарту
	end
})