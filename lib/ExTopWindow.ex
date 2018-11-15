defmodule ExTopWindow do
  use WxDsl
  import WxDefines

  def createWindow(show) do
    mainWindow name: :elixir_top_window, show: show, setFocus: true do
      # Create a simple frame.
      frame id: :main_frame,
            title: "Elixir Top",
            size: {900, 600},
            pos: {200, 100} do
        menuBar do
          menu id: :file_menu, text: "&File" do
            menuSeparator()
            menuItem(id: :exit, text: "&Exit")
          end

          menu id: :sort, text: "&Sort On" do
            menuRadioItem(id: :pid, text: "&Pid")
            menuRadioItem(id: :name, text: "&Name")
            menuRadioItem(id: :status, text: "&Status")
            menuRadioItem(id: :heap, text: "&Heap")
            menuRadioItem(id: :memory, text: "&Memory")
            menuRadioItem(id: :queue, text: "&Queue")
            menuRadioItem(id: :stack, text: "&Stack")
            menuRadioItem(id: :reductions, text: "&Reductions")
            menuSeparator()
            menuRadioItem(id: :decending, text: "&Descending")
            menuRadioItem(id: :ascending, text: "&Ascending")
          end

          events(command_menu_selected: [])
        end

        panel id: :main_panel do
          boxSizer id: :outer_sizer, orient: @wxHORIZONTAL do
            layout1 = [proportion: 1, flag: @wxEXPAND ||| @wxALL, border: 5]

            report id: :report, layout: layout1 do
              reportCol(col: 0, heading: "Pid")
              reportCol(col: 1, heading: "Name")
              reportCol(col: 2, heading: "Status")
              reportCol(col: 3, heading: "Heap Size", format: @wxLIST_FORMAT_RIGHT)
              reportCol(col: 4, heading: "Memeory Size", format: @wxLIST_FORMAT_RIGHT)
              reportCol(col: 5, heading: "Msg Queue", format: @wxLIST_FORMAT_RIGHT)
              reportCol(col: 6, heading: "Stack", format: @wxLIST_FORMAT_RIGHT)
              reportCol(col: 7, heading: "Reductions", format: @wxLIST_FORMAT_RIGHT)
              events(command_list_col_click: [])
            end
          end
        end

        statusBar(text: "--")

        events(
          close_window: []
          # command_menu_selected: [handler: &WxTopWindowLogic.commandMenuSelected/4]
          # command_list_col_click: []
        )
      end
    end
  end
end
