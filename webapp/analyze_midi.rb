require 'require_all'
require 'midilib/sequence'
require 'midilib/consts'
require_all "../src/include"

include MIDI

def png_from_midi(midi_file_path)
  system("mscore -o #{midi_file_path}.png -M ../import_options.xml #{midi_file_path}.mid")
end

def compare_midi(target, source)

  target_seq = MIDI::Sequence.new()
  source_seq = MIDI::Sequence.new()

  # Read the files into the sequences
  File.open(target+'.mid', 'rb') { | file |
    puts "Reading target midi..."
      target_seq.read(file) { | track, num_tracks, i |
          # Print something when each track is read.
          puts "read track #{i} of #{num_tracks}"
      }
  }

  File.open(source+'.mid', 'rb') { | file |
    puts "Reading source midi..."
      source_seq.read(file) { | track, num_tracks, i |
          # Print something when each track is read.
          puts "read track #{i} of #{num_tracks}"
      }
  }


  # Find the longest track in target
  longest_track_target = 0
  first_noteon = nil
  target_seq.each_with_index { |track, i|
    longest_track_target = i if track.events.length > longest_track_target
    puts "track target " + track.name + ": " + track.events.length.to_s

    track.events.each { |event|
      # Grab start time of first note for re-alignment
      if(event.is_a?(NoteOnEvent) && first_noteon.nil?)
        first_noteon = event.time_from_start
      end
    }
  }

  target_track = target_seq.tracks[longest_track_target]

  # Find the longest track in source
  longest_track_source = 0
  source_seq.each_with_index { |track, i|
    longest_track_source = i if track.events.length > longest_track_source
    puts "track source " + track.name + ": " + track.events.length.to_s

    track.events.each { |event|
      # Readjust the start time of the track to fit with the target
      if(event.is_a?(NoteOnEvent) && !first_noteon.nil?)
        event.delta_time = event.delta_time - (event.time_from_start - first_noteon)
        first_noteon = nil
      end
    }
    track.recalc_times
  }

  source_track = source_seq.tracks[longest_track_source]

  # Make intervals from each note on/off
  target_intervals, target_max_t = intervals_from_track(target_track)
  source_intervals, source_max_t = intervals_from_track(source_track)

  # Plot the results
  dtw_path = get_dtw_path(target_intervals, source_intervals)
  compare_gnuplot_from_intervals_w_dtw(source+"_comp", target_intervals, source_intervals, dtw_path)

  # Just for fun make sheet music from the performance
  # png_from_midi(source)

end
