defmodule Soundboard.DynamicSupervisor do
  @moduledoc false
  use DynamicSupervisor
  # alias Soundboard.Worker

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(child_spec) when is_map child_spec do
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def start_child(child_spec, args \\ []) do
    DynamicSupervisor.start_child(__MODULE__, {child_spec, args})
  end
  #Soundboard.DynamicSupervisor.start_child(%{id: Nostrum.Application, start: {Nostrum.Application, :start, ["arg1","arg2"]}})

end
