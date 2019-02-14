function toBits(num,bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
	local st = ""
	for b = bits, 1, -1 do
		st = t[b]..st
	end
    return st
end

while(true) do
	p1x = memory.readbyte(0x0303);
	p1y = memory.readbyte(0x0300);
	vertical_force = memory.readbyte(0x000D);
	jump_force = memory.readbyte(0x000E);
	gravity_delay = memory.readbyte(0x000F);
	p1status = toBits(memory.readbyte(0x000C),8);
	gui.text(1,9,"P1: "..p1x..","..p1y);
	gui.text(141,224,"Player_state: "..p1status);
	gui.text(1,18,"Vforce:"..vertical_force.." Jforce:"..jump_force);
	gui.line(0,p1y,255,p1y);
	gui.line(p1x,0,p1x,255);
	emu.frameadvance();
end;