playtime = {}

local current = {}

local storage = minetest.get_mod_storage()

function playtime.get_current_playtime(name)
  if current[name] then
    return os.time() - current[name]
  else return 0
  end
end

--  Function to get playtime
function playtime.get_total_playtime(name)
  return storage:get_int(name) + playtime.get_current_playtime(name)
end

function playtime.remove_playtime(name)
  storage:set_string(name, "")
end

minetest.register_on_leaveplayer(function(player)
  local name = player:get_player_name()
  storage:set_int(name, storage:get_int(name) + playtime.get_current_playtime(name))
  current[name] = nil
end)

minetest.register_on_joinplayer(function(player)
  local name = player:get_player_name()
  current[name] = os.time()
end)

local function SecondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return hours..":"..mins..":"..secs
  end
end

minetest.register_chatcommand("playtime", {
  params = "<player_name>",
  description = "Use it to get your own playtime!",
  func = function(name, player_name)
    if player_name == nil then
      player_name = name
    end
    if player_name == '' and minetest.is_singleplayer() then
      player_name = 'singleplayer'
    end
    if (minetest.player_exists(player_name) ~= true) then
      return  true,'player "'..player_name..'" does not excist.'
    end
    minetest.chat_send_player(name, 'Play Time For '.. player_name)
    minetest.chat_send_player(name, "Total: "..SecondsToClock(playtime.get_total_playtime(player_name)).." Current: "..SecondsToClock(playtime.get_current_playtime(player_name)))
  end,
})
