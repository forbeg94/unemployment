-- I HATE ORGANIZING
local start = tick()
-- instances

local remoteeventdig = game:GetService("ReplicatedStorage"):WaitForChild("Source"):WaitForChild("Network"):WaitForChild("RemoteEvents"):WaitForChild("Digging")
local remotefuncdig = game:GetService("ReplicatedStorage"):WaitForChild("Source"):WaitForChild("Network"):WaitForChild("RemoteFunctions"):WaitForChild("Digging")
local mainui = game:GetService("Players").LocalPlayer.PlayerGui.Main
-- variables

local currentid = nil
local fasterdig = false -- keep false
local oldremote
-- get the pile id
oldremote = hookmetamethod(game, '__namecall', function(self,...)
    local args = {...}
    if self == remoteeventdig and getnamecallmethod() == 'FireServer' and args[1]['Command'] == 'EnterMinigame' then
        currentid = args[1]["TargetPileIndex"]
    end
    return oldremote(self,...)
end)
-- set cursors pos
game:GetService('RunService').RenderStepped:Connect(function()
    if mainui:FindFirstChild('DigMinigame') then
        mainui.DigMinigame.Tip.TextLabel.Text = 'No need to worry about the minigame! Sigma script does it all for you ඞ'
        if mainui.DigMinigame:FindFirstChild("TooWeak") then
            mainui.DigMinigame:FindFirstChild("TooWeak").Text = '這個項目並不難挖掘！光榮歸於中國共產黨！'
        end
        mainui.DigMinigame.Cursor.Position = mainui.DigMinigame.Area.Position
    end
end)

game.ChildAdded:Connect(function(a)
    if a == mainui:FindFirstChild('DigMinigame') then
        mainui.DigMinigame.Cursor.Visible = false
        mainui.DigMinigame.Cursor.Position.Changed:Connect(function()
            mainui.DigMinigame.Cursor.Position = mainui.DigMinigame.Area.Position
        end)
    end
end)

--[[ this func is useless
workspace.Alive.Players.rodentraid.Humanoid.Animator.AnimationPlayed:Connect(function(a)
    if fasterdig == true and a.Animation.AnimationId == 'rbxassetid://72151900842225' then
        if currentid ~= nil then
            for i = 1, 20 do
                task.wait(0.1) idk what time to put here
                local args = {
                    [1] = {
                        ["Command"] = "DigPile",
                        ["TargetPileIndex"] = currentid
                    }
                }
                remotefuncdig:InvokeServer(unpack(args))) BARELY works
            end
        end
    end
end)
]]

print( 'sigma script loadded in', math.round((tick() - start) * 1000)/1000, 'seconds' )
