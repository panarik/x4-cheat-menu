-- Station module library dump. Log only.
-- MD sends each ware from get_ware_definition tags=tag.module, then StationModDone.

local ffi
local C
local ready = false
local cdef_done = false

local rows = {}
local field_err = {}

local function debug(msg)
  if DebugError then
    DebugError("[CM90] " .. tostring(msg))
  end
end

local function log_md(line)
  line = tostring(line or "")
  debug(line)
  if AddUITriggeredEvent then
    AddUITriggeredEvent("CM90StationMod", "log", line)
  end
end

local function note_fail(field, err)
  if field_err[field] then
    return
  end
  field_err[field] = true
  log_md("HIGH Station mod field fail " .. tostring(field) .. " " .. tostring(err))
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

local function raw_dump(value)
  if value == nil then
    return "nil"
  end
  if type(value) ~= "table" then
    return tostring(value)
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

local function read_raw(fn, id, field)
  if id == "" or type(fn) ~= "function" then
    return nil, "missing"
  end
  local ok, value = pcall(fn, id, field)
  if not ok then
    note_fail(field, value)
    return nil, "ERR"
  end
  return value, raw_dump(value)
end

local function init_ffi()
  if ready then
    return true
  end
  local ok, lib = pcall(require, "ffi")
  if not ok or not lib then
    log_md("HIGH Station mod ffi fail require")
    return false
  end
  ffi = lib
  local cdef_ok, cdef_err = true, nil
  if not cdef_done then
    cdef_ok, cdef_err = pcall(function()
      ffi.cdef[[
        const char* GetMacroClass(const char* macroname);
      ]]
    end)
  end
  if not cdef_ok then
    log_md("HIGH Station mod ffi fail cdef " .. tostring(cdef_err))
    return false
  end
  cdef_done = true
  C = ffi.C
  local sym_ok, sym_err = pcall(function()
    return C.GetMacroClass
  end)
  if not sym_ok then
    log_md("HIGH Station mod ffi fail symbol " .. tostring(sym_err))
    return false
  end
  ready = true
  return true
end

local function macro_class(macro)
  if macro == "" then
    return ""
  end
  if not init_ffi() then
    return "noffi"
  end
  local ok, value = pcall(function()
    return ffi.string(C.GetMacroClass(macro))
  end)
  if not ok then
    note_fail("GetMacroClass", value)
    return "ERR"
  end
  if value == nil then
    return "nil"
  end
  return value
end

local function is_connection(macro)
  if macro == "" or type(IsMacroClass) ~= "function" then
    return "missing"
  end
  local ok, value = pcall(IsMacroClass, macro, "connectionmodule")
  if not ok then
    note_fail("IsMacroClass", value)
    return "ERR"
  end
  if value then
    return "1"
  end
  return "0"
end

local function on_mod(_, param)
  local text = payload_of(_, param)
  local ware, macro = string.match(text, "^([^|]*)|(.*)$")
  if not ware then
    ware = text
    macro = ""
  end
  macro = macro or ""
  local _, name = read_raw(GetWareData, ware, "name")
  local _, owners = read_raw(GetWareData, ware, "blueprintsowners")
  local _, ismodule = read_raw(GetWareData, ware, "ismodule")
  local _, isship = read_raw(GetWareData, ware, "isship")
  local _, isequipment = read_raw(GetWareData, ware, "isequipment")
  local race_raw = nil
  local race_text = "missing"
  local racename = "missing"
  local shortname = "missing"
  local tier = "missing"
  local size = "missing"
  local waregroup = "missing"
  local library = "missing"
  local showname = "missing"
  local showroom = "missing"
  local venture = "missing"
  local maker = "missing"
  if macro ~= "" then
    race_raw, race_text = read_raw(GetMacroData, macro, "makerraceid")
    _, racename = read_raw(GetMacroData, macro, "makerracename")
    _, maker = read_raw(GetMacroData, macro, "makerrace")
    _, shortname = read_raw(GetMacroData, macro, "shortname")
    _, tier = read_raw(GetMacroData, macro, "tier")
    _, size = read_raw(GetMacroData, macro, "size")
    _, waregroup = read_raw(GetMacroData, macro, "waregroup")
    _, library = read_raw(GetMacroData, macro, "infolibrary")
    _, showname = read_raw(GetMacroData, macro, "name")
    _, showroom = read_raw(GetMacroData, macro, "isshowroommodule")
    _, venture = read_raw(GetMacroData, macro, "isventuremodule")
  end
  rows[#rows + 1] = {
    library = library,
    race = race_raw,
    connection = is_connection(macro),
  }
  log_md("LOW Station mod ware=" .. ware
    .. " macro=" .. macro
    .. " name=" .. tostring(name)
    .. " shortname=" .. tostring(shortname)
    .. " class=" .. macro_class(macro)
    .. " connection=" .. rows[#rows].connection
    .. " infolibrary=" .. tostring(library)
    .. " size=" .. tostring(size)
    .. " tier=" .. tostring(tier)
    .. " waregroup=" .. tostring(waregroup)
    .. " makerrace=" .. tostring(maker)
    .. " makerraceid=" .. tostring(race_text)
    .. " makerracename=" .. tostring(racename)
    .. " blueprintsowners=" .. tostring(owners)
    .. " ismodule=" .. tostring(ismodule)
    .. " isship=" .. tostring(isship)
    .. " isequipment=" .. tostring(isequipment)
    .. " isshowroommodule=" .. tostring(showroom)
    .. " isventuremodule=" .. tostring(venture)
    .. " macroname=" .. tostring(showname))
end

local function bump(map, key)
  if key == nil or key == "" or key == "nil" or key == "missing" then
    key = "-"
  end
  map[key] = (map[key] or 0) + 1
end

local function join_counts(map)
  local keys = {}
  for k in pairs(map) do
    keys[#keys + 1] = k
  end
  table.sort(keys)
  local parts = {}
  for i = 1, #keys do
    parts[#parts + 1] = keys[i] .. ":" .. tostring(map[keys[i]])
  end
  if #parts == 0 then
    return "-"
  end
  return table.concat(parts, ",")
end

local function race_keys(value)
  if type(value) ~= "table" then
    if value == nil or value == "" then
      return { "-" }
    end
    return { tostring(value) }
  end
  if #value == 0 then
    return { "-" }
  end
  local out = {}
  for i = 1, #value do
    out[#out + 1] = tostring(value[i])
  end
  return out
end

local function on_done()
  local libraries = {}
  local races = {}
  local connection = 0
  for i = 1, #rows do
    local row = rows[i]
    bump(libraries, row.library)
    local keys = race_keys(row.race)
    for k = 1, #keys do
      bump(races, keys[k])
    end
    if row.connection == "1" then
      connection = connection + 1
    end
  end
  log_md("HIGH Station mod done n=" .. tostring(#rows)
    .. " connection=" .. tostring(connection)
    .. " library=" .. join_counts(libraries)
    .. " race=" .. join_counts(races))
end

local function init()
  debug("HIGH Station mod lua init")
  if not RegisterEvent then
    debug("HIGH Station mod RegisterEvent missing")
    return
  end
  RegisterEvent("CheatMenu90.StationMod", on_mod)
  RegisterEvent("CheatMenu90.StationModDone", on_done)
  debug("HIGH Station mod lua ready")
end

if Register_OnLoad_Init then
  Register_OnLoad_Init(init, "cm90_station_modules")
else
  init()
end
