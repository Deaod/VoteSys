class VS_UIS_PageAdminSetup extends VS_UIS_PageAdmin;

var VS_UI_Checkbox Chk_EnableACEIntegration;
var localized string Text_EnableACEIntegration;

var VS_UI_EditControl Edt_PresetProbeDepth;
var localized string Text_PresetProbeDepth;

var VS_UI_Checkbox Chk_ManageServerPackages;
var localized string Text_ManageServerPackages;

var VS_UI_Checkbox Chk_UseServerPackagesCompatibilityMode;
var localized string Text_UseServerPackagesCompatibilityMode;

var VS_UI_ArrayEditString Adt_DefaultPackages;
var localized string Text_DefaultPackages;

var VS_UI_Checkbox Chk_UseServerActorsCompatibilityMode;
var localized string Text_UseServerActorsCompatibilityMode;

var VS_UI_ArrayEditString Adt_DefaultActors;
var localized string Text_DefaultActors;

var VS_UI_ComboControl Cmb_GameNameMode;
var localized string Text_GameNameMode;
var localized string Text_GameNameMode_DoNotModify;
var localized string Text_GameNameMode_PresetName;
var localized string Text_GameNameMode_CategoryAndPresetName;

var VS_UI_Checkbox Chk_EnableCustomDataTransport;
var localized string Text_EnableCustomDataTransport;

var VS_UI_EditControl Edt_ServerAddress;
var localized string Text_ServerAddress;

var VS_UI_EditControl Edt_DataPort;
var localized string Text_DataPort;

var VS_UI_EditControl Edt_ClientDataPort;
var localized string Text_ClientDataPort;

var VS_UI_EditControl Edt_DefaultPreset;
var localized string Text_DefaultPreset;

var VS_UI_Checkbox Chk_AlwaysUseDefaultPreset;
var localized string Text_AlwaysUseDefaultPreset;

var VS_UI_EditControl Edt_DefaultMap;
var localized string Text_DefaultMap;

var VS_UI_Checkbox Chk_AlwaysUseDefaultMap;
var localized string Text_AlwaysUseDefaultMap;

var VS_UI_EditControl Edt_IdleTimeout;
var localized string Text_IdleTimeout;

function EnableInteraction(bool bEnable) {
	Chk_EnableACEIntegration.bDisabled = !bEnable;
	Edt_DefaultPreset.EditBox.SetEditable(bEnable);
	Chk_AlwaysUseDefaultPreset.bDisabled = !bEnable;
	Edt_DefaultMap.EditBox.SetEditable(bEnable);
	Chk_AlwaysUseDefaultMap.bDisabled = !bEnable;
	Edt_IdleTimeout.EditBox.SetEditable(bEnable);
	Edt_PresetProbeDepth.EditBox.SetEditable(bEnable);
	Chk_ManageServerPackages.bDisabled = !bEnable;
	Chk_UseServerPackagesCompatibilityMode.bDisabled = !bEnable;
	Adt_DefaultPackages.SetEnabled(bEnable);
	Chk_UseServerActorsCompatibilityMode.bDisabled = !bEnable;
	Adt_DefaultActors.SetEnabled(bEnable);
	Cmb_GameNameMode.SetEnabled(bEnable);
	Chk_EnableCustomDataTransport.bDisabled = !bEnable;
	Edt_ServerAddress.EditBox.SetEditable(bEnable);
	Edt_DataPort.EditBox.SetEditable(bEnable);
	Edt_ClientDataPort.EditBox.SetEditable(bEnable);
}

function LoadServerSettings() {
	Chk_EnableACEIntegration.bChecked = Settings.bEnableACEIntegration;
	Edt_DefaultPreset.SetValue(Settings.DefaultPreset);
	Chk_AlwaysUseDefaultPreset.bChecked = Settings.bAlwaysUseDefaultPreset;
	Edt_DefaultMap.SetValue(Settings.DefaultMap);
	Chk_AlwaysUseDefaultMap.bChecked = Settings.bAlwaysUseDefaultMap;
	Edt_IdleTimeout.SetValue(string(Settings.IdleTimeout));
	Edt_PresetProbeDepth.SetValue(string(Settings.PresetProbeDepth));
	Chk_ManageServerPackages.bChecked = Settings.bManageServerPackages;
	Chk_UseServerPackagesCompatibilityMode.bChecked = Settings.bUseServerPackagesCompatibilityMode;
	Adt_DefaultPackages.SetValue(Settings.GetPropertyText("DefaultPackages"));
	Chk_UseServerActorsCompatibilityMode.bChecked = Settings.bUseServerActorsCompatibilityMode;
	Adt_DefaultActors.SetValue(Settings.GetPropertyText("DefaultActors"));
	Cmb_GameNameMode.SetSelectedIndex(int(Settings.GameNameMode));
	Chk_EnableCustomDataTransport.bChecked = Settings.bEnableCustomDataTransport;
	Edt_ServerAddress.SetValue(Settings.ServerAddress);
	Edt_DataPort.SetValue(string(Settings.DataPort));
	Edt_ClientDataPort.SetValue(string(Settings.ClientDataPort));
}

