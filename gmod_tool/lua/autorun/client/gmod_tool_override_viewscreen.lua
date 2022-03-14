local matScreen = Material( "models/weapons/v_toolgun/screen" )
local txBackground = surface.GetTextureID( "models/weapons/v_toolgun/screen_bg" )
local Background = surface.GetTextureID( "debug/debugdrawflat" )

local TEX_SIZE = 256

local RTTexture = GetRenderTarget( "GModToolgunScreen", TEX_SIZE, TEX_SIZE )

surface.CreateFont( "GModToolScreen", {
    font    = "Helvetica",
    size    = 60,
    weight  = 900
} )

surface.CreateFont( "GModToolScreenHelping", {
    font    = "Helvetica",
    size    = 30,
    weight  = 900
} )

surface.CreateFont( "GModToolScreenInfos", {
    font    = "Helvetica",
    size    = 30,
    weight  = 900
} )


local function DrawScrollingText( text, y, texwide )

    local w, h = surface.GetTextSize( text )
    w = w + 64

    y = y - h / 2

    local x = RealTime() * 250 % w * -1

    while ( x < texwide ) do

        surface.SetTextColor( 0, 0, 0, 255 )
        surface.SetTextPos( x + 3, y + 3 )
        surface.DrawText( text )

        surface.SetTextColor( 255, 255, 255, 255 )
        surface.SetTextPos( x, y )
        surface.DrawText( text )

        x = x + w
    end
end

