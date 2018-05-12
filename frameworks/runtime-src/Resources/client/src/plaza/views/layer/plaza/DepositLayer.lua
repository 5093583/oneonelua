--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
--提现
local DepositLayer = class("DepositLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local OperateLayer = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.plaza.OperateLayer")
local CashRecordLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.CashRecordLayer")
local MemberListLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.MemberListLayer")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local week=0
local fp=nil
function DepositLayer:ctor(scene)
    self._scene = scene
pos = {
    cc.p(667, 519),
    cc.p(667, 440),
    cc.p(667, 360)
}
    --节点事件
    ExternalFun.registerNodeEvent(self)
    --加载csb资源
    local csbNode = ExternalFun.loadCSB("Deposit/DepositLayer.csb"):addTo(self)
    self._parent = csbNode:getChildByName("Panel_1")
	fp=self
    --关闭
    self._parent:getChildByName("btn_Close"):addClickEventListener(function()       
        -- 播放音效
        --ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)
    --提现
    self._parent:getChildByName("btn_deposit"):addClickEventListener(function()
        -- 播放音效
        ExternalFun.playClickEffect()
        if self._parent:getChildByName("WithdrawCommission"):getString() ~= "0" then
            local result=self:Y2J(self._parent)
--        else
--            showPopupLayer(OperateLayer:create(self._scene))
--            -- 关闭窗口
			
            --dismissPopupLayer(self)
--self.onKeyBack()
        end

    end)
    -- 提现记录
    self._parent:getChildByName("btn_re"):addClickEventListener(function()
        -- 播放音效
        ExternalFun.playClickEffect()
        showPopupLayer(CashRecordLayer:create(self._scene))
        -- 关闭窗口
        dismissPopupLayer(self)
    end)
    -- 会员列表
    self._parent:getChildByName("btn_show"):addClickEventListener(function()
        -- 播放音效
        ExternalFun.playClickEffect()
        showPopupLayer(MemberListLayer:create(self._scene))
        -- 关闭窗口
        dismissPopupLayer(self)
    end)

    for i=1,3 do
        local sprite = cc.Sprite:create("Deposit/img_line.png")
        if sprite ~= nil then
            self._parent:addChild(sprite)
            sprite:setPosition(pos[i])
        end
    end

    -- 请求当前代理的基础信息
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=GetAgentGrant&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)

        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
                    local tab = data["data"]
                    self._parent:getChildByName("WeekGrant"):setString(tab["WeekGrant"])
                    self._parent:getChildByName("AgentUserGrant"):setString(tab["AgentUserGrant"])
                    self._parent:getChildByName("LowUserGrant"):setString(tab["LowUserGrant"])
                    self._parent:getChildByName("WeekCommission"):setString(tab["WeekCommission"])
					week=tab["WeekCommission"]
                    --self._parent:getChildByName("AgentCommission"):setString(tab["AgentCommission"])
                    self._parent:getChildByName("SumCommission"):setString(tab["SumCommission"])
                    self._parent:getChildByName("WithdrawCommission"):setString(tab["WithdrawCommission"])
                    self._parent:getChildByName("Gold"):setString(tab["Gold"])
                    self._parent:getChildByName("LowUserNum"):setString(tab["LowUserNum"])
                    self._parent:getChildByName("WeekLowUserNum"):setString(tab["WeekLowUserNum"])
                    self._parent:getChildByName("MonthLowUserNum"):setString(tab["MonthLowUserNum"])
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)

    -- 请求当前代理的基础信息
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=getcommtext&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)

        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
                    local msg = sjstable["msg"]
                    self._parent:getChildByName("Text_1"):setString(msg)
                    return
                end
            end
        end
        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)

end

--初始化用户提现信息
function DepositLayer:Y2J(_parent)

    --一键提现佣金到金币余额
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=withdrawcomm&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)

        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
                    --local tab = data["data"]
					GlobalUserItem.lUserScore=data["Gold"]
                    --通知更新        
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
	    eventListener.obj = yl.RY_MSG_USERWEALTH
	    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
                    _parent:getChildByName("WithdrawCommission"):setString(data["WithdrawCommission"])
					_parent:getChildByName("SumCommission"):setString(week)

			QueryDialog:create("成功将佣金提现到金币余额", nil, nil, QueryDialog.QUERY_SURE):addTo(fp)
			return 
	
                    
                    
                end
            end
        end
		
		--DepositLayer:Error()
        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(fp) 
    end)
end

function DepositLayer:onKeyBack()
    yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --播放音效
    ExternalFun.playClickEffect()

    dismissPopupLayer(self)
end
return DepositLayer
--endregion
