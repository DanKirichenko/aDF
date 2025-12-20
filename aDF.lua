--########### armor and Debuff Frame
--########### By Atreyyo @ Vanillagaming.org
--########### Forked by Medvedev


local has_superwow = SetAutoloot and true or false

aDF = CreateFrame('Button', "aDF", UIParent); -- Event Frame
aDF.Options = CreateFrame("Frame",nil,UIParent) -- Options frame

--register events 
aDF:RegisterEvent("ADDON_LOADED")
aDF:RegisterEvent("UNIT_AURA")
aDF:RegisterEvent("PLAYER_TARGET_CHANGED")
aDF:RegisterEvent("UNIT_CASTEVENT")
aDF:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
aDF:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
aDF:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE")

function aDF:SendChatMessage(msg,chan)
  if chan and chan ~= "None" and chan ~= "" then
		SendChatMessage(msg,chan)
	end
end

-- tables 
aDF_frames = {} -- we will put all debuff frames in here
aDF_guiframes = {} -- we wil put all gui frames here
gui_Options = gui_Options or {} -- checklist options
gui_Optionsxy = gui_Optionsxy or 1
gui_chantbl = {
	"None",
	"Say",
	"Yell",
	"Party",
	"Raid",
	"Raid_Warning"
 }

local last_target_change_time = GetTime()
local targettype_time = GetTime()

local rowlength = 8		--Defines amount of debuffs shown before we break row

-- translation table for debuff check on target

aDFSpells = {
	["Sunder Armor"] = "Sunder Armor",
	["Armor Shatter"] = "Armor Shatter",
	["Faerie Fire"] = "Faerie Fire",
	["Nightfall"] = "Spell Vulnerability",
	["Flame Buffet"] = "Flame Buffet",
	["Scorch"] = "Fire Vulnerability",
	["Ignite"] = "Ignite",
	["Curse of Recklessness"] = "Curse of Recklessness",
	["Curse of the Elements"] = "Curse of the Elements",
	["Curse of Shadows"] = "Curse of Shadow",
	["Shadow Bolt"] = "Shadow Vulnerability",
	["Shadow Weaving"] = "Shadow Weaving",
	["Expose Armor"] = "Expose Armor",
	["Demoralizing Shout"] = "Demoralizing Shout",
	["Demoralizing Roar"] = "Demoralizing Roar",
	["Thunder Clap"] = "Thunder Clap",
	["Decaying Flesh"] = "Decaying Flesh",
	["Thunderfury"] = "Thunderfury",
	["Feast of Hakkar"] = "Feast of Hakkar"
}
	--["Vampiric Embrace"] = "Vampiric Embrace",
	--["Crystal Yield"] = "Crystal Yield",
	--["Mage T3 6/9 Bonus"] = "Elemental Vulnerability",
-- table with names and textures 


-- One way to find icons: /run Print(GetItemInfo(ITEMID)) in-game. Find ItemID in DB (Check URL)
aDFDebuffs = {
	["Sunder Armor"] = "Interface\\Icons\\Ability_Warrior_Sunder",
	["Armor Shatter"] = "Interface\\Icons\\INV_Axe_12",
	["Faerie Fire"] = "Interface\\Icons\\Spell_Nature_FaerieFire",
	["Nightfall"] = "Interface\\Icons\\Spell_Holy_ElunesGrace",
	["Flame Buffet"] = "Interface\\Icons\\Spell_Fire_Fireball",
	["Scorch"] = "Interface\\Icons\\Spell_Fire_SoulBurn",
	["Ignite"] = "Interface\\Icons\\Spell_Fire_Incinerate",
	["Curse of Recklessness"] = "Interface\\Icons\\Spell_Shadow_UnholyStrength",
	["Curse of the Elements"] = "Interface\\Icons\\Spell_Shadow_ChillTouch",
	["Curse of Shadows"] = "Interface\\Icons\\Spell_Shadow_CurseOfAchimonde",
	["Shadow Bolt"] = "Interface\\Icons\\Spell_Shadow_ShadowBolt",
	["Shadow Weaving"] = "Interface\\Icons\\Spell_Shadow_BlackPlague",
	["Expose Armor"] = "Interface\\Icons\\Ability_Warrior_Riposte",
	["Demoralizing Shout"] = "Interface\\Icons\\Ability_Warrior_WarCry",
	["Demoralizing Roar"] = "Interface\\Icons\\Ability_Druid_DemoralizingRoar",
	["Thunder Clap"] = "Interface\\Icons\\Spell_Nature_ThunderClap",
	["Decaying Flesh"] = "Interface\\Icons\\Spell_Shadow_LifeDrain",
	["Thunderfury"] = "Interface\\Icons\\Spell_Nature_Cyclone",
	["Shar'tateth"] = "Interface\\Icons\\Inv_Demonaxe",
	["Feast of Hakkar"] = "Interface\\Icons\\INV_Chest_Cloth_42",
}
	--["Vampiric Embrace"] = "Interface\\Icons\\Spell_Shadow_UnsummonBuilding",
	--["Crystal Yield"] = "Interface\\Icons\\INV_Misc_Gem_Amethyst_01",
	--["Elemental Vulnerability"] = "Interface\\Icons\\Spell_Holy_Dizzy",

