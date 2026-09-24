-- Cheat Menu 9.0: loadout snapshot + compat log.
-- This pass is LOG ONLY. No SetUpgradeSlotMacro / no apply.

local LOG_ONLY = true

local C
local ffi
local job = { mode = "compat", loadoutid = "" }
local warepool = {}

local function debug(msg)
  if DebugError then
    DebugError("[CM90] " .. tostring(msg))
  end
end

local function ffi_str(p)
  if p == nil then
    return ""
  end
  local ok, s = pcall(function()
    return ffi.string(p)
  end)
  if ok and s then
    return s
  end
  return tostring(p)
end

local function ship_id(obj)
  if not obj then
    return nil
  end
  if ConvertIDTo64Bit then
    local ok, id = pcall(ConvertIDTo64Bit, obj)
    if ok and id and id ~= 0 then
      return id
    end
  end
  if type(obj) == "cdata" then
    return obj
  end
  return nil
end

local function ship_macro(obj)
  if GetComponentData then
    local ok, macro = pcall(GetComponentData, obj, "macro")
    if ok and macro and macro ~= "" then
      return macro
    end
  end
  return ""
end

local function notify_md(control, payload)
  if AddUITriggeredEvent then
    AddUITriggeredEvent("CM90Fit", control, payload)
  end
end

local function log_md(line)
  line = tostring(line or "")
  debug(line)
  notify_md("log", line)
end

