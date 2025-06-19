local M = {}

local function collect_general_stats(bridge)
  local stats = {}
  stats.total_item_storage = bridge.getTotalItemStorage()
  stats.used_item_storage = bridge.getUsedItemStorage()
  stats.available_item_storage = bridge.getAvailableItemStorage()
  stats.total_fluid_storage = bridge.getTotalFluidStorage()
  stats.used_fluid_storage = bridge.getUsedFluidStorage()
  stats.available_fluid_storage = bridge.getAvailableFluidStorage()
  stats.energy_storage = bridge.getEnergyStorage()
  stats.max_energy_storage = bridge.getMaxEnergyStorage()
  stats.energy_usage = bridge.getEnergyUsage()
  stats.avg_power_injection = bridge.getAvgPowerInjection()
  stats.avg_power_usage = bridge.getAvgPowerUsage()
  return stats
end

local function collect_crafting_cpu_stats(bridge, stats)
  local cpus = bridge.getCraftingCPUs()
  if type(cpus) == "table" then
    local name_count = {}
    for i, cpu in ipairs(cpus) do
      local name = (cpu.name or "unnamed"):lower()
      local base = "crafting_cpu_" .. name
      local field = base
      if stats[field .. "_coprocessors"] then
        local n = name_count[name] or 1
        repeat
          n = n + 1
          field = base .. "_" .. n
        until not stats[field .. "_coprocessors"]
        name_count[name] = n
        base = field
      else
        name_count[name] = 1
      end
      stats[base .. "_coprocessors"] = cpu.coProcessors
      stats[base .. "_busy"] = cpu.isBusy
      stats[base .. "_storage"] = cpu.storage
    end
  end
end

local function extract_queries_from_blockreader(blockreader)
  local ok, blockdata = pcall(function() return blockreader.getBlockData() end)
  if not ok or type(blockdata) ~= "table" or not blockdata.Book or type(blockdata.Book) ~= "table" then
    return nil
  end
  local components = blockdata.Book.components
  if type(components) ~= "table" then return nil end
  local book_content = components["minecraft:writable_book_content"]
  if type(book_content) ~= "table" or type(book_content.pages) ~= "table" then return nil end
  local queries = {}
  for _, page in ipairs(book_content.pages) do
    if type(page) == "table" and type(page.raw) == "string" then
      local page_text = page.raw:sub(3)
      local section_sign = string.char(167)
      for line in page_text:gmatch("[^\r\n]+") do
        -- Remove ALL occurrences of Minecraft formatting codes (section sign + any character)
        local clean_line = line:gsub(section_sign..'.', "")
        -- Now process the cleaned line
        local typ, name = clean_line:match("^(%w+)#(.+)$")
        if typ and name then
          typ = typ:lower()
          if typ == "item" or typ == "fluid" or typ == "gas" then
            table.insert(queries, {type=typ, name=name})
          end
        end
      end
    end
  end
  return queries
end

local function query_item_counts(bridge, item_names, stats)
  for _, item_name in ipairs(item_names) do
    local item = bridge.getItem({name=item_name})
    if type(item) == "table" and type(item.count) == "number" then
      local safe_name = item_name:gsub(":", "_")
      stats["item_count_" .. safe_name] = item.count
    else
      print("Item not found in ME Bridge: " .. item_name)
    end
  end
end

local function query_fluid_counts(bridge, fluid_names, stats)
  local fluids = bridge.listFluids()
  if type(fluids) == "table" then
    local report_all = false
    for _, name in ipairs(fluid_names) do
      if name == "all" then
        report_all = true
        break
      end
    end
    if report_all then
      for _, fluid in pairs(fluids) do
        if type(fluid.name) == "string" and type(fluid.count) == "number" then
          local safe_name = fluid.name:gsub(":", "_")
          stats["fluid_count_" .. safe_name] = fluid.count
        end
      end
    else
      for _, fluid_name in ipairs(fluid_names) do
        local found = false
        for _, fluid in pairs(fluids) do
          if fluid.name == fluid_name then
            local safe_name = fluid_name:gsub(":", "_")
            stats["fluid_count_" .. safe_name] = fluid.count
            found = true
            break
          end
        end
        if not found then
          print("Fluid not found in ME Bridge: " .. fluid_name)
        end
      end
    end
  end
end

local function query_gas_counts(bridge, gas_names, stats)
  local gases = bridge.listGases()
  if type(gases) == "table" then
    for _, gas_name in ipairs(gas_names) do
      local found = false
      for _, gas in pairs(gases) do
        if gas.name == gas_name then
          local safe_name = gas_name:gsub(":", "_")
          stats["gas_count_" .. safe_name] = gas.count
          found = true
          break
        end
      end
      if not found then
        print("Gas not found in ME Bridge: " .. gas_name)
      end
    end
  end
end

local function build_stats(bridge, blockreader)
  local stats = collect_general_stats(bridge)
  collect_crafting_cpu_stats(bridge, stats)
  if blockreader then
    local queries = extract_queries_from_blockreader(blockreader)
    if queries then
      local item_names = {}
      local fluid_names = {}
      local gas_names = {}
      for _, q in ipairs(queries) do
        if q.type == "item" then table.insert(item_names, q.name)
        elseif q.type == "fluid" then table.insert(fluid_names, q.name)
        elseif q.type == "gas" then table.insert(gas_names, q.name)
        end
      end
      if #item_names > 0 then
        query_item_counts(bridge, item_names, stats)
      end
      if #fluid_names > 0 then
        query_fluid_counts(bridge, fluid_names, stats)
      end
      if #gas_names > 0 then
        query_gas_counts(bridge, gas_names, stats)
      end
    end
  end
  return stats
end

function M.collect(peripheral_name, blockreader_name)
  if not peripheral.isPresent(peripheral_name) then
    return nil, "No peripheral found with name: " .. tostring(peripheral_name)
  end
  local bridge = peripheral.wrap(peripheral_name)
  local blockreader = nil
  if blockreader_name then
    if not peripheral.isPresent(blockreader_name) then
      return nil, "No blockReader found with name: " .. tostring(blockreader_name)
    end
    blockreader = peripheral.wrap(blockreader_name)
  end
  local ok, stats_or_err = pcall(build_stats, bridge, blockreader)
  if not ok then
    return nil, "Error collecting me_bridge stats: " .. tostring(stats_or_err)
  end
  return stats_or_err, nil
end

return M
