class VS_PlayerChannel extends Info
	imports(VS_Msg_LocalMessage)
	imports(VS_Util_Logging)
	imports(VS_Util_String);

var PlayerPawn PlayerOwner;
var VS_PlayerInfo PInfo;
var VS_Info Info; // Info Info

enum ECookieSaveState {
	CKSS_Initial,
	CKSS_Save,
	CKSS_Done
};

var int Cookie;
var ECookieSaveState CookieSaveState;
var bool bLastCookieChecked;

var VS_Data_Peer DataPeer;
var VS_Net_ChannelLink DataChannel;
var VS_FavoritesProcessor FavoritesProcessor;
var VS_ServerSettings ServerSettings;
var VS_ClientPresetList ServerPresets;
var VS_ClientMapListsContainer ServerMapLists;

var VS_Preset PresetList;
var VS_UIV_Window VoteMenuDialog;
var VS_UIS_Window SettingsDialog;
var bool bOpenVoteMenuAfterTyping;
var bool bOpenSettingsAfterTyping;

var Object SettingsDummy;
var VS_ClientSettings Settings;
var bool bSettingsInitialized;

// Temporary variables used while receiving Preset/Map information
var VS_Preset LatestPreset;
var VS_Map LatestMap;

var VS_Candidate VotedFor;
var int MapRating;

var int KickVotesAgainstMe;
var array<PlayerReplicationInfo> IWantToKick;

var int MaxMapSequenceNumber;

struct Range {
	var int Beg;
	var int End;
};

replication {
	reliable if (Role < ROLE_Authority)
		ServerBanPlayer,
		ServerSetupFallbackDataTransport,
		ServerKickPlayer,
		ServerVote,
		ServerVoteExisting,
		ServerVoteRandom,
		ServerFindMapRating,
		ServerSetMapRating;

	reliable if (Role == ROLE_Authority)
		ClientApplyKickVote,
		ClientApplyOldMapRating,
		DumpPlayerList,
		ShowVoteMenu,
		HideVoteMenu,
		ShowSettings;

	reliable if (Role == ROLE_Authority && bNetOwner)
		Cookie,
		VotedFor,
		MapRating;

	reliable if (Role == ROLE_Authority && ((bDemoRecording == false) || (bClientDemoRecording && bClientDemoNetFunc) || (Level.NetMode == NM_Standalone)))
		LocalizeMessage, ChatMessage;
}

simulated function ReloadConfigFiles() {
	PlayerOwner = PlayerPawn(Owner);
	if (PlayerOwner == none || Viewport(PlayerOwner.Player) == none)
		return;

	if ((Level.EngineVersion$Level.GetPropertyText("EngineRevision")) < "469d")
		return;

	ConsoleCommand("RELOADCONFIG"@string(class'VS_ClientSettings'));
}

function ServerSetupCustomDataTransport(VS_Net_TcpLink Link) {
	DataPeer = Spawn(class'VS_Data_Server', self);
	DataPeer.Link = Link;
	Link.Peer = DataPeer;
	DataPeer.Connected();
}

simulated function ClientSetupCustomDataTransport(string Address, int Port) {
	local VS_Net_TcpLink Link;

	Link = Spawn(class'VS_Net_TcpLink');
	Link.Peer = DataPeer;
	DataPeer.Link = Link;
	Link.ConnectTo(Address, Port);
}

function ServerSetupFallbackDataTransport() {
	LogDbg("VS_PlayerChannel ServerSetupFallbackDataTransport");

	DataChannel = Spawn(class'VS_Net_ChannelLink', self);

	DataPeer = Spawn(class'VS_Data_Server', self);
	DataPeer.Chan = DataChannel;
	
	DataChannel.Peer = DataPeer;

	DataPeer.Connected();
}

simulated function ClientSetupFallbackDataTransport(VS_Net_ChannelLink Chan) {
	LogDbg("VS_PlayerChannel ClientSetupFallbackDataTransport");

	DataChannel = Chan;
	DataChannel.Peer = DataPeer;
	DataPeer.Chan = DataChannel;
	DataChannel.ClientEnableConnection();
	DataPeer.Connected();
}

