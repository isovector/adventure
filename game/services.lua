local services = { }

for _, service in ipairs(MOAIFileSystem.listFiles("game/services")) do
    table.insert(services, service:sub(1, -5))
end

table.sort(services)

for _, service in ipairs(services) do
    mrequire("game/services/" .. service)
end
