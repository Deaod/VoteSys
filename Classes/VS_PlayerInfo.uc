class VS_PlayerInfo extends ReplicationInfo;

var PlayerReplicationInfo PRI;
var bool bCanVote;
var bool bHasVoted;
var bool bIsPlayer;

replication {
	reliable if (Role == ROLE_Authority)
		bCanVote,
		bHasVoted,
		bIsPlayer,
		PRI;
}

defaultproperties {
	NetUpdateFrequency=10
}
