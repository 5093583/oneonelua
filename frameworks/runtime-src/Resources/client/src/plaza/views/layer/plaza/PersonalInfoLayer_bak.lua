--个人信息
local PersonalInfoLayer = class("PersonalInfoLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

local BindingLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BindingLayer")
local SpreadingLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.SpreadingLayer")
local MySpreaderLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.MySpreaderLayer")
local ShopLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")
local BankLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankLayer")
local BankEnableLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.BankEnableLayer")
local ModifyAvatarLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ModifyAvatarLayer")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

function PersonalInfoLayer:ctor()

    --网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --事件监听
    self:initEventListener()

    --节点事件
    ExternalFun.registerNodeEvent(self)

    local csbNode = ExternalFun.loadCSB("PersonalInfo/PersonalInfoLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")

    --审核隐藏房卡
    if yl.APPSTORE_VERSION then

        local maskLayout = ccui.Layout:create()
        maskLayout:setContentSize(724, 78)
        maskLayout:setPosition(320, 200)
        maskLayout:setBackGroundColor(cc.c3b(255, 242, 223))
        maskLayout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        maskLayout:setTouchEnabled(true)
        maskLayout:addTo(self._content)
    end

    self.acount_node = self._content:getChildByName("acount_node")
    self.name_node = self._content:getChildByName("name_node")
    self.coin_node = self._content:getChildByName("coin_node")
    self.fangka_node = self._content:getChildByName("fangka_node")
    self.signature_node = self._content:getChildByName("signature_node")

    local editUnderwrite = self.signature_node:getChildByName("edit_underwrite")

    --关闭
    local btnClose = self._content:getChildByName("btn_close")
    btnClose:addClickEventListener(function()

        --播放音效
        --ExternalFun.playClickEffect()
        --self.onKeyBack()
        dismissPopupLayer(self)
    end)

    --头像按钮
    local btnAvatar = self._content:getChildByName("btn_avatar")
    btnAvatar:addClickEventListener(function()

        --播放音效
        --ExternalFun.playClickEffect()
        local backse=ModifyAvatarLayer:create()
        yl.ClientScene:addBackFunc(backse)
        showPopupLayer(backse, false)
    end)

    --更换头像提示
    local posX, posY = btnAvatar:getPosition()
    cc.Sprite:create("PersonalInfo/sp_modify_avatar_tip.png")
        :setAnchorPoint(0.5, 0)
        :setPosition(posX, posY - 60)
        :addTo(self._content, 10)

    --性别
    self._checkMan = self._content:getChildByName("check_man")
    self._checkWoman = self._content:getChildByName("check_woman")
    self._checkMan:setSelected(GlobalUserItem.cbGender == 1)
    self._checkWoman:setSelected(GlobalUserItem.cbGender == 0)

    local checkClickFunc = function(ref)
        self:onClickSex(ref)
    end
    self._checkMan:addEventListener(checkClickFunc)
    self._checkWoman:addEventListener(checkClickFunc)

    --游戏ID
    local txtGameID = self._content:getChildByName("txt_gameid")
    txtGameID:setString(GlobalUserItem.dwGameID)
    print("*******************"..GlobalUserItem.dwGameID.."*******************")
    --账号
    local txtAccount = self.acount_node:getChildByName("txt_accounts")
    txtAccount:setString(GlobalUserItem.szAccount)

    --昵称
    local txtNickName = self._content:getChildByName("txt_nick_name")
    txtNickName:setString(GlobalUserItem.szNickName)
    print("**********"..GlobalUserItem.szNickName.."**********")
    --真实姓名
--    local txtName = self._content:getChildByName("txt_user_name")
--    txtName:setString(GlobalUserItem.szTrueName)
    --游戏币
    local txtGold = self._content:getChildByName("txt_money_num")
    txtGold:setString(GlobalUserItem.dwGameID)

    --游戏豆
--    local txtBean = self._content:getChildByName("txt_bean")
--    txtBean:setString(ExternalFun.numberThousands(GlobalUserItem.dUserBeans))

    --房卡
    self.txtRoomCard = self._content:getChildByName("txt_score_num")
    --txtRoomCard:setString(ExternalFun.numberThousands(GlobalUserItem.lRoomCard))

    --头像
    self:onUpdateUserFace()

    --个性签名输入框 
	self._editUnderwrite = ccui.EditBox:create(editUnderwrite:getContentSize(), "blank.png")
		:move(editUnderwrite:getPosition())
		:setAnchorPoint(cc.p(0, 1))
        :setFontSize(30)
        :setFontColor(cc.c3b(255, 255, 255))
		:setFontName("fonts/round_body.ttf")
		:setPlaceholderFontName("fonts/round_body.ttf")
		:setPlaceholderFontSize(30)
        :setPlaceHolder("这个家伙很懒，什么都没留下")
        --:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
		:setMaxLength(200)
        :setText(GlobalUserItem.szSign)
		:addTo(editUnderwrite:getParent())
        self._editUnderwrite:registerScriptEditBoxHandler(function(name, sender)
            self:onEditEvent(name, sender)
        end)
    editUnderwrite:removeFromParent()

    --复制ID
    local btnCopyID = self._content:getChildByName("btn_copyid")
    btnCopyID:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()

        MultiPlatform:getInstance():copyToClipboard("昵称："..GlobalUserItem.szNickName.."，ID："..GlobalUserItem.dwGameID)
        showToast(nil, "已复制到剪贴板", 2)
    end)

    -- --我的推广码
    -- local btnSpreading = self._content:getChildByName("btn_spreading")
    -- btnSpreading:setVisible(not yl.APPSTORE_VERSION)
    -- btnSpreading:addClickEventListener(function()

    --     --播放音效
    --     ExternalFun.playClickEffect()

    --     showPopupLayer(SpreadingLayer:create(), false)
    -- end)

    --我的推荐人
    self.sp_recommender = self._content:getChildByName("sp_recommender")
    self.sp_recommender:setVisible(false)
    self.txt_recommenderId = self._content:getChildByName("txt_recommenderId")
    self.txt_recommenderId:setVisible(false)
    self.sp_binded = self._content:getChildByName("sp_binded")
    self.sp_binded:setVisible(false)

    local btnMySpreader = self._content:getChildByName("btn_my_spreader")
    btnMySpreader:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()

        showPopupLayer(MySpreaderLayer:create(), false)
    end)

    --绑定
    local btnBinding = self.acount_node:getChildByName("btn_binding")
    local sp_cert = self.acount_node:getChildByName("sp_certed")
    btnBinding:setVisible(GlobalUserItem.bVisitor)
    sp_cert:setVisible(not GlobalUserItem.bVisitor)

    if GlobalUserItem.bVisitor then
        btnBinding:addClickEventListener(function()
            
            --播放音效
            ExternalFun.playClickEffect()

            showPopupLayer(BindingLayer:create(), false)
        end)
    end

    --保存修改
    local btnSave = self._content:getChildByName("btn_save")
    btnSave:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()

        self:saveDeposit()
    end)

    --创建编辑框
    --收款人姓名
    local sp_name_bg = self._content:getChildByName("img_player_name")
    self.edSName = self:onCreateEditBox(sp_name_bg, false, false, 33)
    self.edSName:setPlaceHolder("保存后将无法再次更改")
    --手机号
    local sp_phone_bg = self._content:getChildByName("img_phone_num")
    self.edPhone = self:onCreateEditBox(sp_phone_bg, false, true, 19)
    --开户行
    local sp_bank_name = self._content:getChildByName("img_start_bank_name")
    self.edBankName = self:onCreateEditBox(sp_bank_name, false, false, 32)
    --银行帐号
    local sp_bank_acc = self._content:getChildByName("img_bank_acc")
    self.edBankAcc = self:onCreateEditBox(sp_bank_acc, false, true, 32)
    self.edBankAcc:setPlaceHolder("请确保您的银行信息无误")
    --微信帐号
    local sp_wx_acc = self._content:getChildByName("img_wx_acc")
    self.edWXAcc = self:onCreateEditBox(sp_wx_acc, false, false, 32)
    --支付宝帐号
    local sp_al_acc = self._content:getChildByName("img_al_acc")
    self.edALAcc = self:onCreateEditBox(sp_al_acc, false, false, 32)
    --提现密码
    local sp_password = self._content:getChildByName("img_parssword")
    self.edPassword = self:onCreateEditBox(sp_password, true, false, 33)
    --密保答案
