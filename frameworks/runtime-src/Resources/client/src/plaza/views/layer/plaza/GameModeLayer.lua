--
-- Author: Your Name
-- Date: 2017-11-19 22:09:11
--
local GameModeLayer = class("GameModeLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local RoomListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RoomListLayer")
local RoomCreateLayer = appdf.req(appdf.CLIENT_SRC.."privatemode.plaza.src.views.RoomCreateLayer")
local RoomJoinLayer = appdf.req(appdf.CLIENT_SRC.."privatemode.plaza.src.views.RoomJoinLayer")
local RoomRecordLayer = appdf.req(appdf.CLIENT_SRC.."privatemode.plaza.src.views.RoomRecordLayer")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
--local  count  = 1
--创建游戏功能入口界面
function GameModeLayer:ctor(delegate, wKindID)
    print("创建游戏功能入口界面",wKindID)
--    print("aaddfd", count)

    local mask = ccui.Layout:create()
    mask:setName(kMaskLayerName)
    mask:setContentSize(cc.Director:getInstance():getVisibleSize())
    mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    mask:setBackGroundColor(cc.BLACK)
    mask:setBackGroundColorOpacity(153)
    mask:setTouchEnabled(true)
    --mask:addTo(self._scene, self._layerOrder)
    mask:addTo(self)
--    count = count + 1
    self._delegate = delegate
	self.wKindID = wKindID
--    self.test1 = self.wKindID;
    local csbNode = ExternalFun.loadCSB("GameMode/GameModeLayer.csb"):addTo(self)
    self._content = csbNode
--    self.aaaa = 1000

    local title = self._content:getChildByName("Sprite_4")
    title:setTexture("GameMode/img_title_"..wKindID..".png")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()
        --播放音效
--        ExternalFun.playClickEffect()
----        dismissPopupLayer(self)

----print(2522222)
--        self:removeSelf()
self:onKeyBack()
    end)

    self.btn_create = self._content:getChildByName("btn_create")
    self.btn_join = self._content:getChildByName("btn_join")
    self.btn_coin = self._content:getChildByName("btn_coin")
    self.btn_ring = self._content:getChildByName("btn_ring")

    self.btn_create:addClickEventListener(function()
        print("点击创建私人房")            
            ExternalFun.playClickEffect()  --播放按钮音效
            --showPopupLayer(RoomCreateLayer:create(self.wKindID))  --弹出私人房参数界页
            
            self:onClickCreateRoom()
        end)
    self.btn_join:addClickEventListener(function()
		    --播放按钮音效
		    ExternalFun.playClickEffect()
            local backse=RoomJoinLayer:create(self.wKindID)
            yl.ClientScene:addBackFunc(backse)
		    showPopupLayer(backse)
            PriRoom:getInstance():setViewFrame(back)
        end)
    self.btn_coin:addClickEventListener(function()
		    --播放按钮音效
		    ExternalFun.playClickEffect()
            self._roomLayer=RoomListLayer:create(self._delegate, self.wKindID)
            yl.ClientScene:addBackFunc(self._roomLayer)
		    showPopupLayer(self._roomLayer)
        end)

    --比赛场
    self.btn_ring:addClickEventListener(function()
            --播放按钮音效
            ExternalFun.playClickEffect()
            self:updateRoom()
        end)

        --如果是跑得快和百家乐，直接直金币房间列表
        if wKindID == 601 then
            self._roomLayer=RoomListLayer:create(self._delegate, self.wKindID)
            yl.ClientScene:addBackFunc(self._roomLayer)
		    showPopupLayer(self._roomLayer)
        end
    -- 内容跳入
    -- AnimationHelper.jumpIn(self._content)
end
function GameModeLayer:onKeyBack()
    yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --播放音效
    ExternalFun.playClickEffect()
    print("close gametype") 
    self:removeFromParent()
end
function GameModeLayer:updateRoom( )
    --获取房间列表
    local roomList = GlobalUserItem.roomlist[self.wKindID]
    local roomCount = roomList and #roomList or 0
    if roomCount > 4 then
        roomCount = 4
    end
    local isMatch = false
    print("roomCount",roomCount)
    for i=0,roomCount-1 do
        --房间信息
        local roomInfo = roomList[i + 1]
        print("roomInfo.wServerLevel",roomInfo.wServerLevel)
        

        --判断是否是比赛房
        if roomInfo.wServerType == yl.GAME_GENRE_MATCH then
            isMatch = true
            self:onClickRoom(roomInfo.wServerID)
        end
    end

    if isMatch == false then
        print("roomInfo","目前没有擂台赛")
        --QueryDialog:create("功能暂未开通，敬请关注", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
        --showToast(nul,"功能暂未开通，敬请关注",2)
        print("目前没有擂台赛")
        --QueryDialog:create("该功能暂未开通，敬请期待", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
        showToast(self, "该功能暂未开通，敬请期待", 2)
    end
end


--点击房间
function GameModeLayer:onClickRoom(wServerID)
    print("点击房间")
    --播放按钮音效
    ExternalFun.playClickEffect()
    if self._delegate and self._delegate.onClickRoom then
        self._delegate:onClickRoom(wServerID, self.wKindID)
    end
end
--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--点击创建房间
function GameModeLayer:onClickCreateRoom()
print("点击创建房间yes",self.wKindID)
    --播放按钮音效
--    self.aaaa= 999

--    print("1234567899")
    ExternalFun.playClickEffect()
--    self.test1 = self.wKindID;
--    print("点击测试点击测试点击测试点击测试",self.test1,self.wKindID)
    self.m_roomCreateLayer = RoomCreateLayer:create(self.wKindID)
     yl.ClientScene:addBackFunc(self.m_roomCreateLayer)
   self.m_roomCreateLayer:addTo(self)
    --self.m_roomCreateLayer.m_roomList = self
--    showPopupLayer2(self, self.m_roomCreateLayer)

end
return GameModeLayer