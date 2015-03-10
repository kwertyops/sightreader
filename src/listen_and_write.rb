require 'midilib/sequence'
require 'midilib/consts'
require "unimidi"
require 'midi-eye'
require "./setuptools"
include MIDI

# create a new sequence for the file write
seq = Sequence.new()
track = setup_seq(seq)

# keep track of the timestamp for the previous note
# in order to calculate deltas
prev_note = 0

# prompt user for MIDI devices and open them
@input = UniMIDI::Input.gets
@output = UniMIDI::Output.gets
@input.open
@output.open

# create listener for NoteOn and NoteOff
listener = MIDIEye::Listener.new(@input)

# calculate pulses per millisecond
ppms = (1 / seq.pulses_to_seconds(1)) / 1000
puts "Seconds per pulse: " + seq.pulses_to_seconds(1).to_s
puts "PPMS: " + ppms.to_s

# print the message and add it to the sequence
listener.listen_for(:class => [MIDIMessage::NoteOn, MIDIMessage::NoteOff]) do |event|
  timestamp = event[:timestamp].to_f
  pulses = timestamp * ppms
  pulses = pulses.to_i
  if event[:message].kind_of? MIDIMessage::NoteOn
    puts "Note ON"
    track.events << NoteOn.new(0, event[:message].note, 127, pulses - prev_note)
    prev_note = pulses
  else
    puts "Note OFF"
    track.events << NoteOff.new(0, event[:message].note, 127, pulses - prev_note)
    prev_note = pulses
  end
  puts pulses.to_s
  puts event[:message]
  if event[:timestamp] > 20000
    listener.stop
  end
end

# start listening
#listener.run(:background => true)
listener.run()

# notes = [36, 40, 43] # C E G
# octaves = 5
# duration = 0.1

# # using their selection...
# (0..((octaves-1)*12)).step(12) do |oct|
#   notes.each do |note|
#   @output.puts(0x90, note + oct, 100) # note on
#   sleep(duration) # wait
#   @output.puts(0x80, note + oct, 100) # note off
#   end
# end

# # Add some notes
# quarter_note_length = seq.note_to_delta('quarter')
# [0, 2, 4, 5, 7, 9, 11, 12].each do |offset|
#   track.events << NoteOn.new(0, 64 + offset, 127, 0)
#   track.events << NoteOff.new(0, 64 + offset, 127, quarter_note_length)
# end

# Calling recalc_times is not necessary, because that only sets the events'
# start times, which are not written out to the MIDI file. The delta times are
# what get written out.
# track.recalc_times
File.open('from_scratch.mid', 'wb') { |file| seq.write(file) }