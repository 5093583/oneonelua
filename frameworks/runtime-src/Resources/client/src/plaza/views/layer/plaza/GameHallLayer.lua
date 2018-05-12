--游戏大厅
local GameHallLayer = class("GameHallLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")
local FriendsRoomLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.FriendsRoomLayer")
local StoreLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.StoreLayer")
local GameListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.GameListLayer")


function GameHallLayer:ctor(delegate)
    
    self._delegate = delegate
    self._scene = delegate
    -- self._gameListLayer = GameListLayer:create(delegate)

	--网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --节点事件
	ExternalFun.registerNodeEvent(self)

    --默认游戏列表
    self._gameLists = {200, 6, 27, 302}
    
    --默认游戏
    self.wKindID = self._gameLists[1]


	--加载CSB文件
	local csbNode = ExternalFun.loadCSB("GameHall/GameHallLayer.csb"):addTo(self)

    self.top_node = csbNode:getChildByName("Top_Node")
    self.btc_node = self.top_node:getChildByName("BTC_Num")
    self.tab_node = csbNode:getChildByName("Tab_Btn_Node")
    self.list_node = csbNode:getChildByName("List_Node")
    self.item_room = csbNode:getChildByName("Item")

    --返回按钮
    local btn_back = self.top_node:getChildByName("Back_Btn")
    btn_back:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --添加Btc
    local btn_addBTC = self.btc_node:getChildByName("Add_Btn")
    btn_addBTC:addClickEventListener(function()
    
        --播放音效
        ExternalFun.playClickEffect()
        local backsce = StoreLayer:create()
        showPopupLayer(backsce)
    end)

    --比特币量
    local btcnum = self.btc_node:getChildByName("Num")
    btcnum:setString(ExternalFun.formatScoreText(GlobalUserItem.lUserScore) .. " BTC")

    --好友房
    local btn_friends_room = self.top_node:getChildByName("Friends_Room_Btn")
    btn_friends_room:addClickEventListener(function()
        print("好友房按钮")
        --播放音效
        ExternalFun.playClickEffect()
        showToast(self, "该功能暂未开通，敬请期待", 2)
        --local backsce = FriendsRoomLayer:create()
        --showPopupLayer(backsce)
        
    end)
    
    --游戏列表
    self.btn_gameList = {}
    local children = self.tab_node:getChildren()
    for i=1, #children do
        if "Button" == children[i]:getDescription() then
            table.insert(self.btn_gameList, children[i])
        end
    end
    
    local function callback(sender)
        --播放音效
	    ExternalFun.playClickEffect()
        print("滑动点点下载",sender)
        for i=1, #self.btn_gameList do
            if self.btn_gameList[i] == sender then
                self.btn_gameList[i]:getChildByName("Bg"):setVisible(true)
                self.wKindID = self._gameLists[i]
                print("游戏id",self.wKindID)
                if self.wKindID==6 or self.wKindID==302 then
                    showToast(self, "该游戏暂未开通，敬请期待", 2)
                    return 
                end
                self:updateRoomList()
                -- print(88877)
                --点击下载游戏
                --self.btn_gameList[i]:getChildByName("Bg"):addClickEventListener(function()
                    -- self:onClickGame(self.btn_gameList[i])
                    -- onClickGame

                    -- dump(self._gameListLayer)
                    -- self._gameListLayer:onClickGame(self.btn_gameList[i])
                    -- self.curGameIcon = 
                    self:onClickGame(self.wKindID)

                    -- ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("GameHall/login_02/login_02.ExportJson")
                    -- local arm = ccs.Armature:create("login_02")
                    -- arm:getAnimation():play("login_02", -1,1)
                    -- self:addChild(arm)
                    -- arm:setPosition(667, 375)
                    -- self.arm = arm
                --)
            else
                self.btn_gameList[i]:getChildByName("Bg"):setVisible(false)
            end
        end
    end

    for i=1, #self.btn_gameList do
        self.btn_gameList[i]:setTag(self._gameLists[i])
                :addClickEventListener(callback)
    end

    self:updateRoomList()
    self:onClickGame(200)
end

