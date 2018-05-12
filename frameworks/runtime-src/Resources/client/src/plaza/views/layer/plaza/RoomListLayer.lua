-- 房间列表
local RoomListLayer = class("RoomListLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

if not yl then
    appdf.req(appdf.CLIENT_SRC.."plaza.models.yl")
end

function RoomListLayer:ctor(delegate,   wKindID)
print("房间列表",wKindID)
    self._kindID = wKindID
    self._delegate = delegate

    --开启级联透明度
    self:setCascadeOpacityEnabled(true)

    --背景
    self._content = cc.Sprite:create("Room/bg.png")
    self._content:setPosition(display.center)
    self._content:addTo(self)

    local btnClose = ccui.Button:create("Room/btn_back_0.png", "Room/btn_back_1.png")
    btnClose:setPosition(1200, 675)
    btnClose:addClickEventListener(function() 
                --播放音效
                --ExternalFun.playClickEffect()
                self:onKeyBack()
                --dismissPopupLayer(self)
            end)
    btnClose:addTo(self._content)

    self:updateRoom()
end

function RoomListLayer:updateRoom( )
    --获取房间列表
    local roomList1 = GlobalUserItem.roomlist[self._kindID]

    local roomList = {}

    local count = roomList1 and #roomList1 or 0
    local idx = 1
    for i=1,count do
        if roomList1[i].wServerType ~= 16 then
            roomList[idx] = roomList1[i]
            idx = idx + 1
        end
    end

    local roomCount = roomList and #roomList or 0
    if roomCount > 5 then
        roomCount = 5
    end
    print("roomCount",roomCount)
    -- 按房间等级从小到大排序
    table.sort(roomList, function(a, b) return a.wServerLevel < b.wServerLevel end)

    for i=0,roomCount-1 do
        --房间信息
        local roomInfo = roomList[i + 1]
        dump(roomInfo,"房间信息")
        print("roomInfo.wServerLevel",roomInfo.wServerLevel)

        --判断是否是积分房
        if roomInfo.wServerType == yl.GAME_GENRE_GOLD then 
            local x = appdf.WIDTH / roomCount / 2 * (1 + 2 * i)
            print(appdf.WIDTH.." / "..roomCount.." / 2 * (1 + 2 * "..i..") = "..x)
            --创建地板
            local level = roomInfo.wServerLevel % 10
            if level > 4 then
                level = 5
            end
            print("[Room List]: level is -- "..level)
            local btnRoom = ccui.Button:create("Room/item_bg.png", "Room/item_bg.png", "Room/item_bg.png")
            btnRoom:setPosition(x, appdf.HEIGHT/2-30)
            btnRoom:setCascadeOpacityEnabled(true)
            btnRoom:addTo(self._content)
            btnRoom:addClickEventListener(function()
                
                self:onClickRoom(roomInfo.wServerID)
            end)
            --百家乐直接进入游戏
            if self._kindID==122  then
               self:onKeyBack()
                self:onClickRoom(roomInfo.wServerID)
                --self:setVisible(flse)
                
            end
            --分数
            local iconfile = string.format("Room/item_score_%d.png", level)
            cc.Sprite:create(iconfile)
                :setPosition(85, 300)
                :addTo(btnRoom)

            iconfile = string.format("Room/room_number_%d.png", level)
            ccui.TextAtlas:create(roomInfo.lCellScore, iconfile, 26, 34, "0")
                :setPosition(180, 300)
                :addTo(btnRoom)

            iconfile = string.format("Room/item_icon_%d.png", level)
            cc.Sprite:create(iconfile)
                :setPosition(130, 200)
                :addTo(btnRoom)

            iconfile = string.format("Room/item_bg_%d.png", level)
            local bottom = cc.Sprite:create(iconfile)
            bottom:setPosition(137, 48)
            bottom:addTo(btnRoom)

            iconfile = string.format("Room/item_title_%d.png", level)
            cc.Sprite:create(iconfile)
                :setPosition(108, 40)
                :addTo(bottom)
            local score = roomInfo.lEnterScore / 2
            local msg = string.format("入场:"..roomInfo.lEnterScore.."  离场:"..score)
            cc.Label:createWithTTF(msg, "fonts/round_body.ttf", 20)
		        :setTextColor(cc.c4b(244,75,23,255))
		        :setAnchorPoint(cc.p(0.5,0.5))
		        :setDimensions(640, 180)
		        :setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		        :setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_CENTER)
		        :move(bottom:getContentSize().width / 2 ,100)
		        :addTo(bottom)
        end
    end
end

------------------------------------------------------------------------------------------------------------
-- 公共接口

------------------------------------------------------------------------------------------------------------
-- 事件处理

--点击返回
function RoomListLayer:onKeyBack()
    yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --播放音效
    ExternalFun.playClickEffect()
    print("关闭RoomListLayer")
    dismissPopupLayer(self)
end
--function RoomListLayer:onKeyBack()

--    local privateRoomCount = GlobalUserItem.getPrivateRoomCount(self._kindID)

--    if self._scrollView:isVisible() then
--        if privateRoomCount > 0 then --显示房间分类
--            -- self._categoryView:setVisible(true)
--            -- self._scrollView:setVisible(false)
--            self:showRoomCategory(self._kindID)
--            return false
--        end
--    end

--    return true
--end

--点击游戏币场
function RoomListLayer:onClickGoldRoom()
    print("点击游戏币场", wServerID)
    --播放按钮音效
    ExternalFun.playClickEffect()

    self:showRoomList(self._kindID)
end

--点击房间
function RoomListLayer:onClickRoom(wServerID)

    print("点击房间图标", wServerID)

    --播放按钮音效
    ExternalFun.playClickEffect()

    if self._delegate and self._delegate.onClickRoom then
        self._delegate:onClickRoom(wServerID, self._kindID)
    end
end

return RoomListLayer