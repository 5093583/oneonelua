--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local MemberListLayer = class("MemberListLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
--local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

m_pos = {
    cc.p(554, 280),
    cc.p(554, 209),
    cc.p(554, 140),
    cc.p(554, 70)
}

function MemberListLayer:ctor(scene)

    self._scene = scene

    local this = self
    -- 当前第几页
    self._curIdx = 1
    -- 一共有几页
    self._maxIdx = 1
    -- 每页有几条
    self._count = 4
    -- 共有多少条记录
    self._reIdx = 0
    -- 记录
    self._infos = {}

    --节点事件
    ExternalFun.registerNodeEvent(self)
    --加载csb资源
    local csbNode = ExternalFun.loadCSB("Deposit/MemberListLayer.csb"):addTo(self)
    self._parent = csbNode:getChildByName("Panel_1")
    self._panel = self._parent:getChildByName("Panel_2")

    --关闭
    self._parent:getChildByName("btn_Close"):addClickEventListener(function()       
        -- 播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)
    --返回
    self._parent:getChildByName("btn_Back"):addClickEventListener(function()
        -- 播放音效
        ExternalFun.playClickEffect()
        self._scene:showDepositLayer()
        dismissPopupLayer(self)
    end)
    --向前
    self._panel:getChildByName("btn_left"):addClickEventListener(function()
        -- 播放音效
        ExternalFun.playClickEffect()

        self._curIdx = self._curIdx - 1
        if self._curIdx == 0 then
            self._curIdx = 1
        end
        self:initPanel()
    end)
    --向后
    self._panel:getChildByName("btn_right"):addClickEventListener(function()
        -- 播放音效
        ExternalFun.playClickEffect()

        self._curIdx = self._curIdx + 1
        if self._curIdx > self._maxIdx then
            self._curIdx = self._maxIdx
        end
        self:initPanel()
    end)
    -- 查询会员信息
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=GetLowUser&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
                    this._reIdx = data["num"]
                    this._infos = data["data"]
                    this:initPanel()
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)

end

--清理成员列表
function MemberListLayer:clearPanel()

    for i = 1, 4 do
        self._panel:removeChildByName("sprite")
        self._panel:getChildByName("idx_"..i):setString("")
        self._panel:getChildByName("Text_"..i):setString("")
        self._panel:getChildByName("time_"..i):setString("")
        self._panel:getChildByName("frame_"..i):setVisible(false)
        self._panel:getChildByName("flag_"..i):setVisible(false)
    end

    --print(self._maxIdx)
end
--初始化成员列表
function MemberListLayer:initPanel()
    self:clearPanel()
    self._panel:getChildByName("txt_num"):setString(self._reIdx)
    self._maxIdx = math.ceil(self._reIdx / self._count)
    if self._maxIdx == 0 then
        self._maxIdx = 1;
    end

    self._panel:getChildByName("Text_index"):setString(self._curIdx .. "/" .. self._maxIdx);
    local idx = (self._curIdx - 1) * self._count + 1
    local endIdx = self._curIdx * self._count
    if endIdx > self._reIdx then
        endIdx = self._reIdx
    end
    print("EndIdx =========================="..endIdx.."idx======================"..idx)
    for i = idx, endIdx do

        local index = i - (self._curIdx - 1) * self._count
        
        self._panel:getChildByName("idx_"..index):setString(i)
        self._panel:getChildByName("Text_"..index):setString(self._infos[i]["NickName"])
        local pString = self:getTime(self._infos[i]["RegisterDate"])
        self._panel:getChildByName("time_"..index):setString(pString)
        self._panel:getChildByName("frame_"..index):setVisible(true)
        self._panel:getChildByName("frame_"..index):setLocalZOrder(1)
        if index ~= 4 then 
            local sprite = cc.Sprite:create("Deposit/img_line.png")
            if sprite ~= nil then
                self._panel:addChild(sprite)
                sprite:setPosition(m_pos[index])
                sprite:setName("sprite")
            end
        end
        local path = device.writablePath .. "client/res/face/"
        local filename = string.gsub(self._infos[i]["FaceUrl"], "[/.:+]", "") .. ".png"
        filename = index..filename
        self:downloadFace(appdf.HTTP_URL..self._infos[i]["FaceUrl"], path, filename, function(downloadfile)
            
            print(downloadfile)
            local file = "face/"..downloadfile
            local tag = string.sub(downloadfile, 0, 1)
            local head = self._panel:getChildByName("flag_"..tag)
            head:setTexture(file)
            head:setVisible(true)
            head:setScale(0.5)

        end)
    end

    --print(self._maxIdx)
end

--全局通知函数
cc.exports.DOWN_HEAD = function (ncode, msg, filename)
	print(msg)
	local event = cc.EventCustom:new("DOWN_HEAD")
	event.code = ncode
	event.msg = msg
	event.filename = filename

	cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
end

function MemberListLayer:getTime(str)

    str = string.split(str, " ")
    strs = string.split(str[1], "/")
    return strs[1] .. "." .. strs[2] .. "." .. strs[3]

end

--下载头像
function MemberListLayer:downloadFace(url, path, filename, onDownLoadSuccess)
	local downloader = CurlAsset:createDownloader("DOWN_HEAD",url)			
	if false == cc.FileUtils:getInstance():isDirectoryExist(path) then
		cc.FileUtils:getInstance():createDirectory(path)
	end			

	local function eventCustomListener(event)
        if nil ~= event.filename and 0 == event.code then
        	if nil ~= onDownLoadSuccess 
        		and type(onDownLoadSuccess) == "function" 
        		and nil ~= event.filename 
        		and type(event.filename) == "string" then
        		onDownLoadSuccess(event.filename)
        	end        	
        end
	end
    self:getEventDispatcher():removeCustomEventListeners("DOWN_HEAD")
	self.m_downListener = cc.EventListenerCustom:create("DOWN_HEAD",eventCustomListener)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self.m_downListener, self)

	downloader:downloadFile(path, filename)
end

return MemberListLayer


--endregion
