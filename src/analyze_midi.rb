require 'require_all'
require 'midilib/sequence'
require 'midilib/consts'
require_all "include"

include MIDI

# create a new sequence for the file write
# Create a new, empty sequence.
seq = MIDI::Sequence.new()

# Read the contents of a MIDI file into the sequence.
File.open(ARGV[0]+'.mid', 'rb') { | file |
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
    #if event.is_a? MetaEvent
      #puts event.to_s #if !event.is_a? ProgramChange
    #end
  }
}

# Make intervals from each note on/off
intervals = Array.new
notes_on = Hash.new # bucket containing currently on notes, in order to track on/off pairs
last_event_time = 0

#longest_track = 3 #OVERRIDE FOR IMPRO-VISOR

seq.tracks[longest_track].each { |event|
  if(event.is_a? NoteEvent)
    event.print_decimal_numbers = true

    if(event.is_a? NoteOnEvent)
      notes_on[event.note_to_s] = event.time_from_start
    else
      intervals.push(
        [ [notes_on[event.note_to_s], event.note_to_s.to_i],
          [event.time_from_start,     event.note_to_s.to_i] ])
      notes_on.delete(event.note_to_s)

    end

    last_event_time = event.time_from_start if event.time_from_start > last_event_time
    #puts event.to_s
    #puts event.note_to_s
  elsif event.is_a? MetaEvent
    if !event.is_a? ProgramChange
      puts event.to_s
    end
  end
}

gnuplot_from_intervals(ARGV[0]+"_gnuplot", intervals)
#graph_from_intervals(ARGV[0]+"_perf.jpg", intervals, last_event_time)
#pdf_from_midi(ARGV[0])
