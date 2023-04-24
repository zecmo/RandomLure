local rlList, src
local addon = ...

--------------------------------------------------------------------
-- Produced Marco Name [in player's macros]
--   One of the reasons I went with Random Lure over Random Bobble is bc the whole word fits on the actionbar.
--------------------------------------------------------------------

local MacroName = "Lure" 
local debug = false

--------------------------------------------------------------------
-- Bobber Toys List
--------------------------------------------------------------------

local rlToys = {
--- The unique bobble lure to increase. Being in this list is a toss up on pref. --
	{202207, "Reuseable Oversized Bobber"},
--- Remaining are straight fwd lures --
	{142528, "Can of Worms"},
	{147307, "Carved Wooden Helm"},
	{142529, "Cat Head"},
	{147312, "Demon Noggin"},
	{147308, "Enchanted Bobber"},
	{147309, "Face of the Forest"},
	{147310, "Floating Totem"},
	{142532, "Murlock Head"},
	{147311, "Replica Gondola"},
	{142531, "Squeaky Duck"},
	{142530, "Tugboat"},
	{143662, "Wooden Pepe"},	
	}

--------------------------------------------------------------------
-- Bobber Toys SpellIds
--   Upon use, a toy's spellId is sent through the SPELLCAST msgs
--------------------------------------------------------------------

local rlLureToySpellIds = {} --All the toys
-- rlLureToySpellIds[toyId] = spellId -- Human readable name comment -- 
rlLureToySpellIds[202207] = 397827 -- "Reuseable Oversized Bobber"
rlLureToySpellIds[142528] = 231291 -- "Can of Worms"
rlLureToySpellIds[147307] = 000000 -- "Carved Wooden Helm"
rlLureToySpellIds[142529] = 231319 -- "Cat Head"
rlLureToySpellIds[147312] = 000000 -- "Demon Noggin"
rlLureToySpellIds[147308] = 000000 -- "Enchanted Bobber"
rlLureToySpellIds[147309] = 000000 -- "Face of the Forest"
rlLureToySpellIds[147310] = 000000 -- "Floating Totem"
rlLureToySpellIds[142532] = 000000 -- "Murlock Head"
rlLureToySpellIds[147311] = 000000 -- "Replica Gondola"
rlLureToySpellIds[142531] = 231341 -- "Squeaky Duck"
rlLureToySpellIds[142530] = 231338 -- "Tugboat"
rlLureToySpellIds[143662] = 232613 -- "Wooden Pepe"

--------------------------------------------------------------------
-- Used to check incoming spellIds, what is a Lure toy?
--------------------------------------------------------------------
function IsLureToySpellId(spellId)
	if not InCombatLockdown() then
		for k in pairs(rlLureToySpellIds) do
			-- Is spellId one of the lure/bobble toys? --
			if spellId == rlLureToySpellIds[k] then
				return true
			end
		end
	end

	return false
end


--------------------------------------------------------------------
-- UI in Options panel
--------------------------------------------------------------------

local rlOptionsPanel = CreateFrame("Frame")
rlOptionsPanel.name = "Random Lure [/rl or /lure]"
rlOptionsPanel.okay = function() optionsOkay(); end
rlOptionsPanel.cancel = function() optionsCancel(); end
InterfaceOptions_AddCategory(rlOptionsPanel)

-- Title --
local rlTitle = CreateFrame("Frame",nil, rlOptionsPanel)
rlTitle:SetPoint("TOPLEFT", 10, -10)
rlTitle:SetWidth(SettingsPanel.Container:GetWidth()-35)
rlTitle:SetHeight(1)
rlTitle.text = rlTitle:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rlTitle.text:SetPoint("TOPLEFT", rlTitle, 0, 0)
rlTitle.text:SetText("Random Lure")
rlTitle.text:SetFont("Fonts\\FRIZQT__.TTF", 18)

-- Thanks --
rlOptionsPanel.Thanks = rlOptionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rlOptionsPanel.Thanks:SetPoint("BOTTOMRIGHT",-5,5)
rlOptionsPanel.Thanks:SetText("For all my kindred and true fisherlunkers who chose the [Boots of the Bay] first.\n Cloned from \"Random Hearthstone\" by JamienAU.  \n Tweaked into \"Random Lure\" by zecmo.    \nHakkar")
rlOptionsPanel.Thanks:SetFont("Fonts\\FRIZQT__.TTF", 9)
rlOptionsPanel.Thanks:SetJustifyH("RIGHT")

-- Description
local rlDesc = CreateFrame("Frame", nil, rlOptionsPanel)
rlDesc:SetPoint("TOPLEFT", 20, -40)
rlDesc:SetWidth(SettingsPanel.Container:GetWidth()-35)
rlDesc:SetHeight(1)
rlDesc.text = rlDesc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rlDesc.text:SetPoint("TOPLEFT", rlDesc, 0, 0)
rlDesc.text:SetText("Add or remove lure toys from rotation")
rlDesc.text:SetFont("Fonts\\FRIZQT__.TTF", 14)

-- Scroll Frame
local rlOptionsScroll = CreateFrame("ScrollFrame", nil, rlOptionsPanel, "UIPanelScrollFrameTemplate")
rlOptionsScroll:SetPoint("TOPLEFT", 5, -60)
rlOptionsScroll:SetPoint("BOTTOMRIGHT", -25, 100)

-- Divider
local rlDivider = rlOptionsScroll:CreateLine()
rlDivider:SetStartPoint("BOTTOMLEFT", 20, -10)
rlDivider:SetEndPoint("BOTTOMRIGHT", 0, -10)
rlDivider:SetColorTexture(0.25,0.25,0.25,1)
rlDivider:SetThickness(1.2)

-- Scroll Frame child
local rlScrollChild = CreateFrame("Frame")
rlOptionsScroll:SetScrollChild(rlScrollChild)
rlScrollChild:SetWidth(SettingsPanel.Container:GetWidth()-35)
rlScrollChild:SetHeight(1)

-- Checkbox for each toy
local rlCheckButtons = {}
for i = 1, #rlToys do
	local chkOffset = 0
	if i > 1 then
		local _,_,_,_,yOffSet = rlCheckButtons[i-1]:GetPoint()
		chkOffset = math.floor(yOffSet) + -26
	end
	rlCheckButtons[i] = CreateFrame("CheckButton", nil, rlScrollChild, "UICheckButtonTemplate")
	rlCheckButtons[i]:SetPoint("TOPLEFT", 15, chkOffset)
	rlCheckButtons[i]:SetSize(25,25)
	rlCheckButtons[i].ID = rlToys[i][1]
	rlCheckButtons[i].Text:SetText("  " .. rlToys[i][2])
	rlCheckButtons[i].Text:SetTextColor(1,1,1,1)
	rlCheckButtons[i].Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
end

-- Select All button
local rlSelectAll = CreateFrame("Button", nil, rlOptionsPanel, "UIPanelButtonTemplate")
rlSelectAll:SetPoint("BOTTOMLEFT", 20, 50)
rlSelectAll:SetSize(100,25)
rlSelectAll:SetText("Select all")
rlSelectAll:SetScript("OnClick", function(self)
	for i = 1, #rlToys do
		rlCheckButtons[i]:SetChecked(true)
	end
end)

-- Deselect All button
local rlDeselectAll = CreateFrame("Button", nil, rlOptionsPanel, "UIPanelButtonTemplate")
rlDeselectAll:SetPoint("BOTTOMLEFT", 135, 50)
rlDeselectAll:SetSize(100,25)
rlDeselectAll:SetText("Deselect all")
rlDeselectAll:SetScript("OnClick", function(self)
	for i = 1, #rlToys do
		rlCheckButtons[i]:SetChecked(false)
	end
end)

--------------------------------------------------------------------
-- Init/Awake AddonLoaded Msg Handling & Loading
--------------------------------------------------------------------
local rlListener = CreateFrame("Frame")
rlListener:RegisterEvent("ADDON_LOADED")
rlListener:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addon then
		if rlOptions == nil then
			-- Adds all toy IDs to savedvariables as enabled
			rlOptions = {}
			for i=1, #rlToys do
				rlOptions[i] = {rlToys[i][1], true}
			end
		else
			-- Deletes toy IDs that no longer exist in rlToys list
			for i,v in pairs(rlOptions) do
				local chk = 0
				for l = 1, #rlToys do
					if v[1] == rlToys[l][1] then
						chk = 1
					end
				end
				if chk == 0 then 
					rlOptions[i] = nil
				end
			end

			-- Adds any missing toy IDs to savedvariables as enabled
			for i,v in pairs(rlToys) do
				local chk = 0
				for l = 1, #rlOptions do
					if v[1] == rlOptions[l][1] then
						chk = 1
					end
				end
				if chk == 0 then
					table.insert(rlOptions, {v[1], true})
				end
			end
		end
		
		-- Loop through options and set checkbox state
		for i,v in pairs(rlOptions) do
			for l = 1, #rlOptions do
				if rlCheckButtons[l].ID == v[1] and v[2] == true then
					rlCheckButtons[l]:SetChecked(true)
				end
			end
		end

	self:UnregisterEvent("ADDON_LOADED")
	end
end)

