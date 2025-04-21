if getgenv().PMsuncranalready == true then
	print('You cannot run PMunc twice in a single session.')
	return
end
warn('PMsunc')

print("Executor's name:", identifyexecutor())

getgenv().PMsuncranalready = true

local totaltests = 2
local testfailed = 0

local function summarize()
	local a = ((totaltests - testfailed) / totaltests) * 100
	print(testfailed, 'out of', totaltests, 'tests failed,', a..'%', 'PMunc!')
end

local function defineresult(v, b, n)
	if v == true then
		print('✅', n, '-', b)
	elseif v == nil then
		warn('⚠️', n, '-', b)
	elseif v == false then
		testfailed += 1
		warn('❌', n, '-', b)
	end
end 
local function testhookfunc()
	-- variables
    local result = {}
	local good = true
	local func = 'hookfunction'
	local resulttxt

	-- test part
	local success, failure = pcall(function()

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

		a(1)

	end)
	if success == false then
		resulttxt = 'The function returned an error mid-test: '..failure
		good = false
	elseif result[1] == 1 and result[2] == 2 and #result == 2 then
		resulttxt = 'Passed args met the requirements and were in the right ammout'
	elseif result[1] == 1 and result[2] == 2 and #result ~= 2 then
		good = nil
		resulttxt = 'Passed args were modified but in the wrong ammout (expected 2 args, got '..#result..')'
	elseif result[1] == 1 and result[2] ~= 2 and #result == 2 then
		good = false
		resulttxt = "Failed to modify the args, expected 2nd arg to be 2, got ".. result[2]
	else
		good = false
		resulttxt = "Failed to test (none of the args were corrected and returned in the expected ammout)"
	end

	return good, resulttxt, func
end

local function testhookmetamthd()
	-- variables
    local result = {}
	local good = true
	local func = 'hookmetamethod'
	local resulttxt

	-- test part
	local success, failure = pcall(function()

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
		newvalue.Name = 'S'
		table.insert(result, newvalue.Name)

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

		rm:Destroy()
	end)
	-- results

	if result[1] == 'W' and result[2] == 1 and result[3] == 2 and #result == 3 then
		resulttxt = 'Passed args met the requirements and were in the right ammout'
	elseif result[1] == 'W' and result[2] == 1 and result[3] == 2 and #result ~= 3 then
		good = nil
		resulttxt = 'Passed args were modified but in the wrong ammout (expected 2 args, got '..#result..')'
	elseif result[1] == 'W' and result[2] == 1 and result[3] ~= 2 and #result == 3 then
		good = false
		resulttxt = "Failed to modify the args, expected 2nd arg to be 2, got ".. result[2]
	elseif result[1] ~= 'W' and result[2] == 1 and result[3] == 2 and #result == 3 then
		good = false
		resulttxt = "Failed to modify the args, expected 1nd arg to be S, got ".. result[1]
	else
		good = false
		resulttxt = "Failed to test (none of the args were corrected and returned in the expected ammout)"
	end

	return good, resulttxt, func
end

defineresult(testhookfunc())
defineresult(testhookmetamthd())
summarize()
