local _, addon = ...
local frame = CreateFrame("Frame")
local L = addon.L
LibStub("LibSink-2.0"):Embed(addon)

local throttle = {}
local colors = {
	UI_INFO_MESSAGE = { r = 1.0, g = 1.0, b = 0.0 },
	UI_ERROR_MESSAGE = { r = 1.0, g = 0.1, b = 0.1 },
}

local map = {
	SYSMSG = "system",
	UI_INFO_MESSAGE = "information",
	UI_ERROR_MESSAGE = "errors",
}
local originalOnEvent = UIErrorsFrame:GetScript("OnEvent")

UIErrorsFrame:SetScript("OnEvent", function(self, event, ...)
	print('hello ERROR.. from SoundAlerts OnEvent')
	print(...)
	print("1")
	print(event)
	print("2")
	print(self)
	print("3")
	print(throttle)
	print("done")
	local messageType, message, r, g, b
	message, r, g, b = ...
	print(message)
	print(r)
	print(g)
	print(b)
	print(GetTime())
	print(".....")
	local test
	start, duration, enabled, modRate = GetSpellCooldown("Freezing Trap")
	local cdLeft = start + duration - GetTime()
 	print("Trap is cooling down, wait " .. cdLeft .. " seconds for the next one.")
	if addon.db.profile[map[event]] then
		local messageType, message, r, g, b
		if event == "SYSMSG" then
			message, r, g, b = ...
			print("SYS Messages")
		else
			messageType, message = ...
		end
		if addon.db.profile.sink20OutputSink == "None" or (addon.db.profile.combat and InCombatLockdown()) or (throttle[message] and (throttle[message] + 7 > GetTime())) then return end
		if event ~= "SYSMSG" then r, g, b = colors[event].r, colors[event].g, colors[event].b end
		throttle[message] = GetTime()
		addon:Pour(message, r or 1.0, g or 0.1, b or 0.1)
	else
		return originalOnEvent(self, event, ...)
	end
end)

frame:SetScript("OnEvent", function(self, event, addonName)
	print('hello frame .. from SoundAlerts OnEvent')
	if addonName == "SoundAlerts" then
		addon.db = LibStub("AceDB-3.0"):New("SoundAlertsDB", {
			profile = {
				sink20OutputSink = "UIErrorsFrame",
				errors = true,
				information = false,
				system = false,
				combat = false,
			},
		}, true)

		local args = {
			type = "group",
			handler = addon,
			get = function(info) return addon.db.profile[info[1]] end,
			set = function(info, v) addon.db.profile[info[1]] = v end,
			args = {
				desc = {
					type = "description",
					name = L.addon_desc1.."\n\n"..L.addon_desc2.."\n\n"..L.addon_desc3.."\n\n",
					order = 1,
					fontSize = "medium",
				},
				errors = {
					type = "toggle",
					name = L.error,
					desc = L.error_desc,
					order = 2,
					width = "full",
				},
				information = {
					type = "toggle",
					name = L.information,
					desc = L.information_desc,
					order = 3,
					width = "full",
				},
				system = {
					type = "toggle",
					name = L.system,
					desc = L.system_desc,
					order = 4,
					width = "full",
				},
				spacer = {
					type = "description",
					name = "\n",
					order = 10,
				},
				combat = {
					type = "toggle",
					name = L.combat,
					desc = L.combat_desc,
					order = 20,
					width = "full",
				},
			},
		}
		addon:SetSinkStorage(addon.db.profile)

		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SoundAlerts", args)
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("SoundAlerts-Output", function() return addon:GetSinkAce3OptionsDataTable() end)
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SoundAlerts", "SoundAlerts")
		LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SoundAlerts-Output", L.output, "SoundAlerts")

		self:UnregisterEvent("ADDON_LOADED")
		self:SetScript("OnEvent", function() wipe(throttle) end)
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end)

frame:RegisterEvent("ADDON_LOADED")

