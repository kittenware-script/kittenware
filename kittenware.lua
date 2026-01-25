print([[
KuromiWare On Top
==========================================================
|                        KuromiWare                      |
|--------------------------------------------------------|
| Version: v1.09                                         |
|                                                        |
| Bypass loading expect lag                              |
|                                                        |
| Undected: Maybe:3                                      |
| Loaded? Yes! Thanks for using KuromiWare               |
| Status: Loaded and ready to use!                       |
==========================================================
]])

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KuromiWareIntro"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

local introLabel = Instance.new("TextLabel")
introLabel.Size = UDim2.new(0, 500, 0, 100)
introLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
introLabel.AnchorPoint = Vector2.new(0.5, 0.5)
introLabel.BackgroundTransparency = 1
introLabel.Text = "KuromiWare"
introLabel.Font = Enum.Font.GothamBold
introLabel.TextSize = 64
introLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- fallback for gradient
introLabel.TextTransparency = 1 -- start invisible
introLabel.Parent = screenGui

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),   -- Pink
    ColorSequenceKeypoint.new(1, Color3.fromRGB(128, 0, 255))    -- Purple
}
gradient.Rotation = 45
gradient.Parent = introLabel

local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local fadeIn = TweenService:Create(introLabel, tweenInfo, {TextTransparency = 0})
fadeIn:Play()

delay(3.5, function()
    local fadeOut = TweenService:Create(introLabel, tweenInfo, {TextTransparency = 1})
    fadeOut:Play()

    -- Remove GUI after fade out
    fadeOut.Completed:Connect(function()
        screenGui:Destroy()
    end)
end)


loadstring(game:HttpGet('https://raw.githubusercontent.com/KuromiWare-v1/freebypasslmao/refs/heads/main/uhhhidk.lua'))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/kc-ignore/safety/refs/heads/main/AJKSDHJKDHDJKHSJKDHJDKSHJKSHDJKHD",true))()

local Players = game:GetService("Players")
local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

local correctPlaceId = 4991214437

if game.PlaceId ~= correctPlaceId then
    player:Kick("Wrong game!")
end


if getgenv().KittenWareLoaded or getgenv().KittenWareLoading then return end
getgenv().KittenWareLoading = true

----------------------------------------------------------------
-- Services & Locals
----------------------------------------------------------------
local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UIS         = game:GetService("UserInputService")
local StarterGui  = game:GetService("StarterGui")
local Lighting    = game:GetService("Lighting")
local Workspace   = game:GetService("Workspace")
local Stats       = game:GetService("Stats")
local MPS         = game:GetService("MarketplaceService")
local VIM         = game:GetService("VirtualInputManager")

local LP          = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

local function notify(t,x,d) pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d or 3}) end) end
local function clamp(v,a,b) return (v<a) and a or ((v>b) and b or v) end
local function lerp(a,b,t) return a + (b-a)*t end

----------------------------------------------------------------
-- UI (Exunys)
----------------------------------------------------------------
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Roblox-Functions-Library/main/Library.lua"))()
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/kitty92pm/AirHub-V2/refs/heads/main/src/UI%20Library.lua"))()

-- Tabs
local MainUI   = GUI:Load()
local Combat   = MainUI:Tab("Combat")
local SilentTab = MainUI:Tab("Silent")
local ESPTab   = MainUI:Tab("Visual")
local MiscTab  = MainUI:Tab("Exploits")
local World    = MainUI:Tab("Misc")
local HUDTab   = MainUI:Tab("HUD")
local Config   = MainUI:Tab("WL")
local About    = MainUI:Tab("Settings")

----------------------------------------------------------------
-- GLOBAL COLORS
----------------------------------------------------------------
local Theme = {
  Accent       = Color3.fromRGB(170, 120, 255),
  Good         = Color3.fromRGB(50, 220, 140),
  Danger       = Color3.fromRGB(255, 120, 120),
  Secondary    = Color3.fromRGB(230, 230, 235),
  PanelDark    = Color3.fromRGB(20, 20, 26),
  PanelMid     = Color3.fromRGB(40, 40, 55),
}

----------------------------------------------------------------
-- No Recoil (rename "Recoil" tags)
----------------------------------------------------------------
local nrEnabled, nrConns, charAddedConn = false, {}, nil
local function renameOne(inst) if inst and inst.Name=="Recoil" and not inst:GetAttribute("KW") then inst:SetAttribute("KW",true) inst.Name="_Recoil" end end
local function revertOne(inst) if inst and inst.Name=="_Recoil" and inst:GetAttribute("KW") then inst.Name="Recoil" inst:SetAttribute("KW",nil) end end
local function sweep(c) if c then for _,d in ipairs(c:GetDescendants()) do renameOne(d) end renameOne(c) end end
local function revert(c) if c then for _,d in ipairs(c:GetDescendants()) do revertOne(d) end revertOne(c) end end
local function watch(c) if not c then return end table.insert(nrConns,c.DescendantAdded:Connect(renameOne)) table.insert(nrConns,c.ChildAdded:Connect(renameOne)) end
local function unwatch() for _,c in ipairs(nrConns) do if c then c:Disconnect() end end nrConns={} end
local function onCharacter(ch) if not nrEnabled then return end sweep(ch) watch(ch) local bp=LP:FindFirstChildOfClass("Backpack") if bp then sweep(bp) watch(bp) end end
local function enableNR() nrEnabled=true unwatch() sweep(LP) watch(LP) onCharacter(LP.Character or LP.CharacterAdded:Wait()) if charAddedConn then charAddedConn:Disconnect() end charAddedConn=LP.CharacterAdded:Connect(onCharacter) end
local function disableNR() nrEnabled=false unwatch() if charAddedConn then charAddedConn:Disconnect() charAddedConn=nil end revert(LP) if LP.Character then revert(LP.Character) end local bp=LP:FindFirstChildOfClass("Backpack") if bp then revert(bp) end end

Combat:Section({Name="No Recoil", Side="Left"})
:Toggle({Name="Enabled",Flag="KW_NR",Default=false,Callback=function(v) if v then enableNR() else disableNR() end end})

----------------------------------------------------------------
-- ESP++ (Players + Drones) — Drawing API
----------------------------------------------------------------
local hasDrawing = (typeof(Drawing)=="table" and typeof(Drawing.new)=="function")
if not hasDrawing then notify("KuromiWare","Drawing API not found | ESP & HUD disabled.",5) end

local esp = {
  enabled          = false,
  conn             = nil,
  perfMode         = "Auto",
  updateEvery      = 1,
  counter          = 0,

  showSkeleton     = true,
  showBox          = true,
  showCornerBox    = true,
  showFilledBox    = false,
  cornerLen        = 8,
  fillAlpha        = 0.15,

  showTracers      = true,
  tracerOrigin     = "Bottom",

  showNames        = true,
  showHealth       = true,
  showDistance     = true,

  teamCheck        = false,
  useTeamColors    = false,
  onlyVisible      = false,
  passiveESP       = true,
  passiveTag       = " (P)",
  passiveColor     = Color3.fromRGB(150,210,255),

  maxDistance      = 2500,
  fadeByDistance   = true,
  visColor         = Color3.fromRGB(0,255,255),
  occColor         = Color3.fromRGB(255,100,100),
  thicknessBase    = 2.5,
  nearThick        = 3.0,
  farThick         = 1.0,
  alphaBase        = 0.9,

  itemESP          = true,
  itemESPColor     = Color3.fromRGB(255, 200, 120),
  itemSize         = 13,
  itemOffsetY      = 14,
  itemWhenNoTool   = false,

  droneEnabled     = true,
  droneColor       = Color3.fromRGB(255, 180, 60),
  droneName        = "DRONE",
  droneMaxDist     = 3000,
  droneTracers     = true,
  droneFilled      = true,
  droneFillAlpha   = 0.12,
}

local whitelist, ignorelist = {}, {}

local function sameTeam(plr)
  if not esp.teamCheck then return false end
  if LP.Team and plr.Team then return LP.Team==plr.Team end
  if LP.TeamColor and plr.TeamColor then return LP.TeamColor==plr.TeamColor end
  return false
end

local function isPassive(char)
  if not char then return false end
  if char:FindFirstChildOfClass("ForceField") then return true end
  for _,bp in ipairs(char:GetDescendants()) do
    if bp:IsA("BasePart") and bp.Material==Enum.Material.ForceField then return true end
  end
  local hum = char:FindFirstChildOfClass("Humanoid")
  if hum and (hum:GetAttribute("Passive")==true or hum:GetAttribute("Invulnerable")==true) then return true end
  if char:GetAttribute("Passive")==true then return true end
  return false
end

local function parts(char)
  return {
    hum = char:FindFirstChildOfClass("Humanoid"),
    hrp = char:FindFirstChild("HumanoidRootPart"),
    head= char:FindFirstChild("Head"),
    torso= char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"),
    lower= char:FindFirstChild("LowerTorso"),
    luArm= char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm"),
    llArm= char:FindFirstChild("LeftLowerArm"),
    lHand= char:FindFirstChild("LeftHand"),
    ruArm= char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm"),
    rlArm= char:FindFirstChild("RightLowerArm"),
    rHand= char:FindFirstChild("RightHand"),
    luLeg= char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg"),
    llLeg= char:FindFirstChild("LeftLowerLeg"),
    ruLeg= char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg"),
    rlLeg= char:FindFirstChild("RightLowerLeg"),
  }
end

local function vp(v3) local v,o=Camera:WorldToViewportPoint(v3); return Vector2.new(v.X,v.Y), o end

local function mkLine() local l=Drawing.new("Line") l.Visible=false l.Color=Color3.new(1,1,1) l.Thickness=esp.thicknessBase l.Transparency=esp.alphaBase return l end
local function mkText() local t=Drawing.new("Text") t.Visible=false t.Center=true t.Size=14 t.Outline=true t.Transparency=1 t.Color=Theme.Secondary return t end
local function mkSquare() local s=Drawing.new("Square") s.Visible=false s.Thickness=esp.thicknessBase s.Filled=false s.Color=Theme.Secondary s.Transparency=esp.alphaBase return s end

local buckets, signalMap = {}, {}
local function getBucket(plr)
  if buckets[plr] then return buckets[plr] end
  local b = {
    torso=mkLine(), lower=mkLine(), head=mkLine(),
    luArm=mkLine(), llArm=mkLine(), lHand=mkLine(),
    ruArm=mkLine(), rlArm=mkLine(), rHand=mkLine(),
    luLeg=mkLine(), llLeg=mkLine(), ruLeg=mkLine(), rlLeg=mkLine(),
    boxT=mkLine(), boxB=mkLine(), boxL=mkLine(), boxR=mkLine(),
    cTL1=mkLine(), cTL2=mkLine(), cTR1=mkLine(), cTR2=mkLine(),
    cBL1=mkLine(), cBL2=mkLine(), cBR1=mkLine(), cBR2=mkLine(),
    boxFill=mkSquare(),
    tracer=mkLine(),
    nameText=mkText(),
    distText=mkText(),
    itemText=mkText(),
    hpBack=mkSquare(),
    hpBar=mkSquare(),
  }
  buckets[plr]=b; return b
end
local function hideBucket(b) if not b then return end for _,o in pairs(b) do o.Visible=false end end
local function cleanPlayer(plr)
  local b=buckets[plr]; if b then for _,o in pairs(b) do o:Remove() end end buckets[plr]=nil
  local sigs=signalMap[plr]; if sigs then for _,c in ipairs(sigs) do if c then c:Disconnect() end end end signalMap[plr]=nil
end

local droneMap = {}  -- [Model] = bucket
local function mkDroneBucket()
  return {
    boxT=mkLine(), boxB=mkLine(), boxL=mkLine(), boxR=mkLine(),
    fill=mkSquare(),
    tracer=mkLine(),
    label=mkText(),
    dist=mkText(),
  }
