#import "flow-book.typ": flow-book, sidenote
#import "@preview/in-dexter:0.7.2": index
#import "@preview/marginalia:0.3.1" as marginalia

#show: flow-book.with(
  title: "My Awesome Book",
  author: "Jane Doe",
  cover-page: [
    #align(center + horizon)[
      #text(size: 3em, weight: "bold")[My Awesome Book] \
      #text(size: 1.5em)[Jane Doe]
    ]
  ],
  copyright-page: [
    #align(bottom)[
      © 2026 Jane Doe. All rights reserved.
    ]
  ],
  dedication-page: [
    #align(center + horizon)[#include "dedication.typ"]
  ],
  show-table-of-contents: true,
  show-index: true,
)

#set text(font: "Palatino")
#show math.equation: set text(font: "STIX Two Math")

= Introduction
Welcome to the main body of the book. As you can see, the page numbering has restarted at 1.

We can easily drop a side note into the alternating margin reserved by our package#footnote[This is a footnote] layout #sidenote[This is a side note].

If you want to index a specific term, like Typst, you just call it like this #index("Typst"). It will automatically appear in the Term Index at the back of#footnote[This is a footnote #lorem(20)] the book#sidenote[This is a side note. #lorem(20)].

== Welcome

#lorem(200)#sidenote[This is a side note. #lorem(20)]

#lorem(200)#footnote[This is a footnote #lorem(20)]

== Further words

A#sidenote[This is a side note. #lorem(20)] #lorem(200)

#lorem(200)

= Discussion

== Image

== CeTZ

== Table

= Conclusion

#lorem(200)#sidenote[This is a side note. #lorem(20)]#footnote[This is a footnote]
