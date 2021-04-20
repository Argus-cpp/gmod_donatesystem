local tokenFrame
function _DUSTCODE_DONATE:OpenTokenMenu()
	if IsValid(tokenFrame) then tokenFrame:Remove() end
	if !LocalPlayer():IsSuperAdmin() then return end

	tokenFrame = vgui.Create("DFrame")
	tokenFrame:SetSize(400,70)
	tokenFrame:Center()
	tokenFrame:SetAlpha(0)
	tokenFrame:ShowCloseButton(false)
	tokenFrame:SetTitle("")

	tokenFrame:AlphaTo(255, 1, 1, function()
		tokenFrame:MakePopup()
	end)

	tokenFrame:TDLib()
		:ClearPaint()
		:Background(_DUSTCODE_DONATE.Colors.background)
		:Blur(2)	

	local header = vgui.Create("DustCode_CloseButton", tokenFrame)
	header:SetHeader("Введите токен для подключения сервера")

	local textEntry = vgui.Create("DTextEntry", tokenFrame)
	textEntry:Dock(LEFT)
	textEntry:DockMargin(0, 10, 1, 1)
	textEntry:SetWide(250)
	textEntry:SetFont("DustCode_Normal")

	local okBtn = vgui.Create("DButton", tokenFrame)
	okBtn:Dock(LEFT)
	okBtn:SetWide(142)
	okBtn:DockMargin(0,10,1,1)
	okBtn:SetFont("DustCode_Small")
	okBtn:TDLib()
		:ClearPaint()
		:Background(Color(9, 132, 227,50))
		:CircleHover(Color(64,104,171,40))
		:CircleClick()
		:Text("ПОДКЛЮЧИТЬ")

	okBtn.DoClick = function()
		if string.len(textEntry:GetText()) < 5 then
			_DUSTCODE_DONATE:Notify("Токен введен некорректно", 2)
		else
			netstream.Start("DustCode_CheckToken", textEntry:GetText())
		end
	end
end

