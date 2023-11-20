class VS_UI_ArrayEditLB extends VS_UI_ListBox;

function DrawItem(Canvas C, UWindowList Item, float X, float Y, float W, float H) {
	local VS_UI_ArrayEditLI I;

	super.DrawItem(C, Item, X, Y, W, H);

	I = VS_UI_ArrayEditLI(Item);
	ClipText(C, X+2, Y, ">"@I.Text);
}

function VS_UI_ArrayEditLI AddElement(string Text) {
	local VS_UI_ArrayEditLI I;
	I = VS_UI_ArrayEditLI(Items.Append(ListClass));
	I.Text = Text;
	return I;
}

defaultproperties {
	ListClass=class'VS_UI_ArrayEditLI'
	bCanDrag=True
	ItemHeight=13
}