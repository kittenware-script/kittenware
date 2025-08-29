--[[
  KittenWare • 2025
  No Recoil + ESP (Skeleton/Boxes/Tracers/Names/Health/Distance/Fill/Item ESP)
  + Aimbot (Wall Check + Distance + HUD)
  + Fullbright/FOV
  + Gun Chams
  + Silent Aim (assist; with its own FOV circle & toggles; no __namecall hooks)
  + Reload Speed (animation speed multiplier for reload tracks)

  Change Log (this build):
  • Silent Aim now has its own FOV circle (toggle + color) so you can SEE it’s active.
  • Fixed Silent Aim hookup to fire on LMB reliably and show current config in the menu.
  • Replaced “Insta Reload (gentle skip)” with a clean Reload Speed multiplier that
    only calls :AdjustSpeed(multiplier) on reload animations (no time-position jumps).
]]

if getgenv().KittenWareLoaded or getgenv().KittenWareLoading then return end
getgenv().KittenWareLoading = true

----------------------------------------------------------------
-- Services & Helpers
----------------------------------------------------------------
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Lighting   = game:GetService("Lighting")
local Workspace  = game:GetService("Workspace")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local function notify(t,x,d) pcall(function() StarterGui:SetCore("SendNotification",{Title=t,Text=x,Duration=d or 3}) end) end
local function clamp(v,a,b) return (v<a) and a or ((v>b) and b or v) end

-- UI lib (Exunys)
loadstring(game:HttpGet("https://raw.githubusercontent.com/Exunys/Roblox-Functions-Library/main/Library.lua"))()
local GUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/kitty92pm/AirHub-V2/refs/heads/main/src/UI%20Library.lua"))()

-- Tabs
local Main     = GUI:Load()
local Combat   = Main:Tab("Combat")
local Visual   = Main:Tab("Visual")
local Utility  = Main:Tab("Utility")
local Settings = Main:Tab("Settings")

----------------------------------------------------------------
-- No Recoil
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
Combat:Section({Name="No Recoil"}):Toggle({Name="Enabled",Flag="KW_NR",Default=false,Callback=function(v) if v then enableNR() else disableNR() end end})

----------------------------------------------------------------
-- ESP (Drawing API)  — with Item ESP
----------------------------------------------------------------
local hasDrawing=(typeof(Drawing)=="table" and typeof(Drawing.new)=="function")
if not hasDrawing then notify("KittenWare","Drawing API not found; ESP disabled.",5) end

-- Config
local espEnabled, espConn=false,nil
local showSkeleton, showBoxes, showTracers=true,true,true
local showNames, showHealth, showDistance = true, true, true
local showFilledBox = false
local onlyVisible = false
local onlyOnScreen = true
local maxDistance = 2000
local espTeamCheck=false
local useTeamColors=false
local visibleColor=Color3.fromRGB(0,255,255)
local colors={ Red=Color3.fromRGB(255,0,0), Green=Color3.fromRGB(0,255,0), Yellow=Color3.fromRGB(255,255,0), Magenta=Color3.fromRGB(255,0,255) }
local occludedColor=colors.Red
local thickness, alpha=2.5,0.85
local fillAlpha = 0.15
local tracerOrigin="Bottom" -- Bottom/Center/Mouse

-- Item ESP config
local showItem = true
local itemColor = Color3.fromRGB(255, 200, 120)
local itemOffsetY = 14

local playerDraw, espSignals = {}, {}
local playersSignal, playerAddedConn

local function sameTeam(plr)
    if not espTeamCheck then return false end
    if LP.Team and plr.Team then return plr.Team==LP.Team end
    if LP.TeamColor and plr.TeamColor then return plr.TeamColor==LP.TeamColor end
    return false
end
local function isVisibleLOS(part, targetChar)
    if not part then return false end
    local origin=Camera.CFrame.Position
    local dir=(part.Position-origin)
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances={LP.Character, targetChar}
    local hit = Workspace:Raycast(origin, dir, rp)
    return hit == nil
end

local function makeLine() local l=Drawing.new("Line"); l.Visible=false; l.Thickness=thickness; l.Transparency=alpha; return l end
local function makeText() local t=Drawing.new("Text"); t.Visible=false; t.Center=true; t.Size=14; t.Outline=true; t.Transparency=1; t.Color=Color3.new(1,1,1); return t end
local function makeSquare() local s=Drawing.new("Square"); s.Visible=false; s.Filled=false; s.Thickness=thickness; s.Transparency=alpha; s.Color=Color3.new(1,1,1); return s end

local function ensureBundle(plr)
    if playerDraw[plr] then return playerDraw[plr] end
    local b={
        -- Skeleton
        torso=makeLine(), lower=makeLine(), head=makeLine(),
        luArm=makeLine(), llArm=makeLine(), lHand=makeLine(),
        ruArm=makeLine(), rlArm=makeLine(), rHand=makeLine(),
        luLeg=makeLine(), llLeg=makeLine(), ruLeg=makeLine(), rlLeg=makeLine(),
        -- Box (outline)
        boxT=makeLine(), boxB=makeLine(), boxL=makeLine(), boxR=makeLine(),
        -- Filled overlay
        boxFill=makeSquare(),
        -- Tracer
        tracer=makeLine(),
        -- Labels + Health
        nameText=makeText(),
        distText=makeText(),
        hpBack=makeSquare(),
        hpBar=makeSquare(),
        -- Item ESP
        itemText=makeText(),
    }
    playerDraw[plr]=b; return b
