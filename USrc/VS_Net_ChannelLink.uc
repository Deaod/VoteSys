class VS_Net_ChannelLink extends Info
	imports(VS_Util_Logging)
	transient;

var VS_PlayerChannel PlayerChannel;

struct Simplex {
	var() string Buffer;
	var() int Count;
};

struct Connection {
	var VS_Data_Peer Peer;
	var() Simplex Tx;
	var() Simplex Rx;
};

var bool bEnableTraffic;
var Connection Client;
var Connection Server;

const MaxTextPerTick = 400; // assuming everything is ascii
//const UnicodeMaxTextPerTick = 200; // unicode is UTF-16 on all platforms
const UnicodeMaxTextPerTick = 100; // surrogate pairs exist ...

replication {
	reliable if (Role < ROLE_Authority)
		ServerEnableConnection,
		ServerReceiveText;

	reliable if (Role == ROLE_Authority)
		ClientReceiveText;
}

simulated event PostNetBeginPlay() {
	PlayerChannel = VS_PlayerChannel(Owner);
	PlayerChannel.ClientSetupFallbackDataTransport(self);
}

simulated event Tick(float Delta) {
	local string Chunk;
	local int CL;
	local int I;

	if (PlayerChannel != none && Viewport(PlayerChannel.PlayerOwner.Player) != none && Client.Peer == none) {
		// deals with listen server
		PlayerChannel.ClientSetupFallbackDataTransport(self);
	}

	if (Client.Peer != none && Len(Client.Rx.Buffer) > 0) {
		Client.Peer.Receive(Client.Rx.Buffer);
		Client.Rx.Buffer = "";
	}

	if (Server.Peer != none && Len(Server.Rx.Buffer) > 0) {
		Server.Peer.Receive(Server.Rx.Buffer);
		Server.Rx.Buffer = "";
	}

	if (bEnableTraffic == false)
		return;

	if (Len(Client.Tx.Buffer) > 0) {
		Client.Tx.Count += Min(Len(Client.Tx.Buffer), MaxTextPerTick);

		Chunk = Left(Client.Tx.Buffer, MaxTextPerTick);
		CL = Len(Chunk);
		for (I = 0; I < CL; I++) {
			if (Asc(Mid(Chunk, i, 1)) > 0x7F) {
				if (I > UnicodeMaxTextPerTick) {
					Chunk = Left(Chunk, I);
				} else {
					Chunk = Left(Chunk, UnicodeMaxTextPerTick);
				}
				break;
			}
		}

		ServerReceiveText(Chunk);
		Client.Tx.Buffer = Mid(Client.Tx.Buffer, Len(Chunk), Len(Client.Tx.Buffer));
	}

	if (Len(Server.Tx.Buffer) > 0) {
		Server.Tx.Count += Min(Len(Server.Tx.Buffer), MaxTextPerTick);

		Chunk = Left(Server.Tx.Buffer, MaxTextPerTick);
		CL = Len(Chunk);
		for (I = 0; I < CL; I++) {
			if (Asc(Mid(Chunk, i, 1)) > 0x7F) {
				if (I > UnicodeMaxTextPerTick) {
					Chunk = Left(Chunk, I);
				} else {
					Chunk = Left(Chunk, UnicodeMaxTextPerTick);
				}
				break;
			}
		}

		ClientReceiveText(Chunk);
		Server.Tx.Buffer = Mid(Server.Tx.Buffer, Len(Chunk), Len(Server.Tx.Buffer));
	}
}

final simulated function ClientEnableConnection() {
	ServerEnableConnection();
	bEnableTraffic = true;
	LogDbg("VS_Net_ChannelLink ClientEnableConnection");
}

final function ServerEnableConnection() {
	bEnableTraffic = true;
	LogDbg("VS_Net_ChannelLink ServerEnableConnection");
}

final simulated function ClientSendText(coerce string Content) {
	Client.Tx.Buffer = Client.Tx.Buffer$Content;
}

final function ServerSendText(coerce string Content) {
	Server.Tx.Buffer = Server.Tx.Buffer$Content;
}

final simulated function ClientReceiveText(string Content) {
	Client.Rx.Count += Len(Content);
	Client.Rx.Buffer = Client.Rx.Buffer$Content;
}

final function ServerReceiveText(string Content) {
	Server.Rx.Count += Len(Content);
	Server.Rx.Buffer = Server.Rx.Buffer$Content;
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysTick=True
}
