require 'require_all'
require 'midilib/sequence'
require 'midilib/consts'
require_all "../../src/include"

include MIDI

# create a new sequence for the file write
# Create a new, empty sequence.
seq = MIDI::Sequence.new()

# Read the contents of a MIDI file into the sequence.
File.open('invent1_chunk.mid', 'rb') { | file |
    seq.read(file) { | track, num_tracks, i |
        # Print something when each track is read.
        puts "read track #{i} of #{num_tracks}"
    }
}

# Find the longest track
longest_track = 0
seq.each_with_index { |track, i|
  longest_track = i if track.events.length > longest_track
  puts "track " + track.name + ": " + track.events.length.to_s

  track.events.each { |event|
    event.delta_time = event.delta_time * 2
    #if event.is_a? MetaEvent
      #puts event.to_s #if !event.is_a? ProgramChange
    #end
  }
}

File.open('invent1_chunk_new.mid', 'wb') { |file| seq.write(file) }
