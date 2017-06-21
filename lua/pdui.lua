if not PDUtils then return end;
if not PDUI_Bindings then return end;


PDUI = PDUI or class();

PDUI.workspace = nil;
PDUI.modpath = "mods/PDUI/";
PDUI.typeBuilders = {};
PDUI.containerTypes = {};
PDUI.fonts = {};
PDUI.colours = {};
PDUI.variables = {};
--- Structured list containing all loaded elements
-- [id] = {id, path, data, elements}
PDUI.loaded = {};
PDUI.named = {};

--dofile(PDUI.modpath..'lua/dom/pdui_dom_require.lua')

dofile(PDUI.modpath..'lua/dom/pdui_node.lua')
dofile(PDUI.modpath..'lua/dom/pdui_dom.lua')
dofile(PDUI.modpath..'lua/pdui_builder.lua')


function PDUI:Ready()
    return self.workspace ~= nil;
end

--- Registers a type builder.
-- @param type The type to bind the builder to
-- @param func The builder function with the signature of (jsonData)
-- @return The UI element
function PDUI:RegisterTypeBuilder(type, func, isContainer)
    if self.typeBuilders[type] ~= nil then return end;
    self:RegisterTypeBuilderForce(type, func, isContainer);
end

--- Registers a type builder, potentially overwriting existing entries.
-- @param type The type to bind the builder to
-- @param func The builder function with the signature of (ws, parent, jsonData, layer, parentBounds) and returns the widget, and it's transformed bounds
-- @return The UI element
function PDUI:RegisterTypeBuilderForce(type, func, isContainer)
    isContainer = isContainer or false;
    self.typeBuilders[type] = func;
    self.containerTypes[type] = isContainer;
end

function PDUI:HasTypeBuilder(type)
    return self.typeBuilders[type] ~= nil;
end

function PDUI:GetTypeBuilder(type)
    return self.typeBuilders[type] or nil;
end

function PDUI:GetFont(font)
    return self.fonts[font] or font;
end

function PDUI:GetVariable(var)
    local v = self.variables[var];
    if v then
        if PDUtils:IsTable(v) then
            return PDUtils:DeepCopy(v);
        end
        return v;
    end
    return var;
end

function PDUI:IsContainer(type)
    return self.containerTypes[type] == true;
end

function PDUI:GetColour(colour)
    if type(colour) == "string" then
        return self.colours[colour] or colour;
    end
    return Color(colour[1]/255, colour[2]/255, colour[3]/255);
end

function PDUI:RegisterDefaultBuilders()
    self:RegisterTypeBuilder("panel", function(ws, dom, parentNode, data, depth, parentBounds)
        return PDUI_Builder:Panel(ws, dom, parentNode, data, depth, parentBounds);
    end, true);
    self:RegisterTypeBuilder("rect", function(ws, dom, parentNode, data, depth, parentBounds)
        return PDUI_Builder:Rect(ws, dom, parentNode, data, depth, parentBounds);
    end, false);
    self:RegisterTypeBuilder("label", function(ws, dom, parentNode, data, depth, parentBounds)
        return PDUI_Builder:Label(ws, dom, parentNode, data, depth, parentBounds);
    end, false);
    self:RegisterTypeBuilder("bitmap", function(ws, dom, parentNode, data, depth, parentBounds)
        return PDUI_Builder:Bitmap(ws, dom, parentNode, data, depth, parentBounds);
    end, false);
    self:RegisterTypeBuilder("bitmap.9", function(ws, dom, parentNode, data, depth, parentBounds)
        return PDUI_Builder:Bitmap_9(ws, dom, parentNode, data, depth, parentBounds);
    end, false);
end

function PDUI:Init()
    self.workspace = managers.gui_data:create_fullscreen_workspace();
    self:RegisterDefaultBuilders();
    self.dom = PDUI_DOM.new();

    PDUI_Bindings:Init();

    if Hooks then
        Hooks:Add("GameSetupUpdate", "OverlordGameSetupUpdate", function(t, dt)
            if Utils:IsInHeist() then
                PDUI_Bindings:Update(t, dt);
            end
        end)
    else
        log("Hook not bound");
    end

