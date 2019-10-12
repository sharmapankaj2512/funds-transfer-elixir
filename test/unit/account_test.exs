defmodule AccountTest do
  use ExUnit.Case
  doctest FundsTransfer.Account

  alias FundsTransfer.Account, as: Account

  test "should create account with zero balance" do
    id = Account.open()

    assert Account.balance(id) == 0
  end

  test "should credit amount to account" do
    id = Account.open()
    Task.await(Account.credit(id, 100))

    assert Account.balance(id) == 100
  end

  test "should debit amount from account" do
    id = Account.open()
    Task.await(Account.credit(id, 100))
    Task.await(Account.debit(id, 100))

    assert Account.balance(id) == 0
  end

  test "should return error on debit when balance is not sufficient" do
    id = Account.open()
    {:error, message} = Task.await(Account.debit(id, 100))

    assert message == "Insufficient balance"
  end

  test "should transfer from one account to other" do
    first = Account.open()
    second = Account.open()

    Task.await(Account.credit(first, 100))
    Task.await(Account.transfer(first, second, 100))

    assert assert Account.balance(first) == 0
    assert assert Account.balance(second) == 100
  end
end
