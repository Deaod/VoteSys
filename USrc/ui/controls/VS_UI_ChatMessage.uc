class VS_UI_ChatMessage extends UWindowDynamicTextRow;

var string PlayerName;
var bool bTeamMsg;
var int ColorRef;
var color PlayerColor;

function string LineText() {
	if (PlayerName != "")
		return PlayerName$": "$Text;
	return Text;
}
