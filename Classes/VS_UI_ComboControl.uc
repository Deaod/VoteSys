class VS_UI_ComboControl extends UWindowComboControl;

var VS_UI_ThemeBase Theme;

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
