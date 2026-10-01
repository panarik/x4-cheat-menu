-- Found modules. Do not call the preset path.
-- Bridge: CM90Fit.install_found(api, id, macro, fitting).
-- fitting is already the hull walk: empty slots picked, standing modules kept.
-- SaveLoadout writes that list as id cm90_auto.
-- MD then get_loadout + apply_loadout on that id. generate_loadout is only
-- the fallback when the save is missing.

_G.CM90Fit = _G.CM90Fit or {}

function _G.CM90Fit.install_found(api, id, macro, fitting)
  fitting = fitting or {}
  api.set_pending(fitting, nil)
  api.log_before_install("found-modules", fitting, "")
  if api.LOG_ONLY then
    api.log_md("HIGH Fit install skipped LOG_ONLY n=" .. #fitting)
    api.finish_stage3(id, macro, fitting, nil)
    return
  end
  local saved = api.save_slot_loadout(macro, fitting)
  local ok_n, fail_n = api.install_wanted(id, fitting, false)
  if saved then
    api.notify_md("found_saved", "1")
    local wares = api.ware_ids_for(fitting, nil)
    api.log_md("HIGH Fit defer saved loadout wares=" .. #wares)
    api.send_ware_apply("found-modules", wares, "found_apply")
    return
  end
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
