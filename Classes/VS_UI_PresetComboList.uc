class VS_UI_PresetComboList extends UWindowComboList;

// dont work
function AddItem(string Value, optional string Value2, optional int SortWeight);
function InsertItem(string Value, optional string Value2, optional int SortWeight);

function AddPreset(VS_Preset P, bool bEnable) {
	local VS_UI_PresetComboListItem I;

	I = VS_UI_PresetComboListItem(Items.Append(class'VS_UI_PresetComboListItem'));
	I.Preset = P;
	I.Value = P.PresetName;
	I.Value2 = P.Abbreviation;
	I.SortWeight = P.SortPriority;
	I.bEnabled = bEnable;
}

function Created() {
	ListClass = class'VS_UI_PresetComboListItem';
	bAlwaysOnTop = True;
	bTransient = True;
	ItemHeight = 15;
	VBorder = 3;
	HBorder = 3;
	TextBorder = 9;
	super(UWindowListControl).Created();
}

function ExecuteItem(UWindowComboListItem I) {
	VS_UI_PresetComboBox(Owner).SelectedPreset = VS_UI_PresetComboListItem(I).Preset;
	super.ExecuteItem(I);
}

function SetSelected(float X, float Y) {
	local VS_UI_PresetComboListItem NewSelected, Item;
	local int i, Count;

	Count = Items.Count();

	i = (Y - VBorder) / ItemHeight + VertSB.Pos;

	if (i < 0)
		i = 0;

	if (i >= VertSB.Pos + Min(Count, MaxVisible))
		i = VertSB.Pos + Min(Count, MaxVisible) - 1;

	NewSelected = VS_UI_PresetComboListItem(Items.FindEntry(i));

	if (NewSelected != none && NewSelected.bEnabled)
		Selected = NewSelected;
	else
		Selected = none;
}

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_PresetComboListItem I;

	LookAndFeel.ComboList_DrawItem(Self, C, X, Y, W, H, "", Selected == Item);

	I = VS_UI_PresetComboListItem(Item);
	if (I.bEnabled) {
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 0;
	} else {
		C.DrawColor.R = 96;
		C.DrawColor.G = 96;
		C.DrawColor.B = 96;
	}
	ClipText(C, X + TextBorder + 2, Y + 1.5, I.Value);
}
