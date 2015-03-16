defmodule Sanction.AuthenticateTest do
  use ExUnit.Case

  alias Sanction.Authenticate

  defmodule User do
    defstruct id: "John", password_hash: Authenticate.create_password_hash("password")
  end

  test "check valid password hash" do
    user = %User{}
    assert Authenticate.check_user(user, "password") == user
  end

  test "check invalid password hash" do
    users = [%User{id: "Fred", password_hash: Authenticate.create_password_hash("pasw0rd")},
      %User{id: "Tom", password_hash: Authenticate.create_password_hash("pa$sword")},
      %User{id: "Dick", password_hash: Authenticate.create_password_hash("passw0rd")},
      %User{id: "Harry", password_hash: Authenticate.create_password_hash("p@sw0rd")}]
    for user <- users do
      assert Authenticate.check_user(user, "password") == nil
    end
  end

end