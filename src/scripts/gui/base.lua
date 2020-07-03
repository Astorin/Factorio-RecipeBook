local base_gui = {}

local gui = require("__flib__.gui")

local constants = require("constants")

gui.add_templates{
  frame_action_button = {type="sprite-button", style="frame_action_button", mouse_button_filter={"left"}},
  pushers = {
    horizontal = {type="empty-widget", style="flib_horizontal_pusher"},
    vertical = {type="empty-widget", style="flib_vertical_pusher"}
  },
  tool_button = {type="sprite-button", style="tool_button", mouse_button_filter={"left"}},
  --! DEBUGGING
  dummy_content_listbox = function(caption, rows)
    return {type="flow", direction="vertical", children={
      {type="label", style="bold_label", style_mods={bottom_margin=2}, caption=caption},
      {type="frame", style="deep_frame_in_shallow_frame", children={
        {type="scroll-pane", style="rb_list_box_scroll_pane", style_mods={width=400, height=(rows * 28)}, children=gui.templates.dummy_search_contents()}
      }}
    }}
  end,
  dummy_search_contents = function()
    local children = {}
    local i = 0;
    for _, caption in ipairs{
      "[item=iron-plate]  Iron plate (Item)",
      "[fluid=water]  Water (Fluid)",
      "[recipe=advanced-oil-processing]  Advanced oil processing",
      "Loooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooongboi"
    } do
      for _ = 1, 10 do
        i = i + 1
        children[i] = {type="button", style="rb_list_box_item", caption=caption, tooltip=
          "[recipe=advanced-oil-processing]  [font=default-bold][color=255, 230, 192]Advanced oil processing (Recipe)[/color][/font]\n"
          .."[font=default-bold]Ingredients:[/font]\n"
          .."[fluid=water]  50x Water\n"
          .."[fluid=crude-oil]  100x Crude oil\n"
          .."[font=default-bold]Products:[/font]\n"
          .."[fluid=heavy-oil]  25x Heavy oil\n"
          .."[fluid=light-oil]  45x Light oil\n"
          .."[fluid=petroleum-gas]  55x Petroleum gas"
        }
      end
    end
    return children
  end
}

gui.add_handlers{
  base = {
    close_button = {
      on_gui_click = function(e)
        base_gui.close(game.get_player(e.player_index), global.players[e.player_index])
      end
    },
    pin_button = {
      on_gui_click = function(e)
        local player = game.get_player(e.player_index)
        local player_table = global.players[e.player_index]
        local gui_data = player_table.gui.base
        if gui_data.window.pinned then
          gui_data.titlebar.pin_button.style = "frame_action_button"
          gui_data.window.pinned = false
          gui_data.window.frame.force_auto_center()
          player.opened = gui_data.window.frame
        else
          gui_data.titlebar.pin_button.style = "rb_selected_frame_action_button"
          gui_data.window.pinned = true
          gui_data.window.frame.auto_center = false
          player.opened = nil

        end
      end
    },
    settings_button = {
      on_gui_click = function(e)

      end
    },
    window = {
      on_gui_closed = function(e)
        local player_table = global.players[e.player_index]
        if not player_table.gui.base.window.pinned then
          gui.handlers.base.close_button.on_gui_click(e)
        end
      end
    }
  }
}

