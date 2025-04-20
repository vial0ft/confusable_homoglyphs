defmodule ConfusableHomoglyphs.Confusables do
  @moduledoc false
  alias ConfusableHomoglyphs.Categories

  defp get_confusables() do
    :persistent_term.get(ConfusableHomoglyphs.Confusables, %{})
  end

  @doc """
  mixed_script? checks if string contains mixed-scripts content,
  excluding script blocks aliases in allowed_aliases.
  E.g. ``B. C`` is not considered mixed-scripts by default: it contains characters
  from Latin and Common, but Common is excluded by default.
  """

  @spec mixed_script?(String.t(), list(String.t())) :: boolean()
  def mixed_script?(string, allowed_aliases) do
    mixed_script?(string, allowed_aliases, Categories.get_categories())
  end

  @spec mixed_script?(String.t(), list(String.t()) | nil, map()) :: boolean()
  def mixed_script?(string, nil, cats), do: mixed_script?(string, ["COMMON"], cats)

  def mixed_script?(string, allowed_aliases, cats) do
    allowed_aliases_set = aliases_set(allowed_aliases)
    uniq_aliases = Categories.unique_aliases(string, cats)

    MapSet.difference(uniq_aliases, allowed_aliases_set)
    |> MapSet.size() > 1
  end

  @doc """
  find_confusable check if str contains characters which might be confusable with
  characters from preferred_aliases.
  If greedy is false, it will only return the first confusable character
  found without looking at the rest of the string, greedy is true returns
  all of them.
  preferredAliases can take an array of unicode block aliases to
  be considered as your 'base' unicode blocks
  """

  @spec find_confusables(String.t(), boolean(), list(String.t())) :: list(map())
  def find_confusables(string, greedy?, preferred_aliases) do
    find_confusables(string, greedy?, preferred_aliases, get_confusables())
  end

  @spec find_confusables(String.t(), boolean(), list(String.t()), map()) :: list(map())
  def find_confusables(string, greedy?, preferred_aliases, %{
        categories: cats,
        confusables: confusables
      }) do
    preferred_aliases_set = aliases_set(preferred_aliases)

    string
    |> to_charlist()
    |> MapSet.new()
    |> Enum.reduce_while([], fn char, acc ->
      char_alias = Categories.aliaz(char, cats)

      case {MapSet.member?(preferred_aliases_set, char_alias),
            Map.get(confusables, char_to_string(char), nil)} do
        {false, found} when not is_nil(found) ->
          potentially_confusable =
            potentially_confusables_rec(
              preferred_aliases_set |> MapSet.to_list(),
              found,
              cats,
              %{break: false, result: []}
            )

          if length(potentially_confusable) > 0 do
            new_confusable = %{
              char: char_to_string(char),
              aliaz: char_alias,
              homoglyphs: potentially_confusable
            }

            new_acc = [new_confusable | acc]

            if greedy?, do: {:cont, new_acc}, else: {:halt, new_acc}
          else
            {:cont, acc}
          end

        _otherwise ->
          {:cont, acc}
      end
    end)
  end

  # character λ is considered confusable if λ can be confused with a character from
  # preferred_aliases, e.g. if 'LATIN', 'ρ' is confusable with 'p' from LATIN.
  # if 'LATIN', 'Γ' is not confusable because in all the characters confusable with Γ,
  # none of them is LATIN.
  defp potentially_confusables_rec([], found, _, _), do: found
  defp potentially_confusables_rec(_, _, _, %{break?: true, result: result}), do: result
  defp potentially_confusables_rec(_, [], _, _), do: []

  defp potentially_confusables_rec(
         [_ | _] = preferred_aliases,
         [%{"c" => symbol} | rest] = found,
         categories,
         acc
       ) do
    result =
      to_charlist(symbol)
      |> Enum.reduce_while(
        acc,
        fn s, acc ->
          a = Categories.aliaz(s, categories)

          if Enum.any?(preferred_aliases, &(&1 == a)) do
            {:halt, %{break?: true, result: found}}
          else
            {:cont, acc}
          end
        end
      )

    potentially_confusables_rec(preferred_aliases, rest, categories, result)
  end

  @doc """
  dangerous? checks if string can be dangerous, i.e. is it not only mixed-scripts
  but also contains characters from other scripts than the ones in preferred_aliases
  that might be confusable with characters from scripts in preferred_aliases.
  """

  @spec dangerous?(String.t(), list(String.t())) :: boolean()
  def dangerous?(string, preferred_aliases) do
    dangerous?(string, preferred_aliases, %{
      categories: Categories.get_categories(),
      confusables: get_confusables()
    })
  end

  @spec dangerous?(String.t(), list(String.t()), %{categories: map(), confusables: map()}) ::
          boolean()
  def dangerous?(
        str,
        preferred_aliases,
        %{categories: cats, confusables: _confusables} = cat_conf
      ) do
    result = find_confusables(str, false, preferred_aliases, cat_conf)
    mixed_script?(str, nil, cats) and length(result) > 0
  end

  defp char_to_string(ch), do: "#{[ch]}"

  defp aliases_set(aliases) do
    aliases
    |> Enum.map(&String.upcase/1)
    |> MapSet.new()
  end
end
