-- Cheat Menu 9.0: dump catalog log to a text file the player can copy.
-- Tries userdata (Documents/Egosoft/X4/<id>/) then the extension folder.

local buffer = {}

local function debug(msg)
  if DebugError then
    DebugError("[CM90] " .. tostring(msg))
  end
end

local function try_io_write(path, body)
  if not io or not io.open then
    return false, "io.open unavailable"
  end
  local f, err = io.open(path, "w")
  if not f then
    return false, tostring(err)
  end
  f:write(body)
  f:close()
  return true
end

local function try_ffi_write(path, body)
  local ok, ffi = pcall(require, "ffi")
  if not ok or not ffi then
    return false, "ffi unavailable"
  end
  pcall(function()
    ffi.cdef[[
      typedef struct FILE FILE;
      FILE* fopen(const char* filename, const char* mode);
      int fputs(const char* str, FILE* stream);
      int fclose(FILE* stream);
    ]]
  end)
  local wrote, err = pcall(function()
    local file = ffi.C.fopen(path, "w")
    if file == nil then
      error("fopen failed")
    end
    ffi.C.fputs(body, file)
    ffi.C.fclose(file)
  end)
  if not wrote then
    return false, tostring(err)
  end
  return true
end

local function userdata_dir()
  local ok, ffi = pcall(require, "ffi")
  if ok and ffi then
    pcall(function()
      ffi.cdef[[ const char* GetUserDataPath(); ]]
    end)
    local ok2, path = pcall(function()
      return ffi.string(ffi.C.GetUserDataPath())
    end)
    if ok2 and path and path ~= "" then
      return path
    end
  end
  return nil
end

local function dump_body()
  local lines = {
    "Cheat Menu 9.0 catalog log",
    "written=" .. tostring(os and os.date and os.date() or "unknown-time"),
    "lines=" .. tostring(#buffer),
    "-----"
  }
  for i = 1, #buffer do
    table.insert(lines, tostring(buffer[i]))
  end
  return table.concat(lines, "\n") .. "\n"
end

local function write_path(path)
  debug("lua try io path=" .. path)
  table.insert(buffer, "LUA layer: try io path=" .. path)
  body = dump_body()
  local ok, err = try_io_write(path, body)
  if ok then
    return true, "io"
  end
  debug("lua io fail path=" .. path .. " err=" .. tostring(err))
  table.insert(buffer, "LUA layer: io fail path=" .. path .. " err=" .. tostring(err))
  debug("lua try ffi path=" .. path)
  table.insert(buffer, "LUA layer: try ffi path=" .. path)
  body = dump_body()
  ok, err = try_ffi_write(path, body)
  if ok then
    return true, "ffi"
  end
  debug("lua ffi fail path=" .. path .. " err=" .. tostring(err))
  table.insert(buffer, "LUA layer: ffi fail path=" .. path .. " err=" .. tostring(err))
  return false, tostring(err)
end

local function write_file()
  local candidates = {}
  local userdir = userdata_dir()
  debug("lua userdata_dir=" .. tostring(userdir))
  table.insert(buffer, "LUA layer: userdata_dir=" .. tostring(userdir))
  if userdir then
    local sep = string.sub(userdir, -1)
    if sep ~= "/" and sep ~= "\\" then
      userdir = userdir .. "/"
    end
    table.insert(candidates, userdir .. "cm90_cheat_log.txt")
  end
  table.insert(candidates, "extensions/CheatMenu/ui/cm90_cheat_log.txt")
  table.insert(candidates, "extensions/CheatMenu/cm90_cheat_log.txt")
  table.insert(candidates, "cm90_cheat_log.txt")

  local written = nil
  local errors = {}
  for i = 1, #candidates do
    local path = candidates[i]
    local ok, how = write_path(path)
    if ok then
      written = path
      table.insert(buffer, "LUA layer: wrote via=" .. tostring(how) .. " path=" .. path)
      debug("lua wrote via=" .. tostring(how) .. " path=" .. path)
      write_path(path)
      break
    end
    table.insert(errors, path .. " => " .. tostring(how))
  end

  if written then
    debug("log file: " .. written)
    if AddUITriggeredEvent then
      AddUITriggeredEvent("CM90Log", "file", written)
    end
  else
    local msg = "log file FAILED: " .. table.concat(errors, " | ")
    table.insert(buffer, "LUA layer: " .. msg)
    debug(msg)
    if AddUITriggeredEvent then
      AddUITriggeredEvent("CM90Log", "file", msg)
    end
  end
end

local function race_from_id(id)
  local s = tostring(id or "")
  local code = s:match("ship_([%a%d]+)_")
  return code or "?"
end

local function annotate_line(line)
  line = tostring(line or "")
  local id = line:match("id=(ship_[%w_]+)")
  if id then
    line = line .. " luaRace=" .. race_from_id(id)
  end
  return line
end

local function on_line(_, line)
  table.insert(buffer, annotate_line(line))
end

local function on_write()
  table.insert(buffer, "LUA layer: write start buffered=" .. tostring(#buffer))
  debug("lua write start buffered=" .. tostring(#buffer))
  write_file()
end

local function on_clear()
  buffer = {}
  table.insert(buffer, "LUA layer: buffer cleared")
  debug("lua buffer cleared")
end

local function init()
  debug("lua init start")
  if not RegisterEvent then
    debug("RegisterEvent missing")
    return
  end
  RegisterEvent("CheatMenu90.LogClear", on_clear)
  RegisterEvent("CheatMenu90.LogLine", on_line)
  RegisterEvent("CheatMenu90.LogWrite", on_write)
  debug("lua log writer ready")
end

if Register_OnLoad_Init then
  Register_OnLoad_Init(init, "cm90_log")
else
  init()
end