end
local function hideBundle(b) if not b then return end for _,ln in pairs(b) do ln.Visible=false end end
local function cleanup(plr) local t=playerDraw[plr] if t then for _,ln in pairs(t) do ln:Remove() end end playerDraw[plr]=nil local sigs=espSignals[plr] if sigs then for _,c in ipairs(sigs) do if c then c:Disconnect() end end end espSignals[plr]=nil end

local function getParts(c)
    return {
        hum=c:FindFirstChildOfClass("Humanoid"),
        hrp=c:FindFirstChild("HumanoidRootPart"),
        head=c:FindFirstChild("Head"),
        torso=c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso"),
        lower=c:FindFirstChild("LowerTorso"),
        luArm=c:FindFirstChild("LeftUpperArm") or c:FindFirstChild("Left Arm"),
        llArm=c:FindFirstChild("LeftLowerArm"),
        lHand=c:FindFirstChild("LeftHand"),
        ruArm=c:FindFirstChild("RightUpperArm") or c:FindFirstChild("Right Arm"),
        rlArm=c:FindFirstChild("RightLowerArm"),
        rHand=c:FindFirstChild("RightHand"),
        luLeg=c:FindFirstChild("LeftUpperLeg") or c:FindFirstChild("Left Leg"),
        llLeg=c:FindFirstChild("LeftLowerLeg"),
        ruLeg=c:FindFirstChild("RightUpperLeg") or c:FindFirstChild("Right Leg"),
        rlLeg=c:FindFirstChild("RightLowerLeg")
    }
end
local function vp(v3) local v,o=Camera:WorldToViewportPoint(v3); return Vector2.new(v.X,v.Y),o end
local function drawLine(line,a,b,col)
    if a and b then
        local a2,ao=vp(a.Position); local b2,bo=vp(b.Position)
        if ao and bo then
            line.From=a2; line.To=b2; line.Color=col; line.Visible=true
            line.Thickness=thickness; line.Transparency=alpha
        else line.Visible=false end
    else line.Visible=false end
end

local function computeBBox(model)
    local cf,size = model:GetBoundingBox()
    local hx,hy,hz = size.X/2,size.Y/2,size.Z/2
    local C={Vector3.new( hx, hy, hz),Vector3.new(-hx, hy, hz),Vector3.new( hx, hy,-hz),Vector3.new(-hx, hy,-hz),
             Vector3.new( hx,-hy, hz),Vector3.new(-hx,-hy, hz),Vector3.new( hx,-hy,-hz),Vector3.new(-hx,-hy,-hz)}
    local minX,minY,maxX,maxY=math.huge,math.huge,-math.huge,-math.huge
    local any=false
    for _,corner in ipairs(C) do
        local world=cf:PointToWorldSpace(corner)
        local v,on=Camera:WorldToViewportPoint(world)
        if on then any=true end
        minX=math.min(minX,v.X); minY=math.min(minY,v.Y)
        maxX=math.max(maxX,v.X); maxY=math.max(maxY,v.Y)
    end
    return minX,minY,maxX,maxY,any
end

local function drawLineBox(lines, tl, tr, bl, br, col)
    lines.boxT.From=tl; lines.boxT.To=tr; lines.boxT.Color=col; lines.boxT.Visible=true
    lines.boxB.From=bl; lines.boxB.To=br; lines.boxB.Color=col; lines.boxB.Visible=true
    lines.boxL.From=tl; lines.boxL.To=bl; lines.boxL.Color=col; lines.boxL.Visible=true
    lines.boxR.From=tr; lines.boxR.To=br; lines.boxR.Color=col; lines.boxR.Visible=true
    lines.boxT.Thickness=thickness; lines.boxB.Thickness=thickness; lines.boxL.Thickness=thickness; lines.boxR.Thickness=thickness
    lines.boxT.Transparency=alpha; lines.boxB.Transparency=alpha; lines.boxL.Transparency=alpha; lines.boxR.Transparency=alpha
end

local function tracerAnchor()
    if tracerOrigin=="Center" then return Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    elseif tracerOrigin=="Mouse" then local m=UIS:GetMouseLocation(); return Vector2.new(m.X,m.Y)
    else return Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y) end
end

local function getEquippedToolName(ch)
    if not ch then return nil end
    for _,obj in ipairs(ch:GetChildren()) do
        if obj:IsA("Tool") then
            return obj.Name
        end
    end
    return nil
end