--    local sp_lock = self._content:getChildByName("img_lock_txt")
--    self.edLock = self:onCreateEditBox(sp_lock, false, false, 32)


    self:initDeposit()
    --local spEditBg = self._parent:getChildByName("sp_input")
    --self._input = self:onCreateEditBox(spEditBg, true, 12)
    --取款
--    local btnTake = self.coin_node:getChildByName("btn_take")
--    btnTake:addClickEventListener(function()

--        --播放音效
--        ExternalFun.playClickEffect()

--        dismissPopupLayer(self)

--        local scene = cc.Director:getInstance():getRunningScene()
--        if GlobalUserItem.cbInsureEnabled == 0 then
--            showPopupLayer(BankEnableLayer:create(function()
--                BankLayer:create():addTo(scene)
--            end))
--        else
--            BankLayer:create():addTo(scene)
--        end

--    end)

    --充值游戏豆
--    local btnRecharge = self._content:getChildByName("btn_recharge")
--    btnRecharge:addClickEventListener(function()

--        --播放音效
--        ExternalFun.playClickEffect()

--        dismissPopupLayer(self)

--        local scene = cc.Director:getInstance():getRunningScene()
--        ShopLayer:create(1):addTo(scene)
--    end)

   --购买房卡
--    local btnBuy = self.fangka_node:getChildByName("btn_buy")
--    btnBuy:setVisible(false) --2017.8.13 取消房卡购买
--    btnBuy:addClickEventListener(function()

--        --播放音效
--        ExternalFun.playClickEffect()

--        dismissPopupLayer(self)

--        local scene = cc.Director:getInstance():getRunningScene()
--        ShopLayer:create(3):addTo(scene)
--    end)

    --内容跳入
