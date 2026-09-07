-- =================================================================
-- BLOX FRUITS RAYFIELD HUB (EXTENDED FEATURES)
-- =================================================================

local Services = {
   Workspace = game:GetService("Workspace"),
   Players = game:GetService("Players"),
   RunService = game:GetService("RunService"),
   TweenService = game:GetService("TweenService"),
   VirtualUser = game:GetService("VirtualUser"),
   ReplicatedStorage = game:GetService("ReplicatedStorage")
}

local LocalPlayer = Services.Players.LocalPlayer
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Blox Fruits | Extended Hub",
   LoadingTitle = "Loading Engine...",
   LoadingSubtitle = "Delta / Mobile Executor Ready",
   ConfigurationSaving = { Enabled = true, FolderName = "BloxFruitsComplete", FileName = "Settings" },
   Discord = { Enabled = false },
   KeySystem = false
})

-- =================================================================
-- GLOBAL STATE MANAGEMENT
-- =================================================================
local State = {
   KillAura = false,
   HitboxExtend = false,
   HitboxSize = 25,
   InfEnergy = false,
   Noclip = false,
   SafeFly = false,
   FlySpeed = 100,
   AntiAFK = true,
   AutoStats = false,
   AutoChest = false,
   
   -- New Features
   MobMagnet = false,
   MobMagnetRadius = 250,
   AutoBounty = false,
   PlayerESP = false,
   CustomWalkSpeedEnabled = false,
   WalkSpeedValue = 32,
   CustomJumpPowerEnabled = false,
   JumpPowerValue = 100,
   JesusMode = false,
   
   SelectedSea1Island = nil,
   SelectedSea2Island = nil,
   SelectedSea3Island = nil
}

local Threads = {}
local Connections = {}

local function ClearThread(name)
   if Threads[name] then
      task.cancel(Threads[name])
      Threads[name] = nil
   end
end

-- Safe Character Retrieval
local function GetCharacter(player)
   local targetPlayer = player or LocalPlayer
   local char = targetPlayer.Character
   if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
      return char
   end
   return nil
end

-- Safe Remote CommF_ Call
local function FireCommF(...)
   local commF = Services.ReplicatedStorage:FindFirstChild("CommF_", true)
   if commF and commF:IsA("RemoteFunction") then
      return pcall(function(...) return commF:InvokeServer(...) end, ...)
   end
end

-- Fixed Fast Attack Handler
local function FastAttackHit()
   local char = GetCharacter()
   if not char then return end
   
   local tool = char:FindFirstChildOfClass("Tool")
   if tool then
      tool:Activate()
      local netFolder = Services.ReplicatedStorage:FindFirstChild("Modules")
      if netFolder and netFolder:FindFirstChild("Net") then
         local net = netFolder.Net
         if net:FindFirstChild("RegisterAttack") then
            net.RegisterAttack:FireServer()
         end
         if net:FindFirstChild("RegisterHit") then
            net.RegisterHit:FireServer()
         end
      end
   end
end

-- Anti-Rubberband Movement Function
local CurrentTween = nil
local function SafeMoveTo(targetCFrame)
   local char = GetCharacter()
   if not char then return end
   local hrp = char.HumanoidRootPart

   local dist = (hrp.Position - targetCFrame.Position).Magnitude
   if dist < 10 then
      hrp.CFrame = targetCFrame
      return
   end

   local speed = 250
   local tweenInfo = TweenInfo.new(dist / speed, Enum.EasingStyle.Linear)
   
   if CurrentTween then CurrentTween:Cancel() end
   CurrentTween = Services.TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
   CurrentTween:Play()
end

-- Water Walk (Jesus Mode) Platform setup
local WaterPlatform = Instance.new("Part")
WaterPlatform.Name = "JesusPlatform"
WaterPlatform.Size = Vector3.new(500, 1, 500)
WaterPlatform.Anchored = true
WaterPlatform.Transparency = 1
WaterPlatform.CanCollide = false
WaterPlatform.Parent = Services.Workspace

