-- split_filter.lua
-- 自动拆分包含 | 分隔符的候选项
-- 例如将 "布鲁克纳|Bruckner" 拆分为 "布鲁克纳" 和 "Bruckner" 两个候选词

local function split_filter(input, env)
    for cand in input:iter() do
        if cand.text:find("|") then
            -- 使用字符串分割
            local main_text, extra_text = cand.text:match("([^|]+)|([^|]+)")
            
            if main_text and extra_text then
                -- 1. 发射第一部分 (通常是中文)
                yield(Candidate(cand.type, cand.start, cand._end, main_text, cand.comment))
                
                -- 2. 发射第二部分 (通常是英文/拉丁名)
                -- 这里的 comment 可以自定义，方便识别
                yield(Candidate(cand.type, cand.start, cand._end, extra_text, " " .. main_text))
            else
                yield(cand)
            end
        else
            yield(cand)
        end
    end
end

return split_filter
