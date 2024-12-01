_AUTO_RELOAD_DEBUG = function()
    -- do tests like showing a dialog, prompts whatever, or simply do nothing
end


-- shamelessly stolen from https://github.com/MikePehel/breakpal/blob/main/modifiers.lua#L5
local function copy_line(source_line, target_line)
    for note_column_index = 1, 12 do
        local source_note_column = source_line:note_column(note_column_index)
        local target_note_column = target_line:note_column(note_column_index)
        target_note_column:copy_from(source_note_column)
    end

    for effect_column_index = 1, 8 do
        local source_effect_column = source_line:effect_column(effect_column_index)
        local target_effect_column = target_line:effect_column(effect_column_index)
        target_effect_column:copy_from(source_effect_column)
    end
end

local function get_current_phrase()
    local phrase = renoise.song().selected_phrase
    -- local phrase = renoise.song().selected_instrument.phrases[1]
    if phrase == nil then
        renoise.app():show_error("No phrase selected in instrument.")
    end
    return phrase
end

local function get_current_selection()
    local selection = renoise.song().selection_in_phrase
    if selection == nil then
        renoise.app():show_warning("No selection made.")
    end
    return selection
end

---subtracts an set amount of delay from each line. skips empty lines. moves note columns backwards if required
---and there are empty note columns available (in order to avoid side-effects)
---@param phrase renoise.InstrumentPhrase
---@param line_index integer
---@param column_index integer
---@param delay integer
local function fix_column_delay(phrase, line_index, column_index, delay)
    local line = phrase:line(line_index)
    local note_column = line:note_column(column_index)
    local delta = note_column.delay_value - delay
    if delta >= 0 then
        note_column.delay_value = delta
    else
        -- move to previous line, if possible without altering the original pattern
        if not line.is_empty then
            local found_empty_note_column = false
            local previous_line = phrase:line(line_index - 1)
            for k, previous_note_column in ipairs(previous_line.note_columns) do
                if previous_note_column.is_empty then
                    -- TODO should we deal with FX columns?
                    previous_note_column:copy_from(note_column)
                    previous_note_column.delay_value = delta + 255
                    note_column:clear()
                    found_empty_note_column = true
                    break
                end
            end
            if not found_empty_note_column then
                renoise.app():show_warning("Failed to adjust all note offsets (no space), check manually.")
            end
        end
    end
end

---maps phrase to current instrument if keymap mode is enabled for phrases.
---returns true if the phrase was successfully keymapped, false otherwise.
---@param instrument renoise.Instrument
---@param phrase renoise.InstrumentPhrase
---@return boolean
local function keymap_if_possible(instrument, phrase)
    local number_of_pmappings = #instrument.phrase_mappings
    if instrument.phrase_program == 127 then
        for index = 1, number_of_pmappings + 1 do
            if instrument:can_insert_phrase_mapping_at(index) then
                local mapping = instrument:insert_phrase_mapping_at(index, phrase)
                -- clamp note range to make more room for variations etc
                if phrase.mapping ~= nil then
                    phrase.mapping.note_range = { mapping.note_range[1], mapping.note_range[1] }
                end
                return true
            end
        end
    end
    return false
end


