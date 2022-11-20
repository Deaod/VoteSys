class MutVoteSys extends Mutator;

var VS_PlayerChannel ChannelList;
var VS_Info Info;
var VS_DataServer DataServer;

var Object SettingsDummy;
var VS_ServerSettings Settings;

var Object PresetConfigDummy;
var VS_Preset PresetList;

var Object MapListDummy;
var VS_MapList MapLists;

var Object HistoryDummy;
var VS_HistoryConfig History;
var VS_HistoryProcessor HistoryProcessor;

enum EGameState {
	GS_Playing,
	GS_GameEnded,
	GS_Voting,
	GS_VoteEnded,
	GS_Travelling
};

var EGameState GameState;
var int TimeCounter;
var class<CriticalEventPlus> TimeMessageClass;

var VS_Preset DefaultPresetRef;
var string CurrentPreset;

var VS_Preset VotedPreset;
var VS_Map VotedMap;

function VS_PlayerChannel FindChannel(Pawn P) {
	local VS_PlayerChannel C;
	
	if (P.IsA('PlayerPawn') == false)
		return none;

	for (C = ChannelList; C != none; C = C.Next)
		if (P == C.Owner)
			return C;

	return none;
}

function CreateChannel(Pawn P) {
	local VS_PlayerChannel C;
	
	if (P.IsA('PlayerPawn') == false)
		return;

	C = Spawn(class'VS_PlayerChannel', P);
	C.PlayerOwner = PlayerPawn(P);
	C.Next = ChannelList;
	ChannelList = C;
}

event PostBeginPlay() {
	super.PostBeginPlay();

	SettingsDummy = new(none, 'VoteSys') class 'Object';
	Settings = new (SettingsDummy, 'ServerSettings') class'VS_ServerSettings';
	Settings.SaveConfig();

	if ((Level.EngineVersion$Level.GetPropertyText("EngineRevision")) < "469c" && Settings.bManageServerPackages) {
		GetDefaultServerPackages();
	}

	ApplyVotedPreset();

	SetTimer(Level.TimeDilation, true);
	LoadConfig();
	LoadHistory();
	Info = Spawn(class'VS_Info', self);
	Info.VoteSys = self;
	Info.MinimumMapRepeatDistance = Settings.MinimumMapRepeatDistance;
	DataServer = Spawn(class'VS_DataServer', self);

	Level.Game.SetPropertyText("bDontRestart", "True"); // Botpack.DeathMatchPlus and UnrealShare.DeathMatchGame
}

function CreateMissingPlayerChannels() {
	local Pawn P;

	for (P = Level.PawnList; P != none; P = P.NextPawn)
		if (P.IsA('PlayerPawn') && FindChannel(P) == none)
			CreateChannel(P);
}

function UpdatePlayerVoteInformation() {
	local int i;
	local VS_PlayerChannel C;

	for (C = ChannelList; C != none; C = C.Next) {
		if (i < 32 && C.PlayerOwner != none) {
			Info.SetPlayerInfoPRI(i, C.PlayerOwner.PlayerReplicationInfo);
			Info.SetPlayerInfoHasVoted(i, C.bHasVoted);
			i++;
		} else if (C.bHasVoted) {
			C.ClearVote();
		}
	}

	while (i < 32) {
		Info.SetPlayerInfoPRI(i, none);
		i++;
	}
}

function CheckMidGameVoting() {
	local int NumVotes;
	local int NumPlayers;
	local VS_PlayerChannel C;
	local Pawn P;

	for (C = ChannelList; C != none; C = C.Next)
		if (C.PlayerOwner != none && C.bHasVoted)
			NumVotes++;

	NumPlayers = 1; // to round up later
	for (P = Level.PawnList; P != none; P = P.NextPawn)
		if (P.IsA('PlayerPawn') && P.IsA('Spectator') == false)
			NumPlayers++;

	if (NumPlayers <= 1 || NumVotes < NumPlayers/2) // rounding up here
		return;

	GameState = GS_Voting;
	TimeCounter = Settings.VoteTimeLimit;
	BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 4);
	OpenVoteMenuForAll();
	AnnounceCountdown(TimeCounter);
}

