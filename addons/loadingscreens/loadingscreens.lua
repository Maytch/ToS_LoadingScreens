-- Get number of images and array of filenames in loadingscreens folder
local url = config.GetLoadingImgURL();
local urlStr = string.format("%s",url);
urlSubStr = string.sub(urlStr, 1, string.len(urlStr) - 20) .. "\\addons\\loadingscreens\\";
urlCnt = 0;
fileNames = {};
local popen = io.popen;
local pfile = popen('dir "' .. urlSubStr .. '" /b');
for fileName in pfile:lines() do
	if fileName ~= "loadingscreens.lua" then
	    urlCnt = urlCnt + 1;
	    fileNames[urlCnt] = fileName;
	end
end
pfile:close();

function LOADING_SCREENS(addon, frame)

	addon:RegisterMsg('START_LOADING', 'DO_RESIZE_BY_CLIENT_SIZE');
	
	if frame == nil then
		return;
	end

	-- FRAME_FULLSCREEN(frame);
	frame:Resize(option.GetClientWidth() ,option.GetClientHeight() );
	
	local pic = GET_CHILD(frame, "pic", "ui::CWebPicture");
	pic:Resize(frame:GetWidth(), frame:GetHeight());

	local urlIndex = OSRandom(1, urlCnt);
	local urlStr = string.format("%s%s", urlSubStr, fileNames[urlIndex]);
	pic:SetUrlInfo(urlStr);

	local tipGroupbox 		= frame:GetChild('tip');
    local tipCtl 			= tipGroupbox:GetChild('gametip');

	local gauge = frame:GetChild("gauge");
	gauge:Resize(frame:GetWidth(), gauge:GetHeight());

	
	local nowjobtype = config.GetConfig("LastJobCtrltype");
	local nowlevel = config.GetConfigInt("LastPCLevel", 0);

	local clsList, cnt  = GetClassList('LoadingText');
	local tipClass  = nil;

	for i = 1, cnt*5 do
	
		tipClass = GetClassByIndexFromList(clsList, OSRandom(0, cnt  - 1));
		if tipClass.MinLv <= nowlevel and tipClass.MaxLv >= nowlevel then
			if tipClass.Job == 'All' or tipClass.Job == nowjobtype then
				break;
			end
		end

	end

	local txt = '{#f0dcaa}{s20}{ol}{gr gradation2}'..ScpArgMsg("Todays_Tip") ..tipClass.Text;
	tipCtl:SetText(txt);
	tipGroupbox:Resize(tipCtl:GetWidth()+40, tipGroupbox:GetHeight());
	

	local faqclsList, faqcnt  = GetClassList('LoadingFAQ');
	local faqClass  = GetClassByIndexFromList(faqclsList, OSRandom(0, faqcnt  - 1));
	local faqtxt = '{#f0dcaa}{s18}{ol}{gr gradation2}'..faqClass.Text;

	local faqCtl 			= GET_CHILD_RECURSIVELY(frame,'gamefaq')
	faqCtl:SetText(faqtxt);
	local faqGroupbox 		= GET_CHILD_RECURSIVELY(frame,'faq')
	faqGroupbox:Resize(faqCtl:GetWidth()+70, faqCtl:GetHeight() + 50);
	
	frame:Invalidate();

end

-- Overwrite the BG Loading function with ours
local eventHook = "LOADINGBG_ON_INIT";
_G[eventHook] = LOADING_SCREENS;

local sysString = string.format("%d Loading Screens loaded!", urlCnt);
ui.SysMsg(sysString);
