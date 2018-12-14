defmodule GenQueue.Adapters.FaktoryTest do
  use ExUnit.Case

  import GenQueue.Test

  Application.put_env(:faktory_worker_ex, :start_workers, true)

  defmodule Enqueuer do
    use GenQueue, adapter: GenQueue.Adapters.Faktory
  end

  defmodule Job do
    use Faktory.Job

    def perform do
      send_item(Enqueuer, :performed)
      :ok
    end

    def perform(arg1) do
      send_item(Enqueuer, {:performed, arg1})
      :ok
    end
  end

  setup_all do
    Enqueuer.start_link()
    :ok
  end

  setup do
    setup_global_test_queue(Enqueuer, :test)
  end

  describe "push/2" do
    test "enqueues and runs job from module" do
      {:ok, job} = Enqueuer.push(Job)
      assert_receive(:performed)
      assert %GenQueue.Job{module: Job, args: []} = job
    end

    test "enqueues and runs job from module tuple" do
      {:ok, job} = Enqueuer.push({Job})
      assert_receive(:performed)
      assert %GenQueue.Job{module: Job, args: []} = job
    end

    test "enqueues and runs job from module and args" do
      {:ok, job} = Enqueuer.push({Job, [%{"foo" => "bar"}]})
      assert_receive({:performed, %{"foo" => "bar"}})
      assert %GenQueue.Job{module: Job, args: [%{"foo" => "bar"}]} = job
    end

    test "enqueues and runs job from module and single arg" do
      {:ok, job} = Enqueuer.push({Job, %{"foo" => "bar"}})
      assert_receive({:performed, %{"foo" => "bar"}})
      assert %GenQueue.Job{module: Job, args: [%{"foo" => "bar"}]} = job
    end

    test "enqueues a job with millisecond based delay" do
      {:ok, job} = Enqueuer.push({Job, []}, delay: 1_000)
      assert_receive(:performed, 5_000)
      assert %GenQueue.Job{module: Job, args: [], delay: 1_000} = job
    end

    test "enqueues a job with datetime based delay" do
      {:ok, job} = Enqueuer.push({Job, []}, delay: DateTime.utc_now())
      assert_receive(:performed)
      assert %GenQueue.Job{module: Job, args: [], delay: %DateTime{}} = job
    end
  end
end