function CheckGameEnded() {
	if (Level.Game.GameReplicationInfo.GameEndedComments == "")
		// not ended yet
		return;

	GameState = GS_GameEnded;
	TimeCounter = Settings.GameEndedVoteDelay;
}

function AnnounceCountdown(int SecondsLeft) {
	local int Num;
	local Pawn P;

	if (TimeMessageClass == none)
		TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject(Settings.DefaultTimeMessageClass, class'Class'));
	if (SecondsLeft <= 10 && SecondsLeft > 0) {
		Num = SecondsLeft;
	} else if (SecondsLeft == 30) {
		Num = 11;
	} else if (SecondsLeft == 60) {
		Num = 12;
	} else if (SecondsLeft == 120) {
		Num = 13;
	} else if (SecondsLeft == 180) {
		Num = 14;
	} else if (SecondsLeft == 240) {
		Num = 15;
	} else if (SecondsLeft == 300) {
		Num = 16;
	} else {
		return;
	}

	for (P = Level.PawnList; P != none; P = P.NextPawn) {
		if (P.IsA('TournamentPlayer'))
			TournamentPlayer(P).TimeMessage(Num);
		else if (P.IsA('PlayerPawn'))
			P.ReceiveLocalizedMessage(TimeMessageClass, 16 - Num);
	}
}

function TickVoteMenuDelay() {
	TimeCounter--;
	if (TimeCounter > 0)
		return;

	GameState = GS_Voting;
	TimeCounter = Settings.VoteTimeLimit;
	BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 5);
	OpenVoteMenuForAll();
	AnnounceCountdown(TimeCounter);
}

function SortMutator(string ClassName, out string Mutators, out string Actors) {
	local class C;

	if (ClassName == "")
		return;

	C = class(DynamicLoadObject(ClassName, class'Class'));
	if (C == none)
		return;

	if (ClassIsChildOf(C, class'Mutator')) {
		if (Len(Mutators) <= 0) {
			Mutators = ClassName;
		} else if (InStr(Mutators, ClassName) == -1) {
			Mutators = Mutators$","$ClassName;
		}
	} else if (InStr(Actors, ClassName) == -1) {
		if (Len(Actors) <= 0) {
			Actors = ClassName;
		} else {
			Actors = Actors$","$ClassName;
		}
	}
}

function SortMutators(string CombinedList, out string Mutators, out string Actors) {
	local string E;
	local int Pos;

	Pos = InStr(CombinedList, ",");
	while (Pos >= 0) {
		E = Left(CombinedList, Pos);
		SortMutator(E, Mutators, Actors);
		CombinedList = Mid(CombinedList, Pos+1);
		Pos = InStr(CombinedList, ",");
	}
	SortMutator(CombinedList, Mutators, Actors);
}

function TravelTo(VS_Preset P, VS_Map M) {
	local string Url;
	local string Mutators;
	local string Actors;
	local Object TempDataDummy;
	local VS_TempData TD;
	local array<string> Pkgs;

	SortMutators(P.Mutators, Mutators, Actors);
	if (InStr(Mutators, "MutVoteSys") == -1)
		Mutators = string(self.Class)$","$Mutators;

	Url = M.MapName$"?Game="$P.Game$"?Mutator="$Mutators$P.Parameters;

	TempDataDummy = new(none, 'VoteSysTemp') class'Object';
	TD = new(TempDataDummy, 'Data') class'VS_TempData';

	TD.PresetName = P.PresetName;
	TD.Category = P.Category;
	TD.Mutators = Mutators;
	TD.Actors = Actors;
	TD.GameSettings = P.GameSettings;
	TD.SaveConfig();

	History.InsertVote(P.Category, P.PresetName, M.MapName);
	History.SaveConfig();

	if ((Level.EngineVersion$Level.GetPropertyText("EngineRevision")) < "469c" && Settings.bManageServerPackages) {
		Pkgs = Settings.DefaultPackages;
		AddClassesToPackageMap(TD.Mutators, Pkgs);
		AddClassesToPackageMap(TD.Actors, Pkgs);
		SetServerPackages(Pkgs);
	}

	Level.ServerTravel(Url, false);
}

