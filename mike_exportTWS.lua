---------------------------------------------------------------------------------------------------
-- Export start 
---------------------------------------------------------------------------------------------------

f_tews =
{
Start=function(self) 
	package.path = package.path..";.\\LuaSocket\\?.lua"
	package.cpath = package.cpath..";.\\LuaSocket\\?.dll"
	socket = require("socket")
	
	local my_init = socket.protect(function()	
		-- export telemetry to instrumeny panel on android
		host_tews = host_tews or "alarmpi" or "nidefi.lowell" or "android-aa27056d7f19452f.lowell"  	 -- android IP
		port_tews = port_tews or 6001
		c_tews = socket.try(socket.connect(host_tews, port_tews)) -- connect to the listener socket
		c_tews:setoption("tcp-nodelay",true) -- set immediate transmission mode
		c_tews:settimeout(.1)
		--caplog = io.open("C:\users\mike\caplog.json","a")
	end)
	my_init()	
end,

ActivityNextEvent=function(self, t)
	local tNext = t
	
	-- read from TWS FC3 export
	local threats = LoGetTWSInfo()
	local jsonThreats = "{ \"Mode\":1.0, \"MTime\": 0, \"Emitters\":[{ \"ID\":\"test\", \"Power\":0.5, \"Azimuth\":0.8, \"Priority\":150, \"SignalType\":\"scan\", \"Type\":\"CONN\" }] }\n"
	if threats then		
		-- add emitters to json
		local jsonEmitters = "[ "
		for mode,emit in pairs (threats.Emitters) do
			local jsonEmit = ""		
			local threatType = LoGetNameByType(emit.Type.level1, emit.Type.level2, emit.Type.level3, emit.Type.level4)
			if threatType then
				jsonEmit = string.format("{ \"ID\":\"%s\", \"Power\":%f, \"Azimuth\":%f, \"Priority\":%f, \"SignalType\":\"%s\", \"Type\":\"%s\", \"TypeInts\":[%f,%f,%f,%f] }", emit.ID, emit.Power, emit.Azimuth, emit.Priority, emit.SignalType, threatType, emit.Type.level1, emit.Type.level2, emit.Type.level3, emit.Type.level4 )		
			else
				jsonEmit = string.format("{ \"ID\":\"%s\", \"Power\":%f, \"Azimuth\":%f, \"Priority\":%f, \"SignalType\":\"%s\", \"Type\":\"U\" }", emit.ID, emit.Power, emit.Azimuth, emit.Priority, emit.SignalType)		
			end
			if jsonEmitters ~= "[ " then
				jsonEmitters = jsonEmitters .. ","
			end
			jsonEmitters = jsonEmitters .. jsonEmit
		end
		jsonEmitters = jsonEmitters .. "]"
		
		jsonThreats = string.format("{ \"Mode\":%f, \"MTime\": %f, \"Emitters\":%s }\n", threats.Mode, LoGetModelTime(), jsonEmitters)		
	end
	
	local my_send = socket.protect(function()
		if c_tews then
			socket.try(c_tews:send(jsonThreats))
			--caplog:write(jsonThreats)
		end
	end)
	my_send()
	
	return tNext + 0.1
end,

Stop=function(self)
	local my_close = socket.protect(function()
		if c_tews then
			c_tews:close()
		end	
	end)
	my_close()
	--caplog:close()
end
}


-- =============
-- Overload
-- =============

-- Works once just before mission start.
do
	local PrevLuaExportStart=LuaExportStart
	LuaExportStart=function()
		f_tews:Start()
		if PrevLuaExportStart then
			PrevLuaExportStart()
		end
	end
end

-- Works just after every simulation frame.
do
	local PrevLuaExportActivityNextEvent=LuaExportActivityNextEvent
	LuaExportActivityNextEvent=function(t)
		local tNext = t
		tNext = f_tews:ActivityNextEvent(t)
		if PrevLuaExportActivityNextEvent then
			PrevLuaExportActivityNextEvent(t)
		end
		return tNext
	end
end

-- Works once just after mission stop.
do
	local PrevLuaExportStop=LuaExportStop
	LuaExportStop=function()
		f_tews:Stop()
		if PrevLuaExportStop then
			PrevLuaExportStop()
		end
	end
end
