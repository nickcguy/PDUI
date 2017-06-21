--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 18/06/2017
-- Time: 19:38
-- To change this template use File | Settings | File Templates.
--

PDUtils = PDUtils or class();

function PDUtils:FileExists(file)
    local f = io.open(file, "rb")
    if f then f:close() end
    return f ~= nil
end

function PDUtils:FileReadable(file)
    if not self:FileExists(file) then return false end;
    return io.file_is_readable(file);
end

function PDUtils:ShowHint(text, time)
    if managers.hud then
        managers.hud:show_hint({text = text, time = time});
    elseif managers.chat then
        managers.chat:send_message(1, "PDUI", text);
    end
end

function PDUtils:ReadLines(file)
    if not self:FileReadable(file) then return nil end;
    local lines = {};
    for line in io.lines(file) do
        lines[#lines + 1] = line;
    end
    return lines;
end

function PDUtils:ReadFile(file)
    if not self:FileReadable(file) then return nil end;
    local lines = self:ReadLines(file);
    local data = "";
    for _,v in pairs(lines) do
        data = data..tostring(v);
    end
    return data;
end

function PDUtils:EndsWith(String,End)
    return End=='' or string.sub(String,-string.len(End))==End
end

function PDUtils:TransformBounds(bounds, parent)
    bounds = bounds or {0, 0, 0, 0};
    bounds[1] = parent[1] + bounds[1];
    bounds[2] = parent[2] + bounds[2];

    if bounds[3] and type(bounds[3]) == "string" and self:EndsWith(bounds[3], "%") then
        local width = bounds[3]:sub(1, -2)
        width = tonumber(width) / 100;
        bounds[3] = parent[3] * width;
    end

    if bounds[4] and type(bounds[4]) == "string" and self:EndsWith(bounds[4], "%") then
        local height = bounds[4]:sub(1, -2)
        height = tonumber(height) / 100;
        bounds[4] = parent[4] * height;
    end

    return bounds;
end

function PDUtils:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function PDUtils:IsTable(obj)
    return type(obj) == "table";
end

function PDUtils:IsArray(array)
    for k, _ in pairs(array) do
        if type(k) ~= "number" then
            return false
        end
    end
    return true --Found nothing but numbers !
end

function PDUtils:SafeGet(path, fallback, origin)
    local from = origin or _G
    local lPath = ''
    for curr,delim in string.gmatch (path, "([%a_]+)([^%a_]*)") do
        local isFunc = string.find(delim,'%(')
        if isFunc then
            if from and (type(from) == 'table' or type(from) == 'userdata') and from[curr] then
                from = from[curr](from)
            else
                from = nil
                break
            end
        else
            from = from[curr]
        end
        lPath = lPath..curr..delim
        if not from then
            break
        elseif type(from) ~= 'table' and type(from) ~= 'userdata' then
            if lPath ~= path then
                from = nil
                break
            end
        end
    end
    if not from and fallback ~= nil then
        return fallback
    else
        return from
    end
end

function PDUtils:FindKey(table, v)
    for i,value in pairs(table) do
        if value == v then
            return i;
        end
    end
    return nil;
end

function PDUtils:RemoveValue(t, value)
    local i = self:FindKey(t, value);
    if i ~= nil then
        table.remove(t, i);
    end
end

function PDUtils:T(cond, ifTrue, ifFalse)
    if cond then
        return ifTrue;
    end
    return ifFalse;
end