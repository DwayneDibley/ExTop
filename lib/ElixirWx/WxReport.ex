defmodule WxReport do
  require Logger

  # import WxUtilities
  # import WinInfo
  use WxDefines

  @moduledoc """
  The List control is so unintuative (At least to me) so I have created this
  module to interface to it in a sensible way.
  """

  @doc """
  Create a new report using the list control.
  """
  def new(parent, options) do
    Logger.debug("  WxReport.new(#{inspect(parent)}, #{inspect(options)}")
    # ||| @wxLC_SINGLE_SEL)
    reportCtrl = :wxListCtrl.new(parent, style: @wxLC_REPORT)
    Logger.debug("report = #{inspect(reportCtrl)}")
    reportCtrl
  end

  @doc """
  Set the data in a report, where the data contains a list lists
  containing rows of data.
  """
  def setReportData(listCtrl, data) do
    nRows = :wxListCtrl.getItemCount(listCtrl)
    setData(listCtrl, nRows, 0, data)
  end

  def setData(_, _, _, []) do
  end

  def setData(listCtrl, nRows, row, [rowData | rest]) do
    setRowData(listCtrl, nRows, row, 0, rowData)
    setData(listCtrl, nRows, row + 1, rest)
  end

  def setRowData(_, _, _, _, []) do
  end

  def setRowData(listCtrl, nRows, row, 0, [colData | rest]) do
    cond do
      row >= nRows -> :wxListCtrl.insertItem(listCtrl, row, colData)
      true -> :wxListCtrl.setItem(listCtrl, row, 0, colData)
    end

    setColWidth(listCtrl, 0, colData)
    setRowData(listCtrl, nRows, row, 1, rest)
  end

  def setRowData(listCtrl, nRows, row, col, [colData | rest]) do
    :wxListCtrl.setItem(listCtrl, row, col, colData)
    setColWidth(listCtrl, col, colData)
    setRowData(listCtrl, nRows, row, col + 1, rest)
  end

  def setColWidth(listCtrl, col, data) do
    {width, _y, _decent, _extLeading} = :wxListCtrl.getTextExtent(listCtrl, data, [])
    width = width + 10
    cwidth = :wxListCtrl.getColumnWidth(listCtrl, col)
    # Logger.info("col = #{inspect(col)} width = #{inspect(width)}, cwidth = #{inspect(cwidth)}")

    cond do
      width > cwidth -> :wxListCtrl.setColumnWidth(listCtrl, col, width)
      true -> :ok
    end
  end

  @doc """
  Find the row which has the given text in its first column.
  Id partial is true, then find the row where the text starts with firstColtext.
  startRow is the row to start on whilst searching.
  Returns the column index, or -1 if the text is not found.
  """
  def findRowIndex(listCtrl, firstColText) do
    :wxListCtrl.findItem(listCtrl, -1, firstColText)
  end

  def findRowIndex(listCtrl, firstColText, startRow, partial \\ false) do
    :wxListCtrl.findItem(listCtrl, startRow, firstColText, partial: partial)
  end

  @doc """
  Add a new column to the list control
  """
  def newColumn(parent, colNo, heading, options \\ []) do
    Logger.debug(
      "  :wxListCtrl.insertColumn(#{inspect(parent)}, #{inspect(colNo)}, #{inspect(heading)}, #{
        inspect(options)
      })"
    )

    lc = :wxListCtrl.insertColumn(parent, colNo, heading, options)
  end
end