end
local function hideDroneBucket(b) if not b then return end for _,o in pairs(b) do o.Visible=false end end
local function cleanDrone(m) local b=droneMap[m]; if b then for _,o in pairs(b) do o:Remove() end end droneMap[m]=nil end

local function dynThickness(dist)
  if not esp.fadeByDistance then return esp.thicknessBase, esp.alphaBase end
  local t = clamp(dist/esp.maxDistance, 0, 1)
  return lerp(esp.nearThick, esp.farThick, t), lerp(esp.alphaBase, 0.35, t)
end

local function LOS(part, char)
  local rp=RaycastParams.new(); rp.FilterType=Enum.RaycastFilterType.Blacklist
  rp.FilterDescendantsInstances={LP.Character, char}
  local origin=Camera.CFrame.Position
  local dir=part.Position-origin
  return Workspace:Raycast(origin,dir,rp)==nil
end

local function computeBBox(model)
  local cf,size = model:GetBoundingBox()
  local hx,hy,hz=size.X/2,size.Y/2,size.Z/2
  local C={Vector3.new( hx, hy, hz),Vector3.new(-hx, hy, hz),Vector3.new( hx, hy,-hz),Vector3.new(-hx, hy,-hz),
           Vector3.new( hx,-hy, hz),Vector3.new(-hx,-hy, hz),Vector3.new( hx,-hy,-hz),Vector3.new(-hx,-hy,-hz)}
  local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
  local on=false
  for _,c in ipairs(C) do
    local p=cf:PointToWorldSpace(c)
    local v,vis=Camera:WorldToViewportPoint(p)
    if vis then on=true end
    minX=math.min(minX,v.X); minY=math.min(minY,v.Y)
    maxX=math.max(maxX,v.X); maxY=math.max(maxY,v.Y)
  end
  return minX,minY,maxX,maxY,on
end

local function setLine(line,a,b,col,th,al)
  local av,ao=vp(a); local bv,bo=vp(b)
  if ao and bo then line.From=av line.To=bv line.Color=col line.Thickness=th line.Transparency=al line.Visible=true else line.Visible=false end
end

local function drawBoxLines(b,tl,tr,bl,br,col,th,al)
  b.boxT.From=tl; b.boxT.To=tr; b.boxT.Color=col; b.boxT.Thickness=th; b.boxT.Transparency=al; b.boxT.Visible=true
  b.boxB.From=bl; b.boxB.To=br; b.boxB.Color=col; b.boxB.Thickness=th; b.boxB.Transparency=al; b.boxB.Visible=true
  b.boxL.From=tl; b.boxL.To=bl; b.boxL.Color=col; b.boxL.Thickness=th; b.boxL.Transparency=al; b.boxL.Visible=true
  b.boxR.From=tr; b.boxR.To=br; b.boxR.Color=col; b.boxR.Thickness=th; b.boxR.Transparency=al; b.boxR.Visible=true
end

local function corners(b,tl,tr,bl,br,col,th,al,L)
  local function set(ln,a,b2) ln.From=a; ln.To=b2; ln.Color=col; ln.Thickness=th; ln.Transparency=al; ln.Visible=true end
  set(b.cTL1, tl, tl + Vector2.new(L,0)); set(b.cTL2, tl, tl + Vector2.new(0,L))
  set(b.cTR1, tr, tr + Vector2.new(-L,0)); set(b.cTR2, tr, tr + Vector2.new(0,L))
  set(b.cBL1, bl, bl + Vector2.new(L,0)); set(b.cBL2, bl, bl + Vector2.new(0,-L))
  set(b.cBR1, br, br + Vector2.new(-L,0)); set(b.cBR2, br, br + Vector2.new(0,-L))
end

local function tracerAnchor()
  if esp.tracerOrigin=="Center" then return Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
  elseif esp.tracerOrigin=="Mouse" then local m=UIS:GetMouseLocation(); return Vector2.new(m.X,m.Y)
  else return Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y) end
end

local function equippedName(ch)
  if not ch then return nil end
  for _,o in ipairs(ch:GetChildren()) do if o:IsA("Tool") then return o.Name end end
  return nil
end

local function updatePlayer(plr)
  if plr==LP or ignorelist[plr.Name] then local b=buckets[plr]; if b then hideBucket(b) end return end
  if sameTeam(plr) then local b=buckets[plr]; if b then hideBucket(b) end return end

  local ch=plr.Character; if not ch then local b=buckets[plr]; if b then hideBucket(b) end return end
  local p=parts(ch); local hum,hrp=p.hum,p.hrp
  if not hrp or not hum or hum.Health<=0 then local b=buckets[plr]; if b then hideBucket(b) end return end

  local dist=(hrp.Position - Camera.CFrame.Position).Magnitude
  if dist>esp.maxDistance then local b=buckets[plr]; if b then hideBucket(b) end return end

  local vis = LOS(hrp, ch) or (p.torso and LOS(p.torso, ch))
  if esp.onlyVisible and not vis then local b=buckets[plr]; if b then hideBucket(b) end return end

  local base = vis and esp.visColor or esp.occColor
  if esp.useTeamColors and plr.TeamColor then base = plr.TeamColor.Color end
  if esp.passiveESP and isPassive(ch) then base = esp.passiveColor end
  local col=base
  local th,a = dynThickness(dist)

  local b=getBucket(plr)

  if esp.showSkeleton then
    if p.torso then
      setLine(b.torso, p.torso.Position, hrp.Position, col, th, a)
      setLine(b.head,  (p.head and p.head.Position) or p.torso.Position, p.torso.Position, col, th, a)
      setLine(b.lower, (p.lower and p.lower.Position) or p.torso.Position, p.torso.Position, col, th, a)
    else b.torso.Visible=false b.head.Visible=false b.lower.Visible=false end
    setLine(b.luArm, (p.luArm and p.luArm.Position), (p.torso and p.torso.Position) or hrp.Position, col, th, a)
    if p.llArm then setLine(b.llArm, p.llArm.Position, (p.luArm and p.luArm.Position) or ((p.torso or hrp).Position), col, th, a) else b.llArm.Visible=false end
    if p.lHand then setLine(b.lHand, p.lHand.Position, (p.llArm and p.llArm.Position) or (p.luArm and p.luArm.Position), col, th, a) else b.lHand.Visible=false end
    setLine(b.ruArm, (p.ruArm and p.ruArm.Position), (p.torso and p.torso.Position) or hrp.Position, col, th, a)
    if p.rlArm then setLine(b.rlArm, p.rlArm.Position, (p.ruArm and p.ruArm.Position) or ((p.torso or hrp).Position), col, th, a) else b.rlArm.Visible=false end
    if p.rHand then setLine(b.rHand, p.rHand.Position, (p.rlArm and p.rlArm.Position) or (p.ruArm and p.ruArm.Position), col, th, a) else b.rHand.Visible=false end
    local pelvis = p.lower or p.torso or hrp
    setLine(b.luLeg, (p.luLeg and p.luLeg.Position), pelvis.Position, col, th, a)
    if p.llLeg then setLine(b.llLeg, p.llLeg.Position, (p.luLeg and p.luLeg.Position), col, th, a) else b.llLeg.Visible=false end
    setLine(b.ruLeg, (p.ruLeg and p.ruLeg.Position), pelvis.Position, col, th, a)
    if p.rlLeg then setLine(b.rlLeg, p.rlLeg.Position, (p.ruLeg and p.ruLeg.Position), col, th, a) else b.rlLeg.Visible=false end
  else
    b.torso.Visible=false b.head.Visible=false b.lower.Visible=false
    b.luArm.Visible=false b.llArm.Visible=false b.lHand.Visible=false
    b.ruArm.Visible=false b.rlArm.Visible=false b.rHand.Visible=false
    b.luLeg.Visible=false b.llLeg.Visible=false b.ruLeg.Visible=false b.rlLeg.Visible=false
  end

  local minX,minY,maxX,maxY,onScr = computeBBox(ch)
  local tl,tr,bl,br = Vector2.new(minX,minY), Vector2.new(maxX,minY), Vector2.new(minX,maxY), Vector2.new(maxX,maxY)
  if esp.showBox and onScr then
    drawBoxLines(b, tl,tr,bl,br, col, th, a)
    if esp.showCornerBox then corners(b, tl,tr,bl,br, col, th+0.5, a, esp.cornerLen)
    else b.cTL1.Visible=false b.cTL2.Visible=false b.cTR1.Visible=false b.cTR2.Visible=false
         b.cBL1.Visible=false b.cBL2.Visible=false b.cBR1.Visible=false b.cBR2.Visible=false end
    if esp.showFilledBox then
      b.boxFill.Filled=true; b.boxFill.Color=col; b.boxFill.Transparency=clamp(esp.fillAlpha,0.05,0.8)
      b.boxFill.Position=tl; b.boxFill.Size=Vector2.new(maxX-minX, maxY-minY); b.boxFill.Visible=true
    else b.boxFill.Visible=false end
  else
    b.boxT.Visible=false b.boxB.Visible=false b.boxL.Visible=false b.boxR.Visible=false
    b.cTL1.Visible=false b.cTL2.Visible=false b.cTR1.Visible=false b.cTR2.Visible=false
    b.cBL1.Visible=false b.cBL2.Visible=false b.cBR1.Visible=false b.cBR2.Visible=false
    b.boxFill.Visible=false
  end

  if esp.showHealth and hum and onScr then
    local hp, mh = hum.Health, math.max(1, hum.MaxHealth)
    local pct = clamp(hp/mh, 0, 1)
    local H   = (maxY - minY)
    local fill= H * pct
    local bw  = 4
    b.hpBack.Filled=true; b.hpBack.Color=Color3.fromRGB(30,30,30); b.hpBack.Transparency=0.6
    b.hpBack.Position=Vector2.new(minX - (bw+3), minY); b.hpBack.Size=Vector2.new(bw, H); b.hpBack.Visible=true
    local colhp = Color3.new(lerp(1,0,pct), 1, 0)
    b.hpBar.Filled=true; b.hpBar.Color=colhp; b.hpBar.Transparency=0.2
    b.hpBar.Position=Vector2.new(minX - (bw+3), maxY - fill); b.hpBar.Size=Vector2.new(bw, fill); b.hpBar.Visible=true
  else b.hpBack.Visible=false b.hpBar.Visible=false end

  local nameY = math.max(0, minY - 14)
  if esp.showNames and onScr then
    local name = plr.Name
    if esp.passiveESP and isPassive(ch) then name = name .. esp.passiveTag end
    local base = plr.TeamColor and esp.useTeamColors and plr.TeamColor.Color or Theme.Secondary
    if esp.passiveESP and isPassive(ch) then base = esp.passiveColor end
    b.nameText.Text = name; b.nameText.Color=base; b.nameText.Position=Vector2.new((minX+maxX)/2, nameY); b.nameText.Size=14; b.nameText.Visible=true
  else b.nameText.Visible=false end

  if esp.showDistance and onScr then
    b.distText.Text = string.format("%.0f", dist).."s"
    b.distText.Color=Theme.Secondary; b.distText.Position=Vector2.new((minX+maxX)/2, maxY+12); b.distText.Size=13; b.distText.Visible=true
  else b.distText.Visible=false end

  if esp.itemESP and onScr then
    local tname = equippedName(ch)
    if tname or esp.itemWhenNoTool then
      b.itemText.Text  = tname or ""
      b.itemText.Color = esp.itemESPColor
      b.itemText.Size  = esp.itemSize
      b.itemText.Position = Vector2.new((minX+maxX)/2, nameY + esp.itemOffsetY)
      b.itemText.Visible = (tname ~= nil) or esp.itemWhenNoTool
    else b.itemText.Visible=false end
  else b.itemText.Visible=false end

  if esp.showTracers and onScr then
    local p,_=Camera:WorldToViewportPoint(hrp.Position)
    b.tracer.From = tracerAnchor()
    b.tracer.To   = Vector2.new(p.X,p.Y)
    b.tracer.Color= col; b.tracer.Thickness=th; b.tracer.Transparency=a; b.tracer.Visible=true
  else b.tracer.Visible=false end
