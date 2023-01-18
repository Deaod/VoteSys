class VS_Info extends ReplicationInfo;

var MutVoteSys VoteSys;
var string DataAddr;
var int    DataPort;
var int    MinimumMapRepeatDistance;

struct MapCandidateData {
	var() string Preset;
	var() string MapName;
	var() int Votes;
};
struct InternalCandidateData {
	var() VS_Preset Preset;
	var() VS_Map MapRef;
};

const MaxCandidates = 32;
var MapCandidateData Candidates[MaxCandidates];
var InternalCandidateData CandidatesInternal[MaxCandidates];
var int NumCandidates;

struct PlayerVoteSysInfo {
	var() PlayerReplicationInfo PRI;
	var() bool bHasVoted;
};

var PlayerVoteSysInfo PlayerInfo[32];

replication {
	unreliable if (Role == ROLE_Authority)
		DataAddr,
		DataPort,
		MinimumMapRepeatDistance,
		NumCandidates,
		Candidates,
		PlayerInfo;
}

function AddMapVote(VS_PlayerChannel Origin, VS_Preset P, VS_Map M) {
	local int InternalIndex;

	if (VoteSys.CanVote(Origin.PlayerOwner)) {
		if (Origin.PlayerOwner.PlayerReplicationInfo.bAdmin) {
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 7,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				M.MapName@"("$P.Abbreviation$")"
			);
			VoteSys.AdminForceTravelTo(P, M);
		} else {
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 6,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				M.MapName@"("$P.Abbreviation$")"
			);
			InternalIndex = AddMapVoteUnsafe(P.GetFullName(), M.MapName);
			if (InternalIndex >= 0) {
				CandidatesInternal[InternalIndex].Preset = P;
				CandidatesInternal[InternalIndex].MapRef = M;
			}
		}
	}
}

function int AddMapVoteUnsafe(string Preset, string MapName) {
	local int i;
	local int Result;
	local MapCandidateData Tmp;
	local InternalCandidateData TmpInt;

	Result = -1;

	for (i = 0; i < MaxCandidates; i++) {
		if (Candidates[i].Preset == Preset && Candidates[i].MapName == MapName) {
			Candidates[i].Votes += 1;
			Result = -1;
			break;
		}

		if (Candidates[i].Preset == "" && Candidates[i].MapName == "") {
			Candidates[i].Preset = Preset;
			Candidates[i].MapName = MapName;
			Candidates[i].Votes = 1;
			NumCandidates += 1;
			Result = i;
			break;
		}
	}

	if (i >= MaxCandidates)
		return Result;

	while(i > 0 && Candidates[i-1].Votes < Candidates[i].Votes) {
		Tmp = Candidates[i-1];
		Candidates[i-1] = Candidates[i];
		Candidates[i] = Tmp;

		TmpInt = CandidatesInternal[i-1];
		CandidatesInternal[i-1] = CandidatesInternal[i];
		CandidatesInternal[i] = TmpInt;

		i--;
	}

	return Result;
}

function RemMapVote(VS_PlayerChannel Origin, VS_Preset P, VS_Map M) {
	RemMapVoteUnsafe(P.GetFullName(), M.MapName);
}

function RemMapVoteUnsafe(string Preset, string MapName) {
	local int i;
	local MapCandidateData Tmp;
	local InternalCandidateData TmpInt;

	for (i = 0; i < MaxCandidates; i++) {
		if (Candidates[i].Preset == Preset && Candidates[i].MapName == MapName) {
			Candidates[i].Votes -= 1;
			if (Candidates[i].Votes == 0) {
				NumCandidates -= 1;
				Candidates[i] = Candidates[NumCandidates];
				Candidates[NumCandidates].Preset = "";
				Candidates[NumCandidates].MapName = "";
				Candidates[NumCandidates].Votes = 0;
				CandidatesInternal[i] = CandidatesInternal[NumCandidates];
				CandidatesInternal[NumCandidates].Preset = none;
				CandidatesInternal[NumCandidates].MapRef = none;
			}
			break;
		}
	}

	while(i+1 < MaxCandidates && Candidates[i].Votes < Candidates[i+1].Votes) {
		Tmp = Candidates[i+1];
		Candidates[i+1] = Candidates[i];
		Candidates[i] = Tmp;

		TmpInt = CandidatesInternal[i+1];
		CandidatesInternal[i+1] = CandidatesInternal[i];
		CandidatesInternal[i] = TmpInt;

		i++;
	}
}