--    AnimationHelper.jumpIn(self._content, function()

--        --编辑框在动画后有BUG，调整大小让编辑框可以显示文字
--        self._editUnderwrite:setContentSize(self._editUnderwrite:getContentSize())
--    end)
end

--初始化事件监听
function PersonalInfoLayer:initEventListener()

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()

    --用户信息改变事件
    eventDispatcher:addEventListenerWithSceneGraphPriority(
        cc.EventListenerCustom:create(yl.RY_USERINFO_NOTIFY, handler(self, self.onUserInfoChange)),
        self
        )
end

--初始化用户提现信息
function PersonalInfoLayer:initDeposit()

    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=getdepositinfo&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            dump(data)
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    --self.edPhone:setText(data["data"]["PhoneNum"])    
                    self.edBankName:setText(data["data"]["BankName"])
                    self.edBankAcc:setText(data["data"]["BankAccounts"])
                    self.edSName:setText(data["data"]["LockText"])
                    self.edWXAcc:setText(data["data"]["WXAccounts"])
                    self.edALAcc:setText(data["data"]["ALAccounts"])
                    self.edPassword:setText(data["data"]["DPassword"])
                    self.txtRoomCard:setText(data["data"]["PWXAccounts"])
                    --self.edLock:setText(data["data"]["LockText"])
                    if data["data"]["WXAccounts"] ~= "" then
                        self.edSName:setEnabled(false)
                    end
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)

end

--保存用户提现信息
function PersonalInfoLayer:saveDeposit()
    
    local phone = self.edPhone:getText()
    local bankName = appdf.utf8tounicode(self.edBankName:getText())
    local bankAcc = self.edBankAcc:getText()
    local wxacc = self.edWXAcc:getText()
    local sname = appdf.utf8tounicode(self.edSName:getText())
    local alacc = self.edALAcc:getText()
    local pass = self.edPassword:getText()
    local lock = ""
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=updatadepositinfo&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime)
    .."&PhoneNum="..phone.."&BankName="..bankName.."&BankAccounts="..bankAcc.."&WXAccounts="..wxacc.."&ALAccounts="..alacc.."&DPassword="..pass.."&LockText="..sname,function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                
                if true == valid then
                    if wxacc ~= "" then
                        self.edSName:setEnabled(false)
                    end
                    local msg = data["msg"]
                    if msg ~= "" then
                         QueryDialog:create(msg, nil, nil, QueryDialog.QUERY_SURE):addTo(self)
                    else 
                    QueryDialog:create("个人信息保存成功", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
                    end
                    return
                else
                    QueryDialog:create("操作失败，请重试", nil, nil, QueryDialog.QUERY_SURE):addTo(self)
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)

