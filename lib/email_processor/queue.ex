defmodule EmailProcessor.Queue do
  use GenServer

  def start_link(opts) do
    name = Keyword.fetch!(opts, :name)
    init_args = Keyword.fetch!(opts, :init_args)

    GenServer.start_link(__MODULE__, init_args, name: name)
  end

  def init(%{queue_name: queue_name, initial_message: initial_message}) do
    schedule_work()

    {:ok, %{queue_name: queue_name, queue: :queue.in(initial_message, :queue.new())}}
  end

  def enqueue(pid, message) do
    GenServer.cast(pid, {:enqueue, message})
  end

  def handle_cast({:enqueue, message}, %{queue: existing_queue} = state) do
    {:noreply, %{state | queue: :queue.in(message, existing_queue)}}
  end

  def handle_info(:work, %{queue: queue, queue_name: queue_name} = state) do
    new_queue =
      case :queue.out(queue) do
        {{:value, %{email: email, message: message, subject: subject}}, new_queue} ->
          IO.inspect("queue:#{queue_name} subject:#{subject} message:#{message} email:#{email}")

          new_queue

        {:empty, new_queue} ->
          new_queue
      end

    schedule_work()

    {:noreply, %{state | queue: new_queue}}
  end

  defp schedule_work do
    Process.send_after(self(), :work, 1000)
  end
end
