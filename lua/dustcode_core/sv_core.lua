function _DUSTCODE_DONATE:AddMoney(ply, amount, notify)
	if ply == nil then return end
	local steamid = ply
	local curBalance = 0

	if !isstring(ply) and ply:IsPlayer() then
		steamid = ply:SteamID64()
		curBalance = ply:GetNWInt("dustcode_balance", 0)
		ply:SetNWInt("dustcode_balance", curBalance+amount)

		if notify then
			_DUSTCODE_DONATE:Notify("Ваш баланс был пополнен на "..amount.." руб!", 6, ply)
		end
	else
		local FindedPly = _DUSTCODE_DONATE:GetPlayerBySteamID64(ply)

		if IsValid(FindedPly) and FindedPly:IsPlayer() then
			curBalance = FindedPly:GetNWInt("dustcode_balance", 0)
			FindedPly:SetNWInt("dustcode_balance", curBalance + amount)

			if notify then
				_DUSTCODE_DONATE:Notify("Ваш баланс был пополнен на "..amount.." руб!", 6, FindedPly)
			end
		else
			local data = _DUSTCODE_DONATE:SqlQuery("SELECT balance FROM dustcode_players WHERE steamid='"..ply.."'")
			if data and data[1] then
				curBalance = data[1]['balance']
			end
		end
	end

	_DUSTCODE_DONATE:SqlQuery("UPDATE dustcode_players SET balance="..(curBalance+amount).." WHERE steamid='"..steamid.."'")

	hook.Run("DustCode_OnAddMoney", ply, amount)
end

local function UpdateItemsData(ply)
	local sqlData = _DUSTCODE_DONATE:SqlQuery("SELECT itemid,activetime,isactivated,isEquiped FROM dustcode_buyeditems WHERE steamid='"..ply:SteamID64().."'")

	_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()] = {}

	if sqlData and sqlData[1] then
		for _, data in pairs(sqlData) do
			if ((tonumber(data.isactivated) == 1) and (tonumber(data.activetime) <= os.time())) then continue end

			table.insert(_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()], {itemID = data.itemid, activated = tonumber(data['isactivated']), activetime = tonumber(data['activetime']), isEquiped = tonumber(data['isEquiped'])})
		end
	end

	local sendData = {}

	for _, data in pairs(_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()]) do
		local item = _DUSTCODE_DONATE:GetItemByID(data.itemID)

		if item == nil then continue end
		if item.once && item.isactivated then continue end

		table.insert(sendData, data)
	end

	netstream.Start(ply, "dustcode:buyeditems", sendData)

	sendData = nil
end

local function UpdatePaymentsData(ply)
	local data = _DUSTCODE_DONATE:SqlQuery("SELECT amount, date, steamid FROM dustcode_payments WHERE serverip='"..game.GetIPAddress().."'")

	if data and data[1] then
		netstream.Start(ply, "dustcode:sendpayments", data)
	end
end

function _DUSTCODE_DONATE:GiveItem(ply, itemID)
	if !IsValid(ply) then return end

	local finded = _DUSTCODE_DONATE:GetItemByID(itemID)

	if finded == nil then
		_DUSTCODE_DONATE:Log("Товар '"..itemID.."' не найден!");

		return
	end

	if _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()] == nil then 
		_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()] = {} 
	end

	table.insert(_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()], {itemID = finded.unique_id, activated = 0, activetime=finded.time, isEquiped = 0})

	_DUSTCODE_DONATE:SqlQuery("INSERT INTO dustcode_buyeditems (steamid, itemid, activetime, isactivated,isEquiped) VALUES ('"..ply:SteamID64().."', '"..itemID.."', '"..finded.time.."', 0, 0)")
	_DUSTCODE_DONATE:Notify("Вы получили "..finded.name.."!", 5, ply)

	netstream.Start(ply, "dustcode:buyeditems", _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()])

	hook.Run("DustCode_GiveItem", ply, itemID)
	UpdatePaymentsData(ply)
	data = nil
end

function _DUSTCODE_DONATE:ActivateItem(ply, itemID)
	if !IsValid(ply) then return end

	local ItemsData = _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()] 
	if ItemsData == nil then 
		return false
	end

	for _, data in pairs(ItemsData) do
		if (data.itemID == itemID) && (data.activated == 0) then
			local sqlData = _DUSTCODE_DONATE:SqlQuery("SELECT id FROM dustcode_buyeditems WHERE itemid='"..itemID.."' AND isactivated = 0")

			if sqlData and sqlData[1] then
				_DUSTCODE_DONATE:SqlQuery("UPDATE dustcode_buyeditems SET isactivated=1,activetime="..(os.time()+(data.activetime*60))..",isEquiped=0 WHERE id="..sqlData[1]['id'])
			end

			if !file.Exists("dustcode/buyers/"..ply:SteamID64()..".txt", "DATA") then
				file.Write("dustcode/buyers/"..ply:SteamID64()..".txt", util.TableToJSON({{time=(os.time()+(data.activetime*60)), itemID=itemID}}))
			else
				local fData = util.JSONToTable(file.Read("dustcode/buyers/"..ply:SteamID64()..".txt", "DATA"))

				table.insert(fData, {time=(os.time()+(data.activetime*60)), itemID=itemID, isEquiped = 0})

				file.Write("dustcode/buyers/"..ply:SteamID64()..".txt", util.TableToJSON(fData))
			end

			break
		end
	end

	UpdateItemsData(ply)

	data = nil
