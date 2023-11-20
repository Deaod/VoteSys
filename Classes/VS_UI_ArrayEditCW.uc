class VS_UI_ArrayEditCW extends UWindowDialogClientWindow;

var VS_UI_ArrayEditControl Owner;

var VS_UI_EditControl Edt_Element;
var VS_UI_ArrayEditLB Lst_Elements;
var VS_UI_ArrayEditLI CurrentElement;

var UWindowSmallButton Btn_AddElement;
var UWindowSmallButton Btn_RemElement;
var UWindowSmallCloseButton Btn_Close;

function Created() {
	super.Created();
	SetAcceptsFocus();

	Edt_Element = VS_UI_EditControl(CreateControl(class'VS_UI_EditControl', 4, 4, 180, 16));
	Edt_Element.EditBoxWidth = Edt_Element.WinWidth;
	Edt_Element.EditBox.bSelectOnFocus = false;

	Lst_Elements = VS_UI_ArrayEditLB(CreateControl(class'VS_UI_ArrayEditLB', 24, 24, 160, 36));

	Btn_AddElement = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 4, 24, 16, 16));
	Btn_AddElement.SetText("+");
	Btn_AddElement.SetFont(F_Large);

	Btn_RemElement = UWindowSmallButton(CreateControl(class'UWindowSmallButton', 4, 44, 16, 16));
	Btn_RemElement.SetText("-");
	Btn_RemElement.SetFont(F_Large);

	Btn_Close = UWindowSmallCloseButton(CreateControl(class'UWindowSmallCloseButton', 24, 24, 40, 16));
}

function SetTheme(VS_UI_ThemeBase T) {
	Edt_Element.Theme = T;
	Lst_Elements.Theme = T;
}

function Notify(UWindowDialogControl C, byte E) {
	if (E == DE_Click) {
		if (C == Btn_AddElement) {
			AddNewElement();
		} else if (C == Btn_RemElement) {
			RemoveCurrentElement();
		}
	}

	if (E == DE_Change) {
		if (C == Edt_Element) {
			CurrentElement.Text = Edt_Element.GetValue();
		}
	}

	if (E == Lst_Elements.DE_VoteSys_ClickDone && C == Lst_Elements) {
		Edt_Element.ActivateWindow(0, false);
	}
}

function VS_UI_ArrayEditLI AddElement(string Text) {
	return Lst_Elements.AddElement(Text);
}

function AddNewElement() {
	local VS_UI_ArrayEditLI I;
	I = AddElement("");
	Lst_Elements.SetSelectedItem(I);
	Edt_Element.ActivateWindow(0, false);
}

function RemoveCurrentElement() {
	local UWindowListBoxItem It;
	if (CurrentElement == none)
		return;

	It = UWindowListBoxItem(CurrentElement.Next);
	if (It == none)
		It = UWindowListBoxItem(CurrentElement.Prev);

	if (It != none && It != Lst_Elements.Items)
		Lst_Elements.SetSelectedItem(It);
	else
		Lst_Elements.SelectedItem = none;

	CurrentElement.Remove();
}

function Resized() {
	super.Resized();

	Edt_Element.SetSize(WinWidth - 8, 16);
	Edt_Element.EditBoxWidth = Edt_Element.WinWidth;

	Lst_Elements.SetSize(
		WinWidth - 12 - Btn_AddElement.WinWidth,
		WinHeight - 16 - Edt_Element.WinHeight - Btn_Close.WinHeight
	);

	Btn_Close.WinLeft = WinWidth - 4 - Btn_Close.WinWidth;
	Btn_Close.WinTop = WinHeight - 4 - Btn_Close.WinHeight;
}

function BeforePaint(Canvas C, float MouseX, float MouseY) {
	super.BeforePaint(C, MouseX, MouseY);

	if (CurrentElement != Lst_Elements.SelectedItem) {
		CurrentElement = VS_UI_ArrayEditLI(Lst_Elements.SelectedItem);
		Edt_Element.SetValue(CurrentElement.Text);
		Edt_Element.EditBox.MoveEnd();
	}

	if (CurrentElement == none) {
		Btn_RemElement.bDisabled = true;
		Edt_Element.EditBox.bCanEdit = false;
	} else {
		Btn_RemElement.bDisabled = false;
		Edt_Element.EditBox.bCanEdit = true;
	}
}

function SetOwner(VS_UI_ArrayEditControl O) {
	Owner = O;
}
