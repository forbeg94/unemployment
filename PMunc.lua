warn('Loaded PMunc u2.11')

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

local function missingstuff(name, _, msg)
	if msg then
		warn('🟡 ', msg)
	end
end
missingstuff('debug.info', pcall(function() assert(debug.info, 'Missing debug.info') end))

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
    local result = {}

    local a = newcclosure(function()
		table.insert(result, 1)
        task.wait(1)
		table.insert(result, 2)
    end)
	assert(debug.info(a, 's') == '[C]', 'The function is not a C closure')
    assert(checkresult(result, {1, 2}), "Unexpected result.")
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
    local result = {}

    local function a(arg)
        table.insert(result, arg)
        return arg
    end

    a(1)

    local oldfunc
    oldfunc = hookfunction(a, function(arg)
        arg = 2
        return oldfunc(arg)
    end)

    a(1) -- should return 2 because it was hooked

	assert(checkresult(result, {1, 2}), 'Result did not meet expectations.') -- Should return {1, 2}
end))

test('hookmetamethod', pcall(function()
	local result = {}

	local newvalue = Instance.new('IntValue', game)

	newvalue.Name = 'S'

	value = newvalue

	local oldname

	oldname = hookmetamethod(game, '__index', function(self, key)
		if self == newvalue and key == 'Name' then
			return 'W'
		end
		return oldname(self, key)
	end)

	assert(newvalue.Name == 'W', 'Failed to spoof value.')
	newvalue:Destroy()

	local rm = Instance.new('BindableEvent', game)

	rm.Event:Connect(function(arg)
		table.insert(result, arg)
	end)

	rm:Fire(1)

	local oldevent;

	oldevent = hookmetamethod(game, '__namecall', function(self, ...)
		local args = {...}
		if self == rm and getnamecallmethod() == 'Fire' then
			args[1] = 2
			return oldevent(self, unpack(args))
		end
		return oldevent(self, ...)
	end)
	rm:Fire(1)
	assert(result[2] ~= nil, 'Failed to return.')
	assert(result[2] ~= 1, 'Failed to modify arg.')
	rm:Destroy()
end))

test('getgc', pcall(function()
	local result = {}

	local rt = {}
	local function func() end

	for _, val in pairs(getgc()) do
		if val == func() then
			table.insert(result, true)
		end
		assert(value ~= rt, "Shouldn't return tables if true wasnt passed trough it.") -- shouldn't return because yes
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
    local function custominw(basepart) -- please just make ur own one
        if basepart:IsA('BasePart') then
            return basepart.ReceiveAge == 0
        end
    end

    local part1 = Instance.new('Part')
    local part2 = Instance.new('Part')

    part1.Parent = workspace

    assert(custominw(part1) == isnetworkowner(part1), "Unexpected result.")
	assert(custominw(part2) ~= isnetworkowner(part2), "isnetworkowner does not check if the instance is in workspace.")

    part2:Destroy()
    part1:Destroy()
end))

local endingresults = (howmanytests - failed)/howmanytests
print('ℹ️',succeeded, 'Out of', howmanytests, 'Tests were successful! Your PMunc:', math.round(endingresults * 100) ..'%')
