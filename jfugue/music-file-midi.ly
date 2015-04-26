% Lily was here -- automatically converted by /Applications/LilyPond.app/Contents/Resources/bin/midi2ly from music-file.mid
\version "2.14.0"

\layout {
  \context {
    \Voice
    \remove "Note_heads_engraver"
    \consists "Completion_heads_engraver"
    \remove "Rest_engraver"
    \consists "Completion_rest_engraver"
  }
}

trackAchannelA = {
  
  \tempo 4 = 100 
  
}

trackAchannelB = \relative c {
  c8 e g a b a g e 
  | % 2
  c e g a b a g e 
  | % 3
  c e g a b a g e 
  | % 4
  c e g a b a g e 
  | % 5
  f a c d e d c a 
  | % 6
  f a c d e d c a 
  | % 7
  c, e g a b a g e 
  | % 8
  c e g a b a g e 
  | % 9
  g b d e fis e d b 
  | % 10
  f a c d e d c a 
  | % 11
  c, e g a b a g e 
  | % 12
  c e g a b a g e 
  | % 13
  
}

trackA = <<

  \clef bass
  
  \context Voice = voiceA \trackAchannelA
  \context Voice = voiceB \trackAchannelB
>>


\score {
  <<
    \chords { c1 g:sus4 f e }
    \context Staff=trackA \trackA
  >>
  \layout {}
  \midi {}
}
