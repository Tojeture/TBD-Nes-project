while(true) do
	p1x = memory.readbyte(0x0303);
	p1y = memory.readbyte(0x0300);
	p1y_prime = memory.readbyte(0x000A);
	p1x_prime = memory.readbyte(0x0009);
	diff_x = p1x_prime - p1x;
	diff_y = p1y_prime - p1y;
	gui.text(1,9,"P1: "..p1x..","..p1y);
	gui.text(1,19,"Prime: "..p1x_prime..","..p1y_prime);
	gui.text(1,29,"difference: "..diff_x..","..diff_y);
	gui.line(0,p1y,255,p1y);
	gui.line(0,p1y_prime,255,p1y_prime);
	gui.line(p1x,0,p1x,255);
	gui.line(p1x_prime,0,p1x_prime,255);
	emu.frameadvance();
end;