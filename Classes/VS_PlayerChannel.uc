class VS_PlayerChannel extends Info;

var PlayerPawn PlayerOwner;
var VS_Info Info; // Info Info

var VS_DataClient DataClient;

var VS_Preset PresetList;
var VS_UI_Window VoteMenuDialog;
var bool bOpenVoteMenuAfterTyping;

var Object SettingsDummy;
var VS_ClientSettings Settings;

// Temporary variables used while receiving Preset/Map information
var VS_Preset LatestPreset;
var VS_Map LatestMap;

// Player Voting Information
var bool bHasVoted; // unreplicated, server-only
var VS_Preset VotePreset; // unreplicated
var VS_Map VoteMap; // unreplicated

var int KickVotesAgainstMe;
var array<PlayerReplicationInfo> IWantToKick;

var int MaxMapSequenceNumber;

replication {
	reliable if (Role < ROLE_Authority)
		ServerBanPlayer,
		ServerKickPlayer,
		ServerVote,
		ServerVoteExisting;

	reliable if (Role == ROLE_Authority)
		ClientApplyKickVote,
		DumpPlayerList,
		ShowVoteMenu,
		HideVoteMenu;

	reliable if (Role == ROLE_Authority && ((bDemoRecording == false) || (bClientDemoRecording && bClientDemoNetFunc) || (Level.NetMode == NM_Standalone)))
		LocalizeMessage, ChatMessage;
}

simulated event PostBeginPlay() {
	SettingsDummy = new(none, 'VoteSys') class 'Object';
	Settings = new (SettingsDummy, 'ClientSettings') class'VS_ClientSettings';
}

simulated event Tick(float Delta) {
	if (PlayerOwner == none) {
		if (Owner != none) {
			PlayerOwner = PlayerPawn(Owner);
		}
	}

	if (PlayerOwner == none || PlayerOwner.Player == none || PlayerOwner.Player.IsA('Viewport') == false)
		return;

	if (VoteMenuDialog == none)
		TryCreateVoteMenuDialog();

	if (VoteMenuDialog == none)
		return;

	if (DataClient == none)
		DataClient = Spawn(class'VS_DataClient', self);

	if (bOpenVoteMenuAfterTyping && PlayerOwner.Player.Console.IsInState('Typing') == false) {
		bOpenVoteMenuAfterTyping = false;
		ShowVoteMenu();
	}
}

simulated function VS_Info VoteInfo() {
	if (Info != none)
		return Info;

	foreach AllActors(class'VS_Info', Info)
		break;

	return Info;
}

simulated function TryCreateVoteMenuDialog() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none)
		return;

	if (VoteMenuDialog == none) {
		if (C.Root == none)
			return;

		VoteMenuDialog = VS_UI_Window(C.Root.CreateWindow(
			class'VS_UI_Window',
			Settings.MenuX,
			Settings.MenuY,
			0,0 // Size set internally
		));
		if (VoteMenuDialog == none)
			return;
		VoteMenuDialog.Channel = self;
		VoteMenuDialog.Settings = Settings;
		VoteMenuDialog.HideWindow();

	}
}

simulated function CreateVoteMenuDialog() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -4);
		return;
	}

	if (VoteMenuDialog == none) {
		if (C.Root == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', -2);
			return;
		}

		VoteMenuDialog = VS_UI_Window(C.Root.CreateWindow(
			class'VS_UI_Window',
			Settings.MenuX,
			Settings.MenuY,
			0,0 // Size set internally
		));
		VoteMenuDialog.Channel = self;
		VoteMenuDialog.Settings = Settings;
		VoteMenuDialog.HideWindow();

		if (VoteMenuDialog == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', -3);
			return;
		}
	}
}

simulated function ShowVoteMenu() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (DataClient == none || DataClient.bTransferDone == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -1);
		return;
	}

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -4);
		return;
	}

	if (C.IsInState('Typing')) {
		// delay until after player is done typing on the console
		bOpenVoteMenuAfterTyping = true;
		return;
	}

	if (C.bShowConsole) {
		// console is already open, no need to do anything
	} else {
		// probably a hotkey that called this function
		C.bQuickKeyEnable = True;
		C.LaunchUWindow();
	}

	if (VoteMenuDialog == none) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -3);
		return;
	}

	VoteMenuDialog.bLeaveOnscreen = true;
	VoteMenuDialog.ShowWindow();
}

simulated function HideVoteMenu() {
	if (VoteMenuDialog != none)
		VoteMenuDialog.Close();
}

simulated function AddPreset(VS_Preset P) {
	if (LatestPreset != none) {
		if (VoteMenuDialog == none)
			CreateVoteMenuDialog();

		VoteMenuDialog.AddPreset(LatestPreset);
	}

	if (LatestPreset == none) {
		PresetList = P;
	} else {
		LatestPreset.Next = P;
	}
	LatestPreset = P;
	LatestMap = none;
}

simulated function FocusPreset(string Ref) {
	local VS_Preset P;

	for (P = PresetList; P != none; P = P.Next)
		if (P.GetFullName() == Ref)
			break;

	if (P != none)
		VoteMenuDialog.FocusPreset(P);
}

simulated function AddMap(VS_Map M) {
	if (LatestPreset.MapList == none) {
		LatestPreset.MapList = M;
	} else {
		LatestMap.Next = M;
	}
	LatestMap = M;
}

simulated function Vote(VS_Preset P, VS_Map M) {
	if (P == none || M == none)
		return;

	ServerVote(P.Category, P.PresetName, M.MapName);

	VotePreset = P;
	VoteMap = M;
}

