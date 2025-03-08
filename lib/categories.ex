defmodule ConfusableHomoglyphs.Categories do

  def get_categories do
    :persistent_term.get(ConfusableHomoglyphs.Categories, %{})
  end


  @spec aliases_categories(char()) :: {map(), map()}
  def aliases_categories(char) do
    aliases_categories(char, get_categories())
  end

  @spec aliases_categories(char(), map()) :: {map(), map()}
  def aliases_categories(char, cats) do
    l = 0
    r = length(Map.get(cats, "code_points_ranges")) - 1
    aliases_categories_rec(l, r, char, cats)
  end

  @spec aliases_categories_rec(integer(), integer(), char(), map()) :: tuple()
  defp aliases_categories_rec(l, r, char, cats) when r >= l do
    m = div(l + r, 2)
    points_ranges = Map.get(cats, "code_points_ranges", [])
    m_range = Enum.at(points_ranges, m, [])

    cond do
    	char < Enum.at(m_range, 0) -> aliases_categories_rec(l, m - 1, char, cats)
      char > Enum.at(m_range, 1) -> aliases_categories_rec(m + 1, r, char, cats)
    	true ->
        code_2 = Enum.at(m_range, 2, [])
        code_3 = Enum.at(m_range, 3, [])

        {
          Map.get(cats, "iso_15924_aliases", []) |> Enum.at(code_2),
          Map.get(cats, "categories", []) |> Enum.at(code_3)
        }
    end
  end

  defp aliases_categories_rec(_, _,_, _), do: {"Unknown", "Zzzz"}


  @spec unique_aliases(String.t()) :: MapSet.t()
  def unique_aliases(string) do
    unique_aliases(string, get_categories())
  end

  @spec unique_aliases(any(), map()) :: MapSet.t()
  def unique_aliases(string, cats) do
    to_charlist(string)
    |> Enum.map(& aliaz(&1, cats))
    |> MapSet.new()
  end

  @spec aliaz(char()) :: map()
  def aliaz(char) do
    aliaz(char, get_categories())
  end

  @spec aliaz(char(), map()) :: map()
  def aliaz(char, cats) do
    char
    |> aliases_categories(cats)
    |> elem(0)
  end

  @spec category(char()) :: map()
  def category(char)  do
  	category(char, get_categories())
  end

  @spec category(char(), map()) :: map()
  def category(char, cats)  do
  	char
    |> aliases_categories(cats)
    |> elem(1)
  end
end
