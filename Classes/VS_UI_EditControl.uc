class VS_UI_EditControl extends UWindowEditControl;

var VS_UI_ThemeBase Theme;

function Created()
{
	local VS_UI_EditBox EB;

	Super(UWindowDialogControl).Created();
	
	EB = VS_UI_EditBox(CreateWindow(class'VS_UI_EditBox', 0, 0, WinWidth, WinHeight)); 
	EB.NotifyOwner = Self;
	EB.bSelectOnFocus = True;
	EB.EmptyText = Text;
	EditBox = EB;

	EditBoxWidth = WinWidth;

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
}

function SetText(string NewText)
{
	Text = NewText;
	VS_UI_EditBox(EditBox).EmptyText = NewText;
}

function Paint(Canvas C, float MouseX, float MouseY) {
	local string Text2;

	Text2 = Text;
	Text = "";
	Theme.DrawBox(C, self, EditAreaDrawX, 0, EditBoxWidth, WinHeight);
	super(UWindowDialogControl).Paint(C, MouseX, MouseY);
	Text = Text2;
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);
	EditBox.TextColor = Theme.Foreground;
	VS_UI_EditBox(EditBox).EmptyTextColor = Theme.InactiveFG;
}
