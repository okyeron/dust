mymidichan = 1

midistatusbychan = {
        -- note-on, note-off, cc, bend, Aftertouch, program change, poly aftertouch
        {144, 128, 176, 224, 208, 192, 160}, -- 1
        {145, 129, 177, 225, 209, 193, 161}, -- 2
        {146, 130, 178, 226, 210, 194, 162}, -- 3
        {147, 131, 179, 227, 211, 195, 163}, -- 4
        {148, 132, 180, 228, 212, 196, 164}, -- 5
        {149, 133, 181, 229, 213, 197, 165}, -- 6
        {150, 134, 182, 230, 214, 198, 166}, -- 7
        {151, 135, 183, 231, 215, 199, 167}, -- 8
        {152, 136, 184, 232, 216, 200, 168}, -- 9
        {153, 137, 185, 233, 217, 201, 169}, -- 10
        {154, 138, 186, 234, 218, 202, 170}, -- 11
        {155, 139, 187, 235, 219, 203, 171}, -- 12
        {156, 140, 188, 236, 220, 204, 172}, -- 13
        {157, 141, 189, 237, 221, 205, 173}, -- 14
        {158, 142, 190, 238, 222, 206, 174}, -- 15
        {159, 143, 191, 239, 223, 207, 175} -- 16
    }


local function midicc(ccnum, ccvalue, echo, chan)
	-- do stuff
	print ("cc "..ccnum.." : "..ccvalue)
end

local function note_off(note, echo, chan)
  	-- send midi note back to device?
	if echo then
	  midi.send(midi_device, {midistatusbychan[chan][2], note, 0})
	end
	-- do stuff
end

local function note_on(note, vel, echo, chan)
  	-- send midi note back to device?
	if echo then
	  midi.send(midi_device, {midistatusbychan[chan][1], note, vel})
	end
	-- do stuff
	print (note)
end

local function midi_event(data)
    echo = true
    tab.print (data)
    if data[1] == midistatusbychan[mymidichan][1] and data[3] > 0 then
      note_on(data[2], data[3], echo, mymidichan)
    elseif data[1] == midistatusbychan[mymidichan][1] and data[3] == 0  then
      note_off(data[2], echo, mymidichan)
    elseif data[1] == midistatusbychan[mymidichan][2] then
      note_off(data[2], echo, mymidichan)
    elseif data[1] == midistatusbychan[mymidichan][3] then
      midicc(data[2], data[3], echo, mymidichan)
        
    elseif data[1] == midistatusbychan[mymidichan][4] then
        --bend(data[2], data[3])
    elseif data[1] == midistatusbychan[mymidichan][5] then
        --aftertouch(data[2])
    elseif data[1] == midistatusbychan[mymidichan][6] then
        --progchange(data[2])
    elseif data[1] == midistatusbychan[mymidichan][7] then
        --polyaftertouch(data[2], data[3])
    end
end

midi.add = function(dev)
    print('(test) midi device added', dev.id, dev.name)
    dev.event = midi_event
    midi_device = dev
end
