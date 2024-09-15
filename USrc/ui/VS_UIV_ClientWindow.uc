class VS_UIV_ClientWindow extends UWindowDialogClientWindow;

#exec TEXTURE IMPORT Name="Gear" File="Textures/Gear.pcx" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT Name="StarEmpty" File="Textures/Star-Empty.pcx" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT Name="StarFilled" File="Textures/Star-Filled.pcx" MIPS=OFF FLAGS=2

var VS_PlayerChannel Channel;
var VS_ClientSettings Settings;
var int ActiveTheme;
var byte PreviousMapListSort;
var bool bPreviousFavoritesFirst;

var VS_UI_CategoryTabItem ActiveCategory;
var VS_Preset ActivePreset;
var bool bAdmin, bWasAdmin;
var int NumPlayers, PreviousNumPlayers;

var VS_UI_CategoryTabControl CategoryTabs;
var VS_UI_PresetComboBox Presets;
var VS_UI_EditControl MapFilter;
var localized string MapFilterText;
var float LastMapFilterEditTime;
var bool bMapFilterApplied;
var VS_UI_MapListBox MapListBox;

var UWindowSmallButton VoteButton;
var localized string VoteButtonText;
var UWindowSmallButton SuggestButton;
var localized string SuggestButtonText;
var UWindowSmallButton RandomButton;
var localized string RandomButtonText;

var int CandidateMark;
var VS_UI_CandidateListBox VoteListBox;
var VS_UI_PlayerListBox PlayerListBox;

var VS_UI_Logo Logo;
var VS_UI_LinkButton LogoButtons[3];

var VS_UI_ChatArea ChatArea;
var VS_UI_EditControl ChatEdit;
var UWindowSmallButton ChatSay;
var localized string ChatSayText;
var localized string ChatTeamSayText;

var UWindowSmallCloseButton CloseButton;
var VS_UI_IconButton SettingsButton;

var float PrevMouseX, PrevMouseY;
var float LastMouseMoveTime;
var VS_UI_ScreenshotWindow MapScreenshotWindow;

function Created() {
	local float TabsHeight;

	super.Created();

	TabsHeight = LookAndFeel.Size_TabAreaHeight + LookAndFeel.Size_TabAreaOverhangHeight;
	CategoryTabs = VS_UI_CategoryTabControl(CreateControl(class'VS_UI_CategoryTabControl', 0, 0, WinWidth, TabsHeight));

	Presets = VS_UI_PresetComboBox(CreateControl(class'VS_UI_PresetComboBox', 10, TabsHeight + 10, 180, 0));
	Presets.bCanEdit = false;
	Presets.EditBoxWidth = Presets.WinWidth;

	MapFilter = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 10, TabsHeight + 30, 180, 12));
	MapFilter.SetText("");
	MapFilter.SetEmptyText(MapFilterText);

	MapListBox = VS_UI_MapListBox(CreateControl(class'VS_UI_MapListBox', 10, TabsHeight + 50, 180, 284));
	VoteButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 10, TabsHeight + 338, 57, 12));
	VoteButton.SetText(VoteButtonText);
	SuggestButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 71, TabsHeight + 338, 58, 12));
	SuggestButton.SetText(SuggestButtonText);
	RandomButton = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 133, TabsHeight + 338, 57, 12));
	RandomButton.SetText(RandomButtonText);

	VoteListBox = VS_UI_CandidateListBox(CreateControl(class'VS_UI_CandidateListBox', 200, TabsHeight + 10, 400, 100));
	PlayerListBox = VS_UI_PlayerListBox(CreateControl(class'VS_UI_PlayerListBox', 480, TabsHeight + 120, 120, 214));

	Logo = VS_UI_Logo(CreateControl(class'VS_UI_Logo', 200, TabsHeight + 120, 270, 234));

	LogoButtons[0] = VS_UI_LinkButton(CreateControl(class'VS_UI_LinkButton', 200, TabsHeight + 338, 86, 16));
	LogoButtons[0].HideWindow();
	LogoButtons[1] = VS_UI_LinkButton(CreateControl(class'VS_UI_LinkButton', 292, TabsHeight + 338, 86, 16));
	LogoButtons[1].HideWindow();
	LogoButtons[2] = VS_UI_LinkButton(CreateControl(class'VS_UI_LinkButton', 384, TabsHeight + 338, 86, 16));
	LogoButtons[2].HideWindow();

	ChatArea = VS_UI_ChatArea(CreateControl(class'VS_UI_ChatArea', 200, TabsHeight + 120, 270, 214));
	ChatEdit = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, TabsHeight + 338, 220, 12));
	ChatEdit.EditBoxWidth = ChatEdit.WinWidth;
	ChatEdit.SetHistory(true);
	ChatSay = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 424, TabsHeight + 338, 46, 12));
	ChatSay.SetText(ChatSayText);

	CloseButton = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 480, TabsHeight + 338, 100, 12));
	SettingsButton = VS_UI_IconButton(CreateControl(class'VS_UI_IconButton', 584, TabsHeight+338, 16, 12));
	SettingsButton.Icon = texture'Gear';

	MapScreenshotWindow = VS_UI_ScreenshotWindow(Root.CreateWindow(class'VS_UI_ScreenshotWindow', 0,0,130,130, self));
	MapScreenshotWindow.HideWindow();

	Logo.SendToBack();
	Logo.HideWindow();
}

