class VS_UI_EditBox extends UWindowEditBox;

var string EmptyText;
var color EmptyTextColor;

function Paint(Canvas C, float X, float Y) {
	local float W, H;
	local float TextY;

	super.Paint(C, X, Y);

	if (GetValue() == "") {
		C.Font = Root.Fonts[Font];
		TextSize(C, "A", W, H);
		TextY = (WinHeight - H) / 2;

		C.DrawColor = EmptyTextColor;
		ClipText(C, Offset + 3, TextY, EmptyText);
		C.DrawColor = TextColor;
	}
}

defaultproperties {
	EmptyTextColor=(R=128,G=128,B=128,A=255)
}
