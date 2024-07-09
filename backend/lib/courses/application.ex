defmodule Courses.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: Courses.PubSub},
      {EtcdEx, name: Courses.Etcd, endpoint: {:http, "etcd", 2379, []}},
      CoursesWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Courses.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    CoursesWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
