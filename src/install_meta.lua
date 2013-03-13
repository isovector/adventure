--- Installs runtime metalua support.

package.path = "/usr/share/lua/5.1/?.luac;" .. package.path
require "metalua.compiler"

--- Like lua's require(), but loading sources as metalua instead.
-- @param path
function mrequire(path)
    if package.loaded[path] then
        return package.loaded[path]
    end
    
    local file = mlc.luafile_to_function(path .. ".lua")
    package.loaded[path] = file
    return file()
end

mrequire "src/meta/reference"
