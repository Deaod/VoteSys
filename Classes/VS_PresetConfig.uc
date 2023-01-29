class VS_PresetConfig extends Object
	perobjectconfig;

/** Name of the preset */
var config string PresetName;
/** Short version of Name */
var config string Abbreviation;
/** Which Category to add this Preset to */
var config string Category;
/** List of full preset names to inherit data from */
var config array<string> InheritFrom;
/** Which game type to use */
var config string Game;
/** Which MapList to use for this preset, empty uses all map for specified game type */
var config name   MapListName;
/** Comma-separated list of Mutators */
var config array<string> Mutators;
/** Comma-separated list of URL parameters to pass when switching maps */
var config array<string> Parameters;
/** Comma-separated list of game type settings to change */
var config array<string> GameSettings;
/** Disabled presets are not shown to users and cannot be voted for */
var config bool bDisabled;