--------------------------------------------------------------------
-- Assigned methods to the UI Panel's Confirm/Okay & Cancel [which Option UI updates where all changes are live with confirm, I'm not sure if the Cancel ever gets called. Perhaps in other use cases.
--------------------------------------------------------------------
rlOptionsPanel.okay = function() optionsOkay(); end
rlOptionsPanel.cancel = function() optionsCancel(); end

function optionsOkay()
	for i = 1, #rlOptions do
		for _,v in pairs(rlOptions) do
			if rlCheckButtons[i].ID == v[1] then
				v[2] = rlCheckButtons[i]:GetChecked()
			end
		end
	end

	RefreshRandomToyPool()
	SelectRandomLureToy()
end

function optionsCancel()
	for i,v in pairs(rlOptions) do
		for l = 1, #rlOptions do
			if rlCheckButtons[l].ID == v[1] and v[2] == true then
				rlCheckButtons[l]:SetChecked(true)
			end
		end
	end
end

--------------------------------------------------------------------
-- Toys can only be used through a button click, so we create an invisible button for our macro to click.
--  Button creation, named [rlButton]
--------------------------------------------------------------------
local rlBtn = CreateFrame("Button", "rlButton", nil,  "SecureActionButtonTemplate")

-- WoW client events we want to know about --
rlBtn:RegisterEvent("PLAYER_ENTERING_WORLD")
rlBtn:RegisterEvent("UNIT_SPELLCAST_STOP")
rlBtn:RegisterEvent("UNIT_SPELLCAST_FAILED")
rlBtn:RegisterForClicks("LeftButtonDown", "LeftButtonUp" )
rlBtn:SetAttribute("type","toy")

