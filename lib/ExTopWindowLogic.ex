defmodule WxTopWindowLogic do
  require Logger
  use WxDefines

  @moduledoc """

  """
  def init({action, state}) do
    display(state)
    {action, state, 1000}
  end

  @doc """
  Get the process data from the beam engine and display it.
  """
  def display(_state) do
    {sortCol, how} = getSettings()
    listCtrl = WinInfo.getWxObject(:report)

    # Get the beam engine per process data
    procData = getProcessData(sortCol, how)
    nProcs = length(procData)
    data = process(procData, [])
    WxStatusBar.setText("#{nProcs} processes")
    {_selectedIdx, selectedPid} = WxReport.getSelection(listCtrl)

    font = :wxFont.new(14, @wxFONTFAMILY_MODERN, @wxFONTSTYLE_NORMAL, @wxFONTWEIGHT_NORMAL)

    # Freeze the window during the update
    :wxWindow.freeze(listCtrl)
    WxReport.setReportData(listCtrl, data, font)
    :wxWindow.thaw(listCtrl)

    # Maintian the selected row by resetting the selection to the new row
    # containing the selected pid.
    idx = WxReport.findRowIndex(listCtrl, selectedPid)
    WxReport.clearSelection(listCtrl)
    WxReport.setSelection(listCtrl, idx)

    :timer.sleep(1000)
  end

  @doc """
  Process the per process data into a form suitable to display.
  """
  def process([], data) do
    Enum.reverse(data)
  end

  def process([row | rest], data) do
    dat = processRow(row, [])
    process(rest, [dat | data])
  end

  def processRow([], rowData) do
    Enum.reverse(rowData)
  end

  def processRow([{_key, val} | rest], rowData) do
      cond do
        val == [] -> processRow(rest, ["" | rowData])
        true -> processRow(rest, ["#{inspect(val)}" | rowData])
      end
  end

  @doc """
  Get a sorted array containing the process data
  """
  def getProcessData(sortBy, how) do
    procData = getData(:erlang.processes(), [])

    case how do
      :asc -> Enum.sort(procData, &(&1[sortBy] <= &2[sortBy]))
      :dsc -> Enum.sort(procData, &(&1[sortBy] >= &2[sortBy]))
    end
  end

  defp getData([], procData) do
    Enum.reverse(procData)
  end

  defp getData([pid | rest], procData) do
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

  # # Add the process data to the list control
  # def addProcsToCtrl(listCtrl, procData) do
  #   :wxListCtrl.deleteAllItems(listCtrl)
  #   addProcsToCtrl(listCtrl, procData, 0)
  # end
  #
  # # Iterate over the process data list. ---------------------------------------------
  # defp addProcsToCtrl(_listCtrl, [], _) do
  #   :ok
  # end
  #
  # defp addProcsToCtrl(listCtrl, [row | rest], idx) do
  #   addRowData(listCtrl, row, idx)
  #   addProcsToCtrl(listCtrl, rest, idx + 1)
  # end
  #
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

      _ ->
        {:noreply, state, 1}
    end
  end

  # List control event
  def do_command_list_col_click(senderId, col, state) do
    Logger.debug("do_command_list_col_click = #{inspect(senderId)}, #{inspect(col)}")
    {:noreply, state, 1}
  end

  def do_list_ctrl_col_click(senderId, col, state) do
    Logger.debug("do_list_ctrl_col_click = #{inspect(senderId)}, #{inspect(col)}")

    case col do
      0 -> :ok
        1 -> :ok
        2 -> :ok
        3 -> :ok
        4 -> :ok
        5 -> :ok
        6 -> :ok
        7 -> :ok
    end

    {:noreply, state, 1}
  end

  def isChecked(menuItem) do
    obj = WinInfo.getWxObject(menuItem)
    :wxMenuItem.isChecked(obj)
  end

  def eventHandler(name, state) do
    Logger.info("Event handler, #{inspect(name)}, #{inspect(state)}")
    {:ok, state}
  end

  def do_timeout(state) do
    # Logger.info("Do timeout, #{inspect(state)}")
    display(state)
    {:noreply, state, 1000}
  end

  def commandMenuSelected(a, b, c, d) do
    Logger.debug("commandMenuSelected #{inspect({a, b, c, d})}")
  end
end