simulated event Tick(float Delta) {
	if (PlayerOwner == none) {
		if (Owner != none) {
			PlayerOwner = PlayerPawn(Owner);
		}
	}

	if (PlayerOwner == none)
		return;

	if (bSettingsInitialized == false) {
		if (Viewport(PlayerOwner.Player) != none && 
			(Level.EngineVersion$Level.GetPropertyText("EngineRevision")) >= "469d"
		) {
			ConsoleCommand("RELOADCONFIG"@string(class'VS_ClientSettings'));
		}

		SettingsDummy = new(none, 'VoteSys') class 'Object';
		Settings = new (SettingsDummy, 'ClientSettings') class'VS_ClientSettings';
		FavoritesProcessor = Spawn(class'VS_FavoritesProcessor', self);

		if (Viewport(PlayerOwner.Player) != none) {
			ServerFindMapRating(Settings.LastCookie);
		}

		bSettingsInitialized = true;
	}

	if (PlayerOwner.Player == none || PlayerOwner.Player.IsA('Viewport') == false)
		return;

	if (VoteMenuDialog == none)
		TryCreateVoteMenuDialog();

	if (VoteMenuDialog == none)
		return;

	if (DataPeer == none)
		DataPeer = Spawn(class'VS_Data_Client', self);

	if (bOpenVoteMenuAfterTyping && PlayerOwner.Player.Console.IsInState('Typing') == false) {
		bOpenVoteMenuAfterTyping = false;
		ShowVoteMenu();
	}

	if (bOpenSettingsAfterTyping && PlayerOwner.Player.Console.IsInState('Typing') == false) {
		bOpenSettingsAfterTyping = false;
		ShowSettings();
	}

	if (CookieSaveState == CKSS_Save && Cookie != 0) {
		Settings.LastCookie = Cookie;
		CookieSaveState = CKSS_Done;
		Settings.SaveConfig();
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

		VoteMenuDialog = VS_UIV_Window(C.Root.CreateWindow(
			class'VS_UIV_Window',
			Settings.MenuX,
			Settings.MenuY,
			0,0 // Size set internally
		));
		if (VoteMenuDialog == none)
			return;
		VoteMenuDialog.LoadSettings(self);
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
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrWrongConsole, "VoteMenu");
		return;
	}

	if (VoteMenuDialog == none) {
		if (C.Root == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrNoRootWindow, "VoteMenu");
			return;
		}

		VoteMenuDialog = VS_UIV_Window(C.Root.CreateWindow(
			class'VS_UIV_Window',
			Settings.MenuX,
			Settings.MenuY,
			0,0 // Size set internally
		));
		VoteMenuDialog.LoadSettings(self);
		VoteMenuDialog.HideWindow();

		if (VoteMenuDialog == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrCreateDialog, "VoteMenu");
			return;
		}
	}
}

simulated function ShowVoteMenu() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (DataPeer != none && 
		DataPeer.IsConnected() == false && 
		(DataChannel == none || DataChannel.bEnableTraffic == false)
	) {
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrNoConnection);
		return;
	}

	if (DataPeer == none || VS_Data_Client(DataPeer).bTransferDone == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrStillLoading);
		return;
	}

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none) {
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrWrongConsole, "VoteMenu");
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
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrCreateDialog, "VoteMenu");
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
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrWrongConsole, "Settings");
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
			LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrNoRootWindow, "Settings");
			return;
		}

		SettingsDialog = VS_UIS_Window(C.Root.CreateWindow(
			class'VS_UIS_Window',
			Settings.SettingsX,
			Settings.SettingsY,
			0,0 // Size set internally
		));
		SettingsDialog.HideWindow();

		if (SettingsDialog == none) {
			LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrCreateDialog, "Settings");
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

simulated function ConfigureLogo(string Tex, int TexX, int TexY, int TexW, int TexH, int DrawX, int DrawY, int DrawW, int DrawH) {
	if (VoteMenuDialog == none)
		CreateVoteMenuDialog();

	VoteMenuDialog.ConfigureLogo(Tex, TexX, TexY, TexW, TexH, DrawX, DrawY, DrawW, DrawH);
}

simulated function ConfigureLogoButton(int Index, string Label, string LinkURL) {
	if (VoteMenuDialog == none)
		CreateVoteMenuDialog();

	VoteMenuDialog.ConfigureLogoButton(Index, Label, LinkURL);
}

