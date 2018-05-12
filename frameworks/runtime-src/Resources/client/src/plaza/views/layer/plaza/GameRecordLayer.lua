--游戏记录
local GameRecordLayer = class("GameRecordLayer", cc.Layer)
local ExternalFun = appdf.req(appdf.EXTERNAL_SRC .. "ExternalFun")
local QueryDialog = appdf.req(appdf.BASE_SRC .. "app.views.layer.other.QueryDialog")
local ModifyFrame = appdf.req(appdf.CLIENT_SRC.."plaza.models.ModifyFrame")

function GameRecordLayer:ctor()
self.infos={}
	--网络处理
	self._modifyFrame = ModifyFrame:create(self, function(result,message)
		self:onModifyCallBack(result,message)
	end)

    --节点事件
	ExternalFun.registerNodeEvent(self)

	--加载CSB文件
	local csbNode = ExternalFun.loadCSB("GameRecord/GameRecordLayer.csb"):addTo(self)
    self.tab_node = csbNode:getChildByName("Record_List")
    --关闭
    local btn_close = csbNode:getChildByName("Close_Btn")
    btn_close:addClickEventListener(function()

	
        --播放音效
        ExternalFun.playClickEffect()
        dismissPopupLayer(self)
    end)
self:initdata()
end

--------------------------------------------------------------------------------------------------------------------
-- ModifyFrame 回调

--操作结果
function GameRecordLayer:onModifyCallBack(result,message)

    dismissPopWait()

	if  message ~= nil and message ~= "" then
		showToast(nil,message,2)
	end
	if -1 == result then
		return
	end

end

function GameRecordLayer:showdata()

	local item_list = self.tab_node:getChildByName("Item")
	item = item_list:clone()
    local list = self.infos
	self.tab_node:removeAllChildren()
    if #list > 0 then
        for i = 1, #list do
            item = item:clone()
            item:getChildByName("Text"):setString(list[i])
            self.tab_node:pushBackCustomItem(item)
        end
    end
	
end
function GameRecordLayer:getPageList(page)
    local ostime=os.time()
	local url = yl.HTTP_URL .. "/WS/Account.ashx"
 	appdf.onHttpJsionTable(url ,"GET","action=getrecordlist&userid=" .. GlobalUserItem.dwUserID ..  "&page=".. page.."&time=".. ostime .. "&signature=".. GlobalUserItem:getSignature(ostime),function(sjstable,sjsdata)
        
        if type(sjstable) == "table" then
            local data = sjstable["data"]
            if type(data) == "table" then
                local valid = data["valid"]
                if true == valid then
				self.infos={}
                    -- 处理基本信息的显示
		    for key, var in ipairs(data["data"]) do
			amount = ExternalFun.formatScoreText(var["winresult"]) .. " BTC"
			if(var["winresult"]<0) then
			str="输"
			amount=-1*amount
			else 
			str="赢"
			end
			str= string.format("%s                %s                 %s%s ",var["time"],var["gametype"],str,amount) 
			
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
function GameRecordLayer:initdata()
	self:getPageList(1)
	
end
return GameRecordLayer