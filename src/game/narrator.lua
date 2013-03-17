--- The Narrator creates context appropriate strings given a set of rules.
-- It is used primarily to create the action text.

mrequire "src/class"

--- The Narrator class.
-- Constructor signature is (default, missing, sMatch, nMatch).
-- Default is a string to return when no rules match.
-- Missing fills in empty blanks.
-- sMatch is the score awarded for specific rule matches.
-- nMatch is the score awarded for necessary rule matches.
-- @newclass Narrator
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

--- Internal function to parse a rule table into specific and necessary conditions.
-- @param conditions
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

--- Creates a new rule which will return a string when certain conditions match.
-- @param desc The string to return. May include specific keys in braces to be replaced upon match.
-- @param conditions See getString for a description of this table
-- @see Narrator:getString
function Narrator:addRule(desc, conditions)
    local s, n = self:determineConditions(conditions)

    table.insert(self.rules, {
        desc = desc,
        specific = s,
        necessary = n
    })
end

--- Internal method to determine the score of a rule given specific and necessary conditions.
-- @param rule
-- @param s
-- @param n
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

--- Returns the best string for given conditions.
-- @param conditions Table of key=>value pairs for specific conditions, or simply value for keys which must be set.
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