--刷新房间列表
function GameHallLayer:updateRoomList()

    self.list_node:getChildByName("Room_List"):removeAllChildren()

    local roomList = GlobalUserItem.roomlist[self.wKindID]

    local count = roomList and #roomList or 0
    for i=count, 1, -1 do
        if roomList[i].wServerType == 16 then
            table.remove(roomList, i)
        end
    end
    -- dump(self.wKindID)
    -- print(roomList, self.wKindID)
    table.sort(roomList, function(a, b) return a.wServerLevel < b.wServerLevel end)
    
    --判定GameHall.plist文件是否加载
    local isLoad = cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("GameHall/GameHall.plist")
    if not isLoad then
        --加载plist文件
        cc.SpriteFrameCache:getInstance():addSpriteFrames("GameHall/GameHall.plist")
    end

    local room_player_num = ""

    if 200 == self.wKindID then
        room_player_num = "3人桌"
    elseif 6 == self.wKindID then
        room_player_num = "5人桌"
    elseif 27 == self.wKindID then
        room_player_num = "4人桌"
    elseif 302 == self.wKindID then
        room_player_num = "4人桌"
    end

    for i=1, #roomList do
        if yl.GAME_GENRE_GOLD == roomList[i].wServerType then
            local item = self.item_room:clone()
            local sf_title_bg = cc.SpriteFrameCache:getInstance():getSpriteFrame("room_".. i.. "_title_bg.png")
            local sf_icon = cc.SpriteFrameCache:getInstance():getSpriteFrame("btc_".. i.. ".png")
            local sf_title = cc.SpriteFrameCache:getInstance():getSpriteFrame("room_".. i.. "_title.png")
            item:getChildByName("Title_Bg"):loadTexture("room_".. i.. "_title_bg.png" ,ccui.TextureResType.plistType)
            item:getChildByName("Title_Bg"):getChildByName("Icon"):loadTexture("btc_".. i.. ".png" ,ccui.TextureResType.plistType)
            item:getChildByName("Title"):loadTexture("room_".. i.. "_title.png", ccui.TextureResType.plistType)
            item:getChildByName("Title"):getChildByName("Label"):setString(room_player_num)
            item:getChildByName("Controlled"):getChildByName("Text"):setString(ExternalFun.formatScoreText(roomList[i].lEnterScore) .. " BTC")

            math.randomseed( tonumber( tostring( os.time() ):reverse() ) )
            item:getChildByName("People_Num"):getChildByName("Text"):setString( math.floor(math.random(35, 85) -10*i+i ) )
            item:getChildByName("GoInto_Btn"):addClickEventListener( function()
                self:onClickRoom(roomList[i].wServerID)
            end)
            self.list_node:getChildByName("Room_List"):pushBackCustomItem(item)
        end       
    end 
end

function GameHallLayer:onClickRoom(wServerID)
    print("点击房间图标", wServerID)
    --播放按钮音效
    ExternalFun.playClickEffect()

    if self._delegate and self._delegate.onClickRoom then
        self._delegate:onClickRoom(wServerID, self.wKindID)
    end
end

--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function GameHallLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

end



function GameHallLayer:onClickGame(wKindID)

    print("点击游戏图标", wKindID)

    local app = self._scene:getApp()

    dump(app._gameList)

    --判断游戏是否存在
    local gameinfo = app:getGameInfo(wKindID)
    if not gameinfo then 
        showToast(nil, "亲，人家还没准备好呢！", 2)
        return
    end

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    -- if cc.PLATFORM_OS_WINDOWS ~= targetPlatform then
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        --判断是否开放房间
        if GlobalUserItem.getRoomCount(wKindID) == 0 then
            showToast(nil, "抱歉，游戏房间暂未开放，请稍后再试！", 2)
            return
        end
        --通知进入游戏类型
        if self._scene and self._scene.onClickGame then
            print("通知进入游戏类型",wKindID)
            self._scene:onClickGame(wKindID)
        end
    else 
        local version = tonumber(app:getVersionMgr():getResVersion(gameinfo._KindID))
        if version == nil then --下载游戏
            self:downloadGame(gameinfo)
        elseif gameinfo._ServerResVersion > version then --更新游戏
            -- self:updateGame(gameinfo)
        else
            --判断是否开放房间
            if GlobalUserItem.getRoomCount(wKindID) == 0 then
                showToast(nil, "抱歉，游戏房间暂未开放，请稍后再试！", 2)
                return
            end

            --通知进入游戏类型
            if self._scene and self._scene.onClickGame then
                self._scene:onClickGame(wKindID)
            end
        end
    end
