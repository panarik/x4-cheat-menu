-- Found modules. Do not call the preset path.
-- Bridge: CM90Fit.install_found(api, id, macro, fitting). MD install event is found_apply.
-- fitting is the empty-slot list from cm90_fit.lua. Occupied slots are added as
-- they stand: generate_loadout replaces the whole loadout and drops any ware
-- that is not in the list.

_G.CM90Fit = _G.CM90Fit or {}

local function has_slot(fitting, spec, slot)
  for i = 1, #fitting do
    local row = fitting[i]
    if row.spec and row.spec.name == spec and row.slot == slot then
      return true
    end
  end
  return false
end

function _G.CM90Fit.install_found(api, id, macro, fitting)
  fitting = fitting or {}
  local extra = api.collect_occupied(id, macro)
  for i = 1, #extra do
    local row = extra[i]
    if not has_slot(fitting, row.spec.name, row.slot) then
      fitting[#fitting + 1] = row
    end
  end
  api.set_pending(fitting, nil)
  api.log_before_install("found-modules", fitting, "")
  if api.LOG_ONLY then
    api.log_md("HIGH Fit install skipped LOG_ONLY n=" .. #fitting)
    api.finish_stage3(id, macro, fitting, nil)
    return
  end
  local ok_n, fail_n = api.install_wanted(id, fitting, false)
  if fail_n > 0 and #fitting > 0 then
    local wares = api.ware_ids_for(fitting, nil)
    api.log_md("HIGH Fit defer md wares mode=found-modules ffi_ok=" .. tostring(ok_n)
      .. " ffi_fail=" .. tostring(fail_n) .. " wares=" .. #wares)
    if #wares < 1 then
      api.log_md("HIGH Fit result FAIL no-wares")
      api.finish_stage3(id, macro, fitting, nil)
      return
    end
    api.send_ware_apply("found-modules", wares, "found_apply")
    return
  end
  api.log_md("HIGH Fit found install done ok=" .. tostring(ok_n) .. " fail=" .. tostring(fail_n) .. " n=" .. #fitting)
  api.finish_stage3(id, macro, fitting, nil)
end
