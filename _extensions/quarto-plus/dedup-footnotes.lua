local dedup_footnotes = true
local footnote_style = "Footnote Reference"

local seen_notes = {}
local counter = 0

local function note_to_string(note)
  return pandoc.utils.stringify(note.content)
end

return {
  {
    Meta = function(meta)

      if meta["dedup-footnotes"] ~= nil then
        dedup_footnotes =
          pandoc.utils.stringify(meta["dedup-footnotes"]) == "true"
      end

      if meta["dedup-footnotes-style"] ~= nil then
        footnote_style =
          pandoc.utils.stringify(meta["dedup-footnotes-style"])
      end
    end
  },

  {
    Note = function(el)

      if not dedup_footnotes then
        return el
      end

      local key = note_to_string(el)

      if not seen_notes[key] then
        counter = counter + 1
        seen_notes[key] = counter
        return el
      end

      return pandoc.Span(
        pandoc.Superscript({ pandoc.Str(tostring(seen_notes[key])) }),
        pandoc.Attr("", {}, {{"custom-style", footnote_style}})
      )
    end
  }
}