-- Pass in an anonymous function which handles the events --
rlBtn:SetScript("OnEvent", function(self,event, arg1, arg2, arg3)
	if not InCombatLockdown() then
		if event == "PLAYER_ENTERING_WORLD" then
			RefreshRandomToyPool()
			SelectRandomLureToy()
			-- Unregister from event --
			rlBtn:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end
			
		if event == "UNIT_SPELLCAST_STOP" and arg1 == "player" then
			if IsLureToySpellId(arg3) then
				SelectRandomLureToy()
			end
		end

		if event == "UNIT_SPELLCAST_FAILED" and arg1 == "player" then
			if IsLureToySpellId(arg3) then
				 WaitThenSetRandom()
			end
		end
	end
end)

--------------------------------------------------------------------
-- I added handling "UNIT_SPELLCAST_FAILED" to allow cycleing through lure toys on cooldown.
--   However handling the msg too quickly, caused the character to /say part of the macro.
--    Adding a little wait seemed to fix the problem and it's a more consistent UX.
--------------------------------------------------------------------
function WaitThenSetRandom()
	local timeOut = 1
	C_Timer.After(timeOut, function()
		local ticker
		ticker = C_Timer.NewTicker(1, function()
			-- Now call toy selection --
			SelectRandomLureToy()			
  			ticker:Cancel()
	    end)
	end)
