defmodule GenQueue.Adapters.FactoryMockTest do
  use ExUnit.Case

  import GenQueue.Test

  defmodule Enqueuer do
    use GenQueue, adapter: GenQueue.Adapters.MockJob
  end

  defmodule Job do
  end

  setup do
    setup_test_queue(Enqueuer)
  end

  describe "push/2" do
    test "sends the job back to the process from module" do
      {:ok, _} = Enqueuer.push(Job)
      assert_receive(%GenQueue.Job{module: Job, args: []})
    end

    test "sends the job back to the process from module tuple" do
      {:ok, _} = Enqueuer.push({Job})
      assert_receive(%GenQueue.Job{module: Job, args: []})
    end

    test "sends the job back to the process from module and args" do
      {:ok, _} = Enqueuer.push({Job, ["foo", "bar"]})
      assert_receive(%GenQueue.Job{module: Job, args: ["foo", "bar"]})
    end

    test "does nothing if process is not registered" do
      reset_test_queue(Enqueuer)
      {:ok, _} = Enqueuer.push(Job)
    end

    test "sends the job back to a named process" do
      setup_global_test_queue(Enqueuer, :test)
      {:ok, _} = Enqueuer.push(Job)
      assert_receive(%GenQueue.Job{module: Job, args: []})
    end
  end
end
