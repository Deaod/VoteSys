class VS_UI_CategoryTabControl extends UWindowTabControl;

function Paint(Canvas C, float X, float Y) {
	
	super.Paint(C, X, Y);
}

defaultproperties {
	ListClass=class'VS_UI_CategoryTabItem'
}
