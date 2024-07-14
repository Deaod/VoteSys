class VS_DataClient extends TcpLink
	transient;

var VS_Serialization S11N;
var string Buffer;
var string CRLF;

var bool bTransferDone;

var VS_Info Info;
var VS_PlayerChannel Channel;
var VS_Preset Preset;
var VS_Map LastMap;
var VS_ServerSettings ServerSettings;
var VS_ClientPresetList ServerPresets;

var float ResolveDelay;

event PostBeginPlay() {
	Log("VS_DataClient.PostBeginPlay", 'VoteSys');
	LinkMode = MODE_Text;
	ReceiveMode = RMODE_Event;
	S11N = class'VS_Serialization'.static.Instance();
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

function ParseLogo(string Line) {
	local string Tex;
	local int TexX, TexY, TexW, TexH;
	local int DrawX, DrawY, DrawW, DrawH;
	Line = Mid(Line, 6);

	Tex   = S11N.DecodeString(Line); S11N.NextVariable(Line);
	TexX  = int(Line);               S11N.NextVariable(Line);
	TexY  = int(Line);               S11N.NextVariable(Line);
	TexW  = int(Line);               S11N.NextVariable(Line);
	TexH  = int(Line);               S11N.NextVariable(Line);
	DrawX = int(Line);               S11N.NextVariable(Line);
	DrawY = int(Line);               S11N.NextVariable(Line);
	DrawW = int(Line);               S11N.NextVariable(Line);
	DrawH = int(Line);

	Channel.ConfigureLogo(Tex, TexX, TexY, TexW, TexH, DrawX, DrawY, DrawW, DrawH);
}

function ParseLogoButton(string Line) {
	local int Index;
	local string Label, LinkURL;
	Line = Mid(Line, 12);

	Index   = int(Line);               S11N.NextVariable(Line);
	Label   = S11N.DecodeString(Line); S11N.NextVariable(Line);
	LinkURL = S11N.DecodeString(Line);

	Channel.ConfigureLogoButton(Index, Label, LinkURL);
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
		Channel.UpdateFavorites();
	} else if (Left(Line, 6) == "/LOGO/") {
		Log(Line, 'VoteSys');
		ParseLogo(Line);
	} else if (Left(Line, 12) == "/LOGOBUTTON/") {
		Log(Line, 'VoteSys');
		ParseLogoButton(Line);
	} else if (Line == "/NOTADMIN/") {
		ServerSettings.SState = S_NOTADMIN;
		ServerSettings = none;
		ServerPresets.TransmissionState = TS_NotAdmin;
		ServerPresets = none;
	} else if (Left(Line, 15) == "/SERVERSETTING/") {
		Log(Line, 'VoteSys');
		if (ServerSettings != none)
			ParseServerSetting(Line);
	} else if (Line == "/ENDSERVERSETTINGS/") {
		Log("VS_DataClient GetServerSettings Done", 'VoteSys');
		ServerSettings.SState = S_COMPLETE;
	} else if (Left(Line, 25) == "/BEGINSERVERPRESETCONFIG/") {
		ServerPresets.TransmissionState = TS_New;
		ServerPresets.AllocatePresets(int(Mid(Line, 25)));
		Log("VS_DataClient GetServerPresets Begin", 'VoteSys');
	} else if (Left(Line, 22) == "/SERVERPRESETPROPERTY/") {
		ParsePresetProperty(Line);
	} else if (Line == "/ENDSERVERPRESETCONFIG/") {
		ServerPresets.TransmissionState = TS_Complete;
		Log("VS_DataClient GetServerPresets End", 'VoteSys');
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
	SendLine("/SENDLOGO/");

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

function DiscardServerSettings() {
	ServerSettings = none;
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
	SendLine("/SAVESERVERSETTING/"$S11N.SerializeProperty(SettingName, S.GetPropertyText(SettingName)));
}

function SaveServerSettings(VS_ServerSettings S) {
	if (S == none)
		return;

	Log("VS_DataClient SaveServerSettings", 'VoteSys');

	SendServerSetting(S, "bEnableACEIntegration");
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
	SendServerSetting(S, "LogoTexture");
	SendServerSetting(S, "LogoRegion");
	SendServerSetting(S, "LogoButton0");
	SendServerSetting(S, "LogoButton1");
	SendServerSetting(S, "LogoButton2");
	SendLine("/SAVESERVERSETTINGSFILE/");

	Log("VS_DataClient SaveServerSettings Done", 'VoteSys');
}

function DiscardServerPresets() {
	ServerPresets = none;
}

function VS_ClientPresetList GetServerPresets() {
	Log("DataClient GetServerPresets", 'VoteSys');
	if (int(Level.EngineVersion) < 469)
		return none; // not supported without 469

	Log("VS_DataClient GetServerPresets Version OK", 'VoteSys');

	if (ServerPresets == none) {
		ServerPresets = new(none) class'VS_ClientPresetList';
		SendLine("/SENDSERVERPRESETCONFIG/");
		Log("VS_DataClient GetServerPresets Presets Requested", 'VoteSys');
	}
	return ServerPresets;
}

function ParsePresetProperty(string Line) {
	local int Index;
	local string Prop, Value;
	Line = Mid(Line, 22);
	Index = int(Line); S11N.NextVariable(Line);
	S11N.ParseProperty(Line, Prop, Value);
	ServerPresets.PresetList[Index].SetPropertyText(Prop, Value);
}

function SaveServerPresetProperty(VS_ClientPreset P, string Prefix, string Prop) {
	SendLine(Prefix$S11N.SerializeProperty(Prop, P.GetPropertyText(Prop)));
}

function SaveServerPreset(VS_ClientPreset P, int i) {
	local string Prefix;
	Prefix = "/SAVESERVERPRESET/"$i$"/";

	SaveServerPresetProperty(P, Prefix, "PresetName");
	SaveServerPresetProperty(P, Prefix, "Abbreviation");
	SaveServerPresetProperty(P, Prefix, "Category");
	SaveServerPresetProperty(P, Prefix, "SortPriority");
	SaveServerPresetProperty(P, Prefix, "InheritFrom");
	SaveServerPresetProperty(P, Prefix, "Game");
	SaveServerPresetProperty(P, Prefix, "MapListName");
	SaveServerPresetProperty(P, Prefix, "Mutators");
	SaveServerPresetProperty(P, Prefix, "Parameters");
	SaveServerPresetProperty(P, Prefix, "GameSettings");
	SaveServerPresetProperty(P, Prefix, "Packages");
	SaveServerPresetProperty(P, Prefix, "bDisabled");
	SaveServerPresetProperty(P, Prefix, "MinimumMapRepeatDistance");
	SaveServerPresetProperty(P, Prefix, "MinPlayers");
	SaveServerPresetProperty(P, Prefix, "MaxPlayers");
}

function ClearServerPreset(int i) {
	SendLine("/CLEARSERVERPRESET/"$i);
}

function SaveServerPresets(VS_ClientPresetList S) {
	local int i;
	if (S == none)
		return;

	Log("VS_DataClient SaveServerPresets", 'VoteSys');

	for (i = 0; i < S.PresetList.Length; i++) {
		if (S.PresetList[i] != none && S.PresetList[i].PresetName != "") {
			SaveServerPreset(S.PresetList[i], i);
		} else {
			ClearServerPreset(i);
		}
	}

	SendLine("/SAVESERVERPRESETSFILE/");

	Log("VS_DataClient SaveServerPresets Done", 'VoteSys');
}

defaultproperties {
	RemoteRole=ROLE_None
}