local function updateOne(plr)
    if not hasDrawing then return end
    if plr==LP or (espTeamCheck and sameTeam(plr)) then local b=playerDraw[plr]; if b then hideBundle(b) end return end

    local ch=plr.Character; if not ch then local b=playerDraw[plr]; if b then hideBundle(b) end return end
    local P=getParts(ch)
    local hum=P.hum
    if hum and hum.Health<=0 then local b=playerDraw[plr]; if b then hideBundle(b) end return end
    if not P.hrp then local b=playerDraw[plr]; if b then hideBundle(b) end return end

    local camPos = Camera.CFrame.Position
    local dist = (P.hrp.Position - camPos).Magnitude
    if dist > maxDistance then local b=playerDraw[plr]; if b then hideBundle(b) end return end

    local vis = isVisibleLOS(P.hrp, ch) or (P.torso and isVisibleLOS(P.torso, ch))
    if onlyVisible and not vis then local b=playerDraw[plr]; if b then hideBundle(b) end return end
    local col = vis and visibleColor or occludedColor
    if useTeamColors and plr.TeamColor then col = plr.TeamColor.Color end

    local b=ensureBundle(plr)

    -- skeleton
    if showSkeleton then
        if P.torso then drawLine(b.torso,P.torso,P.hrp,col) drawLine(b.head,P.head,P.torso,col) drawLine(b.lower,P.lower or P.torso,P.torso,col)
        else b.torso.Visible=false b.head.Visible=false b.lower.Visible=false end
        drawLine(b.luArm,P.luArm,P.torso or P.hrp,col); if P.llArm then drawLine(b.llArm,P.llArm,P.luArm,col) else b.llArm.Visible=false end
        if P.lHand then drawLine(b.lHand,P.lHand,P.llArm or P.luArm,col) else b.lHand.Visible=false end
        drawLine(b.ruArm,P.ruArm,P.torso or P.hrp,col); if P.rlArm then drawLine(b.rlArm,P.rlArm,P.ruArm,col) else b.rlArm.Visible=false end
        if P.rHand then drawLine(b.rHand,P.rHand,P.rlArm or P.ruArm,col) else b.rHand.Visible=false end
        local pelvis=P.lower or P.torso or P.hrp
        drawLine(b.luLeg,P.luLeg,pelvis,col); if P.llLeg then drawLine(b.llLeg,P.llLeg,P.luLeg,col) else b.llLeg.Visible=false end
        drawLine(b.ruLeg,P.ruLeg,pelvis,col); if P.rlLeg then drawLine(b.rlLeg,P.rlLeg,P.ruLeg,col) else b.rlLeg.Visible=false end
    else
        b.torso.Visible=false b.head.Visible=false b.lower.Visible=false
        b.luArm.Visible=false b.llArm.Visible=false b.lHand.Visible=false
        b.ruArm.Visible=false b.rlArm.Visible=false b.rHand.Visible=false
        b.luLeg.Visible=false b.llLeg.Visible=false b.ruLeg.Visible=false b.rlLeg.Visible=false
    end

    -- 2D box & fill
    local minX,minY,maxX,maxY,onScr = computeBBox(ch)
    if onlyOnScreen and not onScr then hideBundle(b); return end
    local tl,tr,bl,br=Vector2.new(minX,minY),Vector2.new(maxX,minY),Vector2.new(minX,maxY),Vector2.new(maxX,maxY)

    if showBoxes then
        drawLineBox(b, tl,tr,bl,br, col)
        if showFilledBox then
            b.boxFill.Filled = true
            b.boxFill.Color = col
            b.boxFill.Transparency = clamp(fillAlpha, 0, 1)
            b.boxFill.Position = tl
            b.boxFill.Size = Vector2.new(maxX-minX, maxY-minY)
            b.boxFill.Visible = true
        else
            b.boxFill.Visible=false
        end
    else
        b.boxT.Visible=false b.boxB.Visible=false b.boxL.Visible=false b.boxR.Visible=false
        b.boxFill.Visible=false
    end

    -- health bar
    if showHealth and hum then
        local hp = math.max(0, math.min(100, (hum.Health / math.max(1, hum.MaxHealth)) * 100))
        local bw = 4
        local height = (maxY - minY)
        local filled = height * (hp/100)
        b.hpBack.Filled = true
        b.hpBack.Color = Color3.fromRGB(30,30,30)
        b.hpBack.Transparency = 0.6
        b.hpBack.Position = Vector2.new(minX - (bw+3), minY)
        b.hpBack.Size = Vector2.new(bw, height)
        b.hpBack.Visible = true

        b.hpBar.Filled = true
        b.hpBar.Color = Color3.fromRGB(120,255,120)
        b.hpBar.Transparency = 0.2
        b.hpBar.Position = Vector2.new(minX - (bw+3), maxY - filled)
        b.hpBar.Size = Vector2.new(bw, filled)
        b.hpBar.Visible = true
    else
        b.hpBack.Visible=false
        b.hpBar.Visible=false
    end

    -- name & distance
    local nameY = math.max(0, minY - 14)
    if showNames then
        b.nameText.Text = plr.Name .. (showHealth and hum and ("  ["..math.floor((hum.Health)).."]") or "")
        b.nameText.Color = col
        b.nameText.Position = Vector2.new((minX+maxX)/2, nameY)
        b.nameText.Size = 14
        b.nameText.Visible = true
    else b.nameText.Visible=false end

    if showDistance then
        b.distText.Text = string.format("%.0f", dist).."s"
        b.distText.Color = Color3.fromRGB(220,220,220)
        b.distText.Position = Vector2.new((minX+maxX)/2, maxY + 12)
        b.distText.Size = 13
        b.distText.Visible = true
    else b.distText.Visible=false end

    -- Item ESP (equipped tool)
    if showItem then
        local toolName = getEquippedToolName(ch)
        if toolName then
            b.itemText.Text = toolName
            b.itemText.Color = itemColor
            b.itemText.Position = Vector2.new((minX+maxX)/2, nameY + itemOffsetY)
            b.itemText.Size = 13
            b.itemText.Visible = true
        else
            b.itemText.Visible = false
        end
    else
        b.itemText.Visible = false
    end

    -- tracer
    if showTracers then
        local pos,on=Camera:WorldToViewportPoint(P.hrp.Position)
        if on then
            b.tracer.From=tracerAnchor()
            b.tracer.To=Vector2.new(pos.X,pos.Y)
            b.tracer.Color=col
            b.tracer.Thickness=thickness
            b.tracer.Transparency=alpha
            b.tracer.Visible=true
        else b.tracer.Visible=false end
    else b.tracer.Visible=false end
end

local function updateAll() for _,p in ipairs(Players:GetPlayers()) do updateOne(p) end end
local function hookPerPlayerSignals(plr)
    espSignals[plr]=espSignals[plr] or {}
    table.insert(espSignals[plr], plr.CharacterRemoving:Connect(function() local b=playerDraw[plr] if b then hideBundle(b) end end))
