class VS_Net_ChannelLink extends Info
	imports(VS_Util_Logging)
	transient;

var VS_PlayerChannel PlayerChannel;

var bool bEnableTraffic;
var string SendBuffer;

var string RecvBuffer;
var VS_Data_Peer Peer;

var int SendCount;
var int RecvCount;

const MaxTextPerTick = 400; // assuming everything is ascii
const UnicodeMaxTextPerTick = 200; // unicode is UTF-16 on all platforms

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

	if (bEnableTraffic && Len(SendBuffer) > 0) {
		SendCount += Min(Len(SendBuffer), MaxTextPerTick);

		Chunk = Left(SendBuffer, MaxTextPerTick);
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

		if (Role == ROLE_Authority) {
			ClientReceiveText(Chunk);
		} else {
			ServerReceiveText(Chunk);
		}
		SendBuffer = Mid(SendBuffer, Len(Chunk), Len(SendBuffer));
	}

	if (Peer != none && Len(RecvBuffer) > 0) {
		Peer.Receive(RecvBuffer);
		RecvBuffer = "";
	}
}

final function ServerEnableConnection() {
	bEnableTraffic = true;
}

final simulated function ClientEnableConnection() {
	ServerEnableConnection();
	bEnableTraffic = true;
	SetTimer(Level.TimeDilation, true);
}

final simulated function SendText(coerce string Content) {
	SendBuffer = SendBuffer$Content;
}

final function ServerReceiveText(string Content) {
	RecvCount += Len(Content);
	RecvBuffer = RecvBuffer$Content;
}

final simulated function ClientReceiveText(string Content) {
	RecvCount += Len(Content);
	RecvBuffer = RecvBuffer$Content;
}

defaultproperties {
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysTick=True
}