function AdminForceTravelTo(VS_Preset P, VS_Map M) {
	GameState = GS_VoteEnded;
	TimeCounter = 5;
	VotedPreset = P;
	VotedMap = M;
	CloseVoteMenuForAll();
}

function VS_Map SelectRandomMapFromList(VS_Map MapList) {
	local float Target;
	local float TargetCount;
	local VS_Map M;
	local VS_Map Result;

	if (MapList == none)
		return none;

	Target = FRand();
	M = MapList;
	Result = MapList;
	while (M.Next != none) {
		M = M.Next;
		TargetCount += Target;
		if (TargetCount >= 1.0) {
			TargetCount -= 1.0;
			Result = Result.Next;
		}
	}

	return Result;
}

function TallyVotes() {
	local int i, Score;
	local int BestScore;
	local int CountTiedCandidates;
	local float TiedCandidatesFraction;
	local float RandomCandidate;
	local VS_Map M;

	BestScore = 0;
	CountTiedCandidates = 0;

	for (i = 0; i < Info.NumCandidates; i++) {
		Score = Info.GetCandidateVotes(i);
		if (Score > BestScore) {
			BestScore = Score;
			CountTiedCandidates = 1;
		} else if (Score == BestScore) {
			CountTiedCandidates++;
		}
	}

	if (CountTiedCandidates == 0) {
		// nobody voted
		if (DefaultPresetRef == none) {
			// cant do anything, let the game handle this
			Level.Game.SetPropertyText("bDontRestart", "False");
			return;
		}
		M = SelectRandomMapFromList(DefaultPresetRef.MapList);
		if (M == none)
			return;

		VotedPreset = DefaultPresetRef;
		VotedMap = M;

		BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 1, VotedMap.MapName@"("$VotedPreset.Abbreviation$")");
		return;
	}

	TiedCandidatesFraction = 1.0 / CountTiedCandidates;
	RandomCandidate = FRand(); // [0..1] // inclusive at both ends

	for (i = 0; i < Info.NumCandidates; i++) {
		if (Info.GetCandidateVotes(i) == BestScore) {
			RandomCandidate -= TiedCandidatesFraction;
			if (RandomCandidate <= 0.0) {
				// this is the one
				break;
			}
		}
	}

	VotedPreset = Info.GetCandidateInternalPreset(i);
	VotedMap = Info.GetCandidateInternalMap(i);

	if (CountTiedCandidates > 1) {
		BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 2, VotedMap.MapName@"("$VotedPreset.Abbreviation$")");
	} else {
		BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 3, VotedMap.MapName@"("$VotedPreset.Abbreviation$")");
	}
}

function TickVoteTime() {
	TimeCounter--;
	AnnounceCountdown(TimeCounter);
	if (TimeCounter > 0)
		return;

	GameState = GS_VoteEnded;
	TallyVotes();
	CloseVoteMenuForAll();
	TimeCounter = 5;
}

function TickTimeBeforeTravel() {
	TimeCounter--;
	if (TimeCounter > 0)
		return;

	GameState = GS_Travelling;
	TravelTo(VotedPreset, VotedMap);
}

event Timer() {
	CreateMissingPlayerChannels();
	UpdatePlayerVoteInformation();
	switch(GameState) {
		case GS_Playing:
			CheckMidGameVoting();
			CheckGameEnded();
			break;
		case GS_GameEnded:
			TickVoteMenuDelay();
			break;
		case GS_Voting:
			TickVoteTime();
			break;
		case GS_VoteEnded:
			TickTimeBeforeTravel();
			break;
		case GS_Travelling:
			break;
	}
}

function Mutate(string Command, PlayerPawn Sender) {
	if (Command ~= "VoteMenu") {
		OpenVoteMenu(Sender);
		return;
	} else if (Command ~= "bdbmapvote votemenu") {
		OpenVoteMenu(Sender);
	}

	super.Mutate(Command, Sender);
}

