class VS_DataServer extends TcpLink
	imports(VS_Util_Logging)
	transient;

var MutVoteSys VoteSys;
var VS_Info Info;
var VS_ServerSettings Settings;

event PostBeginPlay() {
	local int Prt;

	foreach AllActors(class'MutVoteSys', VoteSys)
		break;

	Settings = VoteSys.Settings;

	// needs to be set because children inherit LinkMode
	LinkMode = MODE_Text;

	Prt = BindPort(Settings.DataPort, true);
	if (Prt == 0) {
		LogErr("VS_DataServer - Failed to BindPort");
		return;
	}

	if (Listen() == false) {
		LogErr("VS_DataServer - Failed to Listen");
		return;
	}

	foreach AllActors(class'VS_Info', Info)
		break;

	Info.Data.Addr = Settings.ServerAddress;
	if (Settings.ClientDataPort == 0 || Settings.DataPort != Prt) {
		// Either the admin didnt specify a port clients should use,
		// or we didnt get the port we wanted (likely because its in use).
		// Anyway, we should use the port we actually bound to.
		Info.Data.Port = Prt;
	} else {
		// we bound to the port we wanted and the admin specified a port clients should use.
		Info.Data.Port = Settings.ClientDataPort;
	}

	LogMsg("VS_DataServer Addr="$Info.Data.Addr@"Port="$Info.Data.Port);
}

defaultproperties {
	AcceptClass=class'VS_DataLink'
	RemoteRole=ROLE_None
}