function ServerVote(string Category, string PresetName, string MapName) {
	local VS_Preset P;
	local VS_Map M;
	local VS_Info I;

	if (PlayerOwner == none)
		return;

	I = VoteInfo();
	P = I.ResolvePresetSeparate(Category, PresetName);
	M = I.ResolveMapOfPreset(P, MapName);

	if (P == none || M == none)
		return;

	if (PlayerOwner.PlayerReplicationInfo.bAdmin == false) {
		if (VotePreset == P && VoteMap == M)
			return;
		if (P.MaxSequenceNumber - M.Sequence < P.MinimumMapRepeatDistance)
			return;
	}

	if (bHasVoted)
		I.RemMapVote(self, VotePreset, VoteMap);
	I.AddMapVote(self, P, M);

	bHasVoted = true;
	VotePreset = P;
	VoteMap = M;
}

simulated function VoteExisting(string Preset, string MapName) {
	ServerVoteExisting(Preset, MapName);
}

function ServerVoteExisting(string Preset, string MapName) {
	local VS_Info I;
	local VS_Preset P;
	local VS_Map M;

	if (PlayerOwner == none)
		return;

	I = VoteInfo();
	P = I.ResolvePresetCombined(Preset);
	M = I.ResolveMapOfPreset(P, MapName);

	if (P == none || M == none)
		return;

	if (VotePreset == P && VoteMap == M && PlayerOwner.PlayerReplicationInfo.bAdmin == false)
		return;

	if (bHasVoted)
		I.RemMapVote(self, VotePreset, VoteMap);
	I.AddMapVote(self, P, M);

	bHasVoted = true;
	VotePreset = P;
	VoteMap = M;
}

function ClearVote() {
	if (bHasVoted) {
		VoteInfo().RemMapVote(self, VotePreset, VoteMap);
		bHasVoted = false;
		VotePreset = none;
		VoteMap = none;
	}
}

simulated function int WantsToKick(PlayerReplicationInfo PRI) {
	local int i;

	for (i = 0; i < IWantToKick.Length; i++) 
		if (IWantToKick[i] == PRI)
			return i;
	
	return -1;
}

simulated function bool ToggleKick(PlayerReplicationInfo PRI) {
	local int Index;

	Index = WantsToKick(PRI);
	if (Index < 0) {
		IWantToKick.Insert(0, 1);
		IWantToKick[0] = PRI;
		return true;
	} else {
		IWantToKick.Remove(Index, 1);
		return false;
	}
}

simulated function KickPlayer(PlayerReplicationInfo PRI) {
	ServerKickPlayer(PRI);
}

function ServerKickPlayer(PlayerReplicationInfo PRI) {
	VoteInfo().KickPlayer(self, PRI);
}

simulated function ClientApplyKickVote(PlayerReplicationInfo PRI) {
	ToggleKick(PRI);
}

simulated function BanPlayer(PlayerReplicationInfo PRI) {
	ServerBanPlayer(PRI);
}

function ServerBanPlayer(PlayerReplicationInfo PRI) {
	if (PlayerOwner == none)
		return;

	VoteInfo().BanPlayer(self, PRI);
}

simulated function LocalizeMessage(
	class<LocalMessage> MessageClass,
	optional int Switch,
	optional string Param1,
	optional string Param2,
	optional string Param3,
	optional string Param4,
	optional string Param5
) {
	local VS_Msg_ParameterContainer Params;

	Params = new(none) class'VS_Msg_ParameterContainer';
	// no Param0, reserved for invalid parameter sequences
	Params.Params[1] = Param1;
	Params.Params[2] = Param2;
	Params.Params[3] = Param3;
	Params.Params[4] = Param4;
	Params.Params[5] = Param5;

	PlayerOwner.ReceiveLocalizedMessage(MessageClass, Switch, /*PRI1*/, /*PRI2*/, Params);
}

simulated function ChatMessage(PlayerReplicationInfo PRI, string Msg) {
	if (VoteMenuDialog == none)
		return;

	VS_UI_ClientWindow(VoteMenuDialog.ClientArea).ChatArea.AddChat(PRI, Msg);
}

simulated function DumpPlayerList() {
	local int i;
	local VS_Info Info;
	local VS_UI_PlayerListItem Item;

	Info = VoteInfo();
	for (i = 0; i < arraycount(Info.PlayerInfo); i++)
		if (Info.PlayerInfo[i] != none)
			PlayerOwner.ClientMessage("["$i$"]=(PRI="$Info.PlayerInfo[i].PRI$",bHasVoted="$Info.PlayerInfo[i].bHasVoted$")");

	for (Item = VS_UI_PlayerListItem(VS_UI_ClientWindow(VoteMenuDialog.ClientArea).PlayerListBox.Items.Next); Item != none; Item = VS_UI_PlayerListItem(Item.Next)) {
		PlayerOwner.ClientMessage(string(Item.PlayerInfo.PRI));
	}
}

simulated function DumpLog() {
	local string Line;

	Line = string(self.Name);
	if (PlayerOwner != none && PlayerOwner.PlayerReplicationInfo != none)
		Line = Line@"'"$PlayerOwner.PlayerReplicationInfo.PlayerName$"'";
	else
		Line = Line@"''";

	if (PlayerOwner != none)
		Line = Line@PlayerOwner.Player;
	else
		Line = Line@none;

	Line = Line@"|"@bHasVoted;
	if (VotePreset != none)
		Line = Line@"'"$VotePreset.GetFullName()$"'";
	else
		Line = Line@"''";

	if (VoteMap != none)
		Line = Line@"'"$VoteMap.MapName$"'";
	else
		Line = Line@"''";

	Log(Line, 'VoteSys');
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
}
