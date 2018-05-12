--奖励展示
local RewardShowLayer = class("RewardShowLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

RewardType = 
{
    Gold = 1,
    Bean = 2,
    RoomCard = 3
}

function RewardShowLayer:ctor(rewardtype, rewardcount, closeCallback)

    local csbNode = ExternalFun.loadCSB("RewardShow/RewardShowLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --确定
    local btnOK = self._content:getChildByName("btn_ok")
    btnOK:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        dismissPopupLayer(self)

        if closeCallback then
            closeCallback()
        end

        --发送更新财富通知       
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
		eventListener.obj = yl.RY_MSG_USERWEALTH
		cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
    end)

    --奖励类型
    local txtRewardType = self._content:getChildByName("txt_reward_type")

    if rewardtype == RewardType.Gold then
        self._content:getChildByName("icon_golds"):setVisible(true)
        txtRewardType:setString("游戏币")
    elseif rewardtype == RewardType.Bean then
        self._content:getChildByName("icon_beans"):setVisible(true)
        txtRewardType:setString("游戏豆")
    elseif rewardtype == RewardType.RoomCard then
        self._content:getChildByName("icon_roomcard"):setVisible(true)
        txtRewardType:setString("房卡")
    end

    --奖励数量
    local txtReward = self._content:getChildByName("txt_reward")
    txtReward:setString("+" .. rewardcount)

    --光线
    local spGuangXian = self._content:getChildByName("sp_guangxian")
    spGuangXian:runAction(cc.RepeatForever:create(cc.RotateBy:create(6.0, 360)))

    btnOK:setVisible(false)
    btnOK:runAction(cc.Sequence:create(
                        cc.DelayTime:create(0.5), 
                        cc.CallFunc:create(function()
                            btnOK:setVisible(true)
                            AnimationHelper.jumpIn(btnOK)
                        end)
                        )
                    )

    self._content:setScale(0.9)
    self._content:runAction(cc.EaseSineOut:create(cc.ScaleTo:create(0.2, 1.0)))

    --播放音效
    ExternalFun.playPlazaEffect("GetGoods.mp3")
end

return RewardShowLayer