simulated function AddMap(VS_Map M) {
	if (LatestPreset.MapList == none) {
		LatestPreset.MapList = M;
	} else {
		LatestMap.Next = M;
	}
	LatestMap = M;
}

simulated function ToggleFavorite(VS_Map M, VS_Preset PrioPreset) {
	local Range R;

	R = FindFavoriteRule(Settings.FavoritesList, M.MapName);
	if (R.Beg >= 0) {
		Settings.FavoritesList = Left(Settings.FavoritesList, R.Beg) $ Mid(Settings.FavoritesList, R.End+1);
	} else {
		Settings.FavoritesList = Settings.FavoritesList $ M.MapName $ ",";
	}
	Settings.SaveConfig();
	UpdateFavorites(PrioPreset);
}

simulated function UpdateFavorites(optional VS_Preset PrioPreset) {
	FavoritesProcessor.UpdateFavorites(PresetList, Settings.FavoritesList, PrioPreset);
}

simulated function UpdateFavoritesEnd() {
	if (VoteMenuDialog != none)
		VoteMenuDialog.UpdateFavoritesEnd();
}

simulated function Range FindFavoriteRule(string Rules, string M) {
	local string List;
	local string Part;
	local int Pos, Old;
	local Range Result;

	List = Rules;
	Old = 0;
	Pos = InStr(List, ",");
	while (Pos >= 0) {
		Part = Trim(Left(List, Pos));

		if (M ~= Part) {
			Result.Beg = Old;
			Result.End = Old+Pos;
			return Result;
		}

		List = Mid(List, Pos + 1);
		Old += Pos + 1;
		Pos = InStr(List, ",");
	}

	if (M ~= List) {
		Result.Beg = Old;
		Result.End = Len(List);
		return Result;
	}

	Result.Beg = -1;
	Result.End = -1;
	return Result;
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

	I = VoteInfo();

	if (I.VoteSys.CanVote(PlayerOwner) == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrNotAllowed);
		return;
	}

	P = I.ResolvePreset(FullPresetName);
	M = I.ResolveMapOfPreset(P, MapName);

	if (P == none || M == none)
		return;

	if (PlayerOwner.bAdmin == false) {
		NumPlayers = Level.Game.NumPlayers;
		if (VotedFor != none && VotedFor.PresetRef == P && VotedFor.MapRef == M)
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

	I = VoteInfo();

	if (I.VoteSys.CanVote(PlayerOwner) == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrNotAllowed);
		return;
	}

	if (Candidate == none)
		return;

	if (VotedFor == Candidate && PlayerOwner.bAdmin == false)
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

	I = VoteInfo();

	if (PlayerOwner == none || I.VoteSys.CanVote(PlayerOwner) == false) {
		LocalizeMessage(class'VS_Msg_LocalMessage', EVS_MsgId.ErrNotAllowed);
		return;
	}

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

simulated function ClientSetKick(PlayerReplicationInfo PRI, bool bWantKick) {
	local VS_PlayerInfo P;

	P = VoteInfo().GetPlayerInfoForPRI(PRI);
	if (P != none)
		P.bLocalPlayerWantsToKick = bWantKick;
}

function int ServerKickIndex(PlayerReplicationInfo PRI) {
	local int Index;

	for (Index = 0; Index < IWantToKick.Length; Index++)
		if (IWantToKick[Index] == PRI)
			return Index;

	return -1;
}

function bool ServerToggleKick(PlayerReplicationInfo PRI, int Index) {
	if (Index < 0) {
		IWantToKick.Insert(0, 1);
		IWantToKick[0] = PRI;
		return true;
	} else {
		IWantToKick.Remove(Index, 1);
		return false;
	}
}

simulated function KickPlayer(PlayerReplicationInfo PRI, bool bWantKick) {
	ServerKickPlayer(PRI, bWantKick);
}

function ServerKickPlayer(PlayerReplicationInfo PRI, bool bWantKick) {
	VoteInfo().KickPlayer(self, PRI, bWantKick);
}

simulated function ClientApplyKickVote(PlayerReplicationInfo PRI, bool bWantKick) {
	ClientSetKick(PRI, bWantKick);
}

