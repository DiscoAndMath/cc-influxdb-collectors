local collectors = {}

-- Big Reactor Collector

collectors.bigreactor = function(peripheral_name)

  local function build_stats(reactor)
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

  return {
    collect = function()
      if not peripheral.isPresent(peripheral_name) then
        return nil, "No peripheral found with name: " .. tostring(peripheral_name)
      end
      local reactor = peripheral.wrap(peripheral_name)
      local ok, stats_or_err = pcall(build_stats, reactor)
      if not ok then
        return nil, "Error collecting reactor stats: " .. tostring(stats_or_err)
      end
      return stats_or_err, nil
    end
  }
end

collectors.inductionport = function(peripheral_name)

  local function build_stats(port)
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

  return {
    collect = function()
      if not peripheral.isPresent(peripheral_name) then
        return nil, "No peripheral found with name: " .. tostring(peripheral_name)
      end
      local port = peripheral.wrap(peripheral_name)
      local ok, stats_or_err = pcall(build_stats, port)
      if not ok then
        return nil, "Error collecting inductionport stats: " .. tostring(stats_or_err)
      end
      return stats_or_err, nil
    end
  }
end

collectors.mek_fission = function(peripheral_name)
  local function build_stats(reactor)
    local stats = {}
    stats.height = reactor.getHeight()
    stats.width = reactor.getWidth()
    stats.logic_mode = reactor.getLogicMode()
    stats.fuel_needed = reactor.getFuelNeeded()
    stats.environmental_loss = reactor.getEnvironmentalLoss()
    stats.heated_coolant = reactor.getHeatedCoolant()
    stats.fuel_filled_percentage = reactor.getFuelFilledPercentage()
    stats.waste = reactor.getWaste()
    stats.redstone_mode = reactor.getRedstoneMode()
    stats.max_pos = reactor.getMaxPos()
    stats.actual_burn_rate = reactor.getActualBurnRate()
    stats.is_formed = reactor.isFormed()
    stats.heating_rate = reactor.getHeatingRate()
    stats.is_force_disabled = reactor.isForceDisabled()
    stats.heat_capacity = reactor.getHeatCapacity()
    stats.waste_capacity = reactor.getWasteCapacity()
    stats.burn_rate = reactor.getBurnRate()
    stats.min_pos = reactor.getMinPos()
    stats.coolant_capacity = reactor.getCoolantCapacity()
    stats.waste_needed = reactor.getWasteNeeded()
    stats.fuel = reactor.getFuel()
    stats.fuel_assemblies = reactor.getFuelAssemblies()
    stats.coolant_filled_percentage = reactor.getCoolantFilledPercentage()
    stats.coolant_needed = reactor.getCoolantNeeded()
    stats.heated_coolant_filled_percentage = reactor.getHeatedCoolantFilledPercentage()
    stats.width = reactor.getWidth()
    stats.heated_coolant_needed = reactor.getHeatedCoolantNeeded()
    stats.temperature = reactor.getTemperature()
    stats.length = reactor.getLength()
    stats.heated_coolant_capacity = reactor.getHeatedCoolantCapacity()
    stats.fuel_surface_area = reactor.getFuelSurfaceArea()
    stats.max_burn_rate = reactor.getMaxBurnRate()
    stats.redstone_logic_status = reactor.getRedstoneLogicStatus()
    stats.damage_percent = reactor.getDamagePercent()
    stats.height = reactor.getHeight()
    stats.burn_rate = reactor.getBurnRate()
    stats.boil_efficiency = reactor.getBoilEfficiency()
    stats.waste_filled_percentage = reactor.getWasteFilledPercentage()
    stats.status = reactor.getStatus()
    stats.fuel_capacity = reactor.getFuelCapacity()
    stats.coolant = reactor.getCoolant()
    return stats
  end

  return {
    collect = function()
      if not peripheral.isPresent(peripheral_name) then
        return nil, "No peripheral found with name: " .. tostring(peripheral_name)
      end
      local port = peripheral.wrap(peripheral_name)
      local ok, stats_or_err = pcall(build_stats, port)
      if not ok then
        return nil, "Error collecting fission reactor stats: " .. tostring(stats_or_err)
      end
      return stats_or_err, nil
    end
  }
end

local me_bridge_collector = require("me_bridge_collector")
collectors.me_bridge = function(peripheral_name, blockreader_name)
  return {
    collect = function()
      return me_bridge_collector.collect(peripheral_name, blockreader_name)
    end
  }
end

return collectors
