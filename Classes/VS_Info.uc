class VS_Info extends ReplicationInfo;

var MutVoteSys VoteSys;
struct ConnectionData {
	var string Addr;
	var int    Port;
};
var ConnectionData Data;

var VS_Candidate FirstCandidate;
var VS_Candidate LastCandidate;

var VS_PlayerInfo PlayerInfo[60];
var string RandomMapNameIdentifier;

replication {
	unreliable if (Role == ROLE_Authority)
		Data,
		FirstCandidate,
		LastCandidate;
}

simulated event PostBeginPlay() {
	SetTimer(0.2, true);
}

simulated event Timer() {
	local int i;
	local VS_PlayerInfo P;

	foreach AllActors(class'VS_PlayerInfo', P)
		if (i < arraycount(PlayerInfo))
			PlayerInfo[i++] = P;
	
	while(i < arraycount(PlayerInfo))
		PlayerInfo[i++] = none;
}

function VS_Candidate AddMapVote(VS_PlayerChannel Origin, VS_Preset P, VS_Map M) {
	if (VoteSys.CanVote(Origin.PlayerOwner)) {
		if (Origin.PlayerOwner.PlayerReplicationInfo.bAdmin) {
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 7,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				M.MapName@"("$P.Abbreviation$")"
			);
			VoteSys.AdminForceTravelTo(P, M);
			return none;
		} else {
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 6,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				M.MapName@"("$P.Abbreviation$")"
			);
			return AddMapVoteInternal(P, M);
		}
	}
	return none;
}

function VS_Candidate AddMapVoteInternal(VS_Preset P, VS_Map M) {
	local VS_Candidate C;

	for (C = FirstCandidate; C != none; C = C.Next) {
		if (C.PresetRef == P && C.MapRef == M) {
			C.Votes += 1;
			break;
		}
	}

	if (C == none) {
		C = Spawn(class'VS_Candidate');
		C.Append(self);
		C.Fill(P, M);
		C.Votes = 1;
	}

	C.SortInList();

	return C;
}

function VS_Candidate AddCandidateVote(VS_PlayerChannel Origin, VS_Candidate Candidate) {
	local VS_Preset P;
	local VS_Map M;
	if (VoteSys.CanVote(Origin.PlayerOwner)) {
		if (Origin.PlayerOwner.PlayerReplicationInfo.bAdmin) {
			P = Candidate.PresetRef;
			M = Candidate.MapRef;
			if (M == none)
				M = P.SelectRandomMapFromList();
				
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 7,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				M.MapName@"("$P.Abbreviation$")"
			);
			VoteSys.AdminForceTravelTo(P, M);
			return none;
		} else {
			if (Candidate.MapRef != none) {
				VoteSys.BroadcastLocalizedMessage2(
					class'VS_Msg_LocalMessage', 6,
					Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
					Candidate.MapRef.MapName@"("$Candidate.PresetRef.Abbreviation$")"
				);
			} else {
				VoteSys.BroadcastLocalizedMessage2(
					class'VS_Msg_LocalMessage', 12,
					Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
					Candidate.PresetRef.Abbreviation
				);
			}
			Candidate.Votes += 1;
			Candidate.SortInList();
			return Candidate;
		}
	}
	return none;
}

function VS_Candidate AddRandomVote(VS_PlayerChannel Origin, VS_Preset P) {
	local VS_Map M;

	if (VoteSys.CanVote(Origin.PlayerOwner)) {
		if (Origin.PlayerOwner.PlayerReplicationInfo.bAdmin) {
			M = P.SelectRandomMapFromList();
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 7,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				M.MapName@"("$P.Abbreviation$")"
			);
			VoteSys.AdminForceTravelTo(P, M);
			return none;
		} else {
			VoteSys.BroadcastLocalizedMessage2(
				class'VS_Msg_LocalMessage', 12,
				Origin.PlayerOwner.PlayerReplicationInfo.PlayerName,
				P.Abbreviation
			);
			return AddRandomVoteInternal(P);
		}
	}
	return none;
}

function VS_Candidate AddRandomVoteInternal(VS_Preset P) {
	local VS_Candidate C;

	for (C = FirstCandidate; C != none; C = C.Next) {
		if (C.PresetRef == P && C.MapName == RandomMapNameIdentifier) {
			C.Votes += 1;
			break;
		}
	}

	if (C == none) {
		C = Spawn(class'VS_Candidate');
		C.Append(self);
		C.FillRandom(P);
		C.Votes = 1;
	}

	C.SortInList();

	return C;
}

function RemCandidateVote(VS_PlayerChannel Origin, VS_Candidate Candidate) {
	Candidate.Votes -= 1;
	if (VoteSys.Settings.bRetainCandidates == false && Candidate.Votes == 0) {
		Candidate.Remove();
		Candidate.Destroy();
	} else {
		Candidate.SortInList();
	}
}

function KickPlayer(VS_PlayerChannel Origin, PlayerReplicationInfo Target) {
	local PlayerPawn P;
	local VS_ChannelContainer ChCont;
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

			VoteSys.TempBanPlayer(P);
			VoteSys.KickPlayer(P, "Admin Kick (VoteSys)");
		}
	} else {
		ChCont = VoteSys.FindChannelForPRI(Target);
		if (ChCont != none)
			TCh = ChCont.Channel;
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

			VoteSys.KickBanPlayer(Origin.PlayerOwner, P, "Admin Ban (VoteSys)");
		}
	}
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

defaultproperties {
	RandomMapNameIdentifier="<Random>"

	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=10
}