function SaveSettings() {
	Settings.bEnableACEIntegration = Chk_EnableACEIntegration.bChecked;
	Settings.DefaultPreset = Edt_DefaultPreset.GetValue();
	Settings.bAlwaysUseDefaultPreset = Chk_AlwaysUseDefaultPreset.bChecked;
	Settings.DefaultMap = Edt_DefaultMap.GetValue();
	Settings.bAlwaysUseDefaultMap = Chk_AlwaysUseDefaultMap.bChecked;
	Settings.IdleTimeout = int(Edt_IdleTimeout.GetValue());
	Settings.PresetProbeDepth = int(Edt_PresetProbeDepth.GetValue());
	Settings.bManageServerPackages = Chk_ManageServerPackages.bChecked;
	Settings.bUseServerPackagesCompatibilityMode = Chk_UseServerPackagesCompatibilityMode.bChecked;
	Settings.SetPropertyText("DefaultPackages", Adt_DefaultPackages.GetValue());
	Settings.bUseServerActorsCompatibilityMode = Chk_UseServerActorsCompatibilityMode.bChecked;
	Settings.SetPropertyText("DefaultActors", Adt_DefaultActors.GetValue());
	Settings.GameNameMode = Settings.IntToGameNameMode(Cmb_GameNameMode.GetSelectedIndex());
	Settings.bEnableCustomDataTransport = Chk_EnableCustomDataTransport.bChecked;
	Settings.ServerAddress = Edt_ServerAddress.GetValue();
	Settings.DataPort = int(Edt_DataPort.GetValue());
	Settings.ClientDataPort = int(Edt_ClientDataPort.GetValue());

	super.SaveSettings();
}

