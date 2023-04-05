class VS_UI_ThemeBase extends UWindowBase
	abstract;

var color Foreground;
var color Background;
var color Separator;
var color InactiveFG;
var color ForegroundAlt;
var color BackgroundAlt;
var color SeparatorAlt;
var color HighlitFG;
var color HighlitBG;
var color HighlitSep;
var color SelectFG;
var color SelectBG;
var color SelectSep;

final function DrawBox(Canvas C, UWindowWindow Win, float X, float Y, float W, float H) {
	//Higor: The borders of the bevel will be drawn in integer scale so they won't look ugly
	local float S;
	local Region TL, T, TR, L, R, BL, B, BR, Area;
	local color OldColor;

	if ( Win.Root.GUIScale > 1 )
		S = float(int(Win.Root.GUIScale)) / Win.Root.GUIScale;
	else
		S = 1;

	TL   = Win.LookAndFeel.MiscBevelTL[Win.LookAndFeel.EditBoxBevel];
	T    = Win.LookAndFeel.MiscBevelT[Win.LookAndFeel.EditBoxBevel];
	TR   = Win.LookAndFeel.MiscBevelTR[Win.LookAndFeel.EditBoxBevel];
	L    = Win.LookAndFeel.MiscBevelL[Win.LookAndFeel.EditBoxBevel];
	R    = Win.LookAndFeel.MiscBevelR[Win.LookAndFeel.EditBoxBevel];
	BL   = Win.LookAndFeel.MiscBevelBL[Win.LookAndFeel.EditBoxBevel];
	B    = Win.LookAndFeel.MiscBevelB[Win.LookAndFeel.EditBoxBevel];
	BR   = Win.LookAndFeel.MiscBevelBR[Win.LookAndFeel.EditBoxBevel];
	Area = Win.LookAndFeel.MiscBevelArea[Win.LookAndFeel.EditBoxBevel];

	OldColor = C.DrawColor;

	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;
	C.DrawColor.A = 255;
	Win.DrawStretchedTextureSegment( C, X             , Y             ,     (TL.W)*S     ,     (TL.H)*S     , TL.X, TL.Y, TL.W, TL.H, Win.LookAndFeel.Misc );
	Win.DrawStretchedTextureSegment( C, X   + (TL.W)*S, Y             , W - (TL.W+TR.W)*S,     (T.H)*S      ,  T.X,  T.Y,  T.W,  T.H, Win.LookAndFeel.Misc );
	Win.DrawStretchedTextureSegment( C, X+W - (TR.W)*S, Y             ,     (TR.W)*S     ,     (TR.H)*S     , TR.X, TR.Y, TR.W, TR.H, Win.LookAndFeel.Misc );
	Win.DrawStretchedTextureSegment( C, X             , Y   + (TL.H)*S,     (L.W)*S      , H - (TL.H+BL.H)*S,  L.X,  L.Y,  L.W,  L.H, Win.LookAndFeel.Misc );
	Win.DrawStretchedTextureSegment( C, X+W - ( R.W)*S, Y   + (TL.H)*S,     (R.W)*S      , H - (TL.H+BL.H)*S,  R.X,  R.Y,  R.W,  R.H, Win.LookAndFeel.Misc );
	Win.DrawStretchedTextureSegment( C, X             , Y+H - (BL.H)*S,     (BL.W)*S     ,     (BL.H)*S     , BL.X, BL.Y, BL.W, BL.H, Win.LookAndFeel.Misc );
	Win.DrawStretchedTextureSegment( C, X   + (BL.W)*S, Y+H - ( B.H)*S, W - (BL.W+BR.W)*S,     (B.H)*S      ,  B.X,  B.Y,  B.W,  B.H, Win.LookAndFeel.Misc );
	Win.DrawStretchedTextureSegment( C, X+W - (BR.W)*S, Y+H - (BR.H)*S,     (BR.W)*S     ,     (BR.H)*S     , BR.X, BR.Y, BR.W, BR.H, Win.LookAndFeel.Misc );

	C.DrawColor = Background;
	Win.DrawStretchedTextureSegment( C, X   + (TL.W)*S, Y   + (TL.H)*S, W - (BL.W+BR.W)*S, H - (TL.H+BL.H)*S, Area.X, Area.Y, Area.W, Area.H, Win.LookAndFeel.Misc );

	C.DrawColor = OldColor;
}

defaultproperties {
	Foreground=(R=0,G=0,B=0,A=0)
	Background=(R=0,G=0,B=0,A=0)
	Separator=(R=0,G=0,B=0,A=0)
	InactiveFG=(R=0,G=0,B=0,A=0)
	ForegroundAlt=(R=0,G=0,B=0,A=0)
	BackgroundAlt=(R=0,G=0,B=0,A=0)
	SeparatorAlt=(R=0,G=0,B=0,A=0)
	HighlitFG=(R=0,G=0,B=0,A=0)
	HighlitBG=(R=0,G=0,B=0,A=0)
	HighlitSep=(R=0,G=0,B=0,A=0)
	SelectFG=(R=0,G=0,B=0,A=0)
	SelectBG=(R=0,G=0,B=0,A=0)
	SelectSep=(R=0,G=0,B=0,A=0)
}
