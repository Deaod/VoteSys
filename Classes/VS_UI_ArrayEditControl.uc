class VS_UI_ArrayEditControl extends UWindowDialogControl;

var	float               EditBoxWidth;
var float               EditAreaDrawX, EditAreaDrawY;

var VS_UI_ThemeBase     Theme;
var UWindowEditBox      EditBox;
var VS_UI_ArrayEditButton Button;
var VS_UI_ArrayEditW    EditWindow;

var array<string>       Entries;

var bool                bCanEdit;
var bool                bEnabled;
var bool                bSavedCanEdit;
var bool                bSavedEditBoxCanEdit;

function Created() {
	Super.Created();
	
	EditBox = UWindowEditBox(CreateWindow(class'UWindowEditBox', 0, 0, WinWidth-12, WinHeight)); 
	EditBox.NotifyOwner = Self;
	EditBoxWidth = WinWidth / 2;
	EditBox.bTransient = True;

	Button = VS_UI_ArrayEditButton(CreateWindow(class'VS_UI_ArrayEditButton', WinWidth-12, 0, 12, 10));
	Button.Owner = Self;

	EditWindow = VS_UI_ArrayEditW(Root.CreateWindow(class'VS_UI_ArrayEditW', 0, 0, 320, 200, self));
	EditWindow.SetOwner(self);
	EditWindow.HideWindow();

	SetEditTextColor(LookAndFeel.EditBoxTextColor);
}

function LaunchEditWindow() {
	local int i;
	EditWindow.WindowTitle = Text;
	EditWindow.SetTheme(Theme);

	VS_UI_ArrayEditCW(EditWindow.ClientArea).Lst_Elements.Items.Clear();
	VS_UI_ArrayEditCW(EditWindow.ClientArea).Lst_Elements.ClearSelection();

	SetPropertyText("Entries", EditBox.GetValue());
	for (i = 0; i < Entries.Length; i++)
		EditWindow.AddElement(Entries[i]);

	GetParent(class'UWindowFramedWindow').ShowModal(EditWindow);
}

function EditWindowClosed(VS_UI_ArrayEditW Wnd) {
	local int i, Count;
	local VS_UI_ArrayEditLI It;

	Count = VS_UI_ArrayEditCW(EditWindow.ClientArea).Lst_Elements.Items.Count();
	Entries.Remove(0, Entries.Length);
	Entries.Insert(0, Count);

	It = VS_UI_ArrayEditLI(VS_UI_ArrayEditCW(EditWindow.ClientArea).Lst_Elements.Items.Next);
	for (i = 0; It != none; It = VS_UI_ArrayEditLI(It.Next))
		Entries[i++] = It.Text;

	EditBox.SetValue(GetPropertyText("Entries"));
}

function Notify(byte E) {
	Super.Notify(E);
}

function Close(optional bool bByParent) {
	// close EditWindow

	Super.Close(bByParent);
}

function SetTheme(VS_UI_ThemeBase T) {
	Theme = T;
}

function SetFont(int NewFont) {
	Super.SetFont(NewFont);
	EditBox.SetFont(NewFont);
}

function SetEditTextColor(Color NewColor) {
	EditBox.SetTextColor(NewColor);
}

function SetEditable(bool bNewCanEdit) {
	bCanEdit = bNewCanEdit;
	EditBox.SetEditable(bCanEdit);
}

function string GetValue() {
	return EditBox.GetValue();
}

function string GetValue2() {
	return EditBox.GetValue2();
}

function SetValue(string NewValue, optional string NewValue2) {
	EditBox.SetValue(NewValue, NewValue2);
}

function SetMaxLength(int MaxLength) {
	EditBox.MaxLength = MaxLength;
}

function Paint(Canvas C, float MouseX, float MouseY) {
	Theme.DrawBox(C, self, EditAreaDrawX, 0, EditBoxWidth, WinHeight);

	if (Text != "") {
		C.DrawColor = TextColor;
		ClipText(C, TextX, TextY, Text);
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
	}
	
	Button.TextY = -3;

	super.Paint(C, MouseX, MouseY);
}

function BeforePaint(Canvas C, float X, float Y) {
	local float TW, TH;

	Super.BeforePaint(C, X, Y);

	// BEGIN COPY UMenuGoldLookAndFeel.Combo_SetupSizes
	C.Font = Root.Fonts[Font];
	TextSize(C, Text, TW, TH);
	
	WinHeight = 12 + LookAndFeel.MiscBevelT[2].H + LookAndFeel.MiscBevelB[2].H;
	
	switch(Align) {
	case TA_Left:
		EditAreaDrawX = WinWidth - EditBoxWidth;
		TextX = 0;
		break;
	case TA_Right:
		EditAreaDrawX = 0;	
		TextX = WinWidth - TW;
		break;
	case TA_Center:
		EditAreaDrawX = (WinWidth - EditBoxWidth) / 2;
		TextX = (WinWidth - TW) / 2;
		break;
	}

	EditAreaDrawY = (WinHeight - 2) / 2;
	TextY = (WinHeight - TH) / 2;

	EditBox.WinLeft = EditAreaDrawX + LookAndFeel.MiscBevelL[2].W;
	EditBox.WinTop = LookAndFeel.MiscBevelT[2].H;
	Button.WinWidth = LookAndFeel.ComboBtnUp.W;

	EditBox.WinWidth = EditBoxWidth - LookAndFeel.MiscBevelL[2].W - LookAndFeel.MiscBevelR[2].W - LookAndFeel.ComboBtnUp.W;
	EditBox.WinHeight = WinHeight - LookAndFeel.MiscBevelT[2].H - LookAndFeel.MiscBevelB[2].H;
	Button.WinLeft = WinWidth - LookAndFeel.ComboBtnUp.W - LookAndFeel.MiscBevelR[2].W;
	Button.WinTop = EditBox.WinTop;
	Button.WinHeight = EditBox.WinHeight;
	// END COPY

	EditBox.TextColor = Theme.Foreground;
}


function ClearValue() {
	EditBox.Clear();
}

function Clear() {
	Entries.Remove(0, Entries.Length);
	EditBox.Clear();
}

function FocusOtherWindow(UWindowWindow W) {
	Super.FocusOtherWindow(W);
}

defaultproperties {
	bNoKeyboard=True
}
