local services = { }
local gservices = { }

for _, service in ipairs(MOAIFileSystem.listFiles("src/game/services")) do
    if service:sub(-4) == ".lua" then
        table.insert(services, service:sub(1, -5))
    end
end

for _, service in ipairs(MOAIFileSystem.listFiles("game/services")) do
    if service:sub(-4) == ".lua" then
        table.insert(gservices, service:sub(1, -5))
    end
end

table.sort(services)
table.sort(gservices)

for _, service in ipairs(services) do
    mrequire("src/game/services/" .. service)
end

for _, service in ipairs(gservices) do
    mrequire("game/services/" .. service)
end
