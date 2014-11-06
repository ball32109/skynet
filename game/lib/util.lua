

local util = {}

function util.dump_table(t, prefix, indent_input)
    local indent = indent_input
    if indent_input == nil then 
        indent = 1 
    end

    local p = nil

    local formatting = string.rep("  ", indent)
    if prefix ~= nil then
        formatting = prefix .. formatting
    end

    if t == nil then
        print(formatting.."nil")
        return
    end

    if type(t) ~= "table" then
        print(formatting..tostring(t))
        return
    end

    for k,v in pairs(t) do
        if type(v) == "table" then
            
            print(formatting..k.."->")

            util.dump_table(v, prefix, indent + 1)
        else
            print(formatting..k.."->"..tostring(v))
        end
    end
end

return util