end


--下载游戏
function GameHallLayer:downloadGame(gameinfo)

    if self._updategame then
        showToast(nil, "正在更新 “" .. self._updategame._GameName .. "” 请稍后", 2)
        return
    end

    --保存更新的游戏
    self._updategame = gameinfo

    local app = self._scene:getApp()
    local updateUrl = app:getUpdateUrl()

    --下载地址
    local fileurl = updateUrl .. "/game/" .. string.sub(gameinfo._Module, 1, -2) .. ".zip"
    --文件名
    local pos = string.find(gameinfo._Module, "/")
    local savename = string.sub(gameinfo._Module, pos + 1, -2) .. ".zip"
    --保存路径
    local savepath = nil
    local unzippath = nil
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        savepath = device.writablePath .. "download/game/" .. gameinfo._Type .. "/"
        unzippath = device.writablePath .. "download/"
    else
        savepath = device.writablePath .. "game/" .. gameinfo._Type .. "/"
        unzippath = device.writablePath
    end

    print("savepath: " .. savepath)
    print("savename: " .. savename)
    print("unzippath: " .. unzippath)

    --下载游戏压缩包
    downFileAsync(fileurl, savename, savepath, function(main, sub)

        --对象已经被销毁
        if not appdf.isObject(self) then
            return
        end

        --下载回调
        if main == appdf.DOWN_PRO_INFO then --进度信息
            
            self:showGameProgress(gameinfo._KindID, sub)
            print(gameinfo._KindID, sub)

        elseif main == appdf.DOWN_COMPELETED then --下载完毕

            local zipfile = savepath .. savename

            --解压
            unZipAsync(zipfile, unzippath, function(result)
                
                --删除压缩文件
                os.remove(zipfile)

                --清空正在更新的游戏状态
                self._updategame = nil

                self:hideGameProgress(gameinfo._KindID)
                print("下载完毕")

                if result == 1 then
                    --保存版本记录
                    app:getVersionMgr():setResVersion(gameinfo._ServerResVersion, gameinfo._KindID)

                    showToast(nil, "“" .. gameinfo._GameName .. "” 下载完毕", 2)

                    --播放音效
                    --self:playFinishEffect()  
                else
                    showToast(nil, "“" .. gameinfo._GameName .. "” 解压失败", 2)
                end

            end)

        else

            --清空正在更新的游戏状态
            self._updategame = nil

            self:hideGameProgress(gameinfo._KindID)

            showToast(nil, "“" .. gameinfo._GameName .. "” 下载失败，错误码：" .. main .. ", " .. sub, 2)

        end
    end)
end

function GameHallLayer:hideGameProgress(KindID)
    if self.blank then
        self.blank:removeFromParent()
        self.blank = nil
        ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("GameHall/login_02/login_02.ExportJson")
    end
end

function GameHallLayer:showGameProgress(KindID, sub)
    print(KindID, sub)

    if self.blank == nil then
        -- 创建触摸处理层
        self.blank = ccui.Layout:create()
        -- 将blank层铺面屏幕
        self.blank:setContentSize(1334, 750)

        local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
        colorLayer:setContentSize(self.blank:getContentSize())
        self.blank:addChild(colorLayer)
        -- 添加监听
        if self.blank then
            -- 创建监听事件
            self.blank:setTouchEnabled(true)
            self:addChild(self.blank)
        end

        local label = ccui.Text:create()
        label:ignoreContentAdaptWithSize(true)
        label:setName("label")
        label:setFontSize(35)
        label:setString("资源载入中...".. sub .."%")
        label:setPosition(667, 300)
        self.blank:addChild(label) 
        -- 动画实现
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("GameHall/login_02/login_02.ExportJson")
        local arm = ccs.Armature:create("login_02")
        arm:getAnimation():play("login_02", -1,1)
        self.blank:addChild(arm)
        arm:setPosition(667, 375)
    end
    self.blank:getChildByName("label"):setString("资源载入中...".. sub .."%")
end


return GameHallLayer