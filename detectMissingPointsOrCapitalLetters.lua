script_author = "zhH"
script_version = "0.2"
script_name = "Detect missing points or capital letters"
script_description =
    "Warn potentially sentences which need a point or capital letter"
script_modified = "10/04/2021"

--- Start script to detect missiong points or capital letter.
---@param subs table: Table of subs
function startScript(subs)

    -- Index of 1st dialogue in subs
    local firstlineIdx = nil
    local sub
    aegisub.progress.task(script_description)

    for i = 1, #subs, 1 do
        sub = subs[i]

        if sub.class == 'dialogue' then

            if firstlineIdx == nil then firstlineIdx = i end

            if not sub.comment then
                nextText = ''
                previousText = ''

                if i < #subs and subs[i + 1].class == 'dialogue' then
                    nextText = subs[i + 1].text
                end

                if i > 1 and subs[i - 1] ~= nil and subs[i - 1].class ==
                    'dialogue' then
                    previousText = subs[i - 1].text
                end
                currentLineNumber = i - firstlineIdx + 1
                detectMissingPoint(sub.text, nextText, currentLineNumber,
                                   sub.style)
                detectMissingCapitalLetter(sub.text, previousText,
                                           currentLineNumber, sub.style)
            end
        end
    end
end

--- Check and detect a missing point in the current line.
---@param text string: Text of the current line
---@param nextText string: Next text in the next line
---@param currentLineNumber number: Number of current line
---@param style string: The name of style used for the current text
function detectMissingPoint(text, nextText, currentLineNumber, style)
    text = cleanTagsAndDashes(text)
    nextText = cleanTagsAndDashes(nextText)

    noPointAtTheEndRegex =
        '[a-zàèìòùáéíóúýâêîôûãñõäëïöüÿ]$'
    startsWithCapitalLetter = '^[A-Z]'

    if text:find(noPointAtTheEndRegex) then
        if nextText:find(startsWithCapitalLetter) or
            startsWithAccentedLetterOrCapitalLetterAccented(nextText, true) then
            aegisub.log('\n Line: ' .. currentLineNumber)
            aegisub.log('\n Style: ' .. style)
            aegisub.log('\n [Point] Warning line -> ' .. text)
            aegisub.log('\n [Point] Next line -> ' .. nextText)
            aegisub.log('\n')
        end
    end
end

--- Check and detect a missing capital Letter in the current line.
---@param text string: Text of the current line
---@param previousText string: Preivous text in the previous line
---@param currentLineNumber number: Number of current line
---@param style string: The name of style used for the current text
function detectMissingCapitalLetter(text, previousText, currentLineNumber, style)
    text = cleanTagsAndDashes(text)
    previousText = cleanTagsAndDashes(previousText)

    startsWithNoCapitalLetterRegex = '^[a-z]'
    endsWithEndPunctuation = '[!?:."»]$'

    if text:find(startsWithNoCapitalLetterRegex) or
        startsWithAccentedLetterOrCapitalLetterAccented(text, false) then
        if previousText:find(endsWithEndPunctuation) then
            aegisub.log('\n Line: ' .. currentLineNumber)
            aegisub.log('\n Style: ' .. style)
            aegisub.log('\n [Capital Letter] Previous line -> ' .. previousText)
            aegisub.log('\n [Capital Letter] Warning line -> ' .. text)
            aegisub.log('\n')
        end
    end
end

--- Check if a text starts with an accented letter or a capital letter accented.
---@param text string: Text to check
---@return boolean: True if the text starts with an accented letter or a capital letter accented
function startsWithAccentedLetterOrCapitalLetterAccented(text,
                                                         checkCapitalLetter)

    test1 = "^à"
    test2 = "^é"
    test3 = "^è"
    test4 = "^ê"
    test5 = "^ô"
    test6 = "^î"
    test7 = "^ç"
    test8 = "^œ"

    if checkCapitalLetter then
        test1 = "^À"
        test2 = "^É"
        test3 = "^È"
        test4 = "^Ê"
        test5 = "^Ô"
        test6 = "^Î"
        test7 = "^Ç"
        test8 = "^Œ"
    end

    if text:find(test1) or text:find(test2) or text:find(test3) or
        text:find(test4) or text:find(test5) or text:find(test6) or
        text:find(test7) or text:find(test8) then
        return true
    else
        return false
    end
end

--- Clean tags and dashes in a text
---@param text string: Text to clean
---@return string: The text cleaned
function cleanTagsAndDashes(text)
    textCleaned = text
    detectTagsRegex = '{[*>]?\\[^}]-}'
    textCleaned = textCleaned:gsub(detectTagsRegex, '')
    textCleaned = textCleaned:gsub(' ', ' ')
    textCleaned = textCleaned:gsub(' ', ' ')
    textCleaned = textCleaned:gsub('- ', '')
    textCleaned = textCleaned:gsub('– ', '')
    textCleaned = textCleaned:gsub('— ', '')
    return textCleaned
end

---------------------------------------------------------------------
---- Macro Registrations - need to stay at the end of the script ----
---------------------------------------------------------------------
aegisub.register_macro(script_name, script_description, startScript)