function LoadSettings(VS_ClientSettings CS) {
	Settings = CS;
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	local VS_Info Info;
	local LevelInfo L;
	local string Filter;
	local VS_UI_MapListItem M;

	super.BeforePaint(C, MouseX, MouseY);

	if (Settings.Theme != ActiveTheme) {
		ActiveTheme = Settings.Theme;
		ApplyTheme(ActiveTheme);
	}

	Info = Channel.VoteInfo();

	bWasAdmin = bAdmin;
	bAdmin = GetPlayerOwner().PlayerReplicationInfo.bAdmin;

	PreviousNumPlayers = NumPlayers;
	NumPlayers = GetPlayerOwner().GameReplicationInfo.NumPlayers;

	UpdateActiveCategory();
	UpdateActivePreset(Info);

	UpdateCandidateList(Info);
	UpdatePlayerList(Info);

	PreviousMapListSort = Settings.MapListSort;
	bPreviousFavoritesFirst = Settings.bFavoritesFirst;

	CategoryTabs.WinWidth = WinWidth;

	VoteButton.bDisabled = (ActivePreset == none);
	SuggestButton.bDisabled = (ActivePreset == none);
	RandomButton.bDisabled = (ActivePreset == none);

	if (ChatEdit.EditBox.bControlDown)
		ChatSay.SetText(ChatTeamSayText);
	else
		ChatSay.SetText(ChatSayText);

	if (Logo.bWindowVisible)
		Logo.SendToBack();

	L = GetLevel();
	if (MouseX != PrevMouseX || MouseY != PrevMouseY || MapListBox.HoverItem == none || IsActive() == false) {
		PrevMouseX = MouseX;
		PrevMouseY = MouseY;
		LastMouseMoveTime = L.TimeSeconds;
		if (MapScreenshotWindow.bWindowVisible)
			MapScreenshotWindow.HideWindow();
	}
	if (((L.TimeSeconds - LastMouseMoveTime) > (L.TimeDilation * 0.5)) &&
	    (MapListBox.HoverItem != none) &&
	    (Presets.bListVisible == false)
	) {
		if (MapScreenshotWindow.bWindowVisible == false) {
			MapScreenshotWindow.ShowWindow();
			MapScreenshotWindow.SetUpFor(VS_UI_MapListItem(MapListBox.HoverItem).MapRef);
		}
	}

	if (((L.TimeSeconds - LastMapFilterEditTime) > (L.TimeDilation * 0.25)) && (bMapFilterApplied == false)) {
		bMapFilterApplied = true;
		Filter = Caps(MapFilter.GetValue());
		if (Filter != "") {
			for (M = VS_UI_MapListItem(MapListBox.Items.Next); M != none; M = VS_UI_MapListItem(M.Next))
				M.bFilteredOut = InStr(Caps(M.MapRef.MapName), Filter) < 0;
		} else {
			for (M = VS_UI_MapListItem(MapListBox.Items.Next); M != none; M = VS_UI_MapListItem(M.Next))
				M.bFilteredOut = false;
		}
	}
}

