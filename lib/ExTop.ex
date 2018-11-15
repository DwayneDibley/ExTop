defmodule ExTop do
  import WxWinObj.API
  require Logger
  # use WxDefines

  # import WinInfo

  @moduledoc """
  A WxWindows top implementation
  """

  @doc """
  The main entry point:
  - Set the application title.
  - Create the GUI.
  Then loop waiting for events.
  """
  def main(_args) do
    start(nil, nil)
  end

  def start(_a, _b) do
    System.put_env("WX_APP_TITLE", "ExTop")

    newWindow(ExTopWindow, WxTopWindowLogic, name: ETopWindow, show: true)
    waitForWindowClose(ETop)

    # We break out of the loop when the exit button is pressed.
    Logger.info("== ElixirWx Top Exiting ==")
    {:ok, self()}
  end
end
