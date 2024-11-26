# snapper

det/hine Renoise tool for preparing breakbeats:

- **yoinking**. basically, this is for reusing the tasty groove of the original
  breakbeat, while still being able to do tight, fast chops
  - chop your breakbeat with slices, then do *Slices -> Render Slices to Phrase*
  - *yoinking* removes the delay from the first hit, then adjusts the relative
    delay of all later hits to keep the groove intact
  - if you *yoink* a selection as a new phrase, and keymap is enabled, this tool
    automatically adds a mapping if possible
        - you can even yoink from every note, with the same result
        - this is great for grooveboxes!
- **loop/unloop on selection** makes it less annoying to inspect phrases.
- TODO instrument: add volume ADSR + pitch macro?
- TODO: generators
  - half-time/2x version of phrase
  - euclidian snare?