end

local function updateDrone(model)
  local b = droneMap[model] or mkDroneBucket(); droneMap[model]=b
  if not esp.droneEnabled then hideDroneBucket(b) return end

  local cf,_ = model:GetBoundingBox()
  local center = cf.Position
  local dist = (center - Camera.CFrame.Position).Magnitude
  if dist > esp.droneMaxDist then hideDroneBucket(b) return end

  local minX,minY,maxX,maxY,onScr = computeBBox(model)
  if not onScr then hideDroneBucket(b) return end

  local tl,tr,bl,br = Vector2.new(minX,minY), Vector2.new(maxX,minY), Vector2.new(minX,maxY), Vector2.new(maxX,maxY)
  local th, al = 2, 0.9
  drawBoxLines(b, tl,tr,bl,br, esp.droneColor, th, al)

  if esp.droneFilled then
    b.fill.Filled=true; b.fill.Color=esp.droneColor; b.fill.Transparency=clamp(esp.droneFillAlpha,0.05,0.8)
    b.fill.Position=tl; b.fill.Size=Vector2.new(maxX-minX, maxY-minY); b.fill.Visible=true
  else b.fill.Visible=false end

  b.label.Text = (model.Name and model.Name ~= "" and model.Name) or "DRONE"
  b.label.Color = esp.droneColor
  b.label.Size = 14
  b.label.Position = Vector2.new((minX+maxX)/2, math.max(0, minY - 14))
  b.label.Visible = true

  b.dist.Text = string.format("%.0f", dist).."s"
  b.dist.Color = Theme.Secondary
  b.dist.Size = 13
  b.dist.Position = Vector2.new((minX+maxX)/2, maxY + 12)
  b.dist.Visible = true

  if esp.droneTracers then
    local v,_ = Camera:WorldToViewportPoint(center)
    b.tracer.From = tracerAnchor()
    b.tracer.To = Vector2.new(v.X, v.Y)
    b.tracer.Color = esp.droneColor
    b.tracer.Thickness = 2
    b.tracer.Transparency = 0.9
    b.tracer.Visible = true
  else b.tracer.Visible=false end
end

local DroneFolderSet = {} -- [Model] = true
local function considerInstance(inst)
  if inst:IsA("Model") and inst.Name == "DroneModel" then
    DroneFolderSet[inst] = true
  end
end
for _,d in ipairs(Workspace:GetDescendants()) do considerInstance(d) end
local descAddConn = Workspace.DescendantAdded:Connect(considerInstance)
local descRemConn = Workspace.DescendantRemoving:Connect(function(inst)
  if DroneFolderSet[inst] then DroneFolderSet[inst]=nil cleanDrone(inst) end
end)

local signalMapGlobal = {}
local function hookSignals(plr)
  signalMap[plr] = signalMap[plr] or {}
  table.insert(signalMap[plr], plr.CharacterRemoving:Connect(function() local b=buckets[plr]; if b then hideBucket(b) end end))
end

esp.chineseHatLocal  = false  -- local player
esp.chineseHatOthers = false  -- other players
esp.chineseHatColor  = Color3.fromRGB(255, 255, 255) -- default color
local chineseHatMap = {}      -- [Character] = cone part

-- Create a cone for a character
local function createHatESP(character)
    if not character or chineseHatMap[character] then return end
    local head = character:FindFirstChild("Head")
    if not head then return end

    local cone = Instance.new("Part")
    cone.Name = "KW_ChineseHatESP"
    cone.Size = Vector3.new(1,1,1)
    cone.BrickColor = BrickColor.new("White")
    cone.Transparency = 0.3
    cone.Anchored = false
    cone.CanCollide = false

    local mesh = Instance.new("SpecialMesh", cone)
    mesh.MeshType = Enum.MeshType.FileMesh
    mesh.MeshId = "rbxassetid://1033714"
    mesh.Scale = Vector3.new(1.7,1.1,1.7)

    local weld = Instance.new("Weld")
    weld.Part0 = head
    weld.Part1 = cone
    weld.C0 = CFrame.new(0, 0.9, 0)

    cone.Parent = character
    weld.Parent = cone

    local highlight = Instance.new("Highlight", cone)
    highlight.FillColor = esp.chineseHatColor
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = esp.chineseHatColor
    highlight.OutlineTransparency = 1

    chineseHatMap[character] = cone
end

-- Remove cone from character
local function removeHatESP(character)
    local cone = chineseHatMap[character]
    if cone then
        cone:Destroy()
        chineseHatMap[character] = nil
    end
end

-- Update all hats based on toggles & ESP state
local function updateHatESP()
    if not esp.enabled then
        -- Hide all hats if ESP is off
        for char, _ in pairs(chineseHatMap) do
            removeHatESP(char)
        end
        return
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        local ch = plr.Character
        if ch then
            local apply = false
            if esp.chineseHatLocal and plr == LP then apply = true end
            if esp.chineseHatOthers and plr ~= LP then apply = true end

            if apply then
                if not chineseHatMap[ch] then
                    createHatESP(ch)
                else
                    -- Update color dynamically
                    local highlight = chineseHatMap[ch]:FindFirstChildOfClass("Highlight")
                    if highlight then
                        highlight.FillColor = esp.chineseHatColor
                        highlight.OutlineColor = esp.chineseHatColor
                    end
                end
            else
                removeHatESP(ch)
            end
        end
    end
end

-- Reapply hats on player respawn/death
local function hookPlayer(plr)
    plr.CharacterAdded:Connect(function(char)
        char:WaitForChild("Head")
        task.wait(0.05)
        updateHatESP()
    end)
    plr.CharacterRemoving:Connect(function()
        local ch = plr.Character
        if ch then removeHatESP(ch) end
    end)
end

-- Hook existing and new players
for _, plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
Players.PlayerAdded:Connect(hookPlayer)

local oldEnableESP = enableESP
local oldDisableESP = disableESP

function enableESP()
    oldEnableESP()
    updateHatESP()  -- show hats immediately when ESP turns on
end

function disableESP()
    oldDisableESP()
    updateHatESP()  -- hide all hats immediately when ESP turns off
end


local function updateESP()
  esp.counter += 1
  local stepEvery = (esp.perfMode=="Fast") and 2 or 1
  if esp.perfMode=="Max" then stepEvery=1 end
  if esp.counter % stepEvery ~= 0 then return end

  for _,plr in ipairs(Players:GetPlayers()) do updatePlayer(plr) end
  for model,_ in pairs(DroneFolderSet) do
    if model and model.Parent then updateDrone(model) else DroneFolderSet[model]=nil cleanDrone(model) end
  end
end

local function enableESP()
  if not hasDrawing then notify("KuromiWare","ESP requires Drawing API",4) return end
  if esp.conn then esp.conn:Disconnect() end
  esp.enabled=true
  esp.conn = RunService.RenderStepped:Connect(updateESP)
  for _,plr in ipairs(Players:GetPlayers()) do hookSignals(plr) end
  if not signalMapGlobal.__rem then
    signalMapGlobal.__rem = Players.PlayerRemoving:Connect(function(plr) cleanPlayer(plr) end)
    signalMapGlobal.__add = Players.PlayerAdded:Connect(function(plr) hookSignals(plr) end)
  end
end
local function disableESP()
  esp.enabled=false
  if esp.conn then esp.conn:Disconnect() esp.conn=nil end
  for plr in pairs(buckets) do cleanPlayer(plr) end
  for m in pairs(droneMap) do cleanDrone(m) end
end

do
  local L = ESPTab:Section({Name="Players | Core", Side="Left"})
  L:Toggle({Name="Enable ESP", Flag="KW_ESP_EN", Default=false, Callback=function(v) if v then enableESP() else disableESP() end end})
  L:Dropdown({Name="Performance", Flag="KW_ESP_PERF", Content={"Auto","Fast","Max"}, Default="Auto", Callback=function(v) esp.perfMode=v end})
  L:Slider({Name="Max Distance", Flag="KW_ESP_MD", Default=esp.maxDistance, Min=200, Max=6000, Callback=function(v) esp.maxDistance=v end})
  L:Toggle({Name="Fade by Distance", Flag="KW_ESP_FBD", Default=esp.fadeByDistance, Callback=function(v) esp.fadeByDistance=v end})
  L:Toggle({Name="Only Visible (LOS)", Flag="KW_ESP_VIS", Default=esp.onlyVisible, Callback=function(v) esp.onlyVisible=v end})
  L:Toggle({Name="Team Check", Flag="KW_ESP_TC", Default=esp.teamCheck, Callback=function(v) esp.teamCheck=v end})
  L:Toggle({Name="Use Team Colors", Flag="KW_ESP_UCT", Default=esp.useTeamColors, Callback=function(v) esp.useTeamColors=v end})

  local R = ESPTab:Section({Name="Players | Elements", Side="Right"})
  R:Toggle({Name="Skeleton", Flag="KW_ESP_SKEL", Default=esp.showSkeleton, Callback=function(v) esp.showSkeleton=v end})
  R:Toggle({Name="Box", Flag="KW_ESP_BOX", Default=esp.showBox, Callback=function(v) esp.showBox=v end})
  R:Toggle({Name="Corner Box", Flag="KW_ESP_CBOX", Default=esp.showCornerBox, Callback=function(v) esp.showCornerBox=v end})
  R:Slider({Name="Corner Length", Flag="KW_ESP_CL", Default=esp.cornerLen, Min=4, Max=24, Callback=function(v) esp.cornerLen=v end})
  R:Toggle({Name="Fill Box", Flag="KW_ESP_FILL", Default=esp.showFilledBox, Callback=function(v) esp.showFilledBox=v end})
  R:Slider({Name="Fill Alpha %", Flag="KW_ESP_FA", Default=math.floor(esp.fillAlpha*100), Min=5, Max=80, Callback=function(v) esp.fillAlpha=clamp(v/100,0.05,0.8) end})
  R:Toggle({Name="Tracers", Flag="KW_ESP_TR", Default=esp.showTracers, Callback=function(v) esp.showTracers=v end})
  R:Dropdown({Name="Tracer Origin", Flag="KW_ESP_TO", Content={"Bottom","Center","Mouse"}, Default=esp.tracerOrigin, Callback=function(v) esp.tracerOrigin=v end})
  R:Toggle({Name="Name", Flag="KW_ESP_NAME", Default=esp.showNames, Callback=function(v) esp.showNames=v end})
  R:Toggle({Name="Health Bar", Flag="KW_ESP_HP", Default=esp.showHealth, Callback=function(v) esp.showHealth=v end})
  R:Toggle({Name="Distance", Flag="KW_ESP_DIST", Default=esp.showDistance, Callback=function(v) esp.showDistance=v end})

  local I = ESPTab:Section({Name="Players | Item ESP | Style", Side="Left"})
  I:Toggle({Name="Item ESP", Flag="KW_ITEM_EN", Default=esp.itemESP, Callback=function(v) esp.itemESP=v end})
  I:Colorpicker({Name="Item Text Color", Flag="KW_ITEM_COL", Default=esp.itemESPColor, Callback=function(c) esp.itemESPColor=c end})
  I:Slider({Name="Item Size", Flag="KW_ITEM_SZ", Default=esp.itemSize, Min=10, Max=22, Callback=function(v) esp.itemSize=math.floor(v) end})
  I:Slider({Name="Item Offset Y", Flag="KW_ITEM_OY", Default=esp.itemOffsetY, Min=8, Max=28, Callback=function(v) esp.itemOffsetY=math.floor(v) end})
  I:Toggle({Name="Show When No Tool", Flag="KW_ITEM_SNT", Default=esp.itemWhenNoTool, Callback=function(v) esp.itemWhenNoTool=v end})

  local P = ESPTab:Section({Name="Players | Passive | Colors", Side="Right"})
  P:Toggle({Name="Show (P) tag", Flag="KW_PAS_TAG", Default=esp.passiveESP, Callback=function(v) esp.passiveESP=v end})
  P:Colorpicker({Name="Passive Color", Flag="KW_PAS_COL", Default=esp.passiveColor, Callback=function(c) esp.passiveColor=c end})
  P:Colorpicker({Name="Visible Color", Flag="KW_C_V", Default=esp.visColor, Callback=function(c) esp.visColor=c end})
  P:Colorpicker({Name="Occluded Color", Flag="KW_C_O", Default=esp.occColor, Callback=function(c) esp.occColor=c end})

  local D = ESPTab:Section({Name="Drones", Side="Left"})
  D:Toggle({Name="Enable Drone ESP", Flag="KW_DR_EN", Default=esp.droneEnabled, Callback=function(v) esp.droneEnabled=v end})
  D:Slider({Name="Max Distance", Flag="KW_DR_MD", Default=esp.droneMaxDist, Min=300, Max=8000, Callback=function(v) esp.droneMaxDist=v end})
  D:Toggle({Name="Tracer", Flag="KW_DR_TR", Default=esp.droneTracers, Callback=function(v) esp.droneTracers=v end})
  D:Toggle({Name="Filled Box", Flag="KW_DR_FILL", Default=esp.droneFilled, Callback=function(v) esp.droneFilled=v end})
  D:Slider({Name="Fill Alpha %", Flag="KW_DR_FA", Default=math.floor(esp.droneFillAlpha*100), Min=5, Max=80, Callback=function(v) esp.droneFillAlpha=clamp(v/100,0.05,0.8) end})
  D:Colorpicker({Name="Drone Color", Flag="KW_DR_COL", Default=esp.droneColor, Callback=function(c) esp.droneColor=c end})

  do
    local H = ESPTab:Section({Name="China China", Side="Right"})
    H:Toggle({
        Name = "Chinese Hat | Self",
        Flag = "KW_CH_HAT_LOCAL",
        Default = esp.chineseHatLocal,
        Callback = function(v)
            esp.chineseHatLocal = v
            updateHatESP()
        end
    })
    H:Toggle({
        Name = "Chinese Hat | Others",
        Flag = "KW_CH_HAT_OTHERS",
        Default = esp.chineseHatOthers,
        Callback = function(v)
            esp.chineseHatOthers = v
            updateHatESP()
        end
    })
    H:Colorpicker({
        Name = "Chinese Hat Color",
        Flag = "KW_CH_HAT_COLOR",
        Default = esp.chineseHatColor,
        Callback = function(c)
            esp.chineseHatColor = c
            updateHatESP()
        end
    })
