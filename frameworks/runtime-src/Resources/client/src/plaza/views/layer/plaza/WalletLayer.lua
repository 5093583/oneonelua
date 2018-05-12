--个人信息
local WalletLayer = class("WalletLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")

function WalletLayer:ctor(index)

    self._index = index
  print("walletlayer%d",index)

    --节点事件
    ExternalFun.registerNodeEvent(self)

    local csbNode = ExternalFun.loadCSB("plaza/walletLayer.csb"):addTo(self)

    self.avatar_node = csbNode:getChildByName("bg")
  
    --关闭
    local btnClose = self.avatar_node:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)

    --确认按钮
    local btn_avatar = self.avatar_node:getChildByName("btn_ok")
    btn_avatar:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
       self:onClickOk()
    end)

   --输入框
    self._editAccount = self:onCreateEditBox(self.avatar_node:getChildByName("kuang"), false, false, 100)
   
end

function WalletLayer:onClickOk(  )
    -- body
    local szAccount = string.gsub(self._editAccount:getText(), " ", "")
    if szAccount == "" then
        QueryDialog:create("钱包地址不能为空", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
        return 
    end
    if self._index == 1 then
        payTpye = "BTC"
    elseif self._index == 2 then
        payTpye = "ETH"
    elseif self._index == 3 then
            payTpye = "PAI"
    end
    local ostime = os.time()
    local url = yl.HTTP_URL .. "/WS/Account.ashx"
        appdf.onHttpJsionTable(url ,"GET","action=updateuseroutcoin&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime).."&type="..payTpye.."&address="..szAccount,function(sjstable,sjsdata)
        
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
                            local call_back = function ( bok )
                                if ok then
                                    
                                end
                            end
                            QueryDialog:create("操作成功", call_back, nil, QueryDialog.QUERY_SURE):addTo(self)
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
end

function WalletLayer:onCreateEditBox(spEditBg, isPassword, isNumeric, maxLength)
    
    local inputMode = isNumeric and cc.EDITBOX_INPUT_MODE_NUMERIC or cc.EDITBOX_INPUT_MODE_SINGLELINE

    local sizeBg = spEditBg:getContentSize()
    local editBox = ccui.EditBox:create(cc.size(sizeBg.width - 16, sizeBg.height - 16), "")
        :move(sizeBg.width / 2, sizeBg.height / 2)
        :setFontSize(32)
        :setFontColor(ccc3(170,170,170))
        :setFontName("fonts/round_body.ttf")
        :setMaxLength(maxLength)
        :setInputMode(inputMode)
        :addTo(spEditBg) 

    --密码框
    if isPassword then
        editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    end

    return editBox
end

return WalletLayer