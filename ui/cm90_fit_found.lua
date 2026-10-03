-- Found modules. Do not call the preset path.
-- Bridge: CM90Fit.install_found(api, id, macro).
-- Empty-slot scan stays in this file. Occupied macros stay in the ware list
-- because generate_loadout replaces the whole kit.
-- MD event is found_apply. It reads md.$cm90.$foundwares only.

_G.CM90Fit = _G.CM90Fit or {}

function _G.CM90Fit.install_found(api, id, macro)
  local fitting = api.collect_found_picks(id, macro)
  api.set_pending(id, fitting, nil)
  api.log_before_install("found-modules", fitting, "")
  if api.LOG_ONLY then
    api.log_md("HIGH Fit install skipped LOG_ONLY n=" .. #fitting)
    api.finish_stage3(id, macro, fitting, nil)
    return
  end
  local wares = api.ware_ids_for(fitting, nil)
  if #wares < 1 then
    api.log_md("HIGH Fit result FAIL no-wares")
    api.finish_stage3(id, macro, fitting, nil)
    return
  end
  api.log_md("HIGH Fit defer md wares mode=found-modules wares=" .. #wares)
  api.send_ware_apply("found-modules", wares, "found_apply")
end
