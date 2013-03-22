local services = { }
local gservices = { }

for _, service in ipairs(MOAIFileSystem.listFiles("src/game/services")) do
    table.insert(services, service:sub(1, -5))
end

for _, service in ipairs(MOAIFileSystem.listFiles("game/services")) do
    table.insert(gservices, service:sub(1, -5))
end

table.sort(services)
table.sort(gservices)

for _, service in ipairs(services) do
    mrequire("src/game/services/" .. service)
end

for _, service in ipairs(gservices) do
    mrequire("game/services/" .. service)
end
