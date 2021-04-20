local PANEL = {}

function PANEL:Init()
	self.category = "other"
	self:TDLib()
		:HideVBar()
end

function PANEL:SetCategory(name)
	self.category = name
end

local function formatTime(time)
	time = time * 60
	//local mo = math.floor(time/2592000)
	local d = math.floor(time/86400)
	local h = math.floor(math.fmod(time, 86400)/3600)
	local mi = math.floor(math.fmod(time, 3600)/60)
	return string.format("%02iд %02iч %02iм", d, h, mi)
end

local function BuyItem(data, unique_id)
	Derma_Query( "Вы уверены, что хотите купить "..data.name.."?", "Покупка товара", "Да", function()
		netstream.Start("dustcode:BuyItem", unique_id)
	end, "Нет")
end

function PANEL:Update()

	local w = self:GetParent():GetWide()

	local Cols = math.Round(w/175)

	if (175*Cols > w) then
		Cols = Cols - 1
	end

	local grid = self:Add("DGrid")
	grid:Dock(FILL)
	grid:DockMargin(w/3*.10, 5, 0, 0)
	//grid:SetPos( 5, 5 )
	grid:SetCols( Cols )
	grid:SetColWide( 175 )
	grid:SetRowHeight( 250 )

	local discountIcon = _DUSTCODE_DONATE:GetImage("discount.png")
	for i, data in SortedPairs(_DUSTCODE_DONATE.Items) do
		if self.category != data.category then continue end

		local time = "Навсегда"

		if data.time > 0 then
			time = "На "..formatTime(data.time)
		end

		if (data.time == 0) and data.once then
			time = "Одноразово"
		end 

		local item = vgui.Create("DPanel")
		item:SetSize(170,240)
		item:SetTooltip(data.description)
		item:SetTooltipPanelOverride("DustCode_Tooltip")
		item:TDLib()
			:ClearPaint()
			:Outline(_DUSTCODE_DONATE.Colors.itemOutline, 4)
			//:Background(Color(5, 5, 5, 240))
			:Blur(1)
			:Gradient(_DUSTCODE_DONATE.Colors.itemGradient, BOTTOM, 1)
			//:BarHover(Color(0, 124, 148), 3)

		local title = vgui.Create("DPanel", item)
		title:Dock(TOP)
		title:SetTall(50)
		title:DockPadding(5, 0, 0, 0)
		title:TDLib()
			:ClearPaint()
			:Background(_DUSTCODE_DONATE.Colors.itemTitle)
			:Blur(1)
		    :DualText(
		        data.name,
		        "DustCode_Small",
		        Color(255, 255, 255, 255),

		        time,
		        "DustCode_Small",
		        Color(200, 200, 200, 200),
		        TEXT_ALIGN_CENTER
		    )

		local buyBtn = vgui.Create("DButton", item)
		buyBtn:Dock(BOTTOM)
		buyBtn:SetTall(40)
		buyBtn:DockMargin(3, 0, 3, 3)
		buyBtn:SetText("")
		buyBtn:TDLib()	
			:ClearPaint()
			:Background(_DUSTCODE_DONATE.Colors.buyBtn)
			:FadeHover(_DUSTCODE_DONATE.Colors.buyBtnHover)

		local mat = _DUSTCODE_DONATE:GetImage(data.icon.name)
		local icon = vgui.Create("DPanel", item)
		icon:TDLib()
			:ClearPaint()
			:Stick(FILL, 10)
			:SquareFromHeight()

		if data.model and (data.model != "") then
			local model = vgui.Create("DAdjustableModelPanel", icon)
			model:Dock(FILL)
			model:SetModel(data.model)
			model:SetCamPos(Vector(131.452362, 13.228242, -3.541138))
			model:SetLookAng(Angle(-11.466, 184.647, 0.000))
			model:SetFOV(49.677134609016)
			function model:LayoutEntity( Entity ) return end
		else
			icon:Material(mat)

			icon.OnCursorEntered = function(s)
				icon:SetCursor('hand')
			end
		end

		item.OnCursorEntered = function(s)
			item:SetCursor('hand')
		end

		buyBtn.DoClick = function(s)
			BuyItem(data, data.unique_id)
		end

		grid:AddItem(item)

		if (data.discount) and (data.discount > 0) then
			local skidka = vgui.Create("DPanel", item)
			skidka:SetSize(120,32)
			skidka:SetPos(item:GetWide()-skidka:GetWide(), 50)
			skidka:TDLib()
				:ClearPaint()
				//:Gradient(Color(184, 18, 19,255), RIGHT, 0.9)
				:Gradient(_DUSTCODE_DONATE.Colors.background, RIGHT, 1)
				:Blur(1)
			
			local oldPaint = skidka.Paint
			skidka.Paint = function(s,w,h)
				oldPaint(s,w,h)

				surface.SetDrawColor(HSVToColor(CurTime() * 40 % 360, 1, 1))
				surface.SetMaterial(discountIcon)
				surface.DrawTexturedRect(w-32,0,32,32)

				draw.SimpleText("-"..(data.discount*100).."%", "DustCode_Normal", w-35, h/2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end

			buyBtn:DualText(
		        data.price.."RUB",
		        "DustCode_SmallStrike",
		        color_black,

		        (data.price-(data.price*data.discount)).." RUB",
		        "DustCode_Small",
		        color_white,
		        TEXT_ALIGN_CENTER
		    )
		else
			buyBtn:Text((data.price-(data.price*data.discount)).." RUB", "DustCode_Small")
		end
	end
end

vgui.Register("DustCode_Items", PANEL, "DScrollPanel")