class VS_UI_LinkButton extends UWindowSmallButton;

var string LinkURL;

function Click(float X, float Y) {
	local VS_UIV_ClientWindow CW;
	
	GetPlayerOwner().ConsoleCommand("start"@LinkURL);

	if (Left(LinkURL, 9) ~= "unreal://") {
		CW = VS_UIV_ClientWindow(GetParent(class'VS_UIV_ClientWindow'));
		CW.Channel.VoteMenuDialog.Close();
		if (CW.Channel.SettingsDialog.WindowIsVisible())
			CW.Channel.SettingsDialog.Close();
	}
}

