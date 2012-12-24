--- Encapsulation of the Polygon class for game usage.
-- A Hotspot consists a Polygon, cursor, z-order information,
-- and door data for Room hotspots. These are usually created
-- in the in-game editor.

mrequire "classes/class"
mrequire "classes/polygon"

--- The Hotspot class.
-- Constructor signature is (id, cursor, name, interface, poly, priority).
-- Cursor should be an index into the game cursors.
-- Interface is a bool whther or not this Hotspot will appear as an object in game.
-- @newclass Hotspot
newclass("Hotspot", function(id, cursor, name, interface, poly, priority)
        priority = priority or 0

        return {
            id = id,
            cursor = cursor,
            name = name,
            interface = interface,
            polygon = poly,
            priority = priority,
            
            endpoint = nil,
            walkspot = nil
        }
    end
)

--------------------------------------------------
;

--- Determines if a ray at (x, y) will hit this Hotspot.
-- @param self The Hotspot instance, or a table of Hotspots.
-- @return The top-most Hotspot IF called as a static function.
function Hotspot.hitTest(self, x, y)
    -- if called as a static method, the first param is a table to search
    if type(self) == "table" then
        local best = nil
        local bestScore = -999999
        for _, hotspot in pairs(self) do
            if hotspot:hitTest(x, y) and hotspot.priority > bestScore then
                bestScore = hotspot.priority
                best = hotspot
            end
        end
        
        return best
    end

    return self.polygon:hitTest(x, y)
end

--------------------------------------------------
;

--- Turns the Hotspot into a door.
-- @param roomId The room to link to.
-- @param x The x position to enter the room at.
-- @param y The y position to enter the room at.
function Hotspot:link(roomId, x, y)
    self.endpoint = {
        room = roomId,
        x = x,
        y = y
    }
end

--- Sets a walkspot Actors will path to when interacting with this Hotspot.
function Hotspot:setWalkspot(x, y)
    self.walkspot = { x, y }
end

--- Flattens the Hotspot into a textual representation for room saving.
-- @param f The output file
-- @param indent The current indent level
-- @param name The output variable name of the hotspot
function Hotspot:__serialize(f, indent, name)
    f:write(string.format("%s%s = Hotspot.new(%q, %d, %q, %s,\n", indent, name, self.id, self.cursor, self.name, tostring(self.interface)))
    
    Serialize.put(f, self.polygon)
    
    f:write(string.format("%s, %d)\n", indent, self.priority))
    
    if self.endpoint then
        local ep = self.endpoint
        f:write(string.format("%s%s:link(%q, %d, %d)\n", indent, name, ep.room, ep.x, ep.y));
    end
    
    if self.walkspot then
        local ws = self.walkspot
        f:write(string.format("%s%s:setWalkspot(%d, %d)\n", indent, name, ws[1], ws[2]));
    end
end
