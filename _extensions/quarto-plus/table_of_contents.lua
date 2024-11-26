-- Function to insert list of tables, list of figures, and table of contents
function Div(el)
  quarto.log.debug("Processing Div element")

  -- Check for '.list_of_tables' class
  if el.classes:includes(".list_of_tables") then
    quarto.log.debug("Div element includes '.list_of_tables' class. Inserting List of Tables")

    -- OOXML content to insert a TOC for tables: \c "Table"
    local ooxml = [[
    <w:p>
      <w:r>
        <w:fldChar w:fldCharType="begin" w:dirty="true"/>
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"> TOC \h \z \c "Table" </w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </w:p>
    ]]

    -- Insert the RawBlock into the div content
    table.insert(el.content, pandoc.RawBlock('openxml', ooxml))

    quarto.log.debug("List of Tables RawBlock inserted into Div element")

    return el

  -- Check for '.list_of_figures' class
  elseif el.classes:includes(".list_of_figures") then
    quarto.log.debug("Div element includes '.list_of_figures' class. Inserting List of Figures")

    -- OOXML content to insert a TOC for figures: \c "Figure"
    local ooxml = [[
    <w:p>
      <w:r>
        <w:fldChar w:fldCharType="begin" w:dirty="true"/>
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"> TOC \h \z \c "Figure" </w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </w:p>
    ]]

    -- Insert the RawBlock into the div content
    table.insert(el.content, pandoc.RawBlock('openxml', ooxml))

    quarto.log.debug("List of Figures RawBlock inserted into Div element")

    return el

  -- Check for '.toc' class
  elseif el.classes:includes(".toc") then
    quarto.log.debug("Div element includes '.toc' class. Inserting Table of Contents")

    -- OOXML content to insert a TOC for headings: \o "1-3"
    local ooxml = [[
    <w:p>
      <w:r>
        <w:fldChar w:fldCharType="begin" w:dirty="true"/>
      </w:r>
      <w:r>
        <w:instrText xml:space="preserve"> TOC \o "1-3" \h \z \u </w:instrText>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="separate"/>
      </w:r>
      <w:r>
        <w:t>Right-click to update field</w:t>
      </w:r>
      <w:r>
        <w:fldChar w:fldCharType="end"/>
      </w:r>
    </w:p>
    ]]

    -- Insert the RawBlock into the div content
    table.insert(el.content, pandoc.RawBlock('openxml', ooxml))

    quarto.log.debug("Table of Contents RawBlock inserted into Div element")

    return el

  else
    quarto.log.debug("Div element does not match to classes: .list_of_tables, .list_of_figures, or .toc. No changes made")
  end
end
