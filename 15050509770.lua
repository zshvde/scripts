repeat task.wait() until game:isLoaded()

if game.PlaceId ~= 15050509770 then return end

local Services = {
    ['Workspace'] = game:GetService('Workspace'),
    ['Players'] = game:GetService('Players'),
    ['PlayerScripts'] = game:GetService('Players').LocalPlayer.PlayerScripts,
    ['PlayerGui'] = game:GetService('Players').LocalPlayer.PlayerGui,
    ['VirtualUser'] = game:GetService('VirtualUser'),
    ['ReplicatedStorage'] = game:GetService('ReplicatedStorage')
}

local Utils = {}; 
do
    function Utils:sendMessage(text)
        getsenv(Services.PlayerGui.Message.Mes).ShowMessage(text, 'rbxassetid://6908011002')
    end

    function Utils:initEnvs()
        getgenv().Settings = {
            claimEvent = false,
            claimGifts = false,
            claimQuest = false,
            push = false,
            click = false,
            rebirth = false,
            superRebirth = false,
            relics = {
                enabled = false,
                minimum = 3
            }
        }
    end

    function Utils:getEggs() 

    end

    function Utils:getRelicsBackpack()
        local Relics = {} local Module = require(Services.ReplicatedStorage.GuiUtils.Ornaments)
        for i,v in next, Module.getBackpackData() do if not Relics[v.GUID] then Relics[v.GUID] = v.Amount; end end
        return Relics
    end

    function Utils:mergeRelics()
        for i,v in next, Utils:getRelicsBackpack() do
            if v >= getgenv().Settings.relics.minimum then Services.ReplicatedStorage.Remote.Event.Ornaments.PlayerTryMerge:FireServer({i, i, i}) end
        end
    end

    function Utils:doClick()
        Services.VirtualUser:CaptureController()
        Services.VirtualUser:ClickButton1(Vector2.new(0, 0), Services.Workspace.CurrentCamera.CFrame)
    end

    function Utils:doPushToEnd()
        local progress = tonumber(Services.PlayerGui.ProgressGui.BarTip.Bar.ClickToShow.Val.Text:sub(1, -4))
        local ball = Services.Workspace.Ball:FindFirstChild(tostring(Services.Players.LocalPlayer.UserId))
        if ball then 
            Services.Players.LocalPlayer.Character:FindFirstChild('HumanoidRootPart').CFrame = Services.Workspace.End[Services.Players.LocalPlayer.World.Value].CFrame
            if progress >= 95 or progress == 100 or progress == 0 then Services.ReplicatedStorage.Remote.Event.Game:FindFirstChild('[C-S]PlayerEnd'):FireServer(true, 1) end
        else Services.ReplicatedStorage.Remote.Event.Game:FindFirstChild('[C-S]PlayerTryBall'):FireServer(Services.Players.LocalPlayer.World.Value) end
    end

    function Utils:doRebirth()
        Services.ReplicatedStorage.Remote.Event.Eco:FindFirstChild('[C-S]PlayerTryRebirth'):FireServer() 
    end
    
    function Utils:doSuperRebirth()
        if Services.Players.LocalPlayer.Eco.rebirth.Value >= 35 then Services.ReplicatedStorage.Remote.Event.Eco:FindFirstChild('[C-S]PlayerTrySuperRebirth'):FireServer() end
    end

    function Utils:claimEvent()
        local claimable = Services.PlayerGui.Main.Event1.Save.Value
        if claimable == 0 then return end
        for i = 1, claimable do Services.ReplicatedStorage.Remote.Event.Events:FindFirstChild('[C-S]TryUseEventCount'):FireServer('Event1', 1) end
    end

    function Utils:claimGifts()
        local ex = {['4'] = true, ['7'] = true, ['9'] = true, ['12'] = true}
        for _, v in pairs(Services.PlayerGui.Main.OnlineRewards.Holder:GetChildren()) do
            if v.ClassName == 'ImageButton' and not ex[v.Name] and v.Timer.Value == 0 then
                Services.ReplicatedStorage.Remote.Event.Reward:FindFirstChild('[C-S]TryGetReward'):FireServer(v.Name)
            end
        end
    end

    function Utils:claimSpins()
        local claimable = Services.PlayerGui.HUD.SpinButton.Notification.Inner.NotificationValue.Text
        if claimable == 0 then return end
        for i = 1, claimable do Services.ReplicatedStorage.Remote.Function.Spin:FindFirstChild('[C-S]TrySpin'):InvokeServer() end
    end

    function Utils:claimQuest()
        if Services.PlayerGui.Main.OnlineEvent.Info.Button.Claim.Visible == false then return end
        Services.ReplicatedStorage.Remote.Event.Events:FindFirstChild('[C-S]PlayerTryGetEventReward'):FireServer('OnlineEvent')
    end