end
local function enableESP()
    if not hasDrawing then notify("KittenWare","ESP needs Drawing API",4) return end
    if espConn then espConn:Disconnect() end
    espEnabled = true
    espConn=RunService.RenderStepped:Connect(updateAll)
    if not playersSignal then playersSignal=Players.PlayerRemoving:Connect(function(plr) cleanup(plr) end) end
    if not playerAddedConn then playerAddedConn=Players.PlayerAdded:Connect(function(plr) hookPerPlayerSignals(plr) end) end
    for _,plr in ipairs(Players:GetPlayers()) do hookPerPlayerSignals(plr) end
end
local function disableESP()
    espEnabled=false
    if espConn then espConn:Disconnect() espConn=nil end
    if playersSignal then playersSignal:Disconnect() playersSignal=nil end
    if playerAddedConn then playerAddedConn:Disconnect() playerAddedConn=nil end
    for plr in pairs(playerDraw) do cleanup(plr) end
end

-- ESP UI
do
    local sec=Visual:Section({Name="ESP Core", Side="Left"})
    sec:Toggle({Name="Enabled",Flag="KW_ESP",Default=false,Callback=function(v) if v then enableESP() else disableESP() end end})
    sec:Toggle({Name="Team Check (skip teammates)",Flag="KW_ESP_TEAM",Default=false,Callback=function(v) espTeamCheck=v end})
    sec:Toggle({Name="Use Team Colors",Flag="KW_ESP_TCOL",Default=false,Callback=function(v) useTeamColors=v end})
    sec:Toggle({Name="Only Visible",Flag="KW_ESP_VIS",Default=false,Callback=function(v) onlyVisible=v end})
    sec:Toggle({Name="Only On-Screen",Flag="KW_ESP_OS",Default=true,Callback=function(v) onlyOnScreen=v end})
    sec:Slider({Name="Max Distance",Flag="KW_ESP_DIST",Default=maxDistance,Min=200,Max=5000,Callback=function(v) maxDistance=v end})
    sec:Dropdown({Name="Occluded Color",Flag="KW_ESPOCC",Content={"Red","Green","Yellow","Magenta"},Default="Red",Callback=function(lbl) occludedColor = colors[lbl] or colors.Red end})
    sec:Slider({Name="Thickness",Flag="KW_ESPTk",Default=math.floor(thickness),Min=1,Max=6,Callback=function(v) thickness=v end})
    sec:Slider({Name="Line Transparency",Flag="KW_ESPAl",Default=math.floor(alpha*10),Min=1,Max=10,Callback=function(v) alpha=v/10 end})

    local s2=Visual:Section({Name="ESP Elements", Side="Right"})
    s2:Toggle({Name="Skeleton",Flag="KW_ESPSkel",Default=true,Callback=function(v) showSkeleton=v end})
    s2:Toggle({Name="Boxes (outline)",Flag="KW_ESPBox",Default=true,Callback=function(v) showBoxes=v end})
    s2:Toggle({Name="Filled Box",Flag="KW_ESPFBox",Default=false,Callback=function(v) showFilledBox=v end})
    s2:Slider({Name="Fill Alpha",Flag="KW_ESPFill",Default=math.floor(fillAlpha*100),Min=1,Max=90,Callback=function(v) fillAlpha = clamp(v/100,0.02,0.9) end})
    s2:Toggle({Name="Tracers",Flag="KW_ESPTracer",Default=true,Callback=function(v) showTracers=v end})
    s2:Dropdown({Name="Tracer Origin",Flag="KW_TR_ORG",Content={"Bottom","Center","Mouse"},Default="Bottom",Callback=function(v) tracerOrigin=v end})
    s2:Toggle({Name="Name Tags",Flag="KW_ESPName",Default=true,Callback=function(v) showNames=v end})
    s2:Toggle({Name="Health Bar + HP",Flag="KW_ESPHP",Default=true,Callback=function(v) showHealth=v end})
    s2:Toggle({Name="Distance Text",Flag="KW_ESPDist",Default=true,Callback=function(v) showDistance=v end})
end

-- Item ESP UI
do
    local I = Visual:Section({Name="Item ESP", Side="Left"})
    I:Toggle({Name="Show Equipped Item", Flag="KW_ITEM_EN", Default=true, Callback=function(v) showItem=v end})
    I:Colorpicker({Name="Item Text Color", Flag="KW_ITEM_COL", Default=itemColor, Callback=function(c) itemColor=c end})
    I:Slider({Name="Item Offset Y", Flag="KW_ITEM_OY", Default=itemOffsetY, Min=-40, Max=40, Callback=function(v) itemOffsetY=v end})
end

----------------------------------------------------------------
-- Aimbot (Wall Check + Distance + HUD)
----------------------------------------------------------------
local aimEnabled=false
local aimHoldToUse=false
local aimKey=Enum.KeyCode.Q
local aimHoldKey=Enum.UserInputType.MouseButton2
local aimTargetPartName="Head"
local aimSmoothing=0.18
local aimFOV=150
local aimTeamCheck=false
local aimWallCheck=true
local aimMaxDistance = 1000
local showTargetHUD = true

local aimConn
local fovCircle, targetHUD
if hasDrawing then
    fovCircle=Drawing.new("Circle")
    fovCircle.Visible=false
    fovCircle.Filled=false
    fovCircle.Thickness=1.5
    fovCircle.Transparency=0.9
    fovCircle.Color=Color3.fromRGB(180,220,255)

    targetHUD=Drawing.new("Text")
    targetHUD.Visible=false
    targetHUD.Center=true
    targetHUD.Size=14
    targetHUD.Outline=true
    targetHUD.Color=Color3.fromRGB(230,230,255)
    targetHUD.Text=""
