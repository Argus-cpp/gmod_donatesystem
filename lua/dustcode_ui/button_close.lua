local BUTTON = {}

function BUTTON:Init()
	self:SetSize(32,25)
	self:SetPos(self:GetParent():GetWide()-self:GetWide()-6,5)
	self:SetFont("DustCode_Normal")

	self:TDLib()
		:SetRemove(self:GetParent())
		:ClearPaint()
		:Background(_DUSTCODE_DONATE.Colors.closeBtnBg)
		:FadeHover(_DUSTCODE_DONATE.Colors.closeBtnBgHover)
		:Text("✖")

end

function BUTTON:SetHeader(text)
	local oldPaint = self:GetParent().Paint

	self:GetParent().Paint = function(s,w,h)
		oldPaint(s,w,h)

		draw.RoundedBox(0,0,0,w,35,_DUSTCODE_DONATE.Colors.title)
		draw.SimpleText(text, "DustCode_Small", 5, 10, color_white)
	end
	//self:GetParent():Gradient(Color(9, 132, 227,100), TOP, 0.023)
end

vgui.Register("DustCode_CloseButton", BUTTON, "DButton")