end

function _DUSTCODE_DONATE:TakeItem(ply, itemID)
	if !IsValid(ply) then return end

	local ItemsData = _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()] 
	if ItemsData == nil then 
		return false
	end

	for _, data in pairs(ItemsData) do
		if data.itemID == itemID then
			local sqlData = _DUSTCODE_DONATE:SqlQuery("SELECT id FROM dustcode_buyeditems WHERE itemid='"..itemID.."'")

			if sqlData and sqlData[1] then
				_DUSTCODE_DONATE:SqlQuery("DELETE FROM `dustcode_buyeditems` WHERE id="..sqlData[1]['id'])
			end

			ItemsData[_] = nil
			break
		end
	end

	UpdateItemsData(ply)

	hook.Run("DustCode_OnTakeItem", ply, itemID)
	data = nil
end

local function InitializePlayerData(ply)
	local plyData = _DUSTCODE_DONATE:SqlQuery("SELECT balance FROM dustcode_players WHERE steamid='"..ply:SteamID64().."'")
	local balance = 0

	if plyData[1]['balance'] == nil then
		_DUSTCODE_DONATE:SqlQuery("INSERT INTO dustcode_players (steamid, balance) VALUES ('"..ply:SteamID64().."', 0)")
	else
		balance = plyData[1]['balance']
	end

	ply:SetNWInt("dustcode_balance", balance)
end

local function UpdateTopPlayers()
	local plysData = _DUSTCODE_DONATE:SqlQuery("SELECT steamid FROM dustcode_players")

	if plysData then
		local paymentsData = {}
		for _, data in pairs(plysData) do
			local amount = _DUSTCODE_DONATE:SqlQuery("SELECT COUNT(amount) AS amount FROM dustcode_payments WHERE steamid='"..data.steamid.."'")

			//if amount[1] then
			//	http.Post("https://gmoddustcode.ru/getsteamnick.php", {
			//		steamid=data['steamid'],
			//	}, function(d)
			//		if (d == nil) or (d=="[]") then return end
					
					//print(d)
					table.insert(paymentsData, {steamid = data.steamid, amount = amount[1].amount/*, nickname = d*/})
			//	end)
			//end
		end

		table.sort( paymentsData, function(a, b) return a.amount > b.amount end )

		local top5 = {}
		local i = 1
		for _, data in SortedPairs(paymentsData) do
			top5[i] = {}
			top5[i].steamid = data.steamid
			top5[i].amount = data.amount
			//top5[i].nickname = data.nickname

			i = i + 1

			if i > 5 then break end
		end

		for _, ply in pairs(player.GetHumans()) do
			netstream.Start(ply, "dustcode:sendtop5", top5)
		end
	end
end

UpdateTopPlayers()

local function CheckPayments()
	http.Post("http://gmoddustcode.ru/donatesystem/getpayments.php", {
		token=_DUSTCODE_DONATE.Token,
		serverip=game.GetIPAddress(),
	}, function(d)
		if (d == nil) or (d=="[]") then return end
		d = util.JSONToTable(d)
		if !istable(d) then return end

		for _, data in pairs(d) do
			local balance = 0

			_DUSTCODE_DONATE:AddMoney(data['userid'], data['amount'], true)
			_DUSTCODE_DONATE:SqlQuery("INSERT INTO dustcode_payments (steamid, amount, serverip, date) VALUES ('"..data['userid'].."', "..data['amount']..", '"..game.GetIPAddress().."', '"..data['date'].."')")

			http.Post("http://gmoddustcode.ru/donatesystem/updatepayments.php", 
				{
					token = _DUSTCODE_DONATE.Token,
					steamid = data['userid'],
					serverip = game.GetIPAddress()
				})

			UpdateTopPlayers()
		end
	end)
end

local function CheckToken()
	local token = ""
	if !file.IsDir("dustcode", "DATA") then
		file.CreateDir("dustcode")

		file.Write("dustcode/token.txt", "-1")
	end

	if !file.IsDir("dustcode/buyers", "DATA") then
		file.CreateDir("dustcode/buyers")
	end

	if file.Exists("dustcode/token.txt", "DATA") then
		token = file.Read("dustcode/token.txt", "DATA")
	end

	_DUSTCODE_DONATE.Token = token

	timer.Simple(2, function()
		_DUSTCODE_DONATE:CheckToken(nil, token)
		CheckVersion()
		UpdateTopPlayers()
	end)
