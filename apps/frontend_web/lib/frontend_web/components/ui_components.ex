defmodule FrontendWeb.UIComponents do
  use FrontendWeb, :verified_routes

  @moduledoc """
  A general header component
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  defdelegate has?(feature), to: Frontend.Feature
  defdelegate has?(feature, user), to: Frontend.Feature

  attr :name, :string, default: "PROJECT_DOMAIN"
  attr :logo_path, :string, default: "/images/logo.png"

  def logo(assigns) do
    ~H"""
    <span class="sr-only"><%= @name %></span>
    <img class="h-8 w-auto sm:h-10" src={@logo_path} alt={@name} />
    """
  end

  slot :inner_block, required: true

  def admin_dashboard(assigns) do
    ~H"""
    <.dashboard>
      <:link label="Users" to={~p"/admin/users"} />
      <:link label="OAuth clients" to={~p"/admin/clients"} />
      <%= render_slot(@inner_block) %>
    </.dashboard>
    """
  end

  slot :inner_block, required: true

  slot :link, default: [%{__slot__: :link, inner_block: nil, label: "Home", to: "/home"}] do
    attr :label, :string
    attr :to, :string
  end

  def dashboard(assigns) do
    ~H"""
    <div class="py-6">
      <div class="mx-auto max-w-3xl sm:px-6 lg:grid lg:max-w-7xl lg:grid-cols-12 lg:gap-8 lg:px-8">
        <div class="hidden lg:col-span-3 lg:block xl:col-span-2">
          <nav aria-label="Sidebar" class="sticky top-6 divide-y divide-gray-300">
            <div class="space-y-1">
              <%= for link <- @link do %>
                <.link
                  navigate={link.to}
                  class="text-gray-600 hover:bg-gray-50 hover:text-gray-900 group flex items-center px-2 py-2 text-sm font-medium rounded-md"
                >
                  <%= link.label %>
                </.link>
              <% end %>
            </div>
          </nav>
        </div>
        <main class="lg:col-span-9 xl:col-span-6">
          <%= render_slot(@inner_block) %>
        </main>
      </div>
    </div>
    """
  end

  attr :current_user, :any, default: nil
  slot :logo

  slot :link, default: [%{__slot__: :link, inner_block: nil, label: "Home", to: "/home"}] do
    attr :label, :string
    attr :to, :string
  end

  def navbar(assigns) do
    ~H"""
    <div>
      <div class="mx-auto max-w-7xl px-4 sm:px-6">
        <div class="flex items-center justify-between border-b-2 border-gray-100 py-6 md:justify-start md:space-x-10">
          <div class="flex justify-start lg:w-0 lg:flex-1">
            <a href="/">
              <%= render_slot(@logo) %>
            </a>
          </div>
          <div class="-my-2 -mr-2 md:hidden">
            <button
              phx-click={toggle_dropdown("#navbar-default")}
              type="button"
              class="inline-flex items-center justify-center rounded-md bg-white p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
              aria-expanded="false"
            >
              <span class="sr-only">Open menu</span>
              <!-- Heroicon name: outline/bars-3 -->
              <svg
                class="h-6 w-6"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            </button>
          </div>
          <nav class="hidden space-x-10 md:flex">
            <%= for link <- @link do %>
              <.link
                navigate={link.to}
                class="text-base font-medium text-gray-500 hover:text-gray-900"
              >
                <%= link.label %>
              </.link>
            <% end %>
            <%= if @current_user do %>
              <.link
                navigate="/dashboard"
                class="text-base font-medium text-gray-500 hover:text-gray-900"
              >
                Dashboard
              </.link>
            <% end %>
          </nav>
          <%= if @current_user do %>
            <div class="hidden items-center justify-end md:flex md:flex-1 space-x-3 lg:w-0">
              <span><%= @current_user.email %></span>
              <.button_link_secondary method="delete" to="/users/log_out">
                Log out
              </.button_link_secondary>
              <%= if has?(:admin, @current_user) do %>
                <.button_link_secondary to={~p"/admin"}>
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    class="w-6 h-6"
                  >
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      d="M11.42 15.17L17.25 21A2.652 2.652 0 0021 17.25l-5.877-5.877M11.42 15.17l2.496-3.03c.317-.384.74-.626 1.208-.766M11.42 15.17l-4.655 5.653a2.548 2.548 0 11-3.586-3.586l6.837-5.63m5.108-.233c.55-.164 1.163-.188 1.743-.14a4.5 4.5 0 004.486-6.336l-3.276 3.277a3.004 3.004 0 01-2.25-2.25l3.276-3.276a4.5 4.5 0 00-6.336 4.486c.091 1.076-.071 2.264-.904 2.95l-.102.085m-1.745 1.437L5.909 7.5H4.5L2.25 3.75l1.5-1.5L7.5 4.5v1.409l4.26 4.26m-1.745 1.437l1.745-1.437m6.615 8.206L15.75 15.75M4.867 19.125h.008v.008h-.008v-.008z"
                    />
                  </svg>
                </.button_link_secondary>
              <% end %>
            </div>
          <% else %>
            <div class="hidden items-center justify-end md:flex md:flex-1 space-x-3 lg:w-0">
              <.button_link_secondary to="/users/log_in">Sign in</.button_link_secondary>
              <.button_link to="/users/register">Sign up</.button_link>
            </div>
          <% end %>
        </div>
      </div>
      <div
        class="absolute duration-100 z-50 inset-x-0 top-0 origin-top-right transform p-2 transition md:hidden hidden"
        id="navbar-default"
      >
        <div class="divide-y-2 divide-gray-50 rounded-lg bg-white shadow-lg ring-1 ring-black ring-opacity-5">
          <div class="px-5 pt-5 pb-6">
            <div class="flex items-center justify-between">
              <div>
                <%= render_slot(@logo) %>
              </div>
              <div class="-mr-2">
                <button
                  phx-click={toggle_dropdown("#navbar-default")}
                  type="button"
                  class="inline-flex items-center justify-center rounded-md bg-white p-2 text-gray-400 hover:bg-gray-100 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-indigo-500"
                  aria-controls="navbar-default"
                  aria-expanded="false"
                >
                  <span class="sr-only">Close menu</span>
                  <!-- Heroicon name: outline/x-mark -->
                  <svg
                    class="h-6 w-6"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke-width="1.5"
                    stroke="currentColor"
                    aria-hidden="true"
                  >
                    <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </button>
              </div>
            </div>
          </div>
          <div class="space-y-6 py-6 px-5">
            <div class="grid grid-cols-2 gap-y-4 gap-x-8">
              <%= for link <- @link do %>
                <.link
                  navigate={link.to}
                  class="text-base font-medium text-gray-900 hover:text-gray-700"
                >
                  <%= link.label %>
                </.link>
              <% end %>
            </div>
            <%= if @current_user do %>
              <div class="hidden items-center justify-end md:flex md:flex-1 space-x-3 lg:w-0">
                <span><%= @current_user.email %></span>
                <.button_link_secondary method="delete" to="/users/log_out">
                  Log out
                </.button_link_secondary>
              </div>
            <% else %>
              <div class="hidden items-center justify-end md:flex md:flex-1 space-x-3 lg:w-0">
                <.button_link_secondary to="/users/log_in">Sign in</.button_link_secondary>
                <.button_link to="/users/register">Sign up</.button_link>
              </div>
            <% end %>

            <div>
              <%= if @current_user do %>
                <.button_link_secondary method="delete" to="/users/log_out">
                  Log out
                </.button_link_secondary>
              <% else %>
                <.button_link to="/users/register">Sign up</.button_link>
                <p class="mt-6 text-center text-base font-medium text-gray-500">
                  Existing customer? <a href="/users/log_in" class="text-brand">Sign in</a>
                </p>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :to, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)
  attr :method, :string, default: nil

  slot :inner_block, required: true

  def button_link(assigns) do
    ~H"""
    <.link
      href={@to}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-emerald-600 hover:bg-emerald-800 py-2 px-3",
        "text-sm font-semibold leading-6 text-white active:text-white/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr :to, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global, include: ~w(disabled form name value)
  attr :method, :string, default: "get"

  slot :inner_block, required: true

  def button_link_secondary(assigns) do
    ~H"""
    <.link
      method={@method}
      href={@to}
      class={[
        "phx-submit-loading:opacity-75 rounded-lg bg-white border border-brand hover:bg-zinc-200 py-2 px-3",
        "text-sm font-semibold leading-6 text-gray-500 active:text-zinc/80",
        @class
      ]}
      {@rest}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  attr :author, :string, default: nil
  attr :published_at, :string, default: nil
  attr :class, :string, default: nil

  def author(%{author: "lenz"} = assigns) do
    ~H"""
    <div class={["mt-6 flex items-center", @class]}>
      <div class="flex-shrink-0">
        <span class="sr-only">Lenz Gschwendtner</span>
        <img class="h-10 w-10 rounded-full" src="/images/lenz.jpg" alt="" />
      </div>
      <div class="ml-3">
        <p class="text-sm font-medium text-brand">
          <span class="hover:underline">Lenz Gschwendtner</span>
        </p>
        <div class="flex space-x-1 text-sm text-gray-500">
          <time datetime="2020-03-16"><%= @published_at %></time>
        </div>
      </div>
    </div>
    """
  end

  def author(%{author: "emily"} = assigns) do
    ~H"""
    <div class={["mt-6 flex items-center", @class]}>
      <div class="flex-shrink-0">
        <span class="sr-only">Emily Sutton</span>
        <img class="h-10 w-10 rounded-full" src="/images/emily.jpeg" alt="" />
      </div>
      <div class="ml-3">
        <p class="text-sm font-medium text-brand">
          <span class="hover:underline">Emily Sutton</span>
        </p>
        <div class="flex space-x-1 text-sm text-gray-500">
          <time datetime="2020-03-16"><%= @published_at %></time>
        </div>
      </div>
    </div>
    """
  end

  def author(assigns) do
    ~H"""
    <div class={["mt-6 flex items-center", @class]}>
      <div class="flex-shrink-0">
        <span class="sr-only"><%= @author %></span>
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="w-10 h-10 rounded-full"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="M15.75 6a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0zM4.501 20.118a7.5 7.5 0 0114.998 0A17.933 17.933 0 0112 21.75c-2.676 0-5.216-.584-7.499-1.632z"
          />
        </svg>
      </div>
      <div class="ml-3">
        <p class="text-sm font-medium text-brand">
          <span class="hover:underline"><%= @author %></span>
        </p>
        <div class="flex space-x-1 text-sm text-gray-500">
          <time datetime="2020-03-16"><%= @published_at %></time>
        </div>
      </div>
    </div>
    """
  end

  defp toggle_dropdown(id, js \\ %JS{}) do
    js
    |> JS.toggle(to: id)
  end
end
