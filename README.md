# GenQueue Faktory

[![Build Status](https://travis-ci.org/nsweeting/gen_queue_faktory.svg?branch=master)](https://travis-ci.org/nsweeting/gen_queue_faktory)
[![GenQueue OPQ Version](https://img.shields.io/hexpm/v/gen_queue_faktory.svg)](https://hex.pm/packages/gen_queue_faktory)

This is an adapter for [GenQueue](https://github.com/nsweeting/gen_queue) to enable
functionaility with [Faktory](https://github.com/cjbottaro/faktory_worker_ex).

## Installation

The package can be installed by adding `gen_queue_faktory` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:gen_queue_faktory, "~> 0.1.0"}
  ]
end
```

## Documentation

See [HexDocs](https://hexdocs.pm/gen_queue_faktory) for additional documentation.

## Configuration

Before starting, please refer to the [Faktory](https://github.com/cjbottaro/faktory_worker_ex) documentation
for details on configuration. This adapter handles zero `Faktory` related config.

## Creating Enqueuers

We can start off by creating a new `GenQueue` module, which we will use to push jobs to
OPQ.

```elixir
defmodule Enqueuer do
  use GenQueue, otp_app: :my_app
end
```

Once we have our module setup, ensure we have our config pointing to the `GenQueue.Adapters.Faktory`
adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.Faktory
]
```

## Starting Enqueuers

By default, `gen_queue_faktory` does not start Faktory on application start. So we must add
our new `Enqueuer` module to our supervision tree.

```elixir
  children = [
    supervisor(Enqueuer, []),
  ]
```

## Creating Jobs

Jobs are simply modules with a `perform` method. With `Faktory` we must add `use Faktory.Job`
to our jobs.

```elixir
defmodule MyJob do
  use Faktory.Job

  def perform(arg1) do
    IO.inspect(arg1)
  end
end
```

## Enqueuing Jobs

We can now easily enqueue jobs to `Faktory`. The adapter will handle a variety of argument formats.

```elixir
# Push MyJob to queue
{:ok, job} = Enqueuer.push(MyJob)

# Push MyJob to queue
{:ok, job} = Enqueuer.push({MyJob})

# Push MyJob to queue with "arg1"
{:ok, job} = Enqueuer.push({MyJob, "arg1"})

# Push MyJob to queue with no args
{:ok, job} = Enqueuer.push({MyJob, []})

# Push MyJob to queue with "arg1" and "arg2"
{:ok, job} = Enqueuer.push({MyJob, ["arg1", "arg2"]})
```

## Testing

Optionally, we can also have our tests use the `GenQueue.Adapters.MockJob` adapter.

```elixir
config :my_app, Enqueuer, [
  adapter: GenQueue.Adapters.MockJob
]
```

This mock adapter uses the standard `GenQueue.Test` helpers to send the job payload
back to the current processes mailbox (or another named process) instead of actually
enqueuing the job to OPQ.

```elixir
defmodule MyJobTest do
  use ExUnit.Case, async: true

  import GenQueue.Test

  setup do
    setup_test_queue(Enqueuer)
  end

  test "my enqueuer works" do
    {:ok, _} = Enqueuer.push(MyJob)
    assert_receive(%GenQueue.Job{module: MyJob, args: []})
  end
end
```

If your jobs are being enqueued outside of the current process, we can use named
processes to recieve the job. This wont be async safe.

```elixir
import GenQueue.Test

setup do
  setup_global_test_queue(Enqueuer, :my_process_name)
end
```
