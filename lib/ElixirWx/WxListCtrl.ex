defmodule WxListCtrl do
  require Logger

  # import WxUtilities
  # import WinInfo
  use WxDefines

  @doc """
  Create a new list control.
  """
  def new(parent, options) do
    Logger.debug("  :wxListCtrl.new(#{inspect(parent)}, #{inspect(options)}")
    # ||| @wxLC_SINGLE_SEL)
    lc = :wxListCtrl.new(parent, style: @wxLC_REPORT)

    # Logger.info("Col Ct = #{inspect(:wxListCtrl.getColumnCount(lc))}")
    lc
  end

  def newColumn(parent, colNo, heading, options \\ []) do
    Logger.debug(
      "  :wxListCtrl.insertColumn(#{inspect(parent)}, #{inspect(colNo)}, #{inspect(heading)}, #{
        inspect(options)
      })"
    )

    :wxListCtrl.insertColumn(parent, colNo, heading, options)
  end
end
