defmodule SoundboardWeb.ProcessHelper do
  def send_process(klass, message) do
    Kernel.send(process_pid(klass), message)
  end

  def call_process(klass, message) do
    GenServer.call(process_pid(klass), message)
  end

  def process_pid(klass) do
    pid = nil

    proc = List.keyfind(Supervisor.which_children(Soundboard.Supervisor), klass, 0)

    pid = if proc != nil do
      {_, pid, _, _} = proc
      pid
    else
      pid
    end
    pid
  end
end
