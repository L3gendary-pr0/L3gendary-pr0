-- This is a MODULE script code

local module = {}


local PileUpTime = 0.05
local PileDownTime = 0.05
local PileDownTweenTime = 0.1

function UnAnchor(model)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("MeshPart") or v:IsA("BasePart") then
			v.Anchored=false
		end
	end
end


function Anchor(model)
	for i,v in pairs(model:GetDescendants()) do
		if v:IsA("MeshPart") or v:IsA("BasePart") then
			v.Anchored=true
		end
	end
end


function GetRelativePart(folder,order)
	if folder:FindFirstChild(tostring(order)) then
		return folder:FindFirstChild(tostring(order)).PrimaryPart
	else
		return nil
	end
end

function PutCFrame(itemInServerStorage,itemClonedInCharacter,RelativePart,itemOrder,ChangeCFrameBecauseItsStorageSpot)
	local AdditionalCFrame
	if itemInServerStorage:FindFirstChild("AdditionalCFrame") then
		AdditionalCFrame=itemInServerStorage.AdditionalCFrame.Value
	end
	local DefaultCFrame
	if not ChangeCFrameBecauseItsStorageSpot then
		DefaultCFrame = RelativePart.CFrame * CFrame.new(0,0,1.5)--CFrame if relative part is lower torso
	else
		DefaultCFrame = RelativePart.CFrame --CFrame if its relative part is a storage spot
	end
	
	local finalCFrame
	
	if AdditionalCFrame and itemOrder>1 then
		finalCFrame=RelativePart.CFrame * AdditionalCFrame
	else
		finalCFrame=DefaultCFrame
	end
	
	itemClonedInCharacter:PivotTo(finalCFrame)
end


function TweenFunction(part,Time,CF)
	local TweenService = game:GetService("TweenService"):Create(part,TweenInfo.new(Time,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{CFrame=CF}):Play()
end

module.PileUp = function(plr,itemName,count)
	
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
			if plr.Character.HumanoidRootPart:FindFirstChild('PopSound') then plr.Character.HumanoidRootPart.PopSound:Play() end
			wait(PileUpTime)
			
		until count<=0 or not plr.Character
	end
end





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




		if plr.Character.HumanoidRootPart:FindFirstChild('PopSound') then plr.Character.HumanoidRootPart.PopSound:Play() end
		wait(PileUpTime)
		
	end

end




module.PileDown = function(plr,itemName,PileDownPart,count)
	
	local folder = plr.Character:FindFirstChild(itemName)
	
	if folder then
		
		repeat
			local item = folder:FindFirstChild(#folder:GetChildren())
			
			if item then
				if item:FindFirstChild("WeldConstraint") then item.WeldConstraint:Destroy() end
				TweenFunction(item.PrimaryPart,PileDownTweenTime,PileDownPart.CFrame)
				
				if plr.Character.HumanoidRootPart:FindFirstChild('PileDownSound') then plr.Character.HumanoidRootPart.PileDownSound:Play() end

				count-=1
				wait(PileDownTime)
				
				item:Destroy()
				
			end
			
		until count<=0 or item==nil or not plr.Character
		
	end
	
end


module.PileDownOnce = function(plr,itemName,PileDownPart)

	local folder = plr.Character:FindFirstChild(itemName)

	if folder then

		local item = folder:FindFirstChild(#folder:GetChildren())

		if item then
			if item:FindFirstChild("WeldConstraint") then item.WeldConstraint:Destroy() end
			TweenFunction(item.PrimaryPart,PileDownTweenTime,PileDownPart.CFrame)

			if plr.Character.HumanoidRootPart:FindFirstChild('PileDownSound') then plr.Character.HumanoidRootPart.PileDownSound:Play() end

			wait(PileDownTime)

			item:Destroy()

		end


	end

end


module.PileUpStorage = function(plr,part,itemName)
	
	
	local itemInServerStorage = game.ServerStorage:FindFirstChild(itemName)

	if itemInServerStorage and part:FindFirstChildOfClass("Folder") and #part:FindFirstChildOfClass("Folder"):GetChildren()==0 then
		part:FindFirstChildOfClass('Folder').Name=itemName
	elseif itemInServerStorage and part:FindFirstChildOfClass("Folder") and #part:FindFirstChildOfClass("Folder"):GetChildren()>0 and part:FindFirstChildOfClass('Folder').Name==itemName then
		--continue normally
	else
		return -- cannot stack different items together on 1 spot
	end
	
		local ItemOrder = #part:FindFirstChildOfClass("Folder"):GetChildren() + 1


		local RelativePart = GetRelativePart(part:FindFirstChildOfClass('Folder'),ItemOrder-1) or part

		local item = itemInServerStorage:Clone()
		item.Parent = part:FindFirstChildOfClass('Folder')
		item.Name=ItemOrder
		Anchor(item)
		PutCFrame(itemInServerStorage,item,RelativePart,ItemOrder,true)

		if plr.Character.HumanoidRootPart:FindFirstChild('PopSound') then plr.Character.HumanoidRootPart.PopSound:Play() end
		
	
end



module.PileDownStorage = function(plr,part,itemName,PileDownPart)

	local folder = part:FindFirstChildOfClass("Folder")

	if folder then

		local item = folder:FindFirstChild(#folder:GetChildren())

		if item then
			if item:FindFirstChild("WeldConstraint") then item.WeldConstraint:Destroy() end
			TweenFunction(item.PrimaryPart,PileDownTweenTime,PileDownPart.CFrame)

			if plr.Character.HumanoidRootPart:FindFirstChild('PileDownSound') then plr.Character.HumanoidRootPart.PileDownSound:Play() end

			wait(PileDownTime)

			item:Destroy()

		end

	end

end

return module