class VS_ChannelContainer extends Info
	imports(VS_BannedPlayers);

var VS_ChannelContainer Next;
var VS_PlayerChannel Channel;
var VS_PlayerInfo PlayerInfo;
var PlayerPawn PlayerOwner;
var Actor AceCheck;
var EBanState BanState;

var int Cookie;
var int MapRating;

function Initialize(PlayerPawn P) {
	PlayerOwner = P;
	Channel = Spawn(class'VS_PlayerChannel', P);
	Channel.PlayerOwner = P;
	PlayerInfo = Spawn(class'VS_PlayerInfo', P);
	PlayerInfo.PRI = P.PlayerReplicationInfo;
}

defaultproperties {
	BanState=BS_Unknown
	RemoteRole=ROLE_None
}
