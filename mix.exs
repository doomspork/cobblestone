defmodule Cobblestone.MixProject do
  use Mix.Project

  @source_url "https://github.com/doomspork/cobblestone"
  @version "1.0.1"

  def project do
    [
      app: :cobblestone,
      version: @version,
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      compilers: [:leex, :yecc] ++ Mix.compilers(),
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "LICENSE.md",
        "README.md"
      ],
      formatters: ["html"],
      homepage_url: @source_url,
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp package do
    [
      name: "cobblestone",
      description: "A better path to data. Powerful data querying and transformation library for Elixir",
      files: [
        "lib",
        "src",
        "mix.exs",
        "README.md",
        "LICENSE.md",
        "CHANGELOG.md",
        ".formatter.exs"
      ],
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/cobblestone/changelog.html",
        "GitHub" => @source_url
      },
      maintainers: [
        "doomspork (iamdoomspork@gmail.com)"
      ]
    ]
  end
end
