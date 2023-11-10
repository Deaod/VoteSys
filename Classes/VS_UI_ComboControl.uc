class VS_UI_ComboControl extends UWindowComboControl;

var VS_UI_ThemeBase Theme;

var bool bEnabled;
var bool bSavedCanEdit;
var bool bSavedEditBoxCanEdit;

function Paint(Canvas C, float MouseX, float MouseY) {
	Theme.DrawBox(C, self, EditAreaDrawX, 0, EditBoxWidth, WinHeight);

	if (Text != "") {
		C.DrawColor = TextColor;
		ClipText(C, TextX, TextY, Text);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
	
	super(UWindowDialogControl).Paint(C, MouseX, MouseY);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);
	EditBox.TextColor = Theme.Foreground;
}

function SetEnabled(bool bEnable) {
	if (bEnabled == bEnable)
		return;

	if (bEnable) {
		Button.bDisabled = false;
		bCanEdit = bSavedCanEdit;
		EditBox.SetEditable(bSavedEditBoxCanEdit);
	} else {
		bSavedCanEdit = bCanEdit;
		bSavedEditBoxCanEdit = EditBox.bCanEdit;

		Button.bDisabled = true;
		bCanEdit = true;
		EditBox.SetEditable(false);
	}
	bEnabled = bEnable;
}

defaultproperties {
	bEnabled=True
}
