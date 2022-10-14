class VS_UI_PresetComboList extends UWindowComboList;

// dont work
function AddItem(string Value, optional string Value2, optional int SortWeight);
function InsertItem(string Value, optional string Value2, optional int SortWeight);

function AddPreset(VS_Preset P) {
	local VS_UI_PresetComboListItem I;

	I = VS_UI_PresetComboListItem(Items.Append(class'VS_UI_PresetComboListItem'));
	I.Preset = P;
	I.Value = P.PresetName;
	I.Value2 = P.Abbreviation;
	I.SortWeight = 0;
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
