class VS_DataClient extends TcpLink
	transient;

var Serialization S11N;
var string Buffer;
var string CRLF;

var bool bTransferDone;

var VS_Info Info;
var VS_PlayerChannel Channel;
var VS_Preset Preset;
var VS_Map LastMap;
var VS_ServerSettings ServerSettings;

var float ResolveDelay;

event PostBeginPlay() {
	Log("VS_DataClient.PostBeginPlay", 'VoteSys');
	LinkMode = MODE_Text;
	ReceiveMode = RMODE_Event;
	S11N = class'Serialization'.static.Instance();
	CRLF = Chr(13)$Chr(10);
	Channel = VS_PlayerChannel(Owner);

	SetTimer(5 * Level.TimeDilation, true);

	foreach AllActors(class'VS_Info', Info)
		break;
}

final function bool SendLine(string Line) {
	// Len+2 to account for cr-lf at the end
	return SendText(Line$CRLF) == Len(Line) + 2;
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

function string ParsePresetRef(string Line) {
	Line = Mid(Line, 5);
	return S11N.DecodeString(Line);
}

function ParseServerSetting(string Line) {
	local string Prop, Value;

	S11N.ParseProperty(Mid(Line, 15), Prop, Value);
	if (ServerSettings.SetPropertyText(Prop, Value))
		Log("Successfully set property"@Prop, 'VoteSys');
}

function ParseLine(string Line) {
	if (Left(Line, 8) == "/PRESET/") {
		bTransferDone = false;
		Log(Line, 'VoteSys');
		Channel.AddPreset(S11N.ParsePreset(Line));
	} else if (Left(Line, 5) == "/MAP/") {
		Channel.AddMap(S11N.ParseMap(Line));
	} else if (Left(Line, 5) == "/END/") {
		bTransferDone = true;
		Log(Line, 'VoteSys');
		Channel.AddPreset(none);
		Channel.FocusPreset(ParsePresetRef(Line));
	} else if (Line == "/NOTADMIN/") {
		ServerSettings.SState = S_NOTADMIN;
		ServerSettings = none;
	} else if (Left(Line, 15) == "/SERVERSETTING/") {
		Log(Line, 'VoteSys');
		if (ServerSettings != none)
			ParseServerSetting(Line);
	} else if (Line == "/ENDSERVERSETTINGS/") {
		Log("VS_DataClient GetServerSettings Done", 'VoteSys');
		ServerSettings.SState = S_COMPLETE;
	} else if (Left(Line, 5) == "/PONG") {
		// nothing to do
	} else {
		Log("Unhandled->"$Line, 'VoteSys');
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

	if (Len(Buffer) >= 0x10000) {
		Log("More than 64KiB without line feed, discarding buffer", 'VoteSys');
		Buffer = "";
	}
}

state Talking {
Begin:
	Log("VS_DataClient Connection Established", 'VoteSys');
	SendLine("/SENDPRESETS");

	while(Channel.Cookie == 0)
		Sleep(0);
	SendLine("/COOKIE/"$Channel.Cookie);
}

event Closed() {
	GotoState('Initial');
}

event Timer() {
	if (IsConnected())
		SendLine("/PING");
}

function VS_ServerSettings GetServerSettings() {
	Log("DataClient GetServerSettings", 'VoteSys');
	if (int(Level.EngineVersion) < 469)
		return none; // not supported without 469

	Log("DataClient GetServerSettings Version OK", 'VoteSys');

	if (ServerSettings == none) {
		ServerSettings = new(none) class'VS_ServerSettings';
		SendLine("/SENDSERVERSETTINGS/");
		Log("VS_DataClient GetServerSettings Settings Requested", 'VoteSys');
	}
	return ServerSettings;
}

function SendServerSetting(VS_ServerSettings S, string SettingName) {
	SendLine("/SAVESERVERSETTING/"$S11N.SerializeProperty(SettingName, ServerSettings.GetPropertyText(SettingName)));
}

function SaveServerSettings(VS_ServerSettings S) {
	Log("DataClient SaveServerSettings", 'VoteSys');

	if (S == none)
		return;

	Log("VS_DataClient SaveServerSettings", 'VoteSys');

	SendServerSetting(S, "MidGameVoteThreshold");
	SendServerSetting(S, "MidGameVoteTimeLimit");
	SendServerSetting(S, "GameEndedVoteDelay");
	SendServerSetting(S, "VoteTimeLimit");
	SendServerSetting(S, "VoteEndCondition");
	SendServerSetting(S, "bRetainCandidates");
	SendServerSetting(S, "KickVoteThreshold");
	SendServerSetting(S, "DefaultPreset");
	SendServerSetting(S, "DefaultMap");
	SendServerSetting(S, "ServerAddress");
	SendServerSetting(S, "DataPort");
	SendServerSetting(S, "ClientDataPort");
	SendServerSetting(S, "bManageServerPackages");
	SendServerSetting(S, "bUseServerPackagesCompatibilityMode");
	SendServerSetting(S, "bUseServerActorsCompatibilityMode");
	SendServerSetting(S, "DefaultPackages");
	SendServerSetting(S, "DefaultActors");
	SendServerSetting(S, "DefaultTimeMessageClass");
	SendServerSetting(S, "IdleTimeout");
	SendServerSetting(S, "MinimumMapRepeatDistance");
	SendServerSetting(S, "PresetProbeDepth");
	SendServerSetting(S, "GameNameMode");
	SendServerSetting(S, "bAlwaysUseDefaultPreset");
	SendServerSetting(S, "bAlwaysUseDefaultMap");
	SendLine("/SAVESERVERSETTINGSFILE/");

	Log("VS_DataClient SaveServerSettings Done", 'VoteSys');
}

defaultproperties {
	RemoteRole=ROLE_None
}
