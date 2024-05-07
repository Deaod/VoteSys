class VS_ChannelContainer extends Info;

var VS_ChannelContainer Next;
var VS_PlayerChannel Channel;
var VS_PlayerInfo PlayerInfo;
var PlayerPawn PlayerOwner;
var Actor AceCheck;
var int KickCheckDelaySeconds;

function Initialize(PlayerPawn P) {
	PlayerOwner = P;
	Channel = Spawn(class'VS_PlayerChannel', P);
	Channel.PlayerOwner = P;
	PlayerInfo = Spawn(class'VS_PlayerInfo', P);
	PlayerInfo.PRI = P.PlayerReplicationInfo;
}

defaultproperties {
	KickCheckDelaySeconds=30
	RemoteRole=ROLE_None
}
