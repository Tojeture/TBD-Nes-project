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
	nt = memory.readbyte(0x0003);
	scroll = memory.readbyte(0x0015);
	test_x = memory.readbyte(0x0023);
	test_y = memory.readbyte(0x0024);
	test_result = memory.readbyte(0x0026);
	p1x = memory.readbyte(0x0303);
	p1y = memory.readbyte(0x0300);
	vertical_force = memory.readbyte(0x000D);
	jump_force = memory.readbyte(0x000E);
	gravity_delay = memory.readbyte(0x000F);
	p1status = toBits(memory.readbyte(0x000C),8);
	gui.text(1,9,"P1: "..p1x..","..p1y);
	-- gui.text(141,224,"Player_state: "..p1status);
	--gui.text(2,224,"nt:"..nt.." scroll:"..scroll);
	gui.text(2,224,"result:"..test_result);
	gui.text(1,18,"Vforce:"..vertical_force.." Jforce:"..jump_force);
	gui.line(0,test_y,255,test_y);
	gui.line(test_x,0,test_x,255);
	
	-- for i=240,0,-8 do
		-- gui.line(0,i,240,i);
	-- end
	-- for i=256,0,-8 do
		-- gui.line(i,0,i,255);
	-- end
	emu.frameadvance();
end;