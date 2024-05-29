--[[---------------------------------------------------------------------------
enxs-weapon_distributor
---------------------------------------------------------------------------]]
include("shared.lua")

local weapons_list

function ENT:Initialize()
end

function ENT:Draw()
    self:DrawModel()

    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    surface.SetFont("HUDNumber5")
    local text = "Weapon distributor"
    local TextWidth = surface.GetTextSize(text)

    Ang:RotateAroundAxis(Ang:Up(), 90)
    Ang.r = 90

    cam.Start3D2D(Pos + Ang:Up() * 16 + Vector(0,0,40), Ang, 0.1)
        draw.WordBox(2, -TextWidth * 0.34, 20, text, "HUDNumber5", Color(0, 140, 30, 100), Color(255, 255, 255, 255))
    cam.End3D2D()
end

net.Receive("LoadWeaponsList", function()
  weapons_list = net.ReadTable()
end)

net.Receive("OpenWeaponDistributorMenu", function()
  local weaponList = net.ReadTable()
  local ply = net.ReadEntity()

  local frame = vgui.Create("DFrame")
  frame:SetTitle("Weapon Distributor")
  frame:SetSize(300, 400)
  frame:Center()
  frame:MakePopup()

  local scrollPanel = vgui.Create("DScrollPanel", frame)
  scrollPanel:Dock(FILL)

  if next(weaponList) == nil then
    
    local noWeaponAvailable = vgui.Create("DLabel", scrollPanel)
    noWeaponAvailable:SetText("No weapons available!")
    noWeaponAvailable:Dock(TOP)
    noWeaponAvailable:SetColor(Color ( 255, 255, 255))
    noWeaponAvailable:DockMargin(8, 8, 8, 8)
    noWeaponAvailable:SizeToContents()

  else

    for _, weapon in ipairs(weaponList) do
      local weaponPanel = vgui.Create("DPanel", scrollPanel)
      weaponPanel:SetSize(380, 50)
      weaponPanel:Dock(TOP)
      weaponPanel:DockMargin(10, 10, 10, 0)

      local weaponNameLabel = vgui.Create("DLabel", weaponPanel)
      weaponNameLabel:SetText(weapon.Name)
      weaponNameLabel:SetPos(10, 15)
      weaponNameLabel:SetSize(200, 20)
      weaponNameLabel:SetFont("DermaDefault")
      weaponNameLabel:SetColor(Color(21, 21, 21))

      local weaponPriceButton = vgui.Create("DButton", weaponPanel)
      weaponPriceButton:SetText("$" .. weapon.Price)
      weaponPriceButton:SetPos(200, 15)
      weaponPriceButton:SetSize(50, 20)
      weaponPriceButton:SetTextColor(Color(21, 21, 21))

      weaponPriceButton.Paint = function(self, w, h)
        if ply:canAfford(weapon.Price) then
          surface.SetDrawColor(0, 113, 0)
          surface.DrawRect(0, 0, w, h)
        else
          surface.SetDrawColor(97, 0, 0)
          surface.DrawRect(0, 0, w, h)
        end
        
      end
      weaponPriceButton.DoClick = function()
        net.Start("BuyWeapon")

        net.WriteTable(weapon)
        net.SendToServer()
        frame:Close()
      end
    end
  end
  
end)