aDFArmorVals = {
	[90]   = "Sunder Armor x1", -- r1 x1
	[180]  = "Sunder Armor",    -- r2 x1, or r1 x2
	[270]  = "Sunder Armor",    -- r3 x1, or r1 x3
	[540]  = "Sunder Armor",    -- r3 x2, or r2 x3
	[810]  = "Sunder Armor x3", -- r3 x3
	[360]  = "Sunder Armor",    -- r4 x1, or r1 x4 or r2 x2
	[720]  = "Sunder Armor",    -- r4 x2, or r2 x4
	[1080] = "Sunder Armor",    -- r4 x3, or r3 x4
	[1440] = "Sunder Armor x4", -- r4 x4
	[450]  = "Sunder Armor",    -- r5 x1, or r1 x5
	[900]  = "Sunder Armor",    -- r5 x2, or r2 x5
	[1350] = "Sunder Armor",    -- r5 x3, or r3 x5
	[1800] = "Sunder Armor",    -- r5 x4, or r4 x5
	[2250] = "Sunder Armor x5", -- r5 x5
--[600]  = "Improved Expose Armor",   -- r1 -- conflicts with anni/rivenspike
--[400]  = "Untalented Expose Armor", -- r1 -- conflicts with anni/rivenspike
-- 	[] = "Improved Expose Armor",  -- 5pt IEA r2 r3 r4 values unknown
	[725]  = "Untalented Expose Armor",
-- 	[] = "Improved Expose Armor",
	[1050] = "Untalented Expose Armor",
-- 	[] = "Improved Expose Armor",
	[1375] = "Untalented Expose Armor",
	[510]  = "Fucked up IEA?",
	[1020] = "Fucked up IEA?",
	[1530] = "Fucked up IEA?",
	[2040] = "Fucked up IEA?",
	[2550] = "Improved Expose Armor",
	[1700] = "Untalented Expose Armor",
	[505]  = "Faerie Fire",
	[395]  = "Faerie Fire R3",
	[285]  = "Faerie Fire R2",
	[175]  = "Faerie Fire R1",
	[640]  = "Curse of Recklessness",
	[465]  = "Curse of Recklessness R3",
	[290]  = "Curse of Recklessness R2",
	[140]  = "Curse of Recklessness R1",
	[600]  = "Annihilator x3 ?", --
	--[400]  = "Annihilator x2 ?", -- Armor Shatter spell=16928, or Puncture Armor r2 spell=17315
	[400] = "Wind Serpent",
	[250] = "Shar'tateth",
	[200]  = "Annihilator x1 ?", --
	[50]   = "Torch of Holy Flame", -- Can also be spell=13526, item=1434 but those conflict FF
	[100]  = "Weapon Proc Faerie Fire", -- non-stacking proc spell=13752, Puncture Armor r1 x1 spell=11791
	[300]  = "Weapon Proc Faerie Fire", -- Dark Iron Sunderer item=11607, Puncture Armor r1 x3
}

aDFAPVals = {
	[146] = "Demoralizing Shout (0/5)",
	[158] = "Demoralizing Shout (1/5)",
	[169] = "Demoralizing Shout (2/5)",
	[181] = "Demoralizing Shout (3/5)",
	[193] = "Demoralizing Shout (4/5)",
	[204] = "Demoralizing Shout (5/5)",
	[138] = "Demoralizing Roar (0/5)",
	[149] = "Demoralizing Roar (1/5)",
	[160] = "Demoralizing Roar (2/5)",
	[171] = "Demoralizing Roar (3/5)",
	[182] = "Demoralizing Roar (4/5)",
	[193] = "Demoralizing Roar (5/5)",
}

function aDF_Default()
	if guiOptions == nil then
		guiOptions = {}
		for k,v in pairs(aDFDebuffs) do
			if guiOptions[k] == nil then
				guiOptions[k] = 1
			end
		end
	end
end

-- the main frame

