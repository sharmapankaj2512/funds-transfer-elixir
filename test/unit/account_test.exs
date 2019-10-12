defmodule AccountTest do
  use ExUnit.Case
  doctest FundsTransfer.Account

  alias FundsTransfer.Account, as: Account

  describe "open()" do
    test "should create account with zero balance" do
      id = Account.open()

      assert Account.balance(id) == 0
    end
  end

  describe "credit()" do
    test "should add amount to account" do
      id = Account.open()
      Task.await(Account.credit(id, 100))

      assert Account.balance(id) == 100
    end
  end

  describe "debit()" do
    test "should deduct amount from account" do
      id = Account.open()
      Task.await(Account.credit(id, 100))
      Task.await(Account.debit(id, 100))

      assert Account.balance(id) == 0
    end

    test "should return error when balance is not sufficient" do
      id = Account.open()
      {:error, message} = Task.await(Account.debit(id, 100))

      assert message == "Insufficient balance"
    end
  end

  describe "transfer()" do
    test "should deduct from source and add to target account" do
      source = Account.open()
      target = Account.open()

      Task.await(Account.credit(source, 100))
      Task.await(Account.transfer(source, target, 100))

      assert assert Account.balance(source) == 0
      assert assert Account.balance(target) == 100
    end
  end
end
