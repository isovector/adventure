breakpoints = {}

function Relevant()
	local file = props["FilePath"]
	local path = props["adventure.path"]
	
	if file:sub(0, #path) == path then
		return true
	end
	
	return false
end

function GetFile()
	local file = props["FilePath"]
	local path = props["adventure.path"]
	
	if file:sub(0, #path) == path then
		file = file:sub(#path + 1)
	end
	
	if file:sub(1, 1) == "/" then
		file = file:sub(2)
	end
	
	return file
end

function LoadBreakpoints()
	local path = props["adventure.path"] .. "/adventure.dbg"
	
	if not FileExists(path) then return end

	io.input(path)
	for breakpoint in io.lines() do
		_, _, line, file = breakpoint:find("([0-9]+)@(.*)")
		line = tonumber(line)
		
		if not breakpoints[file] then
			breakpoints[file] = { }
		end
		
		breakpoints[file][line] = 8
	end
	
	io.close()
end

function UpdateBreakpoints()
	local file = GetFile()

	if breakpoints[file] then
		for line in pairs(breakpoints[file]) do 
			editor:MarkerAdd(line - 1, 3)
		end
	end
end

function SyncBreakpoints()
	if not Relevant() then return end

	breakpoints[GetFile()] = {}
	
	local line = 0
	local markLine = 0
	markLine = editor:MarkerNext(line, 8)
	while markLine >= 0 do
		breakpoints[GetFile()][markLine + 1] = 3
		line = markLine
		markLine = editor:MarkerNext(line + 1, 8)
	end

	SaveBreakpoints()

end

function SaveBreakpoints()
	io.output(props["adventure.path"] .. "/adventure.dbg")

	for file, lines in pairs(breakpoints) do
		for line in pairs(lines) do
			line = line
			io.write(line .. "@" .. file .. "\n")
		end
	end
	
	io.close()
end

function FileExists(path)
  local file = io.open(path, "r")
  if file then file:close() end
  return file ~= nil
end

function OnOpen(f)
	editor:MarkerSetBack(3, tonumber("0000FF",16))
	if Relevant() then
		UpdateBreakpoints()
	end
end

function OnSave()
	if Relevant() then
		SyncBreakpoints()
	end
end

function ToggleBreakpoint()
	if not Relevant() then
		return
	end
	
	local line = editor:LineFromPosition(editor.CurrentPos)
	local bit = editor:MarkerGet(line)
	local file = GetFile()
	
	if bit ~= 8 then
		editor:MarkerAdd(line, 3)
	else
		editor:MarkerDelete(line, 3)
	end
	
	bit = editor:MarkerGet(line)
	
	line = line + 1
	if not breakpoints[file] then
		breakpoints[file] = {}
	end
	
	if bit ~= 8 then
		bit = nil
	end
	
	if breakpoints[file][line] ~= bit then
		breakpoints[file][line] = bit
		SaveBreakpoints()
	end
end

LoadBreakpoints()


-- these are stolen from SciteExtMan

local idx = 20
local shortcuts_used = {}
local alt_letter_map = {}
local alt_letter_map_init = false
local name_id_map = {}

function split(s,delim)
    res = {}
    while true do
        p = string.find(s,delim)
        if not p then
            table.insert(res,s)
            return res
        end
        table.insert(res,string.sub(s,1,p-1))
        s = string.sub(s,p+1)
    end
end

function splitv(s,delim)
    return unpack(split(s,delim))
end

local function set_command(name,cmd,mode)
	local _,_,pattern,md = string.find(mode,'(.+){(.+)}')
	if not _ then
		pattern = mode
		md = 'savebefore:no'
	end
	
	local which = '.'..idx..pattern
	props['command.name'..which] = name
	props['command'..which] = cmd
	props['command.subsystem'..which] = '3'
	props['command.mode'..which] = md
	name_id_map[name] = 1100+idx
	return which
end

local function set_shortcut(shortcut,name,which)
	if shortcut == 'Context' then
		local usr = 'user.context.menu'
		if props[usr] == '' then -- force a separator
			props[usr] = '|'
		end
		props[usr] = props[usr]..'|'..name..'|'..(1100+idx)..'|'
	else
		local cmd = shortcuts_used[shortcut]
		if cmd then
			print('Error: shortcut already used in "'..cmd..'"')
		else
			shortcuts_used[shortcut] = name
			if GTK then check_gtk_alt_shortcut(shortcut,name) end
			props['command.shortcut'..which] = shortcut
		end
	end
end

function scite_Command(tbl)
	if type(tbl) == 'string' then
		tbl = {tbl}
	end
  
	for i,v in pairs(tbl) do
		local name,cmd,mode,shortcut = splitv(v,'|')
		if not shortcut then
			shortcut = mode
			mode = '.*'
		else
			mode = '.'..mode
		end
	 
		local which = set_command(name,cmd,mode)
		if shortcut then
			set_shortcut(shortcut,name,which)
		end
	end
end

scite_Command('Breakpoint|ToggleBreakpoint|F9')