function aDF:Init()
	aDF.Drag = { }
	function aDF.Drag:StartMoving()
		if ( IsShiftKeyDown() ) then
			this:StartMoving()
		end
	end
	
	function aDF.Drag:StopMovingOrSizing()
		this:StopMovingOrSizing()
		local x, y = this:GetCenter()
		local ux, uy = UIParent:GetCenter()
		aDF_x, aDF_y = floor(x - ux + 0.5), floor(y - uy + 0.5)
	end
	
	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="8",
			edgeSize="8",
			insets={
				left="2",
				right="2",
				top="2",
				bottom="2"
			}
	}
	
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth((24+gui_Optionsxy)*rowlength) -- Set these to whatever height/width is needed 
	self:SetHeight(24+gui_Optionsxy) -- for your Texture
	self:SetPoint("CENTER",aDF_x,aDF_y)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1)
	self:SetScript("OnDragStart", aDF.Drag.StartMoving)
	self:SetScript("OnDragStop", aDF.Drag.StopMovingOrSizing)
	self:SetScript("OnMouseDown", function()
		if (arg1 == "RightButton") then
			if aDF_target ~= nil then
				if UnitAffectingCombat(aDF_target) and UnitCanAttack("player", aDF_target) then	
					aDF:SendChatMessage(UnitName(aDF_target).." has ".. UnitResistance(aDF_target,0).." armor", gui_chan)
				end
			end
		end
	end)
	
	-- Armor text
	self.armor = self:CreateFontString(nil, "OVERLAY")
    self.armor:SetPoint("CENTER", self, "CENTER", 0, 0)
    self.armor:SetFont("Fonts\\FRIZQT__.TTF", 24+gui_Optionsxy)
	self.armor:SetShadowOffset(2,-2)
    self.armor:SetText("aDF")

	-- Resistance text
	self.res = self:CreateFontString(nil, "OVERLAY")
    self.res:SetPoint("CENTER", self, "CENTER", 0, 20+gui_Optionsxy)
    self.res:SetFont("Fonts\\FRIZQT__.TTF", 14+gui_Optionsxy)
	self.res:SetShadowOffset(2,-2)
    self.res:SetText("Resistance")
	
	-- for the debuff check function
	aDF_tooltip = CreateFrame("GAMETOOLTIP", "buffScan")
	aDF_tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
	aDF_tooltipTextL = aDF_tooltip:CreateFontString()
	aDF_tooltipTextR = aDF_tooltip:CreateFontString()
	aDF_tooltip:AddFontStrings(aDF_tooltipTextL,aDF_tooltipTextR)
	--R = tip:CreateFontString()b
	--
	
	f_ =  0
	for name,texture in pairs(aDFDebuffs) do
		
		--FINDME
		--aDF:SendChatMessage(name.."-"..texture, gui_chan)


		aDFsize = 24+gui_Optionsxy
		aDF_frames[name] = aDF_frames[name] or aDF.Create_frame(name)
		local frame = aDF_frames[name]
		frame:SetWidth(aDFsize)
		frame:SetHeight(aDFsize)
		frame:SetPoint("BOTTOMLEFT",aDFsize*f_,-aDFsize)
		frame:SetFrameLevel(2)
		frame.icon:SetTexture(texture)
		frame:Show()
		frame:SetScript("OnEnter", function() 
			GameTooltip:SetOwner(frame, "ANCHOR_BOTTOMRIGHT");
			GameTooltip:SetText(this:GetName(), 255, 255, 0, 1, 1);
			GameTooltip:Show()
			end)
		frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
		frame:SetScript("OnMouseDown", function()
			if (arg1 == "RightButton") then
				tdb=this:GetName()
				if aDF_target ~= nil then
					if UnitAffectingCombat(aDF_target) and UnitCanAttack("player", aDF_target) and guiOptions[tdb] ~= nil then
						if not aDF:GetDebuff(aDF_target,aDFSpells[tdb]) then
							aDF:SendChatMessage("["..tdb.."] is not active on "..UnitName(aDF_target), gui_chan)
						else
							if aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) == 1 then
								s_ = "stack"
							elseif aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) > 1 then
								s_ = "stacks"
							end
							if aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) >= 1 and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) < 5 and tdb ~= "Armor Shatter" then
								aDF:SendChatMessage(UnitName(aDF_target).." has "..aDF:GetDebuff(aDF_target,aDFSpells[tdb],1).." ["..tdb.."] "..s_, gui_chan)
							end
							if tdb == "Armor Shatter" and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) >= 1 and aDF:GetDebuff(aDF_target,aDFSpells[tdb],1) < 3 then
								aDF:SendChatMessage(UnitName(aDF_target).." has "..aDF:GetDebuff(aDF_target,aDFSpells[tdb],1).." ["..tdb.."] "..s_, gui_chan)
							end
						end
					end
				end
			end
		end)
		f_ = f_+1	--iterate "position" in grid: Seems to have NO impact on "frame:SetPoint"
	end
