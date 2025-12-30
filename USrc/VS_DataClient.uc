class VS_DataClient extends TcpLink
	imports(VS_Util_Logging)
	transient;

var VS_Serialization S11N;
var string Buffer;
var string CRLF;

var bool bTransferDone;

var VS_Info Info;
var VS_PlayerChannel Channel;
var VS_DataChannel DataChannel;
var VS_Preset Preset;
var VS_Map LastMap;
var VS_ServerSettings ServerSettings;
var VS_ClientPresetList ServerPresets;
var VS_ClientMapListsContainer ServerMapLists;

var float ResolveDelay;

event PostBeginPlay() {
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
	if (IsConnected()) {
		// Len+2 to account for cr-lf at the end
		return SendText(Line$CRLF) == Len(Line) + 2;
	} else if (DataChannel != none) {
		DataChannel.SendText(Line$CRLF);
		return true;
	}

	LogErr("VS_DataClient Trying to SendLine without connection or DataChannel:"@Line);
	return false;
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

		LogMsg("VS_DataClient Opening"@IpAddrToString(RemoteAddr));
		if (BindPort(, true) != 0 && Open(RemoteAddr)) {
			LogMsg("VS_DataClient Open Succeeded");
		} else {
			LogErr("VS_DataClient Open Failed");
		}
	}
	event ResolveFailure() {
		ResolveDelay = 10;
		GotoState('Initial', 'Resolve');
		Channel.PlayerOwner.ClientMessage("Resolving failed, retrying in 10 seconds.");
	}

Begin:
	LogDbg("VS_DataClient Init");
	// Wait for replication of these variables
	while(Info == none) {
		Sleep(0.1);
		foreach AllActors(class'VS_Info', Info)
			break;
	}
	while(Info.Data.Port == 0) {
		Sleep(0.5);
	}

	if (Info.Data.Port == 0xDEADBEEF) {
		LogMsg("VS_DataClient Custom Data Transport Disabled");
		Channel.ServerSetupFallbackDataTransport();
	} else {
		LogMsg("VS_DataClient Addr="$Info.Data.Addr@"Port="$Info.Data.Port);
		LogDbg("VS_DataClient HavePort");
		LogMsg("VS_DataClient RemoteAddress"@GetRemoteAddress());

Resolve:
		Sleep(ResolveDelay);
		Resolve(GetRemoteAddress());
	}
}

function string ParsePresetRef(string Line) {
	Line = Mid(Line, 5);
	return S11N.DecodeString(Line);
}

