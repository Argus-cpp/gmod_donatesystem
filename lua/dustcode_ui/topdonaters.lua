local PANEL = {}

function PANEL:Init()
	self.steamid = ""
	self.playerNick = ""
	self.isMultiColor = false
	self.text = ""
	self.mat = Material("icon.png")

	self:TDLib()
		:ClearPaint()

	local bgCol = Color(40,40,40)
	local textBg = Color(30,30,30)
	self:On("Paint", function(s,w,h)

		if self.steamid == "" then
			draw.RoundedBox(0, 0, 0, w, h, _DUSTCODE_DONATE.Colors.background)
			draw.SimpleText("Пусто", "DustCode_Normal", w/2, h/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

			return
		end

		if self.isMultiColor then
			bgCol = HSVToColor(CurTime() * 70 % 360, 1, 1)
			bgCol.a = 10
		end
		draw.RoundedBox(0, 0, 0, w, h, bgCol)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(self.mat)
		surface.DrawTexturedRect(30,30,w-60,h-60)

		draw.RoundedBox(0, 0, h-25, w, 25, _DUSTCODE_DONATE.Colors.background)

		bgCol.a = 255
		draw.SimpleText(self.text, "DustCode_Normal", w/2, 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)

		if self.isMultiColor then
			draw.SimpleText(self.playerNick, "DustCode_Normal", w/2, h-1, bgCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		else
			draw.SimpleText(self.playerNick, "DustCode_Normal", w/2, h-1, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end
	end)

	self.OnCursorEntered = function(s)
		if self.steamid == "" then return end

		s:SetCursor('hand')
	end

	self.OnMousePressed = function(s)
		if self.steamid == "" then return end

		gui.OpenURL("http://steamcommunity.com/profiles/"..self.steamid)
	end
end

vgui.Register("DustCode_TopSlot", PANEL, "DPanel")

PANEL = {}

local matTop1 = _DUSTCODE_DONATE:GetImage("top1.png")
local matTop2 = _DUSTCODE_DONATE:GetImage("top2.png")
local matTop3 = _DUSTCODE_DONATE:GetImage("top3.png")
local matTop4 = _DUSTCODE_DONATE:GetImage("top4.png")
local matTop5 = _DUSTCODE_DONATE:GetImage("top5.png")
function PANEL:Init()
	local top1 = vgui.Create("DustCode_TopSlot", self)
	top1:SetSize(150,150)
	top1:SetPos(self:GetParent():GetWide()/2-top1:GetWide()/2, 30)
	top1.mat = matTop1
	top1.text = "№1"

	if _DUSTCODE_DONATE.TopDonaters[1] then
		local nick = _DUSTCODE_DONATE:GetPlayerBySteamID64(_DUSTCODE_DONATE.TopDonaters[1].steamid)

		if nick == nil then
			nick = _DUSTCODE_DONATE.TopDonaters[1].steamid
		else
			nick = nick:Name()
		end

		top1.steamid = _DUSTCODE_DONATE.TopDonaters[1].steamid
		top1.playerNick = nick
		top1.isMultiColor = true
	end

	local top2 = vgui.Create("DustCode_TopSlot", self)
	top2:SetSize(150,150)
	top2:SetPos(30, 30+top2:GetTall()+5)
	top2.text = "№2"
	top2.mat = matTop2

	if _DUSTCODE_DONATE.TopDonaters[2] then
		local nick = _DUSTCODE_DONATE:GetPlayerBySteamID64(_DUSTCODE_DONATE.TopDonaters[2].steamid)

		if nick == nil then
			nick = _DUSTCODE_DONATE.TopDonaters[2].steamid
		else
			nick = nick:Name()
		end

		top2.steamid = _DUSTCODE_DONATE.TopDonaters[2].steamid
		top2.playerNick = nick
		top2.isMultiColor = false
	end

	local top3 = vgui.Create("DustCode_TopSlot", self)
	top3:SetSize(150,150)
	top3:SetPos(self:GetParent():GetWide()-30-top3:GetWide(), 30+top3:GetTall()+5)
	top3.mat = matTop3
	top3.text = "№3"

	if _DUSTCODE_DONATE.TopDonaters[3] then
		local nick = _DUSTCODE_DONATE:GetPlayerBySteamID64(_DUSTCODE_DONATE.TopDonaters[3].steamid)

		if nick == nil then
			nick = _DUSTCODE_DONATE.TopDonaters[3].steamid
		else
			nick = nick:Name()
		end

		top3.steamid = _DUSTCODE_DONATE.TopDonaters[3].steamid

		top3.playerNick = nick
		top3.isMultiColor = false
	end	

	local top4 = vgui.Create("DustCode_TopSlot", self)
	top4:SetSize(150,150)
	top4:SetPos(30, 30+top2:GetTall()+5+top4:GetTall()+30)
	top4.mat = matTop4
	top4.text = "№4"

	if _DUSTCODE_DONATE.TopDonaters[4] then
		local nick = _DUSTCODE_DONATE:GetPlayerBySteamID64(_DUSTCODE_DONATE.TopDonaters[4].steamid)

		if nick == nil then
			nick = _DUSTCODE_DONATE.TopDonaters[4].steamid
		else
			nick = nick:Name()
		end

		top4.steamid = _DUSTCODE_DONATE.TopDonaters[4].steamid
		top4.playerNick = nick
		top4.isMultiColor = false
	end

	local top5 = vgui.Create("DustCode_TopSlot", self)
	top5:SetSize(150,150)
	top5:SetPos(self:GetParent():GetWide()-30-top3:GetWide(), 30+top3:GetTall()+5+top5:GetTall()+30)
	top5.mat = matTop5
	top5.text = "№4"

	if _DUSTCODE_DONATE.TopDonaters[5] then
		local nick = _DUSTCODE_DONATE:GetPlayerBySteamID64(_DUSTCODE_DONATE.TopDonaters[5].steamid)

		if nick == nil then
			nick = _DUSTCODE_DONATE.TopDonaters[5].steamid
		else
			nick = nick:Name()
		end

		top5.steamid = _DUSTCODE_DONATE.TopDonaters[5].steamid
		top5.playerNick = nick
		top5.isMultiColor = false
	end
end

function PANEL:Paint()

end

vgui.Register("DustCode_TopDonaters", PANEL, "DPanel")