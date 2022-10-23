class VS_DataServer extends TcpLink
	transient;

var MutVoteSys VoteSys;
var VS_Info Info;
var VS_ServerSettings Settings;

event PostBeginPlay() {
	local IpAddr A;
	local int Prt;

	foreach AllActors(class'MutVoteSys', VoteSys)
		break;

	Settings = VoteSys.Settings;

	// needs to be set because children inherit LinkMode
	LinkMode = MODE_Text;

	Prt = BindPort(, true);
	if (Prt == 0) {
		Log("VS_DataServer - Failed to BindPort", 'VoteSys');
		return;
	}

	if (Listen() == false) {
		Log("VS_DataServer - Failed to Listen", 'VoteSys');
		return;
	}

	foreach AllActors(class'VS_Info', Info)
		break;

	if (StringToIpAddr(Settings.ServerAddress, A)) {
		Log("VS_DataServer UseLocalAddr", 'VoteSys');
		Info.DataAddr = Settings.ServerAddress;
		Info.DataPort = Prt;
	} else {
		Log("VS_DataServer DetermineAddr", 'VoteSys');
		GetLocalIP(A);
		Info.DataAddr = IpAddrToString(A);
		Info.DataAddr = Left(Info.DataAddr, Len(Info.DataAddr)-2); // -2 to cut off Port specifier (:0)
		Info.DataPort = Prt;
	}

	Log("VS_DataServer Addr="$Info.DataAddr@"Port="$Info.DataPort, 'VoteSys');
}

defaultproperties {
	AcceptClass=class'VS_DataLink'
	RemoteRole=ROLE_None
}
