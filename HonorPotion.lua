ADDON_NAME = "HonorPotion"
HONOR_POTION_NAME = "Vicious Flask of Honor"

local f = CreateFrame("Frame")

function f:Initalize()
    StaticPopupDialogs[ADDON_NAME] = {
        text = "Honor potion expired. Use another " .. HONOR_POTION_NAME .. "!",
        button1 = "Ok",
        timeout = 60,
        whileDead = false,
        hideOnEscape = true,
        sound = SOUNDKIT.RAID_WARNING,
        preferredIndex = 3,
    }
    print(ADDON_NAME .. " loaded!")
end

-- Returns the duration in seconds that the honor potion has remaining on the player before it expires.
function f:HonorPotionDuration()
    local aura = C_UnitAuras.GetAuraDataBySpellName("player", HONOR_POTION_NAME)
    if aura == nil or GetTime() >= aura.expirationTime then
        return 0
    end
    return math.floor(aura.expirationTime - GetTime())
end

function f:ADDON_LOADED(event, addOnName)
    if addOnName == ADDON_NAME then
        f:Initalize()
    end
end

function f:PLAYER_ENTERING_BATTLEGROUND(event)
    -- Checking auras immediately after entering isn't reliable, so wait a few seconds first.
    C_Timer.NewTimer(10, function()
        if self.timer ~= nil then
            self.timer:Cancel()
        end
        -- Warn the user when there's 30 seconds left on the honor potion.
        self.timer = C_Timer.NewTimer(math.max(0, f:HonorPotionDuration() - 30), function()
            if not self.timer:IsCancelled() and C_PvP.IsBattleground() then
                StaticPopup_Show(ADDON_NAME)
            end
        end)
    end)
end

function f:PLAYER_ENTERING_WORLD(event)
    if not C_PvP.IsBattleground() and self.timer ~= nil then
        self.timer:Cancel()
    end
end

function f:OnEvent(event, ...)
    self[event](self, event, ...)
end

f:SetScript("OnEvent", f.OnEvent)
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
