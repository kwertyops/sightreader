require 'require_all'
require 'midilib/sequence'
require 'midilib/consts'
require_all "include"

include MIDI

def analyze_and_remove_program_changes(filename)
  # create a new sequence for the file write
  # Create a new, empty sequence.
  seq = MIDI::Sequence.new()

  # Read the contents of a MIDI file into the sequence.
  File.open(filename, 'rb') { | file |
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

    to_delete = Array.new # TEMPORARY

    track.events.each { |event|
      if !event.is_a? NoteEvent
        #puts event.to_s
        if event.is_a? ProgramChange
          puts event.to_s
          to_delete.push(event) # TEMPORARY
        end
      end
      #if event.is_a? MetaEvent
        #puts event.to_s #if !event.is_a? ProgramChange
      #end
    }

    # Delete the program changes
    #
    # TEMPORARY
    #
    to_delete.each do |del|
      puts "Deleting " + del.to_s
      track.events.delete(del)
    end

    track.recalc_times
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

  File.open(filename, 'wb') { |file| seq.write(file) }

  #gnuplot_from_intervals(filename+"_gnuplot", intervals)
  #graph_from_intervals(filename+"_perf.jpg", intervals, last_event_time)
  #png_from_midi(filename)

end

Dir.foreach('../webapp/targets') do |item|
  next if item == '.' or item == '..'
  if File.extname('../webapp/targets/' + item) == ".mid"
    puts item
    puts "Working"
    location = '../webapp/targets/' + item
    location = location.chomp(File.extname(location))
    png_from_midi(location)
    #analyze('../webapp/targets/' + item)
  end
  # do work on real items
end