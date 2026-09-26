-- Pure ship-list grouping. No FFI, no MD, no menu.
-- The game file reads makerraceid and blueprintsowners off each ship, then calls this.

local function parse_maker_race(value)
  if value == nil or value == false or value == "" then
    return nil
  end
  if type(value) == "table" then
    local id = value[1]
    if id == nil or id == "" then
      return nil
    end
    return tostring(id)
  end
  return tostring(value)
end

local function fields_of(text)
  local out = {}
  for part in string.gmatch((text or "") .. "|", "([^|]*)|") do
    out[#out + 1] = part
  end
  if #out > 0 and out[#out] == "" then
    out[#out] = nil
  end
  return out
end

local function bucket_of(race, labels, owner, is_ambiguous)
  if race and race ~= "" then
    local label = labels and labels[race] or nil
    if label == nil or label == "" then
      label = race
    end
    return race, label, "race"
  end
  if owner and not is_ambiguous then
    local key = owner.id or ""
    if key ~= "" then
      local label = owner.name
      if label == nil or label == "" then
        label = key
      end
      return key, label, "faction"
    end
  end
  return "other", "Other", "other"
end

local function group_ships(ships, races, labels, owners, ambiguous)
  local groups = {}
  local order = {}
  local n_race, n_fac, n_other = 0, 0, 0
  ships = ships or {}
  for i = 1, #ships do
    local row = ships[i]
    local race = races and races[row.macro] or nil
    local owner = owners and owners[row.ware] or nil
    local amb = ambiguous and ambiguous[row.ware] or nil
    local key, label, src = bucket_of(race, labels, owner, amb)
    local g = groups[key]
    if not g then
      g = { key = key, label = label, src = src, wares = {} }
      groups[key] = g
      order[#order + 1] = key
    end
    g.wares[#g.wares + 1] = row.ware
    if src == "race" then
      n_race = n_race + 1
    elseif src == "faction" then
      n_fac = n_fac + 1
    else
      n_other = n_other + 1
    end
  end
  return {
    groups = groups,
    order = order,
    n_race = n_race,
    n_faction = n_fac,
    n_other = n_other,
  }
end

_G.CM90Catalog = {
  parse_maker_race = parse_maker_race,
  parse_owner = parse_maker_race,
  fields_of = fields_of,
  bucket_of = bucket_of,
  group_ships = group_ships,
}
