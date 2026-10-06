---@diagnostic disable: lowercase-global, undefined-global
---@funkinScript

--[[
    Creator: RamenDominoes (https://gamebanana.com/members/2135195)
    Version: 3.3.2 (Compatible with psych 1.0 pre-release)

    Thanks for downloadin' this shit I love ya <3
    If you use this event please credit me, it would be very much appreciated!
]]--

local hudItems = {normal, health}
local orderCheck = {underNotes, overNotes}
local initialStrumY = 0
local hpOpacity -- say thank you to DotZZ for tellin' me about this :)

local fadeHUD = true
local fadeNotes = false
local moveNotes = true

function onCreatePost()
    luaDebugMode = true

    luaGraphic("topBar", 0, -1)
    luaGraphic("bottomBar", 0, screenHeight)

    if stringStartsWith(version, "0.7") or stringStartsWith(version, "1.") then
        hpOpacity = getPropertyFromClass("backend.ClientPrefs", "data.healthBarAlpha")
        hudItems.opaque = {"scoreTxt","timeBar","timeTxt"}
        hudItems.nonOpaque = {"healthBar","iconP1","iconP2"}
        orderCheck.underNotes = "uiGroup"
        orderCheck.overNotes = "uiGroup"
        if version == "0.7" or version == "0.7.1" or version == "0.7.1h" then -- 0.7.2 issues lol
            orderCheck.underNotes = "timeBar"
            orderCheck.overNotes = "scoreTxt"
        end
    else -- this will be anything below 0.7
        hpOpacity = getPropertyFromClass("ClientPrefs", "healthBarAlpha")
        hudItems.opaque = {"scoreTxt","timeBar","timeBarBG","timeTxt"}
        hudItems.nonOpaque = {"healthBarBG","healthBar","iconP1","iconP2"}
        orderCheck.underNotes = "timeBarBG"
        orderCheck.overNotes = "scoreTxt"
    end
end

function onCountdownStarted() -- cause of dialogue shit lol (thanks Oxhidoupsil for report)
    initialStrumY = getPropertyFromGroup("strumLineNotes", 0, "y")
end

function onEvent(eventName, value1, value2)
    if eventName == "Cinematics" then
        local barProperties = split(value1, ",") -- Thickness, Speed
        local cinematicType = tonumber(value2)

        doTweenY("moveTopBar", "topBar", (tonumber(barProperties[1]) * 0.5) - 1, tonumber(barProperties[2]), "quadOut")
        doTweenY("scaleTopBar", "topBar.scale", tonumber(barProperties[1]), tonumber(barProperties[2]), "quadOut")
        doTweenY("moveBottomBar", "bottomBar", screenHeight - (tonumber(barProperties[1]) * 0.5), tonumber(barProperties[2]), "quadOut")
        doTweenY("scaleBottomBar", "bottomBar.scale", tonumber(barProperties[1]), tonumber(barProperties[2]), "quadOut")

        if tonumber(barProperties[1]) > 0 then
            setObjectOrder("topBar", cinematicType == 2 and getObjectOrder(orderCheck.overNotes) + 1 or getObjectOrder(orderCheck.underNotes) - 2)
            setObjectOrder("bottomBar", cinematicType == 2 and getObjectOrder(orderCheck.overNotes) + 1 or getObjectOrder(orderCheck.underNotes) - 2)

            fadeHUD = cinematicType ~= 3
            fadeNotes = cinematicType == 4
            moveNotes = cinematicType ~= 5

            if fadeHUD then
                for i = 1, #hudItems.opaque do
                    doTweenAlpha("opaqueFade" .. i, hudItems.opaque[i], 0, tonumber(barProperties[2]), "quadOut")
                end

                for i = 1, #hudItems.nonOpaque do
                    doTweenAlpha("nonOpaqueFade" .. i, hudItems.nonOpaque[i], 0, tonumber(barProperties[2]), "quadOut")
                end
            end

            for i = 0, 7 do
                if fadeNotes then
                    noteTweenAlpha("noteFade" .. i, i, 0, tonumber(barProperties[2]), "quadOut")
                end

                if moveNotes then
                    noteTweenY("noteY" .. i, i, downscroll and (screenHeight - tonumber(barProperties[1])) - (getPropertyFromGroup("strumLineNotes", i, "height") + 45) or tonumber(barProperties[1]) + initialStrumY, tonumber(barProperties[2]), "quadOut")
                end
            end
        else
            fadeHUD = true
            fadeNotes = false
            moveNotes = true

            for i = 1, #hudItems.opaque do
                doTweenAlpha("opaqueFade"..i, hudItems.opaque[i], 1, tonumber(barProperties[2]), "quadOut")
            end

            for i = 1, #hudItems.nonOpaque do
                doTweenAlpha("nonOpaqueFade"..i, hudItems.nonOpaque[i], hpOpacity, tonumber(barProperties[2]), "quadOut")
            end

            for i = 0, 3 do
                noteTweenAlpha("noteFade"..i, i, middlescroll and 0.35 or 1, tonumber(barProperties[2]), "quadOut")
                noteTweenAlpha("noteFade"..i + 4, i + 4, 1, tonumber(barProperties[2]), "quadOut")

                noteTweenY("noteY"..i, i, initialStrumY, tonumber(barProperties[2]), "quadOut")
                noteTweenY("noteY"..i + 4, i + 4, initialStrumY, tonumber(barProperties[2]), "quadOut")
            end
        end
    end
end

function split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, tostring(match));
    end
    return result;
end

function luaGraphic(tag,x,y)
	makeLuaSprite(tag, nil, x, y)
	makeGraphic(tag, screenWidth, 1, "000000")
	setObjectCamera(tag, "HUD")
	addLuaSprite(tag)
end