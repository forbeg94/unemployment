if not debug.info then
    warn('Missing debug.info.')
end

warn('Loaded PMunc u2.2')

print("Executor's identity:", identifyexecutor())

local howmanytests, failed, succeeded = 0, 0, 0

local function test(name, success, what)
    howmanytests += 1
    if what == nil then
        succeeded += 1
        print('🟢', name)
    else
        failed += 1
		if not getgenv()[name] then
			warn('🔴', name, 'Missing function.')
		else
        	warn('🔴', name, what)
		end
    end
end

local function checkresult(t1, t2)
	local h = true
	for i, v in pairs(t1) do
        if v ~= t2[i] then
            h = false
        end
    end
    return h
end

test('newcclosure', pcall(function()
    local a = newcclosure(function()
		return 123
    end)
    local b = function()
        return 123
    end
	assert(debug.info(a, 's') == '[C]', 'The function is not a C closure')
end))

test('iscclosure', pcall(function()
    assert(newcclosure, 'Missing newcclosure.')
    
    local acc = false

    local function a() end

    local ccfunction = newcclosure(a)

    if debug.info(ccfunction, 's') == '[C]' then
        acc = true
    end

    assert(acc == iscclosure(ccfunction), 'Failed to check if function is a C closure')
end))

test('hookfunction', pcall(function()
    local basicfunc = function(arg)
        return arg
    end

    local evilfunction = function()
        return 123
    end

    hookfunction(basicfunc, evilfunction)

    assert(basicfunc(1) == 123, 'Failed to hook function')
    assert(debug.info(basicfunc, 's') ~= '[C]', 'The function is a C closure') -- some executors do that yes
end))

test('hookmetamethod', pcall(function()
	local instance = Instance.new('BindableEvent')

	local index -- __index test

	index = hookmetamethod(game, '__index', function(self, key)
		if self == instance and key == 'Name' then
			checkpoint = true
			return 'Vro'
		end
		return index(self, key)
	end)

	instance.Name = 'Bro'

	assert(instance.Name == 'Vro', '__index failed to modify.')

	hookmetamethod(game, '__index', index)
    task.wait()
    assert(instance.Name == 'Bro', 'Failed to revert.')

    local v = 0

    instance.Event:Connect(function(arg) v = arg end)

	local namecall -- __namecall test

    namecall = hookmetamethod(game, '__namecall', function(self, ...)
        local args = {...}
        if self == instance and getnamecallmethod() == 'Fire' then
            args[1] = 1
            return namecall(self, unpack(args))
        end
        return namecall(self, ...)
    end)

    instance:Fire(123)
    task.wait()

    assert(v == 1, '__namecall failed to modify.')

    hookmetamethod(game, '__namecall', namecall)

    instance:Destroy()
end))

test('getgc', pcall(function()
	local result = {}

	local rt = {}
	local function func() end

	for _, val in pairs(getgc()) do
		if val == func() then
			table.insert(result, true)
		end
		assert(value ~= rt, "Shouldn't return tables if true wasnt passed trough it.")
	end

	for _, val in pairs(getgc(true)) do
		if val == rt then
			table.insert(result, true)
		end
	end

	assert(checkresult(result, {true, true}), "Result did not meet expectations.")
end))

test('firesignal', pcall(function()
    local txtbutton = Instance.new('TextButton')
    local fired = false
    local conncetion = txtbutton.MouseEnter:Connect(function(x, c)
		if x == 1 and c == 2 then
        	fired = true
		end
    end)
    firesignal(txtbutton.MouseEnter, 1, 2)
    assert(fired == true, 'Failed to fire signal')

	txtbutton:Destroy()
	conncetion:Disconnect()
end))

test('loadstring', pcall(function()
	local a = loadstring('return 2')
	local _, res = pcall(a)
	assert(res == 2, 'Failed to use loadstring')
end))

test('isnetworkowner', pcall(function()
    local function customino(basepart) -- please just make ur own one
        if basepart:IsA('BasePart') then
            return basepart.ReceiveAge == 0
        end
    end

    local part1 = Instance.new('Part')
    local part2 = Instance.new('Part')

    part1.Parent = workspace

    assert(customino(part1) == isnetworkowner(part1), "Unexpected result.")
	assert(customino(part2) ~= isnetworkowner(part2), "isnetworkowner does not check if the instance is in workspace.")

    part2:Destroy()
    part1:Destroy()
end))

test('cloneref', pcall(function()
    local instance = game.ReplicatedStorage

    local clone = cloneref(instance)

    assert(instance ~= clone, 'Clone and instance are identical.')
end))

test('gethui', pcall(function()
    local instance = Instance.new('Frame')
    instance.Parent = gethui()
    assert(gethui() ~= game.CoreGui, 'gethui() is the same as game.CoreGui.')
    assert(instance.Parent == gethui(), "Instance haven't been added to gethui.")
    instance:Destroy()
end))

test('getnilinstances', pcall(function()
    local instance1 = Instance.new('Part')
    local instance2 = Instance.new('Part', workspace)

    local found1, found2 = false, false

    for i, v in pairs(getnilinstances()) do
        if v == instance1 then
            found1 = true
        elseif v == instance2 then
            found2 = true
        end
    end

    assert(found1 == true, "Couldn't find an instance which is parented to nil.")
    assert(found2 == false, "Found an instance though it has a parent, whats that blud doing there")

    instance1:Destroy()
    instance2:Destroy()
end))

test('fireclickdetector', pcall(function()
    local instance = Instance.new('Part')
    instance.Parent = workspace
    instance.Anchored = true

    local clickdetector = Instance.new('ClickDetector')

    local counter = 0

    clickdetector.Parent = instance
    clickdetector.MaxActivationDistance = 100

    clickdetector.MouseClick:Connect(function()
        counter += 1
    end)
    instance.Position = game.Players.LocalPlayer.Character:WaitForChild('HumanoidRootPart').CFrame.Position + Vector3.new(0, 20, 0)

    fireclickdetector(clickdetector, 100)
    fireclickdetector(clickdetector, 1)

    assert(counter ~= 0, 'Failed to click.')
    assert(counter ~= 2, 'fireclickdetector ignores set distance.')

    instance:Destroy()
    clickdetector:Destroy()
end))

test('firetouchinterest', pcall(function()
    local instance = Instance.new('Part', workspace)
    instance.Position = Vector3.new(0, 20000, 0)

    local touching = false
    local stopped = false

    instance.Touched:Connect(function() touching = true end)
    instance.TouchEnded:Connect(function() stopped = true end)

    firetouchinterest(instance, game.Players.LocalPlayer.Character:WaitForChild('Head'), true)
    task.wait()
    firetouchinterest(instance, game.Players.LocalPlayer.Character:WaitForChild('Head'), false)
    task.wait()
    instance:Destroy()
    
    assert(touching == true, 'Failed to touch the instance.')
    assert(touching == true, 'Failed to stop touching the instance. - drake')
end))

local endingresults = (howmanytests - failed)/howmanytests
print('ℹ️',succeeded, 'Out of', howmanytests, 'Tests were successful! Your PMunc:', math.round(endingresults * 100) ..'%')
print('Thx')
