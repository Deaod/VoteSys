class MutVoteSys extends Mutator;
// Description="Enables voting for next map"

var VS_ChannelContainer ChannelList;
var VS_Info Info;
var VS_DataServer DataServer;
var VS_ChatObserver ChatObserver;

var Object SettingsDummy;
var VS_ServerSettings Settings;

var Object PresetConfigDummy;
var Object PresetListDummy;
var VS_Preset PresetList;
var array<VS_PresetConfig> PresetArray;
var name PresetNameDummy;
var int PresetMaxIndex;

var Object MapConfigDummy;
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
var int IdleTime;
var bool bConfiguredTempData;
var bool bChangeMapImmediately;
var bool bIsDefaultMap;
var class<CriticalEventPlus> TimeMessageClass;

var VS_Preset DefaultPresetRef;
var string CurrentPreset;

var VS_Preset VotedPreset;
var VS_Map VotedMap;

var Object BannedPlayersDummy;
var VS_BannedPlayers BannedPlayers;
var array<string> BannedAddresses;

var VS_AceHandler AceHandler;

var VS_Package TempPkg;

event PostBeginPlay() {
	super.PostBeginPlay();

	SettingsDummy = new(XLevel, 'VoteSys') class 'Object';
	Settings = new(SettingsDummy, 'ServerSettings') class'VS_ServerSettings';
	Settings.SaveConfig();

	BannedPlayersDummy = new(XLevel, 'VoteSysBans') class'Object';
	BannedPlayers = new(BannedPlayersDummy, 'BannedPlayers') class'VS_BannedPlayers';

	AceHandler = Spawn(class'VS_AceHandler');

	if (Settings.bManageServerPackages &&
		(
			Settings.bUseServerPackagesCompatibilityMode ||
			(Level.EngineVersion$Level.GetPropertyText("EngineRevision")) < "469c"
		)
	) {
		GetDefaultServerPackages();
	}
	if (Settings.bUseServerActorsCompatibilityMode) {
		GetDefaultServerActors();
	}

	ApplyVotedPreset();

	SetTimer(Level.TimeDilation, true);
	LoadConfig();
	LoadHistory();
	Info = Spawn(class'VS_Info', self);
	Info.VoteSys = self;
	DataServer = Spawn(class'VS_DataServer', self);
	ChatObserver = Level.Spawn(class'VS_ChatObserver');
	ChatObserver.VoteSys = self;

	ConfigureGameMode();
}

function ConfigureGameMode() {
	if (Level.Game.IsA('Assault') && Level.Game.GetPropertyText("bDefenseSet") ~= "False")
		return;

	Level.Game.SetPropertyText("bDontRestart", "True"); // Botpack.DeathMatchPlus and UnrealShare.DeathMatchGame
}

function VS_ChannelContainer FindChannel(Pawn P) {
	local VS_ChannelContainer C;
	
	if (P == none || P.IsA('PlayerPawn') == false)
		return none;

	for (C = ChannelList; C != none; C = C.Next)
		if (P == C.PlayerOwner)
			return C;

	return none;
}

function VS_ChannelContainer FindChannelForCookie(int Cookie) {
	local VS_ChannelContainer C;

	for (C = ChannelList; C != none; C = C.Next)
		if (C.Channel != none && C.Channel.Cookie == Cookie)
			return C;

	return none;
}

function VS_ChannelContainer FindChannelForPRI(PlayerReplicationInfo PRI) {
	return FindChannel(Pawn(PRI.Owner));
}

function CreateChannel(PlayerPawn P) {
	local VS_ChannelContainer C;

	C = Spawn(class'VS_ChannelContainer');
	C.Initialize(P);
	C.Channel.Cookie = CreateCookie();
	C.Next = ChannelList;
	ChannelList = C;
}

// returns true if Cookie is not in use yet
function bool CheckCookie(int Cookie) {
	local VS_ChannelContainer C;

	for (C = ChannelList; C != none; C = C.Next)
		if (C.Channel != none && C.Channel.Cookie == Cookie)
			return false;

	return true;
}

function int CreateCookie() {
	local int Candidate;

	do {
		Candidate = (Rand(255) << 24) | (Rand(255) << 16) | (Rand(255) << 8) | Rand(255);
	} until(Candidate != 0 && CheckCookie(Candidate));

	return Candidate;
}

function KickPlayer(PlayerPawn P, string Reason) {
	Log(P.PlayerReplicationInfo.PlayerName@"("$P.GetPlayerNetworkAddress()$") was kicked from the server:"@Reason,'AdminAction');
	P.Destroy();
}

function string StripPort(string Address) {
	local int i;
	
	//Handle IPv6 address (removes the brackets)
	i = InStr(Address,"[");
	if (i == 0) {
		i = InStr(Address,"]");
		if (i > 0)
			return Mid(Address,1,i-1);
	}

	//Remove the port (if present)
	i = InStr(Address,":");
	if (i < 0)
		return Address;
	return Left(Address,i);
}