end 

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/zshvde/ui/main/ui.lua'))() Utils:initEnvs()
local Name = game:GetService('HttpService'):GenerateGUID(false):gsub('-', ''):gsub('.', function(c) if math.random() < 0.5 then return '' else return c end end) local UI = Library.new(Name)

local Pages = {} local Sections = {}

Pages.Main = UI:addPage('Main', 5012544693)
Pages.Farming = UI:addPage('Farming', 5012544693)
Pages.Claimables = UI:addPage('Claimables', 5012544693)
Pages.Relics = UI:addPage('Relics', 5012544693)
-- Pages.Shop = UI:addPage('Shop', 5012544693)
Pages.Settings = UI:addPage('Settings', 5012544693)

Sections.Main = Pages.Main:addSection('Welcome ' .. Services.Players.LocalPlayer.Name .. ', thanks for using my script.')
if (game.PlaceVersion ~= 4485) then
    Sections.Main = Pages.Info:addSection('Information')
    Sections.Main:addButton('An update of the Game has been detected.\nThis means certain functions may get you banned')
end

Sections.Farming = Pages.Farming:addSection('Farming')
Sections.Farming:addToggle('Auto Click', nil, function(value)
    getgenv().Settings.click = value
    while getgenv().Settings.click and task.wait(.15) do 
        coroutine.wrap(function()
            Utils:doClick() 
        end)()
    end
end)
Sections.Farming:addToggle('Auto Push', nil, function(value)
    getgenv().Settings.push = value
    while getgenv().Settings.push and task.wait(.1) do 
        coroutine.wrap(function()
            Utils:doPushToEnd() 
        end)()
    end
end)
Sections.Farming:addToggle('Auto Rebirth', nil, function(value)
    getgenv().Settings.rebirth = value
    while getgenv().Settings.rebirth and task.wait(.1) do 
        coroutine.wrap(function()
            Utils:doRebirth()
        end)()
    end
end)
Sections.Farming:addToggle('Auto Super Rebirth', nil, function(value)
    getgenv().Settings.superRebirth = value
    while getgenv().Settings.superRebirth and task.wait(.1) do 
        coroutine.wrap(function()
            Utils:doSuperRebirth()
        end)()
    end
end)

Sections.Claimables = Pages.Claimables:addSection('Claimables')
Sections.Claimables:addToggle('Auto Claim Gifts', nil, function(value)
    getgenv().Settings.claimGifts = value
    while getgenv().Settings.claimGifts and task.wait(.1) do 
        coroutine.wrap(function()
            Utils:claimGifts()
        end)()
    end
end)
Sections.Claimables:addToggle('Auto Claim Event', nil, function(value)
    getgenv().Settings.claimEvent = value
    while getgenv().Settings.claimEvent and task.wait(.1) do 
        coroutine.wrap(function()
            Utils:claimEvent() 
        end)()
    end
end)
Sections.Claimables:addToggle('Auto Claim Quest', nil, function(value)
    getgenv().Settings.claimQuest = value
    while getgenv().Settings.claimQuest and task.wait(.1) do 
        coroutine.wrap(function()
            Utils:claimQuest()
        end)()
    end
end)
Sections.Claimables:addButton('Claim Spins', function() 
    coroutine.wrap(function()
        Utils:claimSpins()
    end)()
end)

Sections.Relics = Pages.Relics:addSection('Relics')
Sections.Relics:addSlider('Minimum Amount', 3, 3, 33, function(value) getgenv().Settings.relics.minimum = value end)
Sections.Relics:addToggle('Auto Merge Relics', nil, function(value)
    getgenv().Settings.relics.enabled = value
    while getgenv().Settings.relics.enabled and task.wait(.1) do 
        coroutine.wrap(function()
            Utils:mergeRelics()
        end)()
    end
end)

Sections.Settings = Pages.Settings:addSection('Settings')
Sections.Settings:addKeybind('Toggle GUI', Enum.KeyCode.RightShift, function() UI:toggle() end)
Sections.Settings:addButton('Destroy GUI', function()
    Utils:initEnvs()
    game:GetService('CoreGui')[Name]:Destroy() 
end)

UI:SelectPage(UI.pages[1], true)
