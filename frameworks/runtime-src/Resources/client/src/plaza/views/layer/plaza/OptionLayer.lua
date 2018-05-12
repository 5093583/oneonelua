--设置页面
local OptionLayer = class("OptionLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local ModifyPasswordLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ModifyPasswordLayer")
local BindingMobileLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BindingMobileLayer")

local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")

OptionLayer.Enum = 
{
   MUSICSLIDER          = 1,
   VOICESLIDER          = 2,
}

local TAG = OptionLayer.Enum

function OptionLayer:ctor(delegate)
    
    self._delegate = delegate

    local csbNode = ExternalFun.loadCSB("Option/OptionLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --头像
    -- local headSprite = HeadSprite:createClipHead(GlobalUserItem, 120, "sp_avatar_mask_120.png")
    -- headSprite:setPosition(215, 404)
    -- headSprite:addTo(self._content)
    -- headSprite:setVisible(false)

    --昵称
    -- local txtNickName = self._content:getChildByName("txt_nickname")
    -- txtNickName:setString(GlobalUserItem.szNickName)
    -- txtNickName:setVisible(false)

    --绑定手机
    -- self._txtBindMobile = self._content:getChildByName("txt_binding_mobile")
    -- self._txtBindMobile:setVisible(false)

    --背景音乐开关
    local checkBgMusic = self._content:getChildByName("check_bgmusic")
    checkBgMusic:setSelected(GlobalUserItem.bVoiceAble)
    checkBgMusic:addEventListener(function(ref, type)

        --播放音效
        ExternalFun.playClickEffect()

        GlobalUserItem.setVoiceAble(ref:isSelected())

        if ref:isSelected() then
            ExternalFun.playPlazzBackgroudAudio()
        end
    end)

    --游戏音效开关
    local checkGameEffect = self._content:getChildByName("check_gameeffect")
    checkGameEffect:setSelected(GlobalUserItem.bSoundAble)
    checkGameEffect:addEventListener(function(ref, type)

        --播放音效
        ExternalFun.playClickEffect()

        GlobalUserItem.setSoundAble(ref:isSelected())
    end)

    --修改密码
    local btnModifyPwd = self._content:getChildByName("btn_modify_pwd")
    btnModifyPwd:setVisible(false)
    btnModifyPwd:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(ModifyPasswordLayer:create(), false)
    end)

    --切换账号
    local btnSwitchAccount = self._content:getChildByName("btn_switch_account")
    btnSwitchAccount:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        if self._delegate and self._delegate.onSwitchAccount then
            self._delegate:onSwitchAccount()
        end
    end)

    --绑定手机
    self._btnBindMobile = self._content:getChildByName("btn_bind")
    self._btnBindMobile:setVisible(false)
    self._btnBindMobile:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(BindingMobileLayer:create(1), false)
    end)

    --取消绑定手机
    self._btnUnBindMobile = self._content:getChildByName("btn_unbind")
    self._btnUnBindMobile:setVisible(false)
    self._btnUnBindMobile:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(BindingMobileLayer:create(2), false)
    end)

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

--        --播放音效
--        ExternalFun.playClickEffect()
--dismissPopupLayer(self)

   -- print("关闭层")
        
        self:onKeyBack()
    end)

    --musci slider
    self.MusicSlider = self._content:getChildByName("slider_music")
    self.MusicSlider:onEvent(handler(self,OptionLayer.MusicSlideEvent))
    self.MusicSlider:setTag(TAG.MUSICSLIDER)
    -- self.Slider:addTouchEventListener(btcallback)

    --voice slider
    self.VoiceSlider = self._content:getChildByName("slider_voice")
    self.VoiceSlider:onEvent(handler(self,OptionLayer.VoiceSlideEvent))
    self.VoiceSlider:setTag(TAG.VOICESLIDER)

    -- 内容跳入
    AnimationHelper.jumpIn(self._content)
end


function OptionLayer:onKeyBack()
    yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --播放音效
    ExternalFun.playClickEffect()

    dismissPopupLayer(self)
end
------------------------------------------------------------------------------------------------------------
-- 事件处理
--slider 滑动响应
function OptionLayer:MusicSlideEvent(event)
    if event.name == "ON_PERCENTAGE_CHANGED" then
        local percent = event.target:getPercent()
        self.MusicSlider:setPercent(percent)
        local xx = self.MusicSlider:getPercent()
        print("Musicxx",xx)
        GlobalUserItem.setMusicVolume(xx)
        --GlobalUserItem.setEffectsVolume(xx/100.0)
    end
end

function OptionLayer:VoiceSlideEvent(event)
    if event.name == "ON_PERCENTAGE_CHANGED" then
        local percent = event.target:getPercent()
        self.VoiceSlider:setPercent(percent)
        local xx = self.VoiceSlider:getPercent()
        print("Voicexx",xx)
        --GlobalUserItem.setMusicVolume(xx/100.0)
        GlobalUserItem.setEffectsVolume(xx)
    end
end

function OptionLayer:onShow()
    -- --获取绑定手机
    -- if GlobalUserItem.szBindMobile == nil then
    --     RequestManager.getBindMobile(function(result, message)

    --         if appdf.isObject(self) then
    --             self:onUpdateBindingState()
    --         end
    --     end)
    -- else
    --     self:onUpdateBindingState()
    -- end
end

--更新绑定状态
function OptionLayer:onUpdateBindingState()

    if GlobalUserItem.bVisitor then
        self._txtBindMobile:setString("游客无需绑定")
        self._btnBindMobile:setVisible(false)
        self._btnUnBindMobile:setVisible(false)
    elseif GlobalUserItem.szBindMobile == nil or GlobalUserItem.szBindMobile == "" then
        self._txtBindMobile:setString("未绑定")
        self._btnBindMobile:setVisible(true)
        self._btnUnBindMobile:setVisible(false)
    else
        self._txtBindMobile:setString(GlobalUserItem.szBindMobile)
        self._btnBindMobile:setVisible(false)
        self._btnUnBindMobile:setVisible(true)
    end
end

return OptionLayer