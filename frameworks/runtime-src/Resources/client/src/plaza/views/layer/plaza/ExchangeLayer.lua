--兑换
local ExchangeLayer = class("ExchangeLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

function ExchangeLayer:ctor()

    self._index = 1
	--网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --节点事件
	ExternalFun.registerNodeEvent(self)

	--加载CSB文件
	local csbNode = ExternalFun.loadCSB("Exchange/ExchangeLayer.csb"):addTo(self)
    self.wallte_node = csbNode:getChildByName("Exchange_Wallte_Title")
    
    --关闭
    local btn_close = csbNode:getChildByName("Close_Btn")
    btn_close:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --btc余额
    local txt_btc_num = csbNode:getChildByName("BTC_Balance_Title"):getChildByName("Num")
    txt_btc_num:setString(ExternalFun.formatScoreText(GlobalUserItem.lUserScore) .. " BTC")

    --转出币种选择
    local box_btc = self.wallte_node:getChildByName("CheckBox_1")
    local box_eht = self.wallte_node:getChildByName("CheckBox_2")
    local box_usdt = self.wallte_node:getChildByName("CheckBox_3"):setEnabled(false)

    local function callback (sender, eventType)

            --播放音效
        ExternalFun.playClickEffect()

        if sender:getName() == "CheckBox_1" then
                   
            self:updatePage(1)
        elseif sender:getName() == "CheckBox_2" then
                   
            self:updatePage(2)
        elseif sender:getName() == "CheckBox_3" then
                   
            self:updatePage(3)
        end
            
    end
    box_btc:addClickEventListener(callback)
    box_eht:addClickEventListener(callback)
  --  box_usdt:addClickEventListener(callback)

    --转出
    local btn_exchange = csbNode:getChildByName("Exchange_Btn")
    btn_exchange:addClickEventListener(function()
       -- 播放音效
        ExternalFun.playClickEffect()
        local szScore =  string.gsub(csbNode:getChildByName("Exchange_Num_Title"):getChildByName("Edit"):getString(),"([^0-9])","")
		
        szScore = string.gsub(szScore, "[.]", "")
        if #szScore < 1 then 
            QueryDialog:create("请输入转出余额", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
            return
        end
	    local lOperateScore = tonumber(szScore)
        --print("Can Use Number -- "..self.money)
        if lOperateScore > tonumber(GlobalUserItem.lUserScore) then
            QueryDialog:create("您当前可转出余额不足,请重新输入提现余额！", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
            return
        end

        -- 发起提现申请
        local ostime = os.time()
        local payTpye
        if self._index == 1 then
            payTpye = "BTC"
        elseif self._index == 2 then
            payTpye = "ETH"
        elseif self._index == 3 then
            payTpye = "PAI"
        end
	    local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	    appdf.onHttpJsionTable(url ,"GET","action=updateuseroutcoin&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime).. "&money="..lOperateScore .. "&type="..payTpye.."&address=asd",function(sjstable,sjsdata)
        
            if type(sjstable) == "table" then
                local data = sjstable["data"]
                if type(data) == "table" then
                    local valid = data["valid"]
                    if true == valid then
                        local msg = sjstable["msg"]
                        if msg == "0" then
                            QueryDialog:create("操作失败", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
                            return
                        else
			    --self:showMoney()
                            QueryDialog:create("操作成功", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
                            return
                        end
                    else 
                    local msg = sjstable["msg"]
                    QueryDialog:create("操作失败"..msg, nil, nil, QueryDialog.QUERY_SURE):addTo(self)
                    return
                    end
                    
                end
            end

            QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
        end)
    end)
end

function ExchangeLayer:updatePage( index )
    self._index = index
    for i=1,2 do
        local item = self.wallte_node:getChildByName("CheckBox_"..i)
        item:setSelected(index == i)
       
        item:setTouchEnabled( not (index == i))
    end
end

--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function ExchangeLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

end

return ExchangeLayer