function KickBanPlayer(PlayerPawn Admin, PlayerPawn P, string Reason) {
	local string IP;
	local int j;
	local VS_ChannelContainer C;
	local Actor Chk;

	C = FindChannel(P);
	if (C != none) {
		if (Settings.bEnableACEIntegration)
			Chk = C.AceCheck;
	} else if (AceHandler.GetACE() != none) {
		Admin.ClientMessage("Banning"@P.PlayerReplicationInfo.PlayerName@"failed, please try again in a few seconds");
		return;
	}

	if (Chk != none) {
		BannedPlayers.BanPlayer(
			AceHandler.GetAceCheckHWHash(Chk),
			P.PlayerReplicationInfo.PlayerName,
			Admin.PlayerReplicationInfo.PlayerName);
	} else {
		IP = P.GetPlayerNetworkAddress();
		if (Level.Game.CheckIPPolicy(IP)) {
			IP = StripPort(IP);
			Log(P.PlayerReplicationInfo.PlayerName@"("$IP$") was banned from the server:"@Reason,'AdminAction');
			Log("Adding IP Ban for: "$IP, 'AdminAction');
			for (j = 0; j<ArrayCount(Level.Game.IPPolicies); j++)
				if (Level.Game.IPPolicies[j] == "")
					break;
			if (j < ArrayCount(Level.Game.IPPolicies))
				Level.Game.IPPolicies[j] = "DENY,"$IP;
			Level.Game.SaveConfig();
		}
	}

	P.Destroy();
}

function bool IsPlayerBanned(PlayerPawn P, Actor AceCheck) {
	local int i;
	local string Address;

	if (AceCheck != none && BannedPlayers.IsPlayerBanned(AceHandler.GetAceCheckHWHash(AceCheck)))
		return true;

	Address = P.GetPlayerNetworkAddress();
	Log("Checking if"@Address@"is banned", 'VoteSys');
	for (i = 0; i < BannedAddresses.Length; i++)
		if (Address == BannedAddresses[i])
			return true;

	return false;
}

function TempBanPlayer(PlayerPawn P) {
	local VS_ChannelContainer C;
	local Actor Chk;

	C = FindChannel(P);

	if (C != none)
		Chk = C.AceCheck;

	if (IsPlayerBanned(P, Chk))
		return;

	if (Chk != none) {
		BannedPlayers.TempBanPlayer(AceHandler.GetAceCheckHWHash(Chk), P.PlayerReplicationInfo.PlayerName, "KickVote");
	} else {
		BannedAddresses.Insert(BannedAddresses.Length, 1);
		BannedAddresses[BannedAddresses.Length - 1] = P.GetPlayerNetworkAddress();
	}
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
	local VS_ChannelContainer C;
	for (C = ChannelList; C != none; C = C.Next)
		if (C.Channel != none && C.Channel.PlayerOwner != none)
			C.Channel.LocalizeMessage(MessageClass, Switch, Param1, Param2, Param3, Param4, Param5);
}

function ChatMessage(PlayerReplicationInfo PRI, string Msg) {
	local VS_ChannelContainer C;
	for (C = ChannelList; C != none; C = C.Next)
		if (C.Channel != none && C.PlayerOwner != none)
			C.Channel.ChatMessage(PRI, Msg);
}

function Mutate(string Command, PlayerPawn Sender) {
	local int i;
	local VS_ChannelContainer C;

	if (Command ~= "VoteMenu") {
		OpenVoteMenu(Sender);
		return;
	} else if (Command ~= "bdbmapvote votemenu") {
		OpenVoteMenu(Sender);
	} else if (Command ~= "votesys settings") {
		OpenSettings(Sender);
	} else if (Command ~= "votesys dumpplayers server") {
		for (i = 0; i < 32; i++)
			if (Info.PlayerInfo[i] != none)
				Sender.ClientMessage("["$i$"]=("$Info.PlayerInfo[i].Dump()$")");
	} else if (Command ~= "votesys dumpplayers client") {
		C = FindChannel(Sender);
		if (C != none && C.Channel != none)
			C.Channel.DumpPlayerList();
	}

	super.Mutate(Command, Sender);
}

function bool WantAutomaticallyOpenVoteMenu() {
	local VS_Preset P;

	if (Settings.bOpenVoteMenuAutomatically == false)
		return false;

	P = FindPreset(CurrentPreset);
	return P == none || P.bOpenVoteMenuAutomatically;
}

function OpenVoteMenuForAll() {
	local VS_ChannelContainer C;

	if (WantAutomaticallyOpenVoteMenu() == false)
		return;

	for (C = ChannelList; C != none; C = C.Next)
		if (C.Channel != none && CanVote(C.PlayerOwner))
			C.Channel.ShowVoteMenu();
}

function CloseVoteMenuForAll() {
	local VS_ChannelContainer C;
	for (C = ChannelList; C != none; C = C.Next)
		if (C.Channel != none && CanVote(C.PlayerOwner))
			C.Channel.HideVoteMenu();
}

function OpenVoteMenu(PlayerPawn P) {
	local VS_ChannelContainer C;

	C = FindChannel(P);
	if (C == none || C.Channel == none) {
		Log("Could not find Channel for"@P.PlayerReplicationInfo.PlayerName@"("$P.PlayerReplicationInfo.PlayerId$")", 'VoteSys');
		return;
	}

	C.Channel.ShowVoteMenu();
}

function OpenSettings(PlayerPawn P) {
	local VS_ChannelContainer C;

	C = FindChannel(P);
	if (C == none || C.Channel == none) {
		Log("Could not find Channel for"@P.PlayerReplicationInfo.PlayerName@"("$P.PlayerReplicationInfo.PlayerId$")", 'VoteSys');
		return;
	}

	C.Channel.ShowSettings();
}

