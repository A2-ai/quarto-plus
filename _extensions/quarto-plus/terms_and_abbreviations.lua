-- Specify the filenames
local abbrFile = "formatting_files/abbreviations.tex"
local logFile = "unmatched_glossary_terms.json"

-- Function to read in .tex file
local function readFromFile(filename)
    quarto.log.debug("Attempting to read from file: " .. filename)
    -- Open in read mode
    local file = io.open(filename, "r")
    if file then
        local content = file:read("*all")
        file:close()
        quarto.log.debug("Successfully read from file: " .. filename)
        return content
    else
        quarto.log.warning("Failed to read from file: " .. filename)
        error("Could not open file to read: " .. filename)
    end
end

-- Function to append log file
local function writeToFile(filename, content)
    quarto.log.debug("Attempting to write to file: " .. filename)
    -- Open in append mode
    local file = io.open(filename, "a")
    if file then
        file:write(content .. "\n")
        file:close()
        quarto.log.debug("Successfully wrote to file: " .. filename)
    else
        quarto.log.warning("Could not open file for writing: " .. filename)
        error("Could not open file for writing: " .. filename)
    end
end

-- Function to initialize or clear log file
local function initializeLogFile(filename)
    quarto.log.debug("Initializing log file: " .. filename)
    -- Open in write mode to overwrite the file
    local file = io.open(filename, "w")
    if file then
        file:write("")
        file:close()
        quarto.log.debug("Successfully initialized log file: " .. filename)
    else
        quarto.log.warning("Could not open file to initialize: " .. filename)
        error("Could not open file to initialize: " .. filename)
    end
end

-- Initialize the log file (clear previous content per render)
initializeLogFile(logFile)

-- Read the contents of the file
local inputText = readFromFile(abbrFile)

-- Function to generate acronymTable
local function getAcronymTable(inputText)
    quarto.log.debug("Parsing acronym table from input text")
    local acronymTable = {}
    if inputText ~= nil then
        for line in inputText:gmatch("[^\r\n]+") do
            -- Skip lines that start with % (internal comments)
            if not line:match("^%%") then
                local sortingKey, acronym, lookupValue = line:match("\\newacronym{([^}]+)}{([^}]+)}{([^}]+)}")
                if acronym and sortingKey and lookupValue then
                    acronymTable[acronym] = { lookupValue, sortingKey }
                    quarto.log.debug("Parsed acronym: " .. acronym .. " with expansion: " .. lookupValue)
                else
                    quarto.log.warning("Failed to parse line in input text: " .. line)
                end
            else
                quarto.log.debug("Skipped comment line: " .. line)
            end
        end
    else
        quarto.log.warning("Input text is nil. No acronyms were parsed")
    end
    return acronymTable
end


-- Generate acronymTable for the render process
local acronymTable = getAcronymTable(inputText)

-- Establish empty list for the render process
local seenAcronyms = {}

return {
    {
        RawInline = function(r)
            local text = r.text
            -- Check for \\Glspl
            if text:sub(1, 6) == "\\Glspl" then
                local replacement = text:match("\\Glspl{([^}]*)}")
                if replacement then
                    local expansion = acronymTable[replacement]
                    if expansion and not seenAcronyms[replacement] then
                        seenAcronyms[replacement] = true
                        quarto.log.debug("Expanding acronym: " .. replacement .. " to: " .. expansion[1] .. "s")
                        -- Capitalizes content and then pluralize
                        return pandoc.read(expansion[1]:sub(1, 1):upper() ..
                        expansion[1]:sub(2) .. "s (" .. replacement .. "s)").blocks[1].content
                    elseif not expansion then
                        quarto.log.warning("Unmatched glossary term: " .. replacement)
                        -- Log the unmatched glossary term
                        writeToFile(logFile, replacement)
                    end
                    return pandoc.read(replacement .. "s").blocks[1].content
                end
                -- Check for \\glspl
            elseif text:sub(1, 6) == "\\glspl" then
                local replacement = text:match("\\glspl{([^}]*)}")
                if replacement then
                    local expansion = acronymTable[replacement]
                    if expansion and not seenAcronyms[replacement] then
                        seenAcronyms[replacement] = true
                        quarto.log.debug("Expanding acronym: " .. replacement .. " to: " .. expansion[1]:lower() .. "s")
                        -- Uncapitalize the content and then pluralize
                        return pandoc.read(expansion[1] .. "s (" .. replacement .. "s)").blocks[1].content
                    elseif not expansion then
                        quarto.log.warning("Unmatched glossary term: " .. replacement)
                        -- Log the unmatched glossary term
                        writeToFile(logFile, replacement)
                    end
                    return pandoc.read(replacement .. "s").blocks[1].content
                end
                -- Check for \\gls
            elseif text:sub(1, 4) == "\\gls" then
                local replacement = text:match("\\gls{([^}]*)}")
                if replacement then
                    local expansion = acronymTable[replacement]
                    if expansion and not seenAcronyms[replacement] then
                        seenAcronyms[replacement] = true
                        quarto.log.debug("Expanding acronym: " .. replacement .. " to: " .. expansion[1]:lower())
                        -- Uncapitalize the content
                        return pandoc.read(expansion[1] .. " (" .. replacement .. ")").blocks[1].content
                    elseif not expansion then
                        quarto.log.warning("Unmatched glossary term: " .. replacement)
                        -- Log the unmatched glossary term
                        writeToFile(logFile, replacement)
                    end
                    return pandoc.read(replacement).blocks[1].content
                end
                -- Check for \\Gls
            elseif text:sub(1, 4) == "\\Gls" then
                local replacement = text:match("\\Gls{([^}]*)}")
                if replacement then
                    local expansion = acronymTable[replacement]
                    if expansion and not seenAcronyms[replacement] then
                        seenAcronyms[replacement] = true
                        quarto.log.debug("Expanding acronym: " ..
                        replacement .. " to: " .. expansion[1]:sub(1, 1):upper() .. expansion[1]:sub(2):lower())
                        -- Capitalize content
                        return pandoc.read(expansion[1]:sub(1, 1):upper() ..
                        expansion[1]:sub(2) .. " (" .. replacement .. ")").blocks[1].content
                    elseif not expansion then
                        quarto.log.warning("Unmatched glossary term: " .. replacement)
                        -- Log the unmatched glossary term
                        writeToFile(logFile, replacement)
                    end
                    return pandoc.read(replacement).blocks[1].content
                end
            end
            return r
        end,
    },
    {
        Div = function(div)
            quarto.log.debug("Processing Div with classes: " .. table.concat(div.classes, ", "))
            -- Parses document for div elements that have '.abbreviations' class
            if div.classes:includes(".abbreviations") then
                local sortedKeys = {}
                for key, _ in pairs(seenAcronyms) do
                    table.insert(sortedKeys, key)
                end
                -- Sort using the plain-text sorting key
                table.sort(sortedKeys, function(a, b)
                    -- Compare using sorting key
                    return acronymTable[a][2]:lower() < acronymTable[b][2]:lower()
                end)
                quarto.log.debug("Generating acronym table for Div")
                local tableString = "| | | \n| :------ | :---------- | \n"
                for _, key in ipairs(sortedKeys) do
                    -- Generate the table with acronym not in bold and expansion from the table
                    tableString = tableString ..
                    "| " ..
                    key .. " | " .. acronymTable[key][1]:sub(1, 1):upper() .. acronymTable[key][1]:sub(2) .. " | \n"
                end
                local maybeTable = pandoc.read(tableString, "markdown")
                quarto.log.debug("Acronym table generated successfully")
                return maybeTable.blocks
            end
        end
    }
}
