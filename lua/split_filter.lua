-- split_filter.lua
-- 直接返回函数，适配 lua_filter@*split_filter 语法

local function split_filter(input, env)
    local seen = {}
    for cand in input:iter() do
        local text = cand.text
        if text:find("|") then
            local main_text, extra_text = text:match("([^|]+)|([^|]+)")
            if main_text and extra_text then
                -- 1. 输出中文部分
                if not seen[main_text] then
                    yield(Candidate(cand.type, cand.start, cand._end, main_text, cand.comment))
                    seen[main_text] = true
                end
                -- 2. 输出拉丁名
                if not seen[extra_text] then
                    yield(Candidate(cand.type, cand.start, cand._end, extra_text, " " .. main_text))
                    seen[extra_text] = true
                end
                -- 不 yield 原始带 | 的 cand
            else
                if not seen[text] then yield(cand) seen[text] = true end
            end
        else
            if not seen[text] then
                yield(cand)
                seen[text] = true
            end
        end
    end
end

return split_filter