hook.Add("Initialize", "gmod_tool_override_viewscreen", function()
    local SWEP = weapons.GetStored("gmod_tool")

    SWEP.PrintWeaponInfo = weapons.Get("weapon_base").PrintWeaponInfo 
    SWEP.DrawWeaponInfoBox = true
    SWEP.Author = "E2 Ghibli"
    SWEP.Instructions = "Better screen for more information of the tool you use"


    function SWEP:RenderScreen()

        matScreen:SetTexture( "$basetexture", RTTexture )

        render.PushRenderTarget( RTTexture )
        cam.Start2D()

            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.SetTexture( txBackground )
            surface.DrawTexturedRect( 0, 0, TEX_SIZE, TEX_SIZE )

            if ( self:GetToolObject() && self:GetToolObject().DrawToolScreen ) then

                self:GetToolObject():DrawToolScreen( TEX_SIZE, TEX_SIZE )
            else

                OverrideToolScreen(TEX_SIZE,TEX_SIZE)
            end

        cam.End2D()
        render.PopRenderTarget()
    end


    function contrast(color)

        local HSV_H, HSV_S, HSV_L = ColorToHSV(color)
        local Value = 1-HSV_L
        
        HSV_L = Value
        local OUT = HSVToColor(0, 0, HSV_L)    
        return OUT
    end


    local function get_active_tool(ply, tool)
        -- find toolgun
        local activeWep = ply:GetActiveWeapon()
        if not IsValid(activeWep) or activeWep:GetClass() ~= "gmod_tool" or activeWep.Mode ~= tool then return end

        return activeWep:GetToolObject(tool)
    end


    function display_infos(para1,para1_value, para2,para2_value, para3,para3_value, para4,para4_value)

        if para1 then
            --Info1
            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(10,90)
            surface.DrawText(para1)

            local w, h = surface.GetTextSize( para1 )

            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(15+w,90)
            surface.DrawText(para1_value)
        end

        if para2 then
            --Info2
            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(10,130)
            surface.DrawText(para2)

            local w, h = surface.GetTextSize( para2 )

            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(15+w,130)
            surface.DrawText(para2_value)
        end

        if para3 then
            --Info3
            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(10,170)
            surface.DrawText(para3)

            local w, h = surface.GetTextSize( para3 )

            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(15+w,170)
            surface.DrawText(para3_value)
        end

        if type(para4) == "table" then
            --Info4
            local colorPos = 210
            local Color = para4
            local colorStr = "R:".. Color.r .. " G:" .. Color.g .. " B:" .. Color.b
            local w, h = surface.GetTextSize(colorStr)
            surface.SetDrawColor(Color)
            surface.DrawRect( 10, colorPos*1.02, w+10, h )

            surface.SetTextColor(contrast(Color))
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(15,colorPos)
            surface.DrawText(colorStr)
        else
            --Info4
            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(10,210)
            surface.DrawText(para4)

            local w, h = surface.GetTextSize( para4 )

            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(15+w,210)
            surface.DrawText(para4_value)
        end
    end


    function OverrideToolScreen(w,h)

        local mode = GetConVarString( "gmod_toolmode" )

        local center = TEX_SIZE/2

        local ply = LocalPlayer()

        local trace  = ply:GetEyeTrace()
        local ent = trace.Entity

        surface.SetTextColor(255,255,255,255)
        surface.SetTexture(Background)
        surface.DrawTexturedRectRotated(w/2,h/2,w*2,h*2,CurTime()*10)
        surface.SetDrawColor(40,40,40,255)
        surface.DrawRect(0,0,w,h)

        surface.SetDrawColor(60,60,60,255)
        surface.DrawRect(0,0,w,70)
        surface.SetFont( "GModToolScreen" )
        DrawScrollingText( "#tool." .. mode .. ".name", 35, TEX_SIZE )

        local toolInfo = {
            [1] = "#tool.",
            [2] = "#tool." .. mode .. "."
        }

        local switch = {
            ["elastic"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                local constant = tool:GetClientInfo("constant")
                local damping = tool:GetClientInfo("damping")
                local rdamping = tool:GetClientInfo("rdamping")
                --local material = tool:GetClientInfo("material")
                local width = tool:GetClientInfo("width")
                --local stretch_only = tool:GetClientInfo("stretch_only")

                display_infos(toolInfo[2] .. "constant",constant, toolInfo[2] .. "damping",damping, toolInfo[2] .. "rdamping",rdamping, toolInfo[2] .. "width",width)
            end,

            ["hydraulic"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                --local group = tool:GetClientInfo("group")
                local width = tool:GetClientInfo("width")
                local addlength = tool:GetClientInfo("addlength")
                --local fixed = tool:GetClientInfo("fixed")
                local speed = tool:GetClientInfo("speed")
                --local toggle = tool:GetClientInfo("toggle")
                local material = tool:GetClientInfo("material")

                material = string.sub(table.remove(string.Explode("/", material or "?")), 1,-1)

                display_infos(toolInfo[2] .. "addlength",addlength, toolInfo[2] .. "speed",speed, toolInfo[2] .. "width",width, material,"")
            end,

            ["motor"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                local torque = tool:GetClientInfo("torque")
                local friction = tool:GetClientInfo("friction")
                --local nocollide = tool:GetClientInfo("nocollide")
                local forcetime = tool:GetClientInfo("forcetime")
                --local fwd = tool:GetClientInfo("fwd")
                --local bwd = tool:GetClientInfo("bwd")
                --local toggle = tool:GetClientInfo("toggle")
                local forcelimit = tool:GetClientInfo("forcelimit")

                display_infos(toolInfo[2] .. "torque",torque, toolInfo[1] .. "forcelimit",forcelimit, toolInfo[1] .. "hingefriction",friction, toolInfo[2] .. "forcetime",forcetime)
            end,

            ["muscle"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                --local group = tool:GetClientInfo("group")
                local width = tool:GetClientInfo("width")
                local addlength = tool:GetClientInfo("addlength")
                --local fixed = tool:GetClientInfo("fixed")
                local period = tool:GetClientInfo("period")
                local material = tool:GetClientInfo("material")
                --local starton = tool:GetClientInfo("starton")

                material = string.sub(table.remove(string.Explode("/", material or "?")), 1,-1)

                display_infos(toolInfo[2] .. "length",addlength, toolInfo[2] .. "period",period, toolInfo[2] .. "width",width, material,"")
            end,

            ["rope"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                local forcelimit = tool:GetClientInfo("forcelimit")
                local addlength = tool:GetClientInfo("addlength")
                local material = tool:GetClientInfo("material")
                local width = tool:GetClientInfo("width")
                --local rigid = tool:GetClientInfo("rigid")

                material = string.sub(table.remove(string.Explode("/", material or "?")), 1,-1)

                display_infos(toolInfo[1] .. "forcelimit",forcelimit, toolInfo[2] .. "addlength",addlength, toolInfo[2] .. "width",width, material,"")
            end,

            ["winch"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                local rope_material = tool:GetClientInfo("rope_material")
                local rope_width = tool:GetClientInfo("rope_width")
                local fwd_speed = tool:GetClientInfo("fwd_speed")
                local bwd_speed = tool:GetClientInfo("bwd_speed")
                --local fwd_group = tool:GetClientInfo("fwd_group")
                --local bwd_group = tool:GetClientInfo("bwd_group")

                rope_material = string.sub(table.remove(string.Explode("/", rope_material or "?")), 1,-1)

                display_infos(toolInfo[2] .. "fspeed",fwd_speed, toolInfo[2] .. "bspeed",bwd_speed, toolInfo[2] .. "width",rope_width, rope_material,"")
            end,

            ["thruster"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                local force = tool:GetClientInfo("force")
                local model = tool:GetClientInfo("model")
                --local keygroup = tool:GetClientInfo("keygroup")
                --local keygroup_back = tool:GetClientInfo("keygroup_back")
                --local toggle = tool:GetClientInfo("toggle")
                --local collision = tool:GetClientInfo("collision")
                local effect = tool:GetClientInfo("effect")
                --local damageable = tool:GetClientInfo("damageable")
                local soundname = tool:GetClientInfo("soundname")

                model = string.sub(table.remove(string.Explode("/", model or "?")), 1,-5)

                display_infos(toolInfo[2] .. "force",force, toolInfo[2] .. "effect",effect, toolInfo[2] .. "sound",soundname, toolInfo[1] .. "model",model)
            end,

            ["balloon"] = function()  
                local tool = get_active_tool(ply,mode)
                if not tool then return end 

                local ropelength = tool:GetClientInfo("ropelength")
                local force = tool:GetClientInfo("force")
                local r = tool:GetClientInfo("r")
                local g = tool:GetClientInfo("g")
                local b = tool:GetClientInfo("b")
                local Col = Color(r,g,b)
                local model = tool:GetClientInfo("model")

                display_infos(toolInfo[2] .. "ropelength",ropelength, toolInfo[2] .. "force",force, toolInfo[2] .. "model",model, Col)
            end,

            ["dynamite"] = function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                --local group = tool:GetClientInfo("group")
                local damage = tool:GetClientInfo("damage")
                local delay = tool:GetClientInfo("delay")
                local model = tool:GetClientInfo("model")
                --local remove = tool:GetClientInfo("remove")

                model = string.sub(table.remove(string.Explode("/", model or "?")), 1,-5)

                display_infos("nil","", toolInfo[2] .. "damage",damage, toolInfo[2] .. "delay",delay, toolInfo[2] .. "model",model)
            end,

            ["hoverball"] = function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                --local keyup = tool:GetClientInfo("keyup")
                --local keydn = tool:GetClientInfo("keydn")
                local speed = tool:GetClientInfo("speed")
                local resistance = tool:GetClientInfo("resistance")
                local strength = tool:GetClientInfo("strength")
                local model = tool:GetClientInfo("model")

                model = string.sub(table.remove(string.Explode("/", model or "?")), 1,-5)

                display_infos(toolInfo[2] .. "speed",speed, toolInfo[2] .. "resistance",resistance, toolInfo[2] .. "strength",strength, toolInfo[2] .. "model",model)
            end,

            ["button" ]= function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                local model = tool:GetClientInfo("model")
                --local keygroup = tool:GetClientInfo("keygroup")
                local description = tool:GetClientInfo("description")
                local toggle = tool:GetClientInfo("toggle")

                model = string.sub(table.remove(string.Explode("/", model or "?")), 1,-5)

                if description == "" then description = "nil" end

                display_infos("nil","", toolInfo[2] .. "text",description, toolInfo[2] .. "toggle",toggle, toolInfo[2] .. "model",model)
            end,

            ["lamp"] = function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                local r = tool:GetClientInfo("r")
                local g = tool:GetClientInfo("g")
                local b = tool:GetClientInfo("b")
                local Col = Color(r,g,b)
                local fov = tool:GetClientInfo("fov")
                local distance = tool:GetClientInfo("distance")
                local brightness = tool:GetClientInfo("brightness")
                --local texture = tool:GetClientInfo("texture")
                --local model = tool:GetClientInfo("model")
                --local toggle = tool:GetClientInfo("toggle")

                display_infos(toolInfo[2] .. "fov",fov, toolInfo[2] .. "distance",distance, toolInfo[2] .. "brightness",brightness, Col)
            end,

            ["light"] = function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                local ropelength = tool:GetClientInfo("ropelength")
                local r = tool:GetClientInfo("r")
                local g = tool:GetClientInfo("g")
                local b = tool:GetClientInfo("b")
                local Col = Color(r,g,b)
                local brightness = tool:GetClientInfo("brightness")
                local size = tool:GetClientInfo("size")

                display_infos(toolInfo[2] .. "ropelength",ropelength, toolInfo[2] .. "brightness",brightness, toolInfo[2] .. "size",size, Col)
            end,

            ["emitter"] = function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                --local key = tool:GetClientInfo("key")
                local delay = tool:GetClientInfo("delay")
                --local toggle = tool:GetClientInfo("toggle")
                --local starton = tool:GetClientInfo("starton")
                local effect = tool:GetClientInfo("effect")
                local scale = tool:GetClientInfo("scale")

                --local keygroup = language.GetPhrase( input.GetKeyName( key ) )

                display_infos(toolInfo[2] .. "delay",delay, toolInfo[2] .. "scale",scale, toolInfo[1] .. "effect",effect, "nil","")
            end,

            ["colour"] = function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                local r = tool:GetClientInfo("r")
                local g = tool:GetClientInfo("g")
                local b = tool:GetClientInfo("b")
                local a = tool:GetClientInfo("a")
                local Col = Color(r,g,b)

                local mode = tool:GetClientInfo("mode")
                local fx = tool:GetClientInfo("fx")

                local Modes = {
                    [0] = "#rendermode.normal",
                    [1] = "#rendermode.transcolor",
                    [2] = "#rendermode.transtexture",
                    [3] = "#rendermode.glow",
                    [4] = "#rendermode.transalpha",
                    [5] = "#rendermode.transadd",
                    [8] = "#rendermode.transalphaadd",
                    [9] = "#rendermode.worldglow"
                }

                local FX = {
                    [0] = "#renderfx.none",
                    [1] = "#renderfx.pulseslow",
                    [2] = "#renderfx.pulsefast",
                    [3] = "#renderfx.pulseslowwide",
                    [4] = "#renderfx.pulsefastwide",
                    [5] = "#renderfx.fadeslow",
                    [6] = "#renderfx.fadefast",
                    [7] = "#renderfx.solidslow",
                    [8] = "#renderfx.solidfast",
                    [9] = "#renderfx.strobeslow",
                    [10] = "#renderfx.strobefast",
                    [11] = "#renderfx.strobefaster",
                    [12] = "#renderfx.flickerslow",
                    [13] = "#renderfx.flickerfast",
                    [15] = "#renderfx.distort",
                    [16] = "#renderfx.hologram",
                    [24] = "#renderfx.pulsefastwider"
                }

                mode = Modes[tonumber(mode)]
                if mode == nil then mode = "nil" end

                fx = FX[tonumber(fx)]
                if fx == nil then fx = "nil" end

                display_infos(toolInfo[2] .. "mode",mode, toolInfo[2] .. "fx",fx, "nil","", Col)
            end,

            ["trails"] = function() 
                local tool = get_active_tool(ply,mode)
                if not tool then return end

                local r = tool:GetClientInfo("r")
                local g = tool:GetClientInfo("g")
                local b = tool:GetClientInfo("b")
                --local a = tool:GetClientInfo("a")
                local Col = Color(r,g,b)
                local length = tool:GetClientInfo("length")
                local startsize = tool:GetClientInfo("startsize")
                local endsize = tool:GetClientInfo("endsize")
                --local material = tool:GetClientInfo("material")

                display_infos(toolInfo[2] .. "length",length, toolInfo[2] .. "startsize",startsize, toolInfo[2] .. "endsize",endsize, Col)
            end,
        }


        local fSwitch = switch[mode] 
          
        if fSwitch then 
            local result = fSwitch()  
        else
            local Model, RGB, Col, Class, colorPos = "", "", color_white, "", 140

            if IsValid( ent ) then
                local EntModel = string.sub( table.remove( string.Explode( "/", ent:GetModel() or "nil" ) ), 1,-5)
                local EntIndex = " ["..ent:EntIndex().."]"

                if EntModel ~= "" then
                    Model = EntModel .. EntIndex
                else
                    Model = "nil" .. EntIndex
                end

                local max = 16
                if #Model > max then Model = string.sub( Model, 1 ,max ) .. "..." end

                Col = ent:GetColor()

                local colorStr = "R:" .. Col.r .. " G:" .. Col.g .. " B:" .. Col.b

                RGB = colorStr

                Class = ent:GetClass()
            else
                Model = "nil"
                Col = color_white
                RGB = "nil"
                Class = "nil"
            end
            --MODEL
            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(10,90)
            surface.DrawText(Model)

            --COLOR
            local w,h = surface.GetTextSize(RGB)
            surface.SetDrawColor( Col.r, Col.g, Col.b, 255 )
            surface.DrawRect( 10, colorPos*1.02, w+10, h )

            local contrastColor = contrast(Col)
            surface.SetTextColor(contrastColor.r, contrastColor.b, contrastColor.g)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(15,colorPos)
            surface.DrawText(RGB)

            --CLASS
            surface.SetTextColor(color_white)
            surface.SetFont( "GModToolScreenInfos" )
            surface.SetTextPos(10,190)
            surface.DrawText(Class)
        end
    end
end)

if GAMEMODE then
    hook.GetTable().Initialize.gmod_tool_override_viewscreen()
end