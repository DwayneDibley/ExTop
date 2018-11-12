defmodule WinInfoTest do
  use ExUnit.Case
  doctest ExTop

  test "WinInfo.create test" do
    assert WinInfo.createInfoTable() == :ok
  end

  test "WinInfo.insert test" do
    WinInfo.createInfoTable()
    assert WinInfo.insert({:testing, 123, {:wx_ref, 52, :wxPanel, []}}) == true
  end

  test "WinInfo.getWxObject test with atom" do
    WinInfo.createInfoTable()
    WinInfo.insert({:testing, 99999, {:wx_ref, 52, :wxPanel, []}})
    assert WinInfo.getWxObject(:testing) == {:wx_ref, 52, :wxPanel, []}
  end

  test "WinInfo.getWxObject test with integer" do
    WinInfo.createInfoTable()
    WinInfo.insert({:testing, 1234, {:wx_ref, 52, :wxPanel, []}})
    assert WinInfo.getWxObject(1234) == {:wx_ref, 52, :wxPanel, []}
  end

  test "WinInfo.getWxObject not found test with atom" do
    WinInfo.createInfoTable()
    WinInfo.insert({:testing, 99999, {:wx_ref, 52, :wxPanel, []}})
    assert WinInfo.getWxObject(:notpresent) == nil
  end

  test "WinInfo.getWxObject not found test with integer" do
    WinInfo.createInfoTable()
    WinInfo.insert({:testing, 1234, {:wx_ref, 52, :wxPanel, []}})
    assert WinInfo.getWxObject(4321) == nil
  end
end
