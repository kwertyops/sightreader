require_relative "../../rb-music-theory/lib/rb-music-theory"

def analyze_performance()
  
end

def generate_target(user_id)
  
  notes = [ 'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B' ]  # For calculating octaves
  keys = [  {root: 'C', tonality: 'major', accidentals: 0},
            {root: 'G', tonality: 'major', accidentals: 1},
            {root: 'A', tonality: 'major', accidentals: 3},
            {root: 'E', tonality: 'major', accidentals: 4}, 
            {root: 'D', tonality: 'major', accidentals: 2},
            {root: 'F', tonality: 'major', accidentals: -1},
            {root: 'Bb', tonality: 'major', accidentals: -2},
            {root: 'A', tonality: 'minor', accidentals: 0},
            {root: 'G', tonality: 'minor', accidentals: -2},
            {root: 'E', tonality: 'minor', accidentals: 1},
            {root: 'D', tonality: 'minor', accidentals: -1} ]
  
  # Choose a random key signature from the list
  key = keys.sample

  # Generate all 7th chords for this key
  root = Note.new(key[:root])
  scale = root.send(key[:tonality]+"_scale")
  note_values = scale.all_harmonized_chords(key[:tonality].sub("or","")+"7_chord").map{|c| c.note_values}
  note_names = scale.all_harmonized_chords(key[:tonality].sub("or","")+"7_chord").map{|c| c.note_names}
  chord_valid_names = scale.all_harmonized_chords(key[:tonality].sub("or","")+"7_chord").map{|c| Scale.new(c.root_note, c.intervals).valid_chord_names_for_degree(1)}

  jfugue_string = ""

  # Get notes for each chord
  note_values.each_with_index do |chord, c|
    chord.each_with_index do |note, n|

      # Correct note names for key sig
      # This is for writing chord names later
      if(key[:accidentals] < 0 && note_names[c][n].include?("#"))
        note_names[c][n] = notes[(note + 1) % 12] + "b"
      end

      octave = (note / 12).to_s
      
      # Build jfugue string
      jfugue_string += note_names[c][n]
      jfugue_string += octave
      jfugue_string += " "
    end
  end

  # Get name for each chord
  chord_names = Array.new
  chord_valid_names.each do |chord|

    # Remove chord names we don't care about
    chord.delete_if{|i| i.to_s.include?("major") ||
                        i.to_s.include?("minor") ||
                        i.to_s.include?("fifth") ||
                        i.to_s.include?("seventh") ||
                        i.to_s.include?("half_dim") ||
                        i.to_s.include?("min7_flat5") } 

    # sample random name from among remaining
    name = chord.sample.to_s

    # change name to lilypond format
    name.sub!("dim", "dim7")
    name.sub!("min7_b5", "m7.5-")
    name.sub!("min7", "m7")
    name.sub!("dom7","7")
    name.sub!("_chord", "")
    
    chord_names << name
  end

  print "\nStaccato string: " + jfugue_string + "\n"

  # Generate MIDI from jfugue
  print "\n" + 'java -cp "java/jfugue.jar:java" StaccatoToMidi ' + user_id + ' "' + jfugue_string + '"' + "\n"
  system('java -cp "java/jfugue.jar:java" StaccatoToMidi ' + user_id + ' "' + jfugue_string + '"')
  
  # Generate lilypond from MIDI
  midi2ly_key = key[:accidentals].to_s + ":" + (key[:tonality] == 'minor' ? "1" : "0")
  system("../lilypond/bin/midi2ly -k #{midi2ly_key} -o targets/#{user_id}.ly targets/#{user_id}.mid")
  
  # Modify the lilypond file before export
  File.open('targets/'+user_id+'.ly2', 'w') do |output| # 'w' for a new file, 'a' append to existing
    File.open('targets/'+user_id+'.ly', 'r') do |input|
      input.each_line do |line|

        # This is where we write chord names to display above staff
        if(line.include?("context Staff="))
          lilypond_chords = "    \\chords{ "
          chord_names.each_with_index do |name, i|

            # change flat/sharp to lilypond notation
            note_names[i][0].sub!("#", "is")
            note_names[i][0].sub!("b", "es")
            lilypond_chords += note_names[i][0].downcase

            if(i == 0) then lilypond_chords += "1" end # chord length for first chord

            lilypond_chords += ":" + name
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
  system("../lilypond/bin/lilypond --png -o targets/#{user_id} targets/#{user_id}.ly2")

end