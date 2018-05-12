local CreateRoomLayer = class("CreateRoomLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC .. "plaza.models.ModifyFrame")

function CreateRoomLayer:ctor()

    --Ĭ����Ϸ�б�
    self._gameLists = {200, 6, 27, 302}
    
    --Ĭ����Ϸ
    self.wKindID = self._gameLists[1]

    --���紦��
    self._modifyFrame = ModifyFrame:create(self, function (result, message)
        self:onModifyCallBack(result, message)
    end)

    --�ڵ��¼�
    ExternalFun.registerNodeEvent(self)

    --����CSB�ļ�
    local csbNode = ExternalFun.loadCSB("FriendsRoom/CreateRoomLayer.csb"):addTo (self)

    self.main_node = csbNode:getChildByName("Create_Node")

    --���ذ�ť
    local btn_colse = self.main_node:getChildByName("Close_Btn")
    btn_colse:addClickEventListener(function()
        --������Ч
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --��Ϸ�б�
    self.btn_gameList = {}
    local children = self.main_node:getChildByName("Tab_Btn_Node"):getChildren()
    for i=1, #children do
        if "Button" == children[i]:getDescription() then
            table.insert(self.btn_gameList, children[i])
        end
    end
    
    local function callback(sender)
        --������Ч
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