end

-- creates the debuff frames on load (MAIN FRAME)

function aDF.Create_frame(name)
	local frame = CreateFrame('Button', name, aDF)
	frame:SetBackdrop({ bgFile=[[Interface/Tooltips/UI-Tooltip-Background]] })
	frame:SetBackdropColor(0,0,0,1)
	frame.icon = frame:CreateTexture(nil, 'ARTWORK')
	frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
	frame.icon:SetPoint('TOPLEFT', 1, -1)
	frame.icon:SetPoint('BOTTOMRIGHT', -1, 1)
	frame.dur = frame:CreateFontString(nil, "OVERLAY")
	frame.dur:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
	frame.dur:SetFont("Fonts\\FRIZQT__.TTF", 10+gui_Optionsxy)
	frame.dur:SetTextColor(255, 255, 0, 1)
	frame.dur:SetShadowOffset(2,-2)
	frame.dur:SetText("0")
	frame.nr = frame:CreateFontString(nil, "OVERLAY")
	frame.nr:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
	frame.nr:SetFont("Fonts\\FRIZQT__.TTF", 10+gui_Optionsxy)
	frame.nr:SetTextColor(255, 255, 0, 1)
	frame.nr:SetShadowOffset(2,-2)
	frame.nr:SetText("1")
	--DEFAULT_CHAT_FRAME:AddMessage("----- Adding new frame")
	return frame
end

-- creates gui checkboxes

function aDF.Create_guiframe(name)
	local frame = CreateFrame("CheckButton", name, aDF.Options, "UICheckButtonTemplate")
	frame:SetFrameStrata("LOW")
	frame:SetScript("OnClick", function () 
		if frame:GetChecked() == nil then 
			guiOptions[name] = nil
		elseif frame:GetChecked() == 1 then 
			guiOptions[name] = 1 
			table.sort(guiOptions)
		end
		aDF:Sort()
		aDF:Update()
		end)
	frame:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip:SetText(name, 255, 255, 0, 1, 1);
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
	frame:SetChecked(guiOptions[name])
	frame.Icon = frame:CreateTexture(nil, 'ARTWORK')
	frame.Icon:SetTexture(aDFDebuffs[name])
	frame.Icon:SetWidth(25)
	frame.Icon:SetHeight(25)
	frame.Icon:SetPoint("CENTER",-30,0)
	--DEFAULT_CHAT_FRAME:AddMessage("----- Adding new gui checkbox")
	return frame
end

-- update function for the text/debuff frames

local sunderers = {}
local shattered_at = GetTime()
local sundered_at = GetTime()
local thunderclap_at = GetTime()
local anni_stacks_maxed = false

function aDF:Update()
	if aDF_target ~= nil and UnitExists(aDF_target) and not UnitIsDead(aDF_target) then
		if UnitIsUnit(aDF_target,'targettarget') and GetTime() < (last_target_change_time + 1.3) then
			-- we won't allow updates for a while to allow targettarget to catch up
			-- adfprint('target changed too soon, delaying update')
			return
		end
		
		--Checking AP stuff here
		local ap_base, ap_posBuff, ap_negBuff = UnitAttackPower(aDF_target)
		local apcurr = ap_base + ap_posBuff + ap_negBuff	
		if apcurr > (aDF_apprev + 110) then		--An increase of 106 / 110 ?? corresponds to Curse of Recklessness, we want to avoid warning printing a warning for those
			--DEV NOTE: For some unknown reason the AP difference returned from Curse of Recklessness varies by a small amount. 
			local apdiff = apcurr - aDF_apprev
			local ap_diffreason = ""
			if aDF_apprev ~= 0 and aDFAPVals[apdiff] then
				ap_diffreason = " (Dropped " .. aDFAPVals[apdiff] .. ")"
			end
			local msgAP = UnitName(aDF_target).."'s attack power: "..aDF_apprev.." -> "..apcurr..ap_diffreason
			if UnitIsUnit(aDF_target,'target') then	
				-- targettarget does not trigger events when it changes. this means it's hard to tell apart units with the same name, so we don't allow notifications for it
				-- ^ TODO: this isn't true with superwow, we can tell anything apart we like, what is the correct behavior?
				aDF:SendChatMessage(msgAP, gui_chan)
			end
		end
		aDF_apprev = apcurr
		
		--Checking Attack Speed stuff here
		local mainSpeedCurr, offSpeedCurr = UnitAttackSpeed(aDF_target)
		if mainSpeedCurr < aDF_speedprev then
			local speeddiff = aDF_speedprev - mainSpeedCurr
			--aDF:SendChatMessage("Target hits faster now.",gui_chan)
		end
		aDF_speedprev = mainSpeedCurr
		
		
		local armorcurr = UnitResistance(aDF_target,0)
