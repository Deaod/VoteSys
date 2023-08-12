class VS_DataLink extends TcpLink
	transient;

var string Buffer;
var MutVoteSys VoteSys;
var VS_ChannelContainer Channel;

var string SendBuffer;
var VS_Preset TempPreset;
var VS_Map TempMap;
var Serialization S11N;

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
	S11N = class'Serialization'.static.Instance();
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
	} else if (Left(Line, 8) == "/COOKIE/") {
		Channel = VoteSys.FindChannelForCookie(int(Mid(Line, 8)));
		Log("VS_DataLink Found Channel"@Channel, 'VoteSys');
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

function HandleError() {
	SendLine("/RECONNECT");
	Close();
}

defaultproperties {
	RemoteRole=ROLE_None
}