---ensure that a phrase begins with a non-empty note with zero delay.
---rewrites the rest of the phrase to retain relative delays.
---@param source_phrase renoise.InstrumentPhrase
---@param start_line integer
---@param stop_line integer
---@param inline boolean
---@return renoise.InstrumentPhrase
local function yoink_phrase(source_phrase, start_line, stop_line, inline)
    print("starting new line from", start_line, "to", stop_line)
    local instrument = renoise.song().selected_instrument
    local target_phrase

    if inline then
        target_phrase = source_phrase
    else
        -- getting inconsistent results from just using
        -- target_phrase:copy_from(source_phrase), target_phrase:clear(), hence
        -- the manual initialization
        target_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
        target_phrase:copy_from(source_phrase)
        target_phrase:clear()
        target_phrase.number_of_lines = stop_line - start_line + 1
        target_phrase.lpb = source_phrase.lpb
        -- avoid base note shenanigans when doing yoink from each note etc
        target_phrase.key_tracking = renoise.InstrumentPhrase.KEY_TRACKING_NONE
        -- for unknown reasons, this seems to avoid some shenanigans with delays
        -- or samples being mapped incorrectly in Renoise 3.4.4 final, macOS
        target_phrase.instrument_column_visible = true
        target_phrase.delay_column_visible = true
    end
    -- seek until first valid note. deals with sloppy, quick chops
    local first_note_delay = 0
    local first_note_offset = 0
    for line_index, line in ipairs(source_phrase:lines_in_range(start_line, stop_line)) do
        if not line.is_empty then
            first_note_offset = line_index - 1
            local first_note = line:note_column(1)
            first_note_delay = first_note.delay_value
            break
        end
    end
    print("found first non-empty note at offset", first_note_offset, "delay", first_note_delay)

    if not inline then
        for idx = 1, stop_line - start_line do
            local source_line = source_phrase:line(idx + start_line + first_note_offset - 1)
            local target_line = target_phrase:line(idx)
            copy_line(source_line, target_line)
        end
    end
    if first_note_delay > 0 then
        -- TODO: deal with remaining columns as needed
        for line_index = 1, stop_line - start_line do
            fix_column_delay(target_phrase, line_index, 1, first_note_delay)
        end
    end
    return target_phrase
end


renoise.tool():add_menu_entry {
    name = "Phrase Editor:Yoink from every note",
    invoke = function()
        local current_phrase = get_current_phrase()
        if current_phrase == nil then
            return
        end

        local instrument = renoise.song().selected_instrument
        for index, line in ipairs(current_phrase.lines) do
            if not line.is_empty then
                local new_phrase = yoink_phrase(current_phrase, index, current_phrase.number_of_lines, false)
                keymap_if_possible(instrument, new_phrase)
            end
        end
    end

}

renoise.tool():add_menu_entry {
    name = "Phrase Editor:Yoink into new phrase",
    invoke = function()
        local current_phrase = get_current_phrase()
        if current_phrase ~= nil then
            yoink_phrase(current_phrase, 1, current_phrase.number_of_lines, false)
        end
    end
}

renoise.tool():add_menu_entry {
    name = "Phrase Editor:Yoink",
    invoke = function()
        local current_phrase = get_current_phrase()
        if current_phrase ~= nil then
            yoink_phrase(current_phrase, 1, current_phrase.number_of_lines, true)
        end
    end
}


---yoink a selection, and if not inline, automatically add keymapping for new phrase if applicable
---@param inline boolean
local function yoink_selection(inline)
    local current_phrase = get_current_phrase()
    if current_phrase == nil then
        return
    end
    local selection = get_current_selection()
    if selection == nil then
        return
    end
    local new_phrase = yoink_phrase(current_phrase, selection.start_line, selection.end_line, inline)

    if not inline then
        local instrument = renoise.song().selected_instrument
        keymap_if_possible(instrument, new_phrase)
    end
end

renoise.tool():add_menu_entry {
    name = "Phrase Editor:Selection:Yoink into new phrase",
    invoke = function()
        yoink_selection(false)
    end
}
--TODO this has off-by one errors for some reason, leading to line(0) in previous_line comp
--renoise.tool():add_menu_entry {
--    name = "Phrase Editor:Selection:Yoink",
--    invoke = function()
--        yoink_selection(true)
--    end
--}

renoise.tool():add_menu_entry {
    name = "Phrase Editor:Selection:Loop/unloop",
    invoke = function()
        local phrase = get_current_phrase()
        if phrase == nil then
            return
        end
        local selection = get_current_selection()
        if selection == nil then
            return
        end

        phrase.loop_start = selection.start_line
        phrase.loop_end = selection.end_line
        phrase.looping = not phrase.looping
    end
}