--		aDF.armor:SetText(UnitResistance(aDF_target,0).." ["..math.floor(((UnitResistance(aDF_target,0) / (467.5 * UnitLevel("player") + UnitResistance(aDF_target,0) - 22167.5)) * 100),1).."%]")
		-- aDF.armor:SetText(armorcurr)		--This is standard OnEnter
		aDF.armor:SetText("Armor:"..armorcurr.." AP:"..apcurr)
		-- adfprint(string.format('aDF_target %s targetname %s armorcurr %s armorprev %s', aDF_target, UnitName(aDF_target), armorcurr, aDF_armorprev))
		if armorcurr > aDF_armorprev then
			local armordiff = armorcurr - aDF_armorprev
			local diffreason = ""
			if aDF_armorprev ~= 0 and aDFArmorVals[armordiff] then
				diffreason = " (Dropped " .. aDFArmorVals[armordiff] .. ")"
			end
			local msg = UnitName(aDF_target).."'s armor: "..aDF_armorprev.." --> "..armorcurr..diffreason
			-- adfprint(msg)
			if UnitIsUnit(aDF_target,'target') then
				-- targettarget does not trigger events when it changes. this means it's hard to tell apart units with the same name, so we don't allow notifications for it
				-- ^ TODO: this isn't true with superwow, we can tell anything apart we like, what is the correct behavior?
				aDF:SendChatMessage(msg, gui_chan)
			end

		end
		aDF_armorprev = armorcurr

		-- if gui_Options["Resistances"] == 1 then
		if true then
			aDF.res:SetText("|cffFF0000FR "..UnitResistance(aDF_target,2).." |cff00FF00NR "..UnitResistance(aDF_target,3).." |cff004ED6FrR "..UnitResistance(aDF_target,4).." |cff6E00B8SR "..UnitResistance(aDF_target,5).." |cff00E8E8AR "..UnitResistance(aDF_target,6))
		else
			aDF.res:SetText("")
		end
		for i,v in pairs(guiOptions) do
			if aDF:GetDebuff(aDF_target,aDFSpells[i]) then
				
				
				
						
				aDF_frames[i]["icon"]:SetAlpha(1)
				
				if aDF:GetDebuff(aDF_target,aDFSpells[i],1) > 1 then
					aDF_frames[i]["nr"]:SetText(aDF:GetDebuff(aDF_target,aDFSpells[i],1))
				end
				if i == "Sunder Armor" then
					local elapsed = 30 - (GetTime() - sundered_at)
					aDF_frames[i]["nr"]:SetText(aDF:GetDebuff(aDF_target,aDFSpells[i],1))
					aDF_frames[i]["dur"]:SetText(format("%0.f",elapsed >= 0 and elapsed or 0))
				end
				if i == "Thunder Clap" then
					local elapsed = 30 - (GetTime() - thunderclap_at)
					aDF_frames[i]["dur"]:SetText(format("%0.f",elapsed >= 0 and elapsed or 0))
				end
				if i == "Armor Shatter" then
					local elapsed = 45 - (GetTime() - shattered_at)
					-- can't know anni duration once stacks are maxxed, bump it if it's still up?
					if elapsed < 0 then
						shattered_at = shattered_at + 20
					end
					aDF_frames[i]["nr"]:SetText(aDF:GetDebuff(aDF_target,aDFSpells[i],1))
					aDF_frames[i]["dur"]:SetText(format("%0.f",elapsed >= 0 and elapsed or 0))
				end
			else
				aDF_frames[i]["icon"]:SetAlpha(0.3)
				aDF_frames[i]["nr"]:SetText("")
				aDF_frames[i]["dur"]:SetText("")
			end		
		end
	else
		aDF.armor:SetText("")
		aDF.res:SetText("")
		for i,v in pairs(guiOptions) do		--Causes issues cause looping guiOptions forces us to have a 1:1 mapping
			aDF_frames[i]["icon"]:SetAlpha(0.3)
			aDF_frames[i]["nr"]:SetText("")
			aDF_frames[i]["dur"]:SetText("")
		end
		
	end
end