net.Receive("OpenListEditMenu", function()
  local weapons_jobs = net.ReadTable()
  
  local frame = vgui.Create("DFrame")
  frame:SetTitle("Weapon Distributor")
  frame:SetSize(500, 600)
  frame:Center()
  frame:MakePopup()

  function frame:OnClose()
    net.Start("LoadNewWeaponsJobs")
    net.WriteTable(weapons_jobs)
    net.SendToServer()
  end
  
  local tabPanel = vgui.Create("DPropertySheet", frame)
  tabPanel:Dock(LEFT)
  tabPanel:SetHeight(200)
  tabPanel:SetWidth(300)
  
  local citizenContent = vgui.Create("DScrollPanel", tabPanel)
  local policeContent = vgui.Create("DScrollPanel", tabPanel)
  local gangstersContent = vgui.Create("DScrollPanel", tabPanel)

  local tabCitizen = tabPanel:AddSheet("Citizen", citizenContent, "icon16/user.png")
  local tabPolice = tabPanel:AddSheet("Police", policeContent, "icon16/shield.png")
  local tabGangsters = tabPanel:AddSheet("Gangsters",gangstersContent , "icon16/group.png")

  function addWeaponPanel(parent, weapon, index)
    local weaponPanel = vgui.Create("DPanel", parent)
    weaponPanel:SetSize(100, 50)
    weaponPanel:Dock(TOP)
    weaponPanel:DockMargin(10, 10, 20, 0)

    local weaponNameLabel = vgui.Create("DLabel", weaponPanel)
    weaponNameLabel:SetText(weapon.Name .. " - $".. weapon.Price)
    weaponNameLabel:SetPos(10, 15)
    weaponNameLabel:SetSize(180, 20)
    weaponNameLabel:SetFont("DermaDefault")
    weaponNameLabel:SetColor(Color(21, 21, 21))

    local weaponPriceButton = vgui.Create("DButton", weaponPanel)
    weaponPriceButton:SetText("Remove" )
    weaponPriceButton:SetPos(180, 15)
    weaponPriceButton:SetSize(50, 20)
    weaponPriceButton:SetTextColor(Color(21, 21, 21))

    weaponPriceButton.Paint = function(self, w, h)
      surface.SetDrawColor(97, 0, 0)
      surface.DrawRect(0, 0, w, h)
    end
    weaponPriceButton.DoClick = function()
      if IsValid(weaponPanel) then
        weaponPanel:Remove()

        if parent == citizenContent then
          table.remove(weapons_jobs.TEAM_CITIZEN, index)
        elseif parent == policeContent then
          table.remove(weapons_jobs.TEAM_POLICE, index)
        elseif parent == gangstersContent then
          table.remove(weapons_jobs.TEAM_GANG, index)
        end

      end
    end
  end
  
  
  // Populate citizen tab
  for i, weapon in ipairs(weapons_jobs.TEAM_CITIZEN) do
    addWeaponPanel(citizenContent, weapon, i)
  end
  
  // Populate police tab
  for _, weapon in ipairs(weapons_jobs.TEAM_POLICE) do
    addWeaponPanel(policeContent, weapon, i)
  end
  
  // Populate gangsters tab
  for _, weapon in ipairs(weapons_jobs.TEAM_GANG) do
    addWeaponPanel(gangstersContent, weapon, i)
  end
  
  
  local scrollPanel = vgui.Create("DScrollPanel", frame)
  scrollPanel:Dock(FILL)

  // Populate weapon scroll panel with weapons list
  for _, weapon in ipairs(weapons_list) do
    local weaponPanel = vgui.Create("DPanel", scrollPanel)
    weaponPanel:SetSize(100, 50)
    weaponPanel:Dock(TOP)
    weaponPanel:DockMargin(10, 10, 10, 0)

    local weaponNameLabel = vgui.Create("DLabel", weaponPanel)
    weaponNameLabel:SetText(weapon.Name .. " - $".. weapon.Price)
    weaponNameLabel:SetPos(10, 15)
    weaponNameLabel:SetSize(180, 20)
    weaponNameLabel:SetFont("DermaDefault")
    weaponNameLabel:SetColor(Color(21, 21, 21))

    local weaponPriceButton = vgui.Create("DButton", weaponPanel)
    weaponPriceButton:SetText("Add" )
    weaponPriceButton:SetPos(100, 15)
    weaponPriceButton:SetSize(50, 20)
    weaponPriceButton:SetTextColor(Color(21, 21, 21))

    weaponPriceButton.Paint = function(self, w, h)
      surface.SetDrawColor(0, 113, 0) -- Green color
      surface.DrawRect(0, 0, w, h)
    end
    weaponPriceButton.DoClick = function()
      
      local activeTab = tabPanel:GetActiveTab()
      if activeTab then
        
        local tabName = activeTab:GetText()
        local index

        if tabName == "Citizen" and not contains(weapons_jobs.TEAM_CITIZEN, weapon) then

          index = table.insert(weapons_jobs.TEAM_CITIZEN, weapon)

          addWeaponPanel(citizenContent, weapon, index)

        elseif tabName == "Police" and not contains(weapons_jobs.TEAM_POLICE, weapon) then

          index = table.insert(weapons_jobs.TEAM_POLICE, weapon)

          addWeaponPanel(policeContent, weapon, index)

        elseif tabName == "Gangsters" and not contains(weapons_jobs.TEAM_GANG, weapon) then

          index = table.insert(weapons_jobs.TEAM_GANG, weapon)

          addWeaponPanel(citizenContent, weapon, index)

        end

      end

    end
  end


  
end)

function contains(t, elem)
  for _, v in ipairs(t) do
    if v.Name == elem.Name then
      return true
    end
  end
  return false
end


function ENT:Think()
end
