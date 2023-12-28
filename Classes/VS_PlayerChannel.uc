class VS_PlayerChannel extends Info;

var PlayerPawn PlayerOwner;
var VS_PlayerInfo PInfo;
var VS_Info Info; // Info Info
var int Cookie;

var VS_DataClient DataClient;
var VS_ServerSettings ServerSettings;

var VS_Preset PresetList;
var VS_UI_VoteWindow VoteMenuDialog;
var VS_UI_SettingsWindow SettingsDialog;
var bool bOpenVoteMenuAfterTyping;
var bool bOpenSettingsAfterTyping;

var Object SettingsDummy;
var VS_ClientSettings Settings;

// Temporary variables used while receiving Preset/Map information
var VS_Preset LatestPreset;
var VS_Map LatestMap;

var VS_Candidate VotedFor;

var int KickVotesAgainstMe;
var array<PlayerReplicationInfo> IWantToKick;

var int MaxMapSequenceNumber;

replication {
	reliable if (Role < ROLE_Authority)
		ServerBanPlayer,
		ServerKickPlayer,
		ServerVote,
		ServerVoteExisting,
		ServerVoteRandom;

	reliable if (Role == ROLE_Authority)
		ClientApplyKickVote,
		DumpPlayerList,
		ShowVoteMenu,
		HideVoteMenu,
		ShowSettings;

	reliable if (Role == ROLE_Authority && bNetOwner)
		Cookie,
		VotedFor;

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

	if (bOpenSettingsAfterTyping && PlayerOwner.Player.Console.IsInState('Typing') == false) {
		bOpenSettingsAfterTyping = false;
		ShowSettings();
	}
}

simulated function VS_PlayerInfo PlayerInfo() {
	local int i;
	local VS_Info Nfo;

	if (PInfo != none)
		return PInfo;

	Nfo = VoteInfo();
	for (i = 0; i < arraycount(Nfo.PlayerInfo); i++) {
		if (PlayerOwner.PlayerReplicationInfo == Nfo.PlayerInfo[i].PRI) {
			PInfo = Nfo.PlayerInfo[i];
			return PInfo;
		}
	}

	return none;
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

		VoteMenuDialog = VS_UI_VoteWindow(C.Root.CreateWindow(
			class'VS_UI_VoteWindow',
			Settings.MenuX,
			Settings.MenuY,
			0,0 // Size set internally
		));
		if (VoteMenuDialog == none)
			return;
		VoteMenuDialog.Channel = self;
		VoteMenuDialog.LoadSettings(Settings);
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
		LocalizeMessage(class'VS_Msg_LocalMessage', -4, "VoteMenu");
		return;
	}

	if (VoteMenuDialog == none) {
		if (C.Root == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', -2, "VoteMenu");
			return;
		}

		VoteMenuDialog = VS_UI_VoteWindow(C.Root.CreateWindow(
			class'VS_UI_VoteWindow',
			Settings.MenuX,
			Settings.MenuY,
			0,0 // Size set internally
		));
		VoteMenuDialog.Channel = self;
		VoteMenuDialog.LoadSettings(Settings);
		VoteMenuDialog.HideWindow();

		if (VoteMenuDialog == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', -3, "VoteMenu");
			return;
		}
	}
}

simulated function ShowVoteMenu() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (DataClient != none && DataClient.IsConnected() == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -6);
		return;
	}

	if (DataClient == none || DataClient.bTransferDone == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -1);
		return;
	}

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -4, "VoteMenu");
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
		LocalizeMessage(class'VS_Msg_LocalMessage', -3, "VoteMenu");
		return;
	}

	VoteMenuDialog.bLeaveOnscreen = true;
	VoteMenuDialog.ShowWindow();
}

simulated function ShowSettings() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -4, "Settings");
		return;
	}

	if (C.IsInState('Typing')) {
		// delay until after player is done typing on the console
		bOpenSettingsAfterTyping = true;
		return;
	}

	if (C.bShowConsole) {
		// console is already open, no need to do anything
	} else {
		// probably a hotkey that called this function
		C.bQuickKeyEnable = True;
		C.LaunchUWindow();
	}

	if (SettingsDialog == none) {
		if (C.Root == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', -2, "Settings");
			return;
		}

		SettingsDialog = VS_UI_SettingsWindow(C.Root.CreateWindow(
			class'VS_UI_SettingsWindow',
			Settings.MenuX,
			Settings.MenuY,
			0,0 // Size set internally
		));
		SettingsDialog.HideWindow();

		if (SettingsDialog == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', -3, "Settings");
			return;
		}
	}

	SettingsDialog.bLeaveOnscreen = true;
	SettingsDialog.LoadSettings(self);
	SettingsDialog.ShowWindow();
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

	ServerVote(P.GetFullName(), M.MapName);
}

