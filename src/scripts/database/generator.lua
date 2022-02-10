local util = require("scripts.util")

return function(database, dictionaries)
  for name, prototype in pairs(global.prototypes.generator) do
    local fluid_box = prototype.fluidbox_prototypes[1]
    local can_burn = {}
    local fuel_categories = {}
    if fluid_box.filter then
      can_burn = { { class = "fluid", name = fluid_box.filter.name } }
    else
      fuel_categories = { { class = "fuel_category", name = "burnable-fluid" } }
    end

    database.generator[name] = {
      base_pollution = prototype.emissions_per_second > 0 and prototype.emissions_per_second or nil,
      can_burn = can_burn,
      class = "generator",
      fluid_consumption = prototype.fluid_usage_per_tick * 60,
      fuel_categories = fuel_categories,
      max_energy_production = prototype.max_energy_production,
      maximum_temperature = prototype.maximum_temperature,
      minimum_temperature = fluid_box.minimum_temperature,
      placed_by = util.process_placed_by(prototype),
      prototype_name = name,
      unlocked_by = {},
    }

    dictionaries.generator:add(name, prototype.localised_name)
    dictionaries.generator_description:add(name, prototype.localised_description)
  end
end