function OpenVoteMenuForAll() {
	local VS_PlayerChannel C;
	for (C = ChannelList; C != none; C = C.Next)
		if (C.PlayerOwner != none)
			C.ShowVoteMenu();
}

function CloseVoteMenuForAll() {
	local VS_PlayerChannel C;
	for (C = ChannelList; C != none; C = C.Next)
		if (C.PlayerOwner != none)
			C.HideVoteMenu();
}

function OpenVoteMenu(PlayerPawn P) {
	local VS_PlayerChannel C;

	if (CanVote(P) == false)
		return;

	C = FindChannel(P);
	if (C == none) {
		Log("Could not find Channel for"@P.PlayerReplicationInfo.PlayerName@"("$P.PlayerReplicationInfo.PlayerId$")", 'VoteSys');
		return;
	}

	C.ShowVoteMenu();
}

function ApplyVotedPreset() {
	local Object TempDataDummy;
	local VS_TempData TD;
	local array<string> Pkgs;
	local int i;

	TempDataDummy = new(none, 'VoteSysTemp') class'Object';
	TD = new(TempDataDummy, 'Data') class'VS_TempData';

	if (TD.PresetName != "")
		CurrentPreset = TD.Category$"/"$TD.PresetName;
	CreateServerActors(TD.Actors);
	ApplyGameSettings(TD.GameSettings);

	if ((Level.EngineVersion$Level.GetPropertyText("EngineRevision")) >= "469c" && Settings.bManageServerPackages) {
		AddClassToPackageMap(TD.Mutators, Pkgs);
		AddClassToPackageMap(TD.Actors, Pkgs);
		for (i = 0; i < Pkgs.Length; i++)
			if (IsInPackageMap(Pkgs[i], true) == false)
				AddToPackageMap(Pkgs[i]);
	}
}

function AddClassToPackageMap(string ClassName, out array<string> PkgMap) {
	local int DotPos;
	local string P;
	local class C;
	
	DotPos = InStr(ClassName, ".");
	if (DotPos >= 0) {
		P = Left(ClassName, DotPos);
	} else {
		C = class(DynamicLoadObject(ClassName, class'Class'));
		if (C != none)
			AddClassToPackageMap(string(C), PkgMap);
		return;
	}

	if (IsPackageInPackageMap(P, PkgMap) == false)
		InsertPackageIntoPackageMap(P, PkgMap);
}

function bool IsPackageInPackageMap(string Pkg, out array<string> PkgMap) {
	local int i;
	for (i = 0; i < PkgMap.Length; i++)
		if (PkgMap[i] ~= Pkg)
			return true;

	return false;
}

function InsertPackageIntoPackageMap(string Pkg, out array<string> PkgMap) {
	PkgMap.Insert(PkgMap.Length);
	PkgMap[PkgMap.Length - 1] = Pkg;
}

function AddClassesToPackageMap(string Classes, out array<string> PkgMap) {
	local int Pos;

	Pos = InStr(Classes, ",");
	while(Pos >= 0) {
		AddClassToPackageMap(Left(Classes, Pos), PkgMap);
		Classes = Mid(Classes, Pos+1);
		Pos = InStr(Classes, ",");
	}
	AddClassToPackageMap(Classes, PkgMap);
}

function AppendDefaultServerPackage(string Pkg) {
	Settings.DefaultPackages.Insert(Settings.DefaultPackages.Length, 1);
	Settings.DefaultPackages[Settings.DefaultPackages.Length - 1] = Pkg;
}

function GetDefaultServerPackages() {
	local string Prop;
	local int Pos;

	if (Settings.DefaultPackages.Length > 0)
		return; // already done

	Prop = ConsoleCommand("get Engine.GameEngine ServerPackages");
	Log("Packages="$Prop, 'VoteSys');
	Prop = Mid(Prop, 1, Len(Prop)-2); // remove ( and )

	Pos = InStr(Prop, "\"");
	while(Pos >= 0) {
		Prop = Mid(Prop, Pos + 1);
		Pos = InStr(Prop, "\"");
		if (Pos >= 0) {
			AppendDefaultServerPackage(Left(Prop, Pos));
			Prop = Mid(Prop, Pos + 1);
		} else {
			AppendDefaultServerPackage(Prop);
		}

		Pos = InStr(Prop, "\"");
	}

	Settings.SaveConfig();
}