event Timer() {
	if (bChangeMapImmediately) {
		SetTimer(0.0, false);
		GameState = GS_VoteEnded;
		TallyVotes();
		TravelTo(VotedPreset, VotedMap);
		return;
	}

	CreateMissingPlayerChannels();
	UpdatePlayerVoteInformation();
	HandleKickVoting();
	switch(GameState) {
		case GS_Playing:
			CheckIdleTimeout();
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

function CheckIdleTimeout() {
	IdleTime++;
	if (bIsDefaultMap == false && Settings.IdleTimeout > 1 && IdleTime >= Settings.IdleTimeout) {
		QueueImmediateMapChange();
	}
}

function CreateMissingPlayerChannels() {
	local Pawn P;

	for (P = Level.PawnList; P != none; P = P.NextPawn)
		if (P.IsA('PlayerPawn') && FindChannel(P) == none)
			CreateChannel(PlayerPawn(P));
}

function UpdatePlayerVoteInformation() {
	local int i;
	local VS_ChannelContainer C;

	i = 0;
	for (C = ChannelList; C != none; C = C.Next) {
		if (i < arraycount(Info.PlayerInfo) && C.PlayerInfo != none) {
			if (C.PlayerOwner != none) {
				C.PlayerInfo.PRI = C.PlayerOwner.PlayerReplicationInfo;
				C.PlayerInfo.bIsPlayer = C.PlayerOwner.Player != none;
			} else {
				C.PlayerInfo.PRI = none;
				C.PlayerInfo.bIsPlayer = false;
			}
			if (C.Channel != none) {
				C.PlayerInfo.bHasVoted = (C.Channel.VotedFor != none);
				C.PlayerInfo.bCanVote = CanVote(C.PlayerOwner);
				if (C.PlayerInfo.bCanVote == false && (C.Channel.VotedFor != none))
					C.Channel.ClearVote();
			} else {
				C.PlayerInfo.bHasVoted = false;
				C.PlayerInfo.bCanVote = false;
			}
		}
	}

}

function HandleKickVoting() {
	local VS_ChannelContainer C;
	local VS_ChannelContainer Other;
	local int VotingPlayers;
	local int i;
	local Actor Ace;
	local Actor AceCheck;
	local Actor Chk;

	for (C = ChannelList; C != none; C = C.Next) {
		if (CanVote(C.PlayerOwner)) {
			VotingPlayers++;
		} else if (C.Channel != none) {
			for (i = C.Channel.IWantToKick.Length - 1; i >= 0; i--) {
				Other = FindChannelForPRI(C.Channel.IWantToKick[i]);
				if (Other != none && Other.Channel != none)
					Other.Channel.KickVotesAgainstMe--;
			}
			C.Channel.IWantToKick.Remove(0, C.Channel.IWantToKick.Length);
		}
	}

	if (Settings.bEnableACEIntegration) {
		Ace = AceHandler.GetACE();
	}

	for (C = ChannelList; C != none; C = C.Next) {
		if (C.Channel == none || C.PlayerOwner == none)
			continue;

		// Handle new kicks
		if (C.Channel.KickVotesAgainstMe > Settings.KickVoteThreshold * VotingPlayers) {
			BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 11,
				C.PlayerOwner.PlayerReplicationInfo.PlayerName
			);

			TempBanPlayer(C.PlayerOwner);
			KickPlayer(C.PlayerOwner, "Kick Vote Successful (VoteSys)");
		}

		if (C.KickCheckDelaySeconds <= 0)
			continue;

		C.KickCheckDelaySeconds -= 1;

		if (C.KickCheckDelaySeconds > 0)
			continue;

		if (Ace != none) {
			AceCheck = none;
			foreach AllActors(class'Actor', Chk) {
				if (Chk.IsA('IACECheck') &&
					AceHandler.GetAceCheckHWHash(Chk) != "" &&
					C.PlayerOwner.PlayerReplicationInfo.PlayerId == AceHandler.GetAceCheckPlayerId(Chk)
				) {
					AceCheck = Chk;
					break;
				}
			}
			C.AceCheck = AceCheck;
		}

		// Enforce older kicks
		if (C.PlayerOwner != none && IsPlayerBanned(C.PlayerOwner, C.AceCheck)) {
			KickPlayer(C.PlayerOwner, "Temp Banned (VoteSys)");
		}
	}
}

function CheckMidGameVoting() {
	local int NumVotes;
	local int NumPlayers;
	local VS_ChannelContainer C;

	NumPlayers = 0;
	for (C = ChannelList; C != none; C = C.Next) {
		if (C.PlayerInfo != none) {
			if (C.PlayerInfo.bIsPlayer && C.PlayerInfo.bCanVote)
				NumPlayers++;
			if (C.PlayerInfo.bHasVoted)
				NumVotes++;
		}
	}
	
	if (NumPlayers <= 0)
		return;

	IdleTime = 0;

	if ((float(NumVotes) / float(NumPlayers)) < Settings.MidGameVoteThreshold)
		return;

	GameState = GS_Voting;
	TimeCounter = Settings.MidGameVoteTimeLimit;
	if (TimeCounter <= 0)
		TimeCounter = Settings.VoteTimeLimit;
	BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 4);
	OpenVoteMenuForAll();
	AnnounceCountdown(TimeCounter);
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

function CheckGameEnded() {
	local Object TempDataDummy;
	local VS_TempData TD;

	if (GameState >= GS_GameEnded || Level.Game.bGameEnded == false)
		// mid-game voting or not ended yet
		return;

	// HACK HACK HACK
	// Should there be another multi-round gamemode that behaves like
	// Assault, extract this shit into a proxy actor that polls Level.Game
	// for the actual end of a match.
	// Or extend this condition with another gamemode, whatever ...
	if ((Level.Game.IsA('Assault') && Level.Game.GetPropertyText("bDefenseSet") ~= "False")) {
		if (bConfiguredTempData == false) {
			TempDataDummy = new(XLevel, 'VoteSysTemp') class'Object';
			TD = new(TempDataDummy, 'Data') class'VS_TempData';

			TD.bNoColdStart = true;
			TD.SaveConfig();

			bConfiguredTempData = true;
		}
		return;
	}

	GameState = GS_GameEnded;
	TimeCounter = Settings.GameEndedVoteDelay;
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

function array<string> SplitList(string List, string Delimiter) {
	local int Pos, DLen;
	local array<string> Result;

	if (List == "")
		return Result;

	DLen = Len(Delimiter);

	Pos = InStr(List, Delimiter);
	while (Pos >= 0) {
		Result.Insert(Result.Length, 1);
		Result[Result.Length - 1] = Left(List, Pos);

		List = Mid(List, Pos + DLen);
		Pos = InStr(List, Delimiter);
	}
	Result.Insert(Result.Length, 1);
	Result[Result.Length - 1] = List;

	return Result;
}

function MergeListIntoArray(string List, out array<string> Ar) {
	local array<string> L;
	local int i;
	local int Start;

	L = SplitList(List, ",");
	Start = Ar.Length;
	Ar.Insert(Start, L.Length);
	for (i = 0; i < L.Length; i++) {
		if (L[i] == "")
			continue;
		Ar[Start] = L[i];
		Start++;
	}
}

function TravelTo(VS_Preset P, VS_Map M) {
	local string Url;
	local string Mutators;
	local string ActorsList;
	local Object TempDataDummy;
	local VS_TempData TD;
	local array<string> Pkgs;
	local array<string> Actors;

	Level.Game.ResetGame();

	SortMutators(P.Mutators, Mutators, ActorsList);
	if (InStr(Mutators, "MutVoteSys") == -1)
		Mutators = string(self.Class)$","$Mutators;

	TempDataDummy = new(XLevel, 'VoteSysTemp') class'Object';
	TD = new(TempDataDummy, 'Data') class'VS_TempData';

	TD.bNoColdStart = true;
	TD.bDefaultMap = bChangeMapImmediately;
	TD.PresetName = P.PresetName;
	TD.Category = P.Category;
	TD.Mutators = Mutators;
	TD.Actors = ActorsList;
	TD.GameSettings = P.GameSettings;
	TD.Packages = P.Packages;
	TD.SaveConfig();

	if (bChangeMapImmediately == false) {
		History.InsertVote(P, M.MapName);
		History.SaveConfig();
	}

	if (Settings.bManageServerPackages &&
		(
			Settings.bUseServerPackagesCompatibilityMode ||
			(Level.EngineVersion$Level.GetPropertyText("EngineRevision")) < "469c"
		)
	) {
		Pkgs = Settings.DefaultPackages;
		AddClassesToPackageMap(TD.Mutators, Pkgs);
		AddClassesToPackageMap(TD.Actors, Pkgs);
		MergeListIntoArray(TD.Packages, Pkgs);
		SetServerPackages(Pkgs);
	}
	if (Settings.bUseServerActorsCompatibilityMode) {
		Actors = Settings.DefaultActors;
		MergeListIntoArray(TD.Actors, Actors);
		SetServerActors(Actors);
	}

	Url = M.MapName$"?Game="$P.Game$"?Mutator="$Mutators$P.Parameters;

	ServerTravel(Url, M.MapName);
}

// See Engine.LevelInfo.ServerTravel
// Clients dont need to know about the URL, since were not making them switch
// servers. So instead of handing the full URL to GameInfo.ProcessServerTravel,
// we just give it nothing as URL and rely on TRAVEL_Relative doing the right
// thing.
function ServerTravel(string ServerURL, string ClientURL) {
	if (Level.NextURL == "") {
		Level.SetTimer(0.0, false);
		Level.bNextItems = false;
		Level.NextURL = ServerURL;
		if (Level.Game != none)
			Level.Game.ProcessServerTravel(ClientURL, false);
		else
			Level.NextSwitchCountdown = 0;
	}
}

function AdminForceTravelTo(VS_Preset P, VS_Map M) {
	CloseVoteMenuForAll();
	
	VotedPreset = P;
	VotedMap = M;
	CheckVotedMap();
	
	GameState = GS_VoteEnded;
	TimeCounter = 5;
}

function TallyVotes() {
	local int BestScore;
	local int CountTiedCandidates;
	local float TiedCandidatesFraction;
	local float RandomCandidate;
	local VS_Map M;
	local VS_ChannelContainer C;
	local VS_Candidate Cd;

	BestScore = 0;
	CountTiedCandidates = 0;

	for (C = ChannelList; C != none; C = C.Next)
		if (C.Channel != none)
			C.Channel.DumpLog();


	for (Cd = Info.FirstCandidate; Cd != none; Cd = Cd.Next)
		Cd.Dump();

	if (Info.FirstCandidate == none || Info.FirstCandidate.Votes == 0) {
		// nobody voted
		if (DefaultPresetRef == none) {
			// cant do anything, let the game handle this
			Level.Game.SetPropertyText("bDontRestart", "False");
			return;
		}
		if (Settings.bAlwaysUseDefaultPreset || bChangeMapImmediately) {
			VotedPreset = DefaultPresetRef;
		} else {
			VotedPreset = Info.ResolvePreset(CurrentPreset);
		}

		if ((Settings.bAlwaysUseDefaultPreset && Settings.bAlwaysUseDefaultMap) || bChangeMapImmediately)
			M = Info.ResolveMapOfPreset(VotedPreset, Settings.DefaultMap);
		if (M == none)
			M = VotedPreset.SelectRandomMapFromList();
		if (M == none)
			return;
		VotedMap = M;
	} else {
		CountTiedCandidates = 0;
		Cd = Info.FirstCandidate;
		BestScore = Cd.Votes;
		while(Cd != none && Cd.Votes == BestScore) {
			CountTiedCandidates++;
			Cd = Cd.Next;
		}

		TiedCandidatesFraction = 1.0 / CountTiedCandidates;
		RandomCandidate = FRand(); // [0..1] // inclusive at both ends

		for (Cd = Info.FirstCandidate; Cd != none; Cd = Cd.Next) {
			RandomCandidate -= TiedCandidatesFraction;
			if (RandomCandidate <= 0.0) {
				// this is the one
				break;
			}
		}

		VotedPreset = Cd.PresetRef;
		M = Cd.MapRef;
		if (M == none)
			M = VotedPreset.SelectRandomMapFromList();
		VotedMap = M;
	}

	if (CountTiedCandidates == 0) {
		BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 1, VotedMap.MapName@"("$VotedPreset.Abbreviation$")");
	} else if (CountTiedCandidates > 1) {
		BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 2, VotedMap.MapName@"("$VotedPreset.Abbreviation$")");
	} else {
		BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', 3, VotedMap.MapName@"("$VotedPreset.Abbreviation$")");
	}

	CheckVotedMap();
}

