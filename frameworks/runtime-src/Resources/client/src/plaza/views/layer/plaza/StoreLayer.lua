local StoreLayer = class("StoreLayer", cc.Layer)
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local PaymentLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.PaymentLayer")
local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC .. "plaza.models.ModifyFrame")

--道具类型
local PropertyType =
{
    Gold = 5,

}
--列表类型
local ListType = 
{
    Bean = 1,
    Gold = 2,
    RoomCard = 3
}
local payType={
	BTC=1,
	ETH=2,
	USTD=3
}
function StoreLayer:ctor()
        self.infos={}
    --网络处理
    self._modifyFrame = ModifyFrame:create(self, function(result, message)
        self:onModifyCallBack(result, message)
    end)
	self._amount =0
	self.itemPrice = 0
	self._appid = 0
	self.productId = 0
	self.index=1
    --节点事件
    ExternalFun.registerNodeEvent(self)

    --加载CSB文件
    local csbNode = ExternalFun.loadCSB("Store/StoreLayer.csb"):addTo(self)
	
    --返回按钮
    local btn_close = csbNode:getChildByName("Close_Btn")
    btn_close:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    self.layer_record = csbNode:getChildByName("Record_Layer")
	self.panel = csbNode:getChildByName("Merchandise_List_Node"):getChildByName("Panel")
	self.score=csbNode:getChildByName("BTC_Num"):getChildByName("Num")
	self.score:setString(ExternalFun.formatScoreText(GlobalUserItem.lUserScore) .. " BTC")
	self.poplayer = csbNode:getChildByName("Pop_Layer")
	
	self.paylayer_panel = csbNode:getChildByName("Play_Layer"):getChildByName("Panel")
	self.paylayer = csbNode:getChildByName("Play_Layer")
	self.poplayer:addClickEventListener(function()
        ExternalFun.playClickEffect()
       self.poplayer:setVisible(not self.poplayer:isVisible())
    end)
    --转入记录按钮
    local btn_record = csbNode:getChildByName("Record_Btn")
    btn_record:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        self.layer_record:setVisible(not self.layer_record:isVisible())
    end)

    local btn_hide_record = self.layer_record:getChildByName("Hide_Btn")
    btn_hide_record:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        self.layer_record:setVisible(false)
    end)
    self.paylayer_panel:getChildByName("Ok"):addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        self:settextv(false)
    end)
	self.paylayer_panel:getChildByName("Close"):addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        self:settextv(false)
    end)
    self:initdata()
end


function StoreLayer:showdata()
	local item_record = self.layer_record:getChildByName("Item")
    local list_record = self.layer_record:getChildByName("Record_List")
    list_record:removeAllChildren()

    local list = self.infos

    if #list > 0 then
        for i = 1, #list do
            local item = item_record:clone()
            item:getChildByName("Remark"):setString(list[i])
            list_record:pushBackCustomItem(item)
        end
    end
end
function StoreLayer:getPageList(page)
    local ostime=os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=GetCoinCostList&userid=" .. GlobalUserItem.dwUserID ..  "&page=".. page.."&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
				self.infos={}
                    -- 处理基本信息的显示
		    for key, var in ipairs(data["data"]) do
			str= string.format("%s        转入%d个比特币",var["time"],var["amount"]) 
			
			table.insert(self.infos,str)
		    end
		    self:showdata()
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)
end
--初始化用户币种信息
function StoreLayer:getcoinaddr()

    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=getusercoin&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            dump(data)
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    --self.edPhone:setText(data["data"]["PhoneNum"])    
                    --self.edBankName:setText(data["data"]["BTC"])
                    --self.edBankAcc:setText(data["data"]["ETH"])
                    --self.edSName:setText(data["data"]["USDT"])
                    self.btcCoinAddr=data["BTC"]
					self.ethCoinAddr=data["ETH"]
					self.usdtCoinAddr=data["USDT"]
					self.ethbtc=data["ethbtc"]
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)

