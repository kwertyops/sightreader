require 'require_all'
require 'midilib/sequence'
require 'midilib/consts'
require_all "../../src/include"

include MIDI

# create a new sequence for the file write
# Create a new, empty sequence.
seq = MIDI::Sequence.new()

# Read the contents of a MIDI file into the sequence.
File.open('invent1_chunk_new.mid', 'rb') { | file |
    seq.read(file) { | track, num_tracks, i |
        # Print something when each track is read.
        puts "read track #{i} of #{num_tracks}"
    }
}

# Find the longest track
longest_track = 0
seq.each_with_index { |track, i|
  track.recalc_times
  longest_track = i if track.events.length > longest_track
  puts "track " + track.name + ": " + track.events.length.to_s

  track.events.each { |event|
    if(event.time_from_start > 1300 && event.is_a?(NoteOnEvent))
      track.events.delete(event)
    elsif(event.time_from_start > 1400 && event.is_a?(NoteOffEvent))
      track.events.delete(event)
    end
  }
  track.recalc_times
}

File.open('invent1_chunk_short.mid', 'wb') { |file| seq.write(file) }