function ApplyTheme(byte Theme) {
	local VS_UI_ThemeBase T;

	switch(Settings.IntToTheme(Theme)) {
		case TH_Bright:
			T = new class'VS_UI_ThemeBright';
			break;
		case TH_Dark:
			T = new class'VS_UI_ThemeDark';
			break;
		case TH_Black:
			T = new class'VS_UI_ThemeBlack';
			break;
	}

	if (T == none)
		T = new class'VS_UI_ThemeBright';

	Presets.Theme = T;
	MapFilter.Theme = T;
	MapListBox.Theme = T;
	VoteListBox.Theme = T;
	PlayerListBox.Theme = T;
	ChatArea.Theme = T;
	ChatEdit.Theme = T;
}

function Paint(Canvas C, float MouseX, float MouseY) {
	local float S;
	local Region TL, T, TR;
	local float X,Y,W;

	super.Paint(C, MouseX, MouseY);

	// adapted from UWindowWindow.DrawUpBevel
	// draws only the top bevel for a more pleasing separation between tabs and content

	X = 0;
	Y = LookAndFeel.Size_TabAreaHeight;
	W = WinWidth;

	if ( Root.GUIScale > 1 )
		S = float(int(Root.GUIScale)) / Root.GUIScale;
	else
		S = 1;

	TL = LookAndFeel.BevelUpTL;
	T = LookAndFeel.BevelUpT;
	TR = LookAndFeel.BevelUpTR;
	DrawStretchedTextureSegment(C, X             , Y,     (TL.W)*S     , (TL.H)*S, TL.X, TL.Y, TL.W, TL.H, GetLookAndFeelTexture());
	DrawStretchedTextureSegment(C, X   + (TL.W)*S, Y, W - (TL.W+TR.W)*S, (T.H)*S ,  T.X,  T.Y,  T.W,  T.H, GetLookAndFeelTexture());
	DrawStretchedTextureSegment(C, X+W - (TR.W)*S, Y,     (TR.W)*S     , (TR.H)*S, TR.X, TR.Y, TR.W, TR.H, GetLookAndFeelTexture());
}

function UpdateActiveCategory() {
	local VS_UI_CategoryPresetWrapper P;
	local bool bEnable;
	
	if (CategoryTabs.SelectedTab != ActiveCategory ||
		bWasAdmin != bAdmin || 
		PreviousNumPlayers != NumPlayers
	) {
		if (ActiveCategory != none)
			ActiveCategory.SelectedPreset = Presets.SelectedPreset;
		ActiveCategory = VS_UI_CategoryTabItem(CategoryTabs.SelectedTab);
		Presets.List.Clear();
		Presets.List.Selected = none;
		Presets.SelectedPreset = none;

		if (ActiveCategory == none)
			return;
			
		for (P = ActiveCategory.PresetList; P != none; P = P.Next) {
			bEnable = (NumPlayers >= P.Preset.MinPlayers) && (NumPlayers <= P.Preset.MaxPlayers || P.Preset.MaxPlayers <= 0);
			if (bAdmin)
				bEnable = true;
			Presets.AddPreset(P.Preset, bEnable);
		}
		Presets.List.Items.Sort();

		Presets.List.Selected = none;
		Presets.SelectedPreset = none;
		if (ActiveCategory.SelectedPreset != none)
			Presets.FocusPreset(ActiveCategory.SelectedPreset.PresetName);
	}
}