local dMenu
function _DUSTCODE_DONATE:OpenMenu()
	if !GetGlobalBool( "DustCode_TokenIsValid", false ) then
		_DUSTCODE_DONATE:OpenTokenMenu()

		return
	end

	if IsValid(dMenu) then dMenu:Remove() end

	dMenu = vgui.Create("DFrame")
	dMenu:SetSize(ScrW()*0.6,ScrH()*0.8)
	dMenu:Center()
	dMenu:MakePopup()
	dMenu:SetTitle("")
	dMenu:ShowCloseButton(false)
	dMenu:SetAlpha(0)
	dMenu:SetBackgroundBlur(true)

	dMenu:AlphaTo(255,0.5)

	dMenu:TDLib()
		//:ClearPaint()
		:Background(_DUSTCODE_DONATE.Colors.background)
		:Blur(4)
		:Gradient(_DUSTCODE_DONATE.Colors.backgroundGradient)

	local header = vgui.Create("DustCode_CloseButton", dMenu)
	header:SetHeader(GetHostName().." - Донат")

	local lMenu = vgui.Create("DPanel", dMenu)
	lMenu:Dock(LEFT)
	lMenu:DockMargin(1, 15, 1, 10)
	lMenu:SetWide(250)

	local rMenu = vgui.Create("DPanel", dMenu)
	rMenu:DockMargin(1, 5, 1, 1)
	rMenu:TDLib()
		:Stick(FILL)
		:ClearPaint()
		:Blur(2)

	function rMenu:Update(panelName)
		if IsValid(rMenu.content) then rMenu.content:Remove() end

		rMenu.content = vgui.Create(panelName, rMenu)
		rMenu.content:TDLib()
			:Stick(FILL,10)
			:Gradient(_DUSTCODE_DONATE.Colors.rightMenuGradient, LEFT, 0.95)
			:Blur(2)
			//:Gradient(Color(9, 132, 227,50), RIGHT, 0.5)
	end	

	rMenu:Update("DustCode_Items")
	rMenu.content:SetCategory(_DUSTCODE_DONATE.Categories[1].category)
	rMenu.content:Update()

	lMenu:TDLib()
		:ClearPaint()
		:Background(Color(48, 57, 82,0))

	local profileMenu = vgui.Create("DPanel", lMenu)
	profileMenu:Dock(TOP)
	profileMenu:DockMargin(0,0,0,3)
	profileMenu:SetTall(100)
	profileMenu:TDLib()
		:ClearPaint()
		:Background(_DUSTCODE_DONATE.Colors.profileBackground)
		//:Gradient(_DUSTCODE_DONATE.Colors.rightMenuGradient, LEFT)
		:SquareFromWidth()
		:LinedCorners(Color(225, 112, 85,200))

	local avatar = vgui.Create("DPanel", profileMenu)
	avatar:Dock(LEFT)
	avatar:SetWide(lMenu:GetWide()*.27)
	avatar:TDLib()
		:ClearPaint()
		:CircleAvatar():SetPlayer(LocalPlayer(), 184)

	local info = vgui.Create("DPanel", profileMenu)
	info:Dock(LEFT)
	info:DockMargin(5,0,0,0)
	info:SetWide(lMenu:GetWide()*.69)
	info:TDLib()
		:ClearPaint()
	    :DualText(
	        "ID: "..LocalPlayer():SteamID64(),
	        "DustCode_Small",
	        Color(255, 255, 255, 255),

	        "Баланс: "..LocalPlayer():GetNWInt("dustcode_balance", 0).." RUB",
	        "DustCode_Small",
	        Color(200, 200, 200, 200),
	        TEXT_ALIGN_LEFT
	    )

	local menuList = vgui.Create("DPanel", lMenu)
	menuList:DockMargin(0, 2, 0, 1)
	menuList:TDLib()
		:Stick(FILL)
		:ClearPaint()

	local addBalanceBtn = vgui.Create("DButton", lMenu)
	addBalanceBtn:Dock(BOTTOM)
	addBalanceBtn:DockMargin(0, 1, 0, 1)
	addBalanceBtn:SetText("")
	//addBalanceBtn:DockMargin(0, 1, 0, 1)
	addBalanceBtn:SetTall(30)
	addBalanceBtn:TDLib()
		:ClearPaint()
		:Background(_DUSTCODE_DONATE.Colors.addBalanceBackground)
		:Text("Пополнить баланс", "DustCode_Small", color_white, TEXT_ALIGN_LEFT, 15, 0, true)
		//:BarHover(Color(110, 39, 69,255))
		:CircleHover(_DUSTCODE_DONATE.Colors.addBalanceHover)

	addBalanceBtn.DoClick = function()
		rMenu:Update("DustCode_AddMoney")
	end

	local cartBtn = vgui.Create("DButton", lMenu)
	cartBtn:Dock(BOTTOM)
	cartBtn:DockMargin(0, 1, 0, 1)
	cartBtn:SetText("")
	cartBtn:SetTall(30)
	cartBtn:TDLib()
		:ClearPaint()
		:Background(_DUSTCODE_DONATE.Colors.leftButtonsBackground)
		:Text("Корзина", "DustCode_Small", color_white, TEXT_ALIGN_LEFT, 15, 0, true)
		//:BarHover(Color(110, 39, 69,255))
		:CircleHover(_DUSTCODE_DONATE.Colors.leftButtonsHover)

	cartBtn.DoClick = function()
		rMenu:Update("DustCode_Cart")
	end

	if LocalPlayer():IsSuperAdmin() then
		local buyHistory = vgui.Create("DButton", lMenu)
		buyHistory:Dock(BOTTOM)
		buyHistory:DockMargin(0, 1, 0, 1)
		buyHistory:SetText("")
		buyHistory:SetTall(30)
		buyHistory:TDLib()
			:ClearPaint()
			:Background(_DUSTCODE_DONATE.Colors.leftButtonsBackground)
			:Text("История покупок", "DustCode_Small", color_white, TEXT_ALIGN_LEFT, 15, 0, true)
			//:BarHover(Color(110, 119, 69,255))
			:CircleHover(_DUSTCODE_DONATE.Colors.leftButtonsHover)

		buyHistory.DoClick = function()
			rMenu:Update("DustCode_payHistory")
		end
	end

	local topDonators = vgui.Create("DButton", lMenu)
	topDonators:Dock(BOTTOM)
	topDonators:DockMargin(0, 1, 0, 1)
	topDonators:SetText("")
	topDonators:SetTall(30)
	topDonators:TDLib()
		:ClearPaint()
		:Background(_DUSTCODE_DONATE.Colors.leftButtonsBackground)
		:Text("ТОП Донатеры", "DustCode_Small", color_white, TEXT_ALIGN_LEFT, 15, 0, true)
		//:BarHover(Color(110, 39, 69,255))
		:CircleHover(_DUSTCODE_DONATE.Colors.leftButtonsHover)

	topDonators.DoClick = function()
		rMenu:Update("DustCode_TopDonaters")
	end	

	local lScrollMenu = vgui.Create("DScrollPanel", lMenu)
	lScrollMenu:Dock(FILL)
	lScrollMenu:TDLib()
		:HideVBar()

	local curCategory = _DUSTCODE_DONATE.Categories[1].category
	for i, data in SortedPairs(_DUSTCODE_DONATE.Categories) do
		local amount = 0

		for _, d in pairs(_DUSTCODE_DONATE.Items) do
			if d.category != data.category then continue end

			amount = amount + 1
		end

		if amount == 0 then continue end

		if data.name == nil then _DUSTCODE_DONATE:Log("В категории №"..i.." не введено имя категории.") continue end
		if data.category == nil then _DUSTCODE_DONATE:Log("В категории №"..i.." не введен тип категории.") continue end

		local btn = lScrollMenu:Add("DButton")
		btn:Dock(TOP)
		btn:SetTall(40)
		btn:DockMargin(0, 2, 0, 0)
		btn:SetText("")
		btn:TDLib()
			:ClearPaint()
			:Background(_DUSTCODE_DONATE.Colors.leftButtonsBackground)
			//:BarHover(Color(0, 77, 105))
			:CircleHover(_DUSTCODE_DONATE.Colors.leftButtonsHover)
			:CircleClick()
			:Blur(2)
			:Text(data.name, "DustCode_Normal", color_white, TEXT_ALIGN_LEFT, 15, 0, true)
			:SideBlock(_DUSTCODE_DONATE.Colors.title, 4, LEFT)

		btn.OnCursorEntered = function(s)
			s:SetCursor("hand")

			surface.PlaySound("UI/buttonrollover.wav")
		end

		local oldClick = btn.DoClick
		btn.DoClick = function(s)
			oldClick(s)

			rMenu:Update("DustCode_Items")
			rMenu.content:SetCategory(data.category)
			rMenu.content:Update()
		end
	end