end


end

----------------------------------------------------------------
-- Aimbot (stutter-fixed | min HP stop)
----------------------------------------------------------------
local aim = {
  enabled       = false,
  holdToUse     = false,
  holdButton    = Enum.UserInputType.MouseButton2,

  teamCheck     = false,
  wallCheck     = true,
  passiveIgnore = true,
  targetPart    = "Head",
  fov           = 150,
  smooth        = 0.18,
  maxDistance   = 1200,
  showHUD       = true,

  minHPToLock   = 1,

  prediction    = false,
  bulletSpeed   = 300,
  leadStrength  = 1.0,

  selectInterval= 0.08,
  losRefresh    = 0.20,
  lastSelect    = 0,
  lastLOSCheck  = 0,
  currentPart   = nil,

  conn          = nil,
  fovCircle     = nil,
  hudText       = nil,
}

local silentAim = {
    enabled = false,
    droneOnly = false,
    target = nil,
    teamCheck = false,
    wallCheck = true,
    passiveIgnore = true,
    targetPart = "Head",
    fov = 100,
    maxDistance = 1200,
    prediction = 0.1,
    bulletSpeed = 300,
    leadStrength = 1.0,
    selectInterval = 0.1,
    losRefresh = 0.20,
    lastSelect = 0,
    lastLOSCheck = 0,
    FinalTarget = nil
}

if hasDrawing then
  aim.fovCircle = Drawing.new("Circle")
  aim.fovCircle.Visible=false
  aim.fovCircle.Filled=false
  aim.fovCircle.Thickness=1.5
  aim.fovCircle.Transparency=0.9
  aim.fovCircle.Color=Color3.fromRGB(180,220,255)

  aim.hudText = Drawing.new("Text")
  aim.hudText.Visible=false
  aim.hudText.Center=true
  aim.hudText.Size=14
  aim.hudText.Outline=true
  aim.hudText.Color=Color3.fromRGB(230,230,255)
end

local holding=false
UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
  if i.UserInputType==aim.holdButton then holding=true end
  if i.KeyCode==aim.toggleKey then
    aim.enabled = not aim.enabled
    if aim.fovCircle then aim.fovCircle.Visible = aim.enabled end
    if not aim.enabled then aim.currentPart=nil end
  end
end)
UIS.InputEnded:Connect(function(i) if i.UserInputType==aim.holdButton then holding=false end end)

local function setAimHUD(txt)
  if aim.hudText then
    if aim.showHUD and txt then
      aim.hudText.Text = txt
      aim.hudText.Position = Vector2.new(Camera.ViewportSize.X/2, 72)
      aim.hudText.Visible = true
    else aim.hudText.Visible=false end
  end
end

local function updFOV()
  if not aim.fovCircle then return end
  local m=UIS:GetMouseLocation()
  aim.fovCircle.Position=Vector2.new(m.X,m.Y)
  if silentAim.enabled then
    aim.fovCircle.Radius=silentAim.fov
  else
    aim.fovCircle.Radius=aim.fov
  end
  aim.fovCircle.Visible = silentAim.enabled or aim.enabled
end

local function canSee(part, char)
    if not aim.wallCheck then return true end
    if not char then return false end
    local RaycastOrigin = Camera.CFrame.Position

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LP.Character, char}

    local result = Workspace:Raycast(RaycastOrigin, part.Position - RaycastOrigin, params)
    return not result or result.Instance:IsDescendantOf(char)
end

local function validHealth(hum)
  if not hum then return false end
  if hum.Health <= 0 then return false end
  if hum.Health <= aim.minHPToLock then return false end
  return true
end

local function findCandidate()
  local m=UIS:GetMouseLocation()
  local best, bd = nil, math.huge
  local camPos = Camera.CFrame.Position
  for _,plr in ipairs(Players:GetPlayers()) do
    if plr~=LP and not ignorelist[plr.Name] then
      if not (aim.teamCheck and sameTeam(plr)) then
        local ch=plr.Character
        if ch and not (aim.passiveIgnore and isPassive(ch)) then
          local hum = ch:FindFirstChildOfClass("Humanoid")
          if validHealth(hum) then
            local part = ch:FindFirstChild(aim.targetPart) or ch:FindFirstChild("HumanoidRootPart")
            if part then
              local dist = (part.Position - camPos).Magnitude
              if dist <= aim.maxDistance then
                local p, on = Camera:WorldToViewportPoint(part.Position)
                if on then
                  local d = (Vector2.new(p.X,p.Y) - Vector2.new(m.X,m.Y)).Magnitude
                  if d <= aim.fov and d < bd then
                    if canSee(part, ch) then
                      best, bd = part, d
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  return best
end

local function predictedPosition(part)
  if not aim.prediction then return part.Position end
  local vel = (part.AssemblyLinearVelocity or Vector3.zero)
  local dist = (part.Position - Camera.CFrame.Position).Magnitude
  local t = dist / math.max(20, aim.bulletSpeed)
  return part.Position + vel * t * aim.leadStrength
end

local function framerateSmooth(dt, s)
  local perFrame = clamp(s, 0.01, 1)
  local factor = 1 - math.pow(1 - perFrame, dt * 60)
  return clamp(factor, 0.01, 1)
end

local function aimAt(part, dt)
  local cf = Camera.CFrame
  local goal = CFrame.new(cf.Position, predictedPosition(part))
  local blend = framerateSmooth(dt, aim.smooth)
  Camera.CFrame = cf:Lerp(goal, blend)
end

local lastStep = tick()
local function stepAim()
  local now = tick()
  local dt = now - lastStep
  lastStep = now

  updFOV()
  if not aim.enabled or (aim.holdToUse and not holding) then setAimHUD(nil) aim.currentPart=nil return end

  if (now - aim.lastSelect) >= aim.selectInterval or not aim.currentPart then
    aim.currentPart = findCandidate()
    aim.lastSelect = now
    aim.lastLOSCheck = now
  else
    local part = aim.currentPart
    local ch = part and part.Parent
    local hum = ch and ch:FindFirstChildOfClass("Humanoid")
    if not part or not ch or not hum or not validHealth(hum) then
      aim.currentPart = nil
    else
      local camPos = Camera.CFrame.Position
      local dist = (part.Position - camPos).Magnitude
      if dist > aim.maxDistance then aim.currentPart=nil
      else
        local m=UIS:GetMouseLocation()
        local p,on = Camera:WorldToViewportPoint(part.Position)
        if not on or (Vector2.new(p.X,p.Y)-Vector2.new(m.X,m.Y)).Magnitude > aim.fov then
          aim.currentPart=nil
        elseif (now - aim.lastLOSCheck) >= aim.losRefresh then
          if not canSee(part, ch) then aim.currentPart=nil end
          aim.lastLOSCheck = now
        end
      end
    end
  end

  local t = aim.currentPart
  if t then
    aimAt(t, dt)
    local ch = t.Parent
    local pl = ch and Players:GetPlayerFromCharacter(ch)
    local who = pl and pl.Name or "Target"
    if ch and isPassive(ch) then who = who.." (P)" end
    local dist = (t.Position - Camera.CFrame.Position).Magnitude
    setAimHUD(string.format("%s  |  %.0fs", who, dist))
  else
    setAimHUD(nil)
  end
end

local function enableAim() if aim.conn then aim.conn:Disconnect() end aim.conn = RunService.RenderStepped:Connect(stepAim); if aim.fovCircle then aim.fovCircle.Visible=true end end
local function disableAim() if aim.conn then aim.conn:Disconnect() aim.conn=nil end if aim.fovCircle then aim.fovCircle.Visible=false end setAimHUD(nil) aim.currentPart=nil end

