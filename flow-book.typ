// Copyright 2026 Leedehai.
// Use of this code is governed by a MIT license in the LICENSE.txt file.
// Repository: https://github.com/Leedehai/typst-flow-book
//
// Usage:
// ```
// #show flow-book.with(title: "My Awesome Book", ...)
//
// Your content here.
// ```

#import "@preview/marginalia:0.3.1" as marginalia
#import "@preview/in-dexter:0.7.2": make-index
#import "@preview/suboutline:0.3.0": suboutline

// Put a side note. Usage:
// ```
// foo#sidenote[This is a side note]
// ```
#let sidenote = marginalia.note.with(
  anchor-numbering: (.., n) => super(text(fill: eastern)[#numbering("a", n)]),
  numbering: (.., n) => super(text(fill: eastern)[#numbering("a", n)#h(2pt)]),
)

// The entry point. Usage:
// ```
// #show flow-book.with(title: "My Awesome Book", ...)
//
// Your content here.
// ```
#let flow-book(
  title: "",
  author: "",
  cover-page: none,
  copyright-page: none,
  opening-page: none,
  dedication-page: none,
  foreword: none,
  preface: none,
  show-table-of-contents: false,
  show-list-of-figures: false,
  show-list-of-tables: false,
  show-chapter-outline: true, // New parameter to toggle chapter mini-outlines
  appendix: none,
  show-index: false,
  body,
) = {
  // --- HELPER FUNCTION ---
  // Forces the next content to start on an odd-numbered (right-hand) page
  let odd-pagebreak() = {
    pagebreak(to: "odd", weak: true)
  }

  // ------------------------------- FRONTMATTER -------------------------------
  if cover-page != none {
    odd-pagebreak()
    cover-page
  }

  if copyright-page != none {
    pagebreak(weak: true)
    copyright-page
  }

  if opening-page != none {
    odd-pagebreak()
    opening-page
  }

  if dedication-page != none {
    odd-pagebreak()
    dedication-page
  }

  if foreword != none {
    odd-pagebreak()
    counter(heading).update(0)
    heading(level: 1, numbering: none)[Foreword]
    foreword
  }

  if preface != none {
    odd-pagebreak()
    counter(heading).update(0)
    heading(level: 1, numbering: none)[Preface]
    preface
  }

  if show-table-of-contents {
    odd-pagebreak()
    outline(title: [Table of Contents], indent: auto)
  }

  if show-list-of-figures {
    odd-pagebreak()
    outline(title: [List of Figures], target: figure.where(kind: image))
  }

  if show-list-of-tables {
    odd-pagebreak()
    outline(title: [List of Tables], target: figure.where(kind: table))
  }

  // -------------------------------- MAIN BODY --------------------------------
  odd-pagebreak()
  counter(heading).update(0)
  counter(page).update(1)

  set super(size: 0.8em)

  // Align main body text to both the left and right margins
  set par(justify: true)

  // Configure hierarchical chapter numbering
  set heading(numbering: (..nums) => {
    let vals = nums.pos() // Get the current heading numbers as an array

    if vals.len() == 1 {
      // If it's a Level 1 heading, output "Chapter X"
      "Chapter " + str(vals.first())
    } else {
      // If it's a subheading, use standard "1.1" decimal numbering
      numbering("1.1", ..vals)
    }
  })

  // Configure marginalia layout (side notes)
  let note-width = 5.2cm
  let note-sep = 1em
  let breakout-width = note-width + note-sep
  show: marginalia.setup.with(
    outer: (width: note-width, sep: note-sep, far: 2cm),
    book: true, // Alternates margins per page
  )

  // Configure the page number position
  set page(numbering: "1", footer: context {
    let page_num = counter(page).get().first()
    let align_side = if calc.odd(page_num) { right } else { left }
    let wide-block = block(width: 100% + breakout-width, align(align_side, str(page_num)))
    if calc.even(page_num) {
      move(dx: -breakout-width, wide-block)
    } else {
      wide-block
    }
  })

  // Remove the separator from the footnote.entry rule, because it
  // is hard to get the starting point of the separator line right,
  // given there is a margin.
  set footnote.entry(separator: none)

  // Forces the footnote text to span the text block + margin width
  // and forces the entry body to appear like an enumerated list entry
  show footnote.entry: it => context {
    let page-num = counter(page).get().first()
    let loc = it.note.location()
    let num = counter(footnote).at(loc).first()
    let enum-like-entry = enum(
      numbering: "1",
      body-indent: 1em,
      enum.item(num)[#it.note.body],
    )
    let wide-block = block(width: 100% + breakout-width, enum-like-entry)
    if calc.even(page-num) {
      move(dx: -breakout-width, wide-block)
    } else {
      wide-block
    }
  }

  // Configure chapter page start and mini-outlines
  // Applies to all Level 1 headings in the main body
  show heading.where(level: 1): it => {
    pagebreak(weak: true)

    it // Render the chapter title

    // Inject the mini-TOC right below it
    if show-chapter-outline {
      v(0.5em)
      pad(left: 1.5em, right: 1.5em)[
        #suboutline(depth: 2) // Customize depth as needed
      ]
      v(1.5em)
    }
  }

  // Reset counters at each chapter
  show heading.where(level: 1): it => {
    counter(footnote).update(0)
    marginalia.notecounter.update(0)
    it
  }

  body // This is the main body

  // ------------------------------- BACKMATTER --------------------------------
  // Disable the chapter outline show rule for backmatter
  show heading.where(level: 1): it => it

  if appendix != none {
    odd-pagebreak()
    heading(level: 1, numbering: none)[Appendix]
    appendix
  }

  if show-index {
    odd-pagebreak()
    heading(level: 1, numbering: none)[Index]
    make-index()
  }
}
