local FriendsRoomLayer = class("FriendsRoomLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC .. "plaza.models.ModifyFrame")
local CreateRoomLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.CreateRoomLayer")
local StoreLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.StoreLayer")

function FriendsRoomLayer:ctor()
    
	--网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --节点事件
	ExternalFun.registerNodeEvent(self)

	--加载CSB文件
	local csbNode = ExternalFun.loadCSB("FriendsRoom/FriendsRoomLayer.csb"):addTo(self)

    self.top_node = csbNode:getChildByName ("Top_Node")
    self.join_node = csbNode:getChildByName("Join_Node")
    self.sponsor_node = csbNode:getChildByName("Sponsor_Node")

    --返回按钮
    local btn_back = self.top_node:getChildByName("Back_Btn")
    btn_back:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --
    local btn_add_btc = self.top_node:getChildByName("BTC_Num"):getChildByName("Add_Btn")
    btn_add_btc:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        local backsce = StoreLayer:create()
        showPopupLayer(backsce)
    end)

    local field_room_id = self.join_node:getChildByName("RoomID_Edit")
    local btn_join_room = self.join_node:getChildByName("Goto_Room_Btn")
    btn_join_room:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        showToast(self, "该功能暂未开通，敬请期待", 2)
    end)

    --发起房间
    local btn_sponsor = self.sponsor_node:getChildByName("Sponsor_Btn")
    btn_sponsor:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()
        local backsce = CreateRoomLayer:create()
        showPopupLayer(backsce)
    end)

end

--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function FriendsRoomLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

end

return FriendsRoomLayer