function KickPlayer(VS_PlayerChannel Origin, PlayerReplicationInfo Target) {
	local PlayerPawn P;
	local VS_PlayerChannel TCh;

	if (Origin == none || Target == none)
		return;

	if (Origin.PlayerOwner == none || Origin.PlayerOwner.PlayerReplicationInfo == none)
		return;

	if (VoteSys.CanVote(Origin.PlayerOwner) == false)
		return;

	if (Origin.PlayerOwner.PlayerReplicationInfo.bAdmin) {
		P = PlayerPawn(Target.Owner);
		if (P != none) {
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 8,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				Target.PlayerName,
				string(Target.PlayerId)
			);

			VoteSys.TempBanAddress(P.GetPlayerNetworkAddress());
			P.KickMe("Admin Kick (VoteSys)");
		}
	} else {
		TCh = VoteSys.FindChannelForPRI(Target);
		if (TCh != none) {
			if (Origin.ToggleKick(Target)) {
				TCh.KickVotesAgainstMe++;
				VoteSys.BroadcastLocalizedMessage2(
					class'VS_Msg_LocalMessage', 10,
					Target.PlayerName
				);
			} else {
				TCh.KickVotesAgainstMe--;
			}
			Origin.ClientApplyKickVote(Target);
		}
	}
}

function BanPlayer(VS_PlayerChannel Origin, PlayerReplicationInfo Target) {
	local PlayerPawn P;
	if (Origin == none || Target == none)
		return;

	if (Origin.PlayerOwner != none &&
		Origin.PlayerOwner.PlayerReplicationInfo != none &&
		Origin.PlayerOwner.PlayerReplicationInfo.bAdmin
	) {
		P = PlayerPawn(Target.Owner);
		if (P != none) {
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 9,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				Target.PlayerName,
				string(Target.PlayerId)
			);

			P.KickBanMe("Admin Ban (VoteSys)");
		}
	}
}

function int FindCandidateIndex(string Preset, string MapName) {
	local int Index;
	for (Index = 0; Index < MaxCandidates; Index++)
		if (Candidates[Index].Preset == Preset && Candidates[Index].MapName == MapName)
			return Index;
	return -1;
}

function VS_Preset ResolvePresetSeparate(string Category, string PresetName) {
	local VS_Preset P;

	for (P = VoteSys.PresetList; P != none; P = P.Next)
		if (P.Category == Category && P.PresetName == PresetName && P.bDisabled == false)
			return P;

	return none;
}

function VS_Preset ResolvePresetCombined(string FullPresetName) {
	local VS_Preset P;

	for (P = VoteSys.PresetList; P != none; P = P.Next)
		if (P.GetFullName() == FullPresetName && P.bDisabled == false)
			return P;

	return none;
}

function VS_Map ResolveMapOfPreset(VS_Preset P, string MapName) {
	local VS_Map M;

	if (P == none)
		return none;

	for (M = P.MapList; M != none; M = M.Next)
		if (M.MapName == MapName)
			return M;

	return none;
}

simulated final function string GetCandidatePreset(int Index) {
	return Candidates[Index].Preset;
}

simulated final function string GetCandidateMapName(int Index) {
	return Candidates[Index].MapName;
}

simulated final function int GetCandidateVotes(int Index) {
	return Candidates[Index].Votes;
}

final function VS_Preset GetCandidateInternalPreset(int Index) {
	return CandidatesInternal[Index].Preset;
}

final function VS_Map GetCandidateInternalMap(int Index) {
	return CandidatesInternal[Index].MapRef;
}

//

simulated final function PlayerReplicationInfo GetPlayerInfoPRI(int Index) {
	return PlayerInfo[Index].PRI;
}

simulated final function bool GetPlayerInfoHasVoted(int Index) {
	return PlayerInfo[Index].bHasVoted;
}

final function SetPlayerInfoPRI(int Index, PlayerReplicationInfo PRI) {
	PlayerInfo[Index].PRI = PRI;
}

final function SetPlayerInfoHasVoted(int Index, bool bHasVoted) {
	PlayerInfo[Index].bHasVoted = bHasVoted;
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
}