function ParseServerSetting(string Line) {
	local string Prop, Value;

	S11N.ParseProperty(Mid(Line, 15), Prop, Value);
	if (ServerSettings.SetPropertyText(Prop, Value))
		LogDbg("Successfully set property"@Prop);
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
		LogDbg(Line);
		Channel.AddPreset(S11N.ParsePreset(Line));
	} else if (Left(Line, 5) == "/MAP/") {
		Channel.AddMap(S11N.ParseMap(Line));
	} else if (Left(Line, 5) == "/END/") {
		bTransferDone = true;
		LogDbg(Line);
		Channel.AddPreset(none);
		Channel.FocusPreset(ParsePresetRef(Line));
		Channel.UpdateFavorites();
	} else if (Left(Line, 6) == "/LOGO/") {
		LogDbg(Line);
		ParseLogo(Line);
	} else if (Left(Line, 12) == "/LOGOBUTTON/") {
		LogDbg(Line);
		ParseLogoButton(Line);
	} else if (Line == "/NOTADMIN/") {
		ServerSettings.SState = S_NOTADMIN;
		ServerSettings = none;
		ServerPresets.TransmissionState = TS_NotAdmin;
		ServerPresets = none;
	} else if (Left(Line, 15) == "/SERVERSETTING/") {
		LogDbg(Line);
		if (ServerSettings != none)
			ParseServerSetting(Line);
	} else if (Line == "/ENDSERVERSETTINGS/") {
		LogDbg("VS_DataClient GetServerSettings Done");
		ServerSettings.SState = S_COMPLETE;
	} else if (Left(Line, 25) == "/BEGINSERVERPRESETCONFIG/") {
		ServerPresets.TransmissionState = TS_New;
		ServerPresets.AllocatePresets(int(Mid(Line, 25)));
		LogDbg("VS_DataClient GetServerPresets Begin");
	} else if (Left(Line, 22) == "/SERVERPRESETPROPERTY/") {
		ParsePresetProperty(Line);
	} else if (Line == "/ENDSERVERPRESETCONFIG/") {
		ServerPresets.TransmissionState = TS_Complete;
		LogDbg("VS_DataClient GetServerPresets End");
	} else if (Left(Line, 21) == "/BEGINSERVERMAPLISTS/") {
		ServerMapLists.TransmissionState = TS_New;
		ServerMapLists.AllocateMapLists(int(Mid(Line, 21)));
		LogDbg("VS_DataClient GetServerMapLists Begin");
	} else if (Left(Line, 20) == "/BEGINSERVERMAPLIST/") {
		ParseMapListName(Line);
	} else if (Left(Line, 23) == "/SERVERMAPLISTPROPERTY/") {
		ParseMapListProperty(Line);
	} else if (Left(Line, 18) == "/ENDSERVERMAPLIST/") {
		//
	} else if (Line == "/ENDSERVERMAPLISTS/") {
		ServerMapLists.TransmissionState = TS_Complete;
		LogDbg("VS_DataClient GetServerMapLists End");
	} else if (Left(Line, 5) == "/PONG") {
		// nothing to do
	} else {
		LogMsg("Unhandled->"$Line);
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
		LogErr("More than 64KiB without line feed, discarding buffer");
		Buffer = "";
	}
}

state Talking {
Begin:
	LogMsg("VS_DataClient Connection Established");
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
	LogMsg("DataClient GetServerSettings");
	if (int(Level.EngineVersion) < 469)
		return none; // not supported without 469

	LogMsg("DataClient GetServerSettings Version OK");

	if (ServerSettings == none) {
		ServerSettings = new(none) class'VS_ServerSettings';
		SendLine("/SENDSERVERSETTINGS/");
		LogMsg("VS_DataClient GetServerSettings Settings Requested");
	}
	return ServerSettings;
}

function SendServerSetting(VS_ServerSettings S, string SettingName) {
	SendLine("/SAVESERVERSETTING/"$S11N.SerializeProperty(SettingName, S.GetPropertyText(SettingName)));
}

function SaveServerSettings(VS_ServerSettings S) {
	if (S == none)
		return;

	LogMsg("VS_DataClient SaveServerSettings");

	SendServerSetting(S, "bEnableACEIntegration");
	SendServerSetting(S, "MidGameVoteThreshold");
	SendServerSetting(S, "MidGameVoteTimeLimit");
	SendServerSetting(S, "GameEndedVoteDelay");
	SendServerSetting(S, "VoteTimeLimit");
	SendServerSetting(S, "VoteEndCondition");
	SendServerSetting(S, "bRetainCandidates");
	SendServerSetting(S, "bOpenVoteMenuAutomatically");
	SendServerSetting(S, "bEnableKickVoting");
	SendServerSetting(S, "KickVoteThreshold");
	SendServerSetting(S, "DefaultPreset");
	SendServerSetting(S, "DefaultMap");
	SendServerSetting(S, "bEnableCustomDataTransport");
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

	LogMsg("VS_DataClient SaveServerSettings Done");
}

function DiscardServerPresets() {
	ServerPresets = none;
}

