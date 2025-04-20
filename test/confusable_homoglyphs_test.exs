defmodule ConfusableHomoglyphsTest do
  use ExUnit.Case

  alias ConfusableHomoglyphs.Categories
  alias ConfusableHomoglyphs.Confusables

  setup_all do
    ConfusableHomoglyphs.init()
  end

  describe "Confusables" do
    test "mixed_script?" do
      for {str, aliases, mixed?} <- [
            {"Abç", nil, false},
            {"ρτ.τil", false},
            {"ρτ.τ", [], true},
            {"Alloτ", nil, true}
          ] do
        assert Confusables.mixed_script?(str, aliases, Categories.get_categories()) == mixed?
      end
    end

    test "dangerous?" do
      assert Confusables.dangerous?("AlloΓ", ["LATIN"]) == false
    end
  end
end
