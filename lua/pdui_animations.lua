--
-- Created by IntelliJ IDEA.
-- User: Guy
-- Date: 18/06/2017
-- Time: 22:37
-- To change this template use File | Settings | File Templates.
--

PDUI_Animations = PDUI_Animations or class();

PDUI_Animations.animations = PDUI_Animations.animations or {};
PDUI_Animations.runningAnimations = PDUI_Animations.runningAnimations or {};

function PDUI_Animations:Init()
    log("Animations initialized");
    self:AddAnimationType("marquee", function(element, args, dt)
        args.x = element:x()
        args.t = 0
        local speed = args['speed'] or 90
        args.t = args.t + dt
        args.x = args.x - speed * dt
        element:set_x(args.x)
        if 0 > element:right() then
            element:set_x(element:parent():w())
            args.x = element:x()
        end
    end)

    self:AddAnimationType("marquee-bounce", function(element, args, dt)
        args.x = element:x()
        args.t = 0
        args.speed = args.speed or 90

        if args.x < args.left and args.speed > 0 then
            args.speed = -args.speed;
        end

        if element:right() > args.right and args.speed < 0 then
            args.speed = -args.speed;
        end

        args.t = args.t + dt
        args.x = args.x - args.speed * dt
        element:set_x(args.x)
        if 0 > element:right() then
            element:set_x(element:parent():w())
            args.x = element:x()
        end
    end)

end

function PDUI_Animations:RemoveScope(scope)
    self.runningAnimations[scope] = nil;
end

function PDUI_Animations:Update(t, dt)
    for scope,v in pairs(self.runningAnimations) do
        for _,anim in pairs(v) do
            anim.Update(anim.target, anim.args, dt);
        end
    end
end

function PDUI_Animations:AddAnimationType(type, func)
    log("Adding "..tostring(type).." animation");
    self.animations[tostring(type)] = func;
    log(json.encode(self.animations))
end

function PDUI_Animations:FindAndStartAnimations(scope, element, data)
    local animParent = data['animation'];
    if animParent then
        for _,anim in pairs(animParent) do
            local type = anim['type'];
            local animFunc = self.animations[tostring(type)];
            if animFunc then
                local animData = {
                    target = element,
                    args = anim,
                    Update = animFunc;
                };
                self.runningAnimations[scope] = self.runningAnimations[scope] or {};
                table.insert(self.runningAnimations[scope], animData);
            end
        end
    end
end
