defmodule Karmabot.Mixfile do
  use Mix.Project

  def project do
    [
      app: :karmabot,
      version: "0.1.0",
      elixir: "~> 1.5",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Karmabot, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:slack, "~> 0.12.0"}
    ]
  end
end