function CheckVotedMap() {
	local string OldMapName;

	// Object MyLevel is what the game natively loads from maps when switching
	// to them.
	// Without it, the map wont load at all. Checking that that object exists
	// should be enough for us.
	while (DynamicLoadObject(VotedMap.MapName$".MyLevel", class'Object', true) == none) {
		Log(VotedMap.MapName@"failed to load", 'VoteSys');
		OldMapName = VotedMap.MapName;
		VotedMap = VotedPreset.SelectRandomMapFromList();
		BroadcastLocalizedMessage2(class'VS_Msg_LocalMessage', -5, OldMapName, VotedMap.MapName);
	}
}

function bool CheckVoteEndConditions() {
	local VS_ChannelContainer C;
	local int VotesFirst;
	local int VotesSecond;
	local int NumVoters;
	local int NumVotes;

	if (TimeCounter <= 0)
		return true;

	if (Settings.VoteEndCondition == VEC_TimerOnly)
		return false;

	for (C = ChannelList; C != none; C = C.Next) {
		if (C.PlayerInfo != none) {
			if (C.PlayerInfo.bIsPlayer && C.PlayerInfo.bCanVote)
				NumVoters++;
			if (C.PlayerInfo.bHasVoted)
				NumVotes++;
		}
	}

	if (Settings.VoteEndCondition == VEC_TimerOrAllVotesIn) {
		if (NumVotes == NumVoters)
			return true;
	} else if (Settings.VoteEndCondition == VEC_TimerOrResultDetermined) {
		if (Info.FirstCandidate != none) {
			VotesFirst = Info.FirstCandidate.Votes;
			if (Info.FirstCandidate.Next != none)
				VotesSecond = Info.FirstCandidate.Next.Votes;
		}

		if (VotesFirst - VotesSecond > NumVoters - NumVotes)
			return true;
	}

	return false;
}

