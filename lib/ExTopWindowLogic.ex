defmodule WxTopWindowLogic do
  require Logger
  use WxDefines

  def init({action, state}) do
    display()
    {action, state, 1000}
  end

  def display() do
    {sortCol, how} = getSettings()
    # Logger.info("display(#{inspect(sortCol)}, #{inspect(how)})")
    {_, _, listCtrl} = WinInfo.get_by_name(:list_ctrl)

    procData = getProcessData(sortCol, how)

    :wxWindow.freeze(listCtrl)
    addProcsToCtrl(listCtrl, procData)
    :wxWindow.thaw(listCtrl)

    :timer.sleep(1000)
  end

  # Get an array containing the process data
  def getProcessData(sortBy, how) do
    procData = getData(:erlang.processes(), [])

    case how do
      :asc -> Enum.sort(procData, &(&1[sortBy] <= &2[sortBy]))
      :dsc -> Enum.sort(procData, &(&1[sortBy] >= &2[sortBy]))
    end
  end

  def getData([], procData) do
    Enum.reverse(procData)
  end

  def getData([pid | rest], procData) do
    data =
      :erlang.process_info(pid, [
        :registered_name,
        :status,
        :heap_size,
        :memory,
        :message_queue_len,
        :stack_size,
        :reductions
      ])

    getData(rest, [[{:pid, pid} | data] | procData])
  end

  def addProcsToCtrl(listCtrl, procData) do
    :wxListCtrl.deleteAllItems(listCtrl)
    addProcsToCtrl(listCtrl, procData, 0)
  end

  # Iterate over the process data list. ---------------------------------------------
  defp addProcsToCtrl(_listCtrl, [], _) do
    :ok
  end

  defp addProcsToCtrl(listCtrl, [row | rest], idx) do
    addRowData(listCtrl, row, idx)
    addProcsToCtrl(listCtrl, rest, idx + 1)
  end

  # Get and add the process data for the given PID
  def addRowData(listCtrl, [{_, val} | t], idx) do
    data = "  " <> "#{inspect(val)}"
    :wxListCtrl.insertItem(listCtrl, idx, data)

    checkColWidth(listCtrl, 0, data)
    addItemToRow(listCtrl, idx, t, 1)
  end

  def addItemToRow(_listCtrl, _idx, [], _col) do
    :ok
  end

  def addItemToRow(listCtrl, idx, [{_, val} | t], col) do
    data =
      case val do
        [] -> ""
        _ -> "#{inspect(val)}"
      end

    :wxListCtrl.setItem(listCtrl, idx, col, data)
    checkColWidth(listCtrl, col, data)
    addItemToRow(listCtrl, idx, t, col + 1)

    case rem(idx, 2) do
      0 -> :wxListCtrl.setItemBackgroundColour(listCtrl, idx, {230, 247, 255})
      1 -> :wxListCtrl.setItemBackgroundColour(listCtrl, idx, @wxWHITE)
    end
  end

  def checkColWidth(listCtrl, col, data) do
    {width, _y, _decent, _extLeading} = :wxListCtrl.getTextExtent(listCtrl, data, [])
    width = width + 10
    cwidth = :wxListCtrl.getColumnWidth(listCtrl, col)
    # Logger.info("col = #{inspect(col)} width = #{inspect(width)}, cwidth = #{inspect(cwidth)}")

    cond do
      width > cwidth -> :wxListCtrl.setColumnWidth(listCtrl, col, width)
      true -> :ok
    end
  end

  def getSettings() do
    col =
      cond do
        isChecked(:pid) -> :pid
        isChecked(:name) -> :registered_name
        isChecked(:status) -> :status
        isChecked(:heap) -> :heap_size
        isChecked(:memory) -> :memory
        isChecked(:queue) -> :message_queue_len
        isChecked(:stack) -> :stack_size
        isChecked(:reductions) -> :reductions
      end

    case isChecked(:ascending) do
      true -> {col, :asc}
      false -> {col, :dsc}
    end
  end

  ## Menu events
  # def do_menu_click(_window, _eventType, senderId, _senderObj) do
  def do_menu_click(senderId, state) do
    Logger.debug("Menu click sender = #{inspect(senderId)}")

    case senderId do
      :exit ->
        WxFunctions.closeWindow(:Etop)
        {:stop, :normal, state}

      # :exit -> {:stop, "Exit menu clicked", state}
      _ ->
        {:noreply, state, 1}
    end
  end

  def isChecked(menuItem) do
    {_, _, obj} = WinInfo.get_by_name(menuItem)
    :wxMenuItem.isChecked(obj)
  end

  def eventHandler(name, state) do
    Logger.info("Event handler, #{inspect(name)}, #{inspect(state)}")
    {:ok, state}
  end

  def do_timeout(state) do
    # Logger.info("Do timeout, #{inspect(state)}")
    display()
    {:noreply, state, 1000}
  end

  def commandMenuSelected(a, b, c, d) do
    Logger.debug("commandMenuSelected #{inspect({a, b, c, d})}")
  end
end
