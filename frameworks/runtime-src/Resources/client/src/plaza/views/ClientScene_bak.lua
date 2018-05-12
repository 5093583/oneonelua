--[[
	手游大厅界面
	2015_12_03 C.P
]]

-- 场景声明
local ClientScene = class("ClientScene", cc.load("mvc").ViewBase)

-- 导入功能
if not yl then
	appdf.req(appdf.CLIENT_SRC.."plaza.models.yl")
end
if not GlobalUserItem then
	appdf.req(appdf.CLIENT_SRC.."plaza.models.GlobalUserItem")
end

local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local PopWait = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.PopWait")

local CheckinFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.CheckinFrame")
local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local RankingListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RankingListLayer")
local GameListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.GameListLayer")
local RoomListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.RoomListLayer")
local RoomLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.room.RoomLayer")
local FriendLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.friend.FriendLayer")
local PersonalInfoLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.PersonalInfoLayer")
local HelpLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.HelpLayer")
local GameModeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.GameModeLayer")
local UserInfoLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.UserInfoLayer")
local LogonRewardLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.LogonRewardLayer")
local WelfareLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.WelfareLayer")
local NoticeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.NoticeLayer")
local ShopLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")
local OptionLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.OptionLayer")
local BankLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankLayer")
local BankEnableLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankEnableLayer")
local MySpreaderLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.MySpreaderLayer")
local CustomerServiceLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.CustomerServiceLayer")
local ActivityLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ActivityLayer")
local DepositLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.DepositLayer")
local OperateLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.OperateLayer")
local PopularizeLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.PopularizeLayer")
local RoomRecordLayer = appdf.req(appdf.CLIENT_SRC.."privatemode.plaza.src.views.RoomRecordLayer")
--Z序表
local ZORDER = 
{
    ROOM_LIST                               = 8,
    ROOM                                    = 9,
    GAME_LIST                               = 10,
    TRUMPET                                 = 11,
    RANK_LIST                               = 20,
    CATEGORY_LIST                           = 30,
    TOP_BAR                                 = 40,
    BOTTOM_BAR                              = 50,
    POPUP_INFO                              = 100000
}

--层标签表
local LayerTag = 
{
    GAME_LIST                               = 0,
    ROOM_LIST                               = 1,
    ROOM                                    = 2,
}

ClientScene.instance = nil
function ClientScene:getInstance()
    return ClientScene.instance
