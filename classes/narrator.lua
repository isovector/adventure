mrequire "classes/class"

newclass("Narrator",
    function(default, missing, sMatch, nMatch)
        return {
            default = default,
            missing = missing or "",
            sMatch = sMatch or 10,
            nMatch = nMatch or 1,
            
            rules = { }
        }
    end
)

function Narrator:determineConditions(conditions)
    local specific = { }
    local necessary = { }
    
    for key, val in pairs(conditions) do
        if type(key) == "number" then
            necessary[val] = true
        else
            specific[key] = val
        end
    end
    
    return specific, necessary
end

function Narrator:addRule(desc, conditions)
    local s, n = self:determineConditions(conditions)

    table.insert(self.rules, {
        desc = desc,
        specific = s,
        necessary = n
    })
end

function Narrator:evaluate(rule, s, n)
    local score = 0
    
    for key, val in pairs(rule.specific) do
        if s[key] == val then
            score = score + self.sMatch
        else
            return 0
        end
    end
    
    for key, val in pairs(rule.necessary) do
        if s[key] or n[key] then
            score = score + self.nMatch
        else
            return 0
        end
    end
    
    return score
end

function Narrator:getString(conditions)
    local s, n = self:determineConditions(conditions)
    
    local bestScore = 0
    local bestRule = nil
    
    for _, rule in ipairs(self.rules) do
        local score = self:evaluate(rule, s, n)
        
        if score > bestScore then
            bestRule = rule
            bestScore = score
        end
    end
    
    local desc = self.default
    if bestRule then
        desc = bestRule.desc
    end
    
    for key, val in pairs(s) do
        desc = desc:gsub(string.format("{%s}", key), val)
    end
    
    desc = desc:gsub("{[^}]+}", self.missing)
    
    return desc
end
