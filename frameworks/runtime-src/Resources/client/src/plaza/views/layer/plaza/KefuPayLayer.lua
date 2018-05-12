--人工充值页面
local KefuPayLayer = class("KefuPayLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

function KefuPayLayer:ctor()

    local csbNode = ExternalFun.loadCSB("Pay/KefuPayLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")
    --关闭
    local btnClose = self._content:getChildByName("btn_close")
	self.wx1 = self._content:getChildByName("weixin1")
    self.wx2 = self._content:getChildByName("weixin2")
    local txtwx1=""
    local txtwx2=""
    self.wx1:setString(txtwx1)
    self.wx2:setString(txtwx2)
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)
    local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
     appdf.onHttpJsionTable(url ,"GET","action=GetKeFu",function(jstable,jsdata)

         if type(jstable) ~= "table" then
             return
         end
         local data=jstable["data"];
         self.wx1:setString(data["wx1"])
         self.wx2:setString(data["wx2"])

     end)
      --复制
    local btnCopy1 = self._content:getChildByName("bt_weixin1")
    btnCopy1:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
		local res, msg = MultiPlatform:getInstance():copyToClipboard(self.wx1:getText())
		if true == res then
			showToast(nil, "复制到剪贴板成功!", 2)
		else
			if type(msg) == "string" then
				showToast(nil, msg, 2)
			end
		end
    end)
     local btnCopy2 = self._content:getChildByName("bt_weixin2")
    btnCopy2:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
		local res, msg = MultiPlatform:getInstance():copyToClipboard(self.wx2:getText())
		if true == res then
			showToast(nil, "复制到剪贴板成功!", 2)
		else
			if type(msg) == "string" then
				showToast(nil, msg, 2)
			end
		end
    end)
    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
end


return KefuPayLayer