LegendaryStockTracker = LibStub("AceAddon-3.0"):NewAddon("LegendaryStockTracker", "AceConsole-3.0", "AceEvent-3.0", "AceComm-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("LegendaryStockTracker")
local AceSerializer = LibStub:GetLibrary("AceSerializer-3.0")
local LibSerialize = LibStub("LibSerialize")
local LibDeflate = LibStub("LibDeflate")

-- Set up DataBroker for minimap button
local LstockLDB = LibStub("LibDataBroker-1.1"):NewDataObject("LegendaryStockTracker", {
  type = "data source",
  text = "LegendaryStockTracker",
  label = "LegendaryStockTracker",
  icon = "Interface\\AddOns\\LegendaryStockTracker\\LST_logo",
  OnClick = function()
    if LstockMainFrame and LstockMainFrame:IsShown() then
      LstockMainFrame:Hide()
    else
      LegendaryStockTracker:HandleChatCommand("")
    end
  end,
  OnTooltipShow = function(tt)
	LegendaryStockTracker:GetAllItemsInBags()
    tt:AddLine("Legendary Stock Tracker")
    tt:AddLine(" ")
    tt:AddLine(L["Click or type /lst to show the main panel"])
    tt:AddLine(L["Items Scanned:"])
    tt:AddLine(LegendaryStockTracker:GetDataCounts())
  end
})

local db = nil
local LstockIcon = LibStub("LibDBIcon-1.0")
local LstockMainFrame = nil
local LSTTableScrollChild = nil
local LSTRestockScrollChild = nil

--all collections of items are stored separately for future expandability
local itemLinks = {}
local bagItemLinks = {}
local bagItemCount = 0
local bankItemLinks = {}
local bankItemCount = 0
local isBankOpen = false
local ahItemLinks = {}
local ahItemCount = 0
local mailboxItemLinks = {}
local mailboxItemCount = 0
local GuildBankItemLinks = {}
local GuildBankItemCount = 0
local gearLinks = {}
local legendaryLinks = {}
local TSMPriceDataByRank = {}
local Rank1BonusIDs = "::2:1487:6716"
local Rank2BonusIDs = "::2:1507:6717"
local Rank3BonusIDs = "::2:1522:6718"
local Rank4BonusIDs = "::2:1532:6758"

local LegendaryItemData = 
{
	["171419"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171412"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171414"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171416"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171415"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171417"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171413"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["171418"] = {["profession"] = "plate", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["178927"] = {["profession"] = "jewelry", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["178926"] = {["profession"] = "jewelry", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173248"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173249"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173242"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173245"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173244"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173246"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173241"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173243"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["173247"] = {["profession"] = "cloth", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172321"] = {["profession"] = "leather",	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172316"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172317"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172318"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172319"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172315"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172314"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172320"] = {["profession"] = "leather", 	["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172329"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172324"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172326"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172325"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172327"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172323"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172322"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}},
	["172328"] = {["profession"] = "mail", 		["recipeUnlocked"] = 0, ["stock"] = {0,0,0,0}}
}

local GUILD_BANK_SLOTS_PER_TAB = 98
local IsTSMLoaded = false;
local fontStringPool = nil
local RestockList = {}
local numRanks = 4

local activeTab = nil
local exportTab = nil
local contentFrame = nil
local tabWidth = 150
local tabHeight = 24
local contentWidthOffset = 5
local contentHeightOffset = -25

local playerName = ""
local guildName = ""

function LegendaryStockTracker:OnInitialize()
	-- init databroker
	db = LibStub("AceDB-3.0"):New("LegendaryStockTrackerDB", {
		profile = {
			minimap = {
				hide = false,
			},
			frame = {
				point = "CENTER",
				relativeFrame = nil,
				relativePoint = "CENTER",
				ofsx = 0,
				ofsy = 0,
				width = 760,
				height = 590,
			},
			settings = {
				loadUnownedLegendaries = true,
				showPricing = true,
				includeBags = true,
				includeBank = true,
				includeAH = true,
				includeMail = true,
				IncludeGuild = true,
				minProfit = 5000,
				restockAmount = 3,
				minrestockAmount = 2,
				includeCachedData = true,
				syncTarget = "charactername"
			}
		},
		factionrealm = {
			accountUUID = "",
			characters = {
				['*'] = {
					characterName = "",
					classNameBase = "",
					bagItemLinks = {},
					bagItemCount = 0,
					bankItemLinks = {},
					bankItemCount = 0,
					ahItemLinks = {},
					ahItemCount = 0,
					mailboxItemLinks = {},
					mailboxItemCount = 0,
				}
			},
			guilds = {
				['*'] = {
					guildName = "",
					GuildBankItemLinks = {},
					GuildBankItemCount = 0
				}
			},
			syncData = 
			{

			},
		}
	});

	LstockIcon:Register("LegendaryStockTracker", LstockLDB, db.profile.minimap)
	--chat commands
    LegendaryStockTracker:RegisterChatCommand("lstock", "HandleChatCommand")
    LegendaryStockTracker:RegisterChatCommand("lst", "HandleChatCommand")
    LegendaryStockTracker:RegisterChatCommand("LST", "HandleChatCommand")
    LegendaryStockTracker:RegisterChatCommand("lstocktest", "Test")
    LegendaryStockTracker:RegisterChatCommand("lstSetSize", "SetMainFrameSize")
	LegendaryStockTracker:RegisterChatCommand("lstockscan", "ScanAhPrices")
	--events
	LegendaryStockTracker:RegisterEvent("BANKFRAME_OPENED", "GetAllItemsInBank")
	LegendaryStockTracker:RegisterEvent("OWNED_AUCTIONS_UPDATED", "GetAllItemsInAH")
	LegendaryStockTracker:RegisterEvent("MAIL_INBOX_UPDATE", "GetAllItemsInMailbox")
	LegendaryStockTracker:RegisterEvent("MAIL_CLOSED", "GetAllItemsInMailbox")
	LegendaryStockTracker:RegisterEvent("GUILDBANKFRAME_CLOSED", "GetAllItemsInGuildBank")
	LegendaryStockTracker:RegisterEvent("GUILDBANKFRAME_OPENED", "GetAllItemsInGuildBank")
	LegendaryStockTracker:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", "OnItemAdded")
	LegendaryStockTracker:RegisterEvent("GET_ITEM_INFO_RECEIVED", "OnItemInfoReceived")

	self:RegisterComm("LST")

	LegendaryStockTracker:CheckIfTSMIsRunning()
	playerName = UnitName("player")
	--guildName = select(1,GetGuildInfo("player")); --doesn't work on login, only on reloads
	db.factionrealm.characters[playerName].characterName = playerName;
	db.factionrealm.characters[playerName].classNameBase = select(1,UnitClassBase("player"));
	LegendaryStockTracker:GetAllItemsInBags();
	local item = {};
	for id,data in pairs(LegendaryItemData) do
		local iteminfo = GetItemInfo(id);
		if(iteminfo ~= nil ) then
			LegendaryStockTracker:ProcessItemInfo(id, true)
		end
	end
	if(db.factionrealm.accountUUID == nil or db.factionrealm.accountUUID == "") then
		db.factionrealm.accountUUID = LegendaryStockTracker:GenerateUUID();
	end
end

function tst()
	return "test"
end

function LegendaryStockTracker:ProcessItemInfo(itemID, success)
	if(LegendaryItemData[itemID] ~= nil) then
		local itemName, itemLink, _, _, _, _, _, _, _, itemTexture, _, _, _, _, _, _, _ = GetItemInfo(itemID);
		LegendaryItemData[itemID]["name"] = itemName;
		LegendaryItemData[itemID]["itemLink"] = itemLink;
		LegendaryItemData[itemID]["icon"] = itemTexture;
	end
end

function LegendaryStockTracker:OnItemInfoReceived(event, itemID, success)
	if(success == true) then
		LegendaryStockTracker:ProcessItemInfo(tostring(tonumber(itemID)), success);
	end
end


function LegendaryStockTracker:Test()
	numSlots, full = GetNumBankSlots();
	print(numSlots)
	--LegendaryStockTracker:SendDataToPlayer("Talyma-Silvermoon");
end

function LegendaryStockTracker:SetMainFrameSize(value1, value2)
	--db.profile.frame.width = value1
	--db.profile.frame.height = value2
	--local f = LegendaryStockTracker:GetMainFrame()
	--f:SetSize(tonumber(value1), tonumber(value2))
end

function LegendaryStockTracker:GetDataCounts()
	local text = ""
	if(db.profile.settings.includeCachedData) then
		text = text .. L["Bags: "] .. LegendaryStockTracker:GetItemCounts("bagItemCount") .. "\n"
		text = text .. L["Bank: "] .. LegendaryStockTracker:GetItemCounts("bankItemCount") .. "\n"
		text = text .. L["AH: "] .. LegendaryStockTracker:GetItemCounts("ahItemCount") .. "\n"
		text = text .. L["Mail: "] .. LegendaryStockTracker:GetItemCounts("mailboxItemCount") .. "\n"
		local sum = 0
		local count = 0
		local altString = " ("
		for key,val in pairs(db.factionrealm.guilds) do
			sum = sum + db.factionrealm.guilds[key]["GuildBankItemCount"];
			altString = altString .. db.factionrealm.guilds[key]["GuildBankItemCount"] .. " ";
			count = count + 1;
		end
		altString = altString:sub(1, #altString - 1);
		altString = altString .. ")";
		if(count == 0) then
			altString = "";
		end

		text = text .. L["Guild: "] .. sum .. altString .. "\n"
	else
		text = text .. L["Bags: "] .. bagItemCount .. "\n"
		text = text .. L["Bank: "] .. bankItemCount .. "\n"
		text = text .. L["AH: "] .. ahItemCount .. "\n"
		text = text .. L["Mail: "] .. mailboxItemCount .. "\n"
		text = text .. L["Guild: "] .. GuildBankItemCount .. "\n"
	end
	return text
end

function LegendaryStockTracker:GetItemCounts(itemCountParameterName)
	local sum = 0
	local altString = " ("
	local count = 0
	local classColorEsc = ""
	for key,val in pairs(db.factionrealm.characters) do
		sum = sum + db.factionrealm.characters[key][itemCountParameterName];
		if(db.factionrealm.characters[key].classNameBase ~= nil and db.factionrealm.characters[key].classNameBase ~= "") then
			classColorEsc = "|c" .. C_ClassColor.GetClassColor(db.factionrealm.characters[key].classNameBase):GenerateHexColor();
		else
			classColorEsc = "";
		end
		altString = altString .. classColorEsc .. db.factionrealm.characters[key][itemCountParameterName] .. "|r ";
		count = count + 1;
	end
	altString = altString:sub(1, #altString - 1);
	altString = altString .. ")";
	if(count == 0) then
		altString = "";
	end
	return sum .. altString;
end

function LegendaryStockTracker:HandleChatCommand(input)
	local f = LegendaryStockTracker:GetMainFrame(UIParent)
	LegendaryStockTracker:UpdateExportText()
	LegendaryStockTracker:UpdateTable()
	f:Show()
end

function LegendaryStockTracker:UpdateExportText()
	LegendaryStockTracker:UpdateAllAvailableItemSources()
	LegendaryStockTracker:GetLegendariesFromItems()
	--LegendaryStockTracker:GetMainFrame(UIParent)
	LSTEditBox:SetText(LegendaryStockTracker:GenerateExportText())
	LSTEditBox:HighlightText()
end

function LegendaryStockTracker:UpdateTable()
	LegendaryStockTracker:UpdateAllAvailableItemSources()
	LegendaryStockTracker:GetLegendariesFromItems()
	LegendaryStockTracker:CreateTableSheet(LSTTableScrollChild)
	--LegendaryStockTracker:CreateFrameSheet(LstockMainFrame)
end

function LegendaryStockTracker:UpdateRestock()
	LegendaryStockTracker:UpdateAllAvailableItemSources()
	LegendaryStockTracker:GetLegendariesFromItems()
	LegendaryStockTracker:CreateRestockSheet(LSTRestockScrollChild)
end

function LegendaryStockTracker:UpdateAllAvailableItemSources()
	LegendaryStockTracker:GetAllItemsInAH()
	LegendaryStockTracker:GetAllItemsInBags()
	LegendaryStockTracker:GetAllItemsInBank() --if the bank is open at the time of command, update bank as well
	--LegendaryStockTracker:GetAllItemsInAH() auctions specifically not updated on command, as we don't know if the ah is closed or the player has no auctions. relying on OWNED_AUCTIONS_UPDATED to update those.
	--LegendaryStockTracker:GetAllItemsInMailbox() mailbox is updated anytime the mailbox is updated, no need to update on command 
	--LegendaryStockTracker:GetAllItemsInGuildBank()
end

function LegendaryStockTracker:GetLegendariesFromItems()
	LegendaryStockTracker:CheckIfTSMIsRunning()
	LegendaryStockTracker:AddAllItemsToList()
	LegendaryStockTracker:GetGearFromItems()
	LegendaryStockTracker:GetShadowlandsLegendariesFromGear()
	LegendaryStockTracker:CountLegendariesByRank()
end

function LegendaryStockTracker:ShowTestFrame()
	local f = LegendaryStockTracker:GetMainFrame(UIParent)
	f:Show()
end

function LegendaryStockTracker:GetMainFrame(parent)
	if not LstockMainFrame then
		local mainFrameWidth = tonumber(db.profile.frame.width)
		local mainFrameHeight = tonumber(db.profile.frame.height)
		if(mainFrameWidth == nil) then
			mainFrameWidth = 760
		end
		if(mainFrameHeight == nil) then
			mainFrameHeight = 590
		end
		local Backdrop = {
			bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
			--edgeFile = temp,
			tile = false, tileSize = 0, edgeSize = 1,
			insets = {left = 1, right = 1, top = 1, bottom = 1},
		}
		local frameConfig = db.profile.frame
		local f = CreateFrame("Frame","LSTMainFrame",parent, BackdropTemplateMixin and "BackdropTemplate")
		LstockMainFrame = f
		f:SetBackdrop(Backdrop)
		f:SetBackdropColor(0.03,0.03,0.03,0.9)
		f:SetSize(mainFrameWidth, mainFrameHeight )
		f:SetFrameStrata("HIGH")
		f:SetToplevel(true)
		f:SetClampedToScreen(true)
		f:SetPoint(
		frameConfig.point,
		frameConfig.relativeFrame,
		frameConfig.relativePoint,
		frameConfig.ofsx,
		frameConfig.ofsy
		)
		tinsert(UISpecialFrames, f:GetName())
		LegendaryStockTracker:SetFrameMovable(f)

		local tabList = CreateFrame("Frame","LSTTabList",f)
		tabList:SetPoint("TOPLEFT", LstockMainFrame, "TOPLEFT",0,-5)
		tabList:SetPoint("BOTTOMRIGHT", LstockMainFrame, "BOTTOMLEFT",tabWidth,0)

		contentFrame = CreateFrame("Frame","LSTContentFrame",f, BackdropTemplateMixin and "BackdropTemplate")
		contentFrame:SetPoint("TOPLEFT", LstockMainFrame, "TOPLEFT",tabWidth,0)
		contentFrame:SetPoint("BOTTOMRIGHT", LstockMainFrame, "BOTTOMRIGHT")

		--divider lines
		local line = tabList:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPRIGHT",0,4)
		line:SetEndPoint("BOTTOMRIGHT",0,1)

		line= contentFrame:CreateLine()
		line:SetThickness(1)
		line:SetColorTexture(0.6,0.6,0.6,1)
		line:SetStartPoint("TOPLEFT",0,-20)
		line:SetEndPoint("TOPRIGHT",-2,-20)

		--Export Frame
		local exportFrame = LegendaryStockTracker:CreateOptionsContentFrame("LSTExportFrame", contentFrame, Backdrop)
		--exportFrame:SetBackdropColor(0.75,0,0,0.9)
		exportFrame.title:SetText(L["Paste this data into your copy of the spreadsheet"])
		exportFrame:SetScript("OnShow", function()
			LegendaryStockTracker:UpdateExportText()
		end)

		-- scroll frame
		local sf = CreateFrame("ScrollFrame", "LSTScrollFrame", exportFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT")
		sf:SetPoint("RIGHT", -22, 0)
		sf:SetPoint("TOP")
		sf:SetPoint("BOTTOM")
		
		-- edit box
		local eb = CreateFrame("EditBox", "LSTEditBox", LstockScrollFrame)
		eb:SetSize(sf:GetSize())
		eb:SetMultiLine(true)
		eb:SetAutoFocus(true)
		eb:SetFontObject("ChatFontNormal")
		eb:SetScript("OnEscapePressed", function() f:Hide() end)
		sf:SetScrollChild(eb)

		-- resizing
		f:SetResizable(true)
		f:SetMinResize(400, 350)
		local rb = CreateFrame("Button", "LSTResizeButton", f)
		rb:SetPoint("BOTTOMRIGHT", -6, 7)
		rb:SetSize(16, 16)
		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

		rb:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				f:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- more noticeable
			end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
			f:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			contentFrame:SetSize(f:GetWidth() - tabWidth, f:GetHeight())
			-- save size between sessions
			frameConfig.width = f:GetWidth()
			frameConfig.height = f:GetHeight()
		end)
		
		--settings frame
		local settingsFrame = LegendaryStockTracker:CreateOptionsContentFrame("LSTsettingsFrame", contentFrame, Backdrop)
		--settingsFrame:SetBackdropColor(0,0.75,0,0.9)
		settingsFrame.title:SetText(L["Settings"])

		settingsFrame.scrollframe = settingsFrame.scrollframe or CreateFrame("ScrollFrame", "LSTSettingsScrollFrame", settingsFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		settingsFrame.scrollframe:SetPoint("LEFT")
		settingsFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		settingsFrame.scrollframe:SetPoint("TOP")
		settingsFrame.scrollframe:SetPoint("BOTTOM")

		local LSTSettingsScrollChild = settingsFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTSettingsScrollChild", settingsFrame.scrollframe);
		LSTSettingsScrollChild:SetSize(settingsFrame.scrollframe:GetSize())
		settingsFrame.scrollframe:SetScrollChild(LSTSettingsScrollChild)

		--settings options
		local heightOffset = 0
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("ShowUnownedItemsCheckButton", LSTSettingsScrollChild, "loadUnownedLegendaries", L["Show all legendaries"], heightOffset)
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("ShowPricingCheckButton", LSTSettingsScrollChild, "showPricing", L["Show profit (requires TSM operations)"], heightOffset)
		heightOffset = LegendaryStockTracker:AddOptionEditbox("MinProfitEditBox", LSTSettingsScrollChild, "minProfit", L["Min profit before restocking"], heightOffset, 45)
		heightOffset = LegendaryStockTracker:AddOptionEditbox("RestockAmountEditBox", LSTSettingsScrollChild, "restockAmount", L["Restock amount"], heightOffset, 25)
		heightOffset = LegendaryStockTracker:AddOptionEditbox("MinRestockAmountEditBox", LSTSettingsScrollChild, "minrestockAmount", L["Min restock amount"], heightOffset, 25)
		heightOffset = heightOffset - 25
		local text = LSTSettingsScrollChild:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
		text:SetPoint("TOPLEFT", LSTSettingsScrollChild, "TOPLEFT", 0, heightOffset)
		text:SetText(L["Sources to include:"])
		heightOffset = heightOffset - 15
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("IncludeBagsCheckButton", LSTSettingsScrollChild, "includeBags", L["Include Bags"], heightOffset)
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("IncludeBankCheckButton", LSTSettingsScrollChild, "includeBank", L["Include Bank"], heightOffset)
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("IncludeAHCheckButton", LSTSettingsScrollChild, "includeAH", L["Include AH"], heightOffset)
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("IncludeMailCheckButton", LSTSettingsScrollChild, "includeMail", L["Include Mail"], heightOffset)
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("IncludeGuildCheckButton", LSTSettingsScrollChild, "IncludeGuild", L["Include Guild Bank"], heightOffset)
		heightOffset = LegendaryStockTracker:AddOptionCheckbox("includeCacheCheckButton", LSTSettingsScrollChild, "includeCachedData", L["Include Cached items"], heightOffset)
		heightOffset = heightOffset - 25
		local syncEB = nil;
		local syncText = nil;
		heightOffset, syncEB, syncText = LegendaryStockTracker:AddOptionEditbox("syncTargetEditBox", LSTSettingsScrollChild, "syncTarget", L["Send data to this alt"], heightOffset, 100)

		local syncButton = CreateFrame("Button", "LSTSendDataButton", LSTSettingsScrollChild, BackdropTemplateMixin and "BackdropTemplate");
		Backdrop = {
			bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
			edgeFile = "Interface/Buttons/WHITE8X8",
			tile = true, tileSize = 0, edgeSize = 1,
			insets = {left = 0, right = 0, top = 0, bottom = 0},
		}
		syncButton:SetBackdrop(Backdrop)
		syncButton:SetBackdropColor(0.25,0.25,0.25,0.9)
		syncButton:SetBackdropBorderColor(0,0,0,1)
		syncButton:SetSize(200,24)
		syncButton.HighlightTexture = syncButton:CreateTexture()
		syncButton.HighlightTexture:SetColorTexture(1,1,1,.3)
		syncButton.HighlightTexture:SetPoint("TOPLEFT")
		syncButton.HighlightTexture:SetPoint("BOTTOMRIGHT")
		syncButton:SetHighlightTexture(syncButton.HighlightTexture)
		syncButton.PushedTexture = syncButton:CreateTexture()
		syncButton.PushedTexture:SetColorTexture(.9,.8,.1,.3)
		syncButton.PushedTexture:SetPoint("TOPLEFT")
		syncButton.PushedTexture:SetPoint("BOTTOMRIGHT")
		syncButton:SetPushedTexture(syncButton.PushedTexture)
		local padding = 4;
		local xOffset = 0;
		syncButton:SetPoint("TOPLEFT", syncText, "TOPLEFT", -padding + xOffset, padding + 2);
		syncButton:SetPoint("BOTTOMRIGHT", syncText, "BOTTOMRIGHT", padding + xOffset, -padding);
		syncText:SetParent(syncButton);
		syncButton:SetScript("OnClick", function(self) LegendaryStockTracker:SendDataToSyncTarget() end)

		--table frame
		local tableFrame = LegendaryStockTracker:CreateOptionsContentFrame("LSTtableFrame", contentFrame, BackdropTemplateMixin and "BackdropTemplate")
		--tableFrame:SetBackdrop(Backdrop)
		--tableFrame:SetBackdropColor(0,0,1,0.9)
		tableFrame.title:SetText(L["Table"])
		tableFrame:SetScript("OnShow", function()
			LegendaryStockTracker:UpdateTable()
		end)
		tableFrame.scrollframe = tableFrame.scrollframe or CreateFrame("ScrollFrame", "LSTTableScrollFrame", tableFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		tableFrame.scrollframe:SetPoint("LEFT")
		tableFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		tableFrame.scrollframe:SetPoint("TOP")
		tableFrame.scrollframe:SetPoint("BOTTOM")

		LSTTableScrollChild = tableFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTtableScrollChild", tableFrame.scrollframe);
		LSTTableScrollChild:SetSize(tableFrame.scrollframe:GetSize())
		tableFrame.scrollframe:SetScrollChild(LSTTableScrollChild)

		--Restock frame
		local restockFrame = LegendaryStockTracker:CreateOptionsContentFrame("LSTRestockFrame", contentFrame, Backdrop)
		restockFrame.title:SetText(L["Restock"])
		restockFrame:SetScript("OnShow", function()
			LegendaryStockTracker:UpdateRestock()
		end)
		restockFrame.scrollframe = restockFrame.scrollframe or CreateFrame("ScrollFrame", "LSTRestockScrollFrame", restockFrame, BackdropTemplateMixin and "UIPanelScrollFrameTemplate");
		restockFrame.scrollframe:SetPoint("LEFT")
		restockFrame.scrollframe:SetPoint("RIGHT", -22, 0)
		restockFrame.scrollframe:SetPoint("TOP")
		restockFrame.scrollframe:SetPoint("BOTTOM")

		LSTRestockScrollChild = restockFrame.scrollframe.scrollchild or CreateFrame("Frame", "LSTRestockScrollChild", restockFrame.scrollframe);
		LSTRestockScrollChild:SetSize(restockFrame.scrollframe:GetSize())
		restockFrame.scrollframe:SetScrollChild(LSTRestockScrollChild)

		--create tabs
		exportTab = LegendaryStockTracker:AddTab(tabList, tabWidth, 24, 3, exportFrame, L["Export"])
		LegendaryStockTracker:AddTab(tabList, tabWidth, 24, 2, settingsFrame, L["Settings"])
		local tab = LegendaryStockTracker:AddTab(tabList, tabWidth, 24, 1, tableFrame, L["Table"])
		LegendaryStockTracker:AddTab(tabList, tabWidth, 24, 4, restockFrame, L["Restock"])
		LegendaryStockTracker:TabOnClick(tab)

		local closeButton = CreateFrame("Button", "LSTMainFrameCloseButton", f)
		closeButton:SetSize(20,20)
		closeButton:SetText("X")
		closeButton:SetPoint("TOPRIGHT", f, "TOPRIGHT")
		closeButton:SetNormalFontObject("GameFontHighlight")
		closeButton:SetHighlightFontObject("GameFontHighlight")
		closeButton:SetDisabledFontObject("GameFontDisable")
		closeButton:SetScript("OnClick", function()
			LstockMainFrame:Hide()
		end)
	end
	return LstockMainFrame
end

function LegendaryStockTracker:SetFrameMovable(f)
	local frameConfig = db.profile.frame
	f:EnableMouse(true)
	f:SetMovable(true)
	f:SetScript("OnMouseDown", function(self, button)
		if button == "LeftButton" then
		self:StartMoving()
		end
	end)
	f:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing()
	-- save position between sessions
	point, relativeFrame, relativeTo, ofsx, ofsy = self:GetPoint()
	frameConfig.point = point
	frameConfig.relativeFrame = relativeFrame
	frameConfig.relativePoint = relativeTo
	frameConfig.ofsx = ofsx
	frameConfig.ofsy = ofsy
	end)
end

function LegendaryStockTracker:TabOnClick(self)
	if(activeTab ~= nil) then
		activeTab.content:Hide()
	end
	activeTab = self
	self.content:Show()
end

function LegendaryStockTracker:AddTab(parent, width, height, index, content, text)

	local b = CreateFrame("Button", "Tab" .. index, parent)
	b:SetSize(width,24)
	b:SetText(text)
	b:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(index - 1) * height)
	b.HighlightTexture = b:CreateTexture()
	b.HighlightTexture:SetColorTexture(1,1,1,.3)
	b.HighlightTexture:SetPoint("TOPLEFT")
	b.HighlightTexture:SetPoint("BOTTOMRIGHT")
	b:SetHighlightTexture(b.HighlightTexture)
	b.PushedTexture = b:CreateTexture()
	b.PushedTexture:SetColorTexture(.9,.8,.1,.3)
	b.PushedTexture:SetPoint("TOPLEFT")
	b.PushedTexture:SetPoint("BOTTOMRIGHT")
	b:SetPushedTexture(b.PushedTexture)
	--b:SetNormalFontObject("GameFontNormal")
	b:SetNormalFontObject("GameFontHighlight")
	b:SetHighlightFontObject("GameFontHighlight")
	b:SetDisabledFontObject("GameFontDisable")
	b:SetScript("OnClick", function(self)
		LegendaryStockTracker:TabOnClick(self)
	end)
	b.content = content
	b.content:Hide()
	return b
end

function LegendaryStockTracker:CreateOptionsContentFrame(name, parent, backdrop)
	local f = CreateFrame("Frame",name,parent, BackdropTemplateMixin and "BackdropTemplate")
	--f:SetBackdrop(backdrop)
	--f:SetBackdropColor(0.03,0.03,0.03,0.9)
	f:SetPoint("TOPLEFT", parent, "TOPLEFT", contentWidthOffset, contentHeightOffset)
	f:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -contentWidthOffset, -contentHeightOffset)

	f.title = f:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	f.title:SetPoint("BottomLeft",f, "TOPLEFT", 0, 8)
	return f
end

function LegendaryStockTracker:AddOptionCheckbox(name, parent, setting, description, heightOffset)
	local cb = CreateFrame("CheckButton", name, parent, "OptionsCheckButtonTemplate")
	cb:SetSize(20,20)
	cb:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, heightOffset)
	cb.setting = setting
	cb:SetChecked(db.profile.settings[cb.setting])
	cb:SetScript("OnClick", function(cb)
		if cb:GetChecked() then
			db.profile.settings[cb.setting] = true
		else
			db.profile.settings[cb.setting] = false
		end
	end)
	local text = cb:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("LEFT", cb, "RIGHT", 0, 1)
	text:SetText(description)
	return heightOffset - 20
end

function LegendaryStockTracker:AddOptionEditbox(name, parent, setting, description, heightOffset, width)
	local Backdrop = {
		bgFile = "Interface\\AddOns\\LegendaryStockTracker\\Assets\\Plain.tga",
		edgeFile = "Interface/Buttons/WHITE8X8",
		tile = false, tileSize = 0, edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	}

	local eb = CreateFrame("EditBox", name, parent, BackdropTemplateMixin and "BackdropTemplate")
	eb:SetAutoFocus(false)
	eb:SetBackdrop(Backdrop)
	eb:SetBackdropColor(0.25,0.25,0.25,0.9)
	eb:SetBackdropBorderColor(0,0,0,1)
	eb:SetSize(width,22)
	eb:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, heightOffset)
	eb:SetFontObject("GameFontNormal")
	eb:SetTextColor(1,1,1,1)
	eb.setting = setting
	eb:SetText(db.profile.settings[eb.setting])
	eb:SetScript("OnTextChanged", function(self)
		db.profile.settings[eb.setting] = self:GetText()
	end)

	eb:SetScript("OnEscapePressed", function()
		eb:ClearFocus()
	end)

	local text = eb:CreateFontString(nil,"ARTWORK", "GameFontHighlight") 
	text:SetPoint("LEFT", eb, "RIGHT", 6, -1)
	text:SetText(description)
	return heightOffset - 25, eb, text
end

function LegendaryStockTracker:OnEnable()

end

function LegendaryStockTracker:OnDisable()

end

function LegendaryStockTracker:GetAllItemsInBags()
	bagItemLinks = {}
	bagItemCount = 0
	db.factionrealm.characters[playerName].bagItemLinks = {}
	db.factionrealm.characters[playerName].bagItemCount = 0
    for bag=0,NUM_BAG_SLOTS do
        for slot=1,GetContainerNumSlots(bag) do
			if not (GetContainerItemID(bag,slot) == nil) then 
				bagItemLinks[#bagItemLinks+1] = (select(7,GetContainerItemInfo(bag,slot)));
				bagItemCount = bagItemCount + 1;
				db.factionrealm.characters[playerName].bagItemLinks[#db.factionrealm.characters[playerName].bagItemLinks + 1] = (select(7,GetContainerItemInfo(bag,slot)));
				db.factionrealm.characters[playerName].bagItemCount = db.factionrealm.characters[playerName].bagItemCount + 1;
			end
        end
	end
end

function LegendaryStockTracker:GetAllItemsInBank(event)
	if(event ~= nil) then
		if(event == "BANKFRAME_OPENED") then
			LegendaryStockTracker:RegisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank");
			isBankOpen = true;
		elseif(event == "BANKFRAME_CLOSED") then
			LegendaryStockTracker:UnregisterEvent("BANKFRAME_CLOSED", "GetAllItemsInBank");
			isBankOpen = false;
		end
	end

	if(isBankOpen == true) then
		bankItemLinks = {}
		bankItemCount = 0
		db.factionrealm.characters[playerName].bankItemLinks = {}
		db.factionrealm.characters[playerName].bankItemCount = 0
		--go through all bank bag slots
		for bag=NUM_BAG_SLOTS+1,NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			for slot=1,GetContainerNumSlots(bag) do
				if not (GetContainerItemID(bag,slot) == nil) then 
					bankItemLinks[#bankItemLinks+1] = (select(7,GetContainerItemInfo(bag,slot)));
					bankItemCount = bankItemCount + 1;
					db.factionrealm.characters[playerName].bankItemLinks[#db.factionrealm.characters[playerName].bankItemLinks + 1] = (select(7,GetContainerItemInfo(bag,slot)));
					db.factionrealm.characters[playerName].bankItemCount = db.factionrealm.characters[playerName].bankItemCount + 1;
				end
			end
		end
		--go through default 28 bank spaces
		for slot=1,GetContainerNumSlots(-1) do
			if not (GetContainerItemID(-1,slot) == nil) then 
				bankItemLinks[#bankItemLinks+1] = (select(7,GetContainerItemInfo(-1,slot)));
				bankItemCount = bankItemCount + 1;
				db.factionrealm.characters[playerName].bankItemLinks[#db.factionrealm.characters[playerName].bankItemLinks + 1] = (select(7,GetContainerItemInfo(-1,slot)));
				db.factionrealm.characters[playerName].bankItemCount = db.factionrealm.characters[playerName].bankItemCount + 1;
			end
		end
	end
end

function LegendaryStockTracker:GetAllItemsInAH()
	if(C_AuctionHouse.GetNumOwnedAuctions() ~= 0) then
		ahItemLinks = {}
		ahItemCount = 0
		db.factionrealm.characters[playerName].ahItemLinks = {}
		db.factionrealm.characters[playerName].ahItemCount = 0
		local numOwnedAuctions = C_AuctionHouse.GetNumOwnedAuctions()
		for i=1, numOwnedAuctions do
			local auctionInfo = C_AuctionHouse.GetOwnedAuctionInfo(i)
			if(auctionInfo.status == 0) then 
				ahItemLinks[#ahItemLinks+1] = auctionInfo.itemLink;
				ahItemCount = ahItemCount + 1;
				db.factionrealm.characters[playerName].ahItemLinks[#db.factionrealm.characters[playerName].ahItemLinks + 1] = auctionInfo.itemLink;
				db.factionrealm.characters[playerName].ahItemCount = db.factionrealm.characters[playerName].ahItemCount + 1;
			end
		end
	end
end

function LegendaryStockTracker:GetAllItemsInMailbox()
	mailboxItemLinks = {}
	mailboxItemCount = 0
	db.factionrealm.characters[playerName].mailboxItemLinks = {}
	db.factionrealm.characters[playerName].mailboxItemCount = 0
	for i=1, GetInboxNumItems() do
		for j=1,ATTACHMENTS_MAX_RECEIVE do 
			if(GetInboxItemLink(i, j) ~= nil) then
				mailboxItemLinks[#mailboxItemLinks+1] = GetInboxItemLink(i, j);
				mailboxItemCount = mailboxItemCount + 1;
				db.factionrealm.characters[playerName].mailboxItemLinks[#db.factionrealm.characters[playerName].mailboxItemLinks + 1] = GetInboxItemLink(i, j);
				db.factionrealm.characters[playerName].mailboxItemCount = db.factionrealm.characters[playerName].mailboxItemCount + 1;
			end
		end
	end
end

function LegendaryStockTracker:GetAllItemsInGuildBank()
	local guildBankTabCount = GetNumGuildBankTabs()
	guildName = select(1,GetGuildInfo("player"));
	if(guildBankTabCount > 0 and GetGuildBankTabInfo(1) ~= nil) then
		GuildBankItemLinks = {}
		GuildBankItemCount = 0
		db.factionrealm.guilds[guildName].GuildBankItemLinks = {}
		db.factionrealm.guilds[guildName].GuildBankItemCount = 0
		for tab=1,guildBankTabCount do
			for slot=1,GUILD_BANK_SLOTS_PER_TAB do
				if not (GetGuildBankItemInfo(tab,slot) == nil) then 
					GuildBankItemLinks[#GuildBankItemLinks+1] = GetGuildBankItemLink(tab,slot);
					GuildBankItemCount = GuildBankItemCount + 1;
					db.factionrealm.guilds[guildName].GuildBankItemLinks[#db.factionrealm.guilds[guildName].GuildBankItemLinks + 1] = GetGuildBankItemLink(tab,slot);
					db.factionrealm.guilds[guildName].GuildBankItemCount = db.factionrealm.guilds[guildName].GuildBankItemCount + 1;
				end
			end
		end
	end
end

function LegendaryStockTracker:GetGearFromItems()
	gearLinks = {}
	for i=1, #itemLinks do
		if select(12, GetItemInfo(itemLinks[i])) == 4 then 
			gearLinks[#gearLinks+1] = itemLinks[i]
		end
	end
end

function LegendaryStockTracker:AddAllItemsToList()
	itemLinks = {}
	if(db.profile.settings.includeBags) then
		if(db.profile.settings.includeCachedData) then
			LegendaryStockTracker:AddItemsToList("bagItemLinks")
		else
			for i=1, #bagItemLinks do
				itemLinks[#itemLinks+1] = bagItemLinks[i]
			end
		end
	end
	if(db.profile.settings.includeBank) then
		if(db.profile.settings.includeCachedData) then
			LegendaryStockTracker:AddItemsToList("bankItemLinks")
		else
			for i=1, #bankItemLinks do
				itemLinks[#itemLinks+1] = bankItemLinks[i]
			end
		end
	end
	if(db.profile.settings.includeAH) then
		if(db.profile.settings.includeCachedData) then
			LegendaryStockTracker:AddItemsToList("ahItemLinks")
		else
			for i=1, #ahItemLinks do
				itemLinks[#itemLinks+1] = ahItemLinks[i]
			end
		end
	end
	if(db.profile.settings.includeMail) then
		if(db.profile.settings.includeCachedData) then
			LegendaryStockTracker:AddItemsToList("mailboxItemLinks")
		else
			for i=1, #mailboxItemLinks do
				itemLinks[#itemLinks+1] = mailboxItemLinks[i]
			end
		end
	end
	if(db.profile.settings.IncludeGuild) then
		if(db.profile.settings.includeCachedData) then
			for key,val in pairs(db.factionrealm.guilds) do
				for i=1, #db.factionrealm.guilds[key]["GuildBankItemLinks"] do
					itemLinks[#itemLinks+1] = db.factionrealm.guilds[key]["GuildBankItemLinks"][i]
				end
			end
		else
			for i=1, #GuildBankItemLinks do
				itemLinks[#itemLinks+1] = GuildBankItemLinks[i]
			end
		end
	end
end

function LegendaryStockTracker:AddItemsToList(itemSource)
	for key,val in pairs(db.factionrealm.characters) do
		for i=1, #db.factionrealm.characters[key][itemSource] do
			itemLinks[#itemLinks+1] = db.factionrealm.characters[key][itemSource][i]
		end
	end
end

function LegendaryStockTracker:GetShadowlandsLegendariesFromGear()
	legendaryLinks = {}
	for i=1, #gearLinks do
		if (select(3, GetItemInfo(gearLinks[i])) == 1)  then 
			local detailedItemLevel = GetDetailedItemLevelInfo(gearLinks[i])
			if (detailedItemLevel > 175) and (detailedItemLevel < 300) then --leaving ilvl room for future upgradres (max 235 at time of writing)
				legendaryLinks[#legendaryLinks+1] = gearLinks[i]
			end
		end
	end
end

function LegendaryStockTracker:CountLegendariesByRank()
	LegendaryStockTracker:CountLegendariesByRankWithoutSyncdata();

	if(db.profile.settings.includeCachedData) then
		for account, accountdata in pairs(db.factionrealm.syncData) do
			for id, data in pairs (accountdata["legendaries"]) do
				for rank, count in pairs(data["stock"]) do
					LegendaryItemData[id]["stock"][rank] = LegendaryItemData[id]["stock"][rank] + count;
					if(db.profile.settings.loadUnownedLegendaries == false and count > 0) then
						LegendaryStockTracker:UpdateTsmPrices(id, rank);
					end
				end
			end
		end
	end
end

function LegendaryStockTracker:CountLegendariesByRankWithoutSyncdata()
	for id, data in pairs (LegendaryItemData) do
		for rank, count in pairs(LegendaryItemData[id]["stock"]) do
			LegendaryItemData[id]["stock"][rank] = 0;
		end
	end
	
	TSMPriceDataByRank = {}
	for i=1, #legendaryLinks do
		local itemID = select(3, strfind(legendaryLinks[i], "item:(%d+)"));
		local detailedItemLevel = GetDetailedItemLevelInfo(legendaryLinks[i]);
		local rank = 0;
		if detailedItemLevel == 190 then
			rank = 1;
		elseif detailedItemLevel == 210 then
			rank = 2;
		elseif detailedItemLevel == 225 then
			rank = 3;
		elseif detailedItemLevel == 235 then
			rank = 4;
		end
		LegendaryItemData[itemID]["stock"][rank] = LegendaryItemData[itemID]["stock"][rank] + 1;
		if(db.profile.settings.loadUnownedLegendaries == false) then
			LegendaryStockTracker:UpdateTsmPrices(itemID, rank);
		end
	end
end

function LegendaryStockTracker:UpdateRestockList()
	RestockList = {}
	local nameTable = LegendaryStockTracker:createNameTable()
	local restockAmount = tonumber(db.profile.settings.restockAmount)
	for item=1, #nameTable do
		for rank=1, numRanks do
			local currentStock = tonumber(LegendaryStockTracker:GetStockCount(nameTable[item], rank))
			if currentStock < restockAmount and restockAmount - currentStock >= tonumber(db.profile.settings.minrestockAmount) then 
				if(IsTSMLoaded == false or db.profile.settings.showPricing == false) then
					table.insert(RestockList, {LegendaryItemData[nameTable[item]]["name"] , rank, restockAmount - currentStock, 0})
				else
					if tonumber(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank)) > tonumber(db.profile.settings.minProfit) then
						table.insert(RestockList, {LegendaryItemData[nameTable[item]]["name"], rank, restockAmount - currentStock, LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(nameTable[item], rank)})
					end
				end
			end
		end
	end
end

function LegendaryStockTracker:GenerateExportText()
	local NameTable = LegendaryStockTracker:createNameTable()

	local text = ""
	if(IsTSMLoaded == false or db.profile.settings.showPricing == false) then
		text = L["Item name, Rank 1, Rank 2, Rank 3,  Rank 4\n"]
		for i=1, #NameTable do 
			text = text .. LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 1) .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 2) .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 3) .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 4) .. "\n" 
		end
	else
		text = L["Item name, Rank 1, Profit Rank 1, Rank 2, Profit Rank 2, Rank 3, Profit Rank 3, Rank 4, Profit Rank 4\n"]
		for i=1, #NameTable do 
			text = text .. LegendaryItemData[NameTable[i]]["name"] .. "," 
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 1) .. "," .. tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1)) .. ","
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 2) .. "," .. tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2)) .. ","
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 3) .. "," .. tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3)) .. ","
			.. LegendaryStockTracker:GetStockCount(NameTable[i], 4) .. "," .. tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4)) .. "\n"
		end
	end
	return text
end

function LegendaryStockTracker:createNameTable()
	local NameTable = {} --nametable is now "list of items to export"
	if(db.profile.settings.loadUnownedLegendaries == false) then
		for id, data in pairs (LegendaryItemData) do
			local count = 0;
			for rank, data in pairs(LegendaryItemData[id]["stock"]) do
				count = count + data;
			end
			if(count > 0 ) then
				table.insert(NameTable, id) 
			end
		end
		table.sort(NameTable)
	else
		TSMPriceDataByRank = {}
		for id, data in pairs(LegendaryItemData) do 
			table.insert(NameTable, id)
			LegendaryStockTracker:UpdateTsmPriceForAllRanks(id)
		end
		table.sort(NameTable)	
	end
	return NameTable
end

function LegendaryStockTracker:CreateRestockSheet(frame)
	LegendaryStockTracker:UpdateRestockList()
	local NameTable = LegendaryStockTracker:createNameTable()
	if(fontStringPool == nil) then
		fontStringPool = CreateFontStringPool(frame, "OVERLAY", nil, "GameFontNormal", FontStringPool_Hide)
	else
		fontStringPool:ReleaseAll()
	end
	local sheet = {}
	local titles = {LegendaryStockTracker:CreateTableTitle(frame, L["Item"]), LegendaryStockTracker:CreateTableTitle(frame, L["Amount"]), LegendaryStockTracker:CreateTableTitle(frame, L["Profit"])}
	table.insert(sheet, titles)
	for i=1, #RestockList do 
		row = 
		{
			LegendaryStockTracker:CreateTableElement(frame, RestockList[i][1] .. " - " .. L["Rank"] .. " " .. RestockList[i][2],  1, 1, 1, 1),
			LegendaryStockTracker:CreateTableElement(frame, RestockList[i][3],  1, 1, 1, 1),
			LegendaryStockTracker:CreateTableElement(frame, RestockList[i][4],  1, 1, 1, 1)
		}
		table.insert(sheet, row)
	end

	LegendaryStockTracker:CreateFrameSheet(frame, sheet, 3)
end

function LegendaryStockTracker:CreateTableSheet(frame)
	local NameTable = LegendaryStockTracker:createNameTable()
	if(fontStringPool == nil) then
		fontStringPool = CreateFontStringPool(frame, "OVERLAY", nil, "GameFontNormal", FontStringPool_Hide)
	else
		fontStringPool:ReleaseAll()
	end
	local sheet = {}
	if(IsTSMLoaded == false or db.profile.settings.showPricing == false) then
		local titles = {LegendaryStockTracker:CreateTableTitle(frame, L["Item name"]), LegendaryStockTracker:CreateTableTitle(frame, L["Rank 1"]), LegendaryStockTracker:CreateTableTitle(frame, L["Rank 2"]), LegendaryStockTracker:CreateTableTitle(frame, L["Rank 3"]), LegendaryStockTracker:CreateTableTitle(frame, L["Rank 4"])}
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0}
		for i=1, #NameTable do 
			row = 
			{
				LegendaryStockTracker:CreateTableElement(frame, LegendaryItemData[NameTable[i]]["name"],  1, 1, 1, 1),
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 1), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 1))), 
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 2), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 2))), 
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 3), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 3))), 
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 4), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 4)))
			}
			table.insert(sheet, row)
		end
	else
		local titles = {LegendaryStockTracker:CreateTableTitle(frame, L["Item name"]), LegendaryStockTracker:CreateTableTitle(frame, L["R1"]), LegendaryStockTracker:CreateTableTitle(frame, L["Profit R1"]), LegendaryStockTracker:CreateTableTitle(frame, L["R2"]),
			LegendaryStockTracker:CreateTableTitle(frame, L["Profit R2"]), LegendaryStockTracker:CreateTableTitle(frame, L["R3"]), LegendaryStockTracker:CreateTableTitle(frame, L["Profit R3"]), LegendaryStockTracker:CreateTableTitle(frame, L["R4"]), LegendaryStockTracker:CreateTableTitle(frame, "Profit R4")}
		table.insert(sheet, titles)
		maxWidth = {0,0,0,0,0,0,0,0,0}
		for i=1, #NameTable do 
			row = 
			{
				LegendaryStockTracker:CreateTableElement(frame, LegendaryItemData[NameTable[i]]["name"], 1, 1, 1, 1),
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 1), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 1), tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1)))), LegendaryStockTracker:CreateTableElement(frame, tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1)), LegendaryStockTracker:GetTablePriceFont(tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 1)))),
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 2), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 2), tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2)))), LegendaryStockTracker:CreateTableElement(frame, tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2)), LegendaryStockTracker:GetTablePriceFont(tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 2)))),
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 3), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 3), tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3)))), LegendaryStockTracker:CreateTableElement(frame, tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3)), LegendaryStockTracker:GetTablePriceFont(tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 3)))),
				LegendaryStockTracker:CreateTableElement(frame, LegendaryStockTracker:GetStockCount(NameTable[i], 4), LegendaryStockTracker:GetTableStockFont(LegendaryStockTracker:GetStockCount(NameTable[i], 4), tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4)))), LegendaryStockTracker:CreateTableElement(frame, tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4)), LegendaryStockTracker:GetTablePriceFont(tostring(LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(NameTable[i], 4))))
			}
			table.insert(sheet, row)		
		end
	end
	LegendaryStockTracker:CreateFrameSheet(frame, sheet, #maxWidth)
end

function LegendaryStockTracker:CreateFrameSheet(frame, table, numColumns)
	local sheet  = {}
	local maxWidth = {}
	local xStartValue = 0
	local xPosition = xStartValue
	local yPosition = 0
	local YDIFF = 15
	local XDIFF = 15
	maxWidth = {}
	for i=1, numColumns do
		maxWidth[i] = 0
	end

	for i=1, #table do 
		for j=1, #table[i] do
			LegendaryStockTracker:CompareTableValue(frame, maxWidth, j, table[i][j][2])
		end
	end
	for i=1, #table do
		for j=1, #table[i] do
			LegendaryStockTracker:SetElementPosition(table[i][j][1], xPosition, yPosition)
			xPosition = xPosition + XDIFF + maxWidth[j]
		end
		xPosition = xStartValue
		yPosition = yPosition - YDIFF
		--LegendaryStockTracker:AddTableLine(frame, yPosition)
	end
end

function LegendaryStockTracker:GetTablePriceFont(stringValue)
	if(tonumber(db.profile.settings.minProfit) > 0 and tonumber(stringValue) > tonumber(db.profile.settings.minProfit)) then
		return 0.15, 1, 0.15, 1
	elseif(tonumber(stringValue) < 0) then
		return 1, 0.15, 0.15, 1
	else 
		return 1, 1, 1, 1
	end
end

function LegendaryStockTracker:GetTableStockFont(value, price)
	if(value < tonumber(db.profile.settings.restockAmount)) then
		if(db.profile.settings.showPricing == true and price ~= nil) then
			if(tonumber(price) > tonumber(db.profile.settings.minProfit)) then 
				return 0, 0.5, 1, 1
			else 
				return 1, 1, 1, 1
			end
		else
			return 0, 0.75, 1, 1
		end
	else 
		return 1, 1, 1, 1
	end
end

function LegendaryStockTracker:SetElementPosition(element, x, y)
	element:SetPoint("LEFT", x, 0)
	element:SetPoint("TOP", 0, y)
end

function LegendaryStockTracker:CreateTableElement(frame, text, r, g, b, a)
	local fontString = fontStringPool:Acquire()
	fontString:SetParent(frame)
	fontString:SetTextColor(r,g,b,a)
	fontString:SetJustifyH("LEFT")
	fontString:SetJustifyV("MIDDLE")
	fontString:SetPoint("LEFT", 15, 0)
	fontString:SetPoint("TOP", 0, -15)
	fontString:SetText(text)
	fontString:Show()
	return {fontString, fontString:GetStringWidth(text)}
end

function LegendaryStockTracker:CreateTableTitle(frame, text)
	local fontString = fontStringPool:Acquire()
	fontString:SetParent(frame)
	fontString:SetTextColor(1,0.9,0,1)
	--fontString:SetFontObject("GameFontNormal")
	fontString:SetJustifyH("CENTER")
	fontString:SetJustifyV("MIDDLE")
	fontString:SetPoint("LEFT", 15, 0)
	fontString:SetPoint("TOP", 0, -15)
	fontString:SetText(text)
	fontString:Show()
	return {fontString, fontString:GetStringWidth(text)}
end

function LegendaryStockTracker:CompareTableValue(frame, table, index, toCompare)
	if (toCompare > table[index]) then
		table[index] = toCompare
	end
end

function LegendaryStockTracker:AddTableLine(frame, yPosition)
	local line = frame:CreateLine()
	line:SetThickness(1)
	line:SetColorTexture(0.6,0.6,0.6,1)
	line:SetStartPoint("TOPLEFT", -3, yPosition + 2)
	line:SetEndPoint("TOPRIGHT", 3, yPosition + 2)
end

function LegendaryStockTracker:AddEmptyTsmPriceDataEntryIfNotPresent(itemName)
	if (TSMPriceDataByRank[itemName] == nil) then
		TSMPriceDataByRank[itemName] = {{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0},{0,0,0,0,0}} --leaving room for up to 10 legendary ranks
	end
end

function LegendaryStockTracker:GetMinBuyoutMinusAuctionOpMin(name, rank)
	return tonumber(TSMPriceDataByRank[name][rank][1] - TSMPriceDataByRank[name][rank][2]);
end

function LegendaryStockTracker:UpdateTsmPriceForAllRanks(itemName)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 1)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 2)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 3)
	LegendaryStockTracker:UpdateTsmPrices(itemName, 4)
