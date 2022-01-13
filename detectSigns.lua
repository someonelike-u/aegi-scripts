script_author = "Hy"
script_version = "0.1"
script_name = "Detect signs"
script_description = "Detect some signs in subs (for NF or AMZ)"
script_modified = "13/04/2021"

--- Start script to some signs in subs.
---@param subs table: Table of subs
function startScript(subs)
    local sub
    aegisub.progress.task(script_description)
    topStyleExists = false
    signStyleExists = false

    for i = #subs, 1, -1 do
        sub = subs[i]

        if sub.class == 'dialogue' and not sub.comment then
            content = sub.text
            content = deleteAccents(content)

            if content:find('\\an8') or content:find('\\a8') then
                sub.style = 'Top'

                if not topStyleExists then topStyleExists = true end

            else
                sub.style = 'Sign'
                for letter in (content:gmatch('%a')) do

                    -- if it finds a lowercase letter, set the default style
                    if not letter:match('%u') then
                        sub.style = subs[i].style
                        break
                    end
                end

                if not signStyleExists then
                    if sub.style == 'Sign' then
                        signStyleExists = true
                    end
                end

            end

            subs[i] = sub
        end
    end

    if signStyleExists then createNewStyle(subs, 'Sign') end

    if topStyleExists then createNewStyle(subs, 'Top') end
end

--- Create a new style in the subs
---@param subs table: Table of subs
---@param styleName string: The style name to add
function createNewStyle(subs, styleName)
    defaultStyle = nil
    styleNameAlreadyExists = false

    for i = #subs, 1, -1 do
        if defaultStyle == nil and subs[i].class == 'style' and subs[i].name ==
            'Default' then defaultStyle = subs[i] end

        if subs[i].class == 'style' and subs[i].name == styleName then
            styleNameAlreadyExists = true
            break
        end
    end

    if not styleNameAlreadyExists then
        newStyle = defaultStyle
        newStyle.name = styleName
        newStyle.align = 8
        subs.append(newStyle)
    end
end

--- Delete accents
---@param text string: The text to clean
---@return string: A text with no accent
function deleteAccents(text)
    return text:gsub('à', 'a'):gsub('â', 'a'):gsub('ä', 'a'):gsub('é', 'e')
               :gsub('è', 'e'):gsub('ê', 'e'):gsub('ë', 'e'):gsub('ï', 'i')
               :gsub('î', 'i'):gsub('ô', 'o'):gsub('ö', 'o'):gsub('ù', 'u')
               :gsub('û', 'u'):gsub('ü', 'u'):gsub('ÿ', 'y'):gsub('ç', 'c')
               :gsub('À', 'A'):gsub('É', 'E'):gsub('È', 'E'):gsub('Ê', 'E')
               :gsub('Ù', 'U'):gsub('Ô', 'O'):gsub('Î', 'I'):gsub('Ç', 'C')
               :gsub('Œ', 'OE'):gsub('œ', 'oe')
end

---------------------------------------------------------------------
---- Macro Registrations - need to stay at the end of the script ----
---------------------------------------------------------------------
aegisub.register_macro(script_name, script_description, startScript)