function aDF:UpdateCheck()
	-- if utimer == nil or (GetTime() - utimer > 0.8) and UnitIsPlayer("target") then
	if utimer == nil or (GetTime() - utimer > 0.3) then
		utimer = GetTime()
		aDF:Update()
	end
end

-- Sort function to show/hide frames aswell as positioning them correctly

function aDF:Sort()
	for name,_ in pairs(aDFDebuffs) do
		if guiOptions[name] == nil then
			aDF_frames[name]:Hide()
		else
			aDF_frames[name]:Show()
		end
	end
	local aDFTempTable = {}
	for dbf,_ in pairs(guiOptions) do
		table.insert(aDFTempTable,dbf)
	end
	table.sort(aDFTempTable, function(a,b) return a<b end)
	for n, v in pairs(aDFTempTable) do
	--DEFAULT_CHAT_FRAME:AddMessage("Name: "..v)
		if v and aDF_frames[v] then
			sizeadjustor = (24+gui_Optionsxy)		--Each placement is a multiple of sizeadjustor, so no icons overlap
			y_=math.ceil(n/rowlength)
			x_=math.mod(n-1,rowlength)
			aDF_frames[v]:SetPoint('BOTTOMLEFT',sizeadjustor*x_,sizeadjustor*y_*-1)
			
		end
	end
end

-- Options frame

function aDF.Options:Gui()

	aDF.Options.Drag = { }
	function aDF.Options.Drag:StartMoving()
		this:StartMoving()
	end
	
	function aDF.Options.Drag:StopMovingOrSizing()
		this:StopMovingOrSizing()
	end

	local backdrop = {
			edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
			bgFile = "Interface/Tooltips/UI-Tooltip-Background",
			tile="false",
			tileSize="4",
			edgeSize="8",
			insets={
				left="2",
				right="2",
				top="2",
				bottom="2"
			}
	}
	
	self:SetFrameStrata("BACKGROUND")
	self:SetWidth(500) -- Set these to whatever height/width is needed 
	self:SetHeight(450) -- for your Texture
	self:SetPoint("CENTER",0,0)
	self:SetMovable(1)
	self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", aDF.Options.Drag.StartMoving)
	self:SetScript("OnDragStop", aDF.Options.Drag.StopMovingOrSizing)
	self:SetBackdrop(backdrop) --border around the frame
	self:SetBackdropColor(0,0,0,1);
	
	-- Options text
	
	self.text = self:CreateFontString(nil, "OVERLAY")
    self.text:SetPoint("CENTER", self, "CENTER", 0, 180)
    self.text:SetFont("Fonts\\FRIZQT__.TTF", 25)
	self.text:SetTextColor(255, 255, 0, 1)
	self.text:SetShadowOffset(2,-2)
    self.text:SetText("Options")
	
	-- mid line
	
	self.left = self:CreateTexture(nil, "BORDER")
	self.left:SetWidth(125)
	self.left:SetHeight(2)
	self.left:SetPoint("CENTER", -62, 160)
	self.left:SetTexture(1, 1, 0, 1)
	self.left:SetGradientAlpha("Horizontal", 0, 0, 0, 0, 102, 102, 102, 0.6)

	self.right = self:CreateTexture(nil, "BORDER")
	self.right:SetWidth(125)
	self.right:SetHeight(2)
	self.right:SetPoint("CENTER", 63, 160)
	self.right:SetTexture(1, 1, 0, 1)
	self.right:SetGradientAlpha("Horizontal", 255, 255, 0, 0.6, 0, 0, 0, 0)
	
	-- slider

	self.Slider = CreateFrame("Slider", "aDF Slider", self, 'OptionsSliderTemplate')
	self.Slider:SetWidth(200)
	self.Slider:SetHeight(20)
	self.Slider:SetPoint("CENTER", self, "CENTER", 0, 140)
	self.Slider:SetMinMaxValues(1, 10)
	self.Slider:SetValue(gui_Optionsxy)
	self.Slider:SetValueStep(1)
	getglobal(self.Slider:GetName() .. 'Low'):SetText('1')
	getglobal(self.Slider:GetName() .. 'High'):SetText('10')
	--getglobal(self.Slider:GetName() .. 'Text'):SetText('Frame size')
	self.Slider:SetScript("OnValueChanged", function() 
		gui_Optionsxy = this:GetValue()
		for _, frame in pairs(aDF_frames) do
			frame:SetWidth(24+gui_Optionsxy)
			frame:SetHeight(24+gui_Optionsxy)
			frame.nr:SetFont("Fonts\\FRIZQT__.TTF", 16+gui_Optionsxy)
		end
		aDF:SetWidth((24+gui_Optionsxy)*rowlength)
		aDF:SetHeight(24+gui_Optionsxy)
		aDF.armor:SetFont("Fonts\\FRIZQT__.TTF", 24+gui_Optionsxy)
		aDF.res:SetFont("Fonts\\FRIZQT__.TTF", 14+gui_Optionsxy)
		aDF.res:SetPoint("CENTER", aDF, "CENTER", 0, 20+gui_Optionsxy)
		aDF:Sort()
	end)
	self.Slider:Show()
	
	-- checkboxes

	local temptable = {}
	for tempn,_ in pairs(aDFDebuffs) do
		table.insert(temptable,tempn)
	end
	table.sort(temptable, function(a,b) return a<b end)
	-- table.insert(temptable,"Resistances")
	
	local x,y=130,-80
	for _,name in pairs(temptable) do
		y=y-40
		if y < -360 then y=-120; x=x+140 end
		--DEFAULT_CHAT_FRAME:AddMessage("Name of frame: "..name.." ypos: "..y)
		aDF_guiframes[name] = aDF_guiframes[name] or aDF.Create_guiframe(name)
		local frame = aDF_guiframes[name]
		frame:SetPoint("TOPLEFT",x,y)
	end	

	-- drop down menu

	self.dropdown = CreateFrame('Button', 'chandropdown', self, 'UIDropDownMenuTemplate')
	self.dropdown:SetPoint("BOTTOM",-60,20)
	InitializeDropdown = function() 
		local info = {}
		for k,v in pairs(gui_chantbl) do
			info = {}
			info.text = v
			info.value = v
			info.func = function()
			UIDropDownMenu_SetSelectedValue(chandropdown, this.value)
			gui_chan = UIDropDownMenu_GetText(chandropdown)
			end
			info.checked = nil
			UIDropDownMenu_AddButton(info, 1)
			if gui_chan == nil then
				UIDropDownMenu_SetSelectedValue(chandropdown, "None")
			else
				UIDropDownMenu_SetSelectedValue(chandropdown, gui_chan)
			end
		end
	end
	UIDropDownMenu_Initialize(chandropdown, InitializeDropdown)
	
	-- -- resistance check
	
	-- self.resistance = aDF.Create_guiframe("Resistances")
	-- self.resistance:SetPoint("BOTTOM",60,20)

	-- done button
	
	self.dbutton = CreateFrame("Button",nil,self,"UIPanelButtonTemplate")
	self.dbutton:SetPoint("BOTTOM",0,10)
	self.dbutton:SetFrameStrata("LOW")
	self.dbutton:SetWidth(79)
	self.dbutton:SetHeight(18)
	self.dbutton:SetText("Done")
	self.dbutton:SetScript("OnClick", function() PlaySound("igMainMenuOptionCheckBoxOn"); aDF:Sort(); aDF:Update(); aDF.Options:Hide() end)
	self:Hide()
