local PANEL = {}

function PANEL:Init()
	self:TDLib()
		:ClearPaint()

	local w,h = self:GetParent():GetParent():GetWide()-260, self:GetParent():GetParent():GetTall()-28

	local amount = vgui.Create("DTextEntry", self)
	amount:SetSize(200,30)
	amount:SetFont("DustCode_Normal")
	amount:SetNumeric(true)
	//amount:SetTextColor(color_white)
	amount:SetPos(w/2-amount:GetWide()/2, h*.2)
	amount:SetPlaceholderText("Введите сумму")
	//amount:TDLib():ReadyTextbox()
	    //:FadeHover(Color(0,0,0))
	 //   :BarHover()

	local function CheckMinAmount()
		return (amount:GetValue() != "") and (tonumber(amount:GetValue()) > _DUSTCODE_DONATE.MinDonate)
	end

	local qiwi = vgui.Create("DPanel", self)
	qiwi:SetSize(w*.4,h*.4)
	qiwi:SetPos(w*.1, h/2-qiwi:GetTall()/1.7)
	qiwi:TDLib()
		:SquareFromWidth()
		:ClearPaint()
		:Background(Color(25,25,25,200))
		:Blur(1)
		:FadeHover(Color(35,35,35,200))
		:Gradient(Color(35, 35, 35,150))

	local qOldPaint = qiwi.Paint
	qiwi.Paint = function(s,w,h)
		qOldPaint(s,w,h)

		if s:IsHovered() then
			s:SetCursor('hand')
		end		

		surface.SetDrawColor(color_white)
		surface.SetMaterial(_DUSTCODE_DONATE:GetImage("qiwi.png"))
		surface.DrawTexturedRect(30,30,w-60,h-60)

		draw.RoundedBox(0,0,h-30,w,30,_DUSTCODE_DONATE.Colors.background)
		draw.SimpleText("Qiwi/Банк. карты", "DustCode_Normal", w/2,h-2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end

	qiwi.OnMousePressed = function()
		if !CheckMinAmount() then
			_DUSTCODE_DONATE:Notify("Минимальная сумма пополнения ".._DUSTCODE_DONATE.MinDonate.." рублей.")

			return 
		end

		gui.OpenURL("http://gmoddustcode.ru/donatesystem/qiwipay.php?amount="..amount:GetValue().."&steamid="..LocalPlayer():SteamID64().."&serverip="..game.GetIPAddress())
	end

	local another = vgui.Create("DPanel", self)
	another:SetSize(w*.4,h*.4)
	another:SetPos(w-another:GetWide()-w*.1+5, h/2-another:GetTall()/1.7)
	another:TDLib()
		:SquareFromWidth()
		:ClearPaint()
		:Background(Color(25,25,25,200))
		:Blur(1)
		:FadeHover(Color(35,35,35,200))
		:Gradient(Color(35, 35, 35,150))

	local aOldPaint = another.Paint
	another.Paint = function(s,w,h)
		aOldPaint(s,w,h)

		if s:IsHovered() then
			s:SetCursor('hand')
		end

		surface.SetDrawColor(color_white)
		surface.SetMaterial(_DUSTCODE_DONATE:GetImage("anotherwallet.png"))
		surface.DrawTexturedRect(30,30,w-60,h-60)

		draw.RoundedBox(0,0,h-30,w,30,_DUSTCODE_DONATE.Colors.background)
		draw.SimpleText("Другое", "DustCode_Normal", w/2,h-2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	end

	another.OnMousePressed = function()
		if !CheckMinAmount() then
			_DUSTCODE_DONATE:Notify("Минимальная сумма пополнения ".._DUSTCODE_DONATE.MinDonate.." рублей.")

			return 
		end

		gui.OpenURL("https://sci.interkassa.com?ik_co_id=6060c7595341fd43483dfca4&ik_pm_no="..(os.time()+math.random(100,10000)).."&ik_am="..amount:GetValue().."&ik_cur=RUB&ik_desc=Пополнение игрового счета&ik_x_steamid="..LocalPlayer():SteamID64().."&ik_x_serverip="..game.GetIPAddress())
	end
end

vgui.Register("DustCode_AddMoney", PANEL, "DPanel")