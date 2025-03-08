# ConfusableHomoglyphs

> This is elixir version of golang [lib](https://github.com/SkygearIO/go-confusable-homoglyphs/) which is version of python [lib](https://github.com/vhf/confusable_homoglyphs)

a homoglyph is one of two or more graphemes, characters, or glyphs with shapes that appear identical or very similar wikipedia:Homoglyph

Unicode homoglyphs can be a nuisance on the web. Your most popular client, AlaskaJazz, might be upset to be impersonated by a trickster who deliberately chose the username ΑlaskaJazz.

    AlaskaJazz is single script: only Latin characters.
    ΑlaskaJazz is mixed-script: the first character is a greek letter.

You might also want to avoid people being tricked into entering their password on www.micros﻿оft.com or www.faϲebook.com instead of www.microsoft.com or www.facebook.com. Here is a utility to play with these confusable homoglyphs.

Not all mixed-script strings have to be ruled out though, you could only exclude mixed-script strings containing characters that might be confused with a character from some unicode blocks of your choosing.

    Allo and ρττ are fine: single script.
    AlloΓ is fine when our preferred script alias is 'latin': mixed script, but Γ is not confusable.
    Alloρ is dangerous: mixed script and ρ could be confused with p.

# Usage

By default it uses `:persistent_term` for caching data about confusable homoglyphs from `priv/static`.

For initialization `:persistent_term` storage you could execute `ConfusableHomoglyphs.init/0` function.

## But!
You're able to use an alternative ways to keep it by providing `categories` and `confusables` datas as 3th argument to functions.

## Example

### With `ConfusableHomoglyphs.init()`
```
ConfusableHomoglyphs.init()

alias ConfusableHomoglyphs.Confusables

Confusables.dangerous?("AlaskaJazz", []) # false
Confusables.dangerous?("ΑlaskaJazz", []) # true

Confusables.confusable?("microsoft", false, ["latin", "common"]) #[]
Confusables.confusable?("microsоft", false, ["latin", "common"]) #[<not empty>]
```
### With providing categories and confusables

if provided data is the same results would be the similar
```
alias ConfusableHomoglyphs.Confusables

Confusables.dangerous?("AlaskaJazz", [], %{categories: categories, confusables: confusables}) # false
Confusables.dangerous?("ΑlaskaJazz", [], %{categories: categories, confusables: confusables}) # true

Confusables.find_confusables("microsoft", false, ["latin", "common"], %{categories: categories, confusables: confusables}) #[]
Confusables.find_confusables("microsоft", false, ["latin", "common"], %{categories: categories, confusables: confusables}) #[<not empty>]
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `confusable_homoglyphs` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:confusable_homoglyphs, git: "https://github.com/vial0ft/confusable_homoglyphs"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/confusable_homoglyphs>.

