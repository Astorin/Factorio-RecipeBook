local util = require("scripts.util")

local mining_drill_proc = {}

function mining_drill_proc.build(database, dictionaries)
  for name, prototype in pairs(global.prototypes.mining_drill) do
    for category in pairs(prototype.resource_categories) do
      local category_data = database.resource_category[category]
      category_data.mining_drills[#category_data.mining_drills + 1] = { class = "entity", name = name }
    end

    database.entity[name] = {
      blueprintable = util.is_blueprintable(prototype),
      can_burn = {},
      class = "entity",
      enabled = true,
      entity_type = { class = "entity_type", name = prototype.type },
      fuel_categories = util.process_energy_source(prototype),
      mining_area = math.ceil(prototype.mining_drill_radius * 2),
      mining_speed = prototype.mining_speed,
      placed_by = util.process_placed_by(prototype),
      prototype_name = name,
      resource_categories_lookup = prototype.resource_categories,
      resource_categories = util.convert_categories(prototype.resource_categories, "resource_category"),
      science_packs = {},
      size = util.get_size(prototype),
      supports_fluid = #prototype.fluidbox_prototypes > 0,
      unlocked_by = {},
    }
    dictionaries.entity:add(name, prototype.localised_name)
    dictionaries.entity_description:add(name, prototype.localised_description)
  end
end

function mining_drill_proc.add_resources(database)
  for name in pairs(global.prototypes.mining_drill) do
    local drill_data = database.entity[name]
    local can_mine = util.unique_obj_array()
    for category in pairs(drill_data.resource_categories_lookup) do
      local category_data = database.resource_category[category]
      for _, resource_ident in pairs(category_data.resources) do
        local resource_data = database.resource[resource_ident.name]
        if not resource_data.required_fluid or drill_data.supports_fluid then
          can_mine[#can_mine + 1] = resource_ident
        end
      end
    end
    drill_data.can_mine = can_mine
  end
end

-- When calling the module directly, call fluid_proc.build
setmetatable(mining_drill_proc, {
  __call = function(_, ...)
    return mining_drill_proc.build(...)
  end,
})

return mining_drill_proc