function Created() {
	super.Created();

	Chk_EnableACEIntegration = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 4, 8, 188, 16));
	Chk_EnableACEIntegration.SetText(Text_EnableACEIntegration);

	Edt_DefaultPreset = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 28, 188, 16));
	Edt_DefaultPreset.SetText(Text_DefaultPreset);
	Edt_DefaultPreset.EditBoxWidth = 100;

	Chk_AlwaysUseDefaultPreset = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 4, 48, 188, 16));
	Chk_AlwaysUseDefaultPreset.SetText(Text_AlwaysUseDefaultPreset);

	Edt_DefaultMap = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 68, 188, 16));
	Edt_DefaultMap.SetText(Text_DefaultMap);
	Edt_DefaultMap.EditBoxWidth = 100;

	Chk_AlwaysUseDefaultMap = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 4, 88, 188, 16));
	Chk_AlwaysUseDefaultMap.SetText(Text_AlwaysUseDefaultMap);

	Edt_IdleTimeout = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 108, 188, 16));
	Edt_IdleTimeout.SetText(Text_IdleTimeout);
	Edt_IdleTimeout.EditBoxWidth = 60;
	Edt_IdleTimeout.SetNumericOnly(true);

	Edt_PresetProbeDepth = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 128, 188, 16));
	Edt_PresetProbeDepth.SetText(Text_PresetProbeDepth);
	Edt_PresetProbeDepth.EditBoxWidth = 60;
	Edt_PresetProbeDepth.SetNumericOnly(true);

	//
	// Right Side
	//

	Chk_ManageServerPackages = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 200, 8, 188, 16));
	Chk_ManageServerPackages.SetText(Text_ManageServerPackages);

	Chk_UseServerPackagesCompatibilityMode = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 200, 28, 188, 16));
	Chk_UseServerPackagesCompatibilityMode.SetText(Text_UseServerPackagesCompatibilityMode);

	Adt_DefaultPackages = VS_UI_ArrayEditString(CreateControl(class'VS_UI_ArrayEditString', 200, 48, 188, 16));
	Adt_DefaultPackages.SetText(Text_DefaultPackages);
	Adt_DefaultPackages.EditBoxWidth = 100;

	Chk_UseServerActorsCompatibilityMode = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 200, 68, 188, 16));
	Chk_UseServerActorsCompatibilityMode.SetText(Text_UseServerActorsCompatibilityMode);

	Adt_DefaultActors = VS_UI_ArrayEditString(CreateControl(class'VS_UI_ArrayEditString', 200, 88, 188, 16));
	Adt_DefaultActors.SetText(Text_DefaultActors);
	Adt_DefaultActors.EditBoxWidth = 100;

	Cmb_GameNameMode = VS_UI_ComboControl(CreateControl(class'VS_UI_ComboControl', 200, 108, 188, 16));
	Cmb_GameNameMode.SetText(Text_GameNameMode);
	Cmb_GameNameMode.AddItem(Text_GameNameMode_DoNotModify);
	Cmb_GameNameMode.AddItem(Text_GameNameMode_PresetName);
	Cmb_GameNameMode.AddItem(Text_GameNameMode_CategoryAndPresetName);
	Cmb_GameNameMode.EditBoxWidth = 100;
	Cmb_GameNameMode.SetEditable(false);

	Chk_EnableCustomDataTransport = VS_UI_Checkbox(CreateControl(class'VS_UI_Checkbox', 200, 128, 188, 16));
	Chk_EnableCustomDataTransport.SetText(Text_EnableCustomDataTransport);

	Edt_ServerAddress = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 148, 188, 16));
	Edt_ServerAddress.SetText(Text_ServerAddress);
	Edt_ServerAddress.EditBoxWidth = 100;

	Edt_DataPort = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 168, 188, 16));
	Edt_DataPort.SetText(Text_DataPort);
	Edt_DataPort.EditBoxWidth = 60;
	Edt_DataPort.SetNumericOnly(true);

	Edt_ClientDataPort = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 200, 188, 188, 16));
	Edt_ClientDataPort.SetText(Text_ClientDataPort);
	Edt_ClientDataPort.EditBoxWidth = 60;
	Edt_ClientDataPort.SetNumericOnly(true);
}

function ApplyTheme() {
	//Chk_EnableACEIntegration // not themed
	Edt_DefaultPreset.Theme = Theme;
	//Chk_AlwaysUseDefaultPreset // not themed
	Edt_DefaultMap.Theme = Theme;
	//Chk_AlwaysUseDefaultMap // not themed
	Edt_IdleTimeout.Theme = Theme;
	Edt_PresetProbeDepth.Theme = Theme;
	//Chk_ManageServerPackages // not themed
	//Chk_UseServerPackagesCompatibilityMode // not themed
	Adt_DefaultPackages.SetTheme(Theme);
	//Chk_UseServerActorsCompatibilityMode // not themed
	Adt_DefaultActors.SetTheme(Theme);
	Cmb_GameNameMode.Theme = Theme;
	//Chk_EnableCustomDataTransport // not themed
	Edt_ServerAddress.Theme = Theme;
	Edt_DataPort.Theme = Theme;
	Edt_ClientDataPort.Theme = Theme;
}

defaultproperties {
	Text_EnableACEIntegration="Enable ACE Integration"
	Text_DefaultPreset="Default Preset"
	Text_AlwaysUseDefaultPreset="Always Use Default Preset"
	Text_DefaultMap="Default Map"
	Text_AlwaysUseDefaultMap="Always Use Default Map"
	Text_IdleTimeout="Idle Timeout"
	Text_PresetProbeDepth="Preset Probe Depth"
	Text_ManageServerPackages="Manage Server Packages"
	Text_UseServerPackagesCompatibilityMode="Use Server Package Compat. Mode"
	Text_DefaultPackages="Default Packages"
	Text_UseServerActorsCompatibilityMode="Use Server Actors Compat. Mode"
	Text_DefaultActors="Default Actors"
	Text_GameNameMode="GameName Mode"
	Text_GameNameMode_DoNotModify="Do Not Modify"
	Text_GameNameMode_PresetName="Preset Name"
	Text_GameNameMode_CategoryAndPresetName="Full Preset Name"
	Text_EnableCustomDataTransport="Custom Data Transport"
	Text_ServerAddress="Server Address"
	Text_DataPort="Data Port"
	Text_ClientDataPort="Client Data Port"
}
