--// KittenWare post-auth loader — proceeds ONLY if a hidden CoreGui flag "auth-successful" exists
-- If found, it will load+run kc.lua from your repo.

local Players = game:GetService("Players")

-- Safely get potential roots to search (gethui, CoreGui, PlayerGui)
local function getSearchRoots()
    local roots = {}

    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and typeof(hui) == "Instance" then table.insert(roots, hui) end
    end

    local core
    pcall(function() core = game:GetService("CoreGui") end)
    if core then table.insert(roots, core) end

    local lp = Players.LocalPlayer
    if lp then
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:FindFirstChild("PlayerGui")
        if pg then table.insert(roots, pg) end
    end

    return roots
end

-- Returns true if any descendant named "auth-successful" exists (BoolValue preferred)
local function hasAuthFlag()
    for _,root in ipairs(getSearchRoots()) do
        -- Fast path: look for the expected folder first
        local bridge = root:FindFirstChild("KittenWareBridge")
        if bridge then
            local flag = bridge:FindFirstChild("auth-successful")
            if flag then
                if flag:IsA("BoolValue") then
                    return flag.Value == true
                else
                    return true
                end
            end
        end
        -- Fallback: scan all descendants for a node named exactly "auth-successful"
        local ok, list = pcall(function() return root:GetDescendants() end)
        if ok then
            for _,inst in ipairs(list) do
                if inst.Name == "auth-successful" then
                    if inst:IsA("BoolValue") then
                        return inst.Value == true
                    else
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- Main
if hasAuthFlag() then
    local ok, src = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/kc-ignore/yeah/refs/heads/main/kc.lua", true)
    end)
    if ok and type(src) == "string" and #src > 0 then
        local loader = loadstring or load
        local f = select(2, pcall(loader, src))
        if type(f) == "function" then
            pcall(f)
        end
    else
        warn("[KittenWare] download failed")
    end
else
    -- Silently stop if flag isn't set (nothing will run).
    -- You can uncomment the line below if you want feedback.
    -- warn("[KittenWare] Auth flag not present; refusing to proceed.")
end
