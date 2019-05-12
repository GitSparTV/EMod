hook.Add( "AddToolMenuTabs", "EMod.SpawnMenuTab", function()
	spawnmenu.AddToolTab( "EMod", "EMod", "icon16/transmit.png" )
end )
--models/props_c17/utilitypolemount01a.mdl
EMod = {}
EMod.Components = {}

function EMod.RegisterComponent(ENT,name,category,manualSpawn,author,contact)
	if not name then error("] [EMod] Missing argument #1: name (string)") end
	ENT.PrintName = "EMod | "..name
	ENT.Author = author
	ENT.Contact = contact
	ENT.Category = "EMod"
	ENT.Spawnable = manualSpawn or false

	EMod.Components[ENT.Folder:gsub("entities/","")] = {Name=name,Category=category or "Uncategorized"}
end

EMod.Zero = "ZERO"
EMod.Plus = "ANODE"
EMod.Minus = "KATHODE"