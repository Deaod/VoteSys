class VS_PlayerInfo extends ReplicationInfo;

var PlayerReplicationInfo PRI;
var bool bCanVote;
var bool bHasVoted;
var bool bIsPlayer;
var bool bLocalPlayerWantsToKick;

replication {
	reliable if (Role == ROLE_Authority)
		bCanVote,
		bHasVoted,
		bIsPlayer,
		PRI;
}

final simulated function string GetVariableText(string S) {
	local string Result;

	Result = GetPropertyText(S);
	if (InStr(Result, ",") >= 0)
		return "\""$Result$"\"";
	return Result;
}

final simulated function string GetVariable(string S) {
	return S$"="@GetVariableText(S);
}

final simulated function string Dump() {
	return
		GetVariable("PRI")$","$
		GetVariable("bCanVote")$","$
		GetVariable("bHasVoted")$","$
		GetVariable("bIsPlayer")$","$
		GetVariable("bLocalPlayerWantsToKick");
}

defaultproperties {
	NetUpdateFrequency=10
}
