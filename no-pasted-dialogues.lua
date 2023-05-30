script_author = "hyyahou"
script_version = "0.1"
script_name = "No pasted dialogues"
script_description = "Sélectionner les dialogues collés entre eux ou entre une keyframe et les séparés de 3 frames"
script_modified = "29/05/2023"

--- Start script.
function startScript(subs, sel)
    timeToframe = aegisub.frame_from_ms
    frameToTime = aegisub.ms_from_frame
    keyframes = aegisub.keyframes()
    subsLength = tableLength(sel)

    -- Pour chaque ligne sélectionnées
    for k, i in ipairs(sel) do
        currentLine = subs[sel[k]]
        startFrame1 = timeToframe(currentLine.start_time)

        -- Pour le cas du dernier sélectionné ou si 1 ligne est sélectionnée
        if subsLength == k and currentLine.class == 'dialogue' and not currentLine.comment then
            if table_contains(keyframes, startFrame1) then

                -- Si la frame de début est égale au keyframe, alors ajouter 3 frames
                currentLine.start_time = frameToTime(startFrame1 + 3)
                subs[sel[k]] = currentLine
            end
            break
        end

        nextLine = subs[sel[k + 1]]

        -- Dans les autres cas
        if currentLine.class == 'dialogue' and nextLine.class == 'dialogue' and not currentLine.comment and not nextLine.comment then
            endFrame1 = timeToframe(currentLine.end_time)
            startFrame2 = timeToframe(nextLine.start_time)
            endFrame2 = timeToframe(nextLine.end_time)

            -- Si la frame de fin est égale au keyframe et de même pour la frame de début de la ligne suivante, alors ajouter 3 frames de ligne suivante
            if table_contains(keyframes, endFrame1) and (endFrame1 == startFrame2 or startFrame2 - endFrame1 == 1) then
                nextLine.start_time = frameToTime(startFrame2 + 3)
                subs[sel[k + 1]] = nextLine

            -- Si 2 lignes sont collées, alors reculer de 2 frames à la ligne sélectionnée et ajouter 1 frame à la ligne suivante
            elseif endFrame1 == startFrame2 or startFrame2 - endFrame1 == 1 then
                currentLine.end_time = frameToTime(endFrame1 - 2)
                nextLine.start_time = frameToTime(startFrame2 + 1)
                subs[sel[k]] = currentLine
                subs[sel[k + 1]] = nextLine
            end

            -- Si la frame de début est égale au keyframe, alors ajouter 3 frames
            if table_contains(keyframes, startFrame1) then
                currentLine.start_time = frameToTime(startFrame1 + 3)
                subs[sel[k]] = currentLine
            end
        end
    end
end

-- Savoir si une valeur est contenue dans une table
function table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then 
            found = true 
        end
    end
    return found
end

-- Savoir la taille d'une table
function tableLength(tbl)
  local count = 0
  for k, i in ipairs(tbl) do count = count + 1 end
  return count
end


---------------------------------------------------------------------
---- Macro Registrations - need to stay at the end of the script ----
---------------------------------------------------------------------
aegisub.register_macro(script_name, script_description, startScript)