do
  local L = Combat:Section({Name="Aimbot | Core", Side="Left"})
  L:Toggle({Name="Enabled", Flag="KW_AIM_EN", Default=false, Callback=function(v) if v then enableAim() else disableAim() end end})
  L:Toggle({Name="Hold RMB", Flag="KW_AIM_HOLD", Default=false, Callback=function(v) aim.holdToUse=v end})
  L:Keybind({Name="Toggle Key", Flag="KW_AIM_KEY", Default=aim.toggleKey, Callback=function(k) if typeof(k)=="EnumItem" then aim.toggleKey=k end end})
  L:Slider({Name="FOV", Flag="KW_AIM_FOV", Default=aim.fov, Min=40, Max=600, Callback=function(v) aim.fov=v end})
  L:Slider({Name="Smooth", Flag="KW_AIM_SM", Default=math.floor(aim.smooth*100), Min=1, Max=100, Callback=function(v) aim.smooth=clamp(v/100,0.01,1) end})
  L:Slider({Name="Max Distance", Flag="KW_AIM_MD", Default=aim.maxDistance, Min=200, Max=6000, Callback=function(v) aim.maxDistance=v end})

  local F = Combat:Section({Name="Aimbot | Filters", Side="Right"})
  F:Toggle({Name="Team Check", Flag="KW_AIM_TC", Default=aim.teamCheck, Callback=function(v) aim.teamCheck=v end})
  F:Toggle({Name="Wall Check", Flag="KW_AIM_WC", Default=aim.wallCheck, Callback=function(v) aim.wallCheck=v end})
  F:Toggle({Name="Ignore Passive", Flag="KW_AIM_PI", Default=aim.passiveIgnore, Callback=function(v) aim.passiveIgnore=v end})
  F:Dropdown({Name="Target Part", Flag="KW_AIM_TP", Content={"Head","HumanoidRootPart"}, Default=aim.targetPart, Callback=function(v) aim.targetPart=v end})
  F:Slider({Name="Min HP to Lock", Flag="KW_AIM_MHP", Default=aim.minHPToLock, Min=0, Max=100, Callback=function(v) aim.minHPToLock=math.max(0, math.floor(v)) end})
  F:Slider({Name="Select Interval (ms)", Flag="KW_AIM_SI", Default=math.floor(aim.selectInterval*1000), Min=30, Max=200, Callback=function(v) aim.selectInterval=clamp(v/1000,0.03,0.2) end})

  local P = Combat:Section({Name="Aimbot | Prediction", Side="Left"})
  P:Toggle({Name="Velocity Prediction", Flag="KW_AIM_PR", Default=false, Callback=function(v) aim.prediction=v end})
  P:Slider({Name="Bullet Speed", Flag="KW_AIM_BS", Default=aim.bulletSpeed, Min=100, Max=1200, Callback=function(v) aim.bulletSpeed=math.floor(v) end})
  P:Slider({Name="Lead Strength", Flag="KW_AIM_LS", Default=math.floor(aim.leadStrength*10), Min=5, Max=20, Callback=function(v) aim.leadStrength=clamp(v/10,0.5,2.0) end})

  local T = Combat:Section({Name="Trigger bot", Side="Right"})

    -- Triggerbot state
 aim.trigger = {
    enabled = false,
    holdToUse = false,
    delay = 0.03,
    maxDistance = 3000,
    targetPart = "Head",
    teamCheck = false,
    wallCheck = false,
    passiveIgnore = false -- new
}

    T:Toggle({Name="Enabled", Flag="KW_TRIG_EN", Default=false, Callback=function(v) aim.trigger.enabled=v end})
    T:Toggle({Name="Hold RMB", Flag="KW_TRIG_HOLD", Default=false, Callback=function(v) aim.trigger.holdToUse=v end})
    T:Keybind({Name="Toggle Key", Flag="KW_TRIG_KEY", Default=aim.trigger.toggleKey, Callback=function(k) if typeof(k)=="EnumItem" then aim.trigger.toggleKey=k end end})
    T:Slider({Name="Fire Delay (ms)", Flag="KW_TRIG_DELAY", Default=math.floor(aim.trigger.delay*1000), Min=10, Max=200, Callback=function(v) aim.trigger.delay=clamp(v/1000,0.01,0.2) end})
    T:Slider({Name="Max Distance", Flag="KW_TRIG_MD", Default=aim.trigger.maxDistance, Min=200, Max=6000, Callback=function(v) aim.trigger.maxDistance=v end})
	T:Toggle({Name="Ignore Passive", Flag="KW_TRIG_PI", Default=aim.trigger.passiveIgnore, Callback=function(v) aim.trigger.passiveIgnore=v end})

    task.spawn(function()
    local lastShot = 0
    while task.wait() do
        if not aim.trigger.enabled then continue end
        if aim.trigger.holdToUse and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then continue end

        local now = tick()
        if now - lastShot < aim.trigger.delay then continue end

        local target = getCrosshairTarget(
            aim.trigger.maxDistance,
            aim.trigger.targetPart,
            aim.trigger.teamCheck,
            aim.trigger.wallCheck,
            aim.trigger.passiveIgnore
        )

        if target then
            lastShot = now
            mouse1press()
            task.wait(0.01)
            mouse1release()
        end
    end
end)

-- Crosshair target function (improved)
function getCrosshairTarget(maxDist, partName, teamCheck, wallCheck, passiveIgnore)
    local cam = workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local dir = cam.CFrame.LookVector * maxDist

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LP.Character, cam}

    -- Raycast to see if anything is in line (basic wall check)
    local result = workspace:Raycast(origin, dir, params)
    if not result then return nil end

    local hit = result.Instance
    local model = hit:FindFirstAncestorOfClass("Model")
    if not model then return nil end
    local hum = model:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return nil end

    -- Team Check
    if teamCheck then
        local plr = Players:GetPlayerFromCharacter(model)
        if plr and plr.Team == LP.Team then return nil end
    end

    -- Ignore Passive
    if passiveIgnore then
        if model:FindFirstChild("Passive") or model:GetAttribute("Passive") then
            return nil
        end
    end

    -- Improved Wall Check: trigger if your crosshair is directly over target
    local targetPart = model:FindFirstChild(partName)
    if not targetPart then return nil end

    if wallCheck then
        -- ray to part to check walls
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {LP.Character, cam}
        local ray = workspace:Raycast(origin, (targetPart.Position - origin).Unit * maxDist, rayParams)
        if ray and ray.Instance and not ray.Instance:IsDescendantOf(model) then
            return nil -- wall in the way
        end
    end

    return model
end
end


local mt = getrawmetatable(game)
local old_namecall = mt.__namecall
setreadonly(mt, false)
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if silentAim.enabled and not silentAim.droneOnly and method == "FireServer" and tostring(self) == "FireEvent" and silentAim.FinalTarget then
        args[1] = {{{
            silentAim.FinalTarget.Character[silentAim.targetPart],
            silentAim.FinalTarget.Character[silentAim.targetPart].Position,
            Vector3.new(0,0,0),
            Enum.Material.Plastic,
            LP.Character.HumanoidRootPart.Position,
            self.Parent.Flash
        }}}
        args[2] = true
    end
    return old_namecall(self, unpack(args))
end)
setreadonly(mt, true)

local mouse = LP:GetMouse()
local old_mouse_index
old_mouse_index = hookmetamethod(mouse, "__index", function(self, key)
    if silentAim.enabled and silentAim.droneOnly and (key == "Hit" or key == "Target" or key == "TargetFilter") and aim.currentPart then
        if key == "Hit" then
            return CFrame.new(aim.currentPart.Position)
        elseif key == "Target" then
            return aim.currentPart
        elseif key == "TargetFilter" then
            return aim.currentPart.Parent
        end
    end
    return old_mouse_index(self, key)
end)

----------------------------------------------------------------
----------------------------------------------------------------
local semigod = {
    enabled = false,
    heartbeatConn = nil,
}

-- goofy ahh

local function equipItem(itemName)
    local item = LP.Backpack:WaitForChild(itemName, 2)
    if not item then
        notify("KuromiWare", "Could not find " .. itemName, 3)
        return
    end

    item.Parent = LP.Character
    task.wait(0.2)

    local viewportSize = Camera.ViewportSize
    local centerX = viewportSize.X / 2
    local centerY = viewportSize.Y / 2

    VIM:SendMouseButtonEvent(centerX, centerY, 0, true, game, 1)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(centerX, centerY, 0, false, game, 1)
end

local function handleSemigod()
    if not semigod.enabled then return end

    local commandFunction = LP:WaitForChild("PlayerGui"):WaitForChild("ChatConsoleGui"):WaitForChild("CommandFunction")
    
    if not LP.Character:FindFirstChild("Medkit") and not LP.Backpack:FindFirstChild("Medkit") then
        local args = {"!spawn medkit"}
        commandFunction:InvokeServer(unpack(args))
    end
    if not LP.Character:FindFirstChild("Ballistics Helmet") and not LP.Backpack:FindFirstChild("Ballistics Helmet") then
        local args = {"!spawn ball"}
        commandFunction:InvokeServer(unpack(args))
    end
    if not LP.Character:FindFirstChild("Ballistics Vest") and not LP.Backpack:FindFirstChild("Ballistics Vest") then
        local args = {"!spawn ballisticsvest"}
        commandFunction:InvokeServer(unpack(args))
    end
    if not LP.Character:FindFirstChild("Wrench") and not LP.Backpack:FindFirstChild("Wrench") then
        local args = {"!spawn wrench"}
        commandFunction:InvokeServer(unpack(args))
    end

    task.wait(1) 

    if not LP.Character:FindFirstChild("Ballistics Helmet") then
        equipItem("Ballistics Helmet")
    end
    if not LP.Character:FindFirstChild("Ballistics Vest") then
        equipItem("Ballistics Vest")
    end

    if semigod.heartbeatConn then semigod.heartbeatConn:Disconnect() end
    semigod.heartbeatConn = RunService.Heartbeat:Connect(function()
        if not semigod.enabled then
            if semigod.heartbeatConn then semigod.heartbeatConn:Disconnect(); semigod.heartbeatConn = nil end
            return
        end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.Health < 100 then
            local medkit = LP.Backpack:FindFirstChild("Medkit")
            if medkit then
                local originalParent = medkit.Parent
                medkit.Parent = char
                task.wait()
                local actionMain = medkit:FindFirstChild("ActionMain")
                if actionMain and actionMain:IsA("RemoteEvent") then
                    actionMain:FireServer("heal", char)
                end
                task.wait()
                medkit.Parent = originalParent
            else
                local equippedMedkit = char:FindFirstChild("Medkit")
                if equippedMedkit then
                    local actionMain = equippedMedkit:FindFirstChild("ActionMain")
                    if actionMain and actionMain:IsA("RemoteEvent") then
                        actionMain:FireServer("heal", char)
                    end
                end
            end

            local wrench = LP.Backpack:FindFirstChild("Wrench")
            if wrench then
                local originalParent = wrench.Parent
                wrench.Parent = char
                task.wait()
                local actionMain = wrench:FindFirstChild("ActionMain")
                if actionMain and actionMain:IsA("RemoteEvent") then
                    actionMain:FireServer("heal", char)
                end
                task.wait()
                wrench.Parent = originalParent
            else
                local equippedWrench = char:FindFirstChild("Wrench")
                if equippedWrench then
                    local actionMain = equippedWrench:FindFirstChild("ActionMain")
                    if actionMain and actionMain:IsA("RemoteEvent") then
                        actionMain:FireServer("heal", char)
                    end
                end
            end
        end
    end)
end

local function enableSemigod()
    semigod.enabled = true
    task.spawn(handleSemigod)
end

local function disableSemigod()
    semigod.enabled = false
    if semigod.heartbeatConn then
        semigod.heartbeatConn:Disconnect()
        semigod.heartbeatConn = nil
    end
end

----------------------------------------------------------------
----------------------------------------------------------------
local ir = {
    enabled   = false,
    speed     = 10,
    interval  = 0.03,
    conn      = nil,
}

-- aggressive reload detection
local function isReloadTrack(track)
    local name = (track.Name or ""):lower()
    local anim = track.Animation

    if name:find("reload") or name:find("mag") or name:find("clip") then
        return true
    end

    if anim and anim.AnimationId then
        local id = tostring(anim.AnimationId):lower()
        if id:find("reload") or id:find("mag") or id:find("clip") then
            return true
        end
    end

    -- fallback: long non-looped animations
    if track.Length > 1.5 and not track.Looped then
        return true
    end

    return false
end

