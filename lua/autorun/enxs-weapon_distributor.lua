MsgC( Color (200, 100, 100), "[enxs-stuff]", Color (255, 255, 255) , " - Loading enxs-weapon_distributor...\n" )

if SERVER then

  AddCSLuaFile("entities/enxs-weapon_distributor/cl_init.lua")
  AddCSLuaFile("entities/enxs-weapon_distributor/shared.lua")
  include("entities/enxs-weapon_distributor/init.lua")

elseif CLIENT then

  include("entities/enxs-weapon_distributor/cl_init.lua")
  
end

include("entities/enxs-weapon_distributor/shared.lua")
