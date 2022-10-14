class VS_UI_PresetComboBox extends UWindowComboControl;

var VS_Preset SelectedPreset;

function AddPreset(VS_Preset P) {
	VS_UI_PresetComboList(List).AddPreset(P);
	if (List.Selected == none) {
		List.Selected = UWindowComboListItem(List.Items.Next);
		List.ExecuteItem(List.Selected);
	}
}

defaultproperties {
	ListClass=class'VS_UI_PresetComboList'
}