end
local function setFOVVisible(v) if fovCircle then fovCircle.Visible=v end end
local function updateFOVCircle()
    if not fovCircle then return end
    local m=UIS:GetMouseLocation()
    fovCircle.Position=Vector2.new(m.X,m.Y)
    fovCircle.Radius=aimFOV
end
local function setTargetHUD(txt, pos)
    if not targetHUD then return end
    if showTargetHUD and txt then
        targetHUD.Text = txt
        targetHUD.Position = pos or Vector2.new(Camera.ViewportSize.X/2, 40)
        targetHUD.Visible = true
    else
        targetHUD.Visible = false
    end
end
local function screenPoint(part) local v,o=Camera:WorldToViewportPoint(part.Position) return Vector2.new(v.X,v.Y),o end
local function sameTeamAim(plr) return aimTeamCheck and ((LP.Team and plr.Team and LP.Team==plr.Team) or (LP.TeamColor and plr.TeamColor and LP.TeamColor==plr.TeamColor)) end
local function clearLOSTo(part, targetChar)
    if not aimWallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {LP.Character, targetChar}
    local hit = Workspace:Raycast(origin, dir, rp)
    return hit == nil
end
local function getClosestTarget(fovCap, distCap)
    local m=UIS:GetMouseLocation(); local closest,bestDist=nil,math.huge
    local camPos = Camera.CFrame.Position
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and plr.Character and not sameTeamAim(plr) then
            local hum=plr.Character:FindFirstChildOfClass("Humanoid") if hum and hum.Health>0 then
                local part=plr.Character:FindFirstChild(aimTargetPartName) or plr.Character:FindFirstChild("HumanoidRootPart")
                if part then
                    local worldDist = (part.Position - camPos).Magnitude
                    if worldDist <= distCap then
                        local pos,on=screenPoint(part)
                        if on and clearLOSTo(part, plr.Character) then
                            local d=(pos-Vector2.new(m.X,m.Y)).Magnitude
                            if d<=fovCap and d<bestDist then
                                closest,bestDist=part,d
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end
local function aimAt(part)
    if not part then return end
    local cf=Camera.CFrame
    local target=CFrame.new(cf.Position,part.Position)
    Camera.CFrame=cf:Lerp(target,clamp(aimSmoothing,0.01,1))
end
local holding=false
UIS.InputBegan:Connect(function(i,gpe) if gpe then return end if i.UserInputType==aimHoldKey then holding=true end if i.KeyCode==aimKey then aimEnabled=not aimEnabled setFOVVisible(aimEnabled) end end)
UIS.InputEnded:Connect(function(i,gpe) if i.UserInputType==aimHoldKey then holding=false end end)
local function stepAimbot()
    if not aimEnabled then
        updateFOVCircle()
        setTargetHUD(nil)
        return
    end
    if aimHoldToUse and not holding then
        updateFOVCircle()
        setTargetHUD(nil)
        return
    end
    local t=getClosestTarget(aimFOV, aimMaxDistance)
    if t then
        aimAt(t)
        local ch = t.Parent
        local plr = ch and Players:GetPlayerFromCharacter(ch)
        local who = plr and plr.Name or "Target"
        local dist = (t.Position - Camera.CFrame.Position).Magnitude
        setTargetHUD(string.format("%s  •  %.0fs", who, dist), Vector2.new(Camera.ViewportSize.X/2, 40))
    else
        setTargetHUD(nil)
    end
    updateFOVCircle()
end
local function enableAimbot() if aimConn then aimConn:Disconnect() end aimConn=RunService.RenderStepped:Connect(stepAimbot) setFOVVisible(true) end
local function disableAimbot() if aimConn then aimConn:Disconnect() aimConn=nil end setFOVVisible(false) setTargetHUD(nil) end
do
    local sec=Combat:Section({Name="Aimbot",Side="Left"})
    sec:Toggle({Name="Enabled",Flag="KW_AIM_EN",Default=false,Callback=function(v) if v then enableAimbot() else disableAimbot() end end})
    sec:Toggle({Name="Hold RMB",Flag="KW_AIM_HOLD",Default=false,Callback=function(v) aimHoldToUse=v end})
    sec:Toggle({Name="Team Check",Flag="KW_AIM_TEAM",Default=false,Callback=function(v) aimTeamCheck=v end})
    sec:Toggle({Name="Wall Check (LOS)",Flag="KW_AIM_WALL",Default=true,Callback=function(v) aimWallCheck=v end})
    sec:Slider({Name="Max Distance (studs)",Flag="KW_AIM_MAXD",Default=aimMaxDistance,Min=200,Max=5000,Callback=function(v) aimMaxDistance=v end})
    sec:Toggle({Name="Target HUD (name + distance)",Flag="KW_AIM_HUD",Default=true,Callback=function(v) showTargetHUD=v if not v then setTargetHUD(nil) end end})
    sec:Dropdown({Name="Target Part",Flag="KW_AIM_PART",Content={"Head","HumanoidRootPart"},Default="Head",Callback=function(v) aimTargetPartName=v end})
    sec:Slider({Name="FOV",Flag="KW_AIM_FOV",Default=aimFOV,Min=40,Max=600,Callback=function(v) aimFOV=v end})
    sec:Slider({Name="Smooth",Flag="KW_AIM_SM",Default=math.floor(aimSmoothing*100),Min=1,Max=100,Callback=function(v) aimSmoothing=clamp(v/100,0.01,1) end})
    sec:Keybind({Name="Toggle Key",Flag="KW_AIM_KEY",Default=aimKey,Callback=function(k) if typeof(k)=="EnumItem" then aimKey=k end end})
