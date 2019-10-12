defmodule AccountTest do
  use ExUnit.Case
  doctest FundsTransfer.Account

  alias FundsTransfer.Account, as: Account

  test "should create account with zero balance" do
    id = Account.open()

    assert Account.balance(id) == 0
  end

  test "should credit amount to account" do
    id = FundsTransfer.Account.open()
    Task.await(Account.credit(id, 100))

    assert FundsTransfer.Account.balance(id) == 100
  end

  test "should debit amount from account" do
    id = FundsTransfer.Account.open()
    Task.await(Account.credit(id, 100))
    Task.await(Account.debit(id, 100))

    assert FundsTransfer.Account.balance(id) == 0
  end
end
