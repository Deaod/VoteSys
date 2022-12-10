class VS_UI_CategoryTabItem extends UWindowTabControlItem;

var VS_Preset SelectedPreset;
var VS_UI_CategoryPresetWrapper PresetList;
var VS_UI_CategoryPresetWrapper PresetListLast;

function AddPreset(VS_Preset P){
	if (PresetList == none) {
		PresetList = new(none) class'VS_UI_CategoryPresetWrapper';
		PresetListLast = PresetList;
		PresetList.Preset = P;
		return;
	}

	PresetListLast.Next = new(none) class'VS_UI_CategoryPresetWrapper';
	PresetListLast.Next.Preset = P;
	PresetListLast = PresetListLast.Next;
}

