class VS_BannedPlayers extends Object
	perobjectconfig;

struct BannedPlayer {
	var string HWHash;
	var string PlayerName;
	var string BannedBy;
};
var config array<BannedPlayer> BannedPlayers;
var array<BannedPlayer> TempBannedPlayers;

final function bool FindPlayer(array<BannedPlayer> BanList, string HWHash, out int Index) {
	local int F, C;

	HWHash = Caps(HWHash);
	F = 0;
	C = BanList.Length - 1;

	while(F <= C) {
		Index = F + ((C - F) / 2);
		if (BanList[Index].HWHash < HWHash)
			F = Index+1;
		else if (BanList[Index].HWHash > HWHash)
			C = Index-1;
		else
			return true;
	}

	return false;
}

final function AddPlayerToBanList(out array<BannedPlayer> BanList, BannedPlayer P) {
	local int Index;

	if (FindPlayer(BanList, P.HWHash, Index) == false) {
		BanList.Insert(Index, 1);
		BanList[Index] = P;
	} else {
		Log("Player '"$P.PlayerName$"' with HWID '"$P.HWHash$"' is already banned", 'VoteSys');
	}
}

final function BannedPlayer FillBannedPlayerStruct(string HWHash, string PlayerName, string BannedBy) {
	local BannedPlayer P;

	P.HWHash = Caps(HWHash);
	P.PlayerName = PlayerName;
	P.BannedBy = BannedBy;

	return P;
}

final function BanPlayer(string HWHash, string PlayerName, string BannedBy) {
	AddPlayerToBanList(BannedPlayers, FillBannedPlayerStruct(HWHash, PlayerName, BannedBy));
}

final function TempBanPlayer(string HWHash, string PlayerName, string BannedBy) {
	AddPlayerToBanList(TempBannedPlayers, FillBannedPlayerStruct(HWHash, PlayerName, BannedBy));
}

final function bool IsPlayerBanned(string HWHash) {
	local int TempIndex;
	return FindPlayer(BannedPlayers, HWHash, TempIndex) || FindPlayer(TempBannedPlayers, HWHash, TempIndex);
}
