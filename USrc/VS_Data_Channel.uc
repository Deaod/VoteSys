class VS_Data_Channel extends Info
	imports(VS_Util_Logging)
	transient;

// Fallback in case TcpLink doesnt work

var VS_PlayerChannel PlayerChannel;

var bool bEnableTraffic;
var string SendBuffer;

var string RecvBuffer;
var TcpLink Link;

var int SendCount;
var int RecvCount;

const MaxTextPerTick = 400;

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
	if (bEnableTraffic && Len(SendBuffer) > 0) {
		SendCount += Min(Len(SendBuffer), MaxTextPerTick);

		if (Role == ROLE_Authority) {
			ClientReceiveText(Left(SendBuffer, MaxTextPerTick));
			SendBuffer = Mid(SendBuffer, MaxTextPerTick, Len(SendBuffer));
		} else {
			ServerReceiveText(Left(SendBuffer, MaxTextPerTick));
			SendBuffer = Mid(SendBuffer, MaxTextPerTick, Len(SendBuffer));
		}
	}

	if (Link != none && Len(RecvBuffer) > 0) {
		Link.ReceivedText(RecvBuffer);
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
