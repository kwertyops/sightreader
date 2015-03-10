###
# Returns track
###
def setup_seq(seq)
  # Create a first track for the sequence. This holds tempo events and stuff
  # like that.
  track = Track.new(seq)
  seq.tracks << track
  track.events << Tempo.new(Tempo.bpm_to_mpq(120))
  track.events << MetaEvent.new(META_SEQ_NAME, 'Sequence0')

  # Create a track to hold the notes. Add it to the sequence.
  track = Track.new(seq)
  seq.tracks << track

  # Give the track a name and an instrument name (optional).
  track.name = 'Track0'
  track.instrument = GM_PATCH_NAMES[0]

  # Add a volume controller event (optional).
  track.events << Controller.new(0, CC_VOLUME, 127)

  # Initial program change
  track.events << ProgramChange.new(0, 1, 0)

  return track
end

###
# Returns [intervals, last_event_time]
###
def intervals_from_track(track)
  intervals = Array.new
  notes_on = Hash.new # bucket containing currently on notes, in order to track on/off pairs
  last_event_time = 0

  track.each { |event|
    if(event.is_a? NoteEvent)
      event.print_decimal_numbers = true

      # Add note to the bucket
      if(event.is_a? NoteOnEvent)
        notes_on[event.note_to_s] = event.time_from_start
      
      # Remove note from bucket and push interval
      else
        intervals.push(
          [ [notes_on[event.note_to_s], event.note_to_s.to_i],
            [event.time_from_start,     event.note_to_s.to_i] ])
        notes_on.delete(event.note_to_s)
      end

      # Keep track of the last event time
      last_event_time = event.time_from_start if event.time_from_start > last_event_time
      
    # If this is not a note event, print it
    elsif event.is_a? MetaEvent
      if !event.is_a? ProgramChange
        puts event.to_s
      end
    end
  }

  return intervals, last_event_time
end