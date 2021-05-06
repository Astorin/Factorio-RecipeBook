local area = require("__flib__.area")
local gui = require("__flib__.gui-beta")

local constants = require("constants")
local formatter = require("scripts.formatter")
local util = require("scripts.util")

local list_box = {}

function list_box.build(parent, index, component)
  return gui.build(parent, {
    {type = "flow", direction = "vertical", index = index, ref = {"flow"},
      {
        type = "label",
        style = "rb_list_box_label",
        ref = {"label"}
      },
      {type = "frame", style = "deep_frame_in_shallow_frame", ref = {"frame"},
        {
          type = "scroll-pane",
          style = "rb_list_box_scroll_pane",
          -- TODO: Make a constant
          style_mods = {maximal_height = ((component.max_rows or 8) * 28)},
          ref = {"scroll_pane"}
        }
      }
    }
  })
end

function list_box.update(component, refs, objects, player_data, variables)
  -- TODO: Why is this needed?
  objects = objects or {}

  local recipe_book = global.recipe_book

  -- Scroll pane
  local scroll = refs.scroll_pane
  local add = scroll.add
  local children = scroll.children

  -- Settings and variables
  local always_show = component.always_show
  local context = variables.context
  local blueprint_recipe = context.class == "recipe" and component.source == "made_in" and context.name or nil
  local search_query = variables.search_query

  -- Add items
  local i = 0
  for _, obj in pairs(objects) do
    -- Match against search string
    -- TODO: Sanitize in event handler, and get rid of the plaintext switch
    local translation = player_data.translations[obj.class][obj.name]
    if string.find(string.lower(translation), search_query, 1, true) then
      local obj_data = recipe_book[obj.class][obj.name]
      local info = formatter(
        obj_data,
        player_data,
        {
          always_show = always_show,
          amount_string = obj.amount_string,
          blueprint_recipe = blueprint_recipe
        }
      )

      if info then
        i = i + 1
        local style = info.is_researched and "rb_list_box_item" or "rb_unresearched_list_box_item"
        -- TODO:
        -- if highlight_last_selected
        --   and obj.class == last_context.class
        --   and (obj.name == last_context.name or obj_data.prototype_name == last_context.name)
        -- then
        --   style = "rb_last_selected_list_box_item"
        -- else
        -- end
        local item = children[i]
        if item then
          item.style = style
          item.caption = info.caption
          item.tooltip = info.tooltip
          item.enabled = info.is_enabled
          gui.update_tags(item, {obj = {class = obj.class, name = obj.name}})
        else
          add{
            type = "button",
            style = style,
            caption = info.caption,
            tooltip = info.tooltip,
            enabled = info.is_enabled,
            mouse_button_filter = {"left", "middle"},
            tags = {
              [script.mod_name] = {
                blueprint_recipe = blueprint_recipe,
                flib = {
                  on_click = {gui = "info", id = variables.gui_id, action = "navigate_to"}
                },
                obj = {class = obj.class, name = obj.name}
              }
            }
          }
        end
      end
    end
  end
  -- Destroy extraneous items
  for j = i + 1, #children do
    children[j].destroy()
  end

  -- Set listbox properties
  if i > 0 then
    refs.flow.visible = true
    -- Update label caption
    refs.label.caption = {"gui.rb-list-box-"..string.gsub(component.source, "_", "-"), i}
  else
    refs.flow.visible = false
  end
end

return list_box
