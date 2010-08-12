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
local track = 0

local handlers =
{
	REM = function(o, k, v)
		if track > 0 then
			o.tracks[track][k] = v
		else
			o[k] = v
		end
	end,
	TITLE = function(o, s)
		if track > 0 then
			o.tracks[track].title = s
		else
			o.title = s
		end
	end,
	PERFORMER = function(o, s)
		if track > 0 then
			o.tracks[track].performer = s
		else
			o.performer = s
		end
	end,
	FILE = function(o, s1, s2)
		o.filename = s1
		o.filetype = s2
	end,
	TRACK = function(o, n, s)
		track = tonumber(n)
		o.tracks[track] = {
			type = s,
			indices = {}
		}
	end,
	ISRC = function(o, s)
		o.tracks[track].isrc = s
	end,
	CATALOG = function(o, s)
		o.catalog = s
	end,
	SONGWRITER = function(o, s)
		if track > 0 then
			o.tracks[track].songwriter = s
		else
			o.songwriter = s
		end
	end,
	INDEX = function(o, n, s)
		o.tracks[track].indices[n] = timestampToSeconds(s)
	end
}
setmetatable(handlers, {
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