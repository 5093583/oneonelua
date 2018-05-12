local CreateRoomLayer = class("CreateRoomLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC .. "plaza.models.ModifyFrame")

function CreateRoomLayer:ctor()

    --默认游戏列表
    self._gameLists = {200, 6, 27, 302}
    
    --默认游戏
    self.wKindID = self._gameLists[1]

    --网络处理
    self._modifyFrame = ModifyFrame:create(self, function (result, message)
        self:onModifyCallBack(result, message)
    end)

    --节点事件
    ExternalFun.registerNodeEvent(self)

    --加载CSB文件
    local csbNode = ExternalFun.loadCSB("FriendsRoom/CreateRoomLayer.csb"):addTo (self)

    self.main_node = csbNode:getChildByName("Create_Node")

    --返回按钮
    local btn_colse = self.main_node:getChildByName("Close_Btn")
    btn_colse:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --游戏列表
    self.btn_gameList = {}
    local children = self.main_node:getChildByName("Tab_Btn_Node"):getChildren()
    for i=1, #children do
        if "Button" == children[i]:getDescription() then
            table.insert(self.btn_gameList, children[i])
        end
    end
    
    local function callback(sender)
        --播放音效
	    ExternalFun.playClickEffect()
        
        for i=1, #self.btn_gameList do
            if self.btn_gameList[i] == sender then
                self.btn_gameList[i]:getChildByName("Bg"):setVisible(true)
                self.wKindID = self._gameLists[i]
            else
                self.btn_gameList[i]:getChildByName("Bg"):setVisible(false)
            end
        end
    end

    for i=1, #self.btn_gameList do
        self.btn_gameList[i]:setTag(self._gameLists[i])
                :addClickEventListener(callback)
    end
end

function CreateRoomLayer:updateGameConfig()
    
end

return CreateRoomLayer