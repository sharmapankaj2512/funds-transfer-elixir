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

  def revert_debit(accountId, amount) do
    Task.async(fn -> GenServer.call(accountId, {:revert_debit, amount}) end)
  end

  def transfer(source, target, amount) do
    task = debit(source, amount)
    case Task.await(credit(target, amount)) do
      {:error, _} -> revert_debit(source, amount)
      _ -> task
    end
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
  def handle_call({:credit, amount}, _from, balance) when amount < 0 do
    {:reply, {:error, "Negative amount"}, balance}
  end

  @impl true
  def handle_call({:credit, amount}, _from, balance) when amount >= 1000 do
    {:reply, {:error, "Limit Exceeded"}, balance}
  end

  @impl true
  def handle_call({:credit, amount}, _from, balance) do
    {:reply, balance + amount, balance + amount}
  end

  @impl true
  def handle_call({:debit, amount}, _from, balance) when amount < 0 do
    {:reply, {:error, "Negative amount"}, balance}
  end

  @impl true
  def handle_call({:debit, amount}, _from, balance) when balance >= amount do
    {:reply, balance - amount, balance - amount}
  end

  @impl true
  def handle_call({:debit, amount}, _from, balance) when amount > balance do
    {:reply, {:error, "Insufficient balance"}, balance}
  end

  @impl true
  def handle_call({:revert_debit, amount}, _from, balance) do
    {:reply, balance + amount, balance + amount}
  end
end
