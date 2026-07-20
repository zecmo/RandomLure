local rlList, src
local addon = ...

--------------------------------------------------------------------
-- Produced Marco Name [in player's macros]
--   One of the reasons I went with Random Lure over Random Bobble is bc the whole word fits on the actionbar.
--------------------------------------------------------------------

local RLMacroName = "Lure"
local rlDebug = false

--------------------------------------------------------------------
-- Bobber Toys List [curated candidate IDs -- Blizzard has no toy
-- category for "fishing lure", so this list is hand-picked. Name,
-- icon, and spellId are all resolved live from the toy's item data
-- (see rlToyData/BuildToyData below), so there's nothing here to
-- keep in sync by hand besides the IDs themselves.]
--------------------------------------------------------------------

local rlToys = {
--- The unique bobble lure to increase. Being in this list is a toss up on pref. --
	202207, -- Reuseable Oversized Bobber
--- Remaining are straight fwd lures --
	142528, -- Can of Worms
	147307, -- Carved Wooden Helm
	142529, -- Cat Head
	147312, -- Demon Noggin
	147308, -- Enchanted Bobber
	147309, -- Face of the Forest
	147310, -- Floating Totem
	142532, -- Murlock Head
	147311, -- Replica Gondola
	142531, -- Squeaky Duck
	142530, -- Tugboat
	143662, -- Wooden Pepe
--- One Shadowlands lure --
	180993, -- Bat Visage Bobber
--- Three WarWithin/Undermine lures --
	237346, -- Artisan Beverage Goblet
	237345, -- Limited Edition Rocket
	237347, -- Organically-Sourced Wellington
}

--------------------------------------------------------------------
-- Per-toy name/icon/spellId, resolved live via BuildToyData below
-- rather than hand-maintained -- keyed by toy ID, same idea as
-- Random Cosplay's rcToysByID.
--------------------------------------------------------------------

local rlToyData = {}
for _, id in ipairs(rlToys) do
	rlToyData[id] = {}
end

--------------------------------------------------------------------
-- Used to check incoming spellIds, what is a Lure toy?
--------------------------------------------------------------------
function IsLureToySpellId(spellId)
	for _, data in pairs(rlToyData) do
		if spellId == data.spellId then
			return true
		end
	end

	return false
end

--------------------------------------------------------------------
-- UI in Options panel
--------------------------------------------------------------------

local rlOptionsPanel = CreateFrame("Frame")
rlOptionsPanel.name = "Random Lure [/lure]"
rlOptionsPanel.OnCommit = function() RLOptionsOkay(); end
rlOptionsPanel.OnDefault = function() end
rlOptionsPanel.OnRefresh = function() end
local rlureCategory = Settings.RegisterCanvasLayoutCategory(rlOptionsPanel, "Random Lure [/lure]")
Settings.RegisterAddOnCategory(rlureCategory)

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
rlOptionsPanel.Thanks:SetText("For all my kindred and true fisherlunkers who chose the [Boots of the Bay] first.\n zecmo - Runetotem")
rlOptionsPanel.Thanks:SetFont("Fonts\\FRIZQT__.TTF", 9)
rlOptionsPanel.Thanks:SetJustifyH("RIGHT")

-- Description
local rlDesc = CreateFrame("Frame", nil, rlOptionsPanel)
rlDesc:SetPoint("TOPLEFT", 20, -40)
rlDesc:SetWidth(SettingsPanel.Container:GetWidth()-35)
rlDesc:SetHeight(1)
rlDesc.text = rlDesc:CreateFontString(nil, "OVERLAY", "GameFontNormal")
rlDesc.text:SetPoint("TOPLEFT", rlDesc, 0, 0)
rlDesc.text:SetText("Toggle which lure toys are active the \"Lure\" macro's rotation.")
rlDesc.text:SetFont("Fonts\\FRIZQT__.TTF", 14)

-- Search box [filters the grid by toy name -- same SearchBoxTemplate as
-- Random Cosplay's toy grid. OnTextChanged wired below, once
-- ReflowLureGrid exists] --
local rlSearchBox = CreateFrame("EditBox", nil, rlOptionsPanel, "SearchBoxTemplate")
-- x=7 lines the box's left up with the toy grid's left edge below it
-- (scroll frame at x=5 + the cell's 2px inset) --
rlSearchBox:SetPoint("TOPLEFT", 7, -62)
rlSearchBox:SetSize(190, 20)

-- "Uncollected" toggle [when checked, unowned lures show (greyed out);
-- when unchecked, they're hidden from the grid entirely -- mirrors
-- Random Cosplay's show-all-toys checkbox. OnClick wired below] --
local rlShowUncollectedCheck = CreateFrame("CheckButton", nil, rlOptionsPanel, "UICheckButtonTemplate")
rlShowUncollectedCheck:SetPoint("LEFT", rlSearchBox, "RIGHT", 12, 0)
rlShowUncollectedCheck:SetSize(25, 25)
rlShowUncollectedCheck.Text:SetText("  Uncollected")
rlShowUncollectedCheck.Text:SetTextColor(1, 1, 1, 1)
rlShowUncollectedCheck.Text:SetFont("Fonts\\FRIZQT__.TTF", 12)

-- "Favorites first" toggle [sorts the player's Toy Box favorites to the
-- top of the grid -- same as Random Cosplay's favorites-first checkbox.
-- OnClick wired below] --
local rlFavoritesFirstCheck = CreateFrame("CheckButton", nil, rlOptionsPanel, "UICheckButtonTemplate")
rlFavoritesFirstCheck:SetPoint("LEFT", rlShowUncollectedCheck.Text, "RIGHT", 12, 0)
rlFavoritesFirstCheck:SetSize(25, 25)
rlFavoritesFirstCheck.Text:SetText("  Favorites first")
rlFavoritesFirstCheck.Text:SetTextColor(1, 1, 1, 1)
rlFavoritesFirstCheck.Text:SetFont("Fonts\\FRIZQT__.TTF", 12)

-- Scroll Frame
local rlOptionsScroll = CreateFrame("ScrollFrame", nil, rlOptionsPanel, "UIPanelScrollFrameTemplate")
rlOptionsScroll:SetPoint("TOPLEFT", 5, -92)
rlOptionsScroll:SetPoint("BOTTOMRIGHT", -25, 75)

-- Divider [left end meets the toy grid's left edge -- the cells sit 2px
-- in from the scroll frame's left, so the line starts there too] --
local rlDivider = rlOptionsScroll:CreateLine()
rlDivider:SetStartPoint("BOTTOMLEFT", 2, -10)
rlDivider:SetEndPoint("BOTTOMRIGHT", 0, -10)
rlDivider:SetColorTexture(0.25,0.25,0.25,1)
rlDivider:SetThickness(1.2)

-- Scroll Frame child
local GRID_WIDTH = SettingsPanel.Container:GetWidth() - 55
local rlScrollChild = CreateFrame("Frame")
rlOptionsScroll:SetScrollChild(rlScrollChild)
rlScrollChild:SetWidth(GRID_WIDTH)
rlScrollChild:SetHeight(1)

--------------------------------------------------------------------
-- Toy button [icon + quickslot border + name, toggled on/off like a
-- checkbox -- same look as Random Cosplay's Toys tab grid, just a
-- single flat list instead of one grid per category]
--------------------------------------------------------------------
local COLS = 3
local COL_OFFSET = math.floor(GRID_WIDTH / COLS)
local ROW_WIDTH, ROW_HEIGHT, ROW_STEP, ICON_SIZE = COL_OFFSET - 6, 42, 44, 28

local function PlayCheckboxSound(self)
	PlaySound(SOUNDKIT[self:GetChecked() and "IG_MAINMENU_OPTION_CHECKBOX_ON" or "IG_MAINMENU_OPTION_CHECKBOX_OFF"])
end

-- Sole visual for the checked state, copied from Random Cosplay's toy
-- grid: instead of a glow over the icon, the whole cell is framed -- a
-- gold border plus a brighter background -- so a selected toy reads as
-- selected without anything covering its icon.
local DEFAULT_BORDER_COLOR = {0.3, 0.3, 0.3, 1}
local SELECTED_BORDER_COLOR = {1, 0.82, 0, 1}
local function UpdateLureCellSelection(f)
	local selected = f:GetChecked() and true or false
	local color = selected and SELECTED_BORDER_COLOR or DEFAULT_BORDER_COLOR
	f.borderTop:SetColorTexture(unpack(color))
	f.borderBottom:SetColorTexture(unpack(color))
	f.borderLeft:SetColorTexture(unpack(color))
	f.borderRight:SetColorTexture(unpack(color))
	f.cellBg:SetColorTexture(1, 1, 1, selected and 0.14 or 0.06)
end

local function CreateToyButton(parent, id)
	local f = CreateFrame("CheckButton", nil, parent)
	f.ID = id
	f:SetSize(ROW_WIDTH, ROW_HEIGHT)

	-- Subtle cell background so each toy reads as a contained card --
	f.cellBg = f:CreateTexture(nil, "BACKGROUND", nil, -2)
	f.cellBg:SetAllPoints(f)
	f.cellBg:SetColorTexture(1, 1, 1, 0.06)

	-- Thin border, same grey tone as the dividers used elsewhere in this UI
	-- -- stored on f (not local) so UpdateLureCellSelection can recolor them
	-- to gold when this cell is checked --
	local borderColor = DEFAULT_BORDER_COLOR
	f.borderTop = f:CreateTexture(nil, "BORDER")
	f.borderTop:SetColorTexture(unpack(borderColor))
	f.borderTop:SetPoint("TOPLEFT", 0, 0)
	f.borderTop:SetPoint("TOPRIGHT", 0, 0)
	f.borderTop:SetHeight(1)
	f.borderBottom = f:CreateTexture(nil, "BORDER")
	f.borderBottom:SetColorTexture(unpack(borderColor))
	f.borderBottom:SetPoint("BOTTOMLEFT", 0, 0)
	f.borderBottom:SetPoint("BOTTOMRIGHT", 0, 0)
	f.borderBottom:SetHeight(1)
	f.borderLeft = f:CreateTexture(nil, "BORDER")
	f.borderLeft:SetColorTexture(unpack(borderColor))
	f.borderLeft:SetPoint("TOPLEFT", 0, 0)
	f.borderLeft:SetPoint("BOTTOMLEFT", 0, 0)
	f.borderLeft:SetWidth(1)
	f.borderRight = f:CreateTexture(nil, "BORDER")
	f.borderRight:SetColorTexture(unpack(borderColor))
	f.borderRight:SetPoint("TOPRIGHT", 0, 0)
	f.borderRight:SetPoint("BOTTOMRIGHT", 0, 0)
	f.borderRight:SetWidth(1)

	f.icon = f:CreateTexture(nil, "ARTWORK")
	f.icon:SetSize(ICON_SIZE, ICON_SIZE)
	f.icon:SetPoint("LEFT", 3, 0)

	-- Quickslot-style border, same as Random Cosplay's toy icons, dimmed
	-- to half so the ring doesn't outshine the icon itself --
	local bg = f:CreateTexture(nil, "BACKGROUND", nil, -1)
	bg:SetTexture("Interface/Buttons/UI-EmptySlot-Disabled")
	bg:SetPoint("CENTER", f.icon, "CENTER")
	bg:SetSize(1.5*ICON_SIZE, 1.5*ICON_SIZE)
	bg:SetVertexColor(0.5, 0.5, 0.5)
	local edge = f:CreateTexture(nil, "OVERLAY", nil, -1)
	edge:SetTexture("Interface/Buttons/UI-Quickslot2")
	edge:SetSize(1.625*ICON_SIZE, 1.625*ICON_SIZE)
	edge:SetPoint("CENTER", f.icon, "CENTER", 0.25, -0.25)
	edge:SetVertexColor(0.5, 0.5, 0.5)
	local mask = f:CreateMaskTexture()
	mask:SetTexture("Interface/FrameGeneral/UIFrameIconMask")
	mask:SetAllPoints(f.icon)
	f.icon:AddMaskTexture(mask)

	-- Toy Box favorite star, riding the icon's top-left corner -- same
	-- texture the Collections Journal stamps on favorites. Shown per-toy
	-- in ColorizeLureToysText --
	f.favorite = f:CreateTexture(nil, "OVERLAY")
	f.favorite:SetTexture("Interface/Common/FavoritesIcon")
	f.favorite:SetSize(18, 18)
	f.favorite:SetPoint("CENTER", f.icon, "TOPLEFT", 3, -3)
	f.favorite:Hide()

	-- Hover highlight only -- no checked glow over the icon; the selected
	-- state is carried entirely by the cell border and background (see
	-- UpdateLureCellSelection) --
	f:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
	f:GetHighlightTexture():SetBlendMode("ADD")
	f:GetHighlightTexture():SetAllPoints(f.icon)

	f.Text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	f.Text:SetNonSpaceWrap(true)
	f.Text:SetHeight(ROW_HEIGHT - 4)
	f.Text:SetJustifyH("LEFT")
	f.Text:SetJustifyV("MIDDLE")
	f.Text:SetPoint("LEFT", ICON_SIZE + 7, 0)
	f.Text:SetPoint("RIGHT", -2, 0)
	f.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)

	f:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetToyByItemID(self.ID)
		GameTooltip:Show()
	end)
	f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	f:SetScript("OnClick", function(self)
		PlayCheckboxSound(self)
		UpdateLureCellSelection(self)
	end)

	return f
end

-- One button per toy [label/icon fill in once BuildToyData resolves that
-- toy's data; positions are assigned in ReflowLureGrid, since search,
-- Favorites-first, and the Uncollected toggle all reorder/hide cells].
-- Each button stays permanently bound to its toy, so its checked state
-- (the rotation membership committed on Okay) survives every reflow.
local rlCheckButtons = {}
local rlButtonByID = {}
for i, id in ipairs(rlToys) do
	rlCheckButtons[i] = CreateToyButton(rlScrollChild, id)
	rlButtonByID[id] = rlCheckButtons[i]
end

--------------------------------------------------------------------
-- Sorted/filtered view over the toy grid [Random Cosplay's grid does
-- the same over the whole collection; here it's just the curated lure
-- list]. rlView is the display order; ReflowLureGrid positions each
-- toy's button per that order, applying the search text and the
-- Uncollected toggle.
--------------------------------------------------------------------
local rlView = {}

-- Owned lures lead, uncollected trail, alphabetical within each group.
-- With Favorites first on, the player's Toy Box favorites (always owned)
-- rise to the very top -- still alphabetical among themselves. Names
-- resolve async, so this re-runs from ColorizeLureToysText as they land.
function RebuildLureView()
	wipe(rlView)
	for _, id in ipairs(rlToys) do
		table.insert(rlView, id)
	end
	local favoritesFirst = rlSettings and rlSettings.favoritesFirst
	table.sort(rlView, function(a, b)
		local oa, ob = PlayerHasToy(a), PlayerHasToy(b)
		if favoritesFirst then
			local fa = oa and C_ToyBox.GetIsFavorite(a) or false
			local fb = ob and C_ToyBox.GetIsFavorite(b) or false
			if fa ~= fb then return fa end
		end
		if oa ~= ob then return oa end
		return (rlToyData[a].name or "") < (rlToyData[b].name or "")
	end)
end

-- Positions the visible cells in rlView order, hiding any that don't
-- match the search text or that are uncollected while the Uncollected
-- toggle is off. Hidden buttons keep their checked/rotation state --
function ReflowLureGrid()
	local query = rlSearchBox:GetText():lower()
	local showUncollected = not (rlSettings and rlSettings.showUncollected == false)
	local shown = 0
	for _, id in ipairs(rlView) do
		local btn = rlButtonByID[id]
		local data = rlToyData[id]
		local owned = PlayerHasToy(id)
		local matchesSearch = query == "" or (data.name and data.name:lower():find(query, 1, true) and true or false)
		if matchesSearch and (owned or showUncollected) then
			local col = shown % COLS
			local row = math.floor(shown / COLS)
			btn:ClearAllPoints()
			btn:SetPoint("TOPLEFT", 2 + col * COL_OFFSET, -(row * ROW_STEP))
			btn:Show()
			shown = shown + 1
		else
			btn:Hide()
		end
	end
	rlScrollChild:SetHeight(math.max(1, math.ceil(shown / COLS) * ROW_STEP))
end

rlSearchBox:SetScript("OnTextChanged", function(self)
	SearchBoxTemplate_OnTextChanged(self)
	ReflowLureGrid()
end)

rlShowUncollectedCheck:SetScript("OnClick", function(self)
	rlSettings.showUncollected = self:GetChecked() and true or false
	ReflowLureGrid()
end)

rlFavoritesFirstCheck:SetScript("OnClick", function(self)
	rlSettings.favoritesFirst = self:GetChecked() and true or false
	RebuildLureView()
	ReflowLureGrid()
end)

-- Select All button
local rlSelectAll = CreateFrame("Button", nil, rlOptionsPanel, "UIPanelButtonTemplate")
rlSelectAll:SetPoint("BOTTOMLEFT", 20, 25)
rlSelectAll:SetSize(100,25)
rlSelectAll:SetText("Select all")
rlSelectAll:SetScript("OnClick", function(self)
	for i = 1, #rlToys do
		rlCheckButtons[i]:SetChecked(true)
		UpdateLureCellSelection(rlCheckButtons[i])
	end
end)

-- Deselect All button
local rlDeselectAll = CreateFrame("Button", nil, rlOptionsPanel, "UIPanelButtonTemplate")
rlDeselectAll:SetPoint("BOTTOMLEFT", 135, 25)
rlDeselectAll:SetSize(100,25)
rlDeselectAll:SetText("Deselect all")
rlDeselectAll:SetScript("OnClick", function(self)
	for i = 1, #rlToys do
		rlCheckButtons[i]:SetChecked(false)
		UpdateLureCellSelection(rlCheckButtons[i])
	end
end)

--------------------------------------------------------------------
-- C_ToyBox.GetIsFavorite (used by the Favorites-first sort) is backed
-- by Blizzard_Collections, which is load-on-demand -- a player who's
-- never opened the Collections Journal this session may not have it
-- loaded yet, leaving every toy reading as unfavorited.
--------------------------------------------------------------------
local function EnsureCollectionsLoaded()
	if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
		C_AddOns.LoadAddOn("Blizzard_Collections")
	end
end

--------------------------------------------------------------------
-- Init/Awake AddonLoaded Msg Handling & Loading
--------------------------------------------------------------------
local rlListener = CreateFrame("Frame")
rlListener:RegisterEvent("ADDON_LOADED")
-- Fires when the collection or a toy's favorite state changes -- keeps
-- the stars and the Favorites-first sort current without waiting for the
-- panel to be reopened --
rlListener:RegisterEvent("TOYS_UPDATED")
rlListener:SetScript("OnEvent", function(self, event, arg1)
	if event == "TOYS_UPDATED" then
		-- Guard: TOYS_UPDATED can arrive before our own ADDON_LOADED has
		-- set up rlSettings/the view. ColorizeLureToysText re-sorts and
		-- reflows (and refreshes each star) once that's in place --
		if rlSettings then
			ColorizeLureToysText()
		end
		return
	end
	if event == "ADDON_LOADED" and arg1 == addon then
		EnsureCollectionsLoaded()
		BuildToyData()

		-- UI preferences [Uncollected toggle + Favorites-first sort],
		-- separate from rlOptions' per-toy rotation state. Uncollected
		-- defaults on, matching the old always-show-everything behavior --
		rlSettings = rlSettings or {}
		if rlSettings.showUncollected == nil then rlSettings.showUncollected = true end
		if rlSettings.favoritesFirst == nil then rlSettings.favoritesFirst = false end

		if rlOptions == nil then
			-- Adds all toy IDs to savedvariables as enabled
			rlOptions = {}
			for i, id in ipairs(rlToys) do
				rlOptions[i] = {id, true}
			end
		else
			-- Deletes toy IDs that no longer exist in rlToys list
			for i,v in pairs(rlOptions) do
				local chk = 0
				for _, id in ipairs(rlToys) do
					if v[1] == id then
						chk = 1
					end
				end
				if chk == 0 then
					rlOptions[i] = nil
				end
			end

			-- Adds any missing toy IDs to savedvariables as enabled
			for _, id in ipairs(rlToys) do
				local chk = 0
				for l = 1, #rlOptions do
					if id == rlOptions[l][1] then
						chk = 1
					end
				end
				if chk == 0 then
					table.insert(rlOptions, {id, true})
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

		-- Paint the gold-border selection onto every cell now that its
		-- checked state is loaded --
		for i = 1, #rlCheckButtons do
			UpdateLureCellSelection(rlCheckButtons[i])
		end

		-- Seed the header toggles, then build the sorted/filtered view --
		rlShowUncollectedCheck:SetChecked(rlSettings.showUncollected == true)
		rlFavoritesFirstCheck:SetChecked(rlSettings.favoritesFirst == true)
		RebuildLureView()
		ReflowLureGrid()

	self:UnregisterEvent("ADDON_LOADED")
	end
end)

--------------------------------------------------------------------
-- Assigned methods to the UI Panel's Confirm/Okay & Cancel [which Option UI updates where all changes are live with confirm, I'm not sure if the Cancel ever gets called. Perhaps in other use cases.
--------------------------------------------------------------------

function RLOptionsOkay()
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

--------------------------------------------------------------------
-- Toys can only be used through a button click, so we create an invisible button for our macro to click.
--  Button creation, named [rlButton]
--------------------------------------------------------------------
local rlBtn = CreateFrame("Button", "rlButton", nil,  "SecureActionButtonTemplate")

-- WoW client events we want to know about --
rlBtn:RegisterEvent("PLAYER_ENTERING_WORLD")
rlBtn:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
rlBtn:RegisterEvent("UNIT_SPELLCAST_FAILED")
rlBtn:RegisterForClicks("LeftButtonDown", "LeftButtonUp" )
rlBtn:SetAttribute("type","toy")

-- Pass in an anonymous function which handles the events --
rlBtn:SetScript("OnEvent", function(self,event, arg1, arg2, arg3)
	if InCombatLockdown() then return end

	if event == "PLAYER_ENTERING_WORLD" then
		RefreshRandomToyPool()
		SelectRandomLureToy()
		-- Unregister from event --
		rlBtn:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
		if IsLureToySpellId(arg3) then
			SelectRandomLureToy()
		end
	elseif event == "UNIT_SPELLCAST_FAILED" and arg1 == "player" then
		if IsLureToySpellId(arg3) then
			WaitThenSetRandomLure()
		end
	end
end)

--------------------------------------------------------------------
-- I added handling "UNIT_SPELLCAST_FAILED" to allow cycleing through lure toys on cooldown.
--   However handling the msg too quickly, caused the character to /say part of the macro.
--    Adding a little wait seemed to fix the problem and it's a more consistent UX.
--------------------------------------------------------------------
function WaitThenSetRandomLure()
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

	ColorizeLureToysText()
end

--------------------------------------------------------------------
-- Resolves one toy's name/icon/spellId from its item data instead of
-- hand-maintained strings (see rlToys/rlToyData above). Loads async
-- since an uncollected toy's item data may not be cached yet.
--------------------------------------------------------------------
function ResolveToyData(id, onLoaded)
	local item = Item:CreateFromItemID(id)
	item:ContinueOnItemLoad(function()
		local data = rlToyData[id]
		data.name = item:GetItemName()
		data.icon = item:GetItemIcon()
		local _, spellId = C_Item.GetItemSpell(id)
		data.spellId = spellId
		if onLoaded then onLoaded(data) end
	end)
end

--------------------------------------------------------------------
-- Kicks off ResolveToyData for every toy in the list -- each toy's
-- row/color updates for itself as its data comes in.
--------------------------------------------------------------------
function BuildToyData()
	for _, id in ipairs(rlToys) do
		ResolveToyData(id, ColorizeLureToysText)
	end
end

--------------------------------------------------------------------
-- Fills in each toy button's icon/name, full color + saturated icon
-- for known/usable toys, greyed out + desaturated icon for unknown
-- ones -- same treatment as Random Cosplay's toy grid.
--------------------------------------------------------------------
function ColorizeLureToysText()
	for i, id in ipairs(rlToys) do
		local data = rlToyData[id]
		if data.name then
			local owned = PlayerHasToy(id)
			local btn = rlButtonByID[id]
			btn.icon:SetTexture(data.icon)
			btn.icon:SetDesaturated(not owned)
			btn.favorite:SetShown(owned and C_ToyBox.GetIsFavorite(id) or false)
			btn.Text:SetText(data.name)
			btn.Text:SetTextColor(owned and 1 or 0.5, owned and 1 or 0.5, owned and 1 or 0.5)

			if rlDebug then
				print("=== " .. data.name .. " : " .. (owned and "Usable!" or "NOT Usable!!"))
			end
		end
	end

	-- Names/ownership/favorites may have just resolved, changing both the
	-- sort order and what the Uncollected filter hides -- reflow to match.
	-- Guarded because this also runs before ADDON_LOADED builds the view --
	if rlSettings then
		RebuildLureView()
		ReflowLureGrid()
	end
end

--------------------------------------------------------------------
-- Set random Lure/Bobber Toy without from a diminishing pool
--------------------------------------------------------------------
function SelectRandomLureToy()
	if rlDebug then
		print("== remainingInPool_OnEnter: " .. #rlList) end

	-- Make sure the poolList is not empty
	if #rlList == 0 then
		RefreshRandomToyPool()
	end

	-- Still no entries?
	if #rlList == 0 then
		-- Go home and /cry
		UpdateLureMacro("Hearthstone","134414")
		return
	end

	-- Get random index, then remove it from the pool right away --
	local rnd = GetRandomIndex(#rlList)
	local id = rlList[rnd]
	table.remove(rlList, rnd)

	local function ApplySelectedToy()
		local data = rlToyData[id]
		-- Update button and macro
		rlBtn:SetAttribute("toy", data.name)
		UpdateLureMacro(data.name, data.icon)

		if rlDebug then
			print("=== Selected: " .. data.name) end
	end

	if rlToyData[id].name then
		ApplySelectedToy()
	else
		-- BuildToyData hasn't resolved this toy's data yet -- load it now --
		ResolveToyData(id, ApplySelectedToy)
	end
end


--------------------------------------------------------------------
-- Gets random index without allowing the same lure toy twice
--   which can happen on pool refresh
--------------------------------------------------------------------
local prevLureItemId = -1
function GetRandomIndex(size)
	if size > 1 then
		local rando = math.random(1,size)
		if rlList[rando] == prevLureItemId then
			if rando == 1 then
				rando = size
			else
				rando = rando - 1
			end
		end

		prevLureItemId = rlList[rando]
		return rando
	end

	if size == 1 then
		prevLureItemId = rlList[1]
		return 1
	end

	return 0		
end

--------------------------------------------------------------------
-- Update/Create the global macro
--------------------------------------------------------------------
function UpdateLureMacro(name,icon)
	if not InCombatLockdown() then
		local macroIndex = GetMacroIndexByName(RLMacroName)
		if macroIndex > 0 then
			EditMacro(macroIndex, RLMacroName, icon, "#showtooltip " .. name .. src)
		else
			CreateMacro(RLMacroName, icon, "#showtooltip " .. name .. src, nil)
		end
	end
end

--------------------------------------------------------------------
-- Create slash commands
--------------------------------------------------------------------
SLASH_RandomLure1 = "/rl"
function SlashCmdList.RandomLure(msg, editbox)
	Settings.OpenToCategory(rlureCategory:GetID())
end

SLASH_RandomLure2 = "/lure"
function SlashCmdList.RandomLure(msg, editbox)
	Settings.OpenToCategory(rlureCategory:GetID())
end