function SetServerPackages(array<string> Packages) {
	local string Value;
	local int i;

	if (Packages.Length <= 0)
		return;

	Value = "\""$Packages[0]$"\""; // hardcode first to save inside loop
	for (i = 1; i < Packages.Length; i++) {
		Value = Value$",\""$Packages[i]$"\"";
	}

	Log("Packages=("$Value$")", 'VoteSys');
	ConsoleCommand("set Engine.GameEngine ServerPackages ("$Value$")");
}

function CreateServerActor(string ClassName) {
	local class<Actor> C;

	C = class<Actor>(DynamicLoadObject(ClassName, class'Class'));
	if (C != none)
		Level.Game.Spawn(C);
}

function CreateServerActors(string Actors) {
	local int Pos;

	Pos = InStr(Actors, ",");
	while(Pos >= 0) {
		CreateServerActor(Left(Actors, Pos));
		Actors = Mid(Actors, Pos+1);
		Pos = InStr(Actors, ",");
	}
	CreateServerActor(Actors);
}

function ApplyGameSetting(string Setting) {
	local int Pos;
	local string Key, Value;

	Pos = InStr(Setting, "=");
	if (Pos == -1)
		return;

	Key = Left(Setting, Pos);
	Value = Mid(Setting, Pos+1);

	Level.Game.SetPropertyText(Key, Value);
}

function ApplyGameSettings(string GameSettings) {
	local int Pos;

	Pos = InStr(GameSettings, ",");
	while(Pos >= 0) {
		ApplyGameSetting(Left(GameSettings, Pos));
		GameSettings = Mid(GameSettings, Pos+1);
		Pos = InStr(GameSettings, ",");
	}
	ApplyGameSetting(GameSettings);
}

function LoadConfig() {
	local VS_PresetConfig PC;
	local VS_Preset P;

	PresetConfigDummy = new(none, 'VoteSysPresets')  class'Object';
	MapListDummy      = new(none, 'VoteSysMapLists') class'Object';

	while(true) {
		PC = new(PresetConfigDummy) class'VS_PresetConfig';
		Log("Try Loading"@PC.Name, 'VoteSys');
		if (PC.PresetName == "")
			return;

		if (PresetList == none) {
			P = LoadPreset(PC);
			PresetList = P;
		} else {
			P.Next = LoadPreset(PC);
			if (P.Next != none)
				P = P.Next;
		}

		if (DefaultPresetRef == none || (P != none && Len(Settings.DefaultPreset) > 0 && P.GetFullName() == Settings.DefaultPreset))
			DefaultPresetRef = P;
	}

	if (PresetList == none) {
		Level.Game.SetPropertyText("bDontRestart", "False");
		Destroy();
	}
}

function VS_Preset LoadPreset(VS_PresetConfig PC) {
	local class<GameInfo> Game;
	local VS_Preset P;
	local int i;

	Game = class<GameInfo>(DynamicLoadObject(PC.Game, class'Class'));
	if (Game == none)
		return none;

	Log("Adding Preset '"$PC.Category$"/"$PC.PresetName$"' ("$PC.Abbreviation$")", 'VoteSys');

	P = new(PresetConfigDummy) class'VS_Preset';
	P.PresetName   = PC.PresetName;
	P.Abbreviation = PC.Abbreviation;
	P.Category     = PC.Category;
	P.Game         = Game;
	P.MapList      = LoadMapList(Game, PC.MapListName);

	if (PC.Mutators.Length > 0) {
		P.Mutators = PC.Mutators[0];
		for (i = 1; i < PC.Mutators.Length; i++)
			P.Mutators = P.Mutators$","$PC.Mutators[i];
	}

	if (PC.Parameters.Length > 0) {
		for (i = 0; i < PC.Parameters.Length; i++)
			P.Parameters = P.Parameters$PC.Parameters[i];
	}

	if (PC.GameSettings.Length > 0) {
		P.GameSettings = PC.GameSettings[0];
		for (i = 1; i < PC.GameSettings.Length; i++)
			P.GameSettings = P.GameSettings$","$PC.GameSettings[i];
	}

	return P;
}

