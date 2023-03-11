class VS_DataLink extends TcpLink
	transient;

var string Buffer;
var MutVoteSys VoteSys;

var string SendBuffer;
var VS_Preset TempPreset;
var VS_Map TempMap;

event PostBeginPlay() {
	LinkMode = MODE_Text;
	ReceiveMode = RMODE_Event;

	foreach AllActors(class'MutVoteSys', VoteSys)
		break;
}

event Closed() {
	Destroy();
}

function bool SendLine(string Line) {
	// Len+2 to account for cr-lf at the end
	return SendText(Line$Chr(13)$Chr(10)) == Len(Line) + 2;
}

// This functions needs to survive unknown commands without errors
function ParseLine(string Line) {
	if (Len(Line) <= 0)
		return;

	if (Line == "/PING") {
		SendLine("/PONG");
	}
}

// no difference to ReceiveText
event ReceivedLine(string Text) {
	local int Pos;

	Text = Buffer$Text;

	for(Pos = InStr(Text, "\r\n"); Pos > -1; Pos = InStr(Text, "\r\n")) {
		ParseLine(Left(Text, Pos));

		Text = Mid(Text, Pos+2);
	}

	Buffer = Text;
}

event Accepted() {
	Log("VS_DataLink Accepted"@RemoteAddr.Addr@RemoteAddr.Port, 'VoteSys');
	GotoState('SendPresets');
}

function string EncodeString(string S) {
	local int i;
	local string Result;

	Result = "\"";
	i = InStr(S, "\"");
	while (i >= 0) {
		Result = Result$Left(S, i)$"\\\"";
		S = Mid(S, i+1);
		i = InStr(S, "\"");
	}

	return Result $ S $ "\"";
}

state SendPresets {
Begin:
	foreach AllActors(class'MutVoteSys', VoteSys)
		break;
	while(VoteSys.HistoryProcessor != none)
		Sleep(0);

	Log("VS_DataLink SendPresets", 'VoteSys');

	for (TempPreset = VoteSys.PresetList; TempPreset != none; TempPreset = TempPreset.Next) {
		if (TempPreset.bDisabled)
			continue;

		SendBuffer = "/PRESET/"$EncodeString(TempPreset.PresetName)$"/"$EncodeString(TempPreset.Abbreviation)$"/"$EncodeString(TempPreset.Category)$"/"$TempPreset.MinimumMapRepeatDistance$Chr(13)$Chr(10);
		while (true) {
			SendBuffer = Mid(SendBuffer, SendText(SendBuffer));
			if (Len(SendBuffer) <= 0)
				break;
			Sleep(0);
		}
		for (TempMap = TempPreset.MapList; TempMap != none; TempMap = TempMap.Next) {
			SendBuffer = "/MAP/"$EncodeString(TempMap.MapName)$"/"$TempMap.Sequence$Chr(13)$Chr(10);
			while (true) {
				SendBuffer = Mid(SendBuffer, SendText(SendBuffer));
				if (Len(SendBuffer) <= 0)
					break;
				Sleep(0);
			}
		}
	}

	SendBuffer = "/END/"$EncodeString(VoteSys.CurrentPreset)$Chr(13)$Chr(10);
	while (true) {
		SendBuffer = Mid(SendBuffer, SendText(SendBuffer));
		if (Len(SendBuffer) <= 0)
			break;
		Sleep(0);
	}
	Log("VS_DataLink SendPresets Done", 'VoteSys');
}

function HandleError() {
	SendLine("/RECONNECT");
	Close();
}

defaultproperties {
	RemoteRole=ROLE_None
}

