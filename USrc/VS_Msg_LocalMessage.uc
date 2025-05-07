class VS_Msg_LocalMessage extends LocalMessagePlus;

enum EVS_MsgId {
	MsgNobodyVoted,
	MsgVotesTied,
	MsgHaveWinner,
	MsgMidGame,
	MsgGameEnded,
	MsgPlayerVoted,
	MsgAdminForceTravel,
	MsgAdminKickPlayer,
	MsgAdminBanPlayer,
	MsgKickVotePlaced,
	MsgKickVoteSuccessful,
	MsgPlayerVotedRandom,

	ErrStillLoading,
	ErrNoRootWindow,
	ErrCreateDialog,
	ErrWrongConsole,
	ErrMapLoadFailed,
	ErrNoConnection,
	ErrNotAllowed,
	ErrUrlTooLong
};

var localized string MsgNobodyVotedText;
var localized string MsgVotesTiedText;
var localized string MsgHaveWinnerText;
var localized string MsgMidGameText;
var localized string MsgGameEndedText;
var localized string MsgPlayerVotedText;
var localized string MsgAdminForceTravelText;
var localized string MsgAdminKickPlayerText;
var localized string MsgAdminBanPlayerText;
var localized string MsgKickVotePlacedText;
var localized string MsgKickVoteSuccessfulText;
var localized string MsgPlayerVotedRandomText;

var localized string ErrStillLoadingText;
var localized string ErrNoRootWindowText;
var localized string ErrCreateDialogText;
var localized string ErrWrongConsoleText;
var localized string ErrMapLoadFailedText;
var localized string ErrNoConnectionText;
var localized string ErrNotAllowedText;
var localized string ErrUrlTooLongText;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
) {
	local string Result;
	local VS_Msg_ParameterContainer Params;

	Params = VS_Msg_ParameterContainer(OptionalObject);

	switch(Switch) {
		case EVS_MsgId.MsgNobodyVoted:        Result = default.MsgNobodyVotedText; break;
		case EVS_MsgId.MsgVotesTied:          Result = default.MsgVotesTiedText; break;
		case EVS_MsgId.MsgHaveWinner:         Result = default.MsgHaveWinnerText; break;
		case EVS_MsgId.MsgMidGame:            Result = default.MsgMidGameText; break;
		case EVS_MsgId.MsgGameEnded:          Result = default.MsgGameEndedText; break;
		case EVS_MsgId.MsgPlayerVoted:        Result = default.MsgPlayerVotedText; break;
		case EVS_MsgId.MsgAdminForceTravel:   Result = default.MsgAdminForceTravelText; break;
		case EVS_MsgId.MsgAdminKickPlayer:    Result = default.MsgAdminKickPlayerText; break;
		case EVS_MsgId.MsgAdminBanPlayer:     Result = default.MsgAdminBanPlayerText; break;
		case EVS_MsgId.MsgKickVotePlaced:     Result = default.MsgKickVotePlacedText; break;
		case EVS_MsgId.MsgKickVoteSuccessful: Result = default.MsgKickVoteSuccessfulText; break;
		case EVS_MsgId.MsgPlayerVotedRandom : Result = default.MsgPlayerVotedRandomText; break;

		case EVS_MsgId.ErrStillLoading:       Result = default.ErrStillLoadingText; break;
		case EVS_MsgId.ErrNoRootWindow:       Result = default.ErrNoRootWindowText; break;
		case EVS_MsgId.ErrCreateDialog:       Result = default.ErrCreateDialogText; break;
		case EVS_MsgId.ErrWrongConsole:       Result = default.ErrWrongConsoleText; break;
		case EVS_MsgId.ErrMapLoadFailed:      Result = default.ErrMapLoadFailedText; break;
		case EVS_MsgId.ErrNoConnection:       Result = default.ErrNoConnectionText; break;
		case EVS_MsgId.ErrNotAllowed:         Result = default.ErrNotAllowedText; break;
		case EVS_MsgId.ErrUrlTooLong:         Result = default.ErrUrlTooLongText; break;

		default:
			return "";
	}
	
	if (Params == none)
		return Result;
	return Params.ApplyParameters(Result);
}

static function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
) {
	local string Msg;

	Msg = static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if (P.myHUD != none)
		P.myHUD.Message(P.PlayerReplicationInfo, Msg, 'VoteSys');

	if ( Default.bBeep && P.bMessageBeep )
		P.PlayBeepSound();

	if ( Default.bIsConsoleMessage )
	{
		if ((P.Player != None) && (P.Player.Console != None))
			P.Player.Console.Message(P.PlayerReplicationInfo, Msg, 'VoteSys');
	}
}

defaultproperties {
	bIsConsoleMessage=True
	bComplexString=True
	Lifetime=5

	MsgNobodyVotedText="Nobody voted, randomly selecting {1}"
	MsgVotesTiedText="Tied, randomly selecting {1}"
	MsgHaveWinnerText="{1} won"
	MsgMidGameText="Initiating mid-game voting, opening Vote Menu"
	MsgGameEndedText="Game ended, opening Vote Menu"
	MsgPlayerVotedText="{1} voted for {2}"
	MsgAdminForceTravelText="Admin {1} forced switching to {2}"
	MsgAdminKickPlayerText="Admin {1} kicked player {2} ({3})"
	MsgAdminBanPlayerText="Admin {1} banned player {2} ({3})"
	MsgKickVotePlacedText="A player voted to kick {1}"
	MsgKickVoteSuccessfulText="{1} was kicked"
	MsgPlayerVotedRandomText="{1} voted for random map ({2})"

	ErrStillLoadingText="Vote Menu data is still being transferred, please try again"
	ErrNoRootWindowText="Failed to create {1} window (Root does not exist)"
	ErrCreateDialogText="Failed to create {1} window (Could not create Dialog)"
	ErrWrongConsoleText="Failed to create {1} window (Console not a WindowConsole)"
	ErrMapLoadFailedText="Loading map {1} failed, randomly selecting {2}"
	ErrNoConnectionText="VoteSys has no connection to server, check server firewall"
	ErrNotAllowedText="Sorry, you are not allowed to vote"
	ErrUrlTooLongText="URL to switch to '{1}' with preset '{2}' is too long (>1023 characters)"
}