function VS_Map LoadMapList(class<GameInfo> Game, name ListName) {
	local VS_MapListConfig MC;
	local VS_MapList ML;
	local VS_Map M;
	local string FirstMap;
	local string MapName;
	local int i;

	Log("    Loading List '"$ListName$"' for"@Game, 'VoteSys');

	// Use specified map list
	if (ListName != '') {
		// dont recreate if it already exists
		for (ML = MapLists; ML != none; ML = ML.Next)
			if (ML.ListName == string(ListName))
				return ML.DuplicateList();

		MC = new(MapListDummy, ListName) class'VS_MapListConfig';

		ML = new(MapListDummy) class'VS_MapList';
		ML.ListName = string(ListName);

		for (i = 0; i < MC.Map.Length; i++) {
			if (!(Left(MC.Map[i], Len(Game.default.MapPrefix)) ~= Game.default.MapPrefix))
				continue;

			if (ML.First == none) {
				M = new(ML) class'VS_Map';
				ML.First = M;
			} else {
				M.Next = new(ML) class'VS_Map';
				M = M.Next;
			}
			M.MapName = MC.Map[i];
		}

		if (ML.First != none)
			return ML.DuplicateList();
	}

	// If no map list specified, or no maps in map list, use all maps available for game type.
	// As before, see if the list already exists for the specified game type.
	for (ML = MapLists; ML != none; ML = ML.Next)
		if (ML.Game == Game)
			return ML.DuplicateList();

	ML = new(MapListDummy) class'VS_MapList';
	ML.Next = MapLists;
	MapLists = ML;
	ML.Game = Game;
	
	FirstMap = GetMapName(Game.default.MapPrefix, "", 0);
	if (FirstMap == "")
		return none; // no maps for this game type
	MapName = FirstMap;

	do {
		// ignore tutorial maps for game types
		if (!(Left(MapName, Len(MapName) - 4) ~= (Game.default.MapPrefix$"-Tutorial"))) {
			if (ML.First == none) {
				M = new(ML) class'VS_Map';
				ML.First = M;
			} else {
				M.Next = new(ML) class'VS_Map';
				M = M.Next;
			}
			M.MapName = Left(MapName, Len(MapName) - 4); // we dont care about extension
		}

		MapName = GetMapName(Game.default.MapPrefix, MapName, 1);
	} until(MapName == FirstMap);

	return ML.DuplicateList();
}

function LoadHistory() {
	HistoryDummy = new(none, 'VoteSysHistory') class'Object';
	History = new(HistoryDummy, 'History') class'VS_HistoryConfig';

	HistoryProcessor = Spawn(class'VS_HistoryProcessor');
	HistoryProcessor.VoteSys = self;
	HistoryProcessor.History = History;
	HistoryProcessor.PresetList = PresetList;
}

function BroadcastLocalizedMessage2(
	class<LocalMessage> MessageClass,
	optional int Switch,
	optional string Param1,
	optional string Param2,
	optional string Param3,
	optional string Param4,
	optional string Param5
) {
	local VS_PlayerChannel C;
	for (C = ChannelList; C != none; C = C.Next)
		if (C.PlayerOwner != none)
			C.LocalizeMessage(MessageClass, Switch, Param1, Param2, Param3, Param4, Param5);
}

function bool CanVote(PlayerPawn P) {
	return GameState < GS_VoteEnded
		&& P.PlayerReplicationInfo != none
		&& (P.IsA('Spectator') == false || P.PlayerReplicationInfo.bAdmin);
}

defaultproperties {
	GameState=GS_Playing
}
