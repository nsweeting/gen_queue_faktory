defmodule GenQueueFaktory.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :gen_queue_faktory,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      docs: docs(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end


  defp description do
    """
    GenQueue adapter for Faktory
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*"],
      maintainers: ["Nicholas Sweeting"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/nsweeting/gen_queue_faktory",
        "GenQueue" => "https://github.com/nsweeting/gen_queue"
      }
    ]
  end

  defp docs do
    [
      extras: ["README.md"],
      main: "readme",
      source_url: "https://github.com/nsweeting/gen_queue_faktory"
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_queue, "~> 0.1.8"},
      {:faktory_worker_ex, "~> 0.5.0", runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end
end
