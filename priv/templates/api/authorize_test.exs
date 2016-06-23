defmodule <%= base %>.AuthorizeTest do
  use <%= base %>.ConnCase

  import <%= base %>.EctoDB
  import OpenmaizeJWT.Create
  alias <%= base %>.{Repo, User}

  @valid_attrs %{email: "tony@mail.com", password: "mangoes&g0oseberries"}
  @invalid_attrs %{email: "tony@mail.com", password: "maaaangoes&g00zeberries"}

  {:ok, user_token} = %{id: 3, email: "tony@mail.com", role: "user"}
                      |> generate_token({0, 1440})
  @user_token user_token

  setup do
    conn = conn()
    |> put_req_cookie("access_token", @user_token)
    {:ok, conn: conn}
  end

  # The first three tests can be used to test routes protected by
  # the role_check plug or the custom action (authorize_action) function
  test "correct user role is successfully authorized", %{conn: conn} do
    conn = get conn, "/users"
    assert response(conn, 200)
  end

  test "authorization for incorrect role fails", %{conn: conn} do
    conn = get conn, "/admin"
    assert response(conn, 403)
  end

  test "authorization for nil user fails" do
    conn = conn() |> get("/users")
    assert response(conn, 401)
  end

  # Test routes protected by the id_check plug
  test "id check succeeds", %{conn: conn} do
    conn = get conn, "/users/3"
    assert response(conn, 200)
  end

  test "id check fails for incorrect id", %{conn: conn} do
    conn = get conn, "/users/30"
    assert response(conn, 403)
  end

  test "id check fails for nil user" do
    conn = conn() |> get("/users/3")
    assert response(conn, 401)
  end

  test "login succeeds" do
    # Remove the Repo.get_by line if you are not using email confirmation
    Repo.get_by(User, %{email: "tony@mail.com"}) |> user_confirmed
    conn = post conn(), "/login", user: @valid_attrs
    assert response(conn, 200)
  end

  test "login fails" do
    # Remove the Repo.get_by line if you are not using email confirmation
    Repo.get_by(User, %{email: "reg@mail.com"}) |> user_confirmed
    conn = post conn(), "/login", user: @invalid_attrs
    assert response(conn, 401)
  end

  test "logout succeeds" do
  {:ok, user_token} = %{id: 3, email: "tony@mail.com", role: "user"}
                      |> generate_token({0, 1440})
    conn = conn()
    |> put_req_cookie("access_token", user_token)
    |> get("/logout")
    assert response(conn, 200)
  end

end
