class VS_ClientPresetList extends Object;

var array<VS_ClientPreset> PresetList;

enum ETransmissionState {
	TS_New,
	TS_Complete,
	TS_NotAdmin
};
var ETransmissionState TransmissionState;

function AllocatePresets(int MaxIndex) {
	local int i;
	i = PresetList.Length;
	if (i <= MaxIndex) {
		PresetList.Insert(i, MaxIndex - i + 1);
		while(i < PresetList.Length) {
			PresetList[i] = new class'VS_ClientPreset';
			i += 1;
		}
	}
}

function VS_ClientPreset AddPreset() {
	local int i;

	if (TransmissionState != TS_Complete)
		return none;

	i = PresetList.Length;
	PresetList.Insert(i, 1);
	PresetList[i] = new class'VS_ClientPreset';
	return PresetList[i];
}