function ServerVote(string FullPresetName, string MapName) {
	local VS_Preset P;
	local VS_Map M;
	local VS_Info I;
	local int NumPlayers;

	if (PlayerOwner == none || PlayerInfo().bCanVote == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -7);
		return;
	}

	I = VoteInfo();
	P = I.ResolvePreset(FullPresetName);
	M = I.ResolveMapOfPreset(P, MapName);

	if (P == none || M == none)
		return;

	if (PlayerOwner.PlayerReplicationInfo.bAdmin == false) {
		NumPlayers = Level.Game.NumPlayers;
		if (VotedFor.PresetRef == P && VotedFor.MapRef == M)
			return;
		if (M.Sequence > 0 && P.MaxSequenceNumber - M.Sequence < P.MinimumMapRepeatDistance)
			return;
		if (NumPlayers < P.MinPlayers || (NumPlayers > P.MaxPlayers && P.MaxPlayers > 0))
			return;
		if (NumPlayers < M.MinPlayers || (NumPlayers > M.MaxPlayers && M.MaxPlayers > 0))
			return;
	}

	if (VotedFor != none)
		I.RemCandidateVote(self, VotedFor);
	VotedFor = I.AddMapVote(self, P, M);
}

simulated function VoteExisting(VS_Candidate Candidate) {
	ServerVoteExisting(Candidate);
}

function ServerVoteExisting(VS_Candidate Candidate) {
	local VS_Info I;

	if (PlayerOwner == none || PlayerInfo().bCanVote == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -7);
		return;
	}

	I = VoteInfo();

	if (Candidate == none)
		return;

	if (VotedFor == Candidate && PlayerOwner.PlayerReplicationInfo.bAdmin == false)
		return;

	if (VotedFor != none)
		I.RemCandidateVote(self, VotedFor);
	VotedFor = I.AddCandidateVote(self, Candidate);
}

simulated function VoteRandom(VS_Preset P) {
	ServerVoteRandom(P.GetFullName());
}

function ServerVoteRandom(string FullPresetName) {
	local VS_Info I;
	local VS_Preset P;

	if (PlayerOwner == none || PlayerInfo().bCanVote == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', -7);
		return;
	}

	I = VoteInfo();
	P = I.ResolvePreset(FullPresetName);

	if (P == none)
		return;

	if (VotedFor != none)
		I.RemCandidateVote(self, VotedFor);
	VotedFor = I.AddRandomVote(self, P);
}

function ClearVote() {
	if (VotedFor != none) {
		VoteInfo().RemCandidateVote(self, VotedFor);
		VotedFor = none;
	}
}

simulated function bool WantsToKick(PlayerReplicationInfo PRI) {
	local VS_PlayerInfo P;

	P = VoteInfo().GetPlayerInfoForPRI(PRI);
	if (P != none)
		return P.bLocalPlayerWantsToKick;

	return false;
}

simulated function ClientToggleKick(PlayerReplicationInfo PRI) {
	local VS_PlayerInfo P;

	P = VoteInfo().GetPlayerInfoForPRI(PRI);
	if (P != none)
		P.bLocalPlayerWantsToKick = !P.bLocalPlayerWantsToKick;
}

function bool ServerToggleKick(PlayerReplicationInfo PRI) {
	local int Index;

	for (Index = 0; Index < IWantToKick.Length; Index++) 
		if (IWantToKick[Index] == PRI)
			break;

	if (Index >= IWantToKick.Length) {
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
	ClientToggleKick(PRI);
}

simulated function BanPlayer(PlayerReplicationInfo PRI) {
	ServerBanPlayer(PRI);
}

function ServerBanPlayer(PlayerReplicationInfo PRI) {
	if (PlayerOwner == none)
		return;

	VoteInfo().BanPlayer(self, PRI);
}

simulated function VS_ServerSettings ReloadServerSettings() {
	ServerSettings = none;
	DataClient.DiscardServerSettings();
	return GetServerSettings();
}

simulated function VS_ServerSettings GetServerSettings() {
	Log("PlayerChannel GetServerSettings", 'VoteSys');
	if (ServerSettings == none) {
		ServerSettings = DataClient.GetServerSettings();
	}
	return ServerSettings;
}

simulated function SaveServerSettings() {
	Log("PlayerChannel SaveServerSettings", 'VoteSys');
	if (ServerSettings == none)
		return;

	DataClient.SaveServerSettings(ServerSettings);
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

	VS_UI_VoteClientWindow(VoteMenuDialog.ClientArea).ChatArea.AddChat(PRI, Msg);
}

simulated function DumpPlayerList() {
	local int i;
	local VS_Info Info;
	local VS_UI_PlayerListItem Item;

	Info = VoteInfo();
	for (i = 0; i < arraycount(Info.PlayerInfo); i++)
		if (Info.PlayerInfo[i] != none)
			PlayerOwner.ClientMessage("["$i$"]=("$Info.PlayerInfo[i].Dump()$")");

	for (Item = VS_UI_PlayerListItem(VS_UI_VoteClientWindow(VoteMenuDialog.ClientArea).PlayerListBox.Items.Next); Item != none; Item = VS_UI_PlayerListItem(Item.Next)) {
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

	Line = Line@"|"@(VotedFor != none);
	if (VotedFor != none)
		Line = Line@"'"$VotedFor.Preset$"'";
	else
		Line = Line@"''";

	if (VotedFor != none)
		Line = Line@"'"$VotedFor.MapName$"'";
	else
		Line = Line@"''";

	Log(Line, 'VoteSys');
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
}
