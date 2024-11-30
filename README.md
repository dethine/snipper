# snipper

Quick and dirty Renoise utility for making it easy to play around with sliced
breakbeats turned into phrases via *Selection -> Render to slices*.

This tool is very much inspired by the excellent
[BreakPal](https://github.com/MikePehel/breakpal).

Download the latest version from
[Releases](https://github.com/dethine/snipper/releases). Double-click the XRNX
or drag it into your Renoise instance to install it.

## Why does this exist?

See [Groovin in G's excellent
video](https://www.youtube.com/watch?v=ZEuy7SxvuZM&t=1383s) on how to turn
breakbeats into phrases in Renoise. This reconstructs the original breakbeat
using your slices, and allows you to easily apply modulations like volume ADSRs
and filters to individual hits.

There's a catch: What if you want to trigger the breakbeat from a specific
point, like a shuffle or juicy kick? If you simply copy-paste those parts into a
new phrase, your timing will be off, as the delay column is used to express the
original groove. Usually you end up resampling or quantizing by hand.

This tool **solves that problem** by *yoinking*, removing any delay from the
first hit, then adjusting the delays of subsequent hits. You can then use this
to carve out parts of the original break and create nice, snappy phrases that
are easy to trigger when making breakcore, while still being able to modulate
the hits as desired.

## What's added

This tool adds new features to the menu in the phrase editor (right-click):

- *Yoink from every note* creates individual phrases starting at each subsequent
  slice, containing the remainder of the phrase. This is great for jams and
  recreates the experience of playing around with individual slices, but with
  the benefit of being able to modulate every slice.
- *Selection -> Yoink into new phrase*
- *Selection -> Loop/unloop*. This is mostly to make it easy to select parts of
  the phrase, inspect it and then optionally yoink it into a new phrase.
- *Yoink* and *yoink into new phrase* are mostly useful for fixing phrases
  created by manually copying and pasting phrases.

If yoinking creates a new phrase, empty lines in the beginning will be removed.

If the **[playback
mode](https://tutorials.renoise.com/wiki/Phrase_Editor#Phrase_Controls)** is set
to **keymap**, the new phrase is mapped into an unused note. This is done in
order to make it easy and convenient to play around with your new phrases.

## Workflow tips and suggestions

- Chop your break as usual with slices in Renoise. Feel free to be precise and
  slice up individual roll hits, since this tool makes it easy to trigger them!
- Click *Modulation* and add some pitch adjustments, volume ADSR etc. until you
  like what you're hearing when playing the slices manually.
- Right click the waveform and select *Slices -> Render to slices*
- Go into the phrase editor by clicking *Phrases*
- **Sonic mode:** Enable keymap in the bottom right, right click phrase, *Yoink from
  every note* and start mashing your keyboard or MIDI controller.
- **Snippet curation mode:** Find a nice shuffle. Use *Selection -> Loop/unloop*
  to make sure the selection sounds good. *Selection -> Yoink into new phrase*.
    - Select *Transpose* as your key tracking mode. Set the base note to
      something that sounds cool. Increase the width of the area in the piano
      roll allocated to your phrase. Congratulations, you can now play a cool
      Amen shuffle at multiple pitches. For good measure, duplicate it and make
      multiple copies with half and twice the LPB.

## Bugs and known issues

This is a PoC tool and only lightly tested. If you see any unexpected behavior,
please create an issue and let me know. Please include a description of the
problem, and if possible a copy of the phrase or instrument with the issue.