end

-- function to check a unit for a certain debuff and/or number of stacks
function aDF:GetDebuff(name,buff,stacks)
	local a=1
	while UnitDebuff(name,a) do
		local _,s,_,id = UnitDebuff(name,a)
		local n = SpellInfo(id)
		-- local _, s = UnitDebuff(name,a)
		-- aDF_tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		-- aDF_tooltip:ClearLines()
		-- aDF_tooltip:SetUnitDebuff(name,a)
		-- local aDFtext = aDF_tooltipTextL:GetText()
		-- if string.find(aDFtext,buff) then 
		if(n=="Faerie Fire (Feral)") then	--Hardcoding Faerie Fire (Feral) to be interpreted as Faerie Fire
			n="Faerie Fire"
		end	
		if buff == n then 
			if stacks == 1 then
				return s
			else
				return true 
			end
		end
		a=a+1
	end

	-- if not found, check buffs in case over the debuff limit
	a=1
	while UnitBuff(name,a) do
		local _,s,id = UnitBuff(name,a)
		local n = SpellInfo(id)
		-- aDF_tooltip:SetOwner(UIParent, "ANCHOR_NONE");
		-- aDF_tooltip:ClearLines()
		-- aDF_tooltip:SetUnitBuff(name,a)
		-- local aDFtext = aDF_tooltipTextL:GetText()
		-- if string.find(aDFtext,buff) then 
		if(n=="Faerie Fire (Feral)") then	--Hardcoding Faerie Fire (Feral) to be interpreted as Faerie Fire
			n="Faerie Fire"
		end	
		if buff == n then 
			if stacks == 1 then
				return s
			else
				return true 
			end
		end
		a=a+1
	end
	return false
end

