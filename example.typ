#import "flow-book.typ" as book

#set text(font: "Palatino")
#show math.equation: set text(font: "STIX Two Math")

#show: book.setup.with(
  title: "The Flow Book Template",
  subtitle: text(style: "italic")[Featuring side notes and more],
  title-head: "Typst template",
  author: "Leedehai",
  publisher: "The Typst Community",
  versioning: (build-date-pattern: "[year]-[month]-[day]", version: "v0.1.0"),
  paper-size: "us-letter",
  copyright-page: [
    #align(bottom)[
      © 2026 Leedehai.
    ]
  ],
  dedication-page: [
    #include "example-dedication.typ"
  ],
  show-table-of-contents: true,
  show-index: true,
)

= Introduction
Welcome to the main body of the book. As you can see, the page numbering has restarted at 1.

We can easily drop a side note into the alternating margin reserved by our package#footnote[This is a footnote] layout #book.note[This is a side note].

If you want to index a specific term, like Typst, you just call it like this #book.indexed[Typst] #book.indexed[$Omega$-vibration]. It will automatically appear in the Term Index at the back of#footnote[This is a footnote #lorem(20)] the book#book.note[This is a side note. #lorem(20)].

== Welcome

#lorem(200)#book.note[This is a side note. #lorem(20)]

#lorem(200)#footnote[This is a footnote #lorem(20)]

== Further words and words and words

A#book.note[This is a side note. #lorem(20)] #lorem(200)

#lorem(200)

= Discussion

== Image

== CeTZ

== Table

= Conclusion

#lorem(200)#book.note[This is a side note. #lorem(20)]#footnote[This is a footnote]