end
function StoreLayer:payCoin(plat)
	--self.poplayer:getChildByName("Panel"):setVisible(false)
	self.poplayer:setVisible(false)
	paybg=self.poplayer
	--标签文本
	if plat==payType.BTC then
		coinstr="比特币"
		addr=self.btcCoinAddr
	elseif plat==payType.ETH then
		coinstr="以太币"
		addr=self.ethCoinAddr
		self._amount=self._amount*self.ethbtc
	else 
		coinstr="PAI币"
		addr=self.usdtCoinAddr
	end
	flagText="你的"..coinstr.."游戏钱包地址"..addr
    --self.strText1:setString(flagText)
    --self.strText1:enableOutline(cc.c3b(208, 22, 21), 3)
	--self.strText1:addTo(self.poplayer)
	flagText="请将你的".."             ".."个"..coinstr.."转入你的游戏钱包"..coinstr.."地址15分钟到账"
	--self.strText2:setString(flagText)
    --self.strText2:setPosition(700, 420)
    --self.strText2:enableOutline(cc.c3b(208, 22, 21), 3)
	--self.strText2:addTo(self.poplayer)
    local s,t = self:string_insert(addr)
    self.paylayer_panel:getChildByName("Adrvalue"):setVisible(false)
   -- text:setFontSize(28)
  --  text:setColor(cc.c3b(247,153,37))
    local pos = cc.p(430,260)
    local pos2 = cc.p(430,290)
    local pos3 = cc.p(100,280)
    local pos4 = cc.p(250,150)

    self:showStr(pos,t,nil,"1")
    self:showStr(pos2,s,nil,"2")
    self:showStr(pos3,"你的"..coinstr.."游戏钱包地址:",cc.c3b(241,189,253),"3")
    self:showStr(pos4,self._amount,nil,"4")

	self.paylayer_panel:getChildByName("Title"):setString(coinstr.."支付")
	self.paylayer_panel:getChildByName("Adrtext"):setVisible(false)
	
	self.paylayer_panel:getChildByName("Content"):setString(flagText)
	self:settextv(true)
    --txtFlag:setRotation(-45)
	
end

function StoreLayer:string_insert(str) 
    if str == "" then
        return "",""
    end
    local len = 40
    local ba = len / 2
    local a = string.sub(str,1,ba)
    local b = string.sub(str,ba+1)
     return a,b
end

function StoreLayer:showStr( pos,strChat,color,tag)
    local co3 = color and color or cc.c3b(247,153,37)
    local txtWidth = string.len(strChat) * 26
    local txt
    if self.paylayer_panel:getChildByName(tag) then
        txt = self.paylayer_panel:getChildByName(tag)
        txt:setString(strChat)
        return
    else
        txt = ccui.Text:create()
        txt:setName(tag)
    end
    
    txt:setAnchorPoint(cc.p(0, 0))
    txt:setTextAreaSize(cc.size(txtWidth, 0))
    txt:ignoreContentAdaptWithSize(true)
    txt:setString(strChat)
    txt:setFontSize(28)
    txt:setPosition(pos)
    txt:setColor(co3)

   
    self.paylayer_panel:addChild(txt)

  --  imageView:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.RemoveSelf:create() ))
end
--第三方支付
function StoreLayer:onThirdPartyPay(plat)

    local platNameEN = ""
    local platNameCN = ""
    if plat == yl.ThirdParty.WECHAT then
        platNameEN = "wx"
        platNameCN = "微信"
    elseif plat == yl.ThirdParty.ALIPAY then
        platNameEN = "zfb"
        platNameCN = "支付宝"
    else
        return
    end
    
    --判断应用是否安装
    if false == MultiPlatform:getInstance():isPlatformInstalled(plat) then
        showToast(nil, platNameCN .. "未安装, 无法进行" .. platNameCN .. "支付", 2)
        return
    end 

    --生成订单
    local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
	local action = "action=CreatPayOrderID&gameid=" .. GlobalUserItem.dwGameID .. "&amount=" .. self._amount .. "&paytype=" .. platNameEN .. "&appid=" .. self._appid

    showPopWait()

    appdf.onHttpJsionTable(url,"GET",action,function(jstable,jsdata)

        dismissPopWait()

    	if type(jstable) == "table" then
			local data = jstable["data"]
			if type(data) == "table" then
				if nil ~= data["valid"] and true == data["valid"] then
					local payparam = {}
					if plat == yl.ThirdParty.WECHAT then --微信支付
						--获取微信支付订单id
						local paypackage = data["PayPackage"]
						if type(paypackage) == "string" then
							local ok, paypackagetable = pcall(function()
					       		return cjson.decode(paypackage)
					    	end)
					    	if ok then
					    		local payid = paypackagetable["prepayid"]
					    		if nil == payid then
									showToast(nil, "微信支付订单获取异常", 2)
									return 
								end
								payparam["info"] = paypackagetable
					    	else
					    		showToast(nil, "微信支付订单获取异常", 2)
					    		return
					    	end
						end
                    end
					--订单id
					payparam["orderid"] = data["OrderID"]						
					--价格
					payparam["price"] = self._amount
					--商品名
					payparam["name"] = "比特币"

					local function payCallBack(param)

						if type(param) == "string" and "true" == param then
                            GlobalUserItem.setTodayPay()
                                
							showToast(nil, "支付成功", 2)

                            self._callback(0)

                            dismissPopupLayer(self)
						else
							showToast(nil, "支付失败", 2)
						end
					end
					MultiPlatform:getInstance():thirdPartyPay(plat, payparam, payCallBack)
				else
                    if type(jstable["msg"]) == "string" and jstable["msg"] ~= "" then
                        showToast(nil, jstable["msg"], 2)
                    end
                end
			end
		end
    end)
