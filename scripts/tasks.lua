tasks.last_id = 0
tasks.jobs = { }

function tasks.start(chain, continue)
    local func = chain

    if type(chain) == "table" then
        func = function()
            local follow = continue
            
            for _, link in ipairs(chain) do
                if follow == continue then
                    follow = link()
                else
                    return
                end
            end
        end
    end

    tasks.jobs[tasks.last_id] = func
    tasks.raw_start(tasks.last_id)
    
    tasks.last_id = tasks.last_id + 1
end
