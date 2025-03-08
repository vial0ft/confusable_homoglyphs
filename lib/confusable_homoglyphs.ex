defmodule ConfusableHomoglyphs do
  @moduledoc """
  Documentation for `ConfusableHomoglyphs`.
  """

  @spec init() :: :ok
  def init() do
    resources_dir_path =
      :code.priv_dir(:confusable_homoglyphs)
      |> Path.join("static")

    init_confusable_homoglyphs(resources_dir_path)
    init_categories(resources_dir_path)
  end

  defp init_confusable_homoglyphs(path) do
    confusable_homoglyphs =
      path
      |> Path.join("confusables.json")
      |> File.read!()
      |> JSON.decode!()

    :persistent_term.put(ConfusableHomoglyphs.Confusables, confusable_homoglyphs)
  end

  defp init_categories(path) do
    categories =
      path
      |> Path.join("categories.json")
      |> File.read!()
      |> JSON.decode!()

    :persistent_term.put(ConfusableHomoglyphs.Categories, categories)
  end
end
