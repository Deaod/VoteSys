class VS_DataLink extends TcpLink
	transient;

var string Buffer;
var MutVoteSys VoteSys;
var VS_ChannelContainer Channel;

var string SendBuffer;
var VS_Preset TempPreset;
var VS_Map TempMap;
var VS_Serialization S11N;

var string CRLF;

struct Command {
	var name Id;
	var string Params;
};

var array<Command> QueuedCommands;
var name CurrentCommand;
var string CommandParams;

event PostBeginPlay() {
	LinkMode = MODE_Text;
	ReceiveMode = RMODE_Event;
	S11N = class'VS_Serialization'.static.Instance();
	CRLF = Chr(13)$Chr(10);

	foreach AllActors(class'MutVoteSys', VoteSys)
		break;
}

event Closed() {
	Destroy();
}

final function bool SendLine(string Line) {
	// Len+2 to account for cr-lf at the end
	return SendText(Line$CRLF) == Len(Line) + 2;
}

function QueueCommand(name Command, optional coerce string Params) {
	local int Index;
	Index = QueuedCommands.Length;
	QueuedCommands.Insert(Index, 1);
	QueuedCommands[Index].Id = Command;
	QUeuedCommands[Index].Params = Params;
}

state Idle {
Begin:
	if (QueuedCommands.Length > 0) {
		CurrentCommand = QueuedCommands[0].Id;
		CommandParams = QueuedCommands[0].Params;
		QueuedCommands.Remove(0, 1);
		GoToState(CurrentCommand);
	} else {
		Sleep(0);
		goto 'Begin';
	}
}

// This functions needs to survive unknown commands without errors
function ParseLine(string Line) {
	if (Len(Line) <= 0)
		return;

	if (Line == "/PING") {
		SendLine("/PONG");
	} else if (Line == "/SENDPRESETS") {
		QueueCommand('SendPresets');
	} else if (Line == "/SENDLOGO/") {
		QueueCommand('SendLogo');
	} else if (Left(Line, 8) == "/COOKIE/") {
		Channel = VoteSys.FindChannelForCookie(int(Mid(Line, 8)));
		Log("VS_DataLink Found Channel"@Channel, 'VoteSys');
	} else if (Line == "/SENDSERVERSETTINGS/") {
		QueueCommand('SendServerSettings');
	} else if (Left(Line, 19) == "/SAVESERVERSETTING/") {
		SaveServerSetting(Line);
	} else if (Line == "/SAVESERVERSETTINGSFILE/") {
		VoteSys.Settings.SaveConfig();
	} else if (Line == "/SENDSERVERPRESETCONFIG/") {
		QueueCommand('SendServerPresets');
	}
}

// no difference to ReceiveText
event ReceivedText(string Text) {
	local int Pos;

	Text = Buffer$Text;

	for(Pos = InStr(Text, CRLF); Pos > -1; Pos = InStr(Text, CRLF)) {
		ParseLine(Left(Text, Pos));

		Text = Mid(Text, Pos+2);
	}

	Buffer = Text;

	if (Len(Buffer) >= 0x10000) {
		Log("More than 64KiB without line feed, discarding buffer ("$IpAddrToString(RemoteAddr)$")", 'VoteSys');
		Buffer = "";
	}
}

event Accepted() {
	Log("VS_DataLink Accepted"@IpAddrToString(RemoteAddr), 'VoteSys');
	GotoState('Idle');
}

state SendPresets {
Begin:
	foreach AllActors(class'MutVoteSys', VoteSys)
		break;
	while(VoteSys.HistoryProcessor != none)
		Sleep(0);

	Log("VS_DataLink SendPresets"@IpAddrToString(RemoteAddr), 'VoteSys');

	for (TempPreset = VoteSys.PresetList; TempPreset != none; TempPreset = TempPreset.Next) {
		if (TempPreset.bDisabled)
			continue;

		SendLine(S11N.SerializePreset(TempPreset));
		for (TempMap = TempPreset.MapList; TempMap != none; TempMap = TempMap.Next) {
			SendLine(S11N.SerializeMap(TempMap));
		}
	}

	SendLine("/END/"$S11N.EncodeString(VoteSys.CurrentPreset));

	Log("VS_DataLink SendPresets Done"@IpAddrToString(RemoteAddr), 'VoteSys');
	GoToState('Idle');
}

state SendLogo {
Begin:
	SendLine("/LOGO/"$S11N.EncodeString(VoteSys.Settings.LogoTexture)$
		"/"$VoteSys.Settings.LogoRegion.X$
		"/"$VoteSys.Settings.LogoRegion.Y$
		"/"$VoteSys.Settings.LogoRegion.W$
		"/"$VoteSys.Settings.LogoRegion.H$
		"/"$VoteSys.Settings.LogoDrawRegion.X$
		"/"$VoteSys.Settings.LogoDrawRegion.Y$
		"/"$VoteSys.Settings.LogoDrawRegion.W$
		"/"$VoteSys.Settings.LogoDrawRegion.H
	);

	SendLine("/LOGOBUTTON/0/"$
		S11N.EncodeString(VoteSys.Settings.LogoButton0.Label)$"/"$
		S11N.EncodeString(VoteSys.Settings.LogoButton0.LinkURL)
	);
	SendLine("/LOGOBUTTON/1/"$
		S11N.EncodeString(VoteSys.Settings.LogoButton1.Label)$"/"$
		S11N.EncodeString(VoteSys.Settings.LogoButton1.LinkURL)
	);
	SendLine("/LOGOBUTTON/2/"$
		S11N.EncodeString(VoteSys.Settings.LogoButton2.Label)$"/"$
		S11N.EncodeString(VoteSys.Settings.LogoButton2.LinkURL)
	);

	GoToState('Idle');
}

