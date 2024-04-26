local clown = script.Parent
local humanoid = clown.Humanoid




local ReplicatedStorage = game:GetService("ReplicatedStorage")
local jumpscare = ReplicatedStorage:WaitForChild("Jumpscare")

local PathfindingService = game:GetService("PathfindingService")
clown.PrimaryPart:SetNetworkOwner(nil)

local walkspeed = clown:GetAttribute("Walkspeed")
local sprintSpeed = clown:GetAttribute("SprintSpeed")

local lastPosition

if humanoid then
	humanoid.WalkSpeed = walkspeed
end

local function canSeeTarget(target)
	local origin = clown.HumanoidRootPart.Position
	local direction = (target.HumanoidRootPart.Position - clown.HumanoidRootPart.Position).unit * 40
	local ray = Ray.new(origin, direction)
	
	local hit, pos = workspace:FindPartOnRay(ray, clown)
	
	if hit then
		if hit:IsDescendantOf(target) then
			return true
		end
	else
		return false
	end
	
end


local function findTarget()
	local players = game.Players:GetPlayers()
	local maxDistance = clown:GetAttribute("MaxDistance")
	local nearestTarget
	
	for index, player in pairs(players) do
		if player.Character then
			local target = player.Character
			local distance = (clown.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
			
			if distance < maxDistance and canSeeTarget(target) then
				nearestTarget = target
				maxDistance = distance
			end
			
		end
	end
	
	return nearestTarget
end


local function getPath(destination)
	local pathParams = {
		["AgentHeight"] = 5,
		["AgentRadius"] = 2,
		["AgentCanJump"] = false
	}
	
	local path = PathfindingService:CreatePath(pathParams)
	path:ComputeAsync(clown.HumanoidRootPart.Position, destination.Position)

	return path
end


local function attack(target)
	local distance = (clown.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
	
	if distance > 4 then
		humanoid.WalkSpeed = sprintSpeed
		humanoid:MoveTo(target.HumanoidRootPart.Position)
	else
		local attackAnim = humanoid:LoadAnimation(script.Kill)
		attackAnim:Play()
		
		local deadPlayer = game:GetService("Players"):GetPlayerFromCharacter(target)
		jumpscare:FireClient(deadPlayer)
		
		clown.Head.SFX["FNaF 6 Salvage Jumpscare"]:Play()
		target.Humanoid.Health = 0
		clown.Head.SFX["knife stab (de-juicified)"].Looped = true
		clown.Head.SFX["knife stab (de-juicified)"]:Play()
		wait(1.5)
		clown.Head.SFX["VHS Chase 2"].Playing = false
		clown.Head.SFX["knife stab (de-juicified)"].Looped = false
		local TeleportService = game:GetService("TeleportService")
		TeleportService:Teleport(15088737574, deadPlayer)
	end
end

local function walkTo(destination)
	local path = getPath(destination)
	
	if path.Status == Enum.PathStatus.Success then
		for index, waypoint in pairs(path:GetWaypoints()) do
			local target = findTarget()
			if target and target.Humanoid.Health > 0 then
				attack(target)
				lastPosition = target.HumanoidRootPart.Position
				clown.Head.SFX["VHS Chase 2"].Playing = true
				break
			else
				if lastPosition then
					humanoid:MoveTo(lastPosition)
					humanoid.MoveToFinished:Wait()
					lastPosition = nil
					break
				else
					humanoid.WalkSpeed = walkspeed
					clown.Head.SFX["VHS Chase 2"].Playing = false
					humanoid:MoveTo(waypoint.Position)
					humanoid.MoveToFinished:Wait()
				end
				
			end
		end
	else
		humanoid:MoveTo(destination.Position - (clown.HumanoidRootPart.CFrame.LookVector * 10))
	end
end

local function patrol()
	local waypoints = workspace.Waypoints:GetChildren()
	
	local waypoint = math.random(1, #waypoints)
	
	-- print("Walking to " .. waypoints[waypoint].Name) - debug feature
	walkTo(waypoints[waypoint])
end


while wait(0.2) do
	
	patrol()
end