function UpdateActivePreset(VS_Info Info) {
	if (Presets.SelectedPreset != ActivePreset ||
		bWasAdmin != bAdmin ||
		PreviousNumPlayers != NumPlayers ||
		PreviousMapListSort != Settings.MapListSort ||
		bPreviousFavoritesFirst != Settings.bFavoritesFirst
	) {
		ActivePreset = Presets.SelectedPreset;

		FillMapListWithPreset(ActivePreset);

		VS_UI_MapListItem(MapListBox.Items).SortMode = Settings.MapListSort;
		VS_UI_MapListItem(MapListBox.Items).bFavoritesFirst = Settings.bFavoritesFirst;
		MapListBox.Items.Sort();
	}
}

function FillMapListWithPreset(VS_Preset P) {
	local VS_Map M;
	local bool bEnable;

	MapListBox.Items.Clear();

	if (P == none)
		return;

	for (M = P.MapList; M != none; M = M.Next) {
		bEnable = 
			(M.Sequence == 0 || P.MaxSequenceNumber - M.Sequence >= P.MinimumMapRepeatDistance) &&
			(NumPlayers >= M.MinPlayers && (NumPlayers <= M.MaxPlayers || M.MaxPlayers <= 0));
		if (bAdmin)
			bEnable = true;
		MapListBox.AppendMap(M, bEnable);
	}
}

function UpdateCandidateList(VS_Info Info) {
	local VS_UI_CandidateListItem VLI;
	local VS_Candidate C;
	local int NumCandidates;

	CandidateMark++;

	for (C = Info.FirstCandidate; C != none; C = C.Next) {
		if (C.Mark == CandidateMark) {
			// Theres a loop in the candidate list
			// Dont update candidate list this tick and hope replication catches up
			return;
		}
		C.Mark = CandidateMark;
		NumCandidates++;
	}

	while(NumCandidates > VoteListBox.Items.Count())
		VoteListBox.Items.Append(class'VS_UI_CandidateListItem');

	while(NumCandidates < VoteListBox.Items.Count())
		VoteListBox.Items.Last.Remove();

	C = Info.FirstCandidate;
	VLI = VS_UI_CandidateListItem(VoteListBox.Items.Next);
	while (VLI != none && C != none) {
		VLI.Candidate = C;

		C = C.Next;
		VLI = VS_UI_CandidateListItem(VLI.Next);
	}
}

function UpdatePlayerList(VS_Info Info) {
	local int i;
	local VS_UI_PlayerListItem PLI, TempPLI;
	local VS_PlayerInfo PlayerInfo;

	i = 0;

	// update existing items
	PLI = VS_UI_PlayerListItem(PlayerListBox.Items.Next);
	while(i < arraycount(Info.PlayerInfo) && PLI != none) {
		PlayerInfo = Info.PlayerInfo[i];
		if (PlayerInfo != none && PlayerInfo.PRI != none) {
			PLI.PlayerInfo = PlayerInfo;
			PLI = VS_UI_PlayerListItem(PLI.Next);
		}

		i++;
	}

	// add new items for new players
	while(i < arraycount(Info.PlayerInfo)) {
		PlayerInfo = Info.PlayerInfo[i];
		if (PlayerInfo != none && PlayerInfo.PRI != none) {
			PLI = VS_UI_PlayerListItem(PlayerListBox.Items.Append(class'VS_UI_PlayerListItem'));
			PLI.PlayerInfo = PlayerInfo;
			PLI = VS_UI_PlayerListItem(PLI.Next);
		}

		i++;
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
	} else if (
		(C == VoteButton  && E == DE_Click && VoteListBox.SelectedItem != none) ||
		(C == VoteListBox && E == DE_DoubleClick)
	) {
		VLI = VS_UI_CandidateListItem(VoteListBox.SelectedItem);
		if (VLI != none)
			Channel.VoteExisting(VLI.Candidate);
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
	} else if (C == MapFilter && E == DE_Change) {
		LastMapFilterEditTime = GetLevel().TimeSeconds;
		bMapFilterApplied = false;
	} else if (C == SuggestButton && E == DE_Click) {
		SuggestMap();
	} else if (C == RandomButton && E == DE_Click) {
		if (ActivePreset != none)
			Channel.VoteRandom(ActivePreset);
	} else if (C == SettingsButton && E == DE_Click) {
		Channel.ShowSettings();
	} else if (C == Logo && E == Logo.DE_VoteSys_LogoDismiss) {
		Logo.HideWindow();
		LogoButtons[0].HideWindow();
		LogoButtons[1].HideWindow();
		LogoButtons[2].HideWindow();

		ChatArea.ShowWindow();
		ChatEdit.ShowWindow();
		ChatSay.ShowWindow();
	}
}

