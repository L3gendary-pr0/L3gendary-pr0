-- This is a MODULE script code
-- // By L3gendary_pr0 // legendary_. // 2026-1-1 V.3.1.4
local module = {}

local PileUpTime = 0.05
local PileDownTime = 0.05
local PileDownTweenTime = 0.1
local TableOfPlrsCurrentlyPileing = {}

--EZ UNACNHOR
function UnAnchor(model)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("MeshPart") or v:IsA("BasePart") then
			v.Anchored=false
		end
	end
end
--EZ ANCHOR
function Anchor(model)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("MeshPart") or v:IsA("BasePart") then
			v.Anchored=true
		end
	end
end
--most used function for determining the next position of phsical item
--To detect where to stack
function GetRelativePart(folder,order) 
	if folder:FindFirstChild(tostring(order)) then
		return folder:FindFirstChild(tostring(order)).PrimaryPart 
	else
		return nil
	end
end

--Adjusting CFrame based on existence of previous part (additional cframe) or no existence (default cframe)
-- calculates both in finalCFrame variable
function PutCFrame(itemInServerStorage,itemClonedInCharacter,RelativePart,itemOrder,ChangeCFrameBecauseItsStorageSpot)
	local AdditionalCFrame
	if itemInServerStorage:FindFirstChild("AdditionalCFrame") then
		AdditionalCFrame=itemInServerStorage.AdditionalCFrame.Value
	end
	local DefaultCFrame
	if not ChangeCFrameBecauseItsStorageSpot then
		DefaultCFrame = RelativePart.CFrame * CFrame.new(0,0,1.5)
	else
		DefaultCFrame = RelativePart.CFrame 
	end
	local finalCFrame 
	if AdditionalCFrame and itemOrder>1 then
		finalCFrame=RelativePart.CFrame * AdditionalCFrame
	 else 
		finalCFrame=DefaultCFrame
	end
	itemClonedInCharacter:PivotTo(finalCFrame) 
end
--to tween a part to a cframe
function TweenFunction(part,Time,CF)
	game:GetService("TweenService"):Create(part,TweenInfo.new(Time,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=CF}):Play()