end

function PDUI:ModPath()
    return self.modpath;
end

function PDUI:UILoaded(name)
    return self.loaded[name] ~= nil;
end

function PDUI:HasElement(scope, name)
    if self:UILoaded(scope) then
        return self.named[scope][name] ~= nil;
    end
    return false;
end

function PDUI:RemoveUI(name)
    if self.loaded[name] then
        for _,v in pairs(self.loaded[name].elements) do
            if v.clear ~= nil then
                v:clear();
            end
        end
    end
    self.loaded[name] = nil;
    self.named[name] = nil;
    self.dom:RemoveScope(name);
    PDUI_Bindings:UnloadScope(name);
end

function PDUI:GetElement(scope, name)
    if self:HasElement(scope, name) then
        return self.named[scope][name];
    end
    return nil;
end

function PDUI:GetElements(scope, names)
    local nodeGroup = PDUI_NodeGroup.new();
    local e;
    for _,name in pairs(names) do
        e = self:GetElement(scope, name);
        if e then
            nodeGroup:Add(e);
        end
    end
    return nodeGroup;
end

function PDUI:LoadUI(scope, filepath)
    self:LoadSubUI(nil, scope, filepath);
end

function PDUI:LoadSubUI(parentNode, scope, filepath)
    if self:UILoaded(scope) then
        self:RemoveUI(scope);
    end
    local contents = PDUtils:ReadFile(filepath);
    local data = json.decode(contents);
    self.loaded[scope] = {
        id = scope,
        filepath = filepath,
        data = data,
        elements = {}
    };
    self.named[scope] = {};
    local meta = data['meta'];
    if meta then
        self:ProcessMetadata(meta);
    end
    local structure = data['structure'];
    if structure then
        self:BuildChildren(scope, self.dom, parentNode, structure, 1, {0,0,0,0});
    end
end

function PDUI:ProcessMetadata(metadata)
    local fonts = metadata['fonts'] or {};
    self.fonts = fonts;

    local colours = metadata['colours'] or metadata['colors'] or {};
    for k,v in pairs(colours) do
        self.colours[k] = self:GetColour(v);
    end

    local variables = metadata['variables'] or {};
    for k,v in pairs(variables) do
        if PDUtils:IsTable(v) and not PDUtils:IsArray(v) then
            self.variables[k] = PDUI_Bindings:ExtractValue(v);
        else
            self.variables[k] = v;
        end
    end
end

function PDUI:BuildChildren(name, dom, parentNode, data, depth, parentBounds)
    for _,v in pairs(data) do
        self:BuildElement(name, dom, parentNode, v, depth + 1, parentBounds);
    end
end

function PDUI:BuildElement(name, dom, parentNode, data, depth, parentBounds)
    local type = data['type'];
    local func = self:GetTypeBuilder(type);
    local p = parentNode;
    local bounds = parentBounds;
    if func then
        local preD, b = PDUI_Bindings:ResolveInitialBindings(name, data, type);
        local d = {};
        for k,v in pairs(preD) do
            if k ~= "children" then
                d[k] = self:GetVariable(v);
                if PDUtils:IsTable(v) then
                    for k2,v2 in pairs(v) do
                        d[k][k2] = self:GetVariable(v2);
                    end
                end
            end
        end
        p = func(self.workspace, dom, parentNode, d, depth, parentBounds);
        p.scope = name;
        bounds = p.bounds;
        for _,v in pairs(b) do
            v.element = p;
        end
        table.insert(self.loaded[name].elements, p);
        local eName = data['name']
        if eName ~= nil then
            self.named[name][eName] = p;
        end
    else
        log("[PDUI] Unrecognised element type: \""..tostring(type).."\"");
    end

    if self:IsContainer(type) then
        local children = data['children'] or false;
        if children then
            self:BuildChildren(name, dom, p, children, depth, bounds);
        end
    end
end

PDUI:Init()