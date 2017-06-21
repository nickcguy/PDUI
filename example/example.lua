--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 18/06/2017
-- Time: 19:43
-- To change this template use File | Settings | File Templates.
--

local labelNode;

local animToRFunc;
local animToGFunc;
local animToBFunc;

animToRFunc = function()
    labelNode:AnimateColour(Color(1, 0, 0), 5, animToGFunc);
end

animToGFunc = function()
    labelNode:AnimateColour(Color(0, 1, 0), 5, animToBFunc);
end

animToBFunc = function()
    labelNode:AnimateColour(Color(0, 0, 1), 5, animToRFunc);
end

if PDUI:Ready() then
    PDUtils:ShowHint("Loading example UI", 3);
    PDUI:LoadUI("example", PDUI:ModPath().."example/example.json");

    labelNode = PDUI:GetElement("example", "label1");
    local panelNode = PDUI:GetElement("example", "panel2");
    animToRFunc();
    panelNode:TweenTo(500, 500, 1, function()
        panelNode:TweenTo(100, 100, 1);
    end)

    PDUI.dom:Log(">")

else
    PDUtils:ShowHint("PDUI is not ready", 3);
end