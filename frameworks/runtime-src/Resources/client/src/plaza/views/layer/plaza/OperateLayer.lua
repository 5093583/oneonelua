--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local OperateLayer = class("OperateLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local txtFlag=nil
--提现方式
local PAYTYPE = 
{
    ZFB                               = 1,  --支付宝
    YL                                = 2,  --银联
    WX                                = 3   --微信
}

function OperateLayer:ctor(scene)
    self._scene = scene
    -- 默认提现方式为银联
    self._type = PAYTYPE.ZFB

    self.money = ""
	
    --节点事件
    ExternalFun.registerNodeEvent(self)
    --加载csb资源
    local csbNode = ExternalFun.loadCSB("Deposit/OperateLayer.csb"):addTo(self)
    self._parent = csbNode:getChildByName("Panel_1")
    --self.tip = csbNode:getChildByName("Tip")
    --可提现余额
    self.txtMoney = self._parent:getChildByName("txt_money")
    --关闭
    self._parent:getChildByName("btn_Close"):addClickEventListener(function()       
        -- 播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)
    --返回
    self._parent:getChildByName("btn_Back"):setVisible(false)
--    self._parent:getChildByName("btn_Back"):addClickEventListener(function()
--        -- 播放音效
--        ExternalFun.playClickEffect()
--        self._scene:showDepositLayer()
--        dismissPopupLayer(self)
--    end)
    --提现
    self._parent:getChildByName("btn_Operate"):addClickEventListener(function()
        -- 播放音效
        ExternalFun.playClickEffect()

        local szScore =  string.gsub(self._input:getText(),"([^0-9])","")
        szScore = string.gsub(szScore, "[.]", "")
        if #szScore < 1 then 
            QueryDialog:create("请输入提现金额", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
            return
        end

	    local lOperateScore = tonumber(szScore)
	    --if lOperateScore < 50 then
		--    QueryDialog:create("对不起，提现金额不得少于50元", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
		--    return
	    --end
        print("Can Use Number -- "..self.money)
        if lOperateScore > tonumber(self.money) then
            QueryDialog:create("您当前可提现余额不足,请重新输入提现金额！", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
            return
        end

        -- 发起提现申请
        local ostime = os.time()
	    local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	    appdf.onHttpJsionTable(url ,"GET","action=Withdraw&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime).. "&money="..lOperateScore .. "&type=".. self._type,function(sjstable,sjsdata)
        
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
						self:showMoney()
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
txtFlag=nil
    --刷新当前可提现金额
    self:showMoney()

    local cbtlistener = function (sender,eventType)
    self:onSelectedEvent(sender:getTag(),sender)
    end

    -- 提现方式选项
    for i = 1, 3 do
        local checkbx = self._parent:getChildByName("check_" .. i)       
        if nil ~= checkbx then
            checkbx:setTag(i)
            checkbx:addEventListener(cbtlistener)
            if i==self._type then
            checkbx:setSelected(true)
            else
            checkbx:setSelected(false)
            end
        end
    end

    --提现金额
    local spEditBg = self._parent:getChildByName("sp_input")
    self._input = self:onCreateEditBox(spEditBg, true, 12)

end

--初始化可提现金额
function OperateLayer:showMoney()
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=GetBalance&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)

        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    -- 处理基本信息的显示
                    self.money = sjstable["msg"]
                    print("=========="..self.money)
                    GlobalUserItem.lUserScore=self.money
                    --通知更新        
		local eventListener = cc.EventCustom:new(yl.RY_USERINFO_NOTIFY)
	    eventListener.obj = yl.RY_MSG_USERWEALTH
	    cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventListener)
                    if money ~= "" then
                        self.txtMoney:setString(self.money)
                        local m = self.money / 100
						if txtFlag ~=nil then
						print("txtFlag!=nil")
						txtFlag:setString("(可兑换"..m.."元)")
						else 
						print("txtFlag==nil")
                        txtFlag = ccui.Text:create("(可兑换"..m.."元)", "fonts/round_body.ttf", 22)
                        txtFlag:setAnchorPoint(0, 0.5)
                        local x = self.txtMoney:getContentSize().width + 405
                        txtFlag:setPosition(x, 555)
                        txtFlag:addTo(self)
						end
                        return
                    else
                        self.txtMoney:setString("0")
                        local txtFlag = ccui.Text:create("(可提人民币0元)", "fonts/round_body.ttf", 22)
                        txtFlag:setAnchorPoint(0, 0.5)
                        local x = self.txtMoney:getContentSize().width + 405
                        txtFlag:setPosition(x, 555)
                        txtFlag:addTo(self)
                        return
                    end
                end
            end
        end

        QueryDialog:create("查询失败,网络错误", function ()
            dismissPopupLayer(self)
        end, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)
end


function OperateLayer:onSelectedEvent(tag, sender)
    for i = 1, 3 do
        local checkbx = self._parent:getChildByName("check_" .. i)       
        if nil ~= checkbx then
            checkbx:setSelected(false)
        end
    end
    sender:setSelected(true)
    self._type = tag
    print("当前选择提现方式: -- "..tag)
end

--创建编辑框
function OperateLayer:onCreateEditBox(spEditBg, isNumeric, maxLength)
    
    local inputMode = isNumeric and cc.EDITBOX_INPUT_MODE_NUMERIC or cc.EDITBOX_INPUT_MODE_SINGLELINE

    local sizeBg = spEditBg:getContentSize()
    local editBox = ccui.EditBox:create(cc.size(sizeBg.width - 16, sizeBg.height - 16), "")
		:move(sizeBg.width / 2, sizeBg.height / 2)
        :setFontSize(30)
        :setFontColor(cc.WHITE)
		:setFontName("fonts/round_body.ttf")
		:setMaxLength(maxLength)
        :setInputMode(inputMode)
		:addTo(spEditBg) 

    return editBox
end

--清空编辑框
function OperateLayer:onClearEditBoxs()   
    self._input:setText("");
end

return OperateLayer


--endregion
