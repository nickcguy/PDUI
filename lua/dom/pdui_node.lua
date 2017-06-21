--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 21/06/2017
-- Time: 14:33
-- To change this template use File | Settings | File Templates.
--

PDUI_Node = {};
PDUI_Node.__index = PDUI_Node;

setmetatable(PDUI_Node, {
    __call = function(cls, ...)
        return cls.new(...);
    end
});

function PDUI_Node.new(dom, type, element, parent, bounds)
    local self = setmetatable({}, PDUI_Node);
    self.dom = dom;
    self.type = type;
    self.element = element;
    self._parent = parent;
    self.bounds = bounds;
    self.scope = "";
    self.children = {};
    self.dead = false;

    self.events = {};

    if self._parent == nil then
        dom:AddRoot(self);
    else
        self._parent:AddChild(self);
    end

    return self;
end

function PDUI_Node:SetParent(parent)
    self._parent = parent;
end

function PDUI_Node:AddChild(node)
    table.insert(self.children, node);
end
function PDUI_Node:RemoveChild(node)
    PDUtils:RemoveValue(self.children, node);
end

function PDUI_Node:GetWidget()
    return self.element;
end

function PDUI_Node:set_x(x)
    self:SetPosition(x, self.bounds[2])
end
function PDUI_Node:set_y(y)
    self:SetPosition(self.bounds[1], y)
end

function PDUI_Node:SetPosition(x, y)
    self.bounds[1] = x
    self.bounds[2] = y
    self:InvalidateBounds()
    local b = PDUtils:TransformBounds({x, y}, self.bounds)
    for _,child in pairs(self.children) do
        child:SetPosition(b[1], b[2]);
    end
end

function PDUI_Node:SetBounds(x, y, w, h)
    self.bounds[1] = x
    self.bounds[2] = y
    self.bounds[3] = w
    self.bounds[4] = h
    self:InvalidateBounds()
    local b = PDUtils:TransformBounds({x, y, w, h}, self.bounds)
    for _,child in pairs(self.children) do
        child:SetBounds(b[1], b[2], b[3], b[4]);
    end
end

function PDUI_Node:GetAbsoluteBounds()
    local b = self.bounds;
    if self._parent ~= nil then
        b = PDUtils:TransformBounds(b, self._parent:GetAbsoluteBounds());
    end
    return b;
end

function PDUI_Node:InvalidateBounds()
    local w = self:GetWidget();
    local b = self.bounds;
    w:set_x(b[1]);
    w:set_y(b[2]);
    w:set_width(b[3]);
    w:set_height(b[4]);
end

function PDUI_Node:x()
    return self.bounds[1];
end

function PDUI_Node:y()
    return self.bounds[2];
end

function PDUI_Node:width()
    return self.bounds[3];
end

function PDUI_Node:height()
    return self.bounds[4];
end

function PDUI_Node:left()
    return self:GetWidget():left()
end

function PDUI_Node:right()
    return self:GetWidget():right()
end

function PDUI_Node:Log(prefix)
    log(prefix.."Type: "..self.type);
    log(prefix.."Bounds: "..json.encode(self.bounds));
    log(prefix.."Alive: "..PDUtils:T(self.dead, "False", "True"));
    log(prefix.."Element state: ".. PDUtils:T(self.element ~= nil, "Present", "Missing"))
    for _,child in pairs(self.children) do
        child:Log(prefix.."  ")
    end
end

function PDUI_Node:FindScoped(scope)
    local found = {};
    self:FindScoped_Int(scope, found);
    return found;
end

function PDUI_Node:FindScoped_Int(scope, found)
    if self.scope == scope then
        table.insert(found, self);
    end
    for _,child in pairs(self.children) do
        child:FindScoped_Int(scope, found);
    end
end

function PDUI_Node:parent()
    return self._parent;
end

function PDUI_Node:Remove()
    if self.dead then return end;
    for _,child in pairs(self.children) do
        child:Remove();
    end
    if self.events['remove'] ~= nil then
        self.events['remove']();
    end
    local w = self:GetWidget();
    if w.clear ~= nil then
        w:clear();
    end
    if self._parent then
        self._parent:RemoveChild(self);
    else
        self.dom:RemoveRoot(self);
    end
    self.dead = true;
end

function PDUI_Node:Animate(animFunc)
    self:GetWidget():animate(animFunc);
end

-- Animation Helpers

function PDUI_Node:AnimateColour(targetCol, time, callback)
    self:Animate(function(o)
        local colour = o:color();
        over(time, function(p)
            o:set_color(math.lerp(colour, targetCol, p));
        end)
        if callback then
            callback()
        end
    end);
end

function PDUI_Node:Flash(target, callback)
    target = target or tweak_data.screen_colours.important_1;
    self:Animate(function(o)
        local font_size = o:font_size();
        local colour = o:color();
        over(0.14, function(p)
            o:set_color(math.lerp(colour, target, p));
            o:set_font_size(font_size + 1 * (1 - p));
            o:set_rotation(math.sin((1 - p) * 360) * 0.2);
            if o:rotation() == 0 then
                o:set_rotation(0.01);
            end
        end)
        wait(0.01);
        over(0.14, function(p)
            o:set_color(math.lerp(target, colour, p))
            o:set_font_size(font_size + 1 * (1 - p))
            o:set_rotation(math.sin((1 - p) * 360) * 0.2)
            if o:rotation() == 0 then
                o:set_rotation(0.01)
            end
        end)
        o:set_color(colour)
        o:set_font_size(font_size)
        o:set_rotation(360)
        if callback then
            callback()
        end
    end)
end

function PDUI_Node:TweenTo(x, y, duration, callback)
    self:Animate(function(o)
        local currX = o:x();
        local currY = o:y();
        over(duration, function(p)
            o:set_x(math.lerp(currX, x, p));
            o:set_y(math.lerp(currY, y, p));
        end)

        o:set_x(x);
        o:set_y(y);
        if callback then
            callback()
        end
    end)
end

PDUI_NodeGroup = {};
PDUI_NodeGroup.__index = PDUI_NodeGroup;

setmetatable(PDUI_NodeGroup, {
    call = function(cls, ...)
        return cls.new(...);
    end
});

function PDUI_NodeGroup.new()
    local self = setmetatable({}, PDUI_NodeGroup);
    self.nodes = {}
    return self;
end

function PDUI_NodeGroup:Add(node)
    table.insert(self.nodes, node);
end

function PDUI_NodeGroup:Remove(node)
    PDUtils:RemoveValue(self.nodes, node);
end

function PDUI_NodeGroup:Combine(other)
    local n = PDUI_NodeGroup.new();
    n:Merge(self);
    n:Merge(other);
    return n;
end

function PDUI_NodeGroup:Merge(other)
    for _,node in pairs(other.nodes) do
        self:Add(node);
    end
end

function PDUI_NodeGroup:Animate(animFunc)
    for _,e in pairs(self.nodes) do
        e:Animate(animFunc);
    end
end

function PDUI_NodeGroup:AnimateColour(targetCol, time)
    for _,e in pairs(self.nodes) do
        e:AnimateColour(targetCol, time);
    end
end

function PDUI_NodeGroup:Flash(target)
    for _,e in pairs(self.nodes) do
        e:Flash(target);
    end
end

function PDUI_NodeGroup:TweenTo(x, y, duration)
    for _,e in pairs(self.nodes) do
        e:TweenTo(x, y, duration);
    end
end