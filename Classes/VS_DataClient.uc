class VS_DataClient extends TcpLink
	transient;

var string Buffer;
var string CRLF;

var bool bTransferDone;

var VS_Info Info;
var VS_PlayerChannel Channel;
var VS_Preset Preset;
var VS_Map LastMap;

var float ResolveDelay;

event PostBeginPlay() {
	Log("VS_DataClient.PostBeginPlay", 'VoteSys');
	LinkMode = MODE_Text;
	ReceiveMode = RMODE_Event;
	CRLF = Chr(13)$Chr(10);
	Channel = VS_PlayerChannel(Owner);

	SetTimer(5 * Level.TimeDilation, true);

	foreach AllActors(class'VS_Info', Info)
		break;
}

function string GetRemoteAddress() {
	local string Result;
	local string LevelAddress;
	local int PortPos;

	if (Info.Data.Addr != "") // server wants us to connect to this
		return Info.Data.Addr;

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

auto state Initial {
	event Opened() {
		GotoState('Talking');
	}
	event Resolved(IpAddr Addr) {
		RemoteAddr.Addr = Addr.Addr;
		if (Addr.Addr == 0) // listen servers have this address
			StringToIpAddr("127.0.0.1", RemoteAddr);
		RemoteAddr.Port = Info.Data.Port;

		Log("VS_DataClient Opening"@IpAddrToString(RemoteAddr), 'VoteSys');
		if (BindPort(, true) != 0 && Open(RemoteAddr)) {
			Log("VS_DataClient Open Succeeded", 'VoteSys');
		} else {
			Log("VS_DataClient Open Failed", 'VoteSys');
		}
	}
	event ResolveFailure() {
		ResolveDelay = 10;
		GotoState('Initial', 'Resolve');
		Channel.PlayerOwner.ClientMessage("Resolving failed, retrying in 10 seconds.");
	}

Begin:
	Log("VS_DataClient Init", 'VoteSys');
	// Wait for replication of these variables
	while(Info == none) {
		Sleep(0.1);
		foreach AllActors(class'VS_Info', Info)
			break;
	}
	while(Info.Data.Port == 0) {
		Sleep(0.5);
		Log("VS_DataClient Addr="$Info.Data.Addr@"Port="$Info.Data.Port, 'VoteSys');
	}
	Log("VS_DataClient HavePort", 'VoteSys');
	Log("VS_DataClient RemoteAddress"@GetRemoteAddress(), 'VoteSys');

Resolve:
	Sleep(ResolveDelay);
	Resolve(GetRemoteAddress());
}

function string DecodeString(out string S) {
	local int i;
	local string Result;

	if (Left(S, 1) != "\"")
		return "";

	S = Mid(S, 1);

	i = InStr(S, "\"");
	while(i >= 0) {
		if (i == 0) {
			S = Mid(S, 1);
			return Result;
		}

		if (Mid(S, i-1, 1) == "\\") {
			Result = Result $ Left(S, i-1) $ "\"";
			S = Mid(S, i+1);
		} else {
			Result = Result $ Left(S, i);
			S = Mid(S, i+1);
			return Result;
		}

		i = InStr(S, "\"");
	}

	return Result $ S;
}

function NextVariable(out string L) {
	local int Pos;

	Pos = InStr(L, "/");

	if (Pos >= 0)
		L = Mid(L, Pos+1);
	else
		L = "";
}

function VS_Preset ParsePreset(string Line) {
	local VS_Preset P;

	P = new(none) class'VS_Preset';

	Line = Mid(Line, 8);
	//                         |   Parse Content    | Skip /
	P.PresetName               = DecodeString(Line); NextVariable(Line);
	P.Abbreviation             = DecodeString(Line); NextVariable(Line);
	P.Category                 = DecodeString(Line); NextVariable(Line);
	P.MaxSequenceNumber        = int(Line);          NextVariable(Line);
	P.MinimumMapRepeatDistance = int(Line);          NextVariable(Line);
	P.SortPriority             = int(Line);

	return P;
}

function VS_Map ParseMap(string Line) {
	local VS_Map M;
	M = new(none) class'VS_Map';
	Line = Mid(Line, 5);
	M.MapName = DecodeString(Line); Line = Mid(Line, 1);
	M.Sequence = int(Line);
	return M;
}

function string ParsePresetRef(string Line) {
	Line = Mid(Line, 5);
	return DecodeString(Line);
}

function ParseLine(string Line) {
	if (Left(Line, 8) == "/PRESET/") {
		bTransferDone = false;
		Log(Line, 'VoteSys');
		Channel.AddPreset(ParsePreset(Line));
	} else if (Left(Line, 5) == "/MAP/") {
		Channel.AddMap(ParseMap(Line));
	} else if (Left(Line, 4) == "/END") {
		bTransferDone = true;
		Log(Line, 'VoteSys');
		Channel.AddPreset(none);
		Channel.FocusPreset(ParsePresetRef(Line));
	} else if (Left(Line, 5) == "/PONG") {
		// nothing to do
	} else {
		Log(Left(Line, Len(Line)), 'VoteSys');
	}
}

event ReceivedText(string Text) {
	local int Pos;

	Text = Buffer$Text;

	for(Pos = InStr(Text, CRLF); Pos > -1; Pos = InStr(Text, CRLF)) {
		ParseLine(Left(Text, Pos));

		Text = Mid(Text, Pos+2);
	}

	Buffer = Text;
}

state Talking {
Begin:
	Log("VS_DataClient Connection Established", 'VoteSys');
	SendText("/SENDPRESETS"$CRLF);

	while(Channel.Cookie == 0)
		Sleep(0);
	SendText("/COOKIE/"$Channel.Cookie$CRLF);
}

event Closed() {
	GotoState('Initial');
}

event Timer() {
	if (IsConnected())
		SendText("/PING"$CRLF);
}

defaultproperties {
	RemoteRole=ROLE_None
}
