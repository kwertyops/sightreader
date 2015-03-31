###
# No return
###
def png_from_midi(midi_file_path)
  system("mscore -o #{midi_file_path}.png -M ../import_options.xml #{midi_file_path}.mid")
end
