--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 21/06/2017
-- Time: 16:11
-- To change this template use File | Settings | File Templates.
--

PDUI_Builder = PDUI_Builder or class();

function PDUI_Builder:Panel(ws, dom, parentNode, data, depth, parentBounds)
    local rb = data['bounds'];
    local b = PDUtils:TransformBounds(rb, parentBounds);
    local w = ws;
    local element = w:panel({
        name = data['name'],
        layer = depth,
        x = b[1],
        y = b[2],
        w = b[3],
        h = b[4]
    });
    return PDUI_Node.new(dom, "panel", element, parentNode, rb);
end

function PDUI_Builder:Rect(ws, dom, parentNode, data, depth, parentBounds)
    local rb = data['bounds'];
    local b = PDUtils:TransformBounds(rb, parentBounds);
    local alpha = data['alpha'] or 100;
    local element = parentNode:GetWidget():rect({
        color = PDUI:GetColour(data['colour']),
        alpha = alpha / 100,
        layer = depth,
        x = b[1],
        y = b[2],
        w = b[3],
        h = b[4]
    });
    return PDUI_Node.new(dom, "rect", element, parentNode, rb)
end


function PDUI_Builder:Label(ws, dom, parentNode, data, depth, parentBounds)
    local rb = data['bounds'];
    local b = PDUtils:TransformBounds(rb, parentBounds);
    local font = PDUI:GetFont(data['font']);
    local size = data['size'] or 12;
    local alpha = data['alpha'] or 100;
    local align = data['halign'] or nil;
    local vert = data['valign'] or nil;

    local colour = PDUI:GetColour(data['colour']):with_alpha(alpha / 100);
    local element = parentNode:GetWidget():text{
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
    };
    return PDUI_Node.new(dom, "label", element, parentNode, rb);
end

function PDUI_Builder:Bitmap(ws, dom, parentNode, data, depth, parentBounds)
    local rb = data['bounds'];
    local b = PDUtils:TransformBounds(rb, parentBounds);
    local alpha = data['alpha'] or 100;
    local colour = PDUI:GetColour(data['colour']);
    local texture_rect = data['region'] or nil;
    local element = parentNode:GetWidget():bitmap{
        texture = data['texture'],
        render_template = data['template'] or nil,
        blend_mode = data['blend'] or nil,
        wrap_mode = data['wrap'] or nil,
        color = colour,
        layer = depth,
        alpha = alpha / 100,
        texture_rect = texture_rect,
        x = b[1],
        y = b[2],
        w = b[3],
        h = b[4]
    };
    return PDUI_Node.new(dom, "bitmap", element, parentNode, rb)
end

function PDUI_Builder:Bitmap_9(ws, dom, parentNode, data, depth, parentBounds)
    local rb = data['bounds'];
    local b = PDUtils:TransformBounds(rb, parentBounds);
    local alpha = data['alpha'] or 100;
    local colour = PDUI:GetColour(data['colour']);
    local rect = data['region'] or {0, 0, b[3], b[4]};
    -- [Top, Bottom, Left, Right]
    local i = data['insets']

    local regions = {};
    regions[1] = {
        rb = {rb[1], rb[2], i[3], i[1]},
        bounds = {b[1], b[2], i[3], i[1]},
        region = {rect[1], rect[2], i[3], i[1]}
    };
    regions[2] = {
        rb = {rb[1] + i[3], rb[2], rb[3] - (i[3] + i[4]), i[1]},
        bounds = {b[1] + i[3], b[2], b[3] - (i[3] + i[4]), i[1]},
        region = {rect[1] + i[3], rect[2], rect[3] - (i[3] + i[4]), i[1]}
    };
    regions[3] = {
        rb = {rb[1] + (rb[3] - i[4]), rb[2], i[4], i[1]},
        bounds = {b[1] + (b[3] - i[4]), b[2], i[4], i[1]},
        region = {rect[1] + (rect[3] - i[4]), rect[2], i[4], i[1]}
    };

    regions[4] = {
        rb = {rb[1], rb[2] + i[1], i[3], rb[4] - (i[1] + i[2])},
        bounds = {b[1], b[2] + i[1], i[3], b[4] - (i[1] + i[2])},
        region = {rect[1], rect[2] + i[2], i[3], rect[4] - (i[1] + i[2])}
    };
    regions[5] = {
        rb = {rb[1] + i[3], rb[2] + i[1], rb[3] - (i[3] + i[4]), rb[4] - (i[1] + i[2])},
        bounds = {b[1] + i[3], b[2] + i[1], b[3] - (i[3] + i[4]), b[4] - (i[1] + i[2])},
        region = {rect[1] + i[3], rect[2] + i[1], rect[3] - (i[3] + i[4]), rect[4] - (i[1] + i[2])}
    };
    regions[6] = {
        rb = {rb[1] + (rb[3] - i[4]), rb[2] + i[1], i[4], rb[4] - (i[1] + i[2])},
        bounds = {b[1] + (b[3] - i[4]), b[2] + i[1], i[4], b[4] - (i[1] + i[2])},
        region = {rect[1] + (rect[3] - i[4]), rect[2] + i[1], i[4], rect[4] - (i[1] + i[2])}
    };

    regions[7] = {
        rb = {rb[1], rb[2] + (rb[4] - i[2]), i[3], i[2]},
        bounds = {b[1], b[2] + (b[4] - i[2]), i[3], i[2]},
        region = {rect[1], rect[2] + (rect[4] - i[2]), i[3], i[2]}
    };
    regions[8] = {
        rb = {rb[1] + i[3], rb[2] + (rb[4] - i[2]), rb[3] - (i[3] + i[4]), i[2]},
        bounds = {b[1] + i[3], b[2] + (b[4] - i[2]), b[3] - (i[3] + i[4]), i[2]},
        region = {rect[1] + i[3], rect[2] + (rect[4] - i[2]), rect[3] - (i[3] + i[4]), i[2]}
    };
    regions[9] = {
        rb = {rb[1] + (rb[3] - i[4]), rb[2] + (rb[4] - i[2]), i[3], i[2]},
        bounds = {b[1] + (b[3] - i[4]), b[2] + (b[4] - i[2]), i[3], i[2]},
        region = {rect[1] + (rect[3] - i[4]), rect[2] + (rect[4] - i[2]), i[3], i[2]}
    };

    local panel = ws:panel({
        layer = depth,
        x = b[1],
        y = b[2],
        w = b[3],
        h = b[4]
    });
    local panelNode = PDUI_Node.new(dom, "panel", panel, parentNode, rb);

    for _,reg in pairs(regions) do
        local bitmap = panel:bitmap{
            texture = data['texture'],
            render_template = data['template'] or nil,
            blend_mode = data['blend'] or nil,
            wrap_mode = data['wrap'] or nil,
            color = colour,
            layer = depth,
            alpha = alpha / 100,
            texture_rect = reg.region,
            x = reg.bounds[1],
            y = reg.bounds[2],
            w = reg.bounds[3],
            h = reg.bounds[4]
        };
        PDUI_Node.new(dom, "bitmap", bitmap, panelNode, reg.rb);
    end

    return panelNode;
end