end

--创建编辑框
function PersonalInfoLayer:onCreateEditBox(spEditBg, isPassword, isNumeric, maxLength)
    
    local inputMode = isNumeric and cc.EDITBOX_INPUT_MODE_NUMERIC or cc.EDITBOX_INPUT_MODE_SINGLELINE

    local sizeBg = spEditBg:getContentSize()
    local editBox = ccui.EditBox:create(cc.size(sizeBg.width - 16, sizeBg.height - 16), "")
		:move(sizeBg.width / 2, sizeBg.height / 2)
        :setFontSize(24)
        :setFontColor(cc.BLACK)
		:setFontName("mysh.ttf")
		:setMaxLength(maxLength)
        :setInputMode(inputMode)
        :setPlaceholderFontSize(24)
        :setPlaceholderFontName("mysh.ttf")
		:addTo(spEditBg) 

    --密码框
    if isPassword then
        editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    end

    return editBox
end

--清空编辑框
function PersonalInfoLayer:onClearEditBoxs( editBox )   
    editBox:setText("");
end

--------------------------------------------------------------------------------------------------------------------
-- 事件处理

--用户信息改变
function PersonalInfoLayer:onUserInfoChange(event)
    
    print("----------PersonalInfoLayer:onUserInfoChange------------")

	local msgWhat = event.obj
	if nil ~= msgWhat then

        if msgWhat == yl.RY_MSG_USERWEALTH then
		    --更新财富
		    --self:onUpdateScoreInfo()
        elseif msgWhat == yl.RY_MSG_USERHEAD then
            --更新用户头像
            self:onUpdateUserFace()
        end
	end
end

--更新用户头像
function PersonalInfoLayer:onUpdateUserFace()
    
    local headSprite = self._content:getChildByName("sp_avatar")
    if headSprite then

        headSprite:updateHead(GlobalUserItem)
    else

        local btnAvatar = self._content:getChildByName("btn_avatar")

        headSprite = HeadSprite:createClipHead(GlobalUserItem, 120, "sp_avatar_mask_120.png")
        headSprite:setPosition(btnAvatar:getPosition())
        headSprite:addTo(self._content)
        self._content:getChildByName("Image_11"):setLocalZOrder(1)
    end
end
function PersonalInfoLayer:onKeyBack()
    yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --播放音效
    ExternalFun.playClickEffect()

    dismissPopupLayer(self)
end
function PersonalInfoLayer:onExit()

	if self._modifyFrame:isSocketServer() then
		self._modifyFrame:onCloseSocket()
	end
end

function PersonalInfoLayer:onEditEvent(name, sender)

    if name == "return" then

        --修改资料
        self:onSubmit()
    end
end

--点击性别
function PersonalInfoLayer:onClickSex(ref)

    --播放音效
    ExternalFun.playClickEffect()

    self._checkMan:setSelected(ref == self._checkMan)
    self._checkWoman:setSelected(ref == self._checkWoMan)

    self:onSubmit()
end

--提交信息
function PersonalInfoLayer:onSubmit()
    
    showPopWait()

    local cbGender = self._checkMan:isSelected() and yl.GENDER_MANKIND or yl.GENDER_FEMALE
    local szNickName = GlobalUserItem.szNickName
    local szSign = self._editUnderwrite:getText()

    self._modifyFrame:onModifyUserInfo(cbGender, szNickName, szSign)
end

--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function PersonalInfoLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

    local bGender = (GlobalUserItem.cbGender == yl.GENDER_MANKIND and true or false)
	self._checkMan:setSelected(bGender)
	self._checkWoman:setSelected(not bGender)
end

return PersonalInfoLayer