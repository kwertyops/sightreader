require 'require_all'
require 'midilib/sequence'
require 'midilib/consts'
require_all "../src/include"
require_relative "../../rb-music-theory/lib/rb-music-theory"

def generate_target(user_id)
  # lilypond_bin = ""
  lilypond_bin = "../lilypond/bin/"

  if(session.has_key?('lesson_params'))
    params = session['lesson_params']
    print "\nLoading session params"
  else
    # Default param settings
    params = Hash.new
    params['possible_keys'] = 1
    params['measures'] = 1
    params['prob_octave'] = 0.0
    params['prob_shuffle'] = 0.0
    params['notes_per_chord'] = 1
    params['chords_per_measure'] = 1
    params['chord_names'] = 0.0
    session['lesson_params'] = params
    print "\nCreating new session params"

    session['lesson_level'] = 1
  end

  notes = [ 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B' ]  # For calculating octaves
  
  keys = [  {root: 'C', tonality: 'major', accidentals: 0},
            {root: 'G', tonality: 'major', accidentals: 1},
            {root: 'D', tonality: 'major', accidentals: 2},
            {root: 'F', tonality: 'major', accidentals: -1},
            {root: 'Bb', tonality: 'major', accidentals: -2},
            {root: 'A', tonality: 'major', accidentals: 3},
            {root: 'E', tonality: 'major', accidentals: 4},
            {root: 'A', tonality: 'minor', accidentals: 0},
            {root: 'G', tonality: 'minor', accidentals: -2},
            {root: 'E', tonality: 'minor', accidentals: 1},
            {root: 'D', tonality: 'minor', accidentals: -1} ]

  durations = { "1" =>  'w',
                "2" =>  'h',
                "4" =>  'q',
                "8" =>  'i',
                "16" => 's',
                "32" => 't',
                "64" => 'x' }

  # Choose a random key signature from the list
  key = keys[rand(0 ... params['possible_keys'])]

  # Generate all 7th chords for this key
  root = Note.new(key[:root])
  scale = root.send(key[:tonality]+"_scale")
  chords = scale.all_harmonized_chords(key[:tonality].sub("or","")+"7_chord").map{|c| {note_values: c.note_values, note_names: c.note_names, chord_names: Scale.new(c.root_note, c.intervals).valid_chord_names_for_degree(1)}}

  # Get lilypond name for each chord
  chords.each do |chord|

    # Remove chord names we don't care about
    chord[:chord_names].delete_if{|i| i.to_s.include?("major") ||
                        i.to_s.include?("minor") ||
                        i.to_s.include?("fifth") ||
                        i.to_s.include?("seventh") ||
                        i.to_s.include?("half_dim") ||
                        i.to_s.include?("min7_flat5") } 

    # sample random name from among remaining to be chord type for this chord
    chord[:chord_name] = chord[:chord_names].sample.to_s

    # change name to lilypond format
    chord[:chord_name].sub!("dim", "dim7")
    chord[:chord_name].sub!("min7_b5", "m7.5-")
    chord[:chord_name].sub!("min7", "m7")
    chord[:chord_name].sub!("dom7","7")
    chord[:chord_name].sub!("_chord", "")
    
  end

  # Get jfugue note names for each note
  chords.each_with_index do |chord, c|
    chord[:note_octaves] = Array.new
    chord[:note_names].each_with_index do |note_name, n|

      # Correct note names for key sig
      if(key[:accidentals] < 0 && note_name.include?("#"))
        chord[:note_names][n] = notes[(chord[:note_values][n] + 1) % 12] + "b"
      end

      # Save MIDI octave for later use
      chord[:note_octaves][n] = (chord[:note_values][n] / 12).to_s

    end
  end

  printed_chords = Array.new

  # Build jfugue string
  jfugue_string = ""
  (0 ... params['measures']).each do |m|
    (0 ... params['chords_per_measure'].floor).each do |c|
      chord = chords.sample
      printed_chords << chord
      (0 ... params['notes_per_chord']).each do |n|

        # Random chance of shuffling notes
        if(rand(0.0..1.0) < params['prob_shuffle'])
          s = rand(0 ... chord[:note_names].length)
        else
          s = n
        end

        note_name = chord[:note_names][s]
        octave = chord[:note_octaves][s]

        # Random chance of octave shift
        if(rand(0.0..1.0) < params['prob_octave'])
          octave = octave.to_i
          octave += [1, -1].sample
          octave = octave.to_s
        end

        jfugue_string += note_name
        jfugue_string += octave
        jfugue_string += durations[(params['notes_per_chord'] * params['chords_per_measure'].floor).to_s]
        jfugue_string += " "
      end
    end
  end 

  print "\nStaccato string: " + jfugue_string + "\n"

  # Generate MIDI from jfugue
  #
  print "\n" + 'java -cp "java/jfugue.jar:java" StaccatoToMidi ' + user_id + ' "' + jfugue_string + '"' + "\n"
  system('java -cp "java/jfugue.jar:java" StaccatoToMidi ' + user_id + ' "' + jfugue_string + '"')
  
  # Generate lilypond from MIDI
  #
  midi2ly_key = key[:accidentals].to_s + ":" + (key[:tonality] == 'minor' ? "1" : "0")
  system("#{lilypond_bin}midi2ly -k #{midi2ly_key} -o targets/#{user_id}.ly targets/#{user_id}.mid")
  
  # Modify the lilypond file before export to png (add chord names, color notes, add/remove flags, etc)
  #
  File.open('targets/'+user_id+'.ly2', 'w') do |output| # 'w' for a new file, 'a' append to existing
    File.open('targets/'+user_id+'.ly', 'r') do |input|
      input.each_line do |line|

        # Insert chord names to display above staff
        if(line.include?("context Staff=") && 
          session['lesson_level'] >= 15)
          
          lilypond_chords = "    \\chords{ "
          printed_chords.each do |chord|

            # change flat/sharp to lilypond notation
            chord[:note_names][0].sub!("#", "is")
            chord[:note_names][0].sub!("b", "es")
            lilypond_chords += chord[:note_names][0].downcase

            lilypond_chords += params['chords_per_measure'].floor.to_s

            lilypond_chords += ":" + chord[:chord_name]
            lilypond_chords += " "
          end
          lilypond_chords += "}\n"
          output.write(lilypond_chords)
        end

        # This stops lilypond from generating a midi file
        unless line.include?("midi {}")
          output.write(line)
        end

      end
    end
  end
  
  # Export lilypond to png
  #
  system("#{lilypond_bin}lilypond --png -o targets/#{user_id} targets/#{user_id}.ly2")

end

def analyze_performance(user_id)
  params = session['lesson_params']
    # lilypond_bin = ""
  lilypond_bin = "../lilypond/bin/"

  options = {
    'possible_keys' => {
      low: 1,
      high: 11,
      step: 1
    },
    'measures'=> {
      low: 1,
      high: 8,
      step: 1
    },
    'prob_octave' => {
      low: 0.0,
      high: 0.2,
      step: 0.02
    },
    'prob_shuffle' => {
      low: 0.0,
      high: 0.3,
      step: 0.03
    },
    'notes_per_chord' => {
      low: 1,
      high: 8,
      step: 1
    },
    'chords_per_measure' => {
      low: 1.0,
      high: 2.0,
      step: 0.2
    },
    'chord_names' => {
      low: 0.0,
      high: 1.0,
      step: 0.2
    }
  }

  target_seq = MIDI::Sequence.new()
  source_seq = MIDI::Sequence.new()

  # Read the files into the sequences
  read_midi_file_into_sequence('targets/'+user_id+'.mid', target_seq)
  read_midi_file_into_sequence('uploads/'+user_id+'.mid', source_seq)

  # Find the longest track in target
  target_track = target_seq.tracks[find_longest_track(target_seq)]

  # Find the longest track in source
  source_track = source_seq.tracks[find_longest_track(source_seq)]

  # Align the source track to the target track
  set_first_note_time(source_track, get_first_note_time(target_track))

  # Shrink source to fit target (bpm is no longer meaningful)
  shrink_source_to_target_midi(source_track, target_track)

  # Make intervals from each note on/off
  target_intervals = intervals_from_track(target_track)
  source_intervals = intervals_from_track(source_track)

  # Plot the results
  dtw_path = get_dtw_path(target_intervals, source_intervals)
  compare_gnuplot_from_intervals_w_dtw('uploads/'+user_id+"_comp", target_intervals, source_intervals, dtw_path)

  if(source_intervals.length == 0)
    return
  end

  # Find the number of correct notes
  correct = 0
  correct_notes = Array.new
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
    correct_notes << match
  end

  # Color the notes in the target lilypond file
  File.open('targets/'+user_id+'.ly3', 'w') do |output| # 'w' for a new file, 'a' append to existing
    editing_notes = false
    current_target_note_num = 0
    File.open('targets/'+user_id+'.ly2', 'r') do |input|
      input.each_line do |line|

        if(line.include?('\key'))
          editing_notes = true
          next
        end

        if(editing_notes)
          notes_array = line.gsub(/\s+/m, ' ').strip.split(" ")
          if(notes_array[0] == "}")
            editing_notes = false
            output.write("\n" + line)
            next
          end
          if(notes_array[0] == "|")
            next
          end
          notes_array.each do |note|
            colored_string = "\n" 
            colored_string += '\override NoteHead.color = #' 
            colored_string += correct_notes[current_target_note_num] ? 'green' : 'red'
            colored_string += "\n"
            colored_string += note
            output.write(colored_string)
            current_target_note_num += 1
          end
        else
          output.write(line)
        end
      end
    end
  end

  system("#{lilypond_bin}lilypond --png -o uploads/#{user_id}_comp targets/#{user_id}.ly3")

  # Find the params that can be adjusted in the right direction
  adjustable = Array.new
  if(correct == dtw_path.length)  # Performance successful
    step_modifier = 1
    params.each do |key, value|
      if(value != options[key][:high])
        adjustable << key
      end
    end
  else                            # Performance failed
    step_modifier = -1
    params.each do |key, value|
      if(value != options[key][:low])
        adjustable << key
      end
    end
  end

  if(adjustable.length <= 0)
    print "\nNothing to adjust\n"
    return
  end

  # Update some random param
  param_to_update = adjustable.sample
  
  # Notes per chord has special rules
  if(param_to_update == 'notes_per_chord')
    params['notes_per_chord'] = params['notes_per_chord'] * 2 if step_modifier == 1
    params['notes_per_chord'] = params['notes_per_chord'] / 2 if step_modifier == -1
    session['lesson_params'] = params
  else
    # Normal params adjusted by step size
    params[param_to_update] = params[param_to_update] + options[param_to_update][:step] * step_modifier
    session['lesson_params'] = params
  end

  session['lesson_level'] += step_modifier
  if(session['lesson_level'] == 0)
    session['lesson_level'] = 1
  end

end