end

--------------------------------------------------------------------
-- Generate the list of valid Bobble/Lure toys
--------------------------------------------------------------------
function RefreshRandomToyPool()
	rlList = {}
	for i=1, #rlOptions do
		if rlOptions[i][2] == true then
			if PlayerHasToy(rlOptions[i][1]) then
				table.insert(rlList,rlOptions[i][1])
			end
		end
	end

	if #rlList == 0 then 
		print("|cffFF0000RandomLure Addon: No valid Lure/Bobber toy chosen -|r You cry...")
		src = "\n/cry"
	else 
		src = "\n/click rlButton 1\n/click rlButton LeftButton 1" 
	end
end

--------------------------------------------------------------------
-- Set random Lure/Bobber Toy 
--------------------------------------------------------------------
function setRandom()
	if not InCombatLockdown() and #rlList > 0 then
		local rnd = math.random(1,count)
		local item = Item:CreateFromItemID(rlList[rnd])
		item:ContinueOnItemLoad(function()
			local name = item:GetItemName()
			local icon = item:GetItemIcon()
			rlBtn:SetAttribute("toy",name)
			updateMacro(name,icon)
		end)
	elseif #rlList == 0 then
		-- Go home and /cry 
		updateMacro("Hearthstone","134414")
	end
end


--------------------------------------------------------------------
-- Set random Lure/Bobber Toy without from a diminishing pool 
--------------------------------------------------------------------
function SelectRandomLureToy()
	if debug then
		print("== remainingInPool_OnEnter: " .. #rlList) end

	-- Make sure the poolList is not empty 
	if #rlList == 0 then
		RefreshRandomToyPool()
	end

	-- Still no entries?
	if #rlList == 0 then
		-- Go home and /cry 
		updateMacro("Hearthstone","134414")
		return
	end

	-- Get random index --
	local rnd = GetRandomIndex(#rlList)
	local item = Item:CreateFromItemID(rlList[rnd])
	
	-- An async call, so pass in another anonymous fuction
	item:ContinueOnItemLoad(function()
		local name = item:GetItemName()
		local icon = item:GetItemIcon()
		-- Update button and macro 
		rlBtn:SetAttribute("toy",name)
		updateMacro(name,icon)

		-- Once the toy item data is loaded, remove the toy id from the ppol
		table.remove(rlList, rnd)
	
		if debug then
			print("=== Selected: " .. name) end

	end)
end


--------------------------------------------------------------------
-- Gets random index without allowing the same lure toy twice
--   which can happen on pool refresh
--------------------------------------------------------------------
local prevItemId = -1
function GetRandomIndex(size)
	if size > 1 then
		local rando = math.random(1,size)
		if rlList[rando] == prevItemId then
			if rando == 1 then
				rando = size
			else
				rando = rando - 1
			end
		end

		prevItemId = rlList[rando]
		return rando
	end

	if size == 1 then
		prevItemId = rlList[1]
		return 1
	end

	return 0		
end

--------------------------------------------------------------------
-- Update/Create the global macro
--------------------------------------------------------------------
function updateMacro(name,icon)
	if not InCombatLockdown() then
		local macroIndex = GetMacroIndexByName(MacroName)
		if macroIndex > 0 then
			EditMacro(macroIndex, MacroName, icon, "#showtooltip " .. name .. src)
		else
			CreateMacro(MacroName, icon, "#showtooltip " .. name .. src, nil)
		end
	end
end

--------------------------------------------------------------------
-- Create slash commands
--------------------------------------------------------------------
SLASH_RandomLure1 = "/rl"
function SlashCmdList.RandomLure(msg, editbox)
InterfaceOptionsFrame_OpenToCategory(rlOptionsPanel)
InterfaceOptionsFrame_OpenToCategory(rlOptionsPanel)
end

SLASH_RandomLure2 = "/lure"
function SlashCmdList.RandomLure(msg, editbox)
InterfaceOptionsFrame_OpenToCategory(rlOptionsPanel)
InterfaceOptionsFrame_OpenToCategory(rlOptionsPanel)
end
