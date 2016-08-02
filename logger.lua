-- For use with FCEUX
-- FCEUX 2.2.2 only lets us watch for writes, not reads, sadly
-- The address will also be the address of the next instruction, not the
-- address of the write.


-- addresses of instructions where interesting writes were found
-- used so we don't log the same instruction multiple times
local found = {}


function on_write()
    local pc = memory.getregister("pc")
    if not found[pc] then
        emu.print(string.format("PC: %X", pc))
        found[pc] = true
    end
end


-- log writes from [0x2000 .. 0x4fff]
memory.registerwrite(0x2000, 0x3000, on_write)
