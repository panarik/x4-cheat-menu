-- Fleet distance counter. Options menus do not send onCloseElement.
-- This wraps the vanilla OptionsMenu close and tells MD when the cheat page is gone.

local MENU_ID = "cm90_menu"

local function menu_left(was, now)
  return was == MENU_ID and now ~= MENU_ID
end

local function note(msg)
  if DebugError then
    DebugError("[CM90] HIGH Fleet " .. tostring(msg))
  end
end

local function find_options()
  if type(Menus) ~= "table" then
    return nil
  end
  for i = 1, #Menus do
    local ego = Menus[i]
    if type(ego) == "table" and ego.name == "OptionsMenu" then
      return ego
    end
  end
  return nil
end

local function install()
  local menu = find_options()
  if not menu then
    return false
  end
  if menu.cm90_fleet_hook then
    return true
  end
  local original = menu.onCloseElement
  if type(original) ~= "function" then
    return false
  end
  menu.cm90_fleet_hook = true
  menu.onCloseElement = function(dueToClose, ...)
    local was = menu.currentOption
    local result = original(dueToClose, ...)
    if menu_left(was, menu.currentOption) and AddUITriggeredEvent then
      AddUITriggeredEvent("CM90Menu", "closed", tostring(dueToClose or ""))
    end
    return result
  end
  return true
end

local announced = false
local last_miss = nil

local function miss_reason()
  if type(Menus) ~= "table" then
    return "no Menus"
  end
  local menu = find_options()
  if not menu then
    return "no OptionsMenu n=" .. tostring(#Menus)
  end
  if menu.cm90_fleet_hook then
    return nil
  end
  if type(menu.onCloseElement) ~= "function" then
    return "no onCloseElement"
  end
  return nil
end

local function on_hook()
  if install() then
    if not announced then
      note("distance hook ready")
      announced = true
    end
    return
  end
  local why = miss_reason() or "unknown"
  if why ~= last_miss then
    last_miss = why
    note("distance hook miss " .. why)
  end
end

local function init()
  on_hook()
  if RegisterEvent then
    RegisterEvent("CheatMenu90.FleetHook", on_hook)
  end
end

_G.CM90FleetDistance = {
  menu_left = menu_left,
}

if Register_OnLoad_Init then
  Register_OnLoad_Init(init, "cm90_fleet_distance")
else
  init()
end