end
--push层标签
function ClientScene:pushLayerTag(layerTag)

    self._layerTagList[#self._layerTagList + 1] = layerTag

    return layerTag
end

--pop层标签
function ClientScene:popLayerTag()
    
    local layerTag = self._layerTagList[#self._layerTagList]

    if nil ~= layerTag then
        self._layerTagList[#self._layerTagList] = nil
    end

    return layerTag
end

--获取当前层标签
function ClientScene:getCurrentLayerTag()

    return self._layerTagList[#self._layerTagList]
end

-- 初始化界面
function ClientScene:onCreate()

    --缓存公共资源
    self:cachePublicRes()

    -- 初始化游戏列表
    -- self._gameLists = {
    --     { 510, 200, 6},
    --     { 510, 200, 102, 27, 25, 6, 389 },
    --     { 510, 507, 511 },
    --     { 123, 104, 122, 140, 118 }
    -- }
    self._gameLists = {
        200,6,27,302,
    }
	GlobalUserItem.m_tabEnterGame = nil
    ClientScene.instance=self;
    --层标签列表
    self._layerTagList = {}

    --事件监听
    self:initEventListener()

    --节点事件
    ExternalFun.registerNodeEvent(self)

	--加载csb资源
    --local rootLayer, ocsbNode = ExternalFun.loadRootCSB( "plaza/PlazaLayer.csb", self )
	local rootLayer, csbNode = ExternalFun.loadRootCSB( "plaza/PlazaLayer1.csb", self )
   
    local timeline = ExternalFun.loadTimeLine( "plaza/PlazaLayer1.csb" )
    -- local areaToBotp = csbNode:getChildByName("area_top"):setLocalZOrder(ZORDER.TOP_BAR)
    -- local areatom = csbNode:getChildByName("area_bottom"):setLocalZOrder(ZORDER.BOTTOM_BAR)
    -- local areaRank = csbNode:getChildByName("area_rank"):setLocalZOrder(ZORDER.RANK_LIST)
    -- local areaCategory = csbNode:getChildByName("area_category"):setLocalZOrder(ZORDER.CATEGORY_LIST)
    local areaTrumpet = csbNode:getChildByName("area_trumpet"):setLocalZOrder(ZORDER.TRUMPET)

    self._layout = csbNode
    -- self._areaTop = areaTop
    -- self._areaBottom = areaBottom
    -- self._areaRank = areaRank
    -- self._areaCategory = areaCategory
    self._areaTrumpet = areaTrumpet
	self.m_touchFilter = PopWait:create()
			:show(self,"请稍候！")
	-- 定时关闭
	self.m_touchFilter:runAction(cc.Sequence:create(cc.DelayTime:create(1), 
													cc.CallFunc:create(function()
														if nil ~= self.m_touchFilter then
															self.m_touchFilter:dismiss()
															self.m_touchFilter = nil
														end														

														-- 网络断开
														self:disconnectFrame()
													end)
													)
								)	    self._isAgent = false

    self.top_node = csbNode:getChildByName("top_node")
    self.scrollView = csbNode:getChildByName("scrollView")
    self.avatar_node = self.top_node:getChildByName("avatar_node")
    self.bottom_node = csbNode:getChildByName("bottom_node")
    --播放时间轴动画
    csbNode:runAction(timeline)
    timeline:gotoFrameAndPlay(0, true)
    self._txtTrumpet = areaTrumpet:getChildByName("panel_trumpet"):getChildByName("txt_trumpet")
    self._txtTrumpet:setString("")
    --游戏列表
    self._gameListLayer = GameListLayer:create(self)
                                                :setContentSize(appdf.WIDTH, 512)
                                                :setPosition(appdf.WIDTH / 2, appdf.HEIGHT / 2)
                        --                      :setBackGroundColorType(LAYOUT_COLOR_SOLID)
                        --                      :setBackGroundColor(cc.BLACK)
                        --                      :setBackGroundColorOpacity(50)
                                                :setAnchorPoint(cc.p(0.5, 0.5))
                                                :addTo(self._layout, ZORDER.GAME_LIST)
												
	setbackgroundcallback(function (bEnter)
		if type(self.onBackgroundCallBack) == "function" then
			self:onBackgroundCallBack(bEnter)
		end
	end)
    --更新游戏列表
    self._gameListLayer:updateGameList(self._gameLists)

    --头像按钮
    local btnAvatar = self.avatar_node:getChildByName("btn_avatar")
    btnAvatar:addClickEventListener(function()
        
        self:onClickAvatar()
    end)

    --绑定按钮
    self.sp_binded = self.top_node:getChildByName("sp_binded")
    self.sp_binded:setVisible(false)
    self.top_node:getChildByName("btn_bind"):addClickEventListener(function()
            --播放音效
        ExternalFun.playClickEffect()
        local backse=MySpreaderLayer:create()
        self:addBackFunc(backse)
        showPopupLayer(backse, false)
    end)

    --购买金币按钮
    self.top_node:getChildByName("sp_coin"):getChildByName("btn_add_coin"):addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()

        local ostime = os.time()
	    local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	    appdf.onHttpJsionTable(url ,"GET","action=getdepositinfo&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
            if type(sjstable) == "table" then
                local data = sjstable["data"]
                if type(data) == "table" then
                    local valid = data["valid"]
                    if true == valid then
                        if data["data"]["WXAccounts"] == "" or data["data"]["BankName"] == "" or data["data"]["BankAccounts"] == "" then
                            QueryDialog:create("请先完善您的个人信息", function()
                                local backse=PersonalInfoLayer:create()
                                self:addBackFunc(backse)
                                showPopupLayer(backse)
                            end, nil, QueryDialog.QUERY_SURE):addTo(self)
                        else
                            
                            local backse=OperateLayer:create(self)
                            self:addBackFunc(backse)
                            showPopupLayer(backse)
                        end
                        return
                    end
                end
            end

            QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
        end)


        
        --ShopLayer:create(2):addTo(self)
    end)

    --购买房卡按钮
    self.top_node:getChildByName("sp_roonCard"):getChildByName("btn_add_roomCard"):addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
         local backsce=ShopLayer:create(3):addTo(self)
            -- 保存 哪个 层
         self:addBackFunc(backsce)
        
    end)

    --设置按钮
    self.bottom_node:getChildByName("btn_setting"):addClickEventListener(function()
        --播放音效
        print("设置按钮")
        ExternalFun.playClickEffect()
        local backsce=OptionLayer:create(self)
        self:addBackFunc(backsce)
        showPopupLayer(backsce)
    end)

    --帮助按钮
    self.bottom_node:getChildByName("btn_help"):addClickEventListener(function()
         print("帮助按钮")
        --播放音效
        ExternalFun.playClickEffect()
        local backsce=PopularizeLayer:create()
        self:addBackFunc(backsce)
        --CustomerServiceLayer:create():addTo(self)
        showPopupLayer(backsce)
    end)

    --战绩按钮
    self.bottom_node:getChildByName("btn_record"):addClickEventListener(function()
        print("战绩按钮")
        --播放音效
        ExternalFun.playClickEffect()

        --showToast(self, "该功能暂未开通，敬请期待", 2)

        local backsce=RoomRecordLayer:create()
        self:addBackFunc(backsce)
        showPopupLayer(backsce)
    end)

    --好友按钮
    self.bottom_node:getChildByName("btn_friends"):addClickEventListener(function()
        --播放音效
        print("好友按钮")
        ExternalFun.playClickEffect()
		self._isAgent = true 
		self:showDepositLayer() 
        -- 查询当前用户是否为代理,代理才可以打开提现的界面
        --local ostime = os.time()
	    --local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	    --appdf.onHttpJsionTable(url ,"GET","action=IsAgent&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        -- 
        --    if type(sjstable) == "table" then
        --        local data = sjstable["data"]
        --        if type(data) == "table" then
        --            local valid = data["valid"]
        --           if true == valid then
        --                local msg = sjstable["msg"]
        --                   --showPopupLayer(DepositLayer:create(self))  
        --                   self._isAgent = true                                
        --                   return    
        --            end
        --        end
        --    end
        --   QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
        --end)

        -- QueryDialog:create("功能暂未开放，请持续关注游戏动态！", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
    end)

    --公告按钮
    self.bottom_node:getChildByName("btn_notice"):addClickEventListener(function()
        print("公告按钮")
        --播放音效
        ExternalFun.playClickEffect()
        local backsce=NoticeLayer:create()
        self:addBackFunc(backsce)
        showPopupLayer(backsce)
    end)

    --商城按钮
    self.bottom_node:getChildByName("btn_shop"):addClickEventListener(function()

            --播放音效
            ExternalFun.playClickEffect()

            local a = ShopLayer:create():addTo(self)
            -- 保存 哪个 层
            self:addBackFunc(a)
    end)

    -- --游戏列表
    -- self._gameListLayer = GameListLayer:create(self)
    --                                             :setContentSize(908 + (yl.APPSTORE_VERSION and self._areaCategory:getContentSize().width or 0), 512)
    --                                             :setPosition(325, 97)
    --                     --                      :setBackGroundColorType(LAYOUT_COLOR_SOLID)
    --                     --                      :setBackGroundColor(cc.BLACK)
    --                     --                      :setBackGroundColorOpacity(50)
    --                                             :addTo(self._layout, ZORDER.GAME_LIST)
    -- --房间列表
--    self._roomListLayer = GameModeLayer:create(self)
--                                             :setVisible(false)
--                                             :addTo(self._layout, ZORDER.GAME_LIST)

    --房间
    self._roomLayer = RoomLayer:create(self):setVisible(false)
                                        :addTo(self._layout, ZORDER.ROOM)


    -- --游戏分类按钮
    -- self._gameCategoryBtns = {}
    -- for i = 1, 4 do
    --     local btnGameCategory = areaCategory:getChildByName("btn_category_" .. i)
    --     btnGameCategory:addEventListener(function(ref, type)
    --         self:onClickGameCategory(i, true)
    --     end)

    --     self._gameCategoryBtns[i] = btnGameCategory
    -- end


    -- --保存初始坐标(动画用)
    -- self._ptAreaRank = cc.p(self._areaRank:getPosition())
    -- self._ptAreaCategory = cc.p(self._areaCategory:getPosition())
    -- self._ptGameListLayer = cc.p(self._gameListLayer:getPosition())

    --更新用户信息
    self:onUpdateUserInfo()

    --更新在线人数
    self:onUpdateOnlineCount()

    --初始化游戏列表
    self:onClickGameCategory(1)

    --查询滚动公告
    self:requestRollNotice()

    --查询签到信息
    self:requestCheckinInfo()

    --查询活动状态
    --self:requestQueryActivityStatus()
   --返回键began
    self._layerRecord = {} -- 这是记录的一个表

	self._sceneLayer = display.newLayer()
		:setContentSize(yl.WIDTH,yl.HEIGHT)
		:addTo(self)	
    this = self
	--返回键事件
	self._sceneLayer:registerScriptKeypadHandler(function(event)
		if event == "backClicked" then  
			 if this._popWait == nil then
			 	if #self._layerRecord > 0 then
					local layer = self._layerRecord[#self._layerRecord]
					if layer and layer.onKeyBack then
					    layer:onKeyBack() 
                        return
					end
				end
                if this.onKeyBack then
				    this:onKeyBack()
                end
			end
		end
	end)
	self._sceneLayer:setKeyboardEnabled(true)
    yl.ClientScene = self

    --返回键end

end

-- 添加  你打开的 哪个 层
function ClientScene:addBackFunc(layer)

    table.insert(self._layerRecord, layer)
    print("add "..#self._layerRecord )
end

-- 移除  
function ClientScene:removeBackFunc(layer)
    if self._layerRecord~=nil and layer~=nil then
        for i, v in pairs(self._layerRecord) do
            if layer == v then
                table.remove(self._layerRecord, i)
            end
        end
    end
end

function ClientScene:onKeyBack()
    --yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --print("关闭层")
    --播放音效
    --ExternalFun.playClickEffect()

    --self:removeFromParent()
end
function ClientScene:onBackgroundCallBack(bEnter)
	if not bEnter then
		print("onBackgroundCallBack not bEnter")
		local curScene = self._layerRecord[#self._layerRecord]
		if  nil ~= self._gameView then
			--离开游戏
			--local gamelayer = self._gameView
			--print("切到后台")
			--if gamelayer and gamelayer.onExitTable then
			--	gamelayer:onExitTable()
			--end
		end
		if curScene == yl.SCENE_ROOM then
			self:onKeyBack()
		end

		if nil ~= self._gameFrame and self._gameFrame:isSocketServer() and GlobalUserItem.bAutoConnect then			
			self._gameFrame:onCloseSocket()
		end

		self:disconnectFrame()

		self:dismissPopWait()


	else
		print("onBackgroundCallBack  bEnter")
		--if #self._layerRecord > 0 then
		--	local curScene = self._layerRecord[#self._layerRecord]
		--	if curScene == yl.SCENE_GAME then				
		--		if self._gameFrame:isSocketServer() == false and GlobalUserItem.bAutoConnect then
		--			self._gameFrame:OnResetGameEngine()
		--			self:onStartGame()
		--		end
		--	end
		--end
		if  nil ~= self._gameView then
			if self._gameFrame:isSocketServer() == false and GlobalUserItem.bAutoConnect then
			print("OnResetGameEngine")
					self._gameFrame:OnResetGameEngine()
					self:onStartGame()
				end
		end
		--查询财富
		if GlobalUserItem.bJftPay then
			--通知查询     
            local eventListener = cc.EventCustom:new(yl.RY_JFTPAY_NOTIFY)
            cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
		end
	end
end

function ClientScene:popTargetShare( callback, bNotInsideFriend ,game)
	bNotInsideFriend = bNotInsideFriend or false
	local TargetShareLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TargetShareLayer")
	local lay = TargetShareLayer:create(callback, bNotInsideFriend)
    lay:setLocalZOrder(yl.ZORDER.Z_TARGET_SHARE + 100)
	if game~=nil then
    print("房间内分享弹出界面")
    game:addChild(lay)
    else self:addChild(lay)
    end
	--lay:setLocalZOrder(yl.ZORDER.Z_TARGET_SHARE + 1000000)
end
--初始化事件监听
function ClientScene:initEventListener()

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    --用户信息改变事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY, handler(self, self.onUserInfoChange)),
        self
        )
       
end


    



--初始化事件监听
function ClientScene:showDepositLayer()

    if self._isAgent == true then
        local backsce=DepositLayer:create(self)
        self:addBackFunc(backsce)
        showPopupLayer(backsce)
    end
end

------------------------------------------------------------------------------------------------------------
-- 事件处理
local GameFrameEngine = appdf.req(appdf.CLIENT_SRC.."plaza.models.GameFrameEngine")
--场景切换完毕
function ClientScene:onEnterTransitionFinish()
    PriRoom:getInstance():onEnterPlaza(self, GameFrameEngine:getInstance())
end

--用户信息改变
function ClientScene:onUserInfoChange(event)
    
    print("----------ClientScene:onUserInfoChange------------")

	local msgWhat = event.obj
	if nil ~= msgWhat then

        if msgWhat == yl.RY_MSG_USERWEALTH then
		    --更新财富
		    self:onUpdateScoreInfo()
			print("----------ClientScene:onUpdateScoreInfo------------")
        elseif msgWhat == yl.RY_MSG_USERHEAD then
            --更新用户信息
			print("----------ClientScene:onUpdateUserInfo------------")
            self:onUpdateUserInfo()
        end
	end
end
--更新用户信息
function ClientScene:onUpdateUserInfo(flg)
    print("设置玩家头像")
    --设置玩家头像
    --if nil ~= avatar and nil ==flg then
    --    avatar:updateHead(GlobalUserItem)--:setPosition(avatarFrame:getPosition())
    --else
        local avatarFrame = self.avatar_node:getChildByName("sp_avatar_frame")

        HeadSprite:createClipHead(GlobalUserItem, 96,self)
              :setPosition(avatarFrame:getPosition())
              :setName("sp_avatar")
              :addTo(self.avatar_node, avatarFrame:getLocalZOrder() - 1)
    --end

    --玩家昵称
    local txtNickName = self.top_node:getChildByName("txt_nickname")
    txtNickName:setString(GlobalUserItem.szNickName)

    --游戏ID
    local txtGameID = self.top_node:getChildByName("txt_gameid")
    txtGameID:setString(GlobalUserItem.dwGameID)
    print("================="..GlobalUserItem.dwUserID.."=======================")

    --更新分数
    self:onUpdateScoreInfo()
end

--更新分数信息
function ClientScene:onUpdateScoreInfo()
-- ExternalFun.numberThousands()
    --游戏币
    local txt_coin = self.top_node:getChildByName("sp_coin"):getChildByName("txt_coin")
    txt_coin:setString(GlobalUserItem.lUserScore)

    --游戏豆
    local txt_roomCard = self.top_node:getChildByName("sp_roonCard"):getChildByName("txt_roomCard")
    txt_roomCard:setString(GlobalUserItem.lRoomCard)
end

--更新在线人数
function ClientScene:onUpdateOnlineCount()

    -- local onlineCount = GlobalUserItem.getRealOnlineCount()
    -- onlineCount = onlineCount + GlobalUserItem.OnlineBaseCount + math.random(0, 50)

    -- --在线人数
    -- local txtOnlineCount = self._areaRank:getChildByName("area_online_count"):getChildByName("txt_online_count")
    -- txtOnlineCount:setString("在线人数：" .. onlineCount)
end

--点击排行榜分类
function ClientScene:onClickRankCategory(index)
    
    -- --播放按钮音效
    -- ExternalFun.playClickEffect()

    -- for i = 1, #self._rankCategoryBtns do
    --     self._rankCategoryBtns[i]:setSelected(index == i)
    -- end

    -- --防止重复执行
    -- if index == self._rankCategoryIndex then
    --     return
    -- end
    -- self._rankCategoryIndex = index

    -- print("切换排行分类", index)

    -- --加载排行榜
    -- self._rankListLayer:loadRankingList(index)
end

--点击游戏分类
function ClientScene:onClickGameCategory(index, enableSound)
    
    --播放按钮音效
    if enableSound then
        ExternalFun.playClickEffect()
    end

    -- for i = 1, #self._gameCategoryBtns do
    --     self._gameCategoryBtns[i]:setSelected(index == i)
    -- end

    --防止重复执行
    if index == self._gameCategoryIndex then
        return
    end
    self._gameCategoryIndex = index

    print("切换游戏分类", index)

    -- --更新游戏列表
    -- self._gameListLayer:updateGameList(self._gameLists[index])

--    --切换动画
--    self._gameListLayer:stopAllActions()
--    self._gameListLayer:setPosition(cc.p(325 + 454, 97))
--    self._gameListLayer:runAction(cc.EaseSineInOut:create(cc.MoveTo:create(0.3, cc.p(325, 97))))
  
--    --3D翻转动画
--    local scheduler = cc.Director:getInstance():getScheduler()

--    if (self._schedualId) then
--        scheduler:unscheduleScriptEntry(self._schedualId)
--        self._schedualId = 0
--    end

--    self._rotation3D = -45
--    self._rotationAlpha = 0
--    self._schedualId = scheduler:scheduleScriptFunc(function()

--        if self._rotation3D >= 0 then
--            scheduler:unscheduleScriptEntry(self._schedualId)
--            self._schedualId = 0
--            self._rotation3D = 0
--            self._rotationAlpha = 255
--        end

--        self._gameListLayer:setRotation3D(cc.vec3(self._rotation3D, 0, 0));
--        self._gameListLayer:setOpacity(self._rotationAlpha)
--        self._rotation3D = self._rotation3D + 2
--        self._rotationAlpha = (self._rotation3D + 45) * 255 / 45
--    end, 0, false)
    
end

--点击头像
function ClientScene:onClickAvatar()

    --播放按钮音效
    ExternalFun:playClickEffect()
    local backse=PersonalInfoLayer:create()
    self:addBackFunc(backse)
    --显示个人信息
    showPopupLayer(backse)
end

--点击返回
function ClientScene:onClickBack()

    --播放按钮音效
    ExternalFun:playClickEffect()

    local currentLayerTag = self:getCurrentLayerTag()

    --房间列表返回
    if currentLayerTag == LayerTag.ROOM_LIST then

        -- --防止重复执行
        -- if self._gameListLayer:getNumberOfRunningActions() > 0 then
        --     return
        -- end

        -- --内部还有层级没返回
        -- if self._roomListLayer:onKeyBack() == false then
        --     return
        -- end

        -- --隐藏返回按钮
        -- self._btnBack:setVisible(false)

        --显示喇叭
        -- self._areaTrumpet:setVisible(true)

        --停止动画
        -- self._areaRank:stopAllActions()
        -- self._areaCategory:stopAllActions()
        -- self._gameListLayer:stopAllActions()
        -- self._roomListLayer:stopAllActions()

        --执行动画
        -- AnimationHelper.jumpInTo(self._areaRank, 0.4, cc.p(self._ptAreaRank.x, self._ptAreaRank.y), 6, 0)
        -- AnimationHelper.jumpInTo(self._areaCategory, 0.4, cc.p(self._ptAreaCategory.x, self._ptAreaCategory.y), -6, 0)
        -- AnimationHelper.jumpInTo(self._gameListLayer, 0.4, cc.p(self._ptGameListLayer.x, self._ptGameListLayer.y), -6, 0)

        -- AnimationHelper.moveOutTo(self._roomListLayer, 0.2, cc.p(0, -100))
        -- AnimationHelper.alphaOutTo(self._roomListLayer, 0.2, 0, function() self._roomListLayer:setVisible(false) end)

        --移除层
        self:popLayerTag()

    --房间返回
    elseif currentLayerTag == LayerTag.ROOM then
        
        --关闭房间
        -- self._roomLayer:closeRoom()
    end
end

------------------------------------------------------------------------------------------------------------
-- RankingListLayer 回调

--点击排行榜用户
function ClientScene:onClickRankUserItem(userItem)
    
    --播放按钮音效
    ExternalFun:playClickEffect()

    showPopupLayer(UserInfoLayer:create(userItem))
end

------------------------------------------------------------------------------------------------------------
-- GameListLayer 回调

--点击游戏
function ClientScene:onClickGame(wKindID)
	
	print("点击游戏",wKindID)
    -- --防止重复执行
    -- if self._gameListLayer:getNumberOfRunningActions() > 0 then
    --     return
    -- end

    -- --显示返回按钮
    -- self._btnBack:setVisible(true)

    -- --隐藏喇叭
    -- self._areaTrumpet:setVisible(false)

    -- --重置状态
    -- self._areaRank:setPosition(self._ptAreaRank):stopAllActions()
    -- self._areaCategory:setPosition(self._ptAreaCategory):stopAllActions()
    -- self._gameListLayer:setPosition(self._ptGameListLayer):stopAllActions()
    -- self._roomListLayer:setPosition(0, -100):setOpacity(0):setVisible(true):stopAllActions()

    -- --执行动画
    -- AnimationHelper.moveOutTo(self._areaRank, 0.4, cc.p(self._ptAreaRank.x - 500, self._ptAreaRank.y))
    -- AnimationHelper.moveOutTo(self._areaCategory, 0.4, cc.p(self._ptAreaCategory.x + 1200, self._ptAreaCategory.y))
    -- AnimationHelper.moveOutTo(self._gameListLayer, 0.4, cc.p(self._ptGameListLayer.x + 1200, self._ptGameListLayer.y))

    -- AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
    -- AnimationHelper.alphaInTo(self._roomListLayer, 0.3, 255)

    --保存游戏信息（私人房查询需要)
    GlobalUserItem.nCurGameKind = wKindID

    -- local isPriModeGame = MyApp:getInstance():isPrivateModeGame(wKindID)
    -- isPriModeGame = false
    -- if isPriModeGame then
    --     --显示房间分类
    --     self._roomListLayer:showRoomCategory(wKindID)
    -- else
    --     --显示房间列表
    --     self._roomListLayer:showRoomList(wKindID)
    -- end

    --保存层
    -- self:pushLayerTag(LayerTag.ROOM_LIST)
    self._roomListLayer = GameModeLayer:create(self, wKindID)
    yl.ClientScene:addBackFunc(_roomListLayer)
    self._roomListLayer:registerScriptKeypadHandler(function(event)
		if event == "backClicked" then  
        print("返回键")
			 if this._popWait == nil then
			 	if #yl.ClientScene._layerRecord > 0 then
					local layer = yl.ClientScene._layerRecord[#yl.ClientScene._layerRecord]
					if layer and layer.onKeyBack then
                    print("layer返回")
					    layer:onKeyBack() 
                         
                        return
					end
				end
                if this.onKeyBack then
                 print("cline返回")
				    self._roomListLayer:onKeyBack()
                    
                end
			end
		end
	end)
	self._roomListLayer:setKeyboardEnabled(true)
--    showPopupLayer(   self._roomListLayer)
    if wKindID==122 then
        self._roomListLayer:onKeyBack()
            local tmproomLayer=RoomListLayer:create(self._roomListLayer._delegate, wKindID)
            yl.ClientScene:addBackFunc(tmproomLayer)
		    --showPopupLayer(tmproomLayer)
    
    else 
    self._roomListLayer:addTo(self)
    end
end

------------------------------------------------------------------------------------------------------------
-- RoomListLayer 回调

--点击房间
function ClientScene:onClickRoom(wServerID, wKindID)
    print("ClientScene:onClickRoom()")
    --登录房间
    self._roomLayer:logonRoom(wKindID, wServerID)
end

------------------------------------------------------------------------------------------------------------
-- RoomLayer 回调

--进入房间
function ClientScene:onEnterRoom()
    
    print("ClientScene:onEnterRoom()")

    -- --显示房间
    print("显示房间")
    self._roomLayer:setVisible(true)

    -- --隐藏房间列表
    -- self._roomListLayer:setVisible(false)

    --保存层
    self:pushLayerTag(LayerTag.ROOM)
end

--离开房间
function ClientScene:onExitRoom(code, message)

    print("ClientScene:onExitRoom(code = " .. tostring(code) .. ")")

    --显示错误提示
    if type(message) == "string" and message ~= "" then
        print("错误信息："..message)
        --showToast(nil, message, 2)
        if self._roomListLayer._roomLayer==nil then
        QueryDialog:create(message, nil, nil, QueryDialog.QUERY_SURE):addTo(self._roomListLayer.m_roomCreateLayer)
        
        else 
        QueryDialog:create(message, nil, nil, QueryDialog.QUERY_SURE):addTo(self._roomListLayer._roomLayer)
        end
    end

    --隐藏房间
    self._roomLayer:setVisible(false)

    -- --显示房间列表
    -- if code == -1 then
    --     --显示房间列表
    --     self._roomListLayer:setVisible(true)
    -- else
    --     --动画显示房间列表
    --     self._roomListLayer:setPosition(0, -100):setOpacity(0):setVisible(true):stopAllActions()

    --     AnimationHelper.jumpInTo(self._roomListLayer, 0.4, cc.p(0, 0), 0, 6)
    --     AnimationHelper.alphaInTo(self._roomListLayer, 0.3, 255)
    -- end

    --移除层
    if self:getCurrentLayerTag() == LayerTag.ROOM then
        self:popLayerTag()
    end

    --更新积分
    self:onUpdateScoreInfo()

    --更新在线人数
    -- self:onUpdateOnlineCount()

    --移除没使用的纹理
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

--离开桌子
function ClientScene:onExitTable()

    --更新积分
    self:onUpdateScoreInfo()
end

------------------------------------------------------------------------------------------------------------
-- OptionLayer 回调

--切换账号
function ClientScene:onSwitchAccount()

    --关闭房间
    if self._roomLayer:isEnterRoom() then
        self._roomLayer:closeRoom()
    end

    self:getApp():enterSceneEx(appdf.CLIENT_SRC.."plaza.views.LogonScene","FADE",1)

	GlobalUserItem.reSetData()
	--读取配置
	GlobalUserItem.LoadData()
end

------------------------------------------------------------------------------------------------------------
-- 辅助功能

--缓存公共资源
function ClientScene:cachePublicRes(  )
	cc.SpriteFrameCache:getInstance():addSpriteFrames("public/public.plist")
	local dict = cc.FileUtils:getInstance():getValueMapFromFile("public/public.plist")

	local framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame then
				frame:retain()
			end
		end
	end

	cc.SpriteFrameCache:getInstance():addSpriteFrames("plaza/plaza.plist")	
	dict = cc.FileUtils:getInstance():getValueMapFromFile("plaza/plaza.plist")
	framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame then
				frame:retain()
			end
		end
	end
end

--释放公共资源
function ClientScene:releasePublicRes(  )
	local dict = cc.FileUtils:getInstance():getValueMapFromFile("public/public.plist")
	local framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame and frame:getReferenceCount() > 0 then
				frame:release()
			end
		end
	end

	dict = cc.FileUtils:getInstance():getValueMapFromFile("plaza/plaza.plist")
	framesDict = dict["frames"]
	if nil ~= framesDict and type(framesDict) == "table" then
		for k,v in pairs(framesDict) do
			local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(k)
			if nil ~= frame and frame:getReferenceCount() > 0 then
				frame:release()
			end
		end
	end
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("public/public.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("public/public.png")
	cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("plaza/plaza.plist")
	cc.Director:getInstance():getTextureCache():removeTextureForKey("plaza/plaza.png")
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
end

------------------------------------------------------------------------------------------------------------
-- 网络请求

--获取滚动公告
function ClientScene:requestRollNotice()

     local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
     appdf.onHttpJsionTable(url ,"GET","action=getmobilerollnotice",function(jstable,jsdata)

         if type(jstable) ~= "table" then
             return
         end

         local data = jstable["data"]
         if type(data) ~= "table" then
             return
         end

         local notice = data["notice"]
         if type(notice) ~= "table" then
             return
         end

         --把滚动公告拼接到一起
         local contents = ""
         for i = 1, #notice do

             if i == 1 then
                 contents = notice[i].content
             else
                 contents = contents .. "          " .. notice[i].content
             end
         end

         --更新内容
         print("更新公告内容"..contents)
         self._txtTrumpet:setString(contents)

         local containerWidth = self._txtTrumpet:getParent():getContentSize().width
         local contentSize = self._txtTrumpet:getContentSize()

         --初始化位置
         self._txtTrumpet:setPosition(containerWidth, 15)

         --更新动画
         self._txtTrumpet:stopAllActions()
         self._txtTrumpet:runAction(
             cc.RepeatForever:create(
                 cc.Sequence:create(
                     cc.CallFunc:create(function() self._txtTrumpet:setPosition(containerWidth, 15) end),
                     cc.MoveBy:create(16.0 + contentSize.width / 172, cc.p(-contentSize.width - containerWidth, 0))
                 )
             )
         )
     end)
end

--获取签到信息
function ClientScene:requestCheckinInfo()

    --苹果审核不显示登录奖励
    if yl.APPSTORE_VERSION then
        return
    end

    if nil == self._checkInFrame then

        self._checkInFrame = CheckinFrame:create(self, function(result, msg, subMessage)

            if result == 1 then

                local showFunc = function()
                    
                    if GlobalUserItem.bShowedLottery == true then
                        return
                    end

                    GlobalUserItem.bShowedLottery = true

                    self:runAction(cc.Sequence:create(
                                    cc.DelayTime:create(1.0),
                                    cc.CallFunc:create(function()
                                        --显示领奖页面
                                        showPopupLayer(LogonRewardLayer:create(), getPopupMaskCount() == 0)
                                    end)
                                    )
                                )
                end

                --今日还没签到
			    if false == GlobalUserItem.bTodayChecked then

                    --获取抽奖配置
                    if GlobalUserItem.bLotteryConfiged == false then

                        RequestManager.requestLotteryConfig(function(result, message)

                            if result == 0 then
                                --显示领奖页面
                                showFunc()
                            end
                        end)
                    else
                        --显示领奖页面
                        showFunc()
                    end
                end
            end

            --self._checkInFrame:onCloseSocket()
            --self._checkInFrame = nil
        end)
    end

    self._checkInFrame:onCheckinQuery()
	self._checkInFrame:onCloseSocket()
end
function ClientScene:updateEnterRoomInfo(roominfo)
	self._roominfo=roominfo
end
function ClientScene:getEnterRoomInfo()
return self._roominfo
end
--启动游戏
function ClientScene:onStartGame()
	local app = self:getApp()
	local entergame = self:getEnterGameInfo()
	local roominfo = self:getEnterRoomInfo()
	if nil == entergame then
		showToast(self, "游戏信息获取失败", 3)
		return
	end
	self:getEnterGameInfo().nEnterRoomIndex = GlobalUserItem.nCurRoomIndex
	if nil ~= self.m_touchFilter then
		self.m_touchFilter:dismiss()
		self.m_touchFilter = nil
	end
	--self:showPopWait()
	
	self._gameFrame:onInitData()
	self._gameFrame:setKindInfo(entergame._KindID, entergame._KindVersion)
	self._gameFrame:setViewFrame(self._roomLayer)
	self._gameFrame:onCloseSocket()
	self._gameFrame:onLogonRoom(roominfo)
end

--显示等待
function ClientScene:showPopWait(isTransparent)
	if not self._popWait then
		self._popWait = PopWait:create(isTransparent)
			:show(self,"请稍候！")
		self._popWait:setLocalZOrder(yl.MAX_INT)
	end
end

--关闭等待
function ClientScene:dismissPopWait()
	if self._popWait then
		self._popWait:dismiss()
		self._popWait = nil
	end
end
function ClientScene:disconnectFrame()
	if nil ~= self._shopDetailFrame and self._shopDetailFrame:isSocketServer() then
		self._shopDetailFrame:onCloseSocket()
		self._shopDetailFrame = nil
	end

	if nil ~= self._levelFrame and self._levelFrame:isSocketServer() then
		self._levelFrame:onCloseSocket()
		self._levelFrame = nil
	end
    
	if nil ~= self._checkInFrame and self._checkInFrame:isSocketServer() then
		self._checkInFrame:onCloseSocket()
		self._checkInFrame = nil
	end
end
--更新进入游戏记录
function ClientScene:updateEnterGameInfo( info )
	GlobalUserItem.m_tabEnterGame = info
end

function ClientScene:getEnterGameInfo(  )
	return GlobalUserItem.m_tabEnterGame
end
----获取抽奖配置
--function ClientScene:requestLotteryConfig()

--    --获取抽奖奖品配置
--	local url = yl.HTTP_URL .. "/WS/Lottery.ashx"
-- 	appdf.onHttpJsionTable(url ,"GET","action=LotteryConfig",function(jstable,jsdata)

--        if type(jstable) == "table" then
--            local data = jstable["data"]
--            if type(data) == "table" then
--                local valid = data["valid"]
--                if nil ~= valid and true == valid then
--                    local list = data["list"]
--                    if type(list) == "table" then
--                        for i = 1, #list do
--                            --配置转盘
--                            local lottery = list[i]

--                            GlobalUserItem.dwLotteryQuotas[i] = lottery.ItemQuota
--                            GlobalUserItem.cbLotteryTypes[i] = lottery.ItemType
--                        end

--                        --抽奖已配置
--                        GlobalUserItem.bLotteryConfiged = true

--                        --今日还没签到，弹出签到页面
--			            if false == GlobalUserItem.bTodayChecked then
--                            self:runAction(cc.Sequence:create(
--                                                cc.DelayTime:create(1.0),
--                                                cc.CallFunc:create(function()

--                                                        showPopupLayer(LogonRewardLayer:create())
--                                                    end),
--                                                nil
--                                                )
--                                            )
--                        end
--                    end
--                end
--            end
--        end
--    end)
--end

--查询活动状态
--function ClientScene:requestQueryActivityStatus()

    --显示过了就不请求了
 --   if GlobalUserItem.bShowedActivity == true then
 --       return
 --   end

 --   local url = yl.HTTP_URL .. "/WS/NativeWeb.ashx"
 --   local ostime = os.time()
 --   appdf.onHttpJsionTable(url ,"GET","action=queryactivitystatus&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(jstable,jsdata)

 --       if jsdata ~= "0" then
 --           return
 --       end

 --      GlobalUserItem.bShowedActivity = true

 --       self:runAction(cc.Sequence:create(
 --           cc.DelayTime:create(1.0),
--            cc.CallFunc:create(function()
                --显示活动页面
 --               showPopupLayer(ActivityLayer:create(), getPopupMaskCount() == 0)
 --           end)
  --          )
  --      )
 --   end)
--end

return ClientScene