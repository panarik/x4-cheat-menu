-- Station plot purchase. The build pipeline is md/cm90_station_logic.xml.
-- This file only calls the plot FFI the map uses, and reports the raw answer.

local ffi
local C
local ready = false
local cdef_done = false

local PLOT_X = 10000
local PLOT_Y = 10000
local PLOT_Z = 10000

local function debug(msg)
  if DebugError then
    DebugError("[CM90] " .. tostring(msg))
  end
end

local function log_md(line)
  line = tostring(line or "")
  debug(line)
  if AddUITriggeredEvent then
    AddUITriggeredEvent("CM90Station", "log", line)
  end
end

local function plot_result(token)
  log_md("HIGH Station plot result " .. token)
  if AddUITriggeredEvent then
    AddUITriggeredEvent("CM90Station", "plot", token)
  end
end

local function init_ffi()
  if ready then
    return true
  end
  local ok, lib = pcall(require, "ffi")
  if not ok or not lib then
    log_md("HIGH Station plot ffi fail require")
    return false
  end
  ffi = lib
  local cdef_ok, cdef_err = true, nil
  if not cdef_done then
    cdef_ok, cdef_err = pcall(function()
    ffi.cdef[[
      typedef uint64_t UniverseID;
      typedef struct { float x; float y; float z; float yaw; float pitch; float roll; } UIPosRot;
      typedef struct { float x; float y; float z; } Coord3D;
      UIPosRot GetObjectPositionInSector(UniverseID objectid);
      Coord3D GetBuildPlotSize(UniverseID stationid);
      Coord3D GetPaidBuildPlotSize(UniverseID stationid);
      Coord3D GetBuildPlotCenterOffset(UniverseID stationid);
      int64_t GetBuildPlotPrice(UniverseID sectorid, UIPosRot location, float x, float y, float z, const char* factionid);
      void PayBuildPlotSize(UniverseID stationid, Coord3D plotsize, Coord3D plotcenter);
      UniverseID GetSectorControlStation(UniverseID sectorid);
      void ForceBuildCompletion(UniverseID containerid);
      size_t GetNumPlannedStationModules(UniverseID defensibleid, bool includeall);
      uint32_t GetNumStationModules(UniverseID stationid, bool includeconstructions, bool includewrecks);
    ]]
    end)
  end
  if not cdef_ok then
    log_md("HIGH Station plot ffi fail cdef " .. tostring(cdef_err))
    return false
  end
  cdef_done = true
  C = ffi.C
  local sym_ok, sym_err = pcall(function()
    return C.PayBuildPlotSize, C.ForceBuildCompletion
  end)
  if not sym_ok then
    log_md("HIGH Station plot ffi fail symbol " .. tostring(sym_err))
    return false
  end
  ready = true
  log_md("HIGH Station plot ffi ready")
  return true
end

local function id_of(obj)
  if obj == nil then
    return nil
  end
  if ConvertIDTo64Bit then
    local ok, id = pcall(ConvertIDTo64Bit, obj)
    if ok and id ~= nil and tonumber(id) ~= 0 then
      return id
    end
  end
  return nil
end

local function coord_text(c)
  if c == nil then
    return "nil"
  end
  return tostring(c.x) .. "," .. tostring(c.y) .. "," .. tostring(c.z)
end

