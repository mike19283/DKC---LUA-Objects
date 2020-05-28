memory.usememorydomain("WRAM")  -- just in case
local arrays = {  0x0d45,  0x13e9 } -- edit this line to look at different object arrays
 -- d45 id, b19 x, 1375 dest, 13e9 return


local function unsigned16(num) -- Fixes underflow problem
    local maxval = 0x8000
    if num >= 0 then
        return num
    else
        return 2 * maxval + num
    end
end

local function format_hex16(number)
    return string.format('%4x', unsigned16(number))
end


client.SetGameExtraPadding(0, 0, (70 + #arrays * 60)/2, 0)


while true do

    local id, colour, array_x_pos
    local camera_xpos, camera_ypos, xpos_offset, ypos_offset
    
    camera_xpos = mainmemory.read_u16_le(0x088b)
    camera_ypos = mainmemory.read_u16_le(0x0895)
    camera_vertical_offset = mainmemory.read_u16_le(0x004a)
    
    for i = 0, 14, 1 do -- Loop through the 15 slots, 0-14
        colour = "white"
        local d45 = memory.read_s16_le(0x0d45 + i * 2)
        if d45 == 0x14 then
            id = i        
            colour = "red"
        end
        
        
        -- Position
        local xpos = mainmemory.read_u16_le(0x0b19 + 2*i)
        local ypos = mainmemory.read_u16_le(0x0bc1 + 2*i)
        local xscreen = xpos - camera_xpos
        local yscreen = camera_vertical_offset - ypos - camera_ypos
        
        gui.drawAxis(xscreen, yscreen, 3, colour)
        gui.pixelText(xscreen - 7, yscreen + 5, string.format("<%02d>", i), colour, 0)
        
        -- Table for arrays
        
        gui.text(512, 75 + (i * 15), string.format("ID %02d:", i), colour) -- Display on the HUD
        
        array_x_pos = 70
        
        for j = 1, table.getn(arrays), 1 do -- Loop through all my specified arrays, arrays are 1 based
            local val = memory.read_s16_le(arrays[j] + i * 2) -- Get the value at that index
            gui.text(512 + array_x_pos + 60 * (j-1), 55, string.format("$%04x", arrays[j])) -- Display on the HUD            

            gui.text(512 + array_x_pos + 60 * (j-1), 75 + (i * 15), format_hex16(val), colour) -- Display on the HUD
            
            --array_x_pos = array_x_pos + 60
        end                
    end
    gui.text(0, 400, "Object DK is holding: " .. memory.read_s16_le(0x16f5)/2)
    gui.text(0, 415, "Object Diddy is holding: " .. memory.read_s16_le(0x16f7)/2) -- Edit these to manipulate RAM watch

    emu.frameadvance()
end