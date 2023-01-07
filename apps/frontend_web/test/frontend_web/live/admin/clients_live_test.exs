defmodule FrontendWeb.Admin.ClientsLiveTest do
  use FrontendWeb.ConnCase

  import Phoenix.LiveViewTest
  import Frontend.BorutaFixtures

  @create_attrs %{
    authorize_scope: true,
    name: "some name",
    redirect_uri: "some redirect_uri",
    scope: "some scope",
    secret: "some secret"
  }
  @update_attrs %{
    authorize_scope: false,
    name: "some updated name",
    redirect_uri: "some updated redirect_uri",
    scope: "some updated scope",
    secret: "some updated secret"
  }
  @invalid_attrs %{authorize_scope: false, name: nil, redirect_uri: nil, scope: nil, secret: nil}

  defp create_clients(_) do
    clients = clients_fixture()
    %{clients: clients}
  end

  describe "Index" do
    setup [:create_clients]

    test "lists all client", %{conn: conn, clients: clients} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/client")

      assert html =~ "Listing Client"
      assert html =~ clients.name
    end

    test "saves new clients", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/client")

      assert index_live |> element("a", "New Clients") |> render_click() =~
               "New Clients"

      assert_patch(index_live, ~p"/admin/client/new")

      assert index_live
             |> form("#clients-form", clients: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#clients-form", clients: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/client")

      assert html =~ "Clients created successfully"
      assert html =~ "some name"
    end

    test "updates clients in listing", %{conn: conn, clients: clients} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/client")

      assert index_live |> element("#client-#{clients.id} a", "Edit") |> render_click() =~
               "Edit Clients"

      assert_patch(index_live, ~p"/admin/client/#{clients}/edit")

      assert index_live
             |> form("#clients-form", clients: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#clients-form", clients: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/client")

      assert html =~ "Clients updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes clients in listing", %{conn: conn, clients: clients} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/client")

      assert index_live |> element("#client-#{clients.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#clients-#{clients.id}")
    end
  end

  describe "Show" do
    setup [:create_clients]

    test "displays clients", %{conn: conn, clients: clients} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/client/#{clients}")

      assert html =~ "Show Clients"
      assert html =~ clients.name
    end

    test "updates clients within modal", %{conn: conn, clients: clients} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/client/#{clients}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Clients"

      assert_patch(show_live, ~p"/admin/client/#{clients}/show/edit")

      assert show_live
             |> form("#clients-form", clients: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#clients-form", clients: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, ~p"/admin/client/#{clients}")

      assert html =~ "Clients updated successfully"
      assert html =~ "some updated name"
    end
  end
end
