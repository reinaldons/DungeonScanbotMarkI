-----------------------------------------------------------------------------------------------
-- Client Lua Script for DungeonScanbotMarkI
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"

local DungeonScanbotMarkI = {}
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function DungeonScanbotMarkI:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here

    return o
end

function DungeonScanbotMarkI:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- DungeonScanbotMarkI OnLoad
-----------------------------------------------------------------------------------------------
function DungeonScanbotMarkI:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("DungeonScanbotMarkI.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- DungeonScanbotMarkI OnDocLoaded
-----------------------------------------------------------------------------------------------
function DungeonScanbotMarkI:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "DungeonScanbotMarkIForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("ds", "OnDungeonScanbotMarkIOn", self)

		self.timer = ApolloTimer.Create(0.1, true, "OnTimer", self)

		self.skillAlert = Apollo.LoadForm(self.xmlDoc, "SkillAlert", nil, self)
		self.skillAlert:Show(false)
		self.skillAlertTimer = 50

		local displaySize = Apollo.GetDisplaySize()
		self.skillAlert:Move((displaySize["nWidth"] / 2) - 360, 150, self.skillAlert:GetWidth(), self.skillAlert:GetHeight())
		
		self.xmlDoc = nil
	end
end

-----------------------------------------------------------------------------------------------
-- DungeonScanbotMarkI Functions
-----------------------------------------------------------------------------------------------
-- Define general functions here

-- on SlashCommand "/ds"
function DungeonScanbotMarkI:OnDungeonScanbotMarkIOn()
	self.wndMain:Invoke() -- show the window
end

-- control SkillAlert frame
function DungeonScanbotMarkI:SkillAlertTimeout()
	if not self.skillAlert:IsShown() then
		return
	end
	
	if self.skillAlertTimer < 1 then
		self.skillAlert:Show(false)
		self.skillAlertTimer = 50
	else
		self.skillAlertTimer = self.skillAlertTimer - 1
	end
end

-- check Boss events
function DungeonScanbotMarkI:CheckBossEvents()
	local unitPlayer = GameLib.GetPlayerUnit()
	if not unitPlayer then
		return
	end

	local unitTarget = unitPlayer:GetTarget()
	if not unitTarget then
		return
	end
	
	if unitTarget:ShouldShowCastBar() then
		if not self.skillAlert:IsShown() then
			Sound.Play(Sound.PlayUIStoryPanelUrgent)
			self.skillAlert:FindChild("Alert"):SetText(string.format("%s is casting %s", unitTarget:GetName(), unitTarget:GetCastName()))
			self.skillAlert:Show(true)
		end
	end
end

-- on timer
function DungeonScanbotMarkI:OnTimer()
	self:SkillAlertTimeout()
	self:CheckBossEvents()
end


-----------------------------------------------------------------------------------------------
-- DungeonScanbotMarkIForm Functions
-----------------------------------------------------------------------------------------------
-- when the OK button is clicked
function DungeonScanbotMarkI:OnOK()
	self.wndMain:Close() -- hide the window
end

-- when the Cancel button is clicked
function DungeonScanbotMarkI:OnCancel()
	self.wndMain:Close() -- hide the window
end


function DungeonScanbotMarkI:TestSkillAlert( wndHandler, wndControl, eMouseButton )
	self.skillAlert:Show(true)

	Print(self.skillAlert:GetPos())
	
	for k, v in pairs(Apollo.GetDisplaySize()) do
		Print('[' .. k .. '] = ' .. v)
	end
end


-----------------------------------------------------------------------------------------------
-- DungeonScanbotMarkI Instance
-----------------------------------------------------------------------------------------------
local DungeonScanbotMarkIInst = DungeonScanbotMarkI:new()
DungeonScanbotMarkIInst:Init()
