--创建房间界面
local RoomCreateLayer = class("RoomCreateLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")
local RoomLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.room.RoomLayer")
local ShopLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")

--私人房网络框架
local PrivateFrame = appdf.req(appdf.PRIVATE_SRC .. "plaza.src.models.PrivateFrame")

--私人房命令
local cmd_private = appdf.req(appdf.CLIENT_SRC .. "privatemode.header.CMD_Private")
local cmd_pri_game = cmd_private.game

--创建私人房弹窗
function RoomCreateLayer:ctor(wKindID)

    local mask = ccui.Layout:create()
    mask:setName(kMaskLayerName)
    mask:setContentSize(cc.Director:getInstance():getVisibleSize())
    mask:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
    mask:setBackGroundColor(cc.BLACK)
    mask:setBackGroundColorOpacity(153)
    mask:setTouchEnabled(true)
    --mask:addTo(self._scene, self._layerOrder)
    mask:addTo(self)
    print("创建私人房弹窗")
    --保存参数
    self._wKindID = wKindID

    --初始化参数
    self._roomLayer = RoomLayer:getInstance()
    self._roomLayer._roomcreatelayer=self
    --网络处理
    self._privateFrame = PrivateFrame:create(self, wKindID, function(result, message)
        self:onPrivateFrameCallBack(result, message)
    end)

    --事件监听
    self:initEventListener()

    --节点事件
    ExternalFun.registerNodeEvent(self)

    local spritebg9 = ccui.Scale9Sprite:create("RoomList/create_room_bg.png")
    spritebg9:setContentSize(1500, 550)
--    spritebg9:setOpacity(180)
    local contendSize = self:getContentSize()
    spritebg9:setPosition(cc.p(contendSize.width/2, contendSize.height/2))
    spritebg9:addTo(self)

    ccui.Button:create("Welfare/close0.png","Welfare/close1.png")
	:move(contendSize.width - 150, contendSize.height - 80 )
	:addTo(self)
    :setLocalZOrder(1000)
    :setScale(1.2)
	:addClickEventListener(function()
        --播放音效
       -- ExternalFun.playClickEffect()
        --self.m_roomList.m_roomCreateLayer = nil
--        dismissPopupLayer(self)
self:onKeyBack()
    end)

    --获取房间参数
    self._privateFrame:onQueryRoomParam()

    --内容跳入
    AnimationHelper.jumpIn(content)
end
function RoomCreateLayer:onKeyBack()
    yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --播放音效
    print("关闭层")
    ExternalFun.playClickEffect()

    self:removeSelf()
end
--初始化事件监听
function RoomCreateLayer:initEventListener()

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    --用户信息改变事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY, handler(self, self.onUserInfoChange)),
        self
        )

    --私人桌事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create(yl.RY_PERSONAL_TABLE_NOTIFY, handler(self, self.onEventPersonalTable)),
        self
        )
end

------------------------------------------------------------------------------------------------------------
-- 事件处理

function RoomCreateLayer:onExit()
        --重置搜索路径
    local oldPaths = cc.FileUtils:getInstance():getSearchPaths()
    local newPaths = {}
    for k,v in pairs(oldPaths) do
        if tostring(v) ~= tostring(self._priSearchPath) then
            table.insert(newPaths, v)
        else
            print("RoomLayer:removePrivateSearchPath( \"" .. v .. "\" )")
        end
    end
    cc.FileUtils:getInstance():setSearchPaths(newPaths)

    if self._privateFrame:isSocketServer() then
        self._privateFrame:onCloseSocket()
    end
end

--用户信息改变
function RoomCreateLayer:onUserInfoChange(event)
    
    print("----------RoomCreateLayer:onUserInfoChange------------")

	local msgWhat = event.obj
	if nil ~= msgWhat then

        if msgWhat == yl.RY_MSG_USERWEALTH then
		    --更新房卡
		    self:onUpdateRoomCard()
        end
	end
end

--私人桌事件
function RoomCreateLayer:onEventPersonalTable(event)
    
    local cmd = event.cmd
    local data = event.data

    if cmd == cmd_pri_game.SUB_GR_CREATE_SUCCESS then
    
    end
end

--更新房卡信息
function RoomCreateLayer:onUpdateRoomCard()
    
--    self._txtRoomCard:setString(GlobalUserItem.lRoomCard)
end

--创建房间
function RoomCreateLayer:onClickCreate()

    --播放音效
    ExternalFun.playClickEffect()

    if self._detailParamLayer == nil then
        return
    end

    --检查数据有效性
