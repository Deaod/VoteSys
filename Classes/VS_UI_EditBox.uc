class VS_UI_EditBox extends UWindowEditBox;

var string EmptyText;
var color EmptyTextColor;
var bool bNumericNegative;

function Paint(Canvas C, float X, float Y) {
	local float W, H;
	local float TextY;

	super.Paint(C, X, Y);

	if (bCanEdit && GetValue() == "") {
		C.Font = Root.Fonts[Font];
		TextSize(C, "A", W, H);
		TextY = (WinHeight - H) / 2;

		C.DrawColor = EmptyTextColor;
		ClipText(C, Offset + 3, TextY, EmptyText);
		C.DrawColor = TextColor;
	}
}

function KeyType(int Key, float MouseX, float MouseY) {
	if (bCanEdit == false || bKeyDown == false)
		return;

	if (bControlDown)
		return;

	if (bAllSelected)
		Clear();

	bAllSelected = False;

	if (bNumericOnly) {
		if (Key >= 0x30 && Key <= 0x39)
			Insert(Key);
		if (bNumericNegative) {
			if (Key == 0x2D && Left(Value, 1) != "-") {
				Value = "-"$Value;
				CaretOffset += 1;

				if (bDelayedNotify)
					bChangePending = true;
				else
					Notify(DE_Change);
			} else if (Key == 0x2B && Left(Value, 1) == "-") {
				Value = Mid(Value, 1);
				CaretOffset -= 1;

				if (bDelayedNotify)
					bChangePending = true;
				else
					Notify(DE_Change);
			}
		}
	} else {
		if (Key >= 0x20 && Key < 0x80)
			Insert(Key);
	}
}

defaultproperties {
	EmptyTextColor=(R=128,G=128,B=128,A=255)
}
