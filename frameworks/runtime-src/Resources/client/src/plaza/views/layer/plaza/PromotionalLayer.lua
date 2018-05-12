--推广邀请
local PromotionalLayer = class("PromotionalLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

function PromotionalLayer:ctor()
local this=self
self.friends_infos = {}
self.wards_infos = {}
	--网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --节点事件
	ExternalFun.registerNodeEvent(self)

	--加载CSB文件
	local csbNode = ExternalFun.loadCSB("Promotional/PromotionalLayer.csb"):addTo(self)

	self.tab_node = csbNode:getChildByName("Tab_Node")
	self.invite_page = self.tab_node:getChildByName("Invite_Page")
	self.friends_list = self.tab_node:getChildByName("Friends_List")
	self.awards_list = self.tab_node:getChildByName("Awards_List")

    --关闭
    local btn_close = csbNode:getChildByName("Close_Btn")
    btn_close:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    local btn_invite = self.tab_node:getChildByName("Invite_Friends_Box")
    local btn_friends = self.tab_node:getChildByName("Friends_List_Box")
    local btn_awards = self.tab_node:getChildByName("Received_Awards_Box")

    --切换按钮
    if btn_invite and btn_friends and btn_awards then

        local function callback (sender, eventType)

	        --播放音效
	        ExternalFun.playClickEffect()

            local selected_type = sender:getChildByName("Bg")
            if selected_type:isVisible() ~= true then
                if sender:getName() == "Invite_Friends_Box" then
                    btn_friends:getChildByName("Bg"):setVisible(false)
                    btn_awards:getChildByName("Bg"):setVisible(false)
                    selected_type:setVisible(true)
                    self:updatePage(1)
                elseif sender:getName() == "Friends_List_Box" then
                    btn_invite:getChildByName("Bg"):setVisible(false)
                    btn_awards:getChildByName("Bg"):setVisible(false)
                    selected_type:setVisible(true)
                    self:updatePage(2)
                elseif sender:getName() == "Received_Awards_Box" then
                    btn_invite:getChildByName("Bg"):setVisible(false)
                    btn_friends:getChildByName("Bg"):setVisible(false)
                    selected_type:setVisible(true)
                    self:updatePage(3)
                end
                
            end
            
        end
        btn_invite:addClickEventListener(callback)
        btn_friends:addClickEventListener(callback)
        btn_awards:addClickEventListener(callback)
    end

    --复制推荐码
    local btn_cpoy_promo_code = self.invite_page:getChildByName("Promo_Code_Node"):getChildByName("Copy_Btn")
    btn_cpoy_promo_code:addClickEventListener(function()
    	
        --播放音效
        ExternalFun.playClickEffect()

        showToast(self, "该功能暂未开通，敬请期待", 2)
    end)

    --复制推荐地址
    local btn_cpoy_promo_addr = self.invite_page:getChildByName("Promo_Addr_Node"):getChildByName("Copy_Btn")
	btn_cpoy_promo_addr:addClickEventListener(function()
    	
        --播放音效
        ExternalFun.playClickEffect()

        showToast(self, "该功能暂未开通，敬请期待", 2)
    end)

    --分享按钮
    local btn_shared = self.invite_page:getChildByName("Shared_Btn")
    btn_shared:addClickEventListener(function()
    	
        --播放音效
        ExternalFun.playClickEffect()

        showToast(self, "该功能暂未开通，敬请期待", 2)
    end)
this:initdata()
end

function PromotionalLayer:updateFriendsList()
    local item_list = self.tab_node:getChildByName("Item")

    local list = self:getFrinedsList()

    if #list > 0 then
        for i = 1, #list do
            local item = item_list:clone()
            item:getChildByName("Remark_Txt"):setString(list[i])
            --2018-01-01 00:00:01        隔壁老李赢800比特币给你奖励100比特币
            self.friends_list:pushBackCustomItem(item)
        end
    end
end

function PromotionalLayer:getFrinedsList()
  
    return self.friends_infos
end

function PromotionalLayer:updateaWardsList()
    local item_list = self.tab_node:getChildByName("Item")

    local list = self:getWardsList()

    if #list > 0 then
        for i = 1, #list do
            local item = item_list:clone()
            item:getChildByName("Remark_Txt"):setString(list[i])
            self.awards_list:pushBackCustomItem(item)
        end
    end
end

function PromotionalLayer:initdata()
	local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=getshareinfo&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
                    local btc_1,btc_2 = self:string_insert(data["shareinfo"])
					self.invite_page:getChildByName("Promo_Code_Node"):getChildByName("Promo_Code_Txt"):setString(data["sharecode"])
					self.invite_page:getChildByName("Promo_Addr_Node"):getChildByName("Promo_Addr_Txt"):setString(data["shareaddr"])
					self.invite_page:getChildByName("Explain_Txt"):setString(btc_1)
                    self.invite_page:getChildByName("Explain_Txt2"):setString(btc_2)
					local path = device.writablePath
					local filename = "qrcode.png"
					self:downloadFace(data["qrcode"], path, filename, function(downloadfile)
            
						print(downloadfile)
						local file = downloadfile
						--dump(file)
						--local tag = string.sub(downloadfile, 0, 1)
						local head =self.invite_page:getChildByName("QR_Code")
						head:loadTexture(device.writablePath..file)
						head:setVisible(true)
						head:setScale(0.5)

					end)
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)
	
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=GetLowUser&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
		    for key, var in ipairs(data["data"]) do
			--dump(var)
			str= string.format("%s    %s    成功邀请%d位好友",var["nickname"],var["time"],var["sum"]) 
			
			table.insert(self.friends_infos,str)
		    end
		    self:updateFriendsList()
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)
    
    local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=GetGrantList&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
		    for key, var in ipairs(data["data"]) do
			--dump(var)
			str= string.format("%s    %s",var["time"],var["msg"]) 
			
			table.insert(self.wards_infos,str)
		    end
		    self:updateaWardsList()
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)
end

function PromotionalLayer:string_insert(str) 
    if str == "" then
        return "",""
    end
    local len = 40
    local ba = len / 2
    local a = string.sub(str,1,ba)
    local b = string.sub(str,ba+1)
     return a,b
end

function PromotionalLayer:getWardsList()
    return self.wards_infos
end

function PromotionalLayer:updatePage(index)
	if 1 == index then
		self.invite_page:setVisible(true)
		self.friends_list:setVisible(false)
		self.awards_list:setVisible(false)
	elseif 2 == index then
		self.invite_page:setVisible(false)
		self.friends_list:setVisible(true)
        self.awards_list:setVisible(false)
        --self:updateFriendsList()
    elseif 3 == index then
		self.invite_page:setVisible(false)
		self.friends_list:setVisible(false)
        self.awards_list:setVisible(true)
        --self:updateaWardsList()
    end
end

--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function PromotionalLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

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
--下载图片
function PromotionalLayer:downloadFace(url, path, filename, onDownLoadSuccess)
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
return PromotionalLayer