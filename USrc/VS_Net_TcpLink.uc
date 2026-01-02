class VS_Net_TcpLink extends TcpLink
	imports(VS_Util_Logging)
	transient;

var MutVoteSys VoteSys;

var string Buffer;
var string CRLF;

var VS_Data_Peer Peer;
var VS_ChannelContainer Channel;

var string TargetAddress;
var int TargetPort;
var float ResolveDelay;

event PostBeginPlay() {
	LinkMode = MODE_Text;
	ReceiveMode = RMODE_Event;
	CRLF = Chr(13)$Chr(10);
}

event Accepted() {
	LogMsg("VS_Net_TcpLink Accepted"@IpAddrToString(RemoteAddr));
	GotoState('ServerMode');
}

function ConnectTo(string Address, int Port) {
	if (Address == "")
		Address = GetRemoteAddress();

	TargetAddress = Address;
	TargetPort = Port;
	
	GoToState('ClientMode');
}

state ServerMode {
	function SearchCookie() {
		local int Pos;
		local string Line, Text;

		Text = Buffer;
		for (Pos = InStr(Text, CRLF); Pos > -1; Pos = InStr(Text, CRLF)) {
			Line = Left(Text, Pos);
			if (Left(Line, 8) == "/COOKIE/") {
				Channel = VoteSys.FindChannelForCookie(int(Mid(Line, 8)));
				LogDbg("VS_Net_TcpLink Found Channel"@Channel);
			}

			Text = Mid(Text, Pos+2, Len(Text));
		}
	}

	event BeginState() {
		foreach AllActors(class'MutVoteSys', VoteSys)
			break;
	}

	event ReceivedText(string Text) {
		if (Peer != none) {
			Peer.Receive(Text);
			return;
		}

		Buffer = Buffer$Text;
		SearchCookie();
		if (Channel != none) {
			Channel.Channel.ServerSetupCustomDataTransport(self);
			Peer.Receive(Buffer);
			Buffer = "";
		}
	}
}

state ClientMode {
	event Opened() {
		Peer.Connected();
	}

	event Closed() {
		GoToState('ClientMode', 'Begin');
	}

	event Resolved(IpAddr Addr) {
		RemoteAddr.Addr = Addr.Addr;
		if (Addr.Addr == 0) // listen servers have this address
			StringToIpAddr("127.0.0.1", RemoteAddr);
		RemoteAddr.Port = TargetPort;

		LogMsg("VS_Net_TcpLink Opening"@IpAddrToString(RemoteAddr));
		if (BindPort(, true) != 0 && Open(RemoteAddr)) {
			LogMsg("VS_Net_TcpLink Open Succeeded");
		} else {
			LogErr("VS_Net_TcpLink Open Failed");
		}
	}

	event ResolveFailure() {
		ResolveDelay = 10;
		GotoState('Initial', 'Resolve');
		Channel.PlayerOwner.ClientMessage("Resolving failed, retrying in 10 seconds.");
	}

	event ReceivedText(string Text) {
		if (Peer != none)
			Peer.Receive(Text);
	}

Begin:
	LogMsg("VS_Net_TcpLink Addr="$TargetAddress@"Port="$TargetPort);
	LogDbg("VS_Net_TcpLink HavePort");
	LogMsg("VS_Net_TcpLink RemoteAddress"@TargetAddress);

Resolve:
	Sleep(ResolveDelay);
	Resolve(TargetAddress);
}

function string GetRemoteAddress() {
	local string Result;
	local string LevelAddress;
	local int PortPos;

	LevelAddress = Level.GetAddressURL();
	if (Left(LevelAddress, 1) == "[") {
		// ipv6
		Result = Mid(LevelAddress, 1);
		Result = Left(Result, InStr(Result, "]"));
		return Result;
	} else {
		// ipv4 or domain
		PortPos = InStr(LevelAddress, ":");
		if (PortPos == -1)
			return LevelAddress;
		else 
			return Left(LevelAddress, PortPos);
	}
}
