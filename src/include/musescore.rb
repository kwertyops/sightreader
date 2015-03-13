###
# No return
###
def pdf_from_midi(midi_file_path)
  system("/Users/andrewthomas/code/sightreader/MuseScore/applebuild/mscore.app/Contents/MacOS/mscore #{midi_file_path}.mid -o #{midi_file_path}.png")
end