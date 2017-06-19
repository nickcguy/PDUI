if not PDUtils then return end;
if not PDUI_Animations then return end;
if not PDUI_Bindings then return end;

PDUI = PDUI or class();

PDUI.workspace = nil;
PDUI.modpath = nil;
PDUI.typeBuilders = {};
PDUI.containerTypes = {};
PDUI.fonts = {};
PDUI.colours = {};
PDUI.variables = {};
--- Structured list containing all loaded elements
-- [id] = {id, path, data, elements}
PDUI.loaded = {};
PDUI.named = {};

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
    self:RegisterTypeBuilder("panel", function(ws, parent, data, depth, parentBounds)
        local b = PDUtils:TransformBounds(data['bounds'], parentBounds);
        return ws:panel({
            name = data['name'],
            layer = depth,
            x = b[1],
            y = b[2],
            w = b[3],
            h = b[4]
        }), b;
    end, true);

    self:RegisterTypeBuilder("rect", function(ws, parent, data, depth, parentBounds)
        local b = PDUtils:TransformBounds(data['bounds'], parentBounds);
        local alpha = data['alpha'] or 100;
        return parent:rect({
            color = PDUI:GetColour(data['colour']),
            alpha = alpha / 100,
            layer = depth,
            x = b[1],
            y = b[2],
            w = b[3],
            h = b[4]
        }), b;
    end, false);

    self:RegisterTypeBuilder("label", function(ws, parent, data, depth, parentBounds)
        local b = PDUtils:TransformBounds(data['bounds'], parentBounds);
        local font = self:GetFont(data['font']);
        local size = data['size'] or 12;
        local alpha = data['alpha'] or 100;
        local align = data['halign'] or nil;
        local vert = data['valign'] or nil;
        local colour = PDUI:GetColour(data['colour']):with_alpha(alpha / 100);
        return parent:text{
            text = data['text'],
            font = font,
            font_size = size,
            color = colour,
            layer = depth,
            align = align,
            vertical = vert,
            x = b[1],
            y = b[2],
            w = b[3] or nil,
            h = b[4] or nil
        }, b;
    end, false);

    self:RegisterTypeBuilder("bitmap", function(ws, parent, data, depth, parentBounds)
        local b = PDUtils:TransformBounds(data['bounds'], parentBounds);
        local alpha = data['alpha'] or 100;
        local colour = PDUI:GetColour(data['colour']);
        local texture_rect = data['region   '] or nil;
        return parent:bitmap{
            texture = data['texture'],
            render_template = data['template'] or nil,
            blend_mode = data['blend'] or nil,
            wrap_mode = data['wrap_mode'] or nil,
            color = colour,
            layer = depth,
            alpha = alpha / 100,
            texture_rect = texture_rect,
            x = b[1],
            y = b[2],
            w = b[3],
            h = b[4]
        }, b;
    end, false);

end

function PDUI:Init()
    self.modpath = "mods/PDUI/";
    self.workspace = managers.gui_data:create_fullscreen_workspace();
    self:RegisterDefaultBuilders();

    PDUI_Bindings:Init();
    PDUI_Animations:Init();

    if Hooks then
        Hooks:Add("GameSetupUpdate", "OverlordGameSetupUpdate", function(t, dt)
            if Utils:IsInHeist() then
                PDUI_Bindings:Update(t, dt);
                PDUI_Animations:Update(t, dt);
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
    PDUI_Bindings:UnloadScope(name);
    PDUI_Animations:RemoveScope(name);
end

function PDUI:GetElement(scope, name)
    if self:HasElement(scope, name) then
        return self.named[scope][name];
    end
    return nil;
end

function PDUI:LoadUI(name, filepath)
    if self:UILoaded(name) then
        self:RemoveUI(name);
    end
    local contents = PDUtils:ReadFile(filepath);
    local data = json.decode(contents);
    self.loaded[name] = {
        id = name,
        filepath = filepath,
        data = data,
        elements = {}
    };
    self.named[name] = {};
    local meta = data['meta'];
    if meta then
        self:ProcessMetadata(meta);
    end
    local structure = data['structure'];
    if structure then
        self:BuildChildren(name, self.workspace, structure, 1, {0,0,0,0});
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

function PDUI:BuildChildren(name, parent, data, depth, parentBounds)
    for _,v in pairs(data) do
        self:BuildElement(name, parent, v, depth + 1, parentBounds);
    end
end

function PDUI:BuildElement(name, parent, data, depth, parentBounds)
    local type = data['type'];
    local func = self:GetTypeBuilder(type);
    local p = parent;
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
        log(tostring(json.encode(self.variables)))
        p, bounds = func(self.workspace, parent, d, depth, parentBounds);
        PDUI_Animations:FindAndStartAnimations(name, p, d);
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
            self:BuildChildren(name, p, children, depth, bounds);
        end
    end
end

PDUI:Init()