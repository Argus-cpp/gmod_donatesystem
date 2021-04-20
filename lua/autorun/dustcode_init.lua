//hook.Add("PostGamemodeLoaded", "dustcode:load", function()
	include("dustcode_libs/pon.lua")
	include("dustcode_libs/netstream.lua")
	----
	include("__dustcode_config.lua")
	include("dustcode_core/sh_core.lua")

	// UI Elements
	local fname, dir = file.Find("dustcode_ui/*", "LUA")
	for _, file in pairs(fname) do
		if SERVER then
			AddCSLuaFile("dustcode_ui/"..file)
		else
			include("dustcode_ui/"..file)
		end
	end

	if SERVER then
		AddCSLuaFile("dustcode_libs/pon.lua")
		AddCSLuaFile("dustcode_libs/netstream.lua")
		AddCSLuaFile("dustcode_libs/tdlib.lua")
		----
		AddCSLuaFile("__dustcode_config.lua")
		AddCSLuaFile("__dustcode_items.lua")
		AddCSLuaFile("dustcode_core/sh_core.lua")
		AddCSLuaFile("dustcode_core/cl_core.lua")
		----
		include("dustcode_core/sv_core.lua")
		---
		include("__dustcode_mysql.lua")
		include("dustcode_core/sv_sql.lua")
		include("__dustcode_items.lua")
	else
		include("dustcode_libs/tdlib.lua")
		include("dustcode_core/cl_core.lua")
		include("__dustcode_items.lua")
	end
//end)