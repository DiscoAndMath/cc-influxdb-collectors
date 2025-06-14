-- collectors.lua
-- Provides modular collectors for various peripherals, returning a collect() function for each.

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

return collectors