end

----------------------------------------------------------------
-- Silent Aim (with its own FOV circle)
----------------------------------------------------------------
local saEnabled = true
local saFOV     = 120
local saWall    = true
local saMaxDist = 1000
local saTargetPart = "Head"
local saAssistFrames = 2
local saAssistStrength = 1.0
local saShowCircle = true
local saCircleColor = Color3.fromRGB(255, 180, 120)

local saCircle
if hasDrawing then
    saCircle = Drawing.new("Circle")
    saCircle.Visible = false
    saCircle.Filled = false
    saCircle.Thickness = 1.5
    saCircle.Transparency = 0.95
    saCircle.Color = saCircleColor
end

local function updateSACircle()
    if not saCircle then return end
    if not (saEnabled and saShowCircle) then saCircle.Visible=false return end
    local m=UIS:GetMouseLocation()
    saCircle.Position=Vector2.new(m.X,m.Y)
    saCircle.Radius=saFOV
    saCircle.Color=saCircleColor
    saCircle.Visible=true
end

local saSection = Combat:Section({Name="Silent Aim", Side="Right"})
saSection:Toggle({Name="Enabled", Flag="KW_SA_EN", Default=saEnabled, Callback=function(v) saEnabled=v updateSACircle() end})
saSection:Toggle({Name="Show SA FOV", Flag="KW_SA_SHOW", Default=saShowCircle, Callback=function(v) saShowCircle=v updateSACircle() end})
saSection:Colorpicker({Name="SA FOV Color", Flag="KW_SA_COL", Default=saCircleColor, Callback=function(c) saCircleColor=c updateSACircle() end})
saSection:Toggle({Name="Wall Check", Flag="KW_SA_WALL", Default=saWall, Callback=function(v) saWall=v end})
saSection:Slider({Name="FOV", Flag="KW_SA_FOV", Default=saFOV, Min=30, Max=600, Callback=function(v) saFOV=v updateSACircle() end})
saSection:Slider({Name="Max Distance", Flag="KW_SA_MAXD", Default=saMaxDist, Min=200, Max=5000, Callback=function(v) saMaxDist=v end})
saSection:Dropdown({Name="Target Part", Flag="KW_SA_PART", Content={"Head","HumanoidRootPart"}, Default=saTargetPart, Callback=function(v) saTargetPart=v end})
saSection:Slider({Name="Assist Frames", Flag="KW_SA_FRAMES", Default=saAssistFrames, Min=1, Max=3, Callback=function(v) saAssistFrames=math.floor(v) end})
saSection:Slider({Name="Assist Strength%", Flag="KW_SA_STR", Default=math.floor(saAssistStrength*100), Min=25, Max=100, Callback=function(v) saAssistStrength=clamp(v/100,0.25,1) end})

local function clearLOSToSilent(part, ch)
    if not saWall then return true end
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local rp = RaycastParams.new()
    rp.FilterType = Enum.RaycastFilterType.Blacklist
    rp.FilterDescendantsInstances = {LP.Character, ch}
    local hit = Workspace:Raycast(origin, dir, rp)
    return hit == nil
end

local function getClosestForSilent(fovCap, distCap)
    local m=UIS:GetMouseLocation(); local closest,bestDist=nil,math.huge
    local camPos = Camera.CFrame.Position
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=LP and not sameTeam(plr) then
            local ch=plr.Character
            local hum=ch and ch:FindFirstChildOfClass("Humanoid")
            if ch and hum and hum.Health>0 then
                local part=ch:FindFirstChild(saTargetPart) or ch:FindFirstChild("HumanoidRootPart")
                if part then
                    local worldDist=(part.Position-camPos).Magnitude
                    if worldDist <= distCap then
                        local pos,on=Camera:WorldToViewportPoint(part.Position)
                        if on and clearLOSToSilent(part, ch) then
                            local d=(Vector2.new(pos.X,pos.Y)-Vector2.new(m.X,m.Y)).Magnitude
                            if d<=fovCap and d<bestDist then
                                closest,bestDist=part,d
                            end
                        end
                    end
                end
            end
        end
    end
    return closest
end

local snapping=false
UIS.InputBegan:Connect(function(input, gpe)
    if gpe or not saEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if snapping then return end
        local target = getClosestForSilent(saFOV, saMaxDist)
        if target then
            snapping = true
            local oldCF = Camera.CFrame
            local desired = CFrame.new(oldCF.Position, target.Position)
            for _=1, saAssistFrames do
                local blend = (saAssistStrength >= 1) and desired or oldCF:Lerp(desired, saAssistStrength)
                Camera.CFrame = blend
                RunService.RenderStepped:Wait()
            end
            Camera.CFrame = oldCF
            snapping = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    updateSACircle()
end)

----------------------------------------------------------------
-- Reload Speed (animation AdjustSpeed multiplier on reload tracks)
----------------------------------------------------------------
local rsEnabled = true
local rsMultiplier = 3.0      -- 1.0 = normal, 3.0 = 3x faster reload
local rsCooldownMs = 250      -- don’t spam AdjustSpeed too often
local rsScanInterval = 0.06
local rsConn
local rsAccum = 0
local lastRS = {} -- [track] = last adjusted os.clock()

local function isReloadTrack(track)
    local n = (track.Name or ""):lower()
    if n:find("reload") or n:find("mag") or n:find("clip") then return true end
    local anim = track.Animation
    if anim and anim.AnimationId then
        local id = tostring(anim.AnimationId):lower()
        if id:find("reload") or id:find("mag") or id:find("clip") then return true end
    end
    return false
end