end

function LegendaryStockTracker:UpdateTsmPrices(itemName, rank)
	LegendaryStockTracker:AddEmptyTsmPriceDataEntryIfNotPresent(itemName)
	local ItemPrices = TSMPriceDataByRank[itemName]
	if(IsTSMLoaded ~= true) then
		ItemPrices[rank][1] = 0
		ItemPrices[rank][2] = 0
		return nil
	end
	local tsmString = "i:" .. itemName;
	if(rank == 1) then
		tsmString = tsmString .. Rank1BonusIDs
	elseif(rank == 2) then
		tsmString = tsmString .. Rank2BonusIDs
	elseif(rank == 3) then
		tsmString = tsmString .. Rank3BonusIDs
	elseif(rank == 4) then
		tsmString = tsmString .. Rank4BonusIDs
	end
	tsmstring = TSM_API.ToItemString(tsmString)
	ItemPrices[rank][1] = LegendaryStockTracker:ConvertTsmPriceToGold(TSM_API.GetCustomPriceValue("DBMinBuyout", tsmString))
	ItemPrices[rank][2] = LegendaryStockTracker:ConvertTsmPriceToGold(TSM_API.GetCustomPriceValue("AuctioningOpMin", tsmString))
	if(ItemPrices[rank][1] == nil) then
		ItemPrices[rank][1] = LegendaryStockTracker:ConvertTsmPriceToGold(TSM_API.GetCustomPriceValue("AuctioningOpNormal", tsmString))
	end
	if(ItemPrices[rank][1] == nil or ItemPrices[rank][2] == nil) then
		ItemPrices[rank][1] = 0
		ItemPrices[rank][2] = 0
	end

	TSMPriceDataByRank[itemName] = ItemPrices
