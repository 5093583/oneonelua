local SettingLayer = class("SettingLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

function SettingLayer:ctor(delegate)

    self._delegate = delegate

	--网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --节点事件
	ExternalFun.registerNodeEvent(self)

	--加载CSB文件
	local csbNode = ExternalFun.loadCSB("Setting/SettingLayer.csb"):addTo(self)

    self.avatar_node = csbNode:getChildByName("Avatar_Node")
    self.item_music = csbNode:getChildByName("Item_Music")
    self.item_effect = csbNode:getChildByName("Item_Effect")
    self.item_version = csbNode:getChildByName("Item_Version")
    
    --关闭
    local btn_close = csbNode:getChildByName("Close_Btn")
    btn_close:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --退出帐号
    local btn_exit = csbNode:getChildByName("Exit_Btn")
    btn_exit:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        
        if self._delegate and self._delegate.onSwitchAccount then
            self._delegate:onSwitchAccount()
        end
    end)
    
    --背景音乐开关
    local switch_music = self.item_music:getChildByName("Switch")
    switch_music:addClickEventListener(function()
        if (switch_music:getChildByName("OFF"):isVisible() == false) then
            switch_music:getChildByName("OFF"):setVisible(true)
            switch_music:getChildByName("ON"):setVisible(false)
        else
            --播放音效
            ExternalFun.playClickEffect()
            switch_music:getChildByName("OFF"):setVisible(false)
            switch_music:getChildByName("ON"):setVisible(true)
        end
        local isTrue = switch_music:getChildByName("ON"):isVisible()
        GlobalUserItem.setVoiceAble(isTrue)
        
        if isTrue then
            ExternalFun.playPlazzBackgroudAudio()
        end
    end)
    
    --背景音乐开关
    local switch_effect = self.item_effect:getChildByName("Switch")
    switch_effect:addClickEventListener(function()
        if (switch_effect:getChildByName("OFF"):isVisible() == false) then
            switch_effect:getChildByName("OFF"):setVisible(true)
            switch_effect:getChildByName("ON"):setVisible(false)
        else
            --播放音效
            ExternalFun.playClickEffect()
            switch_effect:getChildByName("OFF"):setVisible(false)
            switch_effect:getChildByName("ON"):setVisible(true)
        end
        local isTrue = switch_effect:getChildByName("ON"):isVisible()
        GlobalUserItem.setSoundAble(isTrue)
    end)
    
    --更新用户信息
    self:onUpdateUserInfo()
end

--更新用户信息
function SettingLayer:onUpdateUserInfo()
    print("设置玩家头像")
    local avatar_frame = self.avatar_node:getChildByName("Avatar_Sp")

    HeadSprite:createClipHead(GlobalUserItem, 96,self)
            :setPosition(avatar_frame:getPosition())
            :setName("sp_avatar")
            :addTo(self.avatar_node, avatar_frame:getLocalZOrder() - 1)
    --end

    --玩家昵称
    local txt_nick = self.avatar_node:getChildByName("Nick_Txt")
    txt_nick:setString(GlobalUserItem.szNickName)

     --游戏ID
     local txt_id = self.avatar_node:getChildByName("ID_Txt")
     txt_id:setString("ID:" .. GlobalUserItem.dwGameID)
     print("================="..GlobalUserItem.dwUserID.."=======================")
end

function SettingLayer:updateVersion(sVersion)
    --版本号
    local txt_version = self.item_version:getChildByName("Version_Num")
    txt_version:setString("v " .. appdf.BASE_C_VERSION .. "." .. (sVersion or appdf.BASE_C_RESVERSION))
end
--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function SettingLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

end

return SettingLayer