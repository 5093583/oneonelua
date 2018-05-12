--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local CashRecordLayer = class("CashRecordLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

c_pos = {
    cc.p(554, 350),
    cc.p(554, 280),
    cc.p(554, 209),
    cc.p(554, 140),
    cc.p(554, 70)
}

function CashRecordLayer:ctor(scene)
    self._scene = scene
    local this = self
    -- 当前第几页
    self._curIdx = 1
    -- 一共有几页
    self._maxIdx = 1
    -- 每页有几条
    self._count = 6
    -- 共有多少条记录
    self._reIdx = 0
    -- 记录
    self._infos = {}
    --节点事件
    ExternalFun.registerNodeEvent(self)
    --加载csb资源
    local csbNode = ExternalFun.loadCSB("Deposit/CashRecordLayer.csb"):addTo(self)
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
    -- 查询提现信息
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=GetWithdrawList&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
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
--清理记录
function CashRecordLayer:clearPanel()

    for i = 1, 6 do
        self._panel:removeChildByName("sprite")       
        self._panel:getChildByName("time_"..i):setString("")
        self._panel:getChildByName("Text_"..i):setString("")
        self._panel:getChildByName("falg_"..i):setString("")
    end

    --print(self._maxIdx)
end
--初始化提现记录
function CashRecordLayer:initPanel()
    self:clearPanel()
    self._maxIdx = math.ceil(self._reIdx / self._count)
    self._panel:getChildByName("Text_index"):setString(self._curIdx .. "/" .. self._maxIdx);
    local idx = (self._curIdx - 1) * self._count + 1
    local endIdx = self._curIdx * self._count
    if endIdx > self._reIdx then
        endIdx = self._reIdx
    end

    for i = idx, endIdx do
        
        local index = i - (self._curIdx - 1) * self._count
        local pString = self:getTime(self._infos[i]["WithdrawDate"])
        self._panel:getChildByName("time_"..index):setString(pString)
        self._panel:getChildByName("Text_"..index):setString("提现"..self._infos[i]["Withdrawals"].."元")

        if self._infos[i]["Status"] == 1 then
            self._panel:getChildByName("falg_"..index):setString("已到帐")
            self._panel:getChildByName("falg_"..index):setTextColor(cc.c4b(0, 255, 0, 255))
        else
            self._panel:getChildByName("falg_"..index):setString("未到帐")
            self._panel:getChildByName("falg_"..index):setTextColor(cc.c4b(255, 0, 0, 255))
        end
        
        if index ~= 6 then 
            local sprite = cc.Sprite:create("Deposit/img_line.png")
            if sprite ~= nil then
                self._panel:addChild(sprite)
                sprite:setPosition(c_pos[index])
                sprite:setName("sprite")
            end
        end
    end

    --print(self._maxIdx)
end

function CashRecordLayer:getTime(str)

    str = string.split(str, " ")
    strs = string.split(str[1], "/")
    return strs[1] .. "." .. strs[2] .. "." .. strs[3]

end

return CashRecordLayer


--endregion
