-- Ship list bridge. Reads makerraceid and blueprintsowners on each ship, then asks CM90Catalog.
-- The bucket rule itself is ui/cm90_catalog_rule.lua (no game calls).

local ffi
local C

local ships = {}

local function debug(msg)
  if DebugError then
    DebugError("[CM90] " .. tostring(msg))
  end
end

local function payload_of(event, param)
  if type(param) == "string" then
    return param
  end
  if type(event) == "string" then
    return event
  end
  if type(event) == "table" then
    local p = event.param3 or event.param
    if type(p) == "string" then
      return p
    end
  end
  return ""
end

local function notify(control, payload)
  if AddUITriggeredEvent then
    AddUITriggeredEvent("CM90Catalog", control, tostring(payload or ""))
  end
end

local function log_md(line)
  debug(line)
  notify("log", line)
end

local function cdef_block(block)
  if not ffi then
    return
  end
  pcall(function()
    ffi.cdef(block)
  end)
end

local function init_ffi()
  if C then
    return true
  end
  local ok
  ok, ffi = pcall(require, "ffi")
  if not ok or not ffi then
    log_md("HIGH Cat ffi unavailable")
    return false
  end
  cdef_block[[
    typedef struct {
      const char* id;
      const char* name;
      const char* shortname;
      const char* description;
      const char* icon;
    } RaceInfo;
  ]]
  cdef_block[[
    uint32_t GetNumAllRaces(void);
    uint32_t GetAllRaces(RaceInfo* result, uint32_t resultlen);
  ]]
  cdef_block[[
    typedef struct {
      const char* factionID;
      const char* factionName;
      const char* factionIcon;
    } FactionDetails;
    FactionDetails GetFactionDetails(const char* factionid);
  ]]
  C = ffi.C
  return true
end

local function reset()
  ships = {}
end

