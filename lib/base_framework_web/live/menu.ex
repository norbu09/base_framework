defmodule BaseFrameworkWeb.LiveMenu do
  use Phoenix.LiveView
  require Logger

  def mount(_params, _session, socket) do
    {:ok, assign(socket, 
      nav_open: false,
      full: false)
    }
  end

  def handle_event("toggle_nav", _, socket) do
    state = case socket.assigns.full do
      true -> false
      false -> true
    end
    {:noreply, socket |> assign(:full, state)}
  end

  def nav_bar(%{full: full, nav_open: nav_open, inner_block: inner_block}) do

    {h_class, m_class} = case full do
      true -> {
          "text-red-600 font-black py-4 text-2xl px-4",
          "h-screen bg-gray-200 fixed transition-all duration-300 space-y-2 sm:relative w-64"
      }
      false -> {
          "text-red-600 font-black py-4 text-xl px-4 xm:px-2",
          "h-screen bg-gray-200 fixed transition-all duration-300 space-y-2 sm:relative w-64 sm:w-20"
      }
    end
    main_class = case nav_open do
      true -> m_class
      false -> m_class <> "top-0 -left-64 sm:left-0"
    end
    assigns = %{full: full, main_class: main_class, h_class: h_class, nav_open: nav_open, inner_block: inner_block}

    ~H"""
    <div class={@main_class}>
      <h1 class={h_class}>
        BaseFramework
      </h1>
      <%= render_block(@inner_block) %>
    </div>
    """
  end

  def nav_button(%{full: full, click: click}) do
    assigns = %{full: full, click: click}

    ~H"""
    <button phx-click={@click} class="sm:hidden absolute top-5 right-5 focus:outline-none">
      <%= if(@full) do %>
      <svg x-cloak xmlns="http://www.w3.org/2000/svg" 
           width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-6 h-6">
        <circle cx="12" cy="12" r="10"></circle>
        <line x1="8" y1="12" x2="16" y2="12"></line>
      </svg>
      <% else %>
      <svg xmlns="http://www.w3.org/2000/svg" 
           width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="w-6 h-6">
        <line x1="17" y1="10" x2="3" y2="10"></line>
        <line x1="21" y1="6" x2="3" y2="6"></line>
        <line x1="21" y1="14" x2="3" y2="14"></line>
        <line x1="17" y1="18" x2="3" y2="18"></line>
      </svg>
      <% end %>
    </button>
    """
  end

  def nav_toggle(%{full: full, click: click}) do

    class = case full do
      true -> "h-4 w-4 transition-all duration-300 transform text-white rotate-90"
      false -> "h-4 w-4 transition-all duration-300 transform text-white -rotate-90"
    end
    assigns = %{full: full, click: click, class: class}

    ~H"""
    <button phx-click={@click}
      class="hidden sm:block focus:outline-none absolute -right-3 p-1 top-10 bg-red-600 rounded-full shadow-md">
      <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewbox="0 0 24 24" fill="none" stroke="currentcolor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" 
        class={@class}>
        <polyline points="6 9 12 15 18 9"></polyline>
      </svg>
    </button>
    """
  end

end
