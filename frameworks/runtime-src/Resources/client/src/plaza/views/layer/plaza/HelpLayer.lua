--
-- Author: Your Name
-- Date: 2017-11-18 23:15:35
--
local HelpLayer = class("HelpLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local MyQRCodeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.MyQRCodeLayer")

HelpLayer.CUSTOMER = 1
HelpLayer.GAMEINFO = 2
HelpLayer.TUTORIAL = 3

function HelpLayer:ctor(info)

    local csbNode = ExternalFun.loadCSB("Help/HelpLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)
    end)

    self.btn_customer = self._content:getChildByName("btn_customer")
    self.btn_gameInfo = self._content:getChildByName("btn_gameInfo")
    self.btn_tutorial = self._content:getChildByName("btn_tutorial")

    self.customer_node = self._content:getChildByName("customer_node")
    self.gameInfo_node = self._content:getChildByName("gameInfo_node")
    self.tutorial_node = self._content:getChildByName("tutorial_node")


    self.txt_customer_qq = self.customer_node:getChildByName("txt_customer_qq")
    self.txt_customer_phone = self.customer_node:getChildByName("txt_customer_phone")
    self.qrCodeKuang = self.customer_node:getChildByName("qrCodeKuang")

    self.btn_customer:addClickEventListener(function()
            self:updateView(HelpLayer.CUSTOMER)
        end)
    self.btn_gameInfo:addClickEventListener(function()
            self:updateView(HelpLayer.GAMEINFO)
        end)
    self.btn_tutorial:addClickEventListener(function()
            self:updateView(HelpLayer.TUTORIAL)
        end)


    -- --二维码
    -- local btnQrCode = self._content:getChildByName("btn_qrcode")
    -- btnQrCode:addClickEventListener(function()
        
    --     --播放音效
    --     ExternalFun.playClickEffect()

    --     showPopupLayer(MyQRCodeLayer:create(), false, false)
    -- end)

    local qrContent = GlobalUserItem.szWXSpreaderURL or yl.HTTP_URL
	local qrCode = QrNode:createQrNode(qrContent, 200, 5, 1)
    qrCode:setPosition(self.qrCodeKuang:getPosition())
    qrCode:addTo(self.customer_node)

    self:updateView(HelpLayer.CUSTOMER)
    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
end

function HelpLayer:updateView( index )
	self.btn_customer:setEnabled(index ~= HelpLayer.CUSTOMER)
	self.btn_gameInfo:setEnabled(index ~= HelpLayer.GAMEINFO)
	self.btn_tutorial:setEnabled(index ~= HelpLayer.TUTORIAL)

	self.customer_node:setVisible(index == HelpLayer.CUSTOMER)
	self.gameInfo_node:setVisible(index == HelpLayer.GAMEINFO)
	self.tutorial_node:setVisible(index == HelpLayer.TUTORIAL)
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--点击分享
function HelpLayer:onClickShare(platform)
    
    --播放音效
    ExternalFun.playClickEffect()

	local function sharecall( isok )
        if type(isok) == "string" and isok == "true" then
            showToast(nil, "分享完成", 2)
        end
    end

    local url = GlobalUserItem.szSpreaderURL or yl.HTTP_URL

    if platform == yl.ThirdParty.WECHAT or platform == yl.ThirdParty.WECHAT_CIRCLE then
        MultiPlatform:getInstance():shareToTarget(platform, sharecall, yl.SocialShare.title, yl.SocialShare.content, url)
    elseif platform == yl.ThirdParty.SMS then
        local msg = "亲爱的好友，我最近玩了一款超好玩的游戏，玩法超级多，内容超级精彩，快来加入我，和我一起精彩游戏吧！下载地址：" .. url
        MultiPlatform:getInstance():shareToTarget(platform, sharecall, yl.SocialShare.title, msg)
    end
    
end

return HelpLayer