local function irStep()
    if not ir.enabled then return end

    local ch = LP.Character
    if not ch then return end

    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
        if isReloadTrack(track) then
            pcall(function()
                track:AdjustSpeed(math.clamp(ir.speed, 1, 25))
            end)
        end
    end
end

local function enableIR()
    if ir.conn then ir.conn:Disconnect() end
    ir.enabled = true
    ir.conn = RunService.Heartbeat:Connect(irStep)
end

local function disableIR()
    if ir.conn then ir.conn:Disconnect() ir.conn = nil end
    ir.enabled = false
end

do
    local L = Combat:Section({Name="Fast Reload", Side="Left"})

    L:Toggle({
        Name = "Enabled",
        Flag = "KW_IR_EN",
        Default = false,
        Callback = function(v)
            if v then enableIR() else disableIR() end
        end
    })

    L:Slider({
        Name = "Reload Speed",
        Flag = "KW_IR_SPD",
        Default = ir.speed,
        Min = 1,
        Max = 25,
        Callback = function(v)
            ir.speed = v
        end
    })
end


do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local LP = Players.LocalPlayer

	local cframeSpeed = {
    enabled = false,
    speed = 2,
    holdToUse = false
}

local voidPos = {
    enabled = false,
    holdToUse = false,
    height = 50 -- default void height
}


    local antiYaw = {
        enabled = false,
        mode = "Hard Lock",
        holdToUse = false,
        smoothStrength = 0.15,
        randomSpeed = 5,
        minYaw = -90,
        maxYaw = 90,
        lockCF = nil
    }

    RunService.RenderStepped:Connect(function()
        if not antiYaw.enabled then return end
        if antiYaw.holdToUse and not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end

        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local pos = hrp.Position
        if antiYaw.mode == "Hard Lock" then
            if not antiYaw.lockCF then antiYaw.lockCF = hrp.CFrame end
            local _, y, _ = antiYaw.lockCF:ToOrientation()
            hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, y, 0)
        elseif antiYaw.mode == "Smooth" then
            if not antiYaw.lockCF then antiYaw.lockCF = hrp.CFrame end
            local targetCF = antiYaw.lockCF
            hrp.CFrame = hrp.CFrame:Lerp(targetCF, antiYaw.smoothStrength)
        elseif antiYaw.mode == "Random" then
            local yawOffset = math.rad(math.random(antiYaw.minYaw*100, antiYaw.maxYaw*100)/100)
            local _, y, _ = hrp.CFrame:ToOrientation()
            hrp.CFrame = CFrame.new(pos) * CFrame.Angles(0, y + yawOffset * antiYaw.randomSpeed * RunService.RenderStepped:Wait(), 0)
        end

        antiYaw.lockCF = hrp.CFrame
    end)

	RunService.RenderStepped:Connect(function(dt)
    if not cframeSpeed.enabled then return end
    if cframeSpeed.holdToUse and not UIS:IsKeyDown(Enum.KeyCode.LeftShift) then return end

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hrp and hum and hum.MoveDirection.Magnitude > 0 then
        local move = hum.MoveDirection * cframeSpeed.speed * dt * 60
        hrp.CFrame = hrp.CFrame + move
    end
end)

RunService.RenderStepped:Connect(function()
    if not voidPos.enabled then return end
    if voidPos.holdToUse and not UIS:IsKeyDown(Enum.KeyCode.LeftShift) then return end

    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hrp and hum then
        -- Freeze position at camera X/Z, fixed Y (height)
        local camPos = workspace.CurrentCamera.CFrame.Position
        hrp.CFrame = CFrame.new(camPos.X, voidPos.height, camPos.Z)
        hum.PlatformStand = true -- disables physics on humanoid
    end
end)


    local S = MiscTab:Section({Name="Semigod", Side="Left"})
    S:Toggle({Name="Enabled", Flag="KW_SEMIGOD_EN", Default=false, Callback=function(v) if v then enableSemigod() else disableSemigod() end end})

    local SA = MiscTab:Section({Name="Drone Silent Aim", Side="Right"})
    SA:Toggle({Name="Enabled", Flag="KW_SA_DRONE", Default=false, Callback=function(v) silentAim.droneOnly=v end})

    local BL = MiscTab:Section({Name="Loadout", Side="Right"})
    BL:Button({Name="Equip Loadout", Callback=function()
        local commandFunction = LP:WaitForChild("PlayerGui"):WaitForChild("ChatConsoleGui"):WaitForChild("CommandFunction")
        commandFunction:InvokeServer("!sts ak+eo+ang+pbs sop+eo+ang+pbs mac+blue+acog+ext+sup r7+hunt+pbs+blue wrench medkit")
        local character = LP.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.Health = 0 end
        end
    end})

    local KA = MiscTab:Section({Name="Kill All", Side="Left"})
KA:Button({
    Name = "Execute",
    Callback = function()
        task.spawn(function()

            -- spawn gun
            local commandFunction = LP.PlayerGui.ChatConsoleGui.CommandFunction
            commandFunction:InvokeServer("!spawn l9")

            local char = LP.Character or LP.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid")

            local Gun = LP.Backpack:WaitForChild("L96A1", 5)
            if not Gun then
                warn("Gun not found")
                return
            end

            -- equip properly
            hum:EquipTool(Gun)
            task.wait(0.2)

            local FireEvent = Gun:FindFirstChild("FireEvent", true)
            if not FireEvent then
                warn("FireEvent missing")
                return
            end

            local Handle = Gun:FindFirstChild("Handle") or Gun:FindFirstChildWhichIsA("BasePart")
            if not Handle then
                warn("Gun handle missing")
                return
            end

            -- grab fire delay
            local waitTime = 0.05
            pcall(function()
                local settings = require(Gun.Settings)
                waitTime = settings.waittime or waitTime
            end)

            -- fire at every player
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hum2 = plr.Character:FindFirstChildOfClass("Humanoid")
                    local head = plr.Character:FindFirstChild("Head")

                    if hum2 and hum2.Health > 0 and head then
                        pcall(function()
                            FireEvent:FireServer(
                                {
                                    {
                                        {
                                            head,
                                            head.Position,
                                            Vector3.zero,
                                            Enum.Material.Plastic,
                                            Handle.Position,
                                            Gun.Flash
                                        }
                                    }
                                },
                                true,
                                nil,
                                Vector3.zero,
                                nil,
                                1,
                                waitTime,
                                3.6
                            )
                        end)

                        task.wait(waitTime)
                    end
                end
            end
        end)
    end
})


    local AY = MiscTab:Section({Name="Anti Yaw", Side="Left"})
    AY:Toggle({Name="Enabled", Flag="KW_ANTIYAW_EN", Default=false, Callback=function(v) antiYaw.enabled=v antiYaw.lockCF=nil end})
    AY:Dropdown({Name="Mode", Flag="KW_ANTIYAW_MODE", Content={"Hard Lock"}, Default=antiYaw.mode, Callback=function(v) antiYaw.mode=v end})
    AY:Slider({Name="Smooth Strength", Flag="KW_ANTIYAW_SS", Default=math.floor(antiYaw.smoothStrength*100), Min=5, Max=50, Callback=function(v) antiYaw.smoothStrength=clamp(v/100,0.05,0.5) end})
    AY:Slider({Name="Random Speed", Flag="KW_ANTIYAW_RS", Default=antiYaw.randomSpeed, Min=1, Max=20, Callback=function(v) antiYaw.randomSpeed=v end})
    AY:Slider({Name="Min Yaw Offset", Flag="KW_ANTIYAW_MIN", Default=antiYaw.minYaw, Min=-180, Max=0, Callback=function(v) antiYaw.minYaw=v end})
    AY:Slider({Name="Max Yaw Offset", Flag="KW_ANTIYAW_MAX", Default=antiYaw.maxYaw, Min=0, Max=180, Callback=function(v) antiYaw.maxYaw=v end})

	local CS = MiscTab:Section({Name="CFrame Speed", Side="Right"})

CS:Toggle({
    Name="Enabled",
    Flag="KW_CFS_EN",
    Default=false,
    Callback=function(v)
        cframeSpeed.enabled = v
    end
})

CS:Toggle({
    Name="Hold Shift",
    Flag="KW_CFS_HOLD",
    Default=false,
    Callback=function(v)
        cframeSpeed.holdToUse = v
    end
})

CS:Slider({
    Name="Speed",
    Flag="KW_CFS_SPD",
    Default=1,
    Min=0.5,
    Max=5,
    Callback=function(v)
        cframeSpeed.speed = v
    end
})

local V = MiscTab:Section({Name="Void Position (Beta)", Side="Left"})

V:Toggle({
    Name="Enabled",
    Flag="KW_VOID_EN",
    Default=false,
    Callback=function(v)
        voidPos.enabled = v

        if not v then
            local char = LP.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.PlatformStand = false
            end
        end
    end
})

V:Toggle({
    Name="Hold Shift",
    Flag="KW_VOID_HOLD",
    Default=false,
    Callback=function(v)
        voidPos.holdToUse = v
    end
})

V:Slider({
    Name="Height",
    Flag="KW_VOID_HGT",
    Default=voidPos.height,
    Min=10,
    Max=500,
    Callback=function(v)
        voidPos.height = v
    end
})

end

do
    local L = SilentTab:Section({Name="Silent Aim | Core", Side="Left"})
    L:Toggle({Name="Enabled", Flag="KW_SA_EN", Default=false, Callback=function(v) silentAim.enabled=v end})
    L:Toggle({Name="Hold RMB", Flag="KW_SA_HOLD", Default=false, Callback=function(v) silentAim.holdToUse=v end})
    L:Keybind({Name="Toggle Key", Flag="KW_SA_KEY", Callback=function(k) if typeof(k)=="EnumItem" then silentAim.toggleKey=k end end})
    L:Slider({Name="FOV", Flag="KW_SA_FOV", Default=silentAim.fov, Min=40, Max=600, Callback=function(v) silentAim.fov=v end})
    L:Slider({Name="Max Distance", Flag="KW_SA_MD", Default=silentAim.maxDistance, Min=200, Max=6000, Callback=function(v) silentAim.maxDistance=v end})

    local F = SilentTab:Section({Name="Silent Aim | Filters", Side="Right"})
    F:Toggle({Name="Team Check", Flag="KW_SA_TC", Default=silentAim.teamCheck, Callback=function(v) silentAim.teamCheck=v end})
    F:Toggle({Name="Wall Check", Flag="KW_SA_WC", Default=silentAim.wallCheck, Callback=function(v) silentAim.wallCheck=v end})
    F:Toggle({Name="Ignore Passive", Flag="KW_SA_PI", Default=silentAim.passiveIgnore, Callback=function(v) silentAim.passiveIgnore=v end})
    F:Dropdown({Name="Target Part", Flag="KW_SA_TP", Content={"Head","HumanoidRootPart"}, Default=silentAim.targetPart, Callback=function(v) silentAim.targetPart=v end})
    F:Slider({Name="Min HP to Lock", Flag="KW_SA_MHP", Default=1, Min=0, Max=100, Callback=function(v) silentAim.minHPToLock=math.max(0, math.floor(v)) end})
    F:Slider({Name="Select Interval (ms)", Flag="KW_SA_SI", Default=math.floor(silentAim.selectInterval*1000), Min=30, Max=200, Callback=function(v) silentAim.selectInterval=clamp(v/1000,0.03,0.2) end})

    local P = SilentTab:Section({Name="Silent Aim | Prediction", Side="Left"})
    P:Toggle({Name="Velocity Prediction", Flag="KW_SA_PR", Default=false, Callback=function(v) silentAim.prediction=v end})
    P:Slider({Name="Bullet Speed", Flag="KW_SA_BS", Default=silentAim.bulletSpeed, Min=100, Max=1200, Callback=function(v) silentAim.bulletSpeed=math.floor(v) end})
    P:Slider({Name="Lead Strength", Flag="KW_SA_LS", Default=math.floor(silentAim.leadStrength*10), Min=5, Max=20, Callback=function(v) silentAim.leadStrength=clamp(v/10,0.5,2.0) end})