local function on_plot(_, obj)
  log_md("LOW Station plot raw obj=" .. tostring(obj))
  if not init_ffi() then
    plot_result("fail-ffi")
    return
  end
  local station = id_of(obj)
  if not station then
    log_md("HIGH Station plot fail no station id")
    plot_result("fail-id")
    return
  end
  local owner_ok, owner = pcall(GetComponentData, obj, "owner")
  local sector_ok, sector = pcall(GetComponentData, obj, "sectorid")
  log_md("LOW Station plot raw owner_ok=" .. tostring(owner_ok)
    .. " owner=" .. tostring(owner)
    .. " owner_type=" .. type(owner)
    .. " sector_ok=" .. tostring(sector_ok)
    .. " sector=" .. tostring(sector)
    .. " sector_type=" .. type(sector))
  local ownerid = owner
  if type(owner) == "table" then
    ownerid = owner.id or owner[1]
  end
  ownerid = tostring(ownerid or "")
  local sectorid = id_of(sector)
  if not sectorid then
    log_md("HIGH Station plot fail no sector id")
    plot_result("fail-sector")
    return
  end
  if ownerid == "" or ownerid == "nil" then
    log_md("HIGH Station plot fail no owner")
    plot_result("fail-owner")
    return
  end
  local pos_ok, pos = pcall(function()
    return C.GetObjectPositionInSector(station)
  end)
  if not pos_ok then
    log_md("HIGH Station plot fail position " .. tostring(pos))
    plot_result("fail-position")
    return
  end
  log_md("LOW Station plot position x=" .. tostring(pos.x)
    .. " y=" .. tostring(pos.y)
    .. " z=" .. tostring(pos.z)
    .. " yaw=" .. tostring(pos.yaw))
  local center_ok, center = pcall(function()
    return C.GetBuildPlotCenterOffset(station)
  end)
  log_md("LOW Station plot center_ok=" .. tostring(center_ok)
    .. " center=" .. coord_text(center_ok and center or nil))
  local size_ok, cursize = pcall(function()
    return C.GetBuildPlotSize(station)
  end)
  local paid_ok, paidsize = pcall(function()
    return C.GetPaidBuildPlotSize(station)
  end)
  log_md("LOW Station plot before size_ok=" .. tostring(size_ok)
    .. " size=" .. coord_text(size_ok and cursize or nil)
    .. " paid_ok=" .. tostring(paid_ok)
    .. " paid=" .. coord_text(paid_ok and paidsize or nil))
  local price_ok, price = pcall(function()
    return tonumber(C.GetBuildPlotPrice(sectorid, pos, PLOT_X, PLOT_Y, PLOT_Z, ownerid))
  end)
  log_md("LOW Station plot price_ok=" .. tostring(price_ok)
    .. " price=" .. tostring(price)
    .. " meters=" .. PLOT_X .. "," .. PLOT_Y .. "," .. PLOT_Z
    .. " owner=" .. ownerid)
  if not price_ok or price == nil then
    log_md("HIGH Station plot fail price " .. tostring(price))
    plot_result("fail-price")
    return
  end
  local cash = nil
  if GetPlayerMoney then
    local cash_ok, cash_n = pcall(GetPlayerMoney)
    cash = cash_ok and cash_n or nil
    log_md("LOW Station plot cash_ok=" .. tostring(cash_ok) .. " cash=" .. tostring(cash_n))
  end
  if price <= 0 then
    log_md("HIGH Station plot fail price<=0")
    plot_result("fail-price")
    return
  end
  if cash ~= nil and cash < price then
    log_md("HIGH Station plot fail money price=" .. tostring(price) .. " cash=" .. tostring(cash))
    plot_result("fail-money")
    return
  end
  local control_ok, control = pcall(function()
    return C.GetSectorControlStation(sectorid)
  end)
  log_md("LOW Station plot control_ok=" .. tostring(control_ok)
    .. " control=" .. tostring(control)
    .. " control_n=" .. tostring(tonumber(control)))
  if not control_ok or control == nil or tonumber(control) == 0 then
    log_md("HIGH Station plot fail no control station")
    plot_result("fail-control")
    return
  end
  local payee = nil
  if ConvertStringTo64Bit then
    local payee_ok, payee_id = pcall(ConvertStringTo64Bit, tostring(control))
    log_md("LOW Station plot payee_ok=" .. tostring(payee_ok)
      .. " payee=" .. tostring(payee_id)
      .. " from=" .. tostring(control))
    if payee_ok then
      payee = payee_id
    end
  end
  if payee == nil or tonumber(payee) == 0 then
    log_md("HIGH Station plot fail payee")
    plot_result("fail-payee")
    return
  end
  if TransferPlayerMoneyTo then
    local moved_ok, moved_err = pcall(TransferPlayerMoneyTo, price, payee)
    log_md("LOW Station plot transfer_ok=" .. tostring(moved_ok) .. " err=" .. tostring(moved_err))
    if not moved_ok then
      plot_result("fail-transfer")
      return
    end
  else
    log_md("HIGH Station plot fail no TransferPlayerMoneyTo")
    plot_result("fail-transfer")
    return
  end
  local offset_ok, offset = pcall(function()
    return C.GetBuildPlotCenterOffset(station)
  end)
  log_md("LOW Station plot offset_ok=" .. tostring(offset_ok) .. " offset=" .. coord_text(offset_ok and offset or nil))
  if not offset_ok then
    plot_result("fail-offset")
    return
  end
  local size = ffi.new("Coord3D")
  size.x = PLOT_X
  size.y = PLOT_Y
  size.z = PLOT_Z
  local pay_ok, pay_err = pcall(function()
    C.PayBuildPlotSize(station, size, offset)
  end)
  log_md("LOW Station plot pay_ok=" .. tostring(pay_ok) .. " err=" .. tostring(pay_err))
  if not pay_ok then
    plot_result("fail-pay")
    return
  end
  local after_ok, after = pcall(function()
    return C.GetPaidBuildPlotSize(station)
  end)
  local box_ok, box = pcall(function()
    return C.GetBuildPlotSize(station)
  end)
  log_md("LOW Station plot after paid_ok=" .. tostring(after_ok)
    .. " paid=" .. coord_text(after_ok and after or nil)
    .. " box_ok=" .. tostring(box_ok)
    .. " box=" .. coord_text(box_ok and box or nil))
  plot_result("ok")
