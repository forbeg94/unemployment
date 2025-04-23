warn('Loaded PMunc u2.01')

print("Executor's identity:", identifyexecutor())

local function test(name, success, what)

    if what == nil then
        print('🟢', name)
    else
        warn('🔴', name, what)
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
    local result = {}

    newcclosure(function()
		table.insert(result, 1)
        task.wait(1) -- should be able to yield (thx sunc)
		table.insert(result, 2)
    end)
    assert(checkresult(result, {1, 2}), "Unexpected result.") -- this SHOULDN'T fail at all, well except if ur exec is shit
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

	oldname = hookmetamethod(game, '__index', function(self, ass)
		if self == newvalue and ass == 'Name' then
			return 'W'
		end
		return oldname(self, ass)
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
		assert(value ~= rt, "Shouldn't return tables if true wasnt passed trough it, though it did..")
	end

	for _, val in pairs(getgc(true)) do
		if val == rt then
			table.insert(result, true)
		end
	end

	assert(checkresult(result, {true, true}), "Result did not meet expectations.")
end))