-- Player ESP Highlight Setup
local function ApplyPlayerESP(player)
   if player == LocalPlayer then return end
   
   local function SetupHighlight(character)
      if character:FindFirstChild("ESPHighlight") then return end
      local hl = Instance.new("Highlight")
      hl.Name = "ESPHighlight"
      hl.Adornee = character
      hl.FillColor = Color3.fromRGB(255, 0, 0)
      hl.FillTransparency = 0.5
      hl.OutlineColor = Color3.fromRGB(255, 255, 255)
      hl.OutlineTransparency = 0
      hl.Enabled = State.PlayerESP
      hl.Parent = character
   end

   if player.Character then SetupHighlight(player.Character) end
   player.CharacterAdded:Connect(SetupHighlight)
end

for _, p in ipairs(Services.Players:GetPlayers()) do ApplyPlayerESP(p) end
Services.Players.PlayerAdded:Connect(ApplyPlayerESP)

-- =================================================================
-- DATABASES
-- =================================================================
local IslandData = {
   Sea1 = {
      ["Starter / Windmill"] = CFrame.new(-1059, 16, 1546),
      ["Jungle"]             = CFrame.new(-1598, 37, 153),
      ["Pirate Village"]     = CFrame.new(-1140, 4, 3828),
      ["Desert"]             = CFrame.new(897, 6, 4388),
      ["Middle Town"]        = CFrame.new(-690, 15, 1582),
      ["Frozen Village"]     = CFrame.new(1385, 87, -1298),
      ["Marine Fortress"]    = CFrame.new(-5031, 29, 4324),
      ["Skypiea (Lower)"]    = CFrame.new(-4843, 718, -2623),
      ["Skypiea (Upper)"]    = CFrame.new(-7859, 5545, -380),
      ["Prison"]             = CFrame.new(530, 2, 474),
      ["Colosseum"]          = CFrame.new(-1580, 7, -2982),
      ["Magma Village"]      = CFrame.new(-5313, 12, 8515),
      ["Underwater City"]    = CFrame.new(61122, 18, 1569),
      ["Fountain City"]      = CFrame.new(5127, 59, 4105)
   },
   Sea2 = {
      ["Cafe / Safe Zone"]   = CFrame.new(-380, 73, 298),
      ["Kingdom of Rose"]    = CFrame.new(-428, 73, 1836),
      ["Green Zone"]         = CFrame.new(-2448, 73, -3211),
      ["Graveyard"]          = CFrame.new(-5415, 48, -725),
      ["Snow Mountain"]      = CFrame.new(608, 401, -5371),
      ["Hot and Cold"]       = CFrame.new(-6127, 15, -5040),
      ["Cursed Ship"]        = CFrame.new(923, 125, 32852),
      ["Ice Castle"]         = CFrame.new(5531, 28, -6272),
      ["Forgotten Island"]   = CFrame.new(-3056, 235, -10142)
   },
   Sea3 = {
      ["Mansion / Safe Zone"]= CFrame.new(-12463, 374, -7565),
      ["Port Town"]          = CFrame.new(-290, 7, 5343),
      ["Hydra Island"]       = CFrame.new(5228, 604, 345),
      ["Great Tree"]         = CFrame.new(2185, 29, -6737),
      ["Floating Turtle"]    = CFrame.new(-13274, 332, -7634),
      ["Castle on the Sea"]  = CFrame.new(-5085, 314, -3140),
      ["Haunted Castle"]     = CFrame.new(-9513, 142, 5535),
      ["Sea of Treats"]      = CFrame.new(-2082, 38, -12028)
   }
}

local function TeleportToIsland(targetCFrame)
   local char = GetCharacter()
   if not char or not targetCFrame then return end
   SafeMoveTo(targetCFrame * CFrame.new(0, 5, 0))
end

local function GetSortedKeys(tbl)
   local keys = {}
   for k in pairs(tbl) do table.insert(keys, k) end
   table.sort(keys)
   return keys
end

local sea1Options = GetSortedKeys(IslandData.Sea1)
local sea2Options = GetSortedKeys(IslandData.Sea2)
local sea3Options = GetSortedKeys(IslandData.Sea3)

