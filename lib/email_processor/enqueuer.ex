defmodule EmailProcessor.Enqueuer do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def init(_opts) do
    {:ok, []}
  end

  def enqueue(message) do
    GenServer.cast(__MODULE__, {:enqueue, message})
  end

  def handle_cast({:enqueue, %{queue_name: queue_name} = message}, state) do
    case Registry.lookup(EmailProcessor.QueuesRegistry, queue_name) do
      [] ->
        DynamicSupervisor.start_child(
          EmailProcessor.QueuesSupervisor,
          {EmailProcessor.Queue,
           init_args: %{
             queue_name: queue_name,
             initial_message: message
           },
           name: {:via, Registry, {EmailProcessor.QueuesRegistry, queue_name}}}
        )

      [{pid, _value}] ->
        EmailProcessor.Queue.enqueue(pid, message)
    end

    {:noreply, state}
  end
end
