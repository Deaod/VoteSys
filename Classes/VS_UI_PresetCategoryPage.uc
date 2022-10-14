class VS_UI_PresetCategoryPage extends UWindowPageWindow;

var VS_PlayerChannel Channel;
var VS_UI_PresetComboBox Presets;
var VS_Preset ActivePreset;
var VS_UI_MapListBox MapListBox;

var UWindowSmallButton VoteButton;
var localized string VoteButtonText;

var VS_UI_VoteListBox VoteListBox;

function Created() {
	Presets = VS_UI_PresetComboBox(CreateControl(class'VS_UI_PresetComboBox', 10, 10, 150, 0));
	Presets.bCanEdit = false;
	Presets.EditBoxWidth = 150;

	MapListBox = VS_UI_MapListBox(CreateControl(class'VS_UI_MapListBox', 10, 30, 150, 300));
	VoteButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, 338, 150, 12));
	VoteButton.SetText(VoteButtonText);

	VoteListBox = VS_UI_VoteListBox(CreateControl(class'VS_UI_VoteListBox', 170, 10, 400, 150));
}

function AddPreset(VS_Preset P) {
	Presets.AddPreset(P);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local VS_Map M;
	local VS_UI_VoteListItem VLI;
	local VS_Info Info;
	local int i;

	if (Presets.SelectedPreset != ActivePreset) {
		ActivePreset = Presets.SelectedPreset;
		MapListBox.Items.Clear();
		for (M = ActivePreset.MapList; M != none; M = M.Next)
			MapListBox.AppendMap(M);
		MapListBox.Sort();
	}

	Info = Channel.VoteInfo(); 
	while(Info.NumCandidates > VoteListBox.Items.Count())
		VoteListBox.Items.Append(class'VS_UI_VoteListItem');

	while(Info.NumCandidates < VoteListBox.Items.Count())
		VoteListBox.Items.Last.Remove();

	for (VLI = VS_UI_VoteListItem(VoteListBox.Items.Next); VLI != none; VLI = VS_UI_VoteListItem(VLI.Next)) {
		VLI.Preset = Info.GetCandidatePreset(i);
		VLI.MapName = Info.GetCandidateMapName(i);
		VLI.Votes = Info.GetCandidateVotes(i);
		i++;
	}

	VoteListBox.Items.Sort();
}

function Notify(UWindowDialogControl C, byte E) {
	local VS_UI_VoteListItem VLI;

	if ((C == VoteButton && E == DE_Click && MapListBox.SelectedItem != none) ||
		(C == MapListBox && E == DE_DoubleClick)
	) {
		if (ActivePreset != none)
			Channel.Vote(ActivePreset, VS_UI_MapListItem(MapListBox.SelectedItem).MapRef);
	} else if ((C == VoteButton && E == DE_Click && VoteListBox.SelectedItem != none) ||
		(C == VoteListBox && E == DE_DoubleClick)
	) {
		VLI = VS_UI_VoteListItem(VoteListBox.SelectedItem);
		if (VLI != none)
			Channel.VoteExisting(VLI.Preset, VLI.MapName);
	} else if (C == VoteListBox && E == DE_Click) {
		MapListBox.ClearSelection();
	} else if (C == MapListBox && E == DE_Click) {
		VoteListBox.ClearSelection();
	}
}

defaultproperties {
	VoteButtonText="Vote"
}