end

local function silentCanSee(TargetCharacter)
	if not silentAim.wallCheck then return true end
	if not TargetCharacter then return false end

	local RaycastOrigin = Camera.CFrame.Position
	local partsToCheck = { "Head", "HumanoidRootPart", "Torso" }

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { LP.Character }

	for _, partName in ipairs(partsToCheck) do
		local part = TargetCharacter:FindFirstChild(partName)
		if part then
			local direction = part.Position - RaycastOrigin
			local result = Workspace:Raycast(RaycastOrigin, direction, params)

			if result then
				if result.Instance:IsDescendantOf(TargetCharacter) then
					return true
				end
			else
				return true
			end
		end
	end

	return false
end

RunService.RenderStepped:Connect(function()
	if not silentAim.enabled then
		silentAim.FinalTarget = nil
		return
	end

	local mousePos = UIS:GetMouseLocation()

	-- Validate existing target
	local isFinalTargetValid = false
	if silentAim.FinalTarget
	and silentAim.FinalTarget.Character
	and silentAim.FinalTarget.Character:FindFirstChild("HumanoidRootPart")
	and silentAim.FinalTarget.Character:FindFirstChild("Humanoid") then

		local char = silentAim.FinalTarget.Character
		local hrp = char.HumanoidRootPart
		local hum = char.Humanoid

		local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
		local distToMouse = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

		if onScreen
		and distToMouse <= silentAim.fov
		and hum.Health > 0
		and not char:FindFirstChild("ForceField")
		and (not silentAim.wallCheck or silentCanSee(char)) then
			isFinalTargetValid = true
		end
	end

	-- Pick new target ONLY if current is invalid
	if not isFinalTargetValid then
		silentAim.FinalTarget = nil

		if tick() - silentAim.lastSelect > silentAim.selectInterval then
			silentAim.lastSelect = tick()

			local bestTarget = nil
			local bestDist = math.huge

			for _, Player in ipairs(Players:GetPlayers()) do
				if Player ~= LP
				and Player.Character
				and Player.Character:FindFirstChild("HumanoidRootPart")
				and Player.Character:FindFirstChild("Humanoid")
				and Player.Character.Humanoid.Health > 0
				and not Player.Character:FindFirstChild("ForceField")
				and not ignorelist[Player.Name]
				and not (silentAim.teamCheck and sameTeam(Player)) then

					local hrp = Player.Character.HumanoidRootPart
					local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

					if onScreen then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude

						if dist <= silentAim.fov and dist < bestDist then
							if not silentAim.wallCheck or silentCanSee(Player.Character) then
								bestDist = dist
								bestTarget = Player
							end
						end
					end
				end
			end

			silentAim.FinalTarget = bestTarget
		end
	end
end)

----------------------------------------------------------------
----------------------------------------------------------------
local ir = {
  enabled   = true,
  speed     = 1.0,
  cooldown  = 300,   -- ms
  interval  = 0.06,  -- s
  conn      = nil,
  acc       = 0,
  touched   = {},
}
local function isReloadTrack(track)
  local n=(track.Name or ""):lower()
  if n:find("reload") or n:find("mag") or n:find("clip") then return true end
  local anim=track.Animation
  if anim and anim.AnimationId then
    local id=tostring(anim.AnimationId):lower()
    if id:find("reload") or id:find("mag") or id:find("clip") then return true end
  end
  return false
end
local function irStep(dt)
  ir.acc += dt
  if ir.acc < ir.interval then return end
  ir.acc = 0
  if not ir.enabled then return end
  local ch=LP.Character; if not ch then return end
  local hum=ch:FindFirstChildOfClass("Humanoid"); if not hum then return end
  local animator=hum:FindFirstChildOfClass("Animator"); if not animator then return end
  for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
    if isReloadTrack(track) then
      local now=os.clock()
      if ir.touched[track] and (now - ir.touched[track]) * 1000 < ir.cooldown then
      else
        ir.touched[track]=now
        pcall(function() track:AdjustSpeed(clamp(ir.speed,1,20)) end)
      end
    end
  end
end
local function enableIR() if ir.conn then ir.conn:Disconnect() end ir.enabled=true ir.acc=0 ir.conn=RunService.Heartbeat:Connect(irStep) end
local function disableIR() if ir.conn then ir.conn:Disconnect() ir.conn=nil end ir.enabled=false end



----------------------------------------------------------------
----------------------------------------------------------------
local fb = { enabled=false, brightness=3, clock=14, noShadows=true, noFog=true, conn=nil, saved={}, cc=nil }
local fov = { lock=false, value=80, conn=nil }
local function saveLight()
  fb.saved.Ambient=Lighting.Ambient; fb.saved.OutdoorAmbient=Lighting.OutdoorAmbient
  fb.saved.Brightness=Lighting.Brightness; fb.saved.ClockTime=Lighting.ClockTime
  fb.saved.GlobalShadows=Lighting.GlobalShadows; fb.saved.FogStart=Lighting.FogStart; fb.saved.FogEnd=Lighting.FogEnd
end
local function applyFB()
  Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1)
  Lighting.Brightness=fb.brightness; Lighting.ClockTime=fb.clock; Lighting.GlobalShadows=not fb.noShadows
  if fb.noFog then Lighting.FogStart=0 Lighting.FogEnd=1e6 end
  if not fb.cc then fb.cc=Instance.new("ColorCorrectionEffect") fb.cc.Name="KW_Fullbright" fb.cc.Brightness=0.05 fb.cc.Contrast=0.05 fb.cc.Saturation=0.05 fb.cc.Parent=Lighting end
end
local function enableFB() if fb.enabled then return end saveLight() applyFB() fb.conn=RunService.RenderStepped:Connect(applyFB) fb.enabled=true end
local function disableFB() if not fb.enabled then return end fb.enabled=false if fb.conn then fb.conn:Disconnect() fb.conn=nil end if fb.cc then fb.cc:Destroy() fb.cc=nil end for k,v in pairs(fb.saved) do Lighting[k]=v end end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local fov = {
    value = 120,
    enabled = false,
    connections = {}
}

-- Utility
local function disconnectAll()
    for _, c in ipairs(fov.connections) do
        c:Disconnect()
    end
    table.clear(fov.connections)
end

-- Apply FOV safely
local function applyFOV()
    if not Camera then return end
    if Camera.FieldOfView ~= fov.value then
        Camera.FieldOfView = fov.value
    end
end

-- Lock system
local function hookCamera(cam)
    Camera = cam
    applyFOV()

    -- Detect FOV changes
    table.insert(fov.connections, Camera:GetPropertyChangedSignal("FieldOfView"):Connect(function()
        if fov.enabled and Camera.FieldOfView ~= fov.value then
            Camera.FieldOfView = fov.value
        end
    end))
end

-- Camera replacement handler
table.insert(fov.connections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if fov.enabled then
        hookCamera(workspace.CurrentCamera)
    end
end))

-- Public API
function enableFOV(value)
    if value then fov.value = value end
    fov.enabled = true

    disconnectAll()
    hookCamera(workspace.CurrentCamera)
end

function disableFOV()
    fov.enabled = false
    disconnectAll()
end


do
    --// Services
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local LP = Players.LocalPlayer
    local Cam = workspace.CurrentCamera

    --// Fullbright
    local L = World:Section({Name="Fullbright", Side="Left"})
    L:Toggle({Name="Enabled (lock)", Flag="KW_FB_EN", Default=false, Callback=function(v) if v then enableFB() else disableFB() end end})
    L:Slider({Name="Brightness", Flag="KW_FB_BR", Default=fb.brightness, Min=1, Max=6, Callback=function(v) fb.brightness=v end})
    L:Slider({Name="ClockTime", Flag="KW_FB_CT", Default=fb.clock, Min=0, Max=24, Callback=function(v) fb.clock=v end})
    L:Toggle({Name="No Shadows", Flag="KW_FB_NS", Default=fb.noShadows, Callback=function(v) fb.noShadows=v end})
    L:Toggle({Name="No Fog", Flag="KW_FB_NF", Default=fb.noFog, Callback=function(v) fb.noFog=v end})

    L:Toggle({
        Name="Hide Leaves",
        Flag="KW_HIDE_LEAVES",
        Default=false,
        Callback=function(v)
            local mapDecos = workspace:FindFirstChild("MapDecorations")
            if mapDecos then
                for _, obj in pairs(mapDecos:GetDescendants()) do
                    if (obj:IsA("MeshPart") or obj:IsA("Part")) and (obj.Name=="Leaves" or obj.Name=="leaves") then
                        obj.Transparency = v and 1 or 0
                    end
                end
            end
        end
    })

    --// Camera Section
    local R = World:Section({Name="Camera", Side="Right"})

    R:Toggle({
        Name="FOV Lock",
        Flag="KW_FOV_L",
        Default=false,
        Callback=function(v)
            if v then enableFOV() else disableFOV() end
        end
    })

    R:Slider({
        Name="FOV",
        Flag="KW_FOV_V",
        Default=fov.value,
        Min=40,
        Max=120,
        Callback=function(v)
            fov.value = v
            if fov.enabled and Cam then
                Cam.FieldOfView = v
            end
        end
    })

    --// Third Person State
    local thirdPerson = {
        enabled = false,
        distance = 6,
        height = 2,
        smooth = 0.18,
        unlockMouse = false,
        lastMouseBehavior = UIS.MouseBehavior
    }

    --// Third Person Runtime
    RunService.RenderStepped:Connect(function()
    if not thirdPerson.enabled then return end

    local char = LP.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local camCF = Cam.CFrame
    local desired = CFrame.new(
        hrp.Position
        - camCF.LookVector * thirdPerson.distance
        + Vector3.new(0, thirdPerson.height, 0),
        hrp.Position + Vector3.new(0, thirdPerson.height, 0)
    )

    Cam.CFrame = Cam.CFrame:Lerp(desired, thirdPerson.smooth)

    --// Force Mouse Unlock
    if thirdPerson.unlockMouse then
        if UIS.MouseBehavior ~= Enum.MouseBehavior.Default then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        end
    end
end)


    --// Third Person UI
    R:Toggle({
        Name="Third Person",
        Flag="KW_TP_EN",
        Default=false,
        Callback=function(v)
            thirdPerson.enabled = v

            if not v then
                -- restore mouse behavior
                UIS.MouseBehavior = thirdPerson.lastMouseBehavior
            end
        end
    })

    R:Slider({
        Name="Distance",
        Flag="KW_TP_DIST",
        Default=thirdPerson.distance,
        Min=2,
        Max=15,
        Callback=function(v)
            thirdPerson.distance = v
        end
    })

    R:Slider({
        Name="Height",
        Flag="KW_TP_H",
        Default=thirdPerson.height,
        Min=0,
        Max=6,
        Callback=function(v)
            thirdPerson.height = v
        end
    })

    R:Slider({
        Name="Smooth",
        Flag="KW_TP_SM",
        Default=math.floor(thirdPerson.smooth * 100),
        Min=5,
        Max=50,
        Callback=function(v)
            thirdPerson.smooth = clamp(v / 100, 0.05, 0.5)
        end
    })

    --// Force Unlock Mouse
    R:Toggle({
    Name="Force Unlock Mouse",
    Flag="KW_TP_UNLOCK_MOUSE",
    Default=false,
    Callback=function(v)
        thirdPerson.unlockMouse = v
        if v then
            thirdPerson.lastMouseBehavior = UIS.MouseBehavior
            -- Immediately force
            UIS.MouseBehavior = Enum.MouseBehavior.Default
        else
            -- Restore previous
            UIS.MouseBehavior = thirdPerson.lastMouseBehavior
        end
    end
})
end


