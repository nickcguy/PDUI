--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 18/06/2017
-- Time: 19:43
-- To change this template use File | Settings | File Templates.
--

if PDUI:Ready() then
    PDUtils:ShowHint("Loading example UI", 3);
    PDUI:LoadUI("example", PDUI:ModPath().."example/example.json");
else
    PDUtils:ShowHint("PDUI is not ready", 3);
end