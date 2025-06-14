local collectors = {}

-- Big Reactor Collector

collectors.bigreactor = function(peripheral_name)
  local reactor = peripheral.wrap(peripheral_name)
  if not reactor then
    error("No peripheral found with name: " .. tostring(peripheral_name))
  end
  return {
    collect = function()
      local stats = {}

      -- Direct values
      stats.casing_temperature = reactor.getCasingTemperature()
      stats.active = reactor.getActive()
      stats.number_of_control_rods = reactor.getNumberOfControlRods()

      -- Control rod levels as individual stats
      local levels = reactor.getControlRodsLevels and reactor.getControlRodsLevels()
      if type(levels) == "table" then
        for i, v in ipairs(levels) do
          stats["control_rod_level_" .. i] = v
        end
      end

      -- Fuel stats
      local fuel = reactor.getFuelStats and reactor.getFuelStats()
      if type(fuel) == "table" then
        stats.fuel_temperature = fuel.fuelTemperature
        stats.fuel_amount = fuel.fuelAmount
        stats.fuel_capacity = fuel.fuelCapacity
        stats.waste_amount = fuel.wasteAmount
        stats.fuel_consumed_last_tick = fuel.fuelConsumedLastTick
        stats.fuel_reactivity = fuel.fuelReactivity
      end

      -- Energy stats
      local energy = reactor.getEnergyStats and reactor.getEnergyStats()
      if type(energy) == "table" then
        stats.energy_stored = energy.energyStored
        stats.energy_produced_last_tick = energy.energyProducedLastTick
        stats.energy_capacity = energy.energyCapacity
        stats.energy_system = energy.energySystem
      end

      -- Hot fluid stats
      local hot = reactor.getHotFluidStats and reactor.getHotFluidStats()
      if type(hot) == "table" then
        stats.hot_fluid_produced_last_tick = hot.fluidProducedLastTick
        stats.hot_fluid_amount = hot.fluidAmount
        stats.hot_fluid_capacity = hot.fluidCapacity
      end

      -- Coolant fluid stats
      local coolant = reactor.getCoolantFluidStats and reactor.getCoolantFluidStats()
      if type(coolant) == "table" then
        stats.coolant_fluid_amount = coolant.fluidAmount
        stats.coolant_fluid_capacity = coolant.fluidCapacity
      end

      return stats
    end
  }
end

collectors.inductionport = function(peripheral_name)
  local port = peripheral.wrap(peripheral_name)
  if not port then
    error("No peripheral found with name: " .. tostring(peripheral_name))
  end
  return {
    collect = function()
      local stats = {}

      stats.max_energy = port.getMaxEnergy()
      stats.energy_filled_percentage = port.getEnergyFilledPercentage()
      stats.last_input = port.getLastInput()
      stats.energy_needed = port.getEnergyNeeded()
      stats.height = port.getHeight()
      stats.installed_cells = port.getInstalledCells()
      stats.installed_providers = port.getInstalledProviders()
      stats.energy = port.getEnergy()
      stats.mode = port.getMode()
      stats.width = port.getWidth()
      stats.transfer_cap = port.getTransferCap()

      return stats
    end
  }
end

collectors.me_bridge = function(peripheral_name)
  local bridge = peripheral.wrap(peripheral_name)
  if not bridge then
    error("No peripheral found with name: " .. tostring(peripheral_name))
  end
  return {
    collect = function()
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

      -- Crafting CPUs
      -- For each CPU, the following fields are created:
      --   crafting_cpu_<name>[_n]_coprocessors: Number of coprocessors in the CPU
      --   crafting_cpu_<name>[_n]_busy: Whether the CPU is currently busy
      --   crafting_cpu_<name>[_n]_storage: Storage in bytes for the CPU
      -- If multiple CPUs have the same name, a numeric suffix (_2, _3, etc.) is added to ensure uniqueness.
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
      return stats
    end
  }
end

return collectors
