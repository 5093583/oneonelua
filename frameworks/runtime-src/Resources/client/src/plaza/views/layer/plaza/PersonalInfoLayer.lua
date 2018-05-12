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
local WalletLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.WalletLayer")

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

    self.avatar_node = csbNode:getChildByName("Avatar_Node")
    self.bind_node = csbNode:getChildByName("Bind_Node")
    self.tab_node = csbNode:getChildByName("Tab_Node")
    self.layout_wallet = self.tab_node:getChildByName("Wallet_Layout")

    --关闭
    local btnClose = csbNode:getChildByName("Close_Btn")
    btnClose:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)
    --添加
    local btn_btc_Add = self.layout_wallet:getChildByName("BTC_Add_Btn")
    btn_btc_Add:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        showPopupLayer(WalletLayer:create(1))
    end)

    local btn_eht_Add = self.layout_wallet:getChildByName("EHT_Add_Btn")
    btn_eht_Add:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        showPopupLayer(WalletLayer:create(2))
    end)

    local btn_usdt_Add = self.layout_wallet:getChildByName("USDT_Add_Btn")
    btn_usdt_Add:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        showPopupLayer(WalletLayer:create(3))
    end)

    --头像按钮
    local btn_avatar = self.avatar_node:getChildByName("Avatar_Btn")
    btn_avatar:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        local backse=ModifyAvatarLayer:create()
        yl.ClientScene:addBackFunc(backse)
        showPopupLayer(backse, false)
    end)

    --更换头像提示
    local posX, posY = btn_avatar:getPosition()
    cc.Sprite:create("PersonalInfo/sp_modify_avatar_tip.png")
        :setAnchorPoint(0.5, 0)
        :setPosition(posX, posY - 130)
        :addTo(self.avatar_node, 10)

    --性别
    --判定PersonalInfoLayer.plist文件是否加载
    local isLoad = cc.SpriteFrameCache:getInstance():isSpriteFramesWithFileLoaded("PersonalInfoLayer/PersonalInfoLayer.plist")
    if not isLoad then
        --加载plist文件
        cc.SpriteFrameCache:getInstance():addSpriteFrames("PersonalInfoLayer/PersonalInfoLayer.plist")
    end

    local sp_sex = self.avatar_node:getChildByName("Sex_Sp")

    if (GlobalUserItem.cbGender == 1) then
        local sf_male = cc.SpriteFrameCache:getInstance():getSpriteFrame("sex_male.png")
        sp_sex:setSpriteFrame(sf_male)
    elseif (GlobalUserItem.cbGender == 0) then
        local sf_female = cc.SpriteFrameCache:getInstance():getSpriteFrame("sex_female.png")
        sp_sex:setSpriteFrame(sf_female);
    end

    --游戏ID
    local txt_gameID = self.avatar_node:getChildByName("Id_Txt")
    txt_gameID:setString(GlobalUserItem.dwGameID)
    print("*******************"..GlobalUserItem.dwGameID.."*******************")

    -- --账号
    -- local txtAccount = self.acount_node:getChildByName("txt_accounts")
    -- txtAccount:setString(GlobalUserItem.szAccount)

    --昵称
    local txt_nick = self.avatar_node:getChildByName("Nick_Txt")
    txt_nick:setString(GlobalUserItem.szNickName)
    print("**********"..GlobalUserItem.szNickName.."**********")

    -- --真实姓名
    -- local txtName = self._content:getChildByName("txt_user_name")
    -- txtName:setString(GlobalUserItem.szTrueName)

    --游戏币
    local txt_btc = self.avatar_node:getChildByName("BTC_Num")
    txt_btc:setString(ExternalFun.formatScoreText(GlobalUserItem.lUserScore) .. " BTC")

    -- --游戏豆
    -- local txtBean = self._content:getChildByName("txt_bean")
    -- txtBean:setString(ExternalFun.numberThousands(GlobalUserItem.dUserBeans))

    -- --房卡
    -- self.txtRoomCard = self._content:getChildByName("txt_score_num")
    -- txtRoomCard:setString(ExternalFun.numberThousands(GlobalUserItem.lRoomCard))

    --头像
    self:onUpdateUserFace()

    -- --个性签名输入框 
    -- self._editUnderwrite = ccui.EditBox:create(editUnderwrite:getContentSize(), "blank.png")
    --     :move(editUnderwrite:getPosition())
    --     :setAnchorPoint(cc.p(0, 1))
    --     :setFontSize(30)
    --     :setFontColor(cc.c3b(255, 255, 255))
    --     :setFontName("fonts/round_body.ttf")
    --     :setPlaceholderFontName("fonts/round_body.ttf")
    --     :setPlaceholderFontSize(30)
    --     :setPlaceHolder("这个家伙很懒，什么都没留下")
    --     --:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    --     :setMaxLength(200)
    --     :setText(GlobalUserItem.szSign)
    --     :addTo(editUnderwrite:getParent())
    --     self._editUnderwrite:registerScriptEditBoxHandler(function(name, sender)
    --         self:onEditEvent(name, sender)
    --     end)
    -- editUnderwrite:removeFromParent()

    -- --复制ID
    -- local btnCopyID = self._content:getChildByName("btn_copyid")
    -- btnCopyID:addClickEventListener(function()
        
    --     --播放音效
    --     ExternalFun.playClickEffect()

    --     MultiPlatform:getInstance():copyToClipboard("昵称："..GlobalUserItem.szNickName.."，ID："..GlobalUserItem.dwGameID)
    --     showToast(nil, "已复制到剪贴板", 2)
    -- end)

    -- --我的推荐人
    -- self.sp_recommender = self._content:getChildByName("sp_recommender")
    -- self.sp_recommender:setVisible(false)
    -- self.txt_recommenderId = self._content:getChildByName("txt_recommenderId")
    -- self.txt_recommenderId:setVisible(false)
    -- self.sp_binded = self._content:getChildByName("sp_binded")
    -- self.sp_binded:setVisible(false)

    -- local btnMySpreader = self._content:getChildByName("btn_my_spreader")
    -- btnMySpreader:addClickEventListener(function()

    --     --播放音效
    --     ExternalFun.playClickEffect()

    --     showPopupLayer(MySpreaderLayer:create(), false)
    -- end)

    --绑定手机
    local btn_bind_phone = self.bind_node:getChildByName("Phone_Btn")
    btn_bind_phone:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()
        showPopupLayer(BindingLayer:create(), false)
        showToast(self, "该功能暂未开通，敬请期待", 2)
    end)

    --绑定推荐人
    local btn_bind_referrer = self.bind_node:getChildByName("Referrer_Btn")
    btn_bind_referrer:addClickEventListener(function()
        --播放音效
        ExternalFun.playClickEffect()

        showToast(self, "该功能暂未开通，敬请期待", 2)
    end)

    local btn_deposit = self.tab_node:getChildByName("Deposit_Box")
    local btn_getout = self.tab_node:getChildByName("Getout_Box")
    
    --切换按钮
    if btn_deposit and btn_getout then

        local function callback (sender, eventType)
            local selected_type = sender:getChildByName("Bg")
            if selected_type:isVisible() ~= true then
                if sender:getName() == "Deposit_Box" then
                    btn_getout:getChildByName("Bg"):setVisible(false)
                    selected_type:setVisible(true)
                    self:updateWalletLayout(true)
                elseif sender:getName() == "Getout_Box" then
                    btn_deposit:getChildByName("Bg"):setVisible(false)
                    selected_type:setVisible(true)
                    self:updateWalletLayout(false)
                end
                
            end
            
        end
        btn_deposit:addClickEventListener(callback)
        btn_getout:addClickEventListener(callback)
    end
    self:initDeposit()
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