local function reloadSpeedStep(dt)
    rsAccum += dt
    if rsAccum < rsScanInterval then return end
    rsAccum = 0
    if not rsEnabled then return end

    local ch = LP.Character
    if not ch then return end
    local hum = ch:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then return end

    for _,track in ipairs(animator:GetPlayingAnimationTracks()) do
        if isReloadTrack(track) then
            local now = os.clock()
            if not lastRS[track] or (now - lastRS[track]) * 1000 >= rsCooldownMs then
                lastRS[track] = now
                pcall(function()
                    track:AdjustSpeed(clamp(rsMultiplier, 1.0, 12.0))
                end)
            end
        end
    end
end

local function enableReloadSpeed()
    if rsConn then rsConn:Disconnect() end
    rsEnabled = true
    rsAccum = 0
    rsConn = RunService.Heartbeat:Connect(reloadSpeedStep)
end
local function disableReloadSpeed()
    rsEnabled = false
    if rsConn then rsConn:Disconnect() rsConn=nil end
end

do
    local RS = Combat:Section({Name="Reload Speed", Side="Right"})
    RS:Toggle({Name="Enabled", Flag="KW_RS_EN", Default=true, Callback=function(v) if v then enableReloadSpeed() else disableReloadSpeed() end end})
    RS:Slider({Name="Multiplier (x)", Flag="KW_RS_MULT", Default=math.floor(rsMultiplier*10), Min=10, Max=120, Callback=function(v) rsMultiplier = clamp(v/10,1.0,12.0) end})
    RS:Slider({Name="Per-Adjust Cooldown (ms)", Flag="KW_RS_CD", Default=rsCooldownMs, Min=100, Max=800, Callback=function(v) rsCooldownMs = math.floor(v) end})
    RS:Slider({Name="Scan Interval (ms)", Flag="KW_RS_IV", Default=math.floor(rsScanInterval*1000), Min=30, Max=150, Callback=function(v) rsScanInterval = clamp(v/1000, 0.03, 0.15) end})
end

----------------------------------------------------------------
-- Utility: Fullbright / FOV Lock
----------------------------------------------------------------
local fbEnabled, fbConn=false,nil
local fbBrightness, fbClock, fbNoShadows=3,14,true
local fogEnabled=true
local savedLighting, cc = {}, nil
local function saveLighting() savedLighting.Ambient=Lighting.Ambient; savedLighting.OutdoorAmbient=Lighting.OutdoorAmbient; savedLighting.Brightness=Lighting.Brightness; savedLighting.ClockTime=Lighting.ClockTime; savedLighting.GlobalShadows=Lighting.GlobalShadows; savedLighting.FogStart=Lighting.FogStart; savedLighting.FogEnd=Lighting.FogEnd end
local function applyFullbrightOnce() Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1); Lighting.Brightness=fbBrightness; Lighting.ClockTime=fbClock; Lighting.GlobalShadows=not fbNoShadows; if not fogEnabled then Lighting.FogStart=0 Lighting.FogEnd=1e6 end if not cc then cc=Instance.new("ColorCorrectionEffect") cc.Name="KW_Fullbright" cc.Brightness=0.05 cc.Contrast=0.05 cc.Saturation=0.05 cc.Parent=Lighting end end
local function enableFullbright() if fbEnabled then return end saveLighting() applyFullbrightOnce() fbConn=RunService.RenderStepped:Connect(applyFullbrightOnce) fbEnabled=true end
local function disableFullbright() if not fbEnabled then return end fbEnabled=false if fbConn then fbConn:Disconnect() fbConn=nil end if cc then cc:Destroy() cc=nil end for k,v in pairs(savedLighting) do Lighting[k]=v end end
local fovValue=80; local fovConn
local function enableFOVLock() if fovConn then fovConn:Disconnect() end fovConn=RunService.RenderStepped:Connect(function() Camera.FieldOfView=fovValue end) end
local function disableFOVLock() if fovConn then fovConn:Disconnect() fovConn=nil end end
do
    local U=Utility:Section({Name="Fullbright & Visuals",Side="Left"})
    U:Toggle({Name="Fullbright (lock)",Flag="KW_FB",Default=false,Callback=function(v) if v then enableFullbright() else disableFullbright() end end})
    U:Slider({Name="Brightness",Flag="KW_FB_BR",Default=fbBrightness,Min=1,Max=6,Callback=function(v) fbBrightness=v end})
    U:Slider({Name="Time (Clock)",Flag="KW_FB_TM",Default=fbClock,Min=0,Max=24,Callback=function(v) fbClock=v end})
    U:Toggle({Name="No Shadows",Flag="KW_FB_NS",Default=fbNoShadows,Callback=function(v) fbNoShadows=v end})
    U:Toggle({Name="No Fog",Flag="KW_FB_NF",Default=true,Callback=function(v) fogEnabled=v end})
    local F=Utility:Section({Name="Camera",Side="Right"})
    F:Toggle({Name="FOV Lock",Flag="KW_FOV_L",Default=false,Callback=function(v) if v then enableFOVLock() else disableFOVLock() end end})
    F:Slider({Name="FOV",Flag="KW_FOV_V",Default=fovValue,Min=40,Max=120,Callback=function(v) fovValue=v end})
end

----------------------------------------------------------------
-- Gun Chams (Tools + Arms/Viewmodel)
----------------------------------------------------------------
local gunChamsEnabled=false
local gunChamsMaterial="Neon"
local gunChamsColor=Color3.fromRGB(255,105,180)
local gunChamsTransparency=0.25
local gunChamsIncludeArms=true

local gunChamsState = {}   -- [BasePart] = {Material, Color, Transparency}
local gunChamConns = {}
local matEnum = { Neon = Enum.Material.Neon, ForceField = Enum.Material.ForceField, Plastic = Enum.Material.Plastic }

