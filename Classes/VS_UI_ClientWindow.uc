class VS_UI_ClientWindow extends UWindowDialogClientWindow;

var VS_PlayerChannel Channel;

var VS_UI_CategoryTabItem ActiveCategory;
var VS_Preset ActivePreset;

var VS_UI_CategoryTabControl CategoryTabs;
var VS_UI_PresetComboBox Presets;
var VS_UI_MapListBox MapListBox;

var UWindowSmallButton VoteButton;
var localized string VoteButtonText;

var VS_UI_VoteListBox VoteListBox;

function Created() {
	local float TabsHeight;

	super.Created();

	TabsHeight = LookAndFeel.Size_TabAreaHeight + LookAndFeel.Size_TabAreaOverhangHeight;
	CategoryTabs = VS_UI_CategoryTabControl(CreateControl(class'VS_UI_CategoryTabControl', 0, 0, WinWidth, TabsHeight));

	Presets = VS_UI_PresetComboBox(CreateControl(class'VS_UI_PresetComboBox', 10, TabsHeight + 10, 150, 0));
	Presets.bCanEdit = false;
	Presets.EditBoxWidth = 150;

	MapListBox = VS_UI_MapListBox(CreateControl(class'VS_UI_MapListBox', 10, TabsHeight + 30, 150, 300));
	VoteButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, TabsHeight + 338, 150, 12));
	VoteButton.SetText(VoteButtonText);

	VoteListBox = VS_UI_VoteListBox(CreateControl(class'VS_UI_VoteListBox', 170, TabsHeight + 10, 400, 150));
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local VS_UI_CategoryPresetWrapper P;
	local VS_Map M;
	local VS_UI_VoteListItem VLI;
	local VS_Info Info;
	local int i;

	super.BeforePaint(C, MouseX, MouseY);

	Info = Channel.VoteInfo();

	if (CategoryTabs.SelectedTab != ActiveCategory) {
		if (ActiveCategory != none)
			ActiveCategory.SelectedPreset = Presets.SelectedPreset;
		ActiveCategory = VS_UI_CategoryTabItem(CategoryTabs.SelectedTab);
		Presets.List.Clear();
		Presets.List.Selected = none;
		Presets.SelectedPreset = none;

		if (ActiveCategory != none) {
			for (P = ActiveCategory.PresetList; P != none; P = P.Next)
				Presets.AddPreset(P.Preset);
			if (ActiveCategory.SelectedPreset != none)
				Presets.FocusPreset(ActiveCategory.SelectedPreset.PresetName);
		}
	}

	if (Presets.SelectedPreset != ActivePreset) {
		ActivePreset = Presets.SelectedPreset;
		MapListBox.Items.Clear();
		if (ActivePreset != none) {
			for (M = ActivePreset.MapList; M != none; M = M.Next)
				MapListBox.AppendMap(M, (M.Sequence == 0) || (Channel.MaxMapSequenceNumber - M.Sequence >= Info.MinimumMapRepeatDistance));
			MapListBox.Sort();
		}
	}

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

	CategoryTabs.WinWidth = WinWidth;
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

function AddPreset(VS_Preset P) {
	local string Cat;
	local VS_UI_CategoryTabItem CTI;

	Cat = P.GetDisplayCategory();

	CTI = VS_UI_CategoryTabItem(CategoryTabs.GetTab(Cat));
	if (CTI == none)
		CTI = VS_UI_CategoryTabItem(CategoryTabs.AddTab(Cat));

	CTI.AddPreset(P);
}

function FocusPreset(VS_Preset P) {
	local VS_UI_CategoryTabItem CTI;

	CTI = VS_UI_CategoryTabItem(CategoryTabs.GetTab(P.GetDisplayCategory()));
	if (CTI == none)
		return;

	if (CTI != ActiveCategory) {
		CTI.SelectedPreset = P;
		CategoryTabs.GotoTab(CTI);
	} else {
		Presets.FocusPreset(P.PresetName);
	}
}

defaultproperties {
	VoteButtonText="Vote"
}
