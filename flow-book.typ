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
#import "@preview/in-dexter:0.7.2": index, make-index
#import "@preview/suboutline:0.3.0": suboutline
#import "@preview/hydra:0.6.3": hydra

// Put a side note. Usage:
// ```
// foo#sidenote[This is a side note]
// ```
#let sidenote = marginalia.note.with(
  anchor-numbering: (.., n) => super(text(fill: eastern)[#numbering("a", n)]),
  numbering: (.., n) => super(text(fill: eastern)[#numbering("a", n)#h(2pt)]),
)

// Put an indexed term. Usage:
// ```
// This is called #indexed[Computation Offloading].
// That is called #indexed(fmt: strong)[Reverse Computation Offloading].
// ```
#let indexed(term) = {
  term + index(term)
}

// The entry point. Usage:
// ```
// #show flow-book.with(title: "My Awesome Book", ...)
//
// Your content here.
// ```
#let flow-book(
  title: "",
  subtitle: "",
  titlehead: "",
  author: "",
  publisher: "",
  display-build-date: false,
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
  margin-note-width: 5.2cm,
  body,
) = {
  // --- HELPER FUNCTION ---
  // Forces the next content to start on an odd-numbered (right-hand) page
  let odd-pagebreak() = {
    pagebreak(to: "odd", weak: true)
  }

  // ------------------------------- FRONTMATTER -------------------------------
  odd-pagebreak()
  /*Cover page*/
  [
    #text[#titlehead]
    #align(center)[
      #v(1fr)
      #text(size: 2.5em, weight: "bold")[#title] \
      #v(1em)
      #text(size: 1.5em, weight: "bold")[#subtitle] \
      #if display-build-date {
        v(1em)
        text(size: 1.5em)[#datetime.today().display()]
      }
      #v(2fr)
      #text(size: 1.5em)[#author]
      #v(1em)
      #text(size: 1.5em)[#publisher]
      #v(1fr)
    ]
  ]

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
      // If it's a level-1 heading
      numbering("1.", ..vals)
    } else {
      // If it's a subheading
      numbering("1.1", ..vals)
    }
  })

  // Configure marginalia layout (side notes)
  let note-width = margin-note-width
  let note-sep = 1em
  let breakout-width = note-width + note-sep
  show: marginalia.setup.with(
    outer: (width: note-width, sep: note-sep, far: 2cm),
    book: true, // Alternates margins per page
  )

  // Configure the page number position
  set page(
    numbering: "1",
    number-align: center + top,
    header: context {
      let current-page = here().page()

      let heading-to-show = none
      // 1. Look for a level-1 heading starting on this EXACT page
      let headings-on-page = query(heading.where(level: 1)).filter(h => h.location().page() == current-page)
      if headings-on-page.len() > 0 {
        heading-to-show = headings-on-page.first()
      } else {
        // 2. Look for a level-2 heading starting on this EXACT page
        let headings-on-page = query(heading.where(level: 2)).filter(h => h.location().page() == current-page)
        if headings-on-page.len() > 0 {
          heading-to-show = headings-on-page.first()
        } else {
          // 3. Fall back to the most recent level-2 heading from past pages
          let past-headings = query(heading.where(level: 2).before(here()))
          if past-headings != () {
            heading-to-show = past-headings.last()
          }
        }
      }

      // If there's a heading to show, extract its number and construct the layout
      if heading-to-show != none {
        let chapter-num = counter(heading).at(heading-to-show.location())
        let (formatted-num, formatted-heading) = if heading-to-show.level == 1 {
          (
            box(width: 1cm)[
              #text(size: 2.5em, weight: "bold")[
                #numbering("1.1", ..chapter-num)
              ]
            ],
            [],
          )
        } else {
          (
            box(width: 1cm)[
              #text(style: "italic")[#numbering("1.1", ..chapter-num)]
            ],
            text(style: "italic")[#heading-to-show.body],
          )
        }

        let line = box(line(length: 10em, angle: 90deg, stroke: 0.8pt))

        let page_num = counter(page).get().first()
        let align_side = if calc.odd(page_num) { right } else { left }
        if calc.even(page_num) {
          let wide-block = block(
            width: 100% + breakout-width,
            align(align_side, [#formatted-num#h(1em)#line#h(1em)#formatted-heading]),
          )
          move(dx: -breakout-width, wide-block)
        } else {
          let wide-block = block(
            width: 100% + breakout-width,
            align(align_side, [#formatted-heading#h(1em)#line#h(1em)#formatted-num]),
          )
          wide-block
        }
      }
    },
    footer: context {
      let page_num = counter(page).get().first()
      let align_side = if calc.odd(page_num) { right } else { left }
      let wide-block = block(
        width: 100% + breakout-width,
        align(align_side, text[#page_num]),
      )
      if calc.even(page_num) {
        move(dx: -breakout-width, wide-block)
      } else {
        wide-block
      }
    },
  )

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

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    counter(footnote).update(0)
    marginalia.notecounter.update(0)

    // Inject the mini-TOC right below it
    if show-chapter-outline {
      marginalia.note(
        numbering: none,
        block(
          width: note-width,
          text(style: "italic")[
            #suboutline(depth: 2)
          ],
        ),
      )
    }

    text(size: 1.2em)[#it] // Render the title
    v(1.5em)
  }

  show heading.where(level: 2): it => {
    v(1em)
    it // Render the title
    v(1em)
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
    columns(2)[#make-index(use-page-counter: true)]
  }
}
