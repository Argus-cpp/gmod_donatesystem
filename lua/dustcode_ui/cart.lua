local PANEL = {}

function PANEL:Init()
	self.category = "other"
	self:TDLib()
		:HideVBar()

	self.lThink = CurTime()
	self.lCount = -1

	self:Update(true)
end

function PANEL:Think()
	if self.lThink >= CurTime() then return end

	self:Update(false)

	self.lThink = CurTime() + 1
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
	Derma_Query( "Вы уверены, что хотите активировать "..data.name.."?", "Активация товара", "Да", function()
		netstream.Start("dustcode:ActivateItem", unique_id)
	end, "Нет")
end

function PANEL:Update(force)
	if self.lCount == table.Count(_DUSTCODE_DONATE.BuyedItems) and (force == false) then return end
	self:Clear()

	if table.Count(_DUSTCODE_DONATE.BuyedItems) == 0 then
		self.Paint = function(s,w,h)
			draw.SimpleText("Корзина пустая", "DustCode_Big", w/2,h/2,color_white, TEXT_ALIGN_CENTER)
		end

		return
	end

	self.lCount = table.Count(_DUSTCODE_DONATE.BuyedItems)

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

	for i, item in pairs(_DUSTCODE_DONATE.BuyedItems) do
		if (item.activated == 1) and (item.activetime <= os.time()) then continue end
		if (item.activated == 1) && (item.once) then continue end
		for _, data in SortedPairs(_DUSTCODE_DONATE.Items) do
			if item.itemID != data.unique_id then continue end

			local time = "Навсегда"

			if data.time > 0 then
				time = "На "..formatTime(data.time)
			end

			if (data.time == 0) and data.once then
				time = "Одноразово"
			end 

			local Pitem = vgui.Create("DPanel")
			Pitem:SetSize(170,240)
			Pitem:TDLib()
				:ClearPaint()
				:Outline(_DUSTCODE_DONATE.Colors.itemOutline, 4)
				//:Background(Color(5, 5, 5, 240))
				:Blur(1)
				:Gradient(_DUSTCODE_DONATE.Colors.itemGradient, BOTTOM, 1)
				//:BarHover(Color(0, 124, 148), 3)

			local title = vgui.Create("DPanel", Pitem)
			title:Dock(TOP)
			title:SetTall(40)
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

			local buyBtn = vgui.Create("DButton", Pitem)
			buyBtn:Dock(BOTTOM)
			buyBtn:SetTall(40)
			buyBtn:SetText("")
			buyBtn:TDLib()	
				:ClearPaint()
				:Background(_DUSTCODE_DONATE.Colors.buyBtn)
				:FadeHover(_DUSTCODE_DONATE.Colors.buyBtnHover)

			if data.once or (item.activated == 0) then
				buyBtn:Text("Активировать", "DustCode_Small")

				buyBtn.DoClick = function(s)
					netstream.Start("dustcode:ActivateItem", item.itemID)

					timer.Simple(0.5, function()
						if IsValid(self) then
							self:Update(true)
						end
					end)
				end
			else
				if item.isEquiped and (item.isEquiped == 1) then
					buyBtn:Text("Снять", "DustCode_Small")
					buyBtn.DoClick = function(s)
						_DUSTCODE_DONATE:UnEquipItem(nil, item.itemID)

						timer.Simple(0.5, function()
							if IsValid(self) then
								self:Update(true)
							end
						end)
					end
				else
					buyBtn:Text("Экипировать", "DustCode_Small")

					buyBtn.DoClick = function(s)
						_DUSTCODE_DONATE:EquipItem(nil, item.itemID)
						
						timer.Simple(0.5, function()
							if IsValid(self) then
								self:Update(true)
							end
						end)
					end
				end
			end

			local mat = _DUSTCODE_DONATE:GetImage(data.icon.name)
			local icon = vgui.Create("DPanel", Pitem)
			icon:Dock(FILL)
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

		if item.isEquiped and (item.isEquiped == 1) then
			local skidka = vgui.Create("DPanel", Pitem)
			skidka:SetSize(120,32)
			skidka:SetPos(Pitem:GetWide()-skidka:GetWide()-5, 43)
			skidka:TDLib()
				:ClearPaint()
				:Gradient(_DUSTCODE_DONATE.Colors.itemEquiped, RIGHT, 0.9)
				:Blur(1)
			
			local oldPaint = skidka.Paint
			skidka.Paint = function(s,w,h)
				oldPaint(s,w,h)

				draw.SimpleText("Экипирован", "DustCode_Small", w-1, h/2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
			end
		end

			Pitem.OnCursorEntered = function(s)
				Pitem:SetCursor('hand')
			end

			grid:AddItem(Pitem)
		end
	end
end

vgui.Register("DustCode_Cart", PANEL, "DScrollPanel")