state SendServerSettings {
	function SendServerSetting(string SettingName) {
		SendLine("/SERVERSETTING/"$S11N.SerializeProperty(SettingName, VoteSys.Settings.GetPropertyText(SettingName)));
	}

Begin:
	if (Channel == none ||
		Channel.PlayerOwner == none ||
		Channel.PlayerOwner.bAdmin == false
	) {
		SendLine("/NOTADMIN/");
		GoToState('Idle');
	}

	Log("VS_DataLink SendServerSettings"@IpAddrToString(RemoteAddr), 'VoteSys');

	SendServerSetting("MidGameVoteThreshold");
	SendServerSetting("MidGameVoteTimeLimit");
	SendServerSetting("GameEndedVoteDelay");
	SendServerSetting("VoteTimeLimit");
	SendServerSetting("VoteEndCondition");
	SendServerSetting("bRetainCandidates");
	SendServerSetting("KickVoteThreshold");
	SendServerSetting("DefaultPreset");
	SendServerSetting("DefaultMap");
	SendServerSetting("ServerAddress");
	SendServerSetting("DataPort");
	SendServerSetting("ClientDataPort");
	SendServerSetting("bManageServerPackages");
	SendServerSetting("bUseServerPackagesCompatibilityMode");
	SendServerSetting("bUseServerActorsCompatibilityMode");
	SendServerSetting("DefaultPackages");
	SendServerSetting("DefaultActors");
	SendServerSetting("DefaultTimeMessageClass");
	SendServerSetting("IdleTimeout");
	SendServerSetting("MinimumMapRepeatDistance");
	SendServerSetting("PresetProbeDepth");
	SendServerSetting("GameNameMode");
	SendServerSetting("bAlwaysUseDefaultPreset");
	SendServerSetting("bAlwaysUseDefaultMap");
	SendServerSetting("LogoTexture");
	SendServerSetting("LogoRegion");
	SendServerSetting("LogoButton0");
	SendServerSetting("LogoButton1");
	SendServerSetting("LogoButton2");
	SendLine("/ENDSERVERSETTINGS/");

	Log("VS_DataLink SendServerSettings Done"@IpAddrToString(RemoteAddr), 'VoteSys');
	GoToState('Idle');
}

function SaveServerSetting(string Line) {
	local string PropertyName;
	local string PropertyValue;

	if (Channel == none ||
		Channel.PlayerOwner == none ||
		Channel.PlayerOwner.bAdmin == false
	) {
		return;
	}

	S11N.ParseProperty(Mid(Line, 19), PropertyName, PropertyValue);

	if (VoteSys.Settings.SetPropertyText(PropertyName, PropertyValue))
		Log("Successfully set property"@PropertyName@"to"@PropertyValue, 'VoteSys');
}

state SendServerPresets {
	function SendServerPreset(VS_PresetConfig PC, int Index) {
		local string Prefix;
		Prefix = "/SERVERPRESETPROPERTY/" $ Index $ "/";

		SendServerPresetProperty(Prefix, PC, "PresetName");
		SendServerPresetProperty(Prefix, PC, "Abbreviation");
		SendServerPresetProperty(Prefix, PC, "Category");
		SendServerPresetProperty(Prefix, PC, "SortPriority");
		SendServerPresetProperty(Prefix, PC, "InheritFrom");
		SendServerPresetProperty(Prefix, PC, "Game");
		SendServerPresetProperty(Prefix, PC, "MapListName");
		SendServerPresetProperty(Prefix, PC, "Mutators");
		SendServerPresetProperty(Prefix, PC, "Parameters");
		SendServerPresetProperty(Prefix, PC, "GameSettings");
		SendServerPresetProperty(Prefix, PC, "Packages");
		SendServerPresetProperty(Prefix, PC, "bDisabled");
		SendServerPresetProperty(Prefix, PC, "MinimumMapRepeatDistance");
		SendServerPresetProperty(Prefix, PC, "MinPlayers");
		SendServerPresetProperty(Prefix, PC, "MaxPlayers");
	}

	function SendServerPresetProperty(string Prefix, VS_PresetConfig PC, string PropName) {
		SendLine(Prefix $ S11N.SerializeProperty(PropName, PC.GetPropertyText(PropName)));
	}

Begin:
	if (Channel == none ||
		Channel.PlayerOwner == none ||
		Channel.PlayerOwner.bAdmin == false
	) {
		SendLine("/NOTADMIN/");
		GoToState('Idle');
	}

	Log("VS_DataLink SendServerPresets"@IpAddrToString(RemoteAddr), 'VoteSys');
	SendLine("/BEGINSERVERPRESETCONFIG/"$VoteSys.PresetMaxIndex);

	for (TempPreset = VoteSys.PresetList; TempPreset != none; TempPreset = TempPreset.Next) {
		SendServerPreset(TempPreset.Storage, TempPreset.StorageIndex);
	}

	SendLine("/ENDSERVERPRESETCONFIG/");

	GoToState('Idle');
}

function HandleError() {
	SendLine("/RECONNECT");
	Close();
}

defaultproperties {
	RemoteRole=ROLE_None
}

