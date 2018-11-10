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
        end

        panel id: :main_panel do
          boxSizer id: :outer_sizer, orient: @wxHORIZONTAL do
            layout1 = [proportion: 1, flag: @wxEXPAND ||| @wxALL, border: 5]

            listCtrl id: :list_ctrl, layout: layout1 do
              listCtrlCol(col: 0, heading: "Pid")
              listCtrlCol(col: 1, heading: "Name")
              listCtrlCol(col: 2, heading: "Status")
              listCtrlCol(col: 3, heading: "Heap Size", format: @wxLIST_FORMAT_RIGHT)
              listCtrlCol(col: 4, heading: "Memeory Size", format: @wxLIST_FORMAT_RIGHT)
              listCtrlCol(col: 5, heading: "Msg Queue", format: @wxLIST_FORMAT_RIGHT)
              listCtrlCol(col: 6, heading: "Stack", format: @wxLIST_FORMAT_RIGHT)
              listCtrlCol(col: 7, heading: "Reductions", format: @wxLIST_FORMAT_RIGHT)
            end
          end
        end

        statusBar(text: "--")
      end

      events(
        close_window: [],
        command_menu_selected: [handler: &WxTopWindowLogic.commandMenuSelected/4]
      )
    end
  end
end
