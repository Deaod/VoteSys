class VS_UIA_ClientWindow extends UWindowDialogClientWindow;

#exec OBJ IMPORT Type=TextBuffer FILE="LICENSE" Name=VoteSys_LicenseText
#exec OBJ IMPORT Type=TextBuffer FILE="LICENSE_SHORT" Name=VoteSys_LicenseShortText

var UWindowMessageBoxArea Lbl_Copyright;
var UWindowSmallOKButton Btn_Okay;
var UWindowSmallButton Btn_Github;

var VS_Util_TextBufferOverlay DummyTextBuffer;

function string ReplaceAll(coerce string Haystack, coerce string Needle, coerce string Replacement) {
	local string Result;
	local int Pos;

	Pos = InStr(Haystack, Needle);
	while (Pos != -1) {
		Result = Result $ Left(Haystack, Pos) $ Replacement;
		Haystack = Mid(Haystack, Pos+Len(Needle), Len(Haystack));
		Pos = InStr(Haystack, Needle);
	}

	return Result $ Haystack;
}

function string PrepareLicenseMessage(string S) {
	local string Result;

	Result = ReplaceAll(S, Chr(13)$Chr(10), Chr(13)); // \r\n -> \r
	Result = ReplaceAll(Result, Chr(10), Chr(13)); // \n -> \r

	return Result;
}

function Created() {
	local VS_Util_TextBufferOverlay TB;

	super.Created();

	TB = TextBufferOverlay(TextBuffer'VoteSys_LicenseShortText');

	Lbl_Copyright = UWindowMessageBoxArea(CreateWindow(class'UWindowMessageBoxArea', 5, 5, 100, 100));
	Lbl_Copyright.Message = PrepareLicenseMessage(TB.Text);
	Btn_Okay = UWindowSmallOKButton(CreateControl(class'UWindowSmallOKButton', 5, 5, 48, 16));
	Btn_Github = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 5, 5, 60, 16));
	Btn_Github.SetText("GitHub");
}

function VS_Util_TextBufferOverlay TextBufferOverlay(TextBuffer B) {
	SetPropertyText("DummyTextBuffer", string(B.Class.Name)$"'"$string(B.Outer.Name)$"."$B.Name$"'");
	return DummyTextBuffer;
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	Lbl_Copyright.SetSize(WinWidth - 10, WinHeight - 26);

	Btn_Okay.WinLeft = WinWidth - 5 - Btn_Okay.WinWidth;
	Btn_Okay.WinTop = WinHeight - 5 - Btn_Okay.WinHeight;

	Btn_Github.WinLeft = WinWidth - 10 - Btn_Okay.WinWidth - Btn_Github.WinWidth;
	Btn_Github.WinTop = WinHeight - 5 - Btn_Github.WinHeight;

	super.BeforePaint(C, MouseX, MouseY);
}

function Notify(UWindowDialogControl C, byte E) {
	if (C == Btn_Okay && E == DE_Click) {
		UWindowFramedWindow(GetParent(class'UWindowFramedWindow')).Close();
	} else if (C == Btn_Github && E == DE_Click) {
		GetPlayerOwner().ConsoleCommand("start https://github.com/Deaod/VoteSys");
	}
}

defaultproperties {
}
