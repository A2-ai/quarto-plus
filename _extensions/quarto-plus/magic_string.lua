-- Function to insert magic strings before figures
function Para(para)
  quarto.log.debug("Processing paragraph")

  -- Set magic_string and initialize empty tables for temporary storage
  local blocks = {}
  local elements = {}
  local magic_string = "{rpfy}:"

  for i, elem in ipairs(para.content) do
    if elem.t == 'Image' then
      quarto.log.debug("Found an image element. Source: " .. elem.src)

      -- Extract the file name from the full path
      local image_name = elem.src:match("^.+/(.+)$") or elem.src

      -- Insert the magic string with the image name
      table.insert(blocks, pandoc.Para { pandoc.Str(magic_string .. image_name) })

      -- Add the image as a new paragraph
      quarto.log.debug("Inserting image")
      table.insert(blocks, pandoc.Para { elem })
    else
      table.insert(elements, elem)
    end
  end

  -- If there are elements that are not images, add them as a paragraph
  if #elements > 0 then
    quarto.log.debug("Adding non-image elements as a new paragraph")
    table.insert(blocks, pandoc.Para(elements))
  end

  quarto.log.debug("Returning processed blocks")
  return blocks
end