end

function LegendaryStockTracker:ConvertTsmPriceToGold(value)
	local string = tostring(value)
	if(string ~= "0") then
		string = string:sub(1, #string - 4)
	end
	if(tonumber(string) == nil or tonumber(string) <= 0) then
		return 0
	end
	return tonumber(string)
end

function LegendaryStockTracker:GetStockCount(itemName, rank)
	local count = 0;
	if (LegendaryItemData[itemName] ~= nil) then 
		if (LegendaryItemData[itemName]["stock"][rank] ~= nil) then 
			count = LegendaryItemData[itemName]["stock"][rank];
		end
	end
	return count;
end

function LegendaryStockTracker:CheckIfTSMIsRunning()
	IsTSMLoaded = select(1,IsAddOnLoaded("TradeSkillMaster"))
end

function LegendaryStockTracker:OnItemAdded(self, event, itemKey)
end

function LegendaryStockTracker:ScanAhPrices(item)
	if AuctionHouseFrame and AuctionHouseFrame:IsShown() then
		local itemKeys = {}
		itemKeys[1] = C_AuctionHouse.MakeItemKey(171419, 190, nil)
		itemKeys[2] = C_AuctionHouse.MakeItemKey(171419, 210, nil)
		itemKeys[3] = C_AuctionHouse.MakeItemKey(171419, 225, nil)
		itemKeys[4] = C_AuctionHouse.MakeItemKey(171419, 235, nil)
		C_AuctionHouse.SearchForItemKeys(itemKeys, {})
	end
end

function LegendaryStockTracker:GetKnownTradeSkillRecipes()
	local table = C_TradeSkillUI.GetFilteredRecipeIDs()
	return table;
end

function LegendaryStockTracker:IsTradeSkillRecipeSLLegendary(recipeID)
	local info = C_TradeSkillUI.GetRecipeInfo(recipeID);
	if(info["unlockedRecipeLevel"] == nil) then
		return false;
	end
	return true;
end

function LegendaryStockTracker:GetTradeSkillRecipeName(recipeID)
	local info = C_TradeSkillUI.GetRecipeInfo(recipeID);
	return info["name"];
end

function LegendaryStockTracker:GetSLLegendaryUnlockedLevel(recipeID)
	local info = C_TradeSkillUI.GetRecipeInfo(recipeID);
	return info["unlockedRecipeLevel"];
end

function LegendaryStockTracker:ExportCraftRecipes()
	local test = ""
	local table = LegendaryStockTracker:GetKnownTradeSkillRecipes();
	for key, val in pairs(table) do 
		--test = test .. tostring(LegendaryStockTracker:GetTradeSkillRecipeName(val)) .. ": " .. tostring(LegendaryStockTracker:IsTradeSkillRecipeSLLegendary(val)) .. " rank unlocked: " .. tostring(LegendaryStockTracker:GetSLLegendaryUnlockedLevel(val)) .."\n"
		for k, v in pairs(C_TradeSkillUI.GetRecipeInfo(val)) do  
			test = test .. tostring(k) .. ":" .. tostring(v) .."\n";
		end
	end

	local f = LegendaryStockTracker:GetMainFrame(UIParent)
	LegendaryStockTracker:TabOnClick(exportTab)
	LSTEditBox:SetText(test)
	LSTEditBox:HighlightText()
	f:Show()
end

function LegendaryStockTracker:OnCommReceived(prefix, payload, distribution, sender)
	local decoded = LibDeflate:DecodeForWoWAddonChannel(payload)
	if not decoded then return end
	local decompressed = LibDeflate:DecompressDeflate(decoded)
	if not decompressed then return end
	local success, data = LibSerialize:Deserialize(decompressed)
	if not success then return end
	print(L["LST: Received item data from "] .. sender)
	db.factionrealm.syncData[data["accID"]] = {}
	db.factionrealm.syncData[data["accID"]]["legendaries"] = {}
	local table = db.factionrealm.syncData[data["accID"]]["legendaries"]
	for id, data in pairs (data["legendaries"]) do
		table[id] = 
		{
			["canCraft"] = data[1],
			["stock"] = {data[2],  data[3], data[4], data[5]}
		}
	end
end

function LegendaryStockTracker:SendDataToSyncTarget()
	LegendaryStockTracker:SendDataToPlayer(db.profile.settings.syncTarget)
end

function LegendaryStockTracker:SendDataToPlayer(player)
	print(L["LST: Sending data to "] .. player)
	LegendaryStockTracker:CountLegendariesByRankWithoutSyncdata();
	local syncData = {
		["accID"] = db.factionrealm.accountUUID,
		["legendaries"] = {}
	}

	for id, data in pairs (LegendaryItemData) do
		local count = 0;
		for rank, data in pairs(LegendaryItemData[id]["stock"]) do
			count = count + data;
		end
		if(count > 0 ) then
			syncData["legendaries"][id] = {0, LegendaryItemData[id]["stock"][1], LegendaryItemData[id]["stock"][2], LegendaryItemData[id]["stock"][3], LegendaryItemData[id]["stock"][4]}
		end
	end

	LegendaryStockTracker:CountLegendariesByRank();

	local serialized = LibSerialize:Serialize(syncData)
	local compressed = LibDeflate:CompressDeflate(serialized)
	local encoded = LibDeflate:EncodeForWoWAddonChannel(compressed)
	self:SendCommMessage("LST", encoded, "WHISPER", player, "NORMAL", LegendaryStockTracker:OnCommChunkSent())
end

function LegendaryStockTracker:OnCommChunkSent(arg, sentBytes, totalBytes)
	--print(sentBytes == totalBytes);
end

function LegendaryStockTracker:GenerateUUID()
	local random = math.random
	local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
	return string.gsub(template, '[xy]', function (c)
		local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
		return string.format('%x', v)
	end)
end