-- Preset. Sealed after the 2026-09-26 test: test_3 SUCCESS 175/175.
-- Do not fill kit holes from found modules.
-- Bridge: CM90Fit.install_preset(api, id, macro). MD install event is kit_ready.

_G.CM90Fit = _G.CM90Fit or {}

function _G.CM90Fit.install_preset(api, id, macro)
  api.log_md("HIGH Fit preset apply id=" .. api.job.loadoutid)
  local wanted, kit = api.collect_preset_wanted(id, macro, api.job.loadoutid)
  api.set_pending(wanted, kit)
  api.log_before_install("preset", wanted, " id=" .. api.job.loadoutid)
  if api.LOG_ONLY then
    api.log_md("HIGH Fit install skipped LOG_ONLY n=" .. #wanted)
    api.finish_stage3(id, macro, wanted, kit)
    return
  end
  local ok_n, fail_n = api.install_wanted(id, wanted, true)
  if fail_n > 0 and #wanted > 0 then
    local wares = api.ware_ids_for(wanted, kit)
    api.log_md("HIGH Fit defer md wares mode=preset id=" .. api.job.loadoutid
      .. " ffi_ok=" .. tostring(ok_n) .. " ffi_fail=" .. tostring(fail_n) .. " wares=" .. #wares)
    if #wares < 1 then
      api.log_md("HIGH Fit result FAIL no-wares")
      api.finish_stage3(id, macro, wanted, kit)
      return
    end
    api.send_ware_apply("preset", wares, "kit_ready")
    return
  end
  api.log_md("HIGH Fit install via ffi n=" .. #wanted)
  api.finish_stage3(id, macro, wanted, kit)
end
