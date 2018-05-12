-- 福利
local PopularizeLayer = class("PopularizeLayer", cc.Layer)

local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local AnimationHelper = appdf.req(appdf.EXTERNAL_SRC .. "AnimationHelper")
local MultiPlatform = appdf.req(appdf.EXTERNAL_SRC .. "MultiPlatform")

local ActivityIndicator = appdf.req(appdf.CLIENT_SRC .. "plaza.views.layer.general.ActivityIndicator")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local CheckinFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.CheckinFrame")
local RequestManager = appdf.req(appdf.CLIENT_SRC.."plaza.models.RequestManager")

local LogonRewardLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.LogonRewardLayer")
local ShopLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.ShopLayer")
local TargetShareLayer = appdf.req(appdf.CLIENT_SRC.."plaza.views.layer.plaza.TargetShareLayer")
local HeadSprite = appdf.req(appdf.EXTERNAL_SRC .. "HeadSprite")

function PopularizeLayer:ctor()

    --节点事件
    ExternalFun.registerNodeEvent(self)
    self.idx = {1, 2, 3, 4, 5}
	--网络处理
	self._checkinFrame = CheckinFrame:create(self, function(result, message)
        return self:onCheckInCallBack(result, message)
    end)

    local csbNode = ExternalFun.loadCSB("Welfare/PopularizeLayer.csb"):addTo(self)
    self._content = csbNode:getChildByName("content")
    self._content:getChildByName("Sprite_1"):setVisible(false)
    -- 关闭
    self._content:getChildByName("btn_close"):addClickEventListener( function()

        -- 播放音效
        --ExternalFun.playClickEffect()
        --self.onKeyBack()
        dismissPopupLayer(self)
    end )
    self._content:getChildByName("btn_close"):setVisible(false)
    --关闭
    self.btnclose = ccui.Button:create("Welfare/close0.png", "Welfare/close1.png")
    self.btnclose:setPosition(appdf.WIDTH * 0.05, appdf.HEIGHT * 0.92)
    self.btnclose:setVisible(false)
    self.btnclose:addClickEventListener(function() self:onKeyBack() end)
    self.btnclose:addTo(self, 100)
     --copy
    self.btncopy = ccui.Button:create("Welfare/btn_copy.png", "Welfare/btn_copy.png")
    self.btncopy:setPosition(appdf.WIDTH * 0.05, appdf.HEIGHT * 0.50)
    self.btncopy:setVisible(false)
    self.btncopy:setRotation(-90)
    self.btncopy:addTo(self, 100)
    self.btncopy:addClickEventListener(function()
        
        --播放音效
        ExternalFun.playClickEffect()
        print(self.code)
        MultiPlatform:getInstance():copyToClipboard(self.code)
        showToast(nil, "已复制到剪贴板", 2)
    end)
     --保存
    self.btnsave = ccui.Button:create("Welfare/save.png", "Welfare/save.png")
    self.btnsave:setPosition(appdf.WIDTH * 0.05, appdf.HEIGHT * 0.15)
    self.btnsave:setVisible(false)
    self.btnsave:setRotation(-90)
--    self.btnsave:addClickEventListener(function() 
--        local savePath = cc.FileUtils:getInstance():getWritablePath()
--        if true == MultiPlatform:getInstance():saveImgToSystemGallery(savePath, "dzqpCode.png") then
--			showToast(self, "二维码图片已保存至系统相册", 1)
--	    end
--    end)
    self.btnsave:addTo(self, 100)
    --请求二维码
    local ostime = os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=getqrcode&userid=" .. GlobalUserItem.dwUserID .. "&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)

        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
					local index=sjstable["code"]
					local savePath = cc.FileUtils:getInstance():getWritablePath()
					if CCFileUtils:getInstance():isFileExist(savePath.."Qrcode"..index..".png") then
					self:openQrcode(index)
					else
                    self:createQrcode(sjstable["msg"],index)
					end
                    print(sjstable["msg"])
                    local str=string.match(sjstable["msg"],"qt%=.-&")
                    print(str)
                    self.code=string.sub(str,4,string.len(str)-1)
                    return
                end
            end
        end

        QueryDialog:create("操作失败,网络错误", nil, nil, QueryDialog.QUERY_SURE):addTo(self) 
    end)


