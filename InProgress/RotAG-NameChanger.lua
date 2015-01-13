PLUGIN.Name = "RotAG-NameChanger"
PLUGIN.Title = "RotAG-NameChanger"
PLUGIN.Version = V(2, 1, 1)
PLUGIN.Description = "NameChanger plugin for the experimental RUST branch"
PLUGIN.Author = "TheRotAG"
PLUGIN.HasConfig = true
PLUGIN.ResourceId  = 737

----------------------------------------- LOCALS -----------------------------------------
local mod, cmds, msgs, sets  = {}, {}, {}, {}
local function SendMessage(player, msg)
	player:SendConsoleCommand("chat.add \"".. msgs.ChatName.."\" \"".. msg .."\"")
end

local function HasAccess(player)
	return player:GetComponent("BaseNetworkable").net.connection.authLevel >= mod.Auth_LVL
end

function PLUGIN:SendHelpText(player)
	if HasAccess(player) then
		SendMessage(player, msgs.Help1:format(cmds.Name))
		SendMessage(player, msgs.Help2:format(cmds.TempName))
		SendMessage(player, msgs.Help3:format(cmds.NameOff))
	end
end
------------------------------------------------------------------------------------------

function PLUGIN:Init()
		mod.Auth_LVL = self.Config.Auth_LvL or 1
		self.Config.Auth_LvL = mod.Auth_LVL
		
		self.Config.Messages = self.Config.Messages or {}
		self.Config.Messages.NoPermission = self.Config.Messages.NoPermission or "You don't have permission to use this command!"
		self.Config.Messages.Ok = self.Config.Messages.Ok or "Name changed!"
		self.Config.Messages.OriginalOk = self.Config.Messages.OriginalOk or "Default Name changed! Everytime you relog your Default Name will be loaded! Use /nameoff to load it now!"
		self.Config.Messages.ChatName = self.Config.Messages.ChatName or "[NameChanger]"
		self.Config.Messages.Help1 = self.Config.Messages.Help1 or "use /%s \\\"desired name\\\" -- to change your default name"
		self.Config.Messages.Help2 = self.Config.Messages.Help2 or "use /%s \\\"desired name\\\" -- to change your current name to a temporary one"
		self.Config.Messages.Help3 = self.Config.Messages.Help3 or "use /%s -- to load your default name"
		self.Config.Messages.Syntax = self.Config.Messages.Syntax or "Command Error! Use /%s \\\"desired name\\\""
		
		self.Config.Commands = self.Config.Commands or {}
		self.Config.Commands.Name = self.Config.Commands.Name or "name"
		self.Config.Commands.TempName = self.Config.Commands.TempName or "tempname"
		self.Config.Commands.NameOff = self.Config.Commands.NameOff or "nameoff"
		
		msgs = self.Config.Messages
		cmds = self.Config.Commands
		self:LoadSavedData()
        self:SaveConfig()
		
		if cmds.Name ~= "" then command.AddChatCommand(cmds.Name, self.Object, "C_Name") end
		if cmds.TempName ~= "" then command.AddChatCommand(cmds.TempName, self.Object, "C_TempName") end
		if cmds.NameOff ~= "" then command.AddChatCommand(cmds.NameOff, self.Object, "C_NameOff") end
end		

function PLUGIN:LoadSavedData()
	if not datafile.GetDataTable( "NameChanger" ) then
		self:SaveData()
	end
    NameData           	= datafile.GetDataTable( "NameChanger" )
    NameData           	= NameData or {}
	NameData.Original 	= NameData.Original or {}
	NameData.New		= NameData.New or {}
end

function PLUGIN:SaveData()  
    datafile.SaveDataTable( "NameChanger" )
end

function PLUGIN:C_Name(player, cmd, args)
	if args.Length > 0 then
		if HasAccess(player) then
			local pID = rust.UserIDFromPlayer( player )
			local getOriginal = tostring(args[0])
			NameData.Original[pID] = NameData.Original[pID] or {}
			NameData.Original[pID].Name = NameData.Original[pID].Name or ""
			NameData.Original[pID].Name = tostring(getOriginal)
			self:SaveData()
			SendMessage(player, msgs.OriginalOk)
		else
			SendMessage(player, msgs.NoPermission)
		end
	else
		SendMessage(player, msgs.Syntax:format(cmds.Name))
	end
end

function PLUGIN:C_TempName(player, cmd, args)
	if args.Length > 0 then
		if HasAccess(player) then
			local pID = rust.UserIDFromPlayer( player )
			local getNew = tostring(args[0])
			NameData.New[pID] = NameData.New[pID] or {}
			NameData.New[pID].Name = NameData.New[pID].Name or ""
			NameData.New[pID].Name = getNew
			self:SaveData()
			player.displayName = getNew
			SendMessage(player, msgs.Ok)
			print(tostring(getOriginal).." changed his name to "..getNew)
		else
			SendMessage(player, msgs.NoPermission)
		end
	else
		SendMessage(player, msgs.Syntax:format(cmds.TempName))
	end
end

function PLUGIN:C_NameOff(player, cmd, args)
	if args.Length == 0 then
		if HasAccess(player) then
			datafile.GetDataTable("NameChanger")
			local pID = rust.UserIDFromPlayer(player)
			local getOriginal = NameData.Original[pID].Name
			player.displayName = getOriginal
			NameData.New[pID].Name = getOriginal
			self:SaveData()
			SendMessage(player, msgs.Ok)
		else
			SendMessage(player, msgs.NoPermission)
		end
	end
end

function PLUGIN:OnPlayerInit( player )
	if HasAccess(player) then
		local pID = rust.UserIDFromPlayer(player)
		player.displayName = NameData.Original[pID].Name
	end
end