// returns a value within [0..1)
// ~23 bits of randomness, probably sourced from two consecutive calls to C
// runtime's rand().
function float BetterFRand() {
	return class'IntConverter'.static.ToFloat(0x3f800000 | ((Rand(MaxInt) & 0x7FF) << 12) | (Rand(MaxInt) & 0xFFF)) - 1.0;
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

function SuggestMap() {
	local VS_UI_ListItem MapListItems;
	local int MapCount;

	if (ActivePreset == none)
		return;

	MapListItems = VS_UI_ListItem(MapListBox.Items);
	MapCount = MapListItems.CountEnabled();
	if (MapCount <= 0)
		return;

	Channel.Vote(ActivePreset, VS_UI_MapListItem(MapListItems.FindEnabledEntry(int(MapCount * BetterFRand()))).MapRef);
}

function ToggleFavorite(VS_Map M) {
	Channel.ToggleFavorite(M, ActivePreset);
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

function ConfigureLogo(string Tex, int TexX, int TexY, int TexW, int TexH, int DrawX, int DrawY, int DrawW, int DrawH) {
	Logo.SetLogoTexture(Tex);
	if (TexX != 0 || TexY != 0 || TexW != 0 || TexH != 0)
		Logo.SetLogoRegion(TexX, TexY, TexW, TexH);
	Logo.SetDrawRegion(DrawX, DrawY, DrawW, DrawH);

	if (Logo.LogoTexture != none) {
		Logo.ShowWindow();
		if (LogoButtons[0].LinkURL != "")
			LogoButtons[0].ShowWindow();
		if (LogoButtons[1].LinkURL != "")
			LogoButtons[1].ShowWindow();
		if (LogoButtons[2].LinkURL != "")
			LogoButtons[2].ShowWindow();

		ChatArea.HideWindow();
		ChatEdit.HideWindow();
		ChatSay.HideWindow();
	}
}

function ConfigureLogoButton(int Index, string Label, string LinkURL) {
	if (Index < 0 || Index >= arraycount(LogoButtons))
		return;

	LogoButtons[Index].SetText(Label);
	LogoButtons[Index].LinkURL = LinkURL;

	if (Logo.bWindowVisible && LinkURL != "")
		LogoButtons[Index].ShowWindow();
}

function UpdateFavoritesEnd() {
	MapListBox.Items.Sort();
}

function Close(optional bool bByParent) {
	if (MapScreenshotWindow.bWindowVisible)
		MapScreenshotWindow.Close();

	super.Close(bByParent);
}

defaultproperties {
	ActiveTheme=-1
	
	MapFilterText="Filter Maps By Name"
	VoteButtonText="Vote"
	SuggestButtonText="Suggest"
	RandomButtonText="Random"
	ChatSayText="Say"
	ChatTeamSayText="TeamSay"

	bMapFilterApplied=True
}
