--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 18/06/2017
-- Time: 22:37
-- To change this template use File | Settings | File Templates.
--

PDUI_Bindings = PDUI_Bindings or class();

PDUI_Bindings.bindings = {};
PDUI_Bindings.handlers = {};

function PDUI_Bindings:Init()
    self:RegisterBindingHandler("label", "text", function(element, value, default, binding)

        local prefix = binding['prefix'] or "";
        local suffix = binding['suffix'] or "";

        element:set_text(tostring(prefix)..tostring(value)..tostring(suffix));
    end)

end

function PDUI_Bindings:UnloadScope(scope)
    self.bindings[scope] = nil;
end

function PDUI_Bindings:GetBindingHandler(type)
    return self.handlers[type];
end

--- func: (element, value, default)
function PDUI_Bindings:RegisterBindingHandler(type, field, func)
    self.handlers[type.."_"..field] = func;
end

function PDUI_Bindings:HasBindingHandler(type)
    return self.handlers[type] ~= nil;
end

function PDUI_Bindings:GetBindingHandler(type)
    return self.handlers[type] or nil;
end

function PDUI_Bindings:HasBindingScope(scope)
    return self.bindings[scope] ~= nil;
end

function PDUI_Bindings:ResolveInitialBindings(scope, data, type)
    local bindings = {};
    local modData = {};
    for k,v in pairs(data) do
        if k ~= "children" and PDUtils:IsTable(v) and not PDUtils:IsArray(v) then
            local vType = v['type'] or false;
            if vType and vType == "binding" then
                local d, b = self:ExtractBinding(scope, v, type, k);
                modData[k] = d;
                bindings[k] = b;
            elseif vType and vType == "fetch" then
                modData[k] = self:ExtractValue(v);
            else
                modData[k] = v;
            end
        else
            modData[k] = v;
        end
    end
    return modData, bindings;
end

function PDUI_Bindings:ExtractValue(data)
    local target = data['target'];
    return data['default'] or (target and self:GetValueFromTarget(data, target)) or "Error";
end

function PDUI_Bindings:GetValueFromTarget(data, target)
    if data['unsafe'] == true then
        return loadstring(target);
    else
        return PDUtils:SafeGet(target);
    end
end

function PDUI_Bindings:ExtractBinding(scope, data, type, field)
    local target = data['target'] or nil;
    if target == nil then return end;
    local interval = data['interval'] or 1;
    local default = self:ExtractValue(data);

    local binding = {
        element = nil,
        type = type,
        field = field,
        target = target,
        prefix = data['prefix'] or nil,
        suffix = data['suffix'] or nil,
        interval = interval,
        tick = 0,
        lastTick = 0,
        default = default,
        current = nil
    };

    self.bindings[scope] = self.bindings[scope] or {};
    table.insert(self.bindings[scope], binding);

    return default, binding;
end

function PDUI_Bindings:Update(tick, delta)
    for scope,fieldSet in pairs(self.bindings) do
        for fieldId,binding in pairs(fieldSet) do
            binding['tick'] = tick;
            if tick - binding['lastTick'] > binding['interval'] then
                binding['lastTick'] = tick;
                local value = PDUtils:SafeGet(binding.target) or "Error";
                if value ~= binding.current then
                    local type = binding['type'];
                    local field = binding['field'];
                    local handler = self:GetBindingHandler(type.."_"..field);
                    handler(binding.element, value, binding.default, binding);
                    binding.current = value;
                end
            end
        end
    end
end


