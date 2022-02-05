local gui = require("__flib__.gui")

local formatter = require("scripts.formatter")
local recipe_book = require("scripts.recipe-book")
local util = require("scripts.util")

--- @class VisualSearchGuiRefs
--- @field window LuaGuiElement
--- @field titlebar_flow LuaGuiElement
--- @field group_table LuaGuiElement
--- @field items_frame LuaGuiElement

--- @class VisualSearchGui
local Gui = {}
local actions = require("scripts.gui.visual-search.actions")

function Gui:dispatch(msg, e)
  if type(msg) == "string" then
    actions[msg](self, msg, e)
  else
    actions[msg.action](self, msg, e)
  end
end

function Gui:destroy()
  self.refs.window.destroy()
end

local index = {}

--- @param player LuaPlayer
--- @param player_table PlayerTable
function index.build(player, player_table)
  local player_data = formatter.build_player_data(player, player_table)
  -- The items will actually be iterated in prototype order!
  local group_buttons = {}
  local groups_scroll_panes = {}
  local current_group, current_subgroup
  local current_group_table, current_subgroup_table
  local first_group
  --- @type table<string, ItemData>
  local items = recipe_book.item
  for name, item in pairs(items) do
    local data = formatter(item, player_data, { is_visual_search_result = true })
    if data then
      -- Cycle group and subgroup if necessary
      if item.group.name ~= current_group then
        if current_group and #current_group > 0 then
          local is_selected = current_group == first_group
          table.insert(group_buttons, {
            type = "sprite-button",
            name = current_group,
            style = is_selected and "rb_selected_filter_group_button_tab" or "rb_filter_group_button_tab",
            sprite = "item-group/" .. current_group,
            tooltip = { "item-group-name." .. current_group },
            enabled = not is_selected,
            actions = {
              on_click = { gui = "visual_search", action = "change_group", group = current_group },
            },
          })
        elseif not current_group then
          first_group = item.group.name
        end
        current_group = item.group.name
        current_group_table = {
          type = "scroll-pane",
          name = current_group,
          style = "rb_filter_scroll_pane",
          visible = #groups_scroll_panes == 0,
          vertical_scroll_policy = "always",
        }
        table.insert(groups_scroll_panes, current_group_table)
      end
      if item.subgroup ~= current_subgroup then
        current_subgroup = item.subgroup
        current_subgroup_table = { type = "table", style = "slot_table", column_count = 10 }
        table.insert(current_group_table, current_subgroup_table)
      end
      -- Create the button
      table.insert(current_subgroup_table, {
        type = "sprite-button",
        style = "flib_slot_button_" .. (data.researched and "default" or "red"),
        sprite = "item/" .. name,
        tooltip = data.tooltip,
        actions = {
          on_click = { gui = "visual_search", action = "open_object", context = { class = "item", name = name } },
        },
      })
    end
  end
  if current_group and #current_group > 0 then
    local is_selected = current_group == first_group
    table.insert(group_buttons, {
      type = "sprite-button",
      name = current_group,
      style = is_selected and "rb_selected_filter_group_button_tab" or "rb_filter_group_button_tab",
      sprite = "item-group/" .. current_group,
      tooltip = { "item-group-name." .. current_group },
      enabled = not is_selected,
      actions = {
        on_click = { gui = "visual_search", action = "change_group", group = current_group },
      },
    })
  end

  --- @type VisualSearchGuiRefs
  local refs = gui.build(player.gui.screen, {
    {
      type = "frame",
      direction = "vertical",
      ref = { "window" },
      {
        type = "flow",
        style = "flib_titlebar_flow",
        ref = { "titlebar_flow" },
        { type = "label", style = "frame_title", caption = { "gui.rb-search-title" }, ignored_by_interaction = true },
        { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
        util.frame_action_button("utility/close", { "gui.close-instruction" }, { "close_button" }),
      },
      {
        type = "frame",
        style = "inside_deep_frame",
        direction = "vertical",
        {
          type = "frame",
          style = "subheader_frame",
          { type = "textfield" },
          { type = "empty-widget", style = "flib_horizontal_pusher" },
          { type = "sprite-button", style = "tool_button" },
        },
        {
          type = "table",
          style = "filter_group_table",
          style_mods = { width = 426 },
          column_count = 6,
          ref = { "group_table" },
          children = group_buttons,
        },
        {
          type = "frame",
          style = "rb_filter_frame",
          {
            type = "frame",
            style = "deep_frame_in_shallow_frame",
            style_mods = { height = 40 * 15, natural_width = 40 * 10 },
            ref = { "items_frame" },
            children = groups_scroll_panes,
          },
        },
      },
    },
  })

  refs.titlebar_flow.drag_target = refs.window
  refs.window.force_auto_center()

  --- @type VisualSearchGui
  local self = {
    player = player,
    player_table = player_table,
    refs = refs,
    state = {
      active_group = first_group,
    },
  }
  index.load(self)
  player_table.guis.visual_search = self
end

function index.load(self)
  setmetatable(self, { __index = Gui })
end

return index
