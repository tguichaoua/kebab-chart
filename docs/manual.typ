#import "@preview/mantys:1.0.2": *

#show: mantys(
  ..toml("../typst.toml"),

  title: "Kebab Chart",
  date: datetime.today(),

  // abstract: [
  //   #lorem(50)
  // ],

  // examples-scope: (
  //   scope: (:),
  //   imports: (:)
  // )

  // theme: themes.modern
)

#let show-module(name, scope: (:), outlined: true) = tidy-module(
  name,
  read("../src/" + name + ".typ"),
  scope: scope,
)

// = About
// #lorem(50)

// = Usage
// #lorem(50)

= Available commands

#show-module("chart")