function VS_ClientPresetList GetServerPresets() {
	LogMsg("DataClient GetServerPresets");
	if (int(Level.EngineVersion) < 469)
		return none; // not supported without 469

	LogMsg("VS_DataClient GetServerPresets Version OK");

	if (ServerPresets == none) {
		ServerPresets = new(XLevel) class'VS_ClientPresetList';
		SendLine("/SENDSERVERPRESETCONFIG/");
		LogMsg("VS_DataClient GetServerPresets Presets Requested");
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
	SaveServerPresetProperty(P, Prefix, "ServerName");
	SaveServerPresetProperty(P, Prefix, "Game");
	SaveServerPresetProperty(P, Prefix, "MapListName");
	SaveServerPresetProperty(P, Prefix, "Mutators");
	SaveServerPresetProperty(P, Prefix, "Parameters");
	SaveServerPresetProperty(P, Prefix, "GameSettings");
	SaveServerPresetProperty(P, Prefix, "Packages");
	SaveServerPresetProperty(P, Prefix, "bDisabled");
	SaveServerPresetProperty(P, Prefix, "bOpenVoteMenuAutomatically");
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

	LogMsg("VS_DataClient SaveServerPresets");

	for (i = 0; i < S.PresetList.Length; i++) {
		if (S.PresetList[i] != none && S.PresetList[i].PresetName != "") {
			SaveServerPreset(S.PresetList[i], i);
		} else {
			ClearServerPreset(i);
		}
	}

	SendLine("/SAVESERVERPRESETSFILE/");

	LogMsg("VS_DataClient SaveServerPresets Done");
}

function DiscardServerMapLists() {
	ServerMapLists = none;
}

function VS_ClientMapListsContainer GetServerMapLists() {
	LogMsg("DataClient GetServerMapLists");
	if (int(Level.EngineVersion) < 469)
		return none; // not supported without 469

	if (ServerMapLists == none) {
		ServerMapLists = new(XLevel) class'VS_ClientMapListsContainer';
		SendLine("/SENDSERVERMAPLISTS/");
		LogMsg("VS_DataClient GetServerMapLists Map Lists Requested");
	}

	return ServerMapLists;
}

function ParseMapListName(string Line) {
	local int Index;

	Line = Mid(Line, 20);
	Index = int(Line); S11N.NextVariable(Line);
	ServerMapLists.MapLists[Index].MapListName = S11N.DecodeString(Line);

	LogDbg("VS_DataClient GetServerMapList"@ServerMapLists.MapLists[Index].MapListName);
}

function ParseMapListProperty(string Line) {
	local int Index;
	local string PropName, PropValue;

	Line = Mid(Line, 23);

	Index = int(Line); S11N.NextVariable(Line);
	S11N.ParseProperty(Line, PropName, PropValue);

	ServerMapLists.MapLists[Index].SetPropertyText(PropName, PropValue);
}

function SaveServerMapListProperty(VS_ClientMapList M, string Prefix, string Prop) {
	SendLine(Prefix$S11N.SerializeProperty(Prop, M.GetPropertyText(Prop)));
}

function SaveServerMapList(VS_ClientMapList M, int i) {
	local string Prefix;
	Prefix = "/SAVESERVERMAPLISTPROPERTY/"$i$"/";

	SendLine("/SAVESERVERMAPLISTBEGIN/"$i$"/"$S11N.EncodeString(M.MapListName));

	SaveServerMapListProperty(M, Prefix, "Map");
	SaveServerMapListProperty(M, Prefix, "IgnoreMap");
	SaveServerMapListProperty(M, Prefix, "IncludeMapsWithPrefix");
	SaveServerMapListProperty(M, Prefix, "IgnoreMapsWithPrefix");
	SaveServerMapListProperty(M, Prefix, "IncludeList");
	SaveServerMapListProperty(M, Prefix, "IgnoreList");
}

function SaveServerMapLists(VS_ClientMapListsContainer S) {
	local int i;
	if (S == none)
		return;

	LogMsg("VS_DataClient SaveServerMapLists");

	for (i = 0; i < S.MapLists.Length; i++)
		if (S.MapLists[i] != none && S.MapLists[i].MapListName != "")
			SaveServerMapList(S.MapLists[i], i);

	SendLine("/SAVESERVERMAPLISTSFILE/");

	LogMsg("VS_DataClient SaveServerMapLists Done");
}

defaultproperties {
	RemoteRole=ROLE_None
}
