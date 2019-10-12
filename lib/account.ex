defmodule FundsTransfer.Account do
  use Agent

  def start_link() do
    Agent.start_link(fn -> 0 end)
  end

  def open() do
    {:ok, pid} = start_link()
    pid
  end

  def balance(accountId) do
    Agent.get(accountId, & &1)
  end

  def credit(accountId, amount) do
    Task.async(fn -> Agent.update(accountId, &(&1 + amount)) end)
  end

  def debit(accountId, amount) do
    Task.async(fn -> Agent.update(accountId, &(&1 - amount)) end)
  end
end
