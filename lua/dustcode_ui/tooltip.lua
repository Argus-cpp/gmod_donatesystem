local PANEL = {}

function PANEL:Init()
	self:TDLib()
		:ClearPaint()
		:Background(Color(0,0,0,200))
		:Blur(2)
		:LinedCorners()

	self:SetFont("DustCode_Small")
	self:SetTextColor(color_white)
end



vgui.Register("DustCode_Tooltip", PANEL, "DTooltip")