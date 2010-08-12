local cl = require("cl")

local error,print,setmetatable,tonumber,type = error,print,setmetatable,tonumber,type
local ioOpen = io.open
local stringByte = string.byte

module("cue")

local function timestampToSeconds(s)
	-- assumes mm:ss:ms
	local m, s, ms = s:match("(%d+):(%d+):(%d+)")
	local m, s, ms = tonumber(m)*60, tonumber(s), tonumber(ms)/100
	return m + s + ms
end

local o = {tracks={}}
local current = o

local handlers = setmetatable({
	REM = function(o, k, v)
		current[k:lower()] = v
	end,
	TITLE = function(o, s)
		current.title = s
	end,
	PERFORMER = function(o, s)
		current.performer = s
	end,
	FILE = function(o, s1, s2)
		current.filename = s1
		current.filetype = s2
	end,
	TRACK = function(o, n, s)
		local n = tonumber(n)
		o.tracks[n] = {
			type = s,
			indices = {}
		}
		current = o.tracks[n]
	end,
	ISRC = function(o, s)
		current.isrc = s
	end,
	CATALOG = function(o, s)
		current.catalog = s
	end,
	SONGWRITER = function(o, s)
		current.songwriter = s
	end,
	INDEX = function(o, n, s)
		current.indices[n] = timestampToSeconds(s)
	end
}, {
	__index = function(t, k)
		error("no handler for value "..k)
	end
})

function decode(inF)
	local intype = type(inF)
	if intype == "string" and not inF:find("\n") then
		-- assume filename
		inF = ioOpen(inF, "r")
	end
	local intype = type(inF)
	if intype == "userdata" and inF.read then
		-- assume file handle
		-- UTF-8 BOM removal
		local app = inF:read(3)
		if app == "\239\187\191" then
			app = nil
		end
		while true do
			local n = inF:read("*l")
			if not n then break end
			local f,a,b = cl.unpack(n:gsub("\r", ""))
			if app then
				f = app..f
				app = nil
			end
			handlers[f](o, a, b)
		end
		inF:close()
	elseif intype == "string" then
		-- assume raw cuesheet
		-- UTF-8 BOM removal
		if inF:match("^\239\187\191") then
			inF = inF:sub(4)
		end
		if inF:sub(#inF) ~= "\n" then
			inF = inF.."\n"
		end
		while true do
			local n = inF:find("\n")
			if not n then break end
			local f,a,b = cl.unpack(inF:sub(1,n-1))
			handlers[f](o, a, b)
			inF = inF:sub(n+1)
		end
	else
		error("unhandled input type", 2)
	end
	return o
end