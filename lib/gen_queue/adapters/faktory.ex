defmodule GenQueue.Adapters.Faktory do
  @moduledoc """
  An adapter for `GenQueue` to enable functionaility with `Faktory`.
  """

  use GenQueue.JobAdapter

  def start_link(_gen_queue, _opts \\ []) do
    Faktory.Application.start(nil, nil)
  end

  @doc """
  Push a `GenQueue.Job` for Faktory to consume.

  ## Parameters:
    * `gen_queue` - A `GenQueue` module
    * `job` - A `GenQueue.Job`

  ## Returns:
    * `{:ok, job}` if the operation was successful
    * `{:error, reason}` if there was an error
  """
  def handle_job(_gen_queue, job) do
    with {:ok, options} <- build_options(job) do
      options = Keyword.merge(options, job.config || [])
      Faktory.push(job.module, job.args, options)
      {:ok, job}
    end
  end

  defp build_options(%GenQueue.Job{queue: queue, delay: %DateTime{} = delay}) do
    {:ok, [queue: queue || "default", at: delay]}
  end

  defp build_options(%GenQueue.Job{queue: queue, delay: delay}) when is_integer(delay) do
    now = :os.system_time(:millisecond)

    case DateTime.from_unix(now + delay, :millisecond) do
      {:ok, datetime} -> {:ok, [queue: queue || "default", at: datetime]}
      error -> error
    end
  end

  defp build_options(%GenQueue.Job{queue: queue}) do
    {:ok, [queue: queue || "default"]}
  end
end
