--[[---------------------------------------------------------------------------
enxs-weapon_distributor
---------------------------------------------------------------------------]]
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.AddNetworkString("OpenWeaponDistributorMenu")
util.AddNetworkString("OpenListEditMenu")
util.AddNetworkString("LoadNewWeaponsJobs")
util.AddNetworkString("LoadWeaponsList")
util.AddNetworkString("BuyWeapon")

local weapons_jobs = {
  TEAM_CITIZEN = {
    {Name = "P2282", Class = "weapon_p2282", Price = "200"}
  },
  TEAM_POLICE = {
    {Name = "Stunstick", Class = "stunstick", Price = "50"},
    {Name = "Door ram", Class = "door_ram", Price = "100"},
    {Name = "USP", Class = "weapon_mad_usp", Price = "200"}
  },
  TEAM_GANG = {
    {Name = "Five seven", Class = "weapon_fiveseven2", Price = "200"},
    {Name = "MAC10", Class = "weapon_mac102", Price = "500"}
  }
}

net.Receive("LoadNewWeaponsJobs", function()
  weapons_jobs = net.ReadTable()
end)

local weapons_list = {
  {Name = "Stunstick", Class = "stunstick", Price = "50"},
  {Name = "Door ram", Class = "door_ram", Price = "100"},
  {Name = "P2282", Class = "weapon_p2282", Price = "200"},
  {Name = "USP", Class = "weapon_mad_usp", Price = "200"},
  {Name = "Glock", Class = "weapon_glock2", Price = "200"},
  {Name = "Five seven", Class = "weapon_fiveseven2", Price = "200"},
  {Name = "Deagle", Class = "weapon_deagle2", Price = "350"},
  {Name = "MP5", Class = "weapon_mp52", Price = "400"},
  {Name = "MAC10", Class = "weapon_mac102", Price = "500"},
  {Name = "AK-47", Class = "weapon_ak472", Price = "500"},
  {Name = "M4", Class = "weapon_m42", Price = "500"},
  {Name = "Shotgun", Class = "weapon_pumpshotgun2", Price = "500"},
  {Name = "Sniper", Class = "ls_sniper", Price = "650"}
}

function ENT:Initialize()
  self:SetModel("models/props_lab/reciever_cart.mdl")
  self:PhysicsInit(SOLID_VPHYSICS)
  self:SetMoveType(MOVETYPE_VPHYSICS)
  self:SetSolid(SOLID_VPHYSICS)
  self:SetUseType(SIMPLE_USE)

  local phys = self:GetPhysicsObject()
  if phys:IsValid() then
      phys:Wake()
  end

end

function ENT:Use(activator, caller)
  if not activator:IsPlayer() then return end
  local job = activator:Team()

  if activator:KeyDown(IN_WALK) and activator:IsAdmin() then
    net.Start("LoadWeaponsList")
    net.WriteTable(weapons_list)
    net.Send(activator)

    net.Start("OpenListEditMenu")
    net.WriteTable(weapons_jobs)
    net.Send(activator)
  else
    local weaponList = GetWeaponListForJob(job)
    if not weaponList then return end
  
    net.Start("OpenWeaponDistributorMenu")
    net.WriteTable(weaponList)
    net.WriteEntity(activator)
    net.Send(activator)
  end
  
  
end

function GetWeaponListForJob(job)

  print("called fromn job : ", job)

  if job == TEAM_CITIZEN then
    return weapons_jobs.TEAM_CITIZEN
  elseif job == TEAM_POLICE then 
    return weapons_jobs.TEAM_POLICE
  elseif job == TEAM_GANG then
    return weapons_jobs.TEAM_GANG
  end

  return {}
end

net.Receive("BuyWeapon", function(len, ply)
    local weapon = net.ReadTable()
    if not ply:canAfford(weapon.Price) then
        ply:ChatPrint("You can't afford this weapon.")
        return
    end
    ply:addMoney((-weapon.Price))
    ply:Give(weapon.Class)
end)

hook.Add("PlayerUse", "CheckCustomKeyCombo", function(ply, ent)
  if IsValid(ent) and ply:GetEyeTrace().Entity == ent then
      
  end
end)