simulated function BanPlayer(PlayerReplicationInfo PRI) {
	ServerBanPlayer(PRI);
}

function ServerBanPlayer(PlayerReplicationInfo PRI) {
	VoteInfo().BanPlayer(self, PRI);
}

function ServerFindMapRating(int LastCookie) {
	if (LastCookie == 0) {
		ClientApplyOldMapRating(0);
		return;
	}
	MapRating = VoteInfo().FindMapRating(self, LastCookie);
	bLastCookieChecked = true;
	ClientApplyOldMapRating(MapRating);
}

function ServerSetMapRating(int Rating) {
	if (bLastCookieChecked == false)
		return;

	VoteInfo().SetMapRating(self, Rating, MapRating);
}

simulated function SetMapRating(int Rating) {
	if (CookieSaveState != CKSS_Done)
		return;
	ServerSetMapRating(Rating);
}

simulated function ClientApplyOldMapRating(int Rating) {
	if (CookieSaveState == CKSS_Initial) {
		MapRating = Rating;
		CookieSaveState = CKSS_Save;
	}
}

simulated function VS_ServerSettings ReloadServerSettings() {
	ServerSettings = none;
	VS_Data_Client(DataPeer).DiscardServerSettings();
	return GetServerSettings();
}

simulated function VS_ServerSettings GetServerSettings() {
	LogDbg("PlayerChannel GetServerSettings");
	if (ServerSettings == none) {
		ServerSettings = VS_Data_Client(DataPeer).GetServerSettings();
	}
	return ServerSettings;
}

simulated function SaveServerSettings() {
	LogDbg("PlayerChannel SaveServerSettings");
	if (ServerSettings == none)
		return;

	VS_Data_Client(DataPeer).SaveServerSettings(ServerSettings);
}

simulated function VS_ClientPresetList ReloadServerPresets() {
	ServerPresets = none;
	VS_Data_Client(DataPeer).DiscardServerPresets();
	return GetServerPresets();
}

simulated function VS_ClientPresetList GetServerPresets() {
	LogDbg("PlayerChannel GetServerPresets");
	if (ServerPresets == none) {
		ServerPresets = VS_Data_Client(DataPeer).GetServerPresets();
	}
	return ServerPresets;
}

simulated function SaveServerPresets() {
	LogDbg("PlayerChannel SavePresetSettings");
	if (ServerPresets == none)
		return;

	VS_Data_Client(DataPeer).SaveServerPresets(ServerPresets);
}

simulated function VS_ClientMapListsContainer ReloadServerMapLists() {
	ServerMapLists = none;
	VS_Data_Client(DataPeer).DiscardServerMapLists();
	return GetServerMapLists();
}

simulated function VS_ClientMapListsContainer GetServerMapLists() {
	LogDbg("PlayerChannel GetServerMapLists");
	if (ServerMapLists == none) {
		ServerMapLists = VS_Data_Client(DataPeer).GetServerMapLists();
	}
	return ServerMapLists;
}

simulated function SaveServerMapLists() {
	LogDbg("PlayerChannel SaveServerMapLists");
	if (ServerMapLists == none)
		return;

	VS_Data_Client(DataPeer).SaveServerMapLists(ServerMapLists);
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

simulated function ChatMessage(PlayerReplicationInfo PRI, string Msg, bool bTeamMsg) {
	if (VoteMenuDialog == none)
		return;

	VS_UIV_ClientWindow(VoteMenuDialog.ClientArea).ChatArea.AddChat(PRI, Msg, bTeamMsg);
}

simulated function DumpPlayerList() {
	local int i;
	local VS_Info Info;
	local VS_UI_PlayerListItem Item;

	Info = VoteInfo();
	for (i = 0; i < arraycount(Info.PlayerInfo); i++)
		if (Info.PlayerInfo[i] != none)
			PlayerOwner.ClientMessage("["$i$"]=("$Info.PlayerInfo[i].Dump()$")");

	for (Item = VS_UI_PlayerListItem(VS_UIV_ClientWindow(VoteMenuDialog.ClientArea).PlayerListBox.Items.Next); Item != none; Item = VS_UI_PlayerListItem(Item.Next)) {
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

	LogMsg(Line);
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysTick=True
}