end
function StoreLayer:initbuttom()
	self:getcoinaddr()
	for i=1,6 do
		self.panel:getChildByName("BTC_Btn_"..i):addClickEventListener(function()
			--播放音效
			ExternalFun.playClickEffect()
			self.poplayer:setVisible(true)
			self.poplayer:getChildByName("Panel"):setVisible(true)
			local itemInfo = GlobalUserItem.tabShopCache.shopGoldList[i]
			self._amount = itemInfo.BuyResultsGold 
			self.itemPrice = itemInfo.Cash
			self._appid = itemInfo.ID
			--self.productId = itemInfo.ProductID
			self.index=i
			self:settextv(false)
			--print(self._amount..self.itemPrice..self._appid..self.index)
		end)
	end
	self.poplayer:getChildByName("Panel"):getChildByName("wx"):addClickEventListener(function()
        
        ExternalFun.playClickEffect()
        self:onThirdPartyPay(yl.ThirdParty.WECHAT)
    end)
	self.poplayer:getChildByName("Panel"):getChildByName("zfb"):addClickEventListener(function()
        
        ExternalFun.playClickEffect()
       self:onThirdPartyPay(yl.ThirdParty.ALIPAY)
    end)
	self.poplayer:getChildByName("Panel"):getChildByName("btc"):addClickEventListener(function()
        
        ExternalFun.playClickEffect()
        self:payCoin(payType.BTC)
    end)
	self.poplayer:getChildByName("Panel"):getChildByName("eth"):addClickEventListener(function()
        
        ExternalFun.playClickEffect()
        self:payCoin(payType.ETH)
    end)
	self.poplayer:getChildByName("Panel"):getChildByName("ustd"):addClickEventListener(function()
        
        ExternalFun.playClickEffect()
        self:payCoin(payType.USTD)
    end)
	
end
function StoreLayer:settextv(flag)
	
	self.paylayer:setVisible(flag)
	--self.strText1:setVisible(flag)
	--self.strText2:setVisible(flag)
end
function StoreLayer:initdata()
	self:requestPropertyList(PropertyType.Gold)
	self:initbuttom()
	self:getPageList(1)
	--self.strText1 = ccui.Text:create("", "fonts/round_body.ttf", 22)
	--self.strText1:setPosition(700, 470)
    --self.strText1:enableOutline(cc.c3b(208, 22, 21), 3)
    --self.strText1:addTo(self.poplayer)
	
	--self.strText2 =ccui.Text:create("", "fonts/round_body.ttf", 22)
	--self.strText2:setPosition(700, 420)
    --self.strText2:enableOutline(cc.c3b(208, 22, 21), 3)
    --self.strText2:addTo(self.poplayer)
	self:settextv(false)
end
function StoreLayer:updateList()
	 local listCount=#GlobalUserItem.tabShopCache.shopGoldList
	 for i = 1, listCount do
		itemInfo = GlobalUserItem.tabShopCache.shopGoldList[i]
		self.panel:getChildByName("BTC_Btn_"..i):getChildByName("Title"):setString(ExternalFun.formatScoreText(itemInfo.BuyResultsGold) .. " BTC")
		
       
    end
	
end
--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function StoreLayer:onModifyCallBack(result, message)

    dismissPopWait()

    if  message ~= nil and message ~= "" then
        showToast(nil, message, 2)
    end
    if - 1 == result then
        return
    end

end

--获取道具列表
function StoreLayer:requestPropertyList(typeID)

    --self._activity:start()

    local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
    appdf.onHttpJsionTable(url, "GET", "action=GetMobileProperty&TypeID=" .. typeID,function(jstable,jsdata)

        --对象已经销毁
        if not appdf.isObject(self) then
            return
        end

        --self._activity:stop()

        if type(jstable) ~= "table" then
            return
        end

        local msg = jstable.msg
        if type(msg) == "string" then
           
            --弹出消息
        end

        local data = jstable.data
        if type(data) ~= "table" or data.valid ~= true then
            return
        end

        local list = data.list
        if type(list) ~= "table" then
            return
        end

        --排序
        table.sort(list, function(a,b)
            return a.SortID < b.SortID
        end)

        if typeID == PropertyType.Gold then

            --保存
            GlobalUserItem.tabShopCache.shopGoldList = list
            --更新列表
            self:updateList()
			self:initbuttom()
        end

	end)
end
return StoreLayer