end
--创建二维码
function PopularizeLayer:createQrcode( url,index )
    print("[HTTP]:Qrcode url -- "..url)

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON 

    xhr:open("GET", url.."&index="..index)

	--HTTP回调函数
	local function onJsionTable()

		local response
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	   		response  = xhr.response -- 获得响应数据
            if response ~= nil then
                local savePath = cc.FileUtils:getInstance():getWritablePath()
--                if CCFileUtils:getInstance():isFileExist(savePath.."Qrcode.png") then
--                    os.remove(savePath.."Qrcode.png")
--                    print("删除文件"..savePath.."Qrcode.png")
--                end
--                if CCFileUtils:getInstance():isFileExist(savePath.."Qrcode.png") == false then
--                    print("没有找到文件"..savePath.."Qrcode.png")
--                end
--                math.randomseed(os.time())
--                local r = math.random(1,table.getn(self.idx))
--                local i = self.idx[r]
                table.remove(self.idx, index)
                local f = io.open(savePath.."Qrcode"..index..".png", "wb")
                if f then
                    f:write(response)
                    f:flush()
                    f:close()
                    print(savePath.."Qrcode"..index..".png")
                   self:openQrcode(index)
                end
            end
	    else
	    	print("onJsionTable http fail readyState:"..xhr.readyState.."#status:"..xhr.status)
	    end    
	end
	xhr:registerScriptHandler(onJsionTable)

	xhr:send()

end
--创建二维码
function PopularizeLayer:openQrcode( index )
local savePath = cc.FileUtils:getInstance():getWritablePath()
 local qrCode = ccui.ImageView:create()
                    qrCode:loadTexture(savePath.."Qrcode"..index..".png",0)
                    qrCode:setAnchorPoint(0.5, 0.5)
                    self:addChild(qrCode)
                    qrCode:setPosition(cc.p(appdf.WIDTH / 2, appdf.HEIGHT / 2))
                    local x = appdf.WIDTH / qrCode:getContentSize().height
                    local y = appdf.HEIGHT / qrCode:getContentSize().width
                    print("================x~~"..x.."===================y~~"..y)
                      print("二维码宽，"..qrCode:getContentSize().width.."高"..qrCode:getContentSize().height)
                    qrCode:setScale(y, x)
                    print("二维码宽，"..qrCode:getContentSize().width.."高"..qrCode:getContentSize().height)
                    qrCode:setRotation(-90)
                    self.btnclose:setVisible(true)
                    self.btnsave:setVisible(true)
                    self.btncopy:setVisible(true)
                   self.btnsave:addClickEventListener(function()
                   if true == MultiPlatform:getInstance():saveImgToSystemGallery(savePath.."Qrcode"..index..".png", "qrCode.png") then
				                    showToast(self, "二维码图片已保存至系统相册!", 1)
			                    end
--                        local screenPos = self:convertToWorldSpace(cc.p(qrCode:getPosition()))
--                         cc.utils:captureScreen(afterCaptured, fileName)
--                        captureScreenWithArea(cc.rect(0 , 0, qrCode:getContentSize().height,qrCode:getContentSize().width ), "qrCode.png", function(ok, savepath)	
--		                    if ok then	
--			                    if true == MultiPlatform:getInstance():saveImgToSystemGallery(savepath, "qrCode.png") then
--				                    showToast(self, "二维码图片已保存至系统相册", 1)
--			                    end
--		                    end
--		                end)
                    end)
end 
function PopularizeLayer:onKeyBack()
    yl.ClientScene:removeBackFunc(self)  -- 移除  关闭了层 要移除 所以 肯定要又这行代码
    --播放音效
    ExternalFun.playClickEffect()

    dismissPopupLayer(self)
end
return PopularizeLayer