--初始化用户币种信息
function PersonalInfoLayer:initDeposit()

    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=getusercoin&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
          --  dump(data,"77777777777")
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
                    --self.edPhone:setText(data["data"]["PhoneNum"])    
                    --self.edBankName:setText(data["data"]["BTC"])
                    --self.edBankAcc:setText(data["data"]["ETH"])
                    --self.edSName:setText(data["data"]["USDT"])MaxLineWidth
                    
                    local btc_1,btc_2 = self:string_insert(data["BTC"])
                    local eth_1,eth_2 = self:string_insert(data["ETH"])
                    local pai_1,pai_2 = self:string_insert(data["PAI"])

                    self._btc_1,self._btc_2 = btc_1,btc_2
                    self._eth_1,self._eth_2 = eth_1,eth_2
                    self._pai_1,self._pai_2 = pai_1,pai_2

                    self.layout_wallet:getChildByName("BTC_Icon"):getChildByName("Title"):setText(btc_1)
                    self.layout_wallet:getChildByName("BTC_Icon"):getChildByName("Title2"):setText(btc_2)
					self.layout_wallet:getChildByName("EHT_Icon"):getChildByName("Title"):setText(eth_1)
                    self.layout_wallet:getChildByName("EHT_Icon"):getChildByName("Title_2"):setText(eth_2)
					self.layout_wallet:getChildByName("USDT_Icon"):getChildByName("Title"):setText(pai_1)
                    self.layout_wallet:getChildByName("USDT_Icon"):getChildByName("Title_0"):setText(pai_2)
                 --   self:showChatStr(cc.p(0,30),self.str_BTC)
   
    -- local custom_item = ccui.Layout:create()
    -- custom_item:setContentSize(cc.size(viewSize.width, height))
  
    -- custom_item:addChild(txt)
    
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)

    
end

function PersonalInfoLayer:string_insert(str) 
    if str == "" then
        return "",""
    end
    local len = 40
    local ba = len / 2
    local a = string.sub(str,1,ba)
    local b = string.sub(str,ba+1)
     return a,b
end

function PersonalInfoLayer:showChatStr( pos , strChat)

    local txtWidth = string.len(strChat) * 26
    if txtWidth > 200 then
        txtWidth = 100
    end
    local txt = ccui.Text:create()
     txt:setAnchorPoint(cc.p(0, 0))
    txt:setTextAreaSize(cc.size(txtWidth, 0))
    txt:ignoreContentAdaptWithSize(true)
    txt:setString(strChat)
    txt:setFontSize(26)
    -- txt:setPosition(cc.p(5, 5))
    txt:setColor(cc.c3b(85, 121, 123))

    local txtSize = txt:getContentSize()
    local imageView = ccui.ImageView:create()
    imageView:setScale9Enabled(true)
    imageView:loadTexture("PersonalInfo/wallet_bg.png")
    imageView:setContentSize(cc.size(txtSize.width+10, txtSize.height+10))
    imageView:setAnchorPoint(anchor_pos)

    txt:setPosition(cc.p((txtSize.width+10)/2, (txtSize.height+10)/2))
    
    imageView:setPosition(pos)
    -- imageView:setOpacity(128)
    imageView:addChild(txt)
   
    self.tab_node:addChild(imageView, 9999)

  --  imageView:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.RemoveSelf:create() ))
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
    local avatarFrame = self.avatar_node:getChildByName("Avatar_Sp")

    HeadSprite:createClipHead(GlobalUserItem, 290, self)
            :setPosition(avatarFrame:getPosition())
            :setName("sp_avatar")
            :addTo(self.avatar_node, avatarFrame:getLocalZOrder() - 1)
end

--更新钱包布局
function PersonalInfoLayer:updateWalletLayout(isDeposit)
    local btn_add_BTC = self.layout_wallet:getChildByName("BTC_Add_Btn")
    local btn_add_EHT = self.layout_wallet:getChildByName("EHT_Add_Btn")
    local btn_add_USDT = self.layout_wallet:getChildByName("USDT_Add_Btn")
    local btn_copy_BTC = self.layout_wallet:getChildByName("BTC_Copy_Btn")
    local btn_copy_EHT = self.layout_wallet:getChildByName("EHT_Copy_Btn")
    local btn_copy_USDT = self.layout_wallet:getChildByName("USDT_Copy_Btn")

     local text_BTC = self.layout_wallet:getChildByName("BTC_Icon"):getChildByName("Title")
     local text_EHT = self.layout_wallet:getChildByName("EHT_Icon"):getChildByName("Title")
     local text_USDT = self.layout_wallet:getChildByName("USDT_Icon"):getChildByName("Title")
    local text_BTC_2 = self.layout_wallet:getChildByName("BTC_Icon"):getChildByName("Title2")     
    local text_EHT_2 = self.layout_wallet:getChildByName("EHT_Icon"):getChildByName("Title_2")              
    local text_USDT_2 = self.layout_wallet:getChildByName("USDT_Icon"):getChildByName("Title_0")
    if isDeposit == true then
        btn_add_BTC:setVisible(false)
        btn_add_EHT:setVisible(false)
        btn_add_USDT:setVisible(false)
        btn_copy_BTC:setVisible(true)
        btn_copy_EHT:setVisible(true)
        btn_copy_USDT:setVisible(true)

        text_BTC:setText(self._btc_1)
        text_BTC_2:setText(self._btc_2)
        text_EHT:setText(self._eth_1)
        text_EHT_2:setText(self._eth_2)
        text_USDT:setText(self._pai_1)
        text_USDT_2:setText(self._pai_2)
    else
        btn_add_BTC:setVisible(true)
        btn_add_EHT:setVisible(true)
        btn_add_USDT:setVisible(true)
        btn_copy_BTC:setVisible(false)
        btn_copy_EHT:setVisible(false)
        btn_copy_USDT:setVisible(false)

        text_BTC:setText("")
        text_BTC_2:setText("")
        text_EHT:setText("")
        text_EHT_2:setText("")
        text_USDT:setText("")
        text_USDT_2:setText("")
    end
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