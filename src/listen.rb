require "unimidi"
require 'midi-eye'

# prompt user for input device
@input = UniMIDI::Input.gets

# prompt user for output device
@output = UniMIDI::Output.gets

# open outputs
@input.open
@output.open

# create listener for NoteOn and NoteOff
listener = MIDIEye::Listener.new(@input)

# just print messages that we get
listener.on_message do |event|
  puts event[:timestamp]
  puts event[:message]
end

# start listening
listener.run(:background => true)

notes = [36, 40, 43] # C E G
octaves = 5
duration = 0.1

# using their selection...
(0..((octaves-1)*12)).step(12) do |oct|
  notes.each do |note|
  @output.puts(0x90, note + oct, 100) # note on
  sleep(duration) # wait
  @output.puts(0x80, note + oct, 100) # note off
  end
end