end

timer.Create("dustcode:checkpayemts", 10, 0, CheckPayments)

hook.Add("PlayerInitialSpawn", "dustcode:CheckToken", function(ply)
	if ply:IsSuperAdmin() and !_DUSTCODE_DONATE.TokenIsValid then

		timer.Simple(10, function()
			if _DUSTCODE_DONATE.TokenIsValid then return end

			netstream.Start(ply, "DustCode:OpenTokenMenu")
		end)
	end

	timer.Simple(1, function()
		if ply:IsSuperAdmin() then
			UpdatePaymentsData(ply)
		end

		InitializePlayerData(ply)
		UpdateItemsData(ply)
	end)
end)

hook.Add("PlayerSpawn", "dustcode:giveitems", function(ply)
	timer.Simple(1.05, function()
		local data =_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()] 

		if data then
			for _, d in pairs(data) do
				if ((d.activated == 1) and (d.activetime < os.time())) or ((d.activetime < 0) and (d.activated == 1)) or (d.isEquiped == 0) then continue end

				local itemData = _DUSTCODE_DONATE:GetItemByID(d.itemID)
				if itemData then
					if itemData.once then itemData = nil continue end

					itemData.onBuy(ply)
				end
			end
		end

		if file.Exists("dustcode/buyers/"..ply:SteamID64()..".txt", "DATA") then
			local fData = util.JSONToTable(file.Read("dustcode/buyers/"..ply:SteamID64()..".txt", "DATA"))

			for _, d in pairs(fData) do
				if d.time <= os.time() then
					local item = _DUSTCODE_DONATE:GetItemByID(d.itemID)

					if item then
						item.onEndBuy(ply)
					end

					fData[_] = nil
				end
			end

			file.Write("dustcode/buyers/"..ply:SteamID64()..".txt", util.TableToJSON(fData))
		end
	end)
end)

local function CheckVersion()
	http.Fetch("http://gmoddustcode.ru/donatesystem/scripts/version.php", function(data)
		if data != _DUSTCODE_DONATE.Version then
			_DUSTCODE_DONATE:Log("Новая версия "..data.." доступна для скачивания, текущая ".._DUSTCODE_DONATE.Version, true)
		end
	end)
end

hook.Add("PostGamemodeLoaded", "dustcode:LoadToken", CheckToken)

timer.Simple(7, function()
	CheckToken() -- Запихнул сюда, а то чето через github по http.fetch не грузит
end)

netstream.Hook("dustcode:BuyItem", function(ply, itemID)
	local item = _DUSTCODE_DONATE:GetItemByID(itemID)

	if item == nil then return end
	if !_DUSTCODE_DONATE:canAfford(ply, item.price) then
		_DUSTCODE_DONATE:Notify("Недостаточно денег", 3, ply)

		return
	end

	if item.canBuy then
		local can, msg = item.canBuy(ply)

		if !can then
			if msg then
				_DUSTCODE_DONATE:Notify(msg, 3, ply)
			end

			return 
		end
	end

	_DUSTCODE_DONATE:GiveItem(ply, itemID)
	_DUSTCODE_DONATE:AddMoney(ply, -(item.price - (item.price*item.discount)))
	_DUSTCODE_DONATE:Notify("Товар был успешно куплен и добавлен в корзину!", 3, ply)

	hook.Run("DustCode_OnBuyedItem", ply, itemID)
end)

netstream.Hook("dustcode:ActivateItem", function(ply, itemID)
	local itemsData = _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()]
	if itemsData == nil then return end

	local finded = false
	for _, d in pairs(itemsData) do
		if d.itemID != itemID then continue end
		if d.activated == 1 then continue end

		finded = true
		break
	end

	if !finded then return end

	local item = _DUSTCODE_DONATE:GetItemByID(itemID)
	if item.once then
		item.onBuy(ply) -- Вызов функции
	end

	_DUSTCODE_DONATE:Notify("Вы активировали "..item.name, 3, ply)
	_DUSTCODE_DONATE:ActivateItem(ply, itemID)

	hook.Run("DustCode_OnActivateItem", ply, itemID)
end)

netstream.Hook("DustCode_CheckToken", function(ply, token)
	if !ply:IsSuperAdmin() then return end

	_DUSTCODE_DONATE:CheckToken(ply, token)
end)

netstream.Hook("dustcode:equipitem", function(ply, itemID)
	_DUSTCODE_DONATE:EquipItem(ply, itemID)
end)

netstream.Hook("dustcode:unequipitem", function(ply, itemID)
	_DUSTCODE_DONATE:UnEquipItem(ply, itemID)
end)