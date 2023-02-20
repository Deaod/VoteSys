class VS_DataServer extends TcpLink
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
		Log("VS_DataServer - Failed to BindPort", 'VoteSys');
		return;
	}

	if (Listen() == false) {
		Log("VS_DataServer - Failed to Listen", 'VoteSys');
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

	Log("VS_DataServer Addr="$Info.Data.Addr@"Port="$Info.Data.Port, 'VoteSys');
}

defaultproperties {
	AcceptClass=class'VS_DataLink'
	RemoteRole=ROLE_None
}