end
--to pile up an item, we check if its the first item or not
--we repeat piling up according to available storage (count
--at last we weld
module.PileUp = function(plr,itemName,count) -- To pile up items
	local itemInServerStorage = game.ServerStorage:FindFirstChild(itemName)
	if itemInServerStorage then
		if plr.Character and not plr.Character:FindFirstChild(itemInServerStorage.Name) then
			local folder = Instance.new('Folder')
			folder.Parent=plr.Character
			folder.Name=itemInServerStorage.Name
		end
		repeat 
			local ItemOrder = #plr.Character:FindFirstChild(itemInServerStorage.Name):GetChildren() + 1
			local RelativePart = GetRelativePart(plr.Character:FindFirstChild(itemInServerStorage.Name),ItemOrder-1) or plr.Character.LowerTorso
			local item = itemInServerStorage:Clone()
			item.Parent = plr.Character:FindFirstChild(itemInServerStorage.Name)
			item.Name=ItemOrder
			PutCFrame(itemInServerStorage,item,RelativePart,ItemOrder)
			local weld = Instance.new('WeldConstraint') 
			weld.Parent=item
			weld.Part0=item.PrimaryPart
			weld.Part1=plr.Character.LowerTorso
			UnAnchor(item)
			count-=1
			if plr.Character.HumanoidRootPart:FindFirstChild('PopSound') then
				plr.Character.HumanoidRootPart.PopSound:Play() 
			end
			task.wait(PileUpTime)
		until count<=0 or not plr.Character
	end
end
--Similar as the above pileup but it piles up once, depends on settings and storage availability
module.PileUpOnce = function(plr,itemName) 
	local itemInServerStorage = game.ServerStorage:FindFirstChild(itemName)
	if itemInServerStorage then
		if plr.Character and not plr.Character:FindFirstChild(itemInServerStorage.Name) then 
			local folder = Instance.new('Folder')
			folder.Parent=plr.Character
			folder.Name=itemInServerStorage.Name
		end
		local ItemOrder = #plr.Character:FindFirstChild(itemInServerStorage.Name):GetChildren() + 1 
		local RelativePart = GetRelativePart(plr.Character:FindFirstChild(itemInServerStorage.Name),ItemOrder-1) or plr.Character.LowerTorso
		local item = itemInServerStorage:Clone()
		item.Parent = plr.Character:FindFirstChild(itemInServerStorage.Name)
		item.Name=ItemOrder
		PutCFrame(itemInServerStorage,item,RelativePart,ItemOrder)
		local weld = Instance.new('WeldConstraint')
		weld.Parent=item
		weld.Part0=item.PrimaryPart
		weld.Part1=plr.Character.LowerTorso
		UnAnchor(item)
		if plr.Character.HumanoidRootPart:FindFirstChild('PopSound') then
			plr.Character.HumanoidRootPart.PopSound:Play() 
		end
		task.wait(PileUpTime)
	end
end
--piling down based on storage stock count
--reduces the items on the back and no animation is made here
module.PileDown = function(plr,itemName,PileDownPart,count)
	local folder = plr.Character:FindFirstChild(itemName)
	if folder then 
		repeat 
			local item = folder:FindFirstChild(#folder:GetChildren())
			if item then
				if item:FindFirstChild("WeldConstraint") then
					item.WeldConstraint:Destroy() 
				end
				TweenFunction(item.PrimaryPart,PileDownTweenTime,PileDownPart.CFrame)
				if plr.Character.HumanoidRootPart:FindFirstChild('PileDownSound') then 
					plr.Character.HumanoidRootPart.PileDownSound:Play() 
				end
				count-=1
				task.wait(PileDownTime)
				item:Destroy() 
			end
		until count<=0 or item==nil or not plr.Character
	end
end
--same as above function but does it once
module.PileDownOnce = function(plr,itemName,PileDownPart) -- if settings is set to pile down once or for storage system
	local folder = plr.Character:FindFirstChild(itemName)
	if folder then 
		local item = folder:FindFirstChild(#folder:GetChildren())
		if item then
			if item:FindFirstChild("WeldConstraint") then 
				item.WeldConstraint:Destroy() 
			end
			TweenFunction(item.PrimaryPart,PileDownTweenTime,PileDownPart.CFrame)
			if plr.Character.HumanoidRootPart:FindFirstChild('PileDownSound') then 
				plr.Character.HumanoidRootPart.PileDownSound:Play() 
			end
			task.wait(PileDownTime)
			item:Destroy()
		end
	end
end
--for sotrage, we check if the other part is full or not (aka storage is full or not)
--works like the pile up function above but with extra checking for storage limitations
module.PileUpStorage = function(plr,part,itemName) 
	local itemInServerStorage = game.ServerStorage:FindFirstChild(itemName)
	if itemInServerStorage and part:FindFirstChildOfClass("Folder") and #part:FindFirstChildOfClass("Folder"):GetChildren()==0 then
		part:FindFirstChildOfClass('Folder').Name=itemName
	elseif itemInServerStorage and part:FindFirstChildOfClass("Folder") and #part:FindFirstChildOfClass("Folder"):GetChildren()>0 and part:FindFirstChildOfClass('Folder').Name==itemName then
		local ItemOrder = #part:FindFirstChildOfClass("Folder"):GetChildren() + 1
		local RelativePart = GetRelativePart(part:FindFirstChildOfClass('Folder'),ItemOrder-1) or part
		local item = itemInServerStorage:Clone()
		item.Parent = part:FindFirstChildOfClass('Folder')
		item.Name=ItemOrder
		Anchor(item)
		PutCFrame(itemInServerStorage,item,RelativePart,ItemOrder,true)
		if plr.Character.HumanoidRootPart:FindFirstChild('PopSound') then
			plr.Character.HumanoidRootPart.PopSound:Play() 
		end
	else
		return -- cannot stack different items together on 1 spot
	end
end
--to pile down from storage, check if something is in storage then commit pile down
-- current no animation is available for it yet
module.PileDownStorage = function(plr,part,itemName,PileDownPart) --for storage system
	local folder = part:FindFirstChildOfClass("Folder")
	if folder then
		local item = folder:FindFirstChild(#folder:GetChildren())
		if item then 
			if item:FindFirstChild("WeldConstraint") then item.WeldConstraint:Destroy() end 
			TweenFunction(item.PrimaryPart,PileDownTweenTime,PileDownPart.CFrame) 
			if plr.Character.HumanoidRootPart:FindFirstChild('PileDownSound') then plr.Character.HumanoidRootPart.PileDownSound:Play() end --sound
			task.wait(PileDownTime)
			item:Destroy()
		end
	end
end
--distance before interaction happens
function DistanceFromItemTransferPart(char,part)
	return (char.HumanoidRootPart.Position-part.Position).magnitude<part.Size.X*0.85 
end
--adjust the ui based on interaction (first or non first interaction with the storage)
function TweenInfoUIOfItemTransferPart(infoUI,currentValue,originalValue)
	if originalValue<0 then 
		infoUI.Frame.Size=UDim2.new(1 , 0 , math.abs(math.abs(originalValue-currentValue)/originalValue) , 0)
		infoUI.TextLabel.Text = (math.abs(originalValue)-math.abs(currentValue)).."/"..math.abs(originalValue)
	else 
		infoUI.Frame.Size=UDim2.new(1 , 0 , math.abs(currentValue/originalValue) , 0)
		infoUI.TextLabel.Text = currentValue.."/"..originalValue
	end
end
--random thing to pile down in storage
--if a random item exists and owned by the plr to stack on storage
function GetRandomItemNameWhichPlayerHolds(char) 
	for i,v in pairs(char:GetChildren()) do
		if v:IsA("Folder") then
			if #v:GetChildren()>0 then 
				if game.ServerStorage:FindFirstChild(v.Name) then
					return v.Name
				end
			end
		end
	end
	return nil
end
--for storage system , when depositing or withdrawing, it affects another block
--paste the item name to the other itemtransfer block
--to calculate the difference between receptors and givers
function CheckIfAffectsOtherItemTransfers(AuthorItemTransfer)  
	if AuthorItemTransfer:FindFirstChild("EffectOnOtherItemTransfers") then

		if AuthorItemTransfer.EffectOnOtherItemTransfers:FindFirstChild("PasteSelfNameToThis") then 
			AuthorItemTransfer.EffectOnOtherItemTransfers.PasteSelfNameToThis.Value:FindFirstChildOfClass("NumberValue").Name = AuthorItemTransfer:FindFirstChildOfClass("NumberValue").Name
		end

		if AuthorItemTransfer.EffectOnOtherItemTransfers:FindFirstChild("PasteSelfValueAbsolute") then 
			AuthorItemTransfer.EffectOnOtherItemTransfers.PasteSelfValueAbsolute.Value:FindFirstChildOfClass("NumberValue").Value = math.abs(math.abs(AuthorItemTransfer:FindFirstChildOfClass("NumberValue").Value)-math.abs(AuthorItemTransfer:FindFirstChildOfClass("NumberValue").OriginalValue.Value))
			TweenInfoUIOfItemTransferPart(AuthorItemTransfer.EffectOnOtherItemTransfers.PasteSelfValueAbsolute.Value.InfoUI,AuthorItemTransfer.EffectOnOtherItemTransfers.PasteSelfValueAbsolute.Value:FindFirstChildOfClass('NumberValue').Value,AuthorItemTransfer.EffectOnOtherItemTransfers.PasteSelfValueAbsolute.Value:FindFirstChildOfClass('NumberValue').OriginalValue.Value)
		end

		if AuthorItemTransfer.EffectOnOtherItemTransfers:FindFirstChild("PasteDifferenceOriginalValAndCurrentVal") then
			--these came by trial and error till i found out the correct math for it
			if AuthorItemTransfer.EffectOnOtherItemTransfers.PasteDifferenceOriginalValAndCurrentVal.Value:FindFirstChildOfClass("NumberValue").OriginalValue.Value<0 then
				AuthorItemTransfer.EffectOnOtherItemTransfers.PasteDifferenceOriginalValAndCurrentVal.Value:FindFirstChildOfClass("NumberValue").Value = - math.abs(AuthorItemTransfer:FindFirstChildOfClass("NumberValue").Value-AuthorItemTransfer:FindFirstChildOfClass("NumberValue").OriginalValue.Value)
			else
				AuthorItemTransfer.EffectOnOtherItemTransfers.PasteDifferenceOriginalValAndCurrentVal.Value:FindFirstChildOfClass("NumberValue").Value = math.abs(AuthorItemTransfer:FindFirstChildOfClass("NumberValue").Value-AuthorItemTransfer:FindFirstChildOfClass("NumberValue").OriginalValue.Value)
			end
			TweenInfoUIOfItemTransferPart(AuthorItemTransfer.EffectOnOtherItemTransfers.PasteDifferenceOriginalValAndCurrentVal.Value.InfoUI,AuthorItemTransfer.EffectOnOtherItemTransfers.PasteDifferenceOriginalValAndCurrentVal.Value:FindFirstChildOfClass('NumberValue').Value,AuthorItemTransfer.EffectOnOtherItemTransfers.PasteDifferenceOriginalValAndCurrentVal.Value:FindFirstChildOfClass('NumberValue').OriginalValue.Value)
		end
	end
end
--connected with the loop
--if it consumes an itme and the plr has that item, consume
module.HandlingPileUpOrDown = function(plr,NumberValueInItemTransferPart) 
	if table.find(TableOfPlrsCurrentlyPileing,plr) or NumberValueInItemTransferPart==nil then return end --dont do anything if active or not found
	print(NumberValueInItemTransferPart.Name=="none")
	if NumberValueInItemTransferPart.Value<0 and plr.Character and ((plr.Character:FindFirstChild(NumberValueInItemTransferPart.Name) and #plr.Character:FindFirstChild(NumberValueInItemTransferPart.Name):GetChildren()>0) or NumberValueInItemTransferPart.Name=="none") then
		
		table.insert(TableOfPlrsCurrentlyPileing,plr)
		local itemName
		if NumberValueInItemTransferPart.Name=="none" then
			itemName=GetRandomItemNameWhichPlayerHolds(plr.Character)
		else 
			itemName=NumberValueInItemTransferPart.Name
		end
		print(itemName)
		if itemName then
			NumberValueInItemTransferPart.Name=itemName
			task.spawn(function()
				repeat
					module.PileDownOnce(plr,itemName,NumberValueInItemTransferPart.Parent) 
					if NumberValueInItemTransferPart.Parent:FindFirstChild('PileUp') then 
						module.PileUpStorage(plr,NumberValueInItemTransferPart.Parent:FindFirstChild('PileUp').Value,NumberValueInItemTransferPart.Name)
					end
					NumberValueInItemTransferPart.Value+=1 
					TweenInfoUIOfItemTransferPart(NumberValueInItemTransferPart.Parent.InfoUI,NumberValueInItemTransferPart.Value,NumberValueInItemTransferPart.OriginalValue.Value)
					task.wait(0.0000000001)
					CheckIfAffectsOtherItemTransfers(NumberValueInItemTransferPart.Parent) 
				until not plr.Character:FindFirstChild(NumberValueInItemTransferPart.Name) or #plr.Character:FindFirstChild(NumberValueInItemTransferPart.Name):GetChildren()<=0 or NumberValueInItemTransferPart.Value>=0 or not DistanceFromItemTransferPart(plr.Character,NumberValueInItemTransferPart.Parent)

				if table.find(TableOfPlrsCurrentlyPileing,plr) then
					table.remove(TableOfPlrsCurrentlyPileing,table.find(TableOfPlrsCurrentlyPileing,plr)) 
				end
			end)
		end
	elseif NumberValueInItemTransferPart.Value>0 and game.ServerStorage:FindFirstChild(NumberValueInItemTransferPart.Name) then
		--type = giver
		table.insert(TableOfPlrsCurrentlyPileing,plr) 
		task.spawn(function()
			repeat
				module.PileUpOnce(plr,NumberValueInItemTransferPart.Name)
				if NumberValueInItemTransferPart.Parent:FindFirstChild('PileDown') then 
					module.PileDownStorage(plr,NumberValueInItemTransferPart.Parent:FindFirstChild('PileDown').Value,NumberValueInItemTransferPart.Name,plr.Character.HumanoidRootPart)
				end
				NumberValueInItemTransferPart.Value-=1
				TweenInfoUIOfItemTransferPart(NumberValueInItemTransferPart.Parent.InfoUI,NumberValueInItemTransferPart.Value,NumberValueInItemTransferPart.OriginalValue.Value)
				task.wait(0.0000000000001)
				CheckIfAffectsOtherItemTransfers(NumberValueInItemTransferPart.Parent)
			until NumberValueInItemTransferPart.Value<=0 or not DistanceFromItemTransferPart(plr.Character,NumberValueInItemTransferPart.Parent)
			if table.find(TableOfPlrsCurrentlyPileing,plr) then
				table.remove(TableOfPlrsCurrentlyPileing,table.find(TableOfPlrsCurrentlyPileing,plr))
			end
		end)
	elseif NumberValueInItemTransferPart.Value<0 and NumberValueInItemTransferPart.Name=="none" then
		--impossible
		warn("ERRORRRR 101")
	end
end

return module


