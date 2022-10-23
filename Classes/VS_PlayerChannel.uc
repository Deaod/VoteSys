class VS_PlayerChannel extends Info;

var VS_PlayerChannel Next;
var PlayerPawn PlayerOwner;
var VS_Info Info; // Info Info

var VS_DataClient DataClient;

var VS_Preset PresetList;
var VS_UI_Window VoteMenuDialog;

var Object SettingsDummy;
var VS_ClientSettings Settings;

// Temporary variables used while receiving Preset/Map information
var VS_Preset LatestPreset;
var VS_Map LatestMap;

// Server Player Voting Information
// unreplicated, server-only
var bool bHasVoted;
var string VoteCategory;
var string VotePresetName;
var string VoteMapName;

// Client Player Voting Information
var VS_Preset VotePreset;
var VS_Map VoteMap;

replication {
	reliable if (Role < ROLE_Authority)
		ServerVote;

	reliable if (Role == ROLE_Authority)
		ShowVoteMenu,
		HideVoteMenu;

	reliable if (Role == ROLE_Authority && ((bDemoRecording == false) || (bClientDemoRecording && bClientDemoNetFunc) || (Level.NetMode == NM_Standalone)))
		LocalizeMessage;
}

simulated event PostBeginPlay() {
	Log(self$".PostBeginPlay"@Role, 'VoteSys');
	if (Role != ROLE_Authority) {
		DataClient = Spawn(class'VS_DataClient', self);
	}

	SettingsDummy = new(none, 'VoteSys') class 'Object';
	Settings = new (SettingsDummy, 'ClientSettings') class'VS_ClientSettings';
}

simulated function VS_Info VoteInfo() {
	if (Info != none)
		return Info;

	foreach AllActors(class'VS_Info', Info)
		break;

	return Info;
}

simulated function CreateVoteMenuDialog() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none) {
		PlayerOwner.ClientMessage("Failed to create VoteMenu window (Console not a WindowConsole)");
		return;
	}

	if (VoteMenuDialog == none) {
		if (C.Root == none) {
			PlayerOwner.ClientMessage("Failed to create VoteMenu window (Root does not exist)");
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

		if (VoteMenuDialog == none) {
			PlayerOwner.ClientMessage("Failed to create VoteMenu window (Could not create Dialog)");
			return;
		}
	}
}

simulated function ShowVoteMenu() {
	local WindowConsole C;

	if (PlayerOwner == none)
		PlayerOwner = PlayerPawn(Owner);

	if (PlayerOwner.Player != none)
		C = WindowConsole(PlayerOwner.Player.Console);

	if (C == none) {
		PlayerOwner.ClientMessage("Failed to create VoteMenu window (Console not a WindowConsole)");
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
		PlayerOwner.ClientMessage("Failed to create VoteMenu window (Could not create Dialog)");
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
	VoteMenuDialog.FocusPreset(Ref);
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
	if (PlayerOwner == none)
		return;

	if (VoteCategory == Category && VotePresetName == PresetName && VoteMapName == MapName)
		return;

	if (bHasVoted)
		VoteInfo().RemMapVote(self, VoteCategory, VotePresetName, VoteMapName);
	VoteInfo().AddMapVote(self, Category, PresetName, MapName);

	bHasVoted = true;
	VoteCategory = Category;
	VotePresetName = PresetName;
	VoteMapName = MapName;
}

simulated function VoteExisting(string Preset, string MapName) {
	ServerVoteExisting(Preset, MapName);
}

function ServerVoteExisting(string Preset, string MapName) {
	local int Index;
	local VS_Info I;
	local VS_Preset P;
	local VS_Map M;

	if (PlayerOwner == none)
		return;

	I = VoteInfo();
	Index = I.FindCandidateIndex(Preset, MapName);
	if (Index >= 0) {
		P = I.GetCandidateInternalPreset(Index);
		M = I.GetCandidateInternalMap(Index);

		ServerVote(P.Category, P.PresetName, M.MapName);
	}
}

function ClearVote() {
	if (bHasVoted) {
		VoteInfo().RemMapVote(self, VoteCategory, VotePresetName, VoteMapName);
		bHasVoted = false;
		VoteCategory = "";
		VotePresetName = "";
		VoteMapName = "";
	}
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

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
}