local function on_ship(_, param)
  local rule = _G.CM90Catalog
  if not rule then
    log_md("HIGH Cat rule missing")
    return
  end
  local lines = rule.fields_of(payload_of(_, param))
  local wid = lines[1] or ""
  local macro = lines[2] or ""
  if wid == "" or macro == "" then
    return
  end
  ships[#ships + 1] = { ware = wid, macro = macro }
end

local function race_labels()
  local map = {}
  if not init_ffi() or not C.GetNumAllRaces then
    log_md("HIGH Cat races ffi missing")
    return map
  end
  local ok, n = pcall(function()
    return tonumber(C.GetNumAllRaces()) or 0
  end)
  if not ok or not n or n < 1 then
    log_md("HIGH Cat races count fail")
    return map
  end
  local got = 0
  local okbuf, buf = pcall(ffi.new, "RaceInfo[?]", n)
  if not okbuf or not buf then
    log_md("HIGH Cat races buffer fail")
    return map
  end
  ok, got = pcall(function()
    return tonumber(C.GetAllRaces(buf, n)) or 0
  end)
  if not ok then
    log_md("HIGH Cat races read fail")
    return map
  end
  for i = 0, got - 1 do
    local id = ffi.string(buf[i].id or "")
    local name = ffi.string(buf[i].name or "")
    if id ~= "" then
      if name == "" then
        name = id
      end
      map[id] = name
    end
  end
  log_md("HIGH Cat races listed n=" .. tostring(got))
  return map
end

local function raw_dump(value)
  if value == nil then
    return "nil"
  end
  if type(value) ~= "table" then
    return type(value) .. ":" .. tostring(value)
  end
  local parts = {}
  for i = 1, #value do
    parts[#parts + 1] = tostring(value[i])
  end
  if #parts == 0 then
    for k, v in pairs(value) do
      parts[#parts + 1] = tostring(k) .. "=" .. tostring(v)
    end
  end
  return "table[" .. table.concat(parts, ",") .. "]"
end

local function read_race(macro)
  local rule = _G.CM90Catalog
  if type(GetMacroData) ~= "function" or not rule then
    return nil, "missing"
  end
  local ok, value = pcall(GetMacroData, macro, "makerraceid")
  if not ok then
    return nil, "error:" .. tostring(value)
  end
  return rule.parse_maker_race(value), raw_dump(value)
end

local function ware_name(ware)
  if type(GetWareData) ~= "function" then
    return ""
  end
  local ok, value = pcall(GetWareData, ware, "name")
  if not ok or value == nil then
    return ""
  end
  return tostring(value)
end

local function faction_label(id)
  if not init_ffi() or not C.GetFactionDetails then
    return id
  end
  local ok, details = pcall(C.GetFactionDetails, id)
  if not ok or not details then
    return id
  end
  local okname, name = pcall(ffi.string, details.factionName)
  if not okname or name == nil or name == "" then
    return id
  end
  return name
end

local function read_owner(ware)
  local rule = _G.CM90Catalog
  if type(GetWareData) ~= "function" or not rule then
    return nil, "missing"
  end
  local ok, value = pcall(GetWareData, ware, "blueprintsowners")
  if not ok then
    return nil, "error:" .. tostring(value)
  end
  return rule.parse_owner(value), raw_dump(value)
end

local function on_build()
  local rule = _G.CM90Catalog
  if not rule then
    log_md("HIGH Cat rule missing")
    notify("done", "0")
    return
  end
  local labels = race_labels()
  if type(GetMacroData) ~= "function" then
    log_md("HIGH Cat GetMacroData missing, race step skipped")
  end
  if type(GetWareData) ~= "function" then
    log_md("HIGH Cat GetWareData missing, faction step skipped")
  end

  local races = {}
  local race_raw = {}
  local seen = {}
  local owners = {}
  for i = 1, #ships do
    local row = ships[i]
    if not seen[row.macro] then
      seen[row.macro] = true
      local parsed, raw = read_race(row.macro)
      races[row.macro] = parsed
      race_raw[row.macro] = raw
    end
    local race = races[row.macro]
    local oid, owner_raw = read_owner(row.ware)
    if (not race or race == "") and oid then
      owners[row.ware] = { id = oid, name = faction_label(oid) }
    end
    local owner = owners[row.ware]
    local key, label, src = rule.bucket_of(race, labels, owner, nil)
    log_md("LOW Cat raw ware=" .. row.ware
      .. " name=" .. ware_name(row.ware)
      .. " macro=" .. row.macro
      .. " makerraceid=" .. tostring(race_raw[row.macro])
      .. " blueprintsowners=" .. tostring(owner_raw))
    log_md("MID Cat classify ware=" .. row.ware
      .. " race=" .. tostring(race or "")
      .. " owner=" .. tostring(oid or "")
      .. " src=" .. src
      .. " key=" .. key
      .. " label=" .. label)
  end
  local grouped = rule.group_ships(ships, races, labels, owners, nil)

  log_md("HIGH Cat group race=" .. tostring(grouped.n_race)
    .. " faction=" .. tostring(grouped.n_faction)
    .. " other=" .. tostring(grouped.n_other)
    .. " buckets=" .. tostring(#grouped.order)
    .. " ships=" .. tostring(#ships))

  for i = 1, #grouped.order do
    local g = grouped.groups[grouped.order[i]]
    notify("bucket_src", g.src)
    notify("bucket_key", g.key)
    notify("bucket_label", g.label)
    for w = 1, #g.wares do
      notify("ware", g.wares[w])
    end
    log_md("HIGH Cat group src=" .. g.src
      .. " key=" .. g.key
      .. " label=" .. g.label
      .. " n=" .. tostring(#g.wares))
  end
  notify("done", tostring(#ships))
end

local function init()
  debug("HIGH Cat lua init")
  if not RegisterEvent then
    debug("HIGH Cat RegisterEvent missing")
    return
  end
  RegisterEvent("CheatMenu90.CatReset", function()
    reset()
    log_md("HIGH Cat lua reset")
  end)
  RegisterEvent("CheatMenu90.CatShip", on_ship)
  RegisterEvent("CheatMenu90.CatBuild", function()
    on_build()
  end)
  debug("HIGH Cat lua ready")
end

if Register_OnLoad_Init then
  Register_OnLoad_Init(init, "cm90_catalog")
else
  init()
end
