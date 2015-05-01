require_relative "../../rb-music-theory/lib/rb-music-theory"

def analyze_performance()
  
end

def generate_target(user_id)
  # lilypond_bin = ""
  lilypond_bin = "../lilypond/bin/"

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

  if(session.has_key?('lesson_params'))
    params = session['lesson_params']
  else
    params = Hash.new
    params['possible_keys'] = 11
    params['measures'] = 4
    params['prob_octave'] = 0.2
    params['prob_shuffle'] = 0.3
    params['notes_per_chord'] = 4
    params['chords_per_measure'] = 2
    session['lesson_params'] = params
  end

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

    # sample random name from among remaining
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
        note_name = notes[(chord[:note_values][n] + 1) % 12] + "b"
      end

      # Get octave
      chord[:note_octaves][n] = (chord[:note_values][n] / 12).to_s

    end
  end

  printed_chords = Array.new

  # Build jfugue string
  jfugue_string = ""
  (0 ... params['measures']).each do |m|
    (0 ... params['chords_per_measure']).each do |c|
      chord = chords.sample
      printed_chords << chord
      (0 ... params['notes_per_chord']).each do |n|

        # Possible print out of order
        if(rand(0.0..1.0) < params['prob_shuffle'])
          s = rand(0 ... chord[:note_names].length)
        else
          s = n
        end

        note_name = chord[:note_names][s]
        octave = chord[:note_octaves][s]

        if(rand(0.0..1.0) < params['prob_octave'])
          octave = octave.to_i
          octave += [1, -1].sample
          octave = octave.to_s
        end

        jfugue_string += note_name
        jfugue_string += octave
        jfugue_string += durations[(params['notes_per_chord'] * params['chords_per_measure']).to_s]
        jfugue_string += " "
      end
    end
  end

  # chords.each do |chord|
  #   chord[:note_names].each_with_index do |note_name, n|
  #     jfugue_string += note_name
  #     jfugue_string += chord[:note_octaves][n]
  #     jfugue_string += " "
  #   end
  # end  

  print "\nStaccato string: " + jfugue_string + "\n"

  # Generate MIDI from jfugue
  print "\n" + 'java -cp "java/jfugue.jar:java" StaccatoToMidi ' + user_id + ' "' + jfugue_string + '"' + "\n"
  system('java -cp "java/jfugue.jar:java" StaccatoToMidi ' + user_id + ' "' + jfugue_string + '"')
  
  # Generate lilypond from MIDI
  midi2ly_key = key[:accidentals].to_s + ":" + (key[:tonality] == 'minor' ? "1" : "0")
  system("#{lilypond_bin}midi2ly -k #{midi2ly_key} -o targets/#{user_id}.ly targets/#{user_id}.mid")
  
  # Modify the lilypond file before export
  File.open('targets/'+user_id+'.ly2', 'w') do |output| # 'w' for a new file, 'a' append to existing
    File.open('targets/'+user_id+'.ly', 'r') do |input|
      input.each_line do |line|

        # This is where we write chord names to display above staff
        if(line.include?("context Staff="))
          lilypond_chords = "    \\chords{ "
          printed_chords.each do |chord|

            # change flat/sharp to lilypond notation
            chord[:note_names][0].sub!("#", "is")
            chord[:note_names][0].sub!("b", "es")
            lilypond_chords += chord[:note_names][0].downcase

            lilypond_chords += params['chords_per_measure'].to_s

            lilypond_chords += ":" + chord[:chord_name]
            lilypond_chords += " "
          end
          lilypond_chords += "}\n"
          output.write(lilypond_chords)
        end

        # This stops lilypond from generating midi file
        unless line.include?("midi {}")
          output.write(line)
        end

      end
    end
  end
  
  # Export lilypond to png
  system("#{lilypond_bin}lilypond --png -o targets/#{user_id} targets/#{user_id}.ly2")

end
