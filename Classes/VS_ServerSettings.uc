class VS_ServerSettings extends Object
	perobjectconfig;

enum EVoteEndCond {
	VEC_TimerOnly,
	VEC_TimerOrAllVotesIn,
	VEC_TimerOrResultDetermined
};

var config int GameEndedVoteDelay;
var config int VoteTimeLimit;
var config float MidGameVoteThreshold;
var config int MidGameVoteTimeLimit;
var config EVoteEndCond VoteEndCondition;
var config int MinimumMapRepeatDistance;
var config float KickVoteThreshold;
var config string DefaultTimeMessageClass;
var config string DefaultPreset;
var config string DefaultMap;
var config string ServerAddress;
var config int DataPort;
var config int ClientDataPort;
var config bool bManageServerPackages;
var config bool bUseServerActorsCompatibilityMode;
var config int PresetProbeDepth;
var config array<string> DefaultPackages;
var config array<string> DefaultActors;

defaultproperties {
	GameEndedVoteDelay=5
	VoteTimeLimit=30
	MidGameVoteThreshold=0.5
	MidGameVoteTimeLimit=0
	VoteEndCondition=VEC_TimerOnly
	MinimumMapRepeatDistance=0
	KickVoteThreshold=0.6
	DefaultTimeMessageClass="Botpack.TimeMessage"
	DefaultPreset=
	DefaultMap=
	ServerAddress=
	DataPort=0
	ClientDataPort=0
	bManageServerPackages=False
	bUseServerActorsCompatibilityMode=False
	PresetProbeDepth=1
}