function base_gui.create(player, player_table)
  local elems = gui.build(player.gui.screen, {
    {type="frame", direction="vertical", elem_mods={visible=false}, handlers="base.window", save_as="window.frame", children={
      {type="flow", save_as="titlebar.flow", children={
        {template="frame_action_button", sprite="rb_nav_backward_white", hovered_sprite="rb_nav_backward_black", clicked_sprite="rb_nav_backward_black",
          elem_mods={enabled=false}},
        {template="frame_action_button", sprite="rb_nav_forward_white", hovered_sprite="rb_nav_forward_black", clicked_sprite="rb_nav_forward_black",
          elem_mods={enabled=false}},
        {type="empty-widget"},
        {type="label", style="frame_title", caption={"mod-name.RecipeBook"}, elem_mods={ignored_by_interaction=true}},
        {type="empty-widget", style="rb_drag_handle", elem_mods={ignored_by_interaction=true}},
        {template="frame_action_button", tooltip={"rb-gui.keep-open"}, sprite="rb_pin_white", hovered_sprite="rb_pin_black", clicked_sprite="rb_pin_black",
          handlers="base.pin_button", save_as="titlebar.pin_button"},
        {template="frame_action_button", tooltip={"rb-gui.settings"}, sprite="rb_settings_white", hovered_sprite="rb_settings_black",
          clicked_sprite="rb_settings_black", handlers="base.settings_button", save_as="titlebar.settings_button"},
        {template="frame_action_button", sprite="utility/close_white", hovered_sprite="utility/close_black", clicked_sprite="utility/close_black",
          handlers="base.close_button"}
      }},
      {type="flow", style_mods={horizontal_spacing=12}, children={
        -- search pane
        {type="frame", style="inside_shallow_frame", direction="vertical", children={
          {type="frame", style="subheader_frame", children={
            {type="label", style="subheader_caption_label", caption={"rb-gui.search-by"}},
            {template="pushers.horizontal"},
            {type="drop-down", items=constants.search_categories, selected_index=2}
          }},
          {type="flow", style_mods={padding=12, top_padding=8, right_padding=0, vertical_spacing=10}, direction="vertical", children={
            {type="textfield", style_mods={width=250, right_margin=12}},
            {type="frame", style="deep_frame_in_shallow_frame", style_mods={width=250, height=392}, direction="vertical", children={
              -- {type="frame", style="subheader_frame", style_mods={height=28, horizontally_stretchable=true}, children={
              --   {type="label", style="bold_label", style_mods={left_margin=4}, caption="<"},
              --   {template="pushers.horizontal"},
              --   {type="label", style="bold_label", style_mods={left_margin=4}, caption="1-50  /  263"},
              --   {template="pushers.horizontal"},
              --   {type="label", style="bold_label", style_mods={right_margin=4}, caption=">"},
              -- }},
              {type="scroll-pane", style="rb_list_box_scroll_pane", style_mods={horizontally_stretchable=true, vertically_stretchable=true},
                children=gui.templates.dummy_search_contents()}
            }}
          }}
        }},
        -- info pane
        {type="frame", style="inside_shallow_frame", style_mods={height=486}, direction="vertical", children={
          -- {type="frame", style="subheader_frame", children={
          --   {type="label", style="subheader_caption_label", caption="[recipe=chemical-plant]  Chemical Plant"},
          --   {template="pushers.horizontal"},
          --   -- {template="tool_button"},
          --   {template="tool_button", sprite="rb_favorite_black"}
          -- }},
          {type="scroll-pane", style="rb_info_scroll_pane", vertical_scroll_policy="auto-and-reserve-space", children={
            gui.templates.dummy_content_listbox("Favorites", 7),
            {template="pushers.vertical"},
            gui.templates.dummy_content_listbox("History", 7)
          }}
        }}
      }}
    }}
  })

  elems.window.frame.force_auto_center()
  elems.titlebar.flow.drag_target = elems.window.frame

  elems.window.pinned = false

  player_table.gui.base = elems
end

function base_gui.destroy(player, player_table)

end

function base_gui.open(player, player_table)
  local window = player_table.gui.base.window.frame
  if window and window.valid then
    window.visible = true
  end
  player_table.flags.gui_open = true
  if not player_table.gui.base.pinned then
    player.opened = window
  end
  player.set_shortcut_toggled("rb-toggle-gui", true)
end

function base_gui.close(player, player_table)
  local window = player_table.gui.base.window.frame
  if window and window.valid then
    window.visible = false
  end
  player_table.flags.gui_open = false
  player.opened = nil
  player.set_shortcut_toggled("rb-toggle-gui", false)
end

function base_gui.toggle(player, player_table)
  if player_table.flags.gui_open then
    base_gui.close(player, player_table)
  else
    base_gui.open(player, player_table)
  end
end

function base_gui.update_state(player, player_table, state_changes)

end

return base_gui