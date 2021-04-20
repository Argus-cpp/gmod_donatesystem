local PANEL = {}

function PANEL:Init()
	self:TDLib()
		:ClearPaint()

	local AppList = vgui.Create( "DListView", self )
	AppList:Dock( FILL )
	AppList:SetMultiSelect( false )
	AppList:SetHeaderHeight(30)
	AppList:AddColumn( "Время" )
	AppList:AddColumn( "SteamID покупателя" )
	AppList:AddColumn( "Сумма" )
	AppList:TDLib()
		:ClearPaint()
		:Background(Color(255,255,255,100))
		:Blur(2)

	for _, data in pairs(_DUSTCODE_DONATE.Payments) do
		AppList:AddLine( data.date, data.steamid, data.amount )
	end
end

vgui.Register("DustCode_payHistory", PANEL, "DPanel")