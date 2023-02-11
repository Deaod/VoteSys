class VS_ChannelContainer extends Info;

var VS_ChannelContainer Next;
var VS_PlayerChannel Channel;
var PlayerPawn PlayerOwner;

function Initialize(PlayerPawn P) {
	PlayerOwner = P;
	Channel = Spawn(class'VS_PlayerChannel', P);
	Channel.PlayerOwner = P;
}

defaultproperties {
	RemoteRole=ROLE_None
}
