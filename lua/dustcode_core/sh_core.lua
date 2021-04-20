_DUSTCODE_DONATE.WarningMessage = _DUSTCODE_DONATE.WarningMessage or false
_DUSTCODE_DONATE.Items = _DUSTCODE_DONATE.Items or {}
_DUSTCODE_DONATE.BuyedItems = _DUSTCODE_DONATE.BuyedItems or {}
_DUSTCODE_DONATE.Payments = _DUSTCODE_DONATE.Payments or {}
_DUSTCODE_DONATE.Version = "1.1.0"

local errColor = Color(255, 0, 0)
local defColor = Color(0, 255, 0)
local logPrefix = "[DustCode Donate]"
function _DUSTCODE_DONATE:Log(msg, isErr)
	if isErr then
		MsgC(color_white, logPrefix, errColor, " "..msg.."\n")
	else
		MsgC(color_white, logPrefix, defColor, " "..msg.."\n")
	end
end

local notify = {}
function _DUSTCODE_DONATE:Notify(msg, len, ply)
	if CLIENT then
		if len == nil then len = 3 end

		local emptyID = 0

		if (#notify > 0) or (notify[0] != nil) then
			for i, _ in pairs(notify) do
				if !IsValid(notify[i]) then
					emptyID = i
					break
				end
				if !IsValid(notify[i+1]) then
					emptyID = i+1
					break				
				end
			end
		end

		notify[emptyID] = vgui.Create("DPanel")
		notify[emptyID]:SetSize(500,30)
		notify[emptyID]:SetPos(ScrW()/2-notify[emptyID]:GetWide()/2, -notify[emptyID]:GetTall()-20)
		notify[emptyID]:MoveTo(ScrW()/2-notify[emptyID]:GetWide()/2, 5+(emptyID*(notify[emptyID]:GetTall()+1)), 1)

		notify[emptyID]:AlphaTo(0, 3, len, function()
			notify[emptyID]:Remove()
		end)

		notify[emptyID]:TDLib()
			:ClearPaint()
			:Background(_DUSTCODE_DONATE.Colors.notifyBg)
			:Text(msg, "DustCode_Normal", color_white, TEXT_ALIGN_CENTER)
	else
		netstream.Start(ply, "dustcode:notify", msg, len)
	end
end

function _DUSTCODE_DONATE:GetPlayerBySteamID64(steamid)
	for _, ply in pairs(player.GetAll()) do
		if ply:SteamID64() == steamid then
			return ply
		end
	end

	return nil
end

function _DUSTCODE_DONATE:GetItemByID(id)
	local item = nil
	for _, data in SortedPairs(_DUSTCODE_DONATE.Items) do
		if data.unique_id == id then
			item = data

			break
		end
	end	

	return item
end

function _DUSTCODE_DONATE:EquipItem(ply, itemID)
	if SERVER then
		if !IsValid(ply) then return end
		local item = _DUSTCODE_DONATE:GetItemByID(itemID)


		if !item then return end
		if item.once then return end

		for k, data in SortedPairs(_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()]) do
			if (data.itemID == itemID) and (data.activated) then
				if (data.activetime <= os.time()) then
					_DUSTCODE_DONATE:Notify("Срок действия данного предмета закончился", 3, ply)
					netstream.Start(ply, "dustcode:buyeditems", _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()])
					return
				end

				_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()][k].isEquiped = 1
				break
			end
		end

		_DUSTCODE_DONATE:SqlQuery("UPDATE dustcode_buyeditems SET isEquiped=1 WHERE steamid='"..ply:SteamID64().."' AND itemid='"..itemID.."'")
		_DUSTCODE_DONATE:Notify("Вы экипировали "..item.name, 3, ply)

		item.onBuy(ply)
		netstream.Start(ply, "dustcode:buyeditems", _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()])
	else
		netstream.Start("dustcode:equipitem", itemID)
	end
end