----------------------------------------------------------------
----------------------------------------------------------------
local placeName = "Place"
pcall(function()
  local info = MPS:GetProductInfo(game.PlaceId)
  if info and info.Name and #info.Name > 0 then placeName = info.Name end
end)

local hud = {
  showHeaderBar   = false,     
  showAccentLine  = false,     
  accentPulse     = true,
  accentSpeed     = 0.12,     
  headerAlpha     = 0.18,
  shadowAlpha     = 0.35,
  headerHeight    = 34,
  headerAutoWidth = true,
  headerWidth     = 480,
  headerFontSize  = 15,

  showFPS         = false,
  showPing        = false,
  showPlayers     = false,
  showTime        = false,
  showPlace       = false,
  showUsername    = false,

  showCrosshair   = false,
  crossGap        = 7,
  crossLen        = 9,
  crossThick      = 1.5,
}

local headerBar, headerShadow, headerText, accentLine
local statText = nil
if hasDrawing then
  headerBar    = Drawing.new("Square")
  headerShadow = Drawing.new("Square")
  headerText   = Drawing.new("Text")
  accentLine   = Drawing.new("Line")
  statText     = Drawing.new("Text")

  for _,sq in ipairs({headerBar, headerShadow}) do
    sq.Visible=false; sq.Filled=true; sq.Color=Theme.PanelMid; sq.Thickness=1
  end
  headerShadow.Color = Theme.PanelDark

  headerText.Visible=true; headerText.Center=true; headerText.Size=hud.headerFontSize; headerText.Outline=true; headerText.Color=Theme.Secondary
  statText.Visible=true; statText.Center=true; statText.Size=hud.headerFontSize-1; statText.Outline=true; statText.Color=Color3.fromRGB(200,200,210)

  accentLine.Visible=true; accentLine.Thickness=2
end

local crossLines = {}
if hasDrawing then
  for i=1,4 do local l=Drawing.new("Line"); l.Color=Theme.Secondary; l.Thickness=hud.crossThick; l.Visible=false; crossLines[i]=l end
end

local pingItem = Stats and Stats.Network and Stats.Network.ServerStatsItem and Stats.Network.ServerStatsItem["Data Ping"] or nil
local fpsCounter,lastFPS,fpsAccum = 0,60,0

local function buildHeaderStrings()
  local left = ""
  local rightParts = {}

  if hud.showFPS then table.insert(rightParts, ("FPS %d"):format(lastFPS)) end
  if hud.showPing and pingItem then table.insert(rightParts, ("Ping %dms"):format(math.max(0, math.floor(pingItem:GetValue() or 0)))) end
  if hud.showPlayers then table.insert(rightParts, ("Players %d"):format(#Players:GetPlayers())) end
  if hud.showTime then table.insert(rightParts, os.date("%H:%M:%S")) end
  if hud.showPlace then table.insert(rightParts, placeName) end
  if hud.showUsername then table.insert(rightParts, ("@%s"):format(LP.Name)) end

  local right = table.concat(rightParts, " | ")
  return left, right
end

RunService.RenderStepped:Connect(function(dt)
  if not hasDrawing then return end

  if silentAim.enabled or aim.enabled then
    updFOV()
  end

  fpsAccum += dt; fpsCounter += 1
  if fpsAccum >= 0.25 then lastFPS = math.floor(fpsCounter / fpsAccum + 0.5); fpsAccum, fpsCounter = 0, 0 end

  local left, right = buildHeaderStrings()
  local combined = (right ~= "" and (left.." | "..right)) or left

  local vw = Camera.ViewportSize.X
  local vh = Camera.ViewportSize.Y
  local textSize = hud.headerFontSize
  headerText.Size = textSize
  statText.Size   = textSize - 1

  local approxWidth = math.clamp(#combined * textSize * 0.56 + 40, 260, math.min(vw - 24, 720))
  local w = hud.headerAutoWidth and approxWidth or hud.headerWidth
  local h = hud.headerHeight
  local x = math.floor((vw - w) / 2)
  local y = 8

  if hud.showHeaderBar then
    headerShadow.Position     = Vector2.new(x, y+2)
    headerShadow.Size         = Vector2.new(w, h)
    headerShadow.Transparency = hud.shadowAlpha
    headerShadow.Visible      = true

    headerBar.Position        = Vector2.new(x, y)
    headerBar.Size            = Vector2.new(w, h)
    headerBar.Transparency    = hud.headerAlpha
    headerBar.Visible         = true
  else
    headerShadow.Visible = false
    headerBar.Visible    = false
  end

  local accent = Theme.Accent
  if hud.accentPulse then
    local hue = (os.clock() * hud.accentSpeed) % 1
    accent = Color3.fromHSV(hue, 0.5, 1)
  end
  if hud.showAccentLine then
    accentLine.From         = Vector2.new(x+8, y+h-2)
    accentLine.To           = Vector2.new(x+w-8, y+h-2)
    accentLine.Color        = accent
    accentLine.Transparency = 0.9
    accentLine.Visible      = true
  else
    accentLine.Visible = false
  end

  headerText.Text      = combined
  headerText.Color     = Theme.Secondary
  headerText.Position  = Vector2.new(vw/2, y + h/2 + 1)
  headerText.Visible   = true

  statText.Text        = " "
  statText.Color       = accent
  statText.Position    = Vector2.new(vw/2, y + h + 14)
  statText.Visible     = true

  local m=UIS:GetMouseLocation()
  local cgap,clen=hud.crossGap,hud.crossLen
  local pts={{Vector2.new(m.X - cgap - clen, m.Y), Vector2.new(m.X - cgap, m.Y)},
             {Vector2.new(m.X + cgap, m.Y),       Vector2.new(m.X + cgap + clen, m.Y)},
             {Vector2.new(m.X, m.Y - cgap - clen), Vector2.new(m.X, m.Y - cgap)},
             {Vector2.new(m.X, m.Y + cgap),        Vector2.new(m.X, m.Y + cgap + clen)}}
  for i=1,4 do
    local L=crossLines[i]
    if hud.showCrosshair then
      L.Thickness = hud.crossThick
      L.From=pts[i][1]; L.To=pts[i][2]; L.Visible=true
    else L.Visible=false end
  end
end)

do
  local H = HUDTab:Section({Name="Header | Centered Banner", Side="Left"})
  H:Toggle({Name="Show Header Bar", Flag="KW_HD_BAR", Default=hud.showHeaderBar, Callback=function(v) hud.showHeaderBar=v end})
  H:Toggle({Name="Accent Pulse", Flag="KW_HD_AP", Default=hud.accentPulse, Callback=function(v) hud.accentPulse=v end})
  H:Toggle({Name="Accent Line", Flag="KW_HD_AL", Default=hud.showAccentLine, Callback=function(v) hud.showAccentLine=v end})
  H:Slider({Name="Header Height", Flag="KW_HD_H", Default=hud.headerHeight, Min=24, Max=50, Callback=function(v) hud.headerHeight=math.floor(v) end})
  H:Slider({Name="Header Alpha %", Flag="KW_HD_A", Default=math.floor(hud.headerAlpha*100), Min=0, Max=80, Callback=function(v) hud.headerAlpha=clamp(v/100,0,0.8) end})
  H:Slider({Name="Shadow Alpha %", Flag="KW_HD_SA", Default=math.floor(hud.shadowAlpha*100), Min=0, Max=80, Callback=function(v) hud.shadowAlpha=clamp(v/100,0,0.8) end})
  H:Toggle({Name="Auto Width", Flag="KW_HD_AW", Default=hud.headerAutoWidth, Callback=function(v) hud.headerAutoWidth=v end})
  H:Slider({Name="Manual Width", Flag="KW_HD_MW", Default=hud.headerWidth, Min=260, Max=720, Callback=function(v) hud.headerWidth=math.floor(v) end})
  H:Slider({Name="Font Size", Flag="KW_HD_FS", Default=hud.headerFontSize, Min=12, Max=20, Callback=function(v) hud.headerFontSize=math.floor(v) end})

  local D = HUDTab:Section({Name="Header | Data Chips", Side="Right"})
  D:Toggle({Name="Show FPS", Flag="KW_HD_FPS", Default=hud.showFPS, Callback=function(v) hud.showFPS=v end})
  D:Toggle({Name="Show Ping", Flag="KW_HD_PING", Default=hud.showPing, Callback=function(v) hud.showPing=v end})
  D:Toggle({Name="Show Players", Flag="KW_HD_PLR", Default=hud.showPlayers, Callback=function(v) hud.showPlayers=v end})
  D:Toggle({Name="Show Time", Flag="KW_HD_TIME", Default=hud.showTime, Callback=function(v) hud.showTime=v end})
  D:Toggle({Name="Show Place Name", Flag="KW_HD_PLACE", Default=hud.showPlace, Callback=function(v) hud.showPlace=v end})
  D:Toggle({Name="Show Username", Flag="KW_HD_USER", Default=hud.showUsername, Callback=function(v) hud.showUsername=v end})

  local C = HUDTab:Section({Name="Crosshair", Side="Left"})
  C:Toggle({Name="Enabled", Flag="KW_CH_EN", Default=hud.showCrosshair, Callback=function(v) hud.showCrosshair=v end})
  C:Slider({Name="Gap (px)", Flag="KW_CH_GAP", Default=hud.crossGap, Min=3, Max=24, Callback=function(v) hud.crossGap=math.floor(v) end})
  C:Slider({Name="Length (px)", Flag="KW_CH_LEN", Default=hud.crossLen, Min=4, Max=24, Callback=function(v) hud.crossLen=math.floor(v) end})
  C:Slider({Name="Thickness", Flag="KW_CH_TH", Default=math.floor(hud.crossThick*10), Min=10, Max=40, Callback=function(v) hud.crossThick=clamp(v/10,0.5,4) end})
end

do
  local R = Config:Section({Name="Friends | Ignores", Side="Left"})
  local userBox = R:Box({Name="Player Name", Flag="KW_USER_BOX", Placeholder="Exact name"})
  R:Button({Name="Add to Friends (Whitelist)", Callback=function() local n=GUI.flags["KW_USER_BOX"]; if n and n~="" then whitelist[n]=true end userBox:Set("") end})
  R:Button({Name="Remove Friend", Callback=function() local n=GUI.flags["KW_USER_BOX"]; if n then whitelist[n]=nil end userBox:Set("") end})
  R:Button({Name="Add to Ignore", Callback=function() local n=GUI.flags["KW_USER_BOX"]; if n and n~="" then ignorelist[n]=true end userBox:Set("") end})
  R:Button({Name="Remove Ignore", Callback=function() local n=GUI.flags["KW_USER_BOX"]; if n then ignorelist[n]=nil end userBox:Set("") end})
end

local S = About:Section({Name="KuromiWare", Side="Left"})
S:Keybind({Name="Toggle UI", Flag="KW_UI_TOG", Default=Enum.KeyCode.RightShift, Callback=function(_, newKey) if not newKey then GUI:Close() end end})
S:Button({Name="Unload", Callback=function()
  disableESP(); if descAddConn then descAddConn:Disconnect() end; if descRemConn then descRemConn:Disconnect() end
  disableAim(); disableIR(); disableFB(); disableFOV(); disableSemigod()
  GUI:Unload(); getgenv().KittenWareLoaded=nil
end})

UIS.InputBegan:Connect(function(i,gpe)
  if gpe then return end
end)

enableIR()


getgenv().KittenWareLoaded = true
getgenv().KittenWareLoading = nil
GUI:Close()
