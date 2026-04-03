class VS_UIS_Page extends UWindowPageWindow;

var VS_PlayerChannel Channel;

var int ActiveTheme;
var VS_UI_ThemeBase Theme;

var UWindowSmallButton Btn_Save;
var localized string SaveText;

var UWindowSmallCloseButton Btn_Close;

var string ToolTipText;
var VS_UI_ToolTipWindow ToolTipWindow;

function Created() {
	Btn_Save = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 298, 334, 40, 16));
	Btn_Save.SetText(SaveText);

	Btn_Close = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 342, 334, 40, 16));

	ToolTipWindow = VS_UI_ToolTipWindow(Root.CreateWindow(class'VS_UI_ToolTipWindow', 0, 0, 120, 22, self));
	ToolTipWindow.HideWindow();

	super.Created();
}

function LoadSettings(VS_PlayerChannel C) {
	Channel = C;
}

function SaveSettings() {}

function bool CanSaveSettings() { return true; }

function ApplyTheme() {}

function Notify(UWindowDialogControl C, byte E) {
	super.Notify(C, E);
	
	if (C == Btn_Save && E == DE_Click) {
		if (CanSaveSettings())
			SaveSettings();
	}
}

function ToolTip(string Tip) {
	if (ToolTipText != "")
		ToolTipWindow.HideWindow();
	ToolTipText = Tip;
	if (Tip != "")
		ToolTipWindow.ShowWindow();
	ToolTipWindow.SetText(ToolTipText);
}

function BeforePaint(Canvas C, float X, float Y) {
	super.BeforePaint(C, X, Y);

	if (ActiveTheme != int(Channel.Settings.Theme)) {
		ActiveTheme = int(Channel.Settings.Theme);

		switch(Channel.Settings.Theme) {
			case TH_Bright:
				Theme = new class'VS_UI_ThemeBright';
				break;
			case TH_Dark:
				Theme = new class'VS_UI_ThemeDark';
				break;
			case TH_Black:
				Theme = new class'VS_UI_ThemeBlack';
				break;
		}

		if (Theme != none)
			ApplyTheme();
	}
}

defaultproperties {
	ActiveTheme=-1
	SaveText="Save"
}