end

local function force_result(token)
  log_md("HIGH Station force result " .. token)
  if AddUITriggeredEvent then
    AddUITriggeredEvent("CM90Station", "force", token)
  end
end

local function station_counts(station)
  local tail_ok, tail = pcall(function()
    return tonumber(C.GetNumPlannedStationModules(station, false))
  end)
  local all_ok, alln = pcall(function()
    return tonumber(C.GetNumPlannedStationModules(station, true))
  end)
  local built_ok, built = pcall(function()
    return tonumber(C.GetNumStationModules(station, false, false))
  end)
  local constructing = nil
  if IsComponentConstruction then
    local con_ok, con = pcall(IsComponentConstruction, station)
    constructing = con_ok and con or ("err " .. tostring(con))
  end
  return "tail_ok=" .. tostring(tail_ok) .. " tail=" .. tostring(tail)
    .. " all_ok=" .. tostring(all_ok) .. " all=" .. tostring(alln)
    .. " built_ok=" .. tostring(built_ok) .. " built=" .. tostring(built)
    .. " constructing=" .. tostring(constructing)
end

local function on_force(_, obj)
  log_md("LOW Station force raw obj=" .. tostring(obj))
  if not init_ffi() then
    force_result("fail-ffi")
    return
  end
  local station = id_of(obj)
  if not station then
    log_md("HIGH Station force fail no station id")
    force_result("fail-id")
    return
  end
  log_md("LOW Station force before " .. station_counts(station))
  local call_ok, call_err = pcall(function()
    C.ForceBuildCompletion(station)
  end)
  log_md("LOW Station force call_ok=" .. tostring(call_ok) .. " err=" .. tostring(call_err))
  if not call_ok then
    force_result("fail-call")
    return
  end
  log_md("LOW Station force after " .. station_counts(station))
  force_result("ok")
end

local function init()
  debug("HIGH Station lua init")
  if not RegisterEvent then
    debug("HIGH Station RegisterEvent missing")
    return
  end
  RegisterEvent("CheatMenu90.StationPlot", on_plot)
  RegisterEvent("CheatMenu90.StationForce", on_force)
  debug("HIGH Station lua ready")
end

if Register_OnLoad_Init then
  Register_OnLoad_Init(init, "cm90_station")
else
  init()
end
