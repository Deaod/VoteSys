class VS_UI_PresetComboBox extends VS_UI_ComboControl;

var VS_Preset SelectedPreset;

function AddPreset(VS_Preset P, bool bEnable) {
	VS_UI_PresetComboList(List).AddPreset(P, bEnable);
	if (List.Selected == none) {
		List.Selected = UWindowComboListItem(List.Items.Next);
		List.ExecuteItem(List.Selected);
	}
}

function FocusPreset(string PresetName) {
	local VS_UI_PresetComboListItem I;

	for (I = VS_UI_PresetComboListItem(List.Items.Next); I != none; I = VS_UI_PresetComboListItem(I.Next)) {
		if (I.bEnabled && I.Preset.PresetName == PresetName && List.Selected != I) {
			List.Selected = I;
			List.ExecuteItem(List.Selected);
		}
	}
}

defaultproperties {
	ListClass=class'VS_UI_PresetComboList'
}