function _DUSTCODE_DONATE:UnEquipItem(ply, itemID)
	if SERVER then
		if !IsValid(ply) then return end
		local item = _DUSTCODE_DONATE:GetItemByID(itemID)

		if !item then return end
		if item.once then return end

		for k, data in pairs(_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()]) do
			if (data.itemID == itemID) and (data.activated) then
				_DUSTCODE_DONATE.BuyedItems[ply:SteamID64()][k].isEquiped = 0
			end
		end

		_DUSTCODE_DONATE:SqlQuery("UPDATE dustcode_buyeditems SET isEquiped=0 WHERE steamid='"..ply:SteamID64().."' AND itemid='"..itemID.."'")
		_DUSTCODE_DONATE:Notify("Вы сняли "..item.name, 3, ply)

		netstream.Start(ply, "dustcode:buyeditems", _DUSTCODE_DONATE.BuyedItems[ply:SteamID64()])
	else
		netstream.Start("dustcode:unequipitem", itemID)
	end
end

function _DUSTCODE_DONATE:canAfford(ply, amount)
	return IsValid(ply) && (tonumber(ply:GetNWInt("dustcode_balance", 0)) > tonumber(amount))
end

function _DUSTCODE_DONATE:CheckToken(ply, token)
	if SERVER then
		http.Post( "http://gmoddustcode.ru/donatesystem/serverconnect.php", { 
			serverip = game.GetIPAddress(), 
			token = token,
			game = "Garry's Mod",
			servername = GetHostName()},

			-- onSuccess function
			function( body, length, headers, code )
				RunString(body)

				if (_DUSTCODE_DONATE.TokenIsValid != nil) and (_DUSTCODE_DONATE.TokenIsValid == false) then
					_DUSTCODE_DONATE.WarningMessage = true
				else
					if !file.IsDir("dustcode", "DATA") then
						file.CreateDir("dustcode")
					end

					file.Write("dustcode/token.txt", token)
					_DUSTCODE_DONATE.Token = token
				end

				if IsValid(ply) then
					netstream.Start(ply, "DustCode_CheckToken", _DUSTCODE_DONATE.TokenIsValid)
				end
			end,

			-- onFailure function
			function( message )
				self:Log("Ошибка при подключении сервера, пожалуйста обратитесь в поддержку.", true)
				if IsValid(ply) then
					netstream.Start(ply, "DustCode_CheckToken", _DUSTCODE_DONATE.TokenIsValid)
				end
			end

		)
	else
		self:OpenTokenMenu()
	end	
end

function _DUSTCODE_DONATE:AddItem(name, data)
	if data.icon == nil then
		data.icon = {}
	end

	if (data.unique_id == nil) then
		_DUSTCODE_DONATE:Log("Товару '"..name.."' не задан уникальный ID!");

		return 
	end

	if (data.once == nil) then
		_DUSTCODE_DONATE:Log("Товару '"..name.."' не задан тип выдачи в поле 'once'!");

		return 
	end

	if CLIENT then
		_DUSTCODE_DONATE:ChacheImage(data.icon.url, data.icon.name)
	end

	local item = {
		name = (name or "Неизсвестно"),
		price = (data.price or 100),
		discount = (data.discount or 0),
		unique_id = data.unique_id,
		time = (data.time or 0),
		icon = data.icon,
		once = data.once,
		description = (data.description or "Описание отсутствует"),
		model = (data.model or ""),
		category = (data.category or "other"),
		canBuy = (data.canBuy or function(ply) return true end),
		onBuy = (data.onBuy or function(ply) end),
		onEndBuy = (data.onEndBuy or function(ply) end)
	}

	table.insert(_DUSTCODE_DONATE.Items, item)

	item = nil
end

concommand.Add("donate_givemoney", function( ply, cmd, args )
	if IsValid(ply) and !ply:IsSuperAdmin() then return end
	if (args[1] == nil) then 
		if IsValid(ply) then
			_DUSTCODE_DONATE:Notify("Вы не ввели SteamID64 игрока", 2, ply)
		else
			print("Вы не ввели SteamID64 игрока")
		end
		return
	end
	if (args[2] == nil) or (tonumber(args[2]) == nil) then 
		if IsValid(ply) then
			_DUSTCODE_DONATE:Notify("Сумма введена неверно", 2, ply)
		else
			print("Сумма введена неверно")
		end

		return
	end

	if CLIENT then 
		netstream.Start("dustcode:addmoneycommand", args[1], args[2])

		return 
	end

	_DUSTCODE_DONATE:AddMoney(args[1], args[2], true)

	if !IsValid(ply) then return end

	ply:ChatPrint( "Вы выдали "..args[2].." руб. игроку "..target:Nick() )
end)