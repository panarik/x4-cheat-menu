-- Race membership for station modules. No game, no FFI.
-- A module with maker races belongs only to those races.
-- A module with no maker race belongs to a race only when one of its
-- blueprint owners maps to that race. It is not copied into every race.
-- MD Fill_Build copies TYPE_ORDER. Connectors are not multiplied by count.

local M = {}

local TYPE_ORDER = {
  "dock",
  "storage",
  "production",
  "habitation",
  "welfare",
  "defence",
  "build",
  "processing",
  "radar",
  "venture",
  "other",
}

local LIBRARY_ALIAS = {
  moduletypes_dock = "dock",
  moduletypes_storage = "storage",
  moduletypes_production = "production",
  moduletypes_habitation = "habitation",
  moduletypes_welfare = "welfare",
  moduletypes_defence = "defence",
  moduletypes_build = "build",
  moduletypes_processing = "processing",
  moduletypes_radar = "radar",
  moduletypes_venture = "venture",
  moduletypes_other = "other",
}

local function as_ids(value)
  if type(value) == "string" then
    if value == "" or value == "nil" then
      return {}
    end
    return { value }
  end
  if type(value) ~= "table" then
    return {}
  end
  local out = {}
  local seen = {}
  for i = 1, #value do
    local id = value[i]
    if type(id) ~= "string" then
      id = tostring(id or "")
    end
    if id ~= "" and id ~= "nil" and not seen[id] then
      seen[id] = true
      out[#out + 1] = id
    end
  end
  return out
end

local function name_at(names, index, fallback)
  local name = nil
  if type(names) == "table" then
    name = names[index]
  elseif type(names) == "string" and index == 1 then
    name = names
  end
  if type(name) ~= "string" then
    name = tostring(name or "")
  end
  if name == "" or name == "nil" or name == "missing" then
    return fallback
  end
  return name
end

function M.library_of(value)
  local id = value
  if type(id) ~= "string" then
    id = tostring(id or "")
  end
  if id == "" or id == "nil" or id == "missing" or id == "ERR" then
    return "other"
  end
  if LIBRARY_ALIAS[id] then
    return LIBRARY_ALIAS[id]
  end
  return id
end

function M.parse_factions(text)
  local map = {}
  if type(text) ~= "string" or text == "" then
    return map
  end
  for piece in text:gmatch("[^;]+") do
    local fac, race, name = piece:match("^([^|]*)|([^|]*)|(.*)$")
    if fac and fac ~= "" and race and race ~= "" then
      if not name or name == "" then
        name = race
      end
      map[fac] = { race = race, name = name }
    end
  end
  return map
end

function M.memberships(maker_ids, maker_names, owner_ids, faction_map)
  local map = faction_map or {}
  local makers = as_ids(maker_ids)
  local out = {}
  local seen = {}
  if #makers > 0 then
    for i, id in ipairs(makers) do
      if not seen[id] then
        seen[id] = true
        out[#out + 1] = { id = id, name = name_at(maker_names, i, id) }
      end
    end
    return out
  end
  local owners = as_ids(owner_ids)
  for _, fac in ipairs(owners) do
    local info = map[fac]
    if type(info) == "table" and type(info.race) == "string" and info.race ~= "" and not seen[info.race] then
      seen[info.race] = true
      local name = info.name
      if type(name) ~= "string" or name == "" then
        name = info.race
      end
      out[#out + 1] = { id = info.race, name = name }
    end
  end
  return out
end

function M.expand(ids, counts)
  local out = {}
  if type(ids) ~= "table" or type(counts) ~= "table" then
    return out
  end
  for i = 1, #ids do
    local n = tonumber(counts[i]) or 0
    if n > 0 then
      for _ = 1, n do
        out[#out + 1] = ids[i]
      end
    end
  end
  return out
end

function M.connectors_for(rows, race)
  local out = {}
  local seen = {}
  if type(rows) ~= "table" or type(race) ~= "string" or race == "" then
    return out
  end
  for i = 1, #rows do
    local row = rows[i]
    if type(row) == "table" then
      local conn = row.connection
      local hit = conn == "1" or conn == 1 or conn == true
      local macro = row.macro
      if hit and row.race == race and type(macro) == "string" and macro ~= "" and not seen[macro] then
        seen[macro] = true
        out[#out + 1] = macro
      end
    end
  end
  return out
end

function M.order_types(present)
  local have = {}
  if type(present) == "table" then
    for i = 1, #present do
      local id = M.library_of(present[i])
      if id ~= "" then
        have[id] = true
      end
    end
  end
  local out = {}
  local used = {}
  for i = 1, #TYPE_ORDER do
    local id = TYPE_ORDER[i]
    if have[id] then
      out[#out + 1] = id
      used[id] = true
    end
  end
  local rest = {}
  for id in pairs(have) do
    if not used[id] then
      rest[#rest + 1] = id
    end
  end
  table.sort(rest)
  for i = 1, #rest do
    out[#out + 1] = rest[i]
  end
  return out
end

_G.CM90StationRule = M
