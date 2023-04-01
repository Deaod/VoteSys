class VS_ChannelContainer extends Info;

var VS_ChannelContainer Next;
var VS_PlayerChannel Channel;
var VS_PlayerInfo PlayerInfo;
var PlayerPawn PlayerOwner;
var Actor AceCheck;

function Initialize(PlayerPawn P, Actor AceChk) {
	PlayerOwner = P;
	Channel = Spawn(class'VS_PlayerChannel', P);
	Channel.PlayerOwner = P;
	PlayerInfo = Spawn(class'VS_PlayerInfo', P);
	PlayerInfo.PRI = P.PlayerReplicationInfo;
	AceCheck = AceChk;
}

defaultproperties {
	RemoteRole=ROLE_None
}
