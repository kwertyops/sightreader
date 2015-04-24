###
# No return
###
def png_from_midi(midi_file_path)
  system("/Users/andrewthomas/code/sightreader/MuseScore/applebuild/mscore.app/Contents/MacOS/mscore -o #{midi_file_path}.png -M /Users/andrewthomas/code/sightreader/import_options.xml #{midi_file_path}.mid")
end

def svg_from_midi(midi_file_path)
  system("/Users/andrewthomas/code/sightreader/MuseScore/applebuild/mscore.app/Contents/MacOS/mscore -o #{midi_file_path}.svg -M /Users/andrewthomas/code/sightreader/import_options.xml #{midi_file_path}.mid")
end