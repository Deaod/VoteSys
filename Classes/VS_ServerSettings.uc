class VS_ServerSettings extends Object
	perobjectconfig;

enum EVoteEndCond {
	VEC_TimerOnly,
	VEC_TimerOrAllVotesIn,
	VEC_TimerOrResultDetermined
};

var config float MidGameVoteThreshold;
var config int MidGameVoteTimeLimit;
var config int GameEndedVoteDelay;
var config int VoteTimeLimit;
var config EVoteEndCond VoteEndCondition;

var config float KickVoteThreshold;

var config string DefaultPreset;
var config string DefaultMap;

var config string ServerAddress;
var config int DataPort;
var config int ClientDataPort;

var config bool bManageServerPackages;
var config bool bUseServerActorsCompatibilityMode;
var config array<string> DefaultPackages;
var config array<string> DefaultActors;

var config string DefaultTimeMessageClass;
var config int IdleTimeout;
var config int MinimumMapRepeatDistance;
var config int PresetProbeDepth;
var config bool bChangeGameNameForPresets;

defaultproperties {
	MidGameVoteThreshold=0.5
	MidGameVoteTimeLimit=0
	GameEndedVoteDelay=5
	VoteTimeLimit=30
	VoteEndCondition=VEC_TimerOnly

	KickVoteThreshold=0.6

	DefaultPreset=
	DefaultMap=

	ServerAddress=
	DataPort=0
	ClientDataPort=0

	bManageServerPackages=False
	bUseServerActorsCompatibilityMode=False

	DefaultTimeMessageClass="Botpack.TimeMessage"
	IdleTimeout=0
	MinimumMapRepeatDistance=0
	PresetProbeDepth=1
	bChangeGameNameForPresets=False
}
