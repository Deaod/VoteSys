class VS_UI_SettingsPage extends UWindowPageWindow;

var UWindowSmallButton Btn_Save;
var localized string SaveText;

var UWindowSmallCloseButton Btn_Close;

function Created() {
	super.Created();

	Btn_Save = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 298, 334, 40, 16));
	Btn_Save.SetText(SaveText);

	Btn_Close = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 342, 334, 40, 16));
}

function LoadSettings(VS_ClientSettings S) {}

function SaveSettings() {}

function Notify(UWindowDialogControl C, byte E) {
	if (C == Btn_Save && E == DE_Click) {
		SaveSettings();
	}
}

defaultproperties {
	SaveText="Save"
}
