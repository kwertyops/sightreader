require 'require_all'
require 'midilib/sequence'
require 'midilib/consts'
require_all "../src/include"
require_relative "../../rb-music-theory/lib/rb-music-theory"

###
#   Generate a .png to display to the user
###
def generate_target(user_id)

  # Load params from the session
  # (these are the user's "current
  # settings", so to speak)
  #
  if(session.has_key?('lesson_params'))
    params = session['lesson_params']
    print "\nLoading session params"
  else
    # These are the default values for the params
    params = Hash.new
    params['some_param']      = 0
    params['another_param']   = 1.0
    params['yet_more_param']  = false
    print "\nCreating new session params"

    # save the params in the session
    # so they persist between page reloads
    session['lesson_params'] = params   
  end

  # Generate MIDI from jfugue
  #
  jfugue_string = "C D E F G A"
  system("java -cp \"java/jfugue.jar:java\" StaccatoToMidi #{user_id} \"#{jfugue_string}\"")
  
  path_to_lilypond = "../lilypond/bin/"

  # Generate lilypond from MIDI
  #
  system("#{path_to_lilypond}midi2ly -o targets/#{user_id}.ly targets/#{user_id}.mid")
  
  # Export lilypond to png
  #
  system("#{path_to_lilypond}lilypond --png -o targets/#{user_id} targets/#{user_id}.ly")

  #
  # At the end of this function there should
  # exist a sheet music .png at:
  #   targets/user_id.png
  #
  # which will get sent to the user when
  # the /record page is loaded
  #

end

###
#   Compare the midi performance to the midi target, update parameters accordingly
###
def analyze_performance(user_id)

  # Load params (these are the user's
  # "current settings", so to speak)
  #
  params = session['lesson_params']

  #
  # What follows will analyze the
  # performance .mid vs the target
  # .mid, and should update the 
  # input parameters for the
  # exercise generation based
  # on the outcome of the analysis
  #

  target_seq = MIDI::Sequence.new()
  source_seq = MIDI::Sequence.new()

  # Read the files into the sequences
  read_midi_file_into_sequece('targets/'+user_id+'.mid', target_seq)
  read_midi_file_into_sequece('uploads/'+user_id+'.mid', source_seq)

  # Find the longest track in target
  target_track = target_seq.tracks[find_longest_track(target_track)]

  # Find the longest track in source
  source_track = source_seq.tracks[find_longest_track(source_seq)]

  # Align the source track to the target track
  set_first_note_time(source_track, get_first_note_time(target_track))

  # Shrink source to fit target (bpm is no longer meaningful)
  shink_source_to_target_midi(source_track, target_track)

  # Make intervals from each note on/off
  target_intervals = intervals_from_track(target_track)
  source_intervals = intervals_from_track(source_track)

  # Plot the results
  dtw_path = get_dtw_path(target_intervals, source_intervals)
  compare_gnuplot_from_intervals_w_dtw('uploads/'+user_id+"_comp", target_intervals, source_intervals, dtw_path)

  # If there was no performance, do nothing
  if(source_intervals.length == 0)
    return
  end

  # Find the number of "correct" notes
  correct = 0
  dtw_path.each do |target_index, source_notes|
    match = false
    target_noteon_y = target_intervals[target_index][0][1]
    
    # Look at all of the notes that were matched with this target note
    source_notes.each do |source_note|
      source_noteon_y = source_intervals[source_note][0][1]
      
      # Just check if the pitch is correct
      if(source_noteon_y == target_noteon_y)
        match = true
      end
    end
    if(match == true)
      correct += 1
    end
  end

  # Performance score as percentage of target notes hit
  performance_score = correct / dtw_path.length


  #
  # Somehow update the session params here to reflect 
  # the outcome of the performance
  # (ie make it harder if they did well, easier
  #  if they failed)
  #

  # Finally, save the updated params so they persist between page loads
  session['lesson_params'] = params

end
