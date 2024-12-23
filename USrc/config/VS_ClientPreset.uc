class VS_ClientPreset extends Object;

var string        PresetName;
var string        Abbreviation;
var string        Category;
var int           SortPriority;
var array<string> InheritFrom;
var string        ServerName;
var string        Game;
var name          MapListName;
var array<string> Mutators;
var array<string> Parameters;
var array<string> GameSettings;
var array<string> Packages;
var bool          bDisabled;
var bool          bOpenVoteMenuAutomatically;
var int           MinimumMapRepeatDistance;
var int           MinPlayers;
var int           MaxPlayers;

defaultproperties {
	bOpenVoteMenuAutomatically=True
	MinimumMapRepeatDistance=-1
	MinPlayers=-1
	MaxPlayers=-1
}