local function init_ffi()
  if C then
    return true
  end
  local ok
  ok, ffi = pcall(require, "ffi")
  if not ok or not ffi then
    debug("HIGH Fit ffi unavailable")
    return false
  end
  pcall(function()
    ffi.cdef[[
      typedef uint64_t UniverseID;
      typedef struct {
        const char* id;
        const char* name;
        const char* iconid;
        bool deleteable;
      } UILoadoutInfo;
      typedef struct {
        const char* path;
        const char* group;
      } UpgradeGroup;
      typedef struct {
        const char* macro;
        const char* upgradetypename;
        size_t slot;
        bool optional;
      } UILoadoutMacroData;
      typedef struct {
        const char* macro;
        const char* path;
        const char* group;
        uint32_t count;
        bool optional;
      } UILoadoutGroupData;
      typedef struct {
        const char* macro;
        uint32_t amount;
        bool optional;
      } UILoadoutAmmoData;
      typedef struct {
        const char* ware;
      } UILoadoutSoftwareData;
      typedef struct {
        const char* macro;
        bool optional;
      } UILoadoutVirtualMacroData;
      typedef struct {
        const char* ware;
        const char* macro;
        int amount;
      } UIWareInfo;
      typedef struct {
        UILoadoutMacroData* weapons;
        uint32_t numweapons;
        UILoadoutMacroData* turrets;
        uint32_t numturrets;
        UILoadoutMacroData* shields;
        uint32_t numshields;
        UILoadoutMacroData* engines;
        uint32_t numengines;
        UILoadoutGroupData* turretgroups;
        uint32_t numturretgroups;
        UILoadoutGroupData* shieldgroups;
        uint32_t numshieldgroups;
        UILoadoutAmmoData* ammo;
        uint32_t numammo;
        UILoadoutAmmoData* units;
        uint32_t numunits;
        UILoadoutSoftwareData* software;
        uint32_t numsoftware;
        UILoadoutVirtualMacroData thruster;
      } UILoadout;
      typedef struct {
        uint32_t numweapons;
        uint32_t numturrets;
        uint32_t numshields;
        uint32_t numengines;
        uint32_t numturretgroups;
        uint32_t numshieldgroups;
        uint32_t numammo;
        uint32_t numunits;
        uint32_t numsoftware;
      } UILoadoutCounts;
      size_t GetNumUpgradeSlots(UniverseID destructibleid, const char* macroname, const char* upgradetypename);
      size_t GetNumVirtualUpgradeSlots(UniverseID objectid, const char* macroname, const char* upgradetypename);
      const char* GetUpgradeSlotCurrentMacro(UniverseID defensibleid, UniverseID moduleid, const char* upgradetypename, size_t slot);
      const char* GetVirtualUpgradeSlotCurrentMacro(UniverseID defensibleid, const char* upgradetypename, size_t slot);
      UpgradeGroup GetUpgradeSlotGroup(UniverseID destructibleid, const char* macroname, const char* upgradetypename, size_t slot);
      uint32_t GetNumUpgradeGroups(UniverseID destructibleid, const char* macroname);
      uint32_t GetUpgradeGroups(UpgradeGroup* result, uint32_t resultlen, UniverseID destructibleid, const char* macroname);
      bool IsUpgradeMacroCompatible(UniverseID defensibleid, UniverseID moduleid, const char* macroname, bool ismodule, const char* upgradetypename, size_t slot, const char* upgrademacroname);
      bool IsUpgradeGroupMacroCompatible(UniverseID destructibleid, const char* macroname, const char* path, const char* group, const char* upgradetypename, const char* upgrademacroname);
      bool IsVirtualUpgradeMacroCompatible(UniverseID defensibleid, const char* macroname, const char* upgradetypename, size_t slot, const char* upgrademacroname);
      bool IsAmmoMacroCompatible(const char* weaponmacroname, const char* ammomacroname);
      uint32_t GetNumLoadoutsInfo(UniverseID componentid, const char* macroname);
      uint32_t GetLoadoutsInfo(UILoadoutInfo* result, uint32_t resultlen, UniverseID componentid, const char* macroname);
      bool HasDefaultLoadout(const char* macroname);
      uint32_t GetNumWares(const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
      uint32_t GetWares(const char** result, uint32_t resultlen, const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
      void GetCurrentLoadoutCounts(UILoadoutCounts* result, UniverseID defensibleid, UniverseID moduleid);
      void GetCurrentLoadout(UILoadout* result, UniverseID defensibleid, UniverseID moduleid);
      uint32_t GetLoadoutCounts(UILoadoutCounts* result, UniverseID defensibleid, const char* macroname, const char* loadoutid);
      void GetLoadout(UILoadout* result, UniverseID defensibleid, const char* macroname, const char* loadoutid);
      uint32_t GetMissileCargo(UIWareInfo* result, uint32_t resultlen, UniverseID containerid);
    ]]
  end)
  pcall(function()
    ffi.cdef[[
      bool SetUpgradeSlotMacro(UniverseID defensibleid, UniverseID moduleid, const char* upgradetypename, size_t slot, const char* macroname);
      bool SetVirtualUpgradeSlotMacro(UniverseID defensibleid, const char* upgradetypename, size_t slot, const char* macroname);
    ]]
  end)
  C = ffi.C
  return true
end

local SLOT_TYPES = {
  { name = "engine", tags = "engine", virtual = false },
  { name = "shield", tags = "shield", virtual = false },
  { name = "weapon", tags = "weapon", virtual = false },
  { name = "turret", tags = "turret", virtual = false },
  { name = "thruster", tags = "thruster", virtual = true },
}

local function buf(ctype, n)
  n = tonumber(n) or 0
  if n < 1 then
    n = 1
  end
  return ffi.new(ctype .. "[?]", n)
end

local function alloc_loadout(counts)
  local lo = ffi.new("UILoadout")
  lo.weapons = buf("UILoadoutMacroData", counts.numweapons)
  lo.numweapons = counts.numweapons
  lo.turrets = buf("UILoadoutMacroData", counts.numturrets)
  lo.numturrets = counts.numturrets
  lo.shields = buf("UILoadoutMacroData", counts.numshields)
  lo.numshields = counts.numshields
  lo.engines = buf("UILoadoutMacroData", counts.numengines)
  lo.numengines = counts.numengines
  lo.turretgroups = buf("UILoadoutGroupData", counts.numturretgroups)
  lo.numturretgroups = counts.numturretgroups
  lo.shieldgroups = buf("UILoadoutGroupData", counts.numshieldgroups)
  lo.numshieldgroups = counts.numshieldgroups
  lo.ammo = buf("UILoadoutAmmoData", counts.numammo)
  lo.numammo = counts.numammo
  lo.units = buf("UILoadoutAmmoData", counts.numunits)
  lo.numunits = counts.numunits
  lo.software = buf("UILoadoutSoftwareData", counts.numsoftware)
  lo.numsoftware = counts.numsoftware
  return lo
end

local function log_chunks(prefix, items)
  if not items or #items < 1 then
    log_md(prefix .. " n=0")
    return
  end
  local i = 1
  local part = 1
  while i <= #items do
    local chunk = {}
    local n = 0
    while i <= #items and n < 12 do
      chunk[#chunk + 1] = items[i]
      i = i + 1
      n = n + 1
    end
    log_md(prefix .. " n=" .. #items .. " [" .. part .. "] " .. table.concat(chunk, ","))
    part = part + 1
  end
end

local function dump_macro_arr(prefix, kind, arr, n)
  n = tonumber(n) or 0
  log_md(prefix .. " " .. kind .. " count=" .. n)
  for i = 0, n - 1 do
    local row = arr[i]
    log_md(prefix .. " " .. kind .. " i=" .. i
      .. " slot=" .. tostring(tonumber(row.slot) or 0)
      .. " optional=" .. tostring(row.optional)
      .. " type=" .. ffi_str(row.upgradetypename)
      .. " macro=" .. ffi_str(row.macro))
  end
end

local function dump_group_arr(prefix, kind, arr, n)
  n = tonumber(n) or 0
  log_md(prefix .. " " .. kind .. " count=" .. n)
  for i = 0, n - 1 do
    local row = arr[i]
    log_md(prefix .. " " .. kind .. " i=" .. i
      .. " path=" .. ffi_str(row.path)
      .. " group=" .. ffi_str(row.group)
      .. " count=" .. tostring(tonumber(row.count) or 0)
      .. " optional=" .. tostring(row.optional)
      .. " macro=" .. ffi_str(row.macro))
  end
end

local function dump_ammo_arr(prefix, kind, arr, n)
  n = tonumber(n) or 0
  log_md(prefix .. " " .. kind .. " count=" .. n)
  for i = 0, n - 1 do
    local row = arr[i]
    log_md(prefix .. " " .. kind .. " i=" .. i
      .. " amount=" .. tostring(tonumber(row.amount) or 0)
      .. " optional=" .. tostring(row.optional)
      .. " macro=" .. ffi_str(row.macro))
  end
end

local function dump_software_arr(prefix, arr, n)
  n = tonumber(n) or 0
  log_md(prefix .. " software count=" .. n)
  for i = 0, n - 1 do
    log_md(prefix .. " software i=" .. i .. " ware=" .. ffi_str(arr[i].ware))
  end
end

local function dump_loadout(prefix, lo, counts)
  log_md(prefix .. " counts"
    .. " weapons=" .. tostring(tonumber(counts.numweapons) or 0)
    .. " turrets=" .. tostring(tonumber(counts.numturrets) or 0)
    .. " shields=" .. tostring(tonumber(counts.numshields) or 0)
    .. " engines=" .. tostring(tonumber(counts.numengines) or 0)
    .. " turretgroups=" .. tostring(tonumber(counts.numturretgroups) or 0)
    .. " shieldgroups=" .. tostring(tonumber(counts.numshieldgroups) or 0)
    .. " ammo=" .. tostring(tonumber(counts.numammo) or 0)
    .. " units=" .. tostring(tonumber(counts.numunits) or 0)
    .. " software=" .. tostring(tonumber(counts.numsoftware) or 0))
  dump_macro_arr(prefix, "engine", lo.engines, lo.numengines)
  dump_macro_arr(prefix, "weapon", lo.weapons, lo.numweapons)
  dump_macro_arr(prefix, "turret", lo.turrets, lo.numturrets)
  dump_macro_arr(prefix, "shield", lo.shields, lo.numshields)
  dump_group_arr(prefix, "turretgroup", lo.turretgroups, lo.numturretgroups)
  dump_group_arr(prefix, "shieldgroup", lo.shieldgroups, lo.numshieldgroups)
  dump_ammo_arr(prefix, "ammo", lo.ammo, lo.numammo)
  dump_ammo_arr(prefix, "units", lo.units, lo.numunits)
  dump_software_arr(prefix, lo.software, lo.numsoftware)
  log_md(prefix .. " thruster optional=" .. tostring(lo.thruster.optional)
    .. " macro=" .. ffi_str(lo.thruster.macro))
end

local function dump_current_loadout(id, label)
  local counts = ffi.new("UILoadoutCounts")
  local ok = pcall(function()
    C.GetCurrentLoadoutCounts(counts, id, 0)
  end)
  if not ok then
    log_md("LOW Fit " .. label .. " GetCurrentLoadoutCounts FAIL")
    return
  end
  local lo = alloc_loadout(counts)
  ok = pcall(function()
    C.GetCurrentLoadout(lo, id, 0)
  end)
  if not ok then
    log_md("LOW Fit " .. label .. " GetCurrentLoadout FAIL")
    return
  end
  dump_loadout("LOW Fit " .. label .. " current", lo, counts)
end

local function dump_named_loadout(id, shipmacro, loadoutid, label)
  local counts = ffi.new("UILoadoutCounts")
  local ok = pcall(function()
    C.GetLoadoutCounts(counts, id or 0, shipmacro or "", loadoutid)
  end)
  if not ok then
    log_md("LOW Fit " .. label .. " GetLoadoutCounts FAIL id=" .. tostring(loadoutid))
    return false
  end
  local lo = alloc_loadout(counts)
  ok = pcall(function()
    C.GetLoadout(lo, id or 0, shipmacro or "", loadoutid)
  end)
  if not ok then
    log_md("LOW Fit " .. label .. " GetLoadout FAIL id=" .. tostring(loadoutid))
    return false
  end
  dump_loadout("LOW Fit " .. label .. " namedkit id=" .. tostring(loadoutid), lo, counts)
  return true
end

local function num_slots(id, macro, spec)
  local n = 0
  local ok
  if spec.virtual then
    ok, n = pcall(function()
      return tonumber(C.GetNumVirtualUpgradeSlots(id, macro, spec.name)) or 0
    end)
  else
    ok, n = pcall(function()
      return tonumber(C.GetNumUpgradeSlots(id, macro, spec.name)) or 0
    end)
  end
  if not ok then
    return 0
  end
  return n
end

local function current_macro(id, spec, slot)
  local ok, p
  if spec.virtual then
    ok, p = pcall(function()
      return C.GetVirtualUpgradeSlotCurrentMacro(id, spec.name, slot)
    end)
  else
    ok, p = pcall(function()
      return C.GetUpgradeSlotCurrentMacro(id, 0, spec.name, slot)
    end)
  end
  if not ok or p == nil then
    return ""
  end
  return ffi_str(p)
end

local function slot_group(id, shipmacro, spec, slot)
  if spec.virtual then
    return "", ""
  end
  local ok, g = pcall(function()
    return C.GetUpgradeSlotGroup(id, shipmacro or "", spec.name, slot)
  end)
  if not ok or g == nil then
    return "", ""
  end
  return ffi_str(g.path), ffi_str(g.group)
end

local function compatible_slot(id, shipmacro, spec, slot, cand)
  local ok, yes
  if spec.virtual then
    ok, yes = pcall(function()
      return C.IsVirtualUpgradeMacroCompatible(id, shipmacro, spec.name, slot, cand)
    end)
  else
    ok, yes = pcall(function()
      return C.IsUpgradeMacroCompatible(id, 0, shipmacro, false, spec.name, slot, cand)
    end)
  end
  return ok and yes
end

local function compatible_group(id, shipmacro, spec, path, group, cand)
  if spec.virtual or path == "" or group == "" then
    return false
  end
  local ok, yes = pcall(function()
    return C.IsUpgradeGroupMacroCompatible(id, shipmacro, path, group, spec.name, cand)
  end)
  return ok and yes
end

local function ware_macro(wareid)
  if GetWareData then
    local ok, m = pcall(GetWareData, wareid, "component")
    if ok and m and m ~= "" then
      return m
    end
    ok, m = pcall(GetWareData, wareid, "macro")
    if ok and m and m ~= "" then
      return m
    end
  end
  if type(wareid) == "string" and wareid:match("_macro$") then
    return wareid
  end
  return tostring(wareid or "")
end

local function ware_mk(wareid)
  local s = tostring(wareid or "")
  local n = s:match("_mk(%d+)")
  if n then
    return tonumber(n) or 0
  end
  return 0
end

local function list_wares(tags)
  if warepool[tags] then
    return warepool[tags]
  end
  local out = {}
  local ok, n = pcall(function()
    return tonumber(C.GetNumWares(tags, false, "", "")) or 0
  end)
  if not ok then
    log_md("LOW Fit warepool tag=" .. tags .. " GetNumWares FAIL")
    warepool[tags] = out
    return out
  end
  local cap = n
  if cap > 400 then
    cap = 400
  end
  if n < 1 then
    log_md("LOW Fit warepool tag=" .. tags .. " n=0")
    warepool[tags] = out
    return out
  end
  local raw = ffi.new("const char*[?]", cap)
  local got = 0
  ok, got = pcall(function()
    return tonumber(C.GetWares(raw, cap, tags, false, "", "")) or 0
  end)
  if not ok then
    log_md("LOW Fit warepool tag=" .. tags .. " GetWares FAIL n=" .. tostring(n))
    warepool[tags] = out
    return out
  end
  local macros = {}
  for i = 0, got - 1 do
    local id = ffi_str(raw[i])
    if id ~= "" then
      out[#out + 1] = id
      macros[#macros + 1] = ware_macro(id)
    end
  end
  log_md("LOW Fit warepool tag=" .. tags .. " n=" .. tostring(n) .. " got=" .. tostring(got) .. " truncated=" .. tostring(n > cap))
  log_chunks("LOW Fit warepool tag=" .. tags .. " wares", out)
  log_chunks("LOW Fit warepool tag=" .. tags .. " macros", macros)
  warepool[tags] = out
  return out
end

local function dump_upgrade_groups(id, shipmacro, label)
  local n = 0
  local ok
  ok, n = pcall(function()
    return tonumber(C.GetNumUpgradeGroups(id, shipmacro or "")) or 0
  end)
  if not ok then
    log_md("LOW Fit " .. label .. " GetNumUpgradeGroups FAIL")
    return
  end
  log_md("LOW Fit " .. label .. " groups n=" .. tostring(n))
  if n < 1 then
    return
  end
  local arr = buf("UpgradeGroup", n)
  local got = 0
  ok, got = pcall(function()
    return tonumber(C.GetUpgradeGroups(arr, n, id, shipmacro or "")) or 0
  end)
  if not ok then
    log_md("LOW Fit " .. label .. " GetUpgradeGroups FAIL")
    return
  end
  for i = 0, got - 1 do
    log_md("LOW Fit " .. label .. " group i=" .. i
      .. " path=" .. ffi_str(arr[i].path)
      .. " group=" .. ffi_str(arr[i].group))
  end
end

local function snapshot(id, shipmacro, label)
  local filled = 0
  local empty = 0
  log_md("HIGH Fit " .. label .. " macro=" .. tostring(shipmacro))
  for t = 1, #SLOT_TYPES do
    local spec = SLOT_TYPES[t]
    local n = num_slots(id, shipmacro, spec)
    local f, e = 0, 0
    for slot = 1, n do
      local cur = current_macro(id, spec, slot)
      local path, group = slot_group(id, shipmacro, spec, slot)
      if cur == "" then
        e = e + 1
        empty = empty + 1
        log_md("MID Fit " .. label .. " " .. spec.name .. " slot=" .. slot
          .. " path=" .. path .. " group=" .. group .. " empty")
      else
        f = f + 1
        filled = filled + 1
        log_md("MID Fit " .. label .. " " .. spec.name .. " slot=" .. slot
          .. " path=" .. path .. " group=" .. group .. " macro=" .. cur)
      end
    end
    log_md("HIGH Fit " .. label .. " " .. spec.name .. " slots=" .. n .. " filled=" .. f .. " empty=" .. e)
  end
  log_md("HIGH Fit " .. label .. " total filled=" .. filled .. " empty=" .. empty)
  return empty
end

local function scan_candidates(id, shipmacro, spec, slot, path, group, wares)
  local best_macro = nil
  local best_mk = -1
  local slotcompat = 0
  local groupcompat = 0
  local names = {}
  for i = 1, #wares do
    local cand = ware_macro(wares[i])
    if cand and cand ~= "" then
      local slotok = compatible_slot(id, shipmacro, spec, slot, cand)
      local groupok = compatible_group(id, shipmacro, spec, path, group, cand)
      if slotok then
        slotcompat = slotcompat + 1
      end
      if groupok then
        groupcompat = groupcompat + 1
      end
      if slotok or groupok then
        names[#names + 1] = cand
        local mk = ware_mk(wares[i])
        if mk > best_mk then
          best_mk = mk
          best_macro = cand
        elseif best_macro == nil then
          best_macro = cand
          best_mk = mk
        end
      end
    end
  end
  return best_macro, slotcompat, groupcompat, names
end

local function log_empty_compat(id, shipmacro)
  for t = 1, #SLOT_TYPES do
    local spec = SLOT_TYPES[t]
    local wares = list_wares(spec.tags)
    local n = num_slots(id, shipmacro, spec)
    for slot = 1, n do
      local cur = current_macro(id, spec, slot)
      if cur == "" then
        local path, group = slot_group(id, shipmacro, spec, slot)
        local pick, slotcompat, groupcompat, names = scan_candidates(id, shipmacro, spec, slot, path, group, wares)
        log_md("MID Fit compat " .. spec.name .. " slot=" .. slot
          .. " path=" .. path .. " group=" .. group
          .. " slotcompat=" .. slotcompat
          .. " groupcompat=" .. groupcompat
          .. " pick=" .. tostring(pick))
        log_chunks("LOW Fit candidates " .. spec.name .. " slot=" .. slot, names)
        if pick then
          log_md("HIGH Fit would-install " .. spec.name .. " slot=" .. slot .. " macro=" .. pick .. " LOG_ONLY=" .. tostring(LOG_ONLY))
        else
          log_md("MID Fit none " .. spec.name .. " slot=" .. slot .. " path=" .. path .. " group=" .. group)
        end
      end
    end
  end
  log_md("HIGH Fit fill skipped LOG_ONLY=" .. tostring(LOG_ONLY))
end

local function dump_missile_cargo(id, label)
  local arr = buf("UIWareInfo", 64)
  local got = 0
  local ok
  ok, got = pcall(function()
    return tonumber(C.GetMissileCargo(arr, 64, id)) or 0
  end)
  if not ok then
    log_md("LOW Fit " .. label .. " GetMissileCargo FAIL")
    return
  end
  log_md("LOW Fit " .. label .. " missilecargo n=" .. tostring(got))
  for i = 0, got - 1 do
    log_md("LOW Fit " .. label .. " missilecargo i=" .. i
      .. " ware=" .. ffi_str(arr[i].ware)
      .. " macro=" .. ffi_str(arr[i].macro)
      .. " amount=" .. tostring(tonumber(arr[i].amount) or 0))
  end
end

local function ammo_compatible(weaponmacro, ammomacro)
  local ok, yes = pcall(function()
    return C.IsAmmoMacroCompatible(weaponmacro, ammomacro)
  end)
  return ok and yes
end

local function log_ammo(id, shipmacro)
  dump_missile_cargo(id, "stage2")
  local missiles = list_wares("missile")
  local kinds = {
    { name = "weapon", virtual = false },
    { name = "turret", virtual = false },
  }
  for k = 1, #kinds do
    local spec = kinds[k]
    local n = num_slots(id, shipmacro, spec)
    for slot = 1, n do
      local cur = current_macro(id, spec, slot)
      if cur ~= "" then
        local names = {}
        for i = 1, #missiles do
          local cand = ware_macro(missiles[i])
          if cand ~= "" and ammo_compatible(cur, cand) then
            names[#names + 1] = cand
          end
        end
        log_md("MID Fit ammo " .. spec.name .. " slot=" .. slot
          .. " weapon=" .. cur .. " compat=" .. #names)
        log_chunks("LOW Fit ammo candidates " .. spec.name .. " slot=" .. slot, names)
      else
        log_md("MID Fit ammo " .. spec.name .. " slot=" .. slot .. " skip empty weapon")
      end
    end
  end
end

local function on_list(_, macroid)
  macroid = tostring(macroid or "")
  debug("HIGH Fit ListLoadouts macro=" .. macroid)
  warepool = {}
  if not init_ffi() or macroid == "" then
    notify_md("presets_ready", "0")
    return
  end
  local n = 0
  local ok
  ok, n = pcall(function()
    return tonumber(C.GetNumLoadoutsInfo(0, macroid)) or 0
  end)
  if not ok then
    n = 0
  end
  local hasdef = false
  pcall(function()
    hasdef = C.HasDefaultLoadout(macroid) and true or false
  end)
  log_md("HIGH Fit loadouts macro=" .. macroid .. " n=" .. tostring(n) .. " hasDefault=" .. tostring(hasdef))
  if n < 1 then
    notify_md("presets_ready", "0")
    return
  end
  if n > 16 then
    n = 16
  end
  local info = ffi.new("UILoadoutInfo[?]", n)
  local got = 0
  ok, got = pcall(function()
    return tonumber(C.GetLoadoutsInfo(info, n, 0, macroid)) or 0
  end)
  if not ok then
    got = 0
  end
  local sent = 0
  local rows = {}
  for i = 0, got - 1 do
    local id = ffi_str(info[i].id)
    if id ~= "" then
      local name = ffi_str(info[i].name)
      local del = false
      pcall(function()
        del = info[i].deleteable and true or false
      end)
      local kind = "author"
      if id:match("^player_") or del then
        kind = "player"
      end
      if name == "" then
        name = id
      end
      rows[#rows + 1] = { kind = kind, id = id, name = name, del = del }
      log_md("MID Fit named loadout kind=" .. kind .. " id=" .. id .. " name=" .. name .. " deleteable=" .. tostring(del))
    end
  end
  for r = 1, #rows do
    local row = rows[r]
    notify_md("preset_kind", row.kind)
    notify_md("preset", row.id)
    notify_md("preset_name", row.name)
    sent = sent + 1
  end
  notify_md("presets_ready", tostring(sent))
  for r = 1, #rows do
    dump_named_loadout(0, macroid, rows[r].id, "list")
  end
end

local function on_job(_, payload)
  payload = tostring(payload or "compat")
  if payload:sub(1, 7) == "preset|" then
    job.mode = "preset"
    job.loadoutid = payload:sub(8)
  else
    job.mode = "compat"
    job.loadoutid = ""
  end
  debug("HIGH Fit job mode=" .. job.mode .. " id=" .. job.loadoutid)
end

local function on_fit(_, obj)
  if not init_ffi() then
    log_md("HIGH Fit abort: no ffi")
    return
  end
  local id = ship_id(obj)
  local macro = ship_macro(obj)
  if not id then
    log_md("HIGH Fit abort: no ship id")
    return
  end
  local hasdef = false
  pcall(function()
    hasdef = C.HasDefaultLoadout(macro) and true or false
  end)
  log_md("HIGH Fit stage2 start LOG_ONLY=" .. tostring(LOG_ONLY)
    .. " mode=" .. job.mode
    .. " loadout=" .. job.loadoutid
    .. " hasDefault=" .. tostring(hasdef)
    .. " macro=" .. tostring(macro))
  dump_current_loadout(id, "stage2")
  dump_upgrade_groups(id, macro, "stage2")
  snapshot(id, macro, "stage2")
  if job.mode == "preset" and job.loadoutid ~= "" then
    log_md("HIGH Fit preset dump id=" .. job.loadoutid .. " (not applied, LOG_ONLY)")
    dump_named_loadout(id, macro, job.loadoutid, "stage2")
  end
  log_empty_compat(id, macro)
  log_ammo(id, macro)
  dump_current_loadout(id, "stage3")
  snapshot(id, macro, "stage3")
end

local function init()
  debug("HIGH Fit lua init LOG_ONLY=" .. tostring(LOG_ONLY))
  if not RegisterEvent then
    debug("HIGH Fit RegisterEvent missing")
    return
  end
  RegisterEvent("CheatMenu90.ListLoadouts", on_list)
  RegisterEvent("CheatMenu90.SetJob", on_job)
  RegisterEvent("CheatMenu90.Fit", on_fit)
  debug("HIGH Fit lua ready")
end

if Register_OnLoad_Init then
  Register_OnLoad_Init(init, "cm90_fit")
else
  init()
end