function TickVoteTime() {
	TimeCounter--;
	AnnounceCountdown(TimeCounter);
	if (CheckVoteEndConditions() == false)
		return;

	CloseVoteMenuForAll();
	TallyVotes();
	GameState = GS_VoteEnded;
	TimeCounter = 5;
}

function TickTimeBeforeTravel() {
	TimeCounter--;
	if (TimeCounter > 0)
		return;

	GameState = GS_Travelling;
	TravelTo(VotedPreset, VotedMap);
}

function QueueImmediateMapChange() {
	bChangeMapImmediately = true;
}

function ApplyVotedPreset() {
	local Object TempDataDummy;
	local VS_TempData TD;
	local array<string> Pkgs;
	local int i;

	TempDataDummy = new(XLevel, 'VoteSysTemp') class'Object';
	TD = new(TempDataDummy, 'Data') class'VS_TempData';

	if (TD.bNoColdStart) {
		TD.bNoColdStart = false;
		TD.SaveConfig();
	} else {
		// crash during gameplay (outside map change) or deliberate restart
		QueueImmediateMapChange();
	}
	bIsDefaultMap = TD.bDefaultMap;

	if (TD.PresetName != "")
		CurrentPreset = TD.Category$"/"$TD.PresetName;
	if (CurrentPreset != "") {
		switch(Settings.GameNameMode) {
			case GNM_DoNotModify:
				break;
			case GNM_PresetName:
				Level.Game.GameName = TD.PresetName;
				break;
			case GNM_CategoryAndPresetName:
				Level.Game.GameName = CurrentPreset;
				break;
		}
	}
	if (Settings.bUseServerActorsCompatibilityMode == false)
		CreateServerActors(TD.Actors);
	ApplyGameSettings(TD.GameSettings);

	if (Settings.bManageServerPackages &&
		Settings.bUseServerPackagesCompatibilityMode == false &&
		(Level.EngineVersion$Level.GetPropertyText("EngineRevision")) >= "469c"
	) {
		AddClassesToPackageMap(TD.Mutators, Pkgs);
		AddClassesToPackageMap(TD.Actors, Pkgs);
		MergeListIntoArray(TD.Packages, Pkgs);
		for (i = 0; i < Pkgs.Length; i++)
			if (IsInPackageMap(Pkgs[i], true) == false)
				AddToPackageMap(Pkgs[i]);
	}
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

function AddClassToPackageMap(string ClassName, out array<string> PkgMap) {
	local string P;
	local class C;
	local int Pos;

	Pos = InStr(ClassName, " ");
	if (Pos >= 0)
		ClassName = Left(ClassName, Pos);

	if (ClassName == "")
		return;
	C = class(DynamicLoadObject(ClassName, class'Class'));
	if (C == none)
		return;

	P = string(C.Outer.Name);

	SetPropertyText("TempPkg", C.GetPropertyText("Outer"));
	if (TempPkg == none) {
		Log("Casting to Package failed"@C.Outer, 'VoteSys');
		return;
	} else if ((TempPkg.PackageFlags & 0x0004) != 0) {
		Log("Package '"$P$"' is marked ServerSideOnly", 'VoteSys');
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

function SortMutators(string CombinedList, out string Mutators, out string Actors) {
	local array<string> Classes;
	local int i;

	Classes = SplitList(CombinedList, ",");
	for (i = 0; i < Classes.Length; i++)
		SortMutator(Classes[i], Mutators, Actors);
}

function SortMutator(string Mut, out string Mutators, out string Actors) {
	local class C;
	local int Pos;
	local string ClassName;

	Pos = InStr(Mut, " ");
	if (Pos >= 0)
		ClassName = Left(Mut, Pos);
	else
		ClassName = Mut;

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
			Actors = Mut;
		} else {
			Actors = Actors$","$Mut;
		}
	}
}

function GetDefaultServerPackages() {
	local string Prop;

	if (Settings.DefaultPackages.Length > 0)
		return; // already done

	Prop = ConsoleCommand("get Engine.GameEngine ServerPackages");
	Log("Packages="$Prop, 'VoteSys');
	Settings.DefaultPackages = ParseConsoleStringArray(Prop);
	Settings.SaveConfig();
}

function GetDefaultServerActors() {
	local string Prop;

	if (Settings.DefaultActors.Length > 0)
		return; // already done

	Prop = ConsoleCommand("get Engine.GameEngine ServerActors");
	Log("Actors="$Prop, 'VoteSys');
	Settings.DefaultActors = ParseConsoleStringArray(Prop);
	Settings.SaveConfig();
}

// This function has a glaring weakness: it cannot parse strings correctly, if
// those strings contain one or more commas.
// Dont expect this to work.
function array<string> ParseConsoleStringArray(string Output) {
	local array<string> Result;
	local int i;

	Output = Mid(Output, Len(Output) - 2); // remove ( and )

	Result = SplitList(Output, ",");
	for (i = 0; i < Result.Length; i++)
		Result[i] = Mid(Result[i], Len(Result[i]) - 2); // remove surrounding ""

	return Result;
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

function SetServerActors(array<string> Actors) {
	local string Value;
	local int i;

	if (Actors.Length <= 0)
		return;

	Value = "\""$Actors[0]$"\""; // hardcode first to save inside loop
	for (i = 1; i < Actors.Length; i++) {
		Value = Value$",\""$Actors[i]$"\"";
	}

	Log("Actors=("$Value$")", 'VoteSys');
	ConsoleCommand("set Engine.GameEngine ServerActors ("$Value$")");
}

function CreateServerActors(string Actors) {
	local int i;
	local array<string> ActorList;

	ActorList = SplitList(Actors, ",");
	for (i = 0; i < ActorList.Length; i++)
		CreateServerActor(ActorList[i]);
}

function CreateServerActor(string ActorLine) {
	local class<Actor> C;
	local array<string> Elements;
	local Actor A;
	local int i;
	local int Pos;

	Elements = SplitList(ActorLine, " ");
	if (Elements[0] != "")
		C = class<Actor>(DynamicLoadObject(Elements[0], class'Class'));
	if (C != none)
		A = Level.Game.Spawn(C);

	if (A == none)
		return;

	for (i = 1; i < Elements.Length; i++) {
		Pos = InStr(Elements[i], "=");
		if (Pos == -1)
			continue;

		A.SetPropertyText(Left(Elements[i], Pos), Mid(Elements[i], Pos+1));
	}
}

function ApplyGameSettings(string GameSettings) {
	local int i;
	local array<string> Settings;

	Settings = SplitList(GameSettings, ",");
	for (i = 0; i < Settings.Length; i++)
		ApplyGameSetting(Settings[i]);
}

function ApplyGameSetting(string Setting) {
	local int Pos;
	local string Key, Value;

	Pos = InStr(Setting, "=");
	if (Pos == -1)
		return;

	Key = Left(Setting, Pos);
	Value = Mid(Setting, Pos+1);

	if (Key != "")
		Level.Game.SetPropertyText(Key, Value);
}

function LoadConfig() {
	local VS_PresetConfig PC;
	local VS_Preset P;
	local int i;
	local int ProbeDepth;

	// fix problematic settings
	if (Settings.PresetProbeDepth < 1)
		Settings.PresetProbeDepth = 1;

	PresetConfigDummy = new(XLevel, 'VoteSysPresets')  class'Object';
	PresetListDummy   = new(XLevel)                    class'Object';
	MapConfigDummy    = new(XLevel, 'VoteSysMapLists') class'Object';
	MapListDummy      = new(XLevel)                    class'Object';
	i = 0;

	for (i = 0; ProbeDepth < Settings.PresetProbeDepth; i++) {
		SetPropertyText("PresetNameDummy", "VS_PresetConfig"$i);
		PC = new(PresetConfigDummy, PresetNameDummy) class'VS_PresetConfig';
		Log("Try Loading"@PC.Name, 'VoteSys');
		if (PC.PresetName == "") {
			ProbeDepth++;
			continue;
		}

		ProbeDepth = 0;

		if (PresetList == none) {
			P = LoadPresetPassOne(PC, i);
			PresetList = P;
		} else {
			P.Next = LoadPresetPassOne(PC, i);
			if (P.Next != none)
				P = P.Next;
		}
	};

	PresetMaxIndex = i - ProbeDepth;
	PresetArray.Insert(0, PresetMaxIndex + 1);

	for (P = PresetList; P != none; P = P.Next) {
		PresetArray[P.StorageIndex] = P.Storage;
		LoadPresetPassTwo(P);

		if ((DefaultPresetRef == none && P.bDisabled == false) ||
			(P != none && Settings.DefaultPreset != "" && P.GetFullName() == Settings.DefaultPreset) ||
			(P != none && Settings.DefaultPreset == "" && CurrentPreset != "" && P.GetFullName() == CurrentPreset)
		) {
			DefaultPresetRef = P;
		}
	}

	if (DefaultPresetRef == none) {
		Level.Game.SetPropertyText("bDontRestart", "False");
		Destroy();
	}
}

function VS_Preset LoadPresetPassOne(VS_PresetConfig PC, int Index) {
	local VS_Preset P;

	Log("Adding Preset '"$PC.Category$"/"$PC.PresetName$"' ("$PC.Abbreviation$")", 'VoteSys');

	P = new(PresetListDummy) class'VS_Preset';
	P.PresetName   = PC.PresetName;
	P.Abbreviation = PC.Abbreviation;
	P.Category     = PC.Category;
	P.SortPriority = PC.SortPriority;
	P.Storage      = PC;
	P.StorageIndex = Index;

	return P;
}

function LoadPresetPassTwo(VS_Preset P) {
	local VS_PresetConfig PC;
	local class<GameInfo> Game;
	local VS_Preset Base;
	local int i;

	if (P.bLoaded)
		return;

	if (P.bLoading) {
		Log("    Preset '"$P.GetFullName()$"' is already being loaded. Circular reference detected.", 'VoteSys');
		return;
	}

	Log("Loading Preset '"$P.GetFullName()$"'", 'VoteSys');

	P.bLoading = true;
	PC = P.Storage;
	P.MinimumMapRepeatDistance = PC.MinimumMapRepeatDistance;
	P.MinPlayers = PC.MinPlayers;
	P.MaxPlayers = PC.MaxPlayers;

	for (i = 0; i < PC.InheritFrom.Length; i++) {
		if (PC.InheritFrom[i] == "")
			continue;

		Base = FindPreset(PC.InheritFrom[i]);
		if (Base == none) {
			Log("    Base '"$PC.InheritFrom[i]$"' does not exist.", 'VoteSys');
			continue;
		}
		
		LoadPresetPassTwo(Base);

		if (P.Game == none)
			P.Game = Base.Game;
		if (P.MinimumMapRepeatDistance < 0)
			P.MinimumMapRepeatDistance = Base.MinimumMapRepeatDistance;
		if (P.MinPlayers < 0)
			P.MinPlayers = Base.MinPlayers;
		if (P.MaxPlayers < 0)
			P.MaxPlayers = Base.MaxPlayers;

		P.AppendMutator(Base.Mutators);
		P.AppendParameter(Base.Parameters);
		P.AppendGameSetting(Base.GameSettings);
		P.AppendPackage(Base.Packages);
	}

	Game = class<GameInfo>(DynamicLoadObject(PC.Game, class'Class', true));
	if (Game != none)
		P.Game = Game;

	P.bDisabled = PC.bDisabled;
	P.bOpenVoteMenuAutomatically = PC.bOpenVoteMenuAutomatically;
	if (P.MinimumMapRepeatDistance < 0)
		P.MinimumMapRepeatDistance = Settings.MinimumMapRepeatDistance;

	if (P.Game == none && P.bDisabled == false) {
		Log("    Forcibly disabling '"$P.GetFullName()$"' because it has no gamemode.", 'VoteSys');
		P.bDisabled = true;
	}

	if (P.bDisabled == false)
		P.MapList = LoadMapList(P.Game, PC.MapListName);

	for (i = 0; i < PC.Mutators.Length; i++)
		P.AppendMutator(PC.Mutators[i]);

	for (i = 0; i < PC.Parameters.Length; i++)
		P.AppendParameter(PC.Parameters[i]);

	for (i = 0; i < PC.GameSettings.Length; i++)
		P.AppendGameSetting(PC.GameSettings[i]);

	for (i = 0; i < PC.Packages.Length; i++)
		P.AppendPackage(PC.Packages[i]);

	P.bLoaded = true;
	P.bLoading = false;
}

function VS_Map LoadMapList(class<GameInfo> Game, name ListName) {
	local VS_MapList ML;
	local bool bHaveTutorial;
	local VS_Map Result;

	if (Game != none) {
		Log("    Loading List '"$ListName$"' for"@Game, 'VoteSys');
	} else {
		Log("    Loading List '"$ListName$"'", 'VoteSys');
	}

	ML = LoadMapListByName(ListName);
	if (ML != none)
		return ML.DuplicateList();

	if (Game == none)
		return none;

	// If no map list specified, or no maps in map list, use all maps available for game type.
	// As before, see if the list already exists for the specified game type.
	ML = LoadMapListByPrefix(Game.default.MapPrefix);

	bHaveTutorial = ML.RemoveMap(Game.default.MapPrefix$"-Tutorial");
	Result = ML.DuplicateList();
	if (bHaveTutorial) ML.AddMap(Game.default.MapPrefix$"-Tutorial");

	return Result;
}

function VS_MapList LoadMapListByName(name ListName) {
	local VS_MapListConfig MC;
	local VS_MapList ML;
	local VS_MapList MLIgnore;

	// Use specified map list
	if (ListName == '')
		return none;

	// dont recreate if it already exists
	ML = FindMapListByName(string(ListName));
	if (ML != none)
		return ML;

	MC = new(MapConfigDummy, ListName) class'VS_MapListConfig';

	MLIgnore = new(MapListDummy) class'VS_MapList';

	AddAllMapsToMapList(MC.IgnoreMap, MLIgnore);
	AddMapPrefixesToMapList(MC.IgnoreMapsWithPrefix, MLIgnore);
	AddMapListsToMapList(MC.IgnoreList, MLIgnore);

	ML = new(MapListDummy) class'VS_MapList';
	ML.ListName = string(ListName);
	ML.Storage = MC;

	AddAllMapsToMapList(MC.Map, ML);
	AddMapPrefixesToMapList(MC.IncludeMapsWithPrefix, ML);
	AddMapListsToMapList(MC.IncludeList, ML);

	ML.RemoveMapList(MLIgnore);

	return ML;
}

function VS_MapList LoadMapListByPrefix(string Prefix) {
	local VS_MapList ML;
	local string FirstMap;
	local string MapName;

	if (Prefix == "")
		return none;

	ML = FindMapListByPrefix(Prefix);
	if (ML != none)
		return ML;

	ML = new(MapListDummy) class'VS_MapList';
	ML.Next = MapLists;
	MapLists = ML;
	ML.Prefix = Prefix;

	FirstMap = GetMapName(Prefix, "", 0);
	if (FirstMap == "")
		return none; // no maps with this prefix
	MapName = FirstMap;

	do {
		ML.AddMap(Left(MapName, Len(MapName) - 4)); // we dont care about extension
		MapName = GetMapName(Prefix, MapName, 1);
	} until(MapName == FirstMap);

	return ML;
}

function VS_MapList FindMapListByName(string ListName) {
	local VS_MapList ML;

	for (ML = MapLists; ML != none; ML = ML.Next)
		if (ML.ListName == ListName)
			return ML;

	return none;
}

function VS_MapList FindMapListByPrefix(string Prefix) {
	local VS_MapList ML;

	for (ML = MapLists; ML != none; ML = ML.Next)
		if (ML.Prefix == Prefix)
			return ML;

	return none;
}

function AddAllMapsToMapList(array<string> MapArray, VS_MapList MapList) {
	local int i;

	for (i = 0; i < MapArray.Length; i++)
		if (MapArray[i] != "")
			MapList.AddMapFromConfig(MapArray[i]);
}

function AddMapPrefixesToMapList(array<string> MapPrefixArray, VS_MapList MapList) {
	local VS_MapList ML;
	local int i;

	for (i = 0; i < MapPrefixArray.Length; i++) {
		ML = LoadMapListByPrefix(MapPrefixArray[i]);
		if (ML != none)
			MapList.AddMapList(ML);
	}
}

function AddMapListsToMapList(array<name> MapListArray, VS_MapList MapList) {
	local VS_MapList IncludeList;
	local int i;

	for (i = 0; i < MapListArray.Length; i++) {
		if (MapListArray[i] == '')
			continue;

		IncludeList = LoadMapListByName(MapListArray[i]);
		if (IncludeList != none)
			MapList.AddMapList(IncludeList);
	}
}

function LoadHistory() {
	HistoryDummy = new(XLevel, 'VoteSysHistory') class'Object';
	History = new(HistoryDummy, 'History') class'VS_HistoryConfig';

	HistoryProcessor = Spawn(class'VS_HistoryProcessor');
	HistoryProcessor.VoteSys = self;
	HistoryProcessor.History = History;
	HistoryProcessor.PresetList = PresetList;
}

function bool CanVote(PlayerPawn P) {
	return GameState < GS_VoteEnded
		&& P != none
		&& (P.IsA('Spectator') == false || P.bAdmin)
		&& P.Player != none; // disconnected players cant vote
}

function VS_Preset FindPreset(string FullName) {
	local VS_Preset P;

	for (P = PresetList; P != none; P = P.Next)
		if (P.GetFullName() == FullName)
			return P;

	return none;
}

defaultproperties {
	GameState=GS_Playing
	bAlwaysTick=True
}