local function savePartState(p)
    if gunChamsState[p] then return end
    gunChamsState[p] = { Material = p.Material, Color = p.Color, Transparency = p.Transparency }
end
local function restorePartState(p)
    local st = gunChamsState[p]
    if not st then return end
    pcall(function() p.Material = st.Material p.Color = st.Color p.Transparency = st.Transparency end)
    gunChamsState[p] = nil
end
local function applyChamToPart(p)
    if not p:IsA("BasePart") then return end
    savePartState(p)
    pcall(function()
        p.Material = matEnum[gunChamsMaterial] or Enum.Material.Neon
        p.Color = gunChamsColor
        p.Transparency = clamp(gunChamsTransparency,0,1)
        p.Reflectance = 0
    end)
end
local function applyChamToContainer(container)
    if not container then return end
    for _,d in ipairs(container:GetDescendants()) do
        if d:IsA("BasePart") then applyChamToPart(d) end
    end
end
local function restoreContainer(container)
    if not container then return end
    for _,d in ipairs(container:GetDescendants()) do
        if d:IsA("BasePart") then restorePartState(d) end
    end
end
local function hookTool(tool)
    table.insert(gunChamConns, tool.AncestryChanged:Connect(function(_, parent)
        if not gunChamsEnabled then return end
        if tool:IsDescendantOf(LP.Character) then applyChamToContainer(tool) else restoreContainer(tool) end
    end))
    if tool:IsDescendantOf(LP.Character) then applyChamToContainer(tool) end
end
local gunChamLoop
local function sweepGunChams()
    if not gunChamsEnabled then return end
    local ch = LP.Character
    if ch then
        for _,child in ipairs(ch:GetChildren()) do
            if child:IsA("Tool") or child:IsA("Model") then applyChamToContainer(child) end
        end
    end
    if gunChamsIncludeArms then
        for _,camChild in ipairs(Camera:GetChildren()) do
            if camChild:IsA("Model") or camChild:IsA("Folder") then applyChamToContainer(camChild)
            elseif camChild:IsA("BasePart") then applyChamToPart(camChild) end
        end
    end
end
local function unhookGunChams() for _,c in ipairs(gunChamConns) do if c then c:Disconnect() end end gunChamConns = {} end
local function enableGunChams()
    if gunChamsEnabled then return end
    gunChamsEnabled = true
    local ch = LP.Character
    if ch then for _,child in ipairs(ch:GetChildren()) do if child:IsA("Tool") or child:IsA("Model") then hookTool(child) end end end
    table.insert(gunChamConns, LP.CharacterAdded:Connect(function(newCh)
        task.wait(0.1)
        for _,child in ipairs(newCh:GetChildren()) do if child:IsA("Tool") or child:IsA("Model") then hookTool(child) end end
    end))
    table.insert(gunChamConns, LP.Character.ChildAdded:Connect(function(obj) if obj:IsA("Tool") or obj:IsA("Model") then hookTool(obj) end end))
    if gunChamLoop then gunChamLoop:Disconnect() end
    gunChamLoop = RunService.RenderStepped:Connect(sweepGunChams)
end
local function disableGunChams()
    gunChamsEnabled = false
    if gunChamLoop then gunChamLoop:Disconnect() gunChamLoop=nil end
    unhookGunChams()
    for part,_ in pairs(gunChamsState) do restorePartState(part) end
end

do
    local G = Visual:Section({Name="Gun Chams", Side="Right"})
    G:Toggle({Name="Enabled", Flag="KW_GC_EN", Default=false, Callback=function(v) if v then enableGunChams() else disableGunChams() end end})
    G:Dropdown({Name="Material", Flag="KW_GC_MAT", Content={"Neon","ForceField","Plastic"}, Default="Neon", Callback=function(v) gunChamsMaterial=v end})
    G:Colorpicker({Name="Color", Flag="KW_GC_COL", Default=gunChamsColor, Callback=function(c) gunChamsColor=c end})
    G:Slider({Name="Transparency", Flag="KW_GC_TR", Default=math.floor(gunChamsTransparency*100), Min=0, Max=100, Callback=function(v) gunChamsTransparency = clamp(v/100,0,1) end})
    G:Toggle({Name="Include Camera Arms/Viewmodel", Flag="KW_GC_ARMS", Default=true, Callback=function(v) gunChamsIncludeArms=v end})
end

----------------------------------------------------------------
-- Settings / Hotkeys / Lifecycle
----------------------------------------------------------------
local S = Settings:Section({Name="KittenWare"})
S:Keybind({Name="Toggle UI", Flag="KW_UI", Default=Enum.KeyCode.RightShift, Callback=function(_, newKey) if not newKey then GUI:Close() end end})
S:Button({Name="Unload", Callback=function()
    disableGunChams()
    disableAimbot()
    disableESP()
    disableNR()
    disableFullbright()
    disableReloadSpeed()
    GUI:Unload()
    getgenv().KittenWareLoaded=nil
end})

UIS.InputBegan:Connect(function(i,gpe)
    if gpe then return end
    if i.KeyCode==Enum.KeyCode.N then if nrEnabled then disableNR() else enableNR() end
    elseif i.KeyCode==Enum.KeyCode.B then if espEnabled then disableESP() else enableESP() end end
end)

game:BindToClose(function()
    disableGunChams(); disableAimbot(); disableESP(); disableNR(); disableFullbright(); disableReloadSpeed()
end)

-- start systems
enableReloadSpeed()

getgenv().KittenWareLoaded = true
getgenv().KittenWareLoading = nil
-- UI left open