--    local message = self._detailParamLayer:checkDetailParamValues()
--    if type(message) == "string" and message ~= "" then
--        showToast(nil, message, 1)
--        return
--    end

    --查询私人房服务器
    PriRoom:getInstance():getNetFrame():onCreateRoom()
--    self._privateFrame:onQueryGameServer(self._roomParam.cbIsJoinGame)
end

------------------------------------------------------------------------------------------------------------
-- 功能函数

--获取游戏私人房创建层
function RoomCreateLayer:getPriRoomCreateLayer()

    --获取游戏参数
    local gameInfo = MyApp:getInstance():getGameInfo(self._wKindID)
    if gameInfo == nil then
        return nil
    end

    self._priSearchPath = device.writablePath.."game/" .. gameInfo._Module .. "/res/privateroom/";
    cc.FileUtils:getInstance():addSearchPath(self._priSearchPath)

    local PriRoomCreateLayer = appdf.req(appdf.GAME_SRC .. gameInfo._KindName .. "src.privateroom.PriRoomCreateLayer")
    return PriRoomCreateLayer
end

------------------------------------------------------------------------------------------------------------
-- PrivateFrame 回调

function RoomCreateLayer:onPrivateFrameCallBack(result, message)

    dismissPopWait()

    if type(message) == "string" and message ~= "" then
        showToast(nil, message, 2)
    end
end

--获取到房间参数
function RoomCreateLayer:onGetRoomParam(param)

    self._roomParam = param
end

--获取到房间费用参数
function RoomCreateLayer:onGetRoomFeeParam(param)

--    self._activity:stop()

    self._roomFeeParam = param

    local PriRoomCreateLayer = self:getPriRoomCreateLayer()
    if PriRoomCreateLayer == nil then
        return
    end

    self._detailParamLayer = PriRoomCreateLayer:create(self)
    yl.ClientScene:addBackFunc(self._detailParamLayer)
    PriRoom:getInstance():setViewFrame(self._detailParamLayer)
    self._detailParamLayer:addTo(self)




----    GlobalUserItem.tabEnterGame = MyApp:getInstance():getGameInfo(self._wKindID)
----    --创建参数页面
----    self._detailParamLayer = PriRoom:getInstance():getTagLayer(PriRoom.LAYTAG.LAYER_CREATEPRIROOME, nil, self._roomLayer)
--      self._detailParamLayer = PriRoomCreateLayer:create(self)
--      PriRoom:getInstance():setViewFrame(self._detailParamLayer)
----      self._detailParamLayer:setScale(2, 2)
--      self._detailParamLayer.m_rootLayer:setPositionY(-800)
----    self._detailParamLayer = PriRoomCreateLayer:create(self._roomParam, self._roomFeeParam)
--    self._detailParamLayer:setAnchorPoint(0, 1)
----    self._detailParamLayer:setPosition(0, 0)
----    self._detailParamLayer:addTo(self, 100)
--    self._detailParamLayer:addTo(self._scrollView)

--    local scrollViewSize = self._scrollView:getContentSize()
--    local paramLayerSize = self._detailParamLayer:getContentSize()

--    if paramLayerSize.height < scrollViewSize.height then
--        self._detailParamLayer:setPosition(0, scrollViewSize.height)
--        self._scrollView:setInnerContainerSize(scrollViewSize)
--        self._scrollView:setBounceEnabled(false)
--    else
--        self._detailParamLayer:setPosition(0, paramLayerSize.height)
--        self._scrollView:setInnerContainerSize(cc.size(scrollViewSize.width, paramLayerSize.height))
--        self._scrollView:setBounceEnabled(true)
--    end
end

--获取到私人房服务器
function RoomCreateLayer:onGetGameServer(wServerID)

    --登录私人房
    self._roomLayer:logonPrivateRoom(self._wKindID, wServerID, function()

        --创建桌子
        local data = self._detailParamLayer:getCreateTableData()
        self._roomLayer:createTable(data)
    end)
end


function RoomCreateLayer:dismissPopWait()
    dismissPopWait()
end

function RoomCreateLayer:showPopWait()
    showPopWait()
end
--弹出帮助层
function RoomCreateLayer:popHelpLayer( url)
	local IntroduceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.IntroduceLayer")
	local lay = IntroduceLayer:create(self, url)
	lay:setName(HELP_LAYER_NAME)
--	local runScene = cc.Director:getInstance():getRunningScene()
--	if nil ~= runScene then
		self:addChild(lay)
--	end
end

return RoomCreateLayer