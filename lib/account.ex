defmodule FundsTransfer.Account do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, 0)
  end

  def open() do
    {:ok, pid} = start_link()
    pid
  end

  def balance(accountId) do
    GenServer.call(accountId, :balance)
  end

  def credit(accountId, amount) do
    Task.async(fn -> GenServer.call(accountId, {:credit, amount}) end)
  end

  def debit(accountId, amount) do
    Task.async(fn -> GenServer.call(accountId, {:debit, amount}) end)
  end

  def transfer(source, target, amount) do
    debit(source, amount)
    credit(target, amount)
  end

  @impl true
  def init(balance) do
    {:ok, balance}
  end

  @impl true
  def handle_call(:balance, _from, balance) do
    {:reply, balance, balance}
  end

  @impl true
  def handle_call({:credit, amount}, _from, balance) do
    {:reply, balance + amount, balance + amount}
  end

  @impl true
  def handle_call({:debit, amount}, _from, balance) when balance >= amount do
    {:reply, balance - amount, balance - amount}
  end

  @impl true
  def handle_call({:debit, amount}, _from, balance) when amount > balance do
    {:reply, {:error, "Insufficient balance"}, balance}
  end
end
