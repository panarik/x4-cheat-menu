-- Pure fit decisions. No FFI, no MD, no ship.
-- The game file asks the engine which macros fit a slot, then calls this.

local function ware_mk(wareid)
  local s = tostring(wareid or "")
  local n = s:match("_mk(%d+)")
  if n then
    return tonumber(n) or 0
  end
  return 0
end

local function pick_best(candidates)
  local best_macro = nil
  local best_mk = -1
  local slotcompat = 0
  local groupcompat = 0
  local names = {}
  for i = 1, #(candidates or {}) do
    local row = candidates[i]
    local macro = row.macro
    if macro and macro ~= "" then
      if row.slotok then
        slotcompat = slotcompat + 1
      end
      if row.groupok then
        groupcompat = groupcompat + 1
      end
      if row.slotok or row.groupok then
        names[#names + 1] = macro
        local mk = tonumber(row.mk) or 0
        if mk > best_mk or best_macro == nil then
          best_mk = mk
          best_macro = macro
        end
      end
    end
  end
  return best_macro, slotcompat, groupcompat, names
end

local function slot_taken(fitting, name, slot)
  for i = 1, #(fitting or {}) do
    local row = fitting[i]
    if row.spec and row.spec.name == name and row.slot == slot then
      return true
    end
  end
  return false
end

local function merge_keep(fitting, extra)
  local out = {}
  for i = 1, #(fitting or {}) do
    out[#out + 1] = fitting[i]
  end
  for i = 1, #(extra or {}) do
    local row = extra[i]
    local name = row.spec and row.spec.name or ""
    if not slot_taken(out, name, row.slot) then
      out[#out + 1] = row
    end
  end
  return out
end

local function plan_slots(wanted)
  local plan = {
    engines = {},
    weapons = {},
    turrets = {},
    shields = {},
    thruster = "",
  }
  local box = {
    engine = plan.engines,
    weapon = plan.weapons,
    turret = plan.turrets,
    shield = plan.shields,
  }
  for i = 1, #(wanted or {}) do
    local row = wanted[i]
    local name = row.spec and row.spec.name or ""
    local macro = row.macro
    if name == "thruster" then
      if macro and macro ~= "" then
        plan.thruster = macro
      end
    elseif box[name] and macro and macro ~= "" then
      local list = box[name]
      list[#list + 1] = { slot = row.slot or 0, macro = macro }
    end
  end
  return plan
end

local function is_empty(current)
  return current == nil or current == ""
end

-- One hull walk. Empty slot takes the best compatible macro.
-- A standing module stays, even when a higher _mk is compatible.
-- Two fills of the same sockets therefore produce two different lists.
local function walk_hull(slots)
  local picks = {}
  local occupied = {}
  for i = 1, #(slots or {}) do
    local slot = slots[i]
    local name = slot.name or (slot.spec and slot.spec.name) or ""
    local spec = slot.spec or { name = name }
    if is_empty(slot.current) then
      local best = pick_best(slot.candidates)
      if best and best ~= "" then
        picks[#picks + 1] = {
          spec = spec,
          slot = slot.slot,
          path = slot.path or "",
          group = slot.group or "",
          macro = best,
          source = "found-compat",
        }
      end
    else
      occupied[#occupied + 1] = {
        spec = spec,
        slot = slot.slot,
        path = slot.path or "",
        group = slot.group or "",
        macro = slot.current,
        source = "found-occupied",
      }
    end
  end
  return merge_keep(picks, occupied)
end

local function unique_ids(list)
  local seen = {}
  local ids = {}
  for i = 1, #(list or {}) do
    local ware = tostring(list[i] or "")
    if ware ~= "" and not seen[ware] then
      seen[ware] = true
      ids[#ids + 1] = ware
    end
  end
  return ids
end

_G.CM90FitRule = {
  ware_mk = ware_mk,
  pick_best = pick_best,
  merge_keep = merge_keep,
  plan_slots = plan_slots,
  walk_hull = walk_hull,
  unique_ids = unique_ids,
}
