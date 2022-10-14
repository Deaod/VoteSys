class MutVoteSys extends Mutator
	config(VoteSys);

var VS_PlayerChannel ChannelList;
var VS_Info Info;
var VS_DataServer DataServer;

var Object PresetConfigDummy;
var VS_Preset PresetList;

var Object MapListDummy;
var VS_MapList MapLists;

enum EGameState {
	GS_Playing,
	GS_GameEnded,
	GS_Voting,
	GS_VoteEnded
};

var EGameState GameState;
var int TimeCounter;
var config int GameEndedVoteDelay;
var config int VoteTimeLimit;

var config string DefaultTimeMessageClass;
var class<CriticalEventPlus> TimeMessageClass;

var config string DefaultPreset;
var VS_Preset DefaultPresetRef;

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

	ApplyVotedPreset();

	SetTimer(Level.TimeDilation, true);
	LoadConfig();
	Info = Spawn(class'VS_Info', self);
	Info.VoteSys = self;
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
	TimeCounter = VoteTimeLimit;
	BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 4);
	OpenVoteMenuForAll();
	AnnounceCountdown(TimeCounter);
}

function CheckGameEnded() {
	if (Level.Game.GameReplicationInfo.GameEndedComments == "")
		// not ended yet
		return;

	GameState = GS_GameEnded;
	TimeCounter = GameEndedVoteDelay;
}

function AnnounceCountdown(int SecondsLeft) {
	local int Num;
	local Pawn P;

	if (TimeMessageClass == none)
		TimeMessageClass = class<CriticalEventPlus>(DynamicLoadObject(DefaultTimeMessageClass, class'Class'));
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
	TimeCounter = VoteTimeLimit;
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

	SortMutators(P.Mutators, Mutators, Actors);
	if (InStr(Mutators, "MutVoteSys") == -1)
		Mutators = string(self.Class)$","$Mutators;

	Url = M.MapName$"?Game="$P.Game$"?Mutator="$Mutators$P.Parameters;

	TempDataDummy = new(none, 'VoteSysTemp') class'Object';
	TD = new(TempDataDummy, 'Data') class'VS_TempData';

	TD.Mutators = Mutators;
	TD.Actors = Actors;
	TD.GameSettings = P.GameSettings;
	TD.SaveConfig();

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
	}
}

function Mutate(string Command, PlayerPawn Sender) {
	if (Command ~= "VoteMenu") {
		OpenVoteMenu(Sender);
		return;
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

	TempDataDummy = new(none, 'VoteSysTemp') class'Object';
	TD = new(TempDataDummy, 'Data') class'VS_TempData';

	AddClassesToPackageMap(TD.Mutators);
	CreateServerActors(TD.Actors);
	AddClassesToPackageMap(TD.Actors);
	ApplyGameSettings(TD.GameSettings);

	TD.Mutators = "";
	TD.Actors = "";
	TD.GameSettings = "";
	TD.SaveConfig();
}

function AddClassToPackageMap(string ClassName) {
	local int DotPos;
	local string P;
	local class C;
	
	DotPos = InStr(ClassName, ".");
	if (DotPos >= 0) {
		P = Left(ClassName, DotPos);
	} else {
		C = class(DynamicLoadObject(ClassName, class'Class'));
		if (C != none)
			AddClassToPackageMap(string(C));
		return;
	}

	// TODO: uncomment the following lines once compiling with 469c
	// if (IsInPackageMap(P, true) == false) 
	// 	AddToPackageMap(P);
}

function AddClassesToPackageMap(string Classes) {
	local int Pos;

	if ((Level.EngineVersion$Level.GetPropertyText("EngineRevision")) < "469c")
		return;

	Pos = InStr(Classes, ",");
	while(Pos >= 0) {
		AddClassToPackageMap(Left(Classes, Pos));
		Classes = Mid(Classes, Pos+1);
		Pos = InStr(Classes, ",");
	}
	AddClassToPackageMap(Classes);
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

	Pos = InStr(GameSettings, Chr(10));
	while(Pos >= 0) {
		ApplyGameSetting(Left(GameSettings, Pos));
		GameSettings = Mid(GameSettings, Pos+1);
		Pos = InStr(GameSettings, Chr(10));
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

		if (DefaultPresetRef == none || (P != none && Len(DefaultPreset) > 0 && P.GetFullName() == DefaultPreset))
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
			P.GameSettings = P.GameSettings$Chr(10)$PC.GameSettings[i];
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
				return ML.First;

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
			return ML.First;
	}

	// If no map list specified, or no maps in map list, use all maps available for game type.
	// As before, see if the list already exists for the specified game type.
	for (ML = MapLists; ML != none; ML = ML.Next)
		if (ML.Game == Game)
			return ML.First;

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

	return ML.First;
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
	return GameState != GS_VoteEnded
		&& P.PlayerReplicationInfo != none
		&& (P.PlayerReplicationInfo.bIsSpectator == false || P.PlayerReplicationInfo.bAdmin);
}

defaultproperties {
	GameState=GS_Playing
	GameEndedVoteDelay=5
	VoteTimeLimit=30
	DefaultTimeMessageClass="Botpack.TimeMessage"
}
