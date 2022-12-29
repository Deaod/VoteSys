class VS_UI_ClientWindow extends UWindowDialogClientWindow;

var VS_PlayerChannel Channel;

var VS_UI_CategoryTabItem ActiveCategory;
var VS_Preset ActivePreset;

var VS_UI_CategoryTabControl CategoryTabs;
var VS_UI_PresetComboBox Presets;
var VS_UI_MapListBox MapListBox;

var UWindowSmallButton VoteButton;
var localized string VoteButtonText;

var VS_UI_CandidateListBox VoteListBox;
var VS_UI_PlayerListBox PlayerListBox;

var VS_UI_ChatArea ChatArea;
var UWindowEditControl ChatEdit;
var UWindowSmallButton ChatSay;
var localized string ChatSayText;
var localized string ChatTeamSayText;

function Created() {
	local float TabsHeight;

	super.Created();

	TabsHeight = LookAndFeel.Size_TabAreaHeight + LookAndFeel.Size_TabAreaOverhangHeight;
	CategoryTabs = VS_UI_CategoryTabControl(CreateControl(class'VS_UI_CategoryTabControl', 0, 0, WinWidth, TabsHeight));

	Presets = VS_UI_PresetComboBox(CreateControl(class'VS_UI_PresetComboBox', 10, TabsHeight + 10, 150, 0));
	Presets.bCanEdit = false;
	Presets.EditBoxWidth = 150;

	MapListBox = VS_UI_MapListBox(CreateControl(class'VS_UI_MapListBox', 10, TabsHeight + 30, 150, 304));
	VoteButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, TabsHeight + 338, 150, 12));
	VoteButton.SetText(VoteButtonText);

	VoteListBox = VS_UI_CandidateListBox(CreateControl(class'VS_UI_CandidateListBox', 170, TabsHeight + 10, 400, 100));
	PlayerListBox = VS_UI_PlayerListBox(CreateControl(class'VS_UI_PlayerListBox', 450, TabsHeight + 120, 120, 214));

	ChatArea = VS_UI_ChatArea(CreateControl(class'VS_UI_ChatArea', 170, TabsHeight + 120, 270, 214));
	ChatEdit = UWindowEditControl(CreateControl(class'UWindowEditControl', 170, TabsHeight + 338, 220, 12));
	ChatEdit.EditBoxWidth = ChatEdit.WinWidth;
	ChatEdit.SetHistory(true);
	ChatSay = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 395, TabsHeight + 338, 45, 12));
	ChatSay.SetText(ChatSayText);
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local VS_Info Info;

	super.BeforePaint(C, MouseX, MouseY);

	Info = Channel.VoteInfo();

	UpdateActiveCategory();
	UpdateActivePreset(Info);

	UpdateCandidateList(Info);
	UpdatePlayerList(Info);

	CategoryTabs.WinWidth = WinWidth;

	if (ChatEdit.EditBox.bControlDown)
		ChatSay.SetText(ChatTeamSayText);
	else
		ChatSay.SetText(ChatSayText);
}

function UpdateActiveCategory() {
	local VS_UI_CategoryPresetWrapper P;
	
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
}

function UpdateActivePreset(VS_Info Info) {
	local VS_Map M;

	if (Presets.SelectedPreset != ActivePreset) {
		ActivePreset = Presets.SelectedPreset;
		MapListBox.Items.Clear();
		if (ActivePreset != none) {
			for (M = ActivePreset.MapList; M != none; M = M.Next)
				MapListBox.AppendMap(M, (M.Sequence == 0) || (Channel.MaxMapSequenceNumber - M.Sequence >= Info.MinimumMapRepeatDistance));
			MapListBox.Sort();
		}
	}
}

function UpdateCandidateList(VS_Info Info) {
	local int i;
	local VS_UI_CandidateListItem VLI;

	while(Info.NumCandidates > VoteListBox.Items.Count())
		VoteListBox.Items.Append(class'VS_UI_CandidateListItem');

	while(Info.NumCandidates < VoteListBox.Items.Count())
		VoteListBox.Items.Last.Remove();

	i = 0;
	for (VLI = VS_UI_CandidateListItem(VoteListBox.Items.Next); VLI != none; VLI = VS_UI_CandidateListItem(VLI.Next)) {
		VLI.Preset = Info.GetCandidatePreset(i);
		VLI.MapName = Info.GetCandidateMapName(i);
		VLI.Votes = Info.GetCandidateVotes(i);
		i++;
	}
}

function UpdatePlayerList(VS_Info Info) {
	local int i;
	local VS_UI_PlayerListItem PLI, TempPLI;
	local PlayerReplicationInfo PRI;

	i = 0;

	// update existing items
	PLI = VS_UI_PlayerListItem(PlayerListBox.Items.Next);
	PRI = Info.GetPlayerInfoPRI(i);
	while(PRI != none && PLI != none) {
		PLI.PRI = PRI;
		PLI.bHasVoted = Info.GetPlayerInfoHasVoted(i);

		i++;
		PLI = VS_UI_PlayerListItem(PLI.Next);
		PRI = Info.GetPlayerInfoPRI(i);
	}

	// add new items for new players
	while(PRI != none) {
		PLI = VS_UI_PlayerListItem(PlayerListBox.Items.Append(class'VS_UI_PlayerListItem'));
		PLI.PRI = PRI;
		PLI.bHasVoted = Info.GetPlayerInfoHasVoted(i);

		i++;
		PLI = VS_UI_PlayerListItem(PLI.Next);
		PRI = Info.GetPlayerInfoPRI(i);
	}

	// remove superfluous items
	while(PLI != none) {
		TempPLI = VS_UI_PlayerListItem(PLI.Next);
		PLI.Remove();
		PLI = TempPLI;
	}
}

function Notify(UWindowDialogControl C, byte E) {
	local VS_UI_CandidateListItem VLI;

	if ((C == VoteButton && E == DE_Click && MapListBox.SelectedItem != none) ||
		(C == MapListBox && E == DE_DoubleClick)
	) {
		if (ActivePreset != none)
			Channel.Vote(ActivePreset, VS_UI_MapListItem(MapListBox.SelectedItem).MapRef);
	} else if ((C == VoteButton && E == DE_Click && VoteListBox.SelectedItem != none) ||
		(C == VoteListBox && E == DE_DoubleClick)
	) {
		VLI = VS_UI_CandidateListItem(VoteListBox.SelectedItem);
		if (VLI != none)
			Channel.VoteExisting(VLI.Preset, VLI.MapName);
	} else if (C == VoteListBox && E == DE_Click) {
		MapListBox.ClearSelection();
	} else if (C == MapListBox && E == DE_Click) {
		VoteListBox.ClearSelection();
	} else if (C == ChatSay && E == DE_Click) {
		// instead of invoking SendChat immediately, divert through
		// ChatEdit.EditBox to make its history actually useful
		ChatEdit.EditBox.KeyDown(GetPlayerOwner().EInputKey.IK_Enter, 0, 0);
		ChatEdit.EditBox.KeyUp(GetPlayerOwner().EInputKey.IK_Enter, 0, 0);
	} else if (C == ChatEdit && E == DE_EnterPressed) {
		SendChat();
	}
}

function SendChat() {
	local string Msg;

	Msg = ChatEdit.GetValue();
	if (Msg == "")
		return;

	if (ChatEdit.EditBox.bControlDown)
		GetPlayerOwner().TeamSay(Msg);
	else
		GetPlayerOwner().Say(Msg);

	ChatEdit.Clear();
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
	ChatSayText="Say"
	ChatTeamSayText="TeamSay"
}
