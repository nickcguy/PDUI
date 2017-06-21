--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 21/06/2017
-- Time: 14:47
-- To change this template use File | Settings | File Templates.
--

PDUI_DOM = {};
PDUI_DOM.__index = PDUI_DOM;

setmetatable(PDUI_DOM, {
    call = function(cls, ...)
        return cls.new(...);
    end
});

function PDUI_DOM.new()
    local self = setmetatable({}, PDUI_DOM)
    self.roots = {}
    return self
end

function PDUI_DOM:AddRoot(node)
    table.insert(self.roots, node);
end

function PDUI_DOM:RemoveRoot(node)
    PDUtils:RemoveValue(self.roots, node);
end

function PDUI_DOM:Log(prefix)
    prefix = prefix or ""
    log("DOM")
    for _,root in pairs(self.roots) do
        root:Log(prefix.."  ");
    end
end

function PDUI_DOM:FindScoped(scope)
    local found = {};
    for _,root in pairs(self.roots) do
        root:FindScoped_Int(scope, found);
    end
    return found;
end

function PDUI_DOM:RemoveScope(scope)
    log("Removing scope")
    local scoped = self:FindScoped(scope);
    for _,e in pairs(scoped) do
        e:Remove();
    end
end