end

function _DUSTCODE_DONATE:ChacheImage(url, name)
	if (url == nil) or (name == nil) then return end

	if !file.IsDir("dustcode/images", "DATA") then
		file.CreateDir("dustcode/images")
	end

	http.Fetch(url, function(data)
		file.Write("dustcode/images/"..name, data)
	end)
end

function _DUSTCODE_DONATE:ChacheImages()
	for _, data in pairs(_DUSTCODE_DONATE.Images) do
		_DUSTCODE_DONATE:ChacheImage(data.url, data.name)
	end
end

function _DUSTCODE_DONATE:GetImage(name)
	if name && file.Exists("dustcode/images/"..name, "DATA") then
		return Material("../data/dustcode/images/"..name)
	end

	return Material("../data/dustcode/images/default.png")
end

_DUSTCODE_DONATE:ChacheImages()

netstream.Hook("DustCode_CheckToken", function(bool)
	if bool then
		_DUSTCODE_DONATE:Notify("Сервер успешно подключен", 2)
		tokenFrame:Remove()		
	else
		_DUSTCODE_DONATE:Notify("Токен не прошел проверку", 2)
	end

	_DUSTCODE_DONATE.TokenIsValid = bool
end)

netstream.Hook("DustCode:OpenTokenMenu", _DUSTCODE_DONATE.OpenTokenMenu)
netstream.Hook("dustcode:notify", function(msg, len)
	_DUSTCODE_DONATE:Notify(msg, len)
end)

netstream.Hook("dustcode:buyeditems", function(data)
	PrintTable(data)
	_DUSTCODE_DONATE.BuyedItems = data
end)

netstream.Hook("dustcode:sendpayments", function(data)
	if !istable(data) then return end

	_DUSTCODE_DONATE.Payments = data
end)

netstream.Hook("dustcode:sendtop5", function(data)
	_DUSTCODE_DONATE.TopDonaters = data
end)

hook.Add("PostGamemodeLoaded", "dustcode:GamemodeLoaded", function()
	_DUSTCODE_DONATE:ChacheImages()
end)

hook.Add("PlayerButtonDown", "dustcode:openfromkey", function(_,key)
	if key == _DUSTCODE_DONATE.OpenKey then
		_DUSTCODE_DONATE:OpenMenu()
	end
end)

hook.Add("OnPlayerChat", "dustcode:openfromchat", function(ply,txt)
	if ply != LocalPlayer() then return end

	if table.HasValue(_DUSTCODE_DONATE.OpenCmds,txt) then
		_DUSTCODE_DONATE:OpenMenu()

		return ''
	end
end)