class VS_Data_Peer extends Info
	imports(VS_Util_Logging)
	transient;

var VS_Net_TcpLink Link;
var VS_Net_ChannelLink Chan;

event Connected();

final function bool IsConnected() {
	if (Link != none)
		return Link.IsConnected();
	else
		return Chan.bEnableTraffic;
}

final function Send(string Content) {
	if (Link != none && Link.IsConnected())
		Link.SendText(Content);
	else if (Chan != none)
		Chan.SendText(Content);
	else
		LogErr("VS_Data_Peer SendText - Internal Error while sending:"@Content);
}

final function string GetIdentifier() {
	if (Link != none)
		return Link.IpAddrToString(Link.RemoteAddr);
	if (Chan != none)
		return PlayerPawn(Chan.Owner).PlayerReplicationInfo.PlayerName;

	return "Unknown";
}

event Receive(string Content);

defaultproperties {
	RemoteRole=ROLE_None
}