-- =================================================================
-- PERFORMANCE ENGINE (RUNSERVICE)
-- =================================================================
Connections["MainEngine"] = Services.RunService.Stepped:Connect(function()
   local char = GetCharacter()
   if not char then return end
   local hrp = char:FindFirstChild("HumanoidRootPart")
   local hum = char:FindFirstChild("Humanoid")
   
   -- 1. Noclip Engine
   if State.Noclip or State.AutoChest or State.SafeFly or State.AutoBounty then
      for _, part in ipairs(char:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = false
         end
      end
   end

   -- 2. Hitbox Extender
   if State.HitboxExtend then
      for _, player in ipairs(Services.Players:GetPlayers()) do
         if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = player.Character.HumanoidRootPart
            targetHrp.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
            targetHrp.Transparency = 0.7
            targetHrp.BrickColor = BrickColor.new("Really red")
            targetHrp.CanCollide = false
         end
      end
   end

   -- 3. Infinite Energy
   if State.InfEnergy and char:FindFirstChild("Energy") then
      char.Energy.Value = char.Energy.MaxValue
   end

   -- 4. Flight Engine
   if State.SafeFly and hrp then
      local camera = Services.Workspace.CurrentCamera
      hrp.Velocity = Vector3.zero
      hrp.CFrame = hrp.CFrame + (camera.CFrame.LookVector * (State.FlySpeed / 50))
   end

   -- 5. WalkSpeed & JumpPower
   if hum then
      if State.CustomWalkSpeedEnabled then
         hum.WalkSpeed = State.WalkSpeedValue
      end
      if State.CustomJumpPowerEnabled then
         hum.UseJumpPower = true
         hum.JumpPower = State.JumpPowerValue
      end
   end

   -- 6. Walk on Water (Jesus Mode)
   if hrp then
      if State.JesusMode then
         WaterPlatform.CanCollide = true
         WaterPlatform.CFrame = CFrame.new(hrp.Position.X, 1, hrp.Position.Z)
      else
         WaterPlatform.CanCollide = false
      end
   end

   -- 7. Bring Mobs / Mob Magnet
   if State.MobMagnet and hrp then
      local enemies = Services.Workspace:FindFirstChild("Enemies")
      if enemies then
         for _, mob in ipairs(enemies:GetChildren()) do
            local mobHrp = mob:FindFirstChild("HumanoidRootPart")
            local mobHum = mob:FindFirstChild("Humanoid")
            if mobHrp and mobHum and mobHum.Health > 0 then
               local distance = (mobHrp.Position - hrp.Position).Magnitude
               if distance <= State.MobMagnetRadius then
                  mobHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                  mobHrp.Velocity = Vector3.zero
                  mobHrp.CanCollide = false
               end
            end
         end
      end
   end
end)

-- Anti-AFK
Services.Players.LocalPlayer.Idled:Connect(function()
   if State.AntiAFK then
      Services.VirtualUser:Button2Down(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
      task.wait(1)
      Services.VirtualUser:Button2Up(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
   end
end)

-- =================================================================
-- TAB 1: COMBAT & AUTOMATION
-- =================================================================
local Tab1 = Window:CreateTab("Combat & Stats", 4483362458)

Tab1:CreateSection("Combat Mods & Survival")

Tab1:CreateToggle({
   Name = "Kill Aura / Fast Attack",
   CurrentValue = false,
   Flag = "KillAuraFlag",
   Callback = function(Value)
      State.KillAura = Value
      ClearThread("KillAura")

      if State.KillAura then
         Threads["KillAura"] = task.spawn(function()
            while State.KillAura do
               FastAttackHit()
               task.wait(0.05)
            end
         end)
      end
   end,
})

Tab1:CreateToggle({
   Name = "Bring Mobs / Mob Magnet",
   CurrentValue = false,
   Flag = "MobMagnetFlag",
   Callback = function(Value)
      State.MobMagnet = Value
   end,
})

Tab1:CreateSlider({
   Name = "Mob Magnet Radius",
   Range = {50, 500},
   Increment = 25,
   Suffix = "studs",
   CurrentValue = 250,
   Flag = "MobMagnetRadiusFlag",
   Callback = function(Value)
      State.MobMagnetRadius = Value
   end,
})

Tab1:CreateToggle({
   Name = "Auto Bounty / Farm Players",
   CurrentValue = false,
   Flag = "AutoBountyFlag",
   Callback = function(Value)
      State.AutoBounty = Value
      ClearThread("AutoBounty")

      if State.AutoBounty then
         Threads["AutoBounty"] = task.spawn(function()
            while State.AutoBounty do
               local localChar = GetCharacter()
               if localChar then
                  local targetPlayer = nil
                  local lowestHealth = math.huge

                  for _, p in ipairs(Services.Players:GetPlayers()) do
                     if p ~= LocalPlayer then
                        local pChar = GetCharacter(p)
                        if pChar then
                           local pHum = pChar:FindFirstChild("Humanoid")
                           if pHum and pHum.Health > 0 and pHum.Health < lowestHealth then
                              lowestHealth = pHum.Health
                              targetPlayer = p
                           end
                        end
                     end
                  end

                  if targetPlayer and targetPlayer.Character then
                     local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                     if targetHrp then
                        SafeMoveTo(targetHrp.CFrame * CFrame.new(0, 3, 3))
                        FastAttackHit()
                     end
                  end
               end
               task.wait(0.1)
            end
         end)
      end
   end,
})

Tab1:CreateToggle({
   Name = "Hitbox Extender",
   CurrentValue = false,
   Flag = "HitboxFlag",
   Callback = function(Value)
      State.HitboxExtend = Value
   end,
})

Tab1:CreateSlider({
   Name = "Hitbox Size",
   Range = {10, 60},
   Increment = 5,
   Suffix = "studs",
   CurrentValue = 25,
   Flag = "HitboxSizeFlag",
   Callback = function(Value)
      State.HitboxSize = Value
   end,
})

Tab1:CreateToggle({
   Name = "Infinite Energy / Dash",
   CurrentValue = false,
   Flag = "InfEnergyFlag",
   Callback = function(Value)
      State.InfEnergy = Value
   end,
})

Tab1:CreateSection("Character Automation")

Tab1:CreateToggle({
   Name = "Auto Stats (Melee, Defense, Fruit)",
   CurrentValue = false,
   Flag = "AutoStatsFlag",
   Callback = function(Value)
      State.AutoStats = Value
      ClearThread("AutoStats")

      if State.AutoStats then
         Threads["AutoStats"] = task.spawn(function()
            while State.AutoStats do
               FireCommF("AddPoint", "Melee", 1)
               FireCommF("AddPoint", "Defense", 1)
               FireCommF("AddPoint", "Demon Fruit", 1)
               task.wait(0.5)
            end
         end)
      end
   end,
})

-- =================================================================
-- TAB 2: UTILITIES & WORLD COLLECTORS
-- =================================================================
local Tab2 = Window:CreateTab("Utilities & Visuals", 4483362458)

Tab2:CreateSection("World Collectors")

Tab2:CreateToggle({
   Name = "Auto Chest Collector",
   CurrentValue = false,
   Flag = "AutoChestFlag",
   Callback = function(Value)
      State.AutoChest = Value
      ClearThread("AutoChest")

      if State.AutoChest then
         Threads["AutoChest"] = task.spawn(function()
            while State.AutoChest do
               local char = GetCharacter()
               if char then
                  for _, obj in ipairs(Services.Workspace:GetChildren()) do
                     if not State.AutoChest then break end
                     if string.find(obj.Name, "Chest") and obj:IsA("BasePart") then
                        SafeMoveTo(obj.CFrame * CFrame.new(0, 2, 0))
                        task.wait(0.4)
                     end
                  end
               end
               task.wait(1)
            end
         end)
      end
   end,
})

Tab2:CreateSection("Visuals & ESP")

Tab2:CreateToggle({
   Name = "Player ESP",
   CurrentValue = false,
   Flag = "PlayerESPFlag",
   Callback = function(Value)
      State.PlayerESP = Value
      for _, p in ipairs(Services.Players:GetPlayers()) do
         if p ~= LocalPlayer and p.Character then
            local hl = p.Character:FindFirstChild("ESPHighlight")
            if hl then hl.Enabled = Value end
         end
      end
   end,
})

Tab2:CreateSection("Movement & Modifiers")

Tab2:CreateToggle({
   Name = "Enable Custom WalkSpeed",
   CurrentValue = false,
   Flag = "CustomWalkSpeedFlag",
   Callback = function(Value)
      State.CustomWalkSpeedEnabled = Value
      if not Value then
         local char = GetCharacter()
         if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
         end
      end
   end,
})

Tab2:CreateSlider({
   Name = "WalkSpeed Modifier",
   Range = {16, 250},
   Increment = 4,
   Suffix = "speed",
   CurrentValue = 32,
   Flag = "WalkSpeedValueFlag",
   Callback = function(Value)
      State.WalkSpeedValue = Value
   end,
})

Tab2:CreateToggle({
   Name = "Enable Custom JumpPower",
   CurrentValue = false,
   Flag = "CustomJumpPowerFlag",
   Callback = function(Value)
      State.CustomJumpPowerEnabled = Value
      if not Value then
         local char = GetCharacter()
         if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = 50
         end
      end
   end,
})

Tab2:CreateSlider({
   Name = "JumpPower Modifier",
   Range = {50, 300},
   Increment = 10,
   Suffix = "power",
   CurrentValue = 100,
   Flag = "JumpPowerValueFlag",
   Callback = function(Value)
      State.JumpPowerValue = Value
   end,
})

Tab2:CreateToggle({
   Name = "Walk on Water (Jesus Mode)",
   CurrentValue = false,
   Flag = "JesusModeFlag",
   Callback = function(Value)
      State.JesusMode = Value
   end,
})

Tab2:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipFlag",
   Callback = function(Value)
      State.Noclip = Value
   end,
})

Tab2:CreateToggle({
   Name = "Safe Fly",
   CurrentValue = false,
   Flag = "SafeFlyFlag",
   Callback = function(Value)
      State.SafeFly = Value
   end,
})

Tab2:CreateSlider({
   Name = "Fly / Movement Speed",
   Range = {50, 300},
   Increment = 10,
   Suffix = "studs/s",
   CurrentValue = 100,
   Flag = "FlySpeedFlag",
   Callback = function(Value)
      State.FlySpeed = Value
   end,
})

-- =================================================================
-- TAB 3: ISLAND TELEPORTER
-- =================================================================
local TabTeleport = Window:CreateTab("Islands Teleport", 4483362458)

TabTeleport:CreateSection("First Sea (Sea 1)")
TabTeleport:CreateDropdown({
   Name = "Select First Sea Island",
   Options = sea1Options,
   CurrentOption = {sea1Options[1]},
   MultipleOptions = false,
   Flag = "Sea1IslandSelect",
   Callback = function(Option)
      State.SelectedSea1Island = (type(Option) == "table") and Option[1] or Option
   end,
})

TabTeleport:CreateButton({
   Name = "Teleport to Selected First Sea Island",
   Callback = function()
      local target = State.SelectedSea1Island or sea1Options[1]
      if IslandData.Sea1[target] then
         TeleportToIsland(IslandData.Sea1[target])
      end
   end,
})

TabTeleport:CreateSection("Second Sea (Sea 2)")
TabTeleport:CreateDropdown({
   Name = "Select Second Sea Island",
   Options = sea2Options,
   CurrentOption = {sea2Options[1]},
   MultipleOptions = false,
   Flag = "Sea2IslandSelect",
   Callback = function(Option)
      State.SelectedSea2Island = (type(Option) == "table") and Option[1] or Option
   end,
})

TabTeleport:CreateButton({
   Name = "Teleport to Selected Second Sea Island",
   Callback = function()
      local target = State.SelectedSea2Island or sea2Options[1]
      if IslandData.Sea2[target] then
         TeleportToIsland(IslandData.Sea2[target])
      end
   end,
})

TabTeleport:CreateSection("Third Sea (Sea 3)")
TabTeleport:CreateDropdown({
   Name = "Select Third Sea Island",
   Options = sea3Options,
   CurrentOption = {sea3Options[1]},
   MultipleOptions = false,
   Flag = "Sea3IslandSelect",
   Callback = function(Option)
      State.SelectedSea3Island = (type(Option) == "table") and Option[1] or Option
   end,
})

TabTeleport:CreateButton({
   Name = "Teleport to Selected Third Sea Island",
   Callback = function()
      local target = State.SelectedSea3Island or sea3Options[1]
      if IslandData.Sea3[target] then
         TeleportToIsland(IslandData.Sea3[target])
      end
   end,
})

Rayfield:Notify({
   Title = "Hub Executed",
   Content = "Script loaded with all requested features.",
   Duration = 5,
   Image = 4483362458,
})
