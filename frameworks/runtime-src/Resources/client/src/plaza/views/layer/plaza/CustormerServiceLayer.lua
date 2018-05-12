
-- 客服服务视图
local CustormerServiceLayer = class("CustormerServiceLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")

local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

function CustormerServiceLayer:ctor()

	--网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --节点事件
	ExternalFun.registerNodeEvent(self)

	--加载CSB文件
	local csbNode = ExternalFun.loadCSB("CustormerService/CustormerServiceLayer.csb"):addTo(self)
    
    --关闭
    local btn_close = csbNode:getChildByName("Close_Btn")
    btn_close:addClickEventListener(function()

        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)
	local url = yl.HTTP_URL .. "/WS/MobileInterface.ashx"
     appdf.onHttpJsionTable(url ,"GET","action=GetKeFu",function(jstable,jsdata)

         if type(jstable) ~= "table" then
             return
         end
         local data=jstable["data"]
        csbNode:getChildByName("WeChat_Item"):getChildByName("Text"):setString(data["wx1"])
        csbNode:getChildByName("QQ_Item"):getChildByName("Text"):setString(data["wx2"])
		self:createQrcode(yl.HTTP_URL..data["wxqr"])
     end)
	self.qrcode=csbNode:getChildByName("QR_Code")
	--csbNode:getChildByName("QR_Code"):loadTexture("F:\\00WHGame\\mobile-game316\\client\\wxQrcode.png",0)

end


--创建二维码
function CustormerServiceLayer:createQrcode( url )
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON 

    xhr:open("GET", url)

	--HTTP回调函数
	local function onJsionTable()
		local response
	    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
	   		response  = xhr.response -- 获得响应数据
            if response ~= nil then
                local savePath = cc.FileUtils:getInstance():getWritablePath()
             
                local f = io.open(savePath.."wxQrcode.png", "wb")
                if f then
                    f:write(response)
                    f:flush()
                    f:close()
                    print(savePath.."wxQrcode.png")
					self:showqr(savePath.."wxQrcode.png")
                end
            end
	    else
	    	print("onJsionTable http fail readyState:"..xhr.readyState.."#status:"..xhr.status)
	    end    
	end
	xhr:registerScriptHandler(onJsionTable)

	xhr:send()

end

function CustormerServiceLayer:showqr(path)
	self.qrcode:loadTexture(path,0)
end
--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function CustormerServiceLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

end

return CustormerServiceLayer