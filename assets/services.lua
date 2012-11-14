local services = { }

for _, service in ipairs(MOAIFileSystem.listFiles("assets/services")) do
    table.insert(services, service:sub(1, -5))
end

table.sort(services)

for _, service in ipairs(services) do
    require("assets/services/" .. service)
end