-- event function, will load the frames we need
function aDF:OnEvent()

	--Troubleshooting
	--print("arg1"..arg1.."/arg2:"..arg2)


	if event == "ADDON_LOADED" and arg1 == "aDF" then
		aDF_Default()
		aDF_target = nil
		aDF_armorprev = 30000
		aDF_apprev = 30000 	--Intial load stuff?
		aDF_speedprev = 0
		aDF_tarnameprev = ""
		if gui_chan == nil then gui_chan = Say end
		aDF:Init() -- loads frame, see the function
		aDF.Options:Gui() -- loads options frame
		aDF:Sort() -- sorts the debuff frames and places them to eachother
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r Loaded",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf show|r to show frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf hide|r to hide frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf options|r for options frame",1,1,1)
  elseif event == "UNIT_AURA" and arg1 == aDF_target then
		-- print("adf update")
		local anni_prev = tonumber(aDF_frames["Armor Shatter"]["nr"]:GetText()) or 0
		aDF:Update()
		local anni = tonumber(aDF_frames["Armor Shatter"]["nr"]:GetText()) or 0
		if anni_prev ~= anni then shattered_at = GetTime() end
		if anni_stacks_maxed and anni < 3 then anni_stacks_maxed = false end
		if not anni_stacks_maxed and anni >= 3 then
			UIErrorsFrame:AddMessage("Annihilator Stacks Maxxed",1,0.1,0.1,1)
			PlaySoundFile("Sound\\Spells\\YarrrrImpact.wav")
			anni_stacks_maxed = true
		end
	elseif event == "UNIT_CASTEVENT" and arg2 == aDF_target then
	-- elseif event == "UNIT_CASTEVENT" then
		-- print(SpellInfo(arg4) .. " " .. arg4)
		local name = SpellInfo(arg4)
		if name == "Sunder Armor" then
			sunderers[UnitName(arg1)] = sundered_at
			local now = GetTime()
			-- print("since sunder: "..now - sundered_at)
			sundered_at = now
		end

	elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then -- self
		local sunder_miss = string.find(arg1,"^Your Sunder Armor") -- (was parried/dodges) or (missed)
		if not sunder_miss then return end
		local n = UnitName("player")
		if sunderers[n] then
			sundered_at = sunderers[n]
			sunderers[n] = nil
		end
		
	elseif event == "CHAT_MSG_SPELL_PARTY_DAMAGE" or event == "CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE" then
		local _,_,n = string.find(arg1,"^(%S+)%s?'s Sunder Armor") -- (was parried) or (missed)
		if not n then return end
		if sunderers[n] then
			sundered_at = sunderers[n]
			sunderers[n] = nil
		end

	elseif event == "PLAYER_TARGET_CHANGED" then
		local aDF_target_old = aDF_target
		aDF_target = nil
		last_target_change_time = GetTime()
		if UnitIsPlayer("target") then
			aDF_target = "targettarget"
		end
		if UnitCanAttack("player", "target") then
			aDF_target = "target"			
		end
		aDF_armorprev = 30000
		aDF_apprev = 30000		--Initializes values to avoid null checks & to ensure comparison always is false before 1st armor/ap calculation
		aDF_speedprev = 0
		if has_superwow then
			_,aDF_target = UnitExists(aDF_target)
		end
		if aDF_target ~= aDF_target_old then
			anni_stacks_maxed = false
		end

		-- adfprint('PLAYER_TARGET_CHANGED ' .. tostring(aDF_target))
		aDF:Update()
		
		
		
		
		
	end
end

-- update and onevent who will trigger the update and event functions

aDF:SetScript("OnEvent", aDF.OnEvent)
aDF:SetScript("OnUpdate", aDF.UpdateCheck)

-- slash commands

function aDF.slash(arg1,arg2,arg3)
	if arg1 == nil or arg1 == "" then
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf show|r to show frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf hide|r to hide frame",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r type |cFFFFFF00 /adf options|r for options frame",1,1,1)
		else
		if arg1 == "show" then
			aDF:Show()
		elseif arg1 == "hide" then
			aDF:Hide()
		elseif arg1 == "options" then
			aDF.Options:Show()
		else
			DEFAULT_CHAT_FRAME:AddMessage(arg1)
			DEFAULT_CHAT_FRAME:AddMessage("|cFFF5F54A aDF:|r unknown command",1,0.3,0.3);
		end
	end
end

SlashCmdList['ADF_SLASH'] = aDF.slash
SLASH_ADF_SLASH1 = '/adf'
SLASH_ADF_SLASH2 = '/ADF'

-- debug

function adfprint(arg1)
	DEFAULT_CHAT_FRAME:AddMessage("|cffCC121D adf debug|r "..arg1)
end
