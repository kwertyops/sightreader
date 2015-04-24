import org.jfugue.player.Player;
import org.jfugue.pattern.Pattern;
import org.jfugue.midi.MidiFileManager;
import org.staccato.ReplacementMapPreprocessor;
import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import org.jfugue.theory.ChordProgression;

public class TwelveBarBlues {
    public static void main(String[] args) {

        // Specify the transformation rules for this Lindenmayer system
        Map rules = new HashMap() {{
              put("Cmajw", "Cmajw Fmajw");
              put("Fmajw", "Rw Bbmajw");
              put("Bbmajw", "Rw Fmajw");
              put("C5q", "C5q G5q E6q C6q");
              put("E6q", "G6q D6q F6i C6i D6q");
              put("G6i+D6i", "Rq Rq G6i+D6i G6i+D6i Rq");
              put("axiom", "axiom V0 I[Flute] Rq C5q V1 I[Tubular_Bells] Rq Rq Rq G6i+D6i V2 I[Piano] Cmajw E6q " +
                "V3 I[Warm] E6q G6i+D6i V4 I[Voice] C5q E6q");
        }};

        // Set up the ReplacementMapPreprocessor to iterate 3 times
        // and not require brackets around replacements
        ReplacementMapPreprocessor rmp = ReplacementMapPreprocessor.getInstance();
        rmp.setReplacementMap(rules);
        rmp.setIterations(4);
        rmp.setRequireAngleBrackets(false);

        // Create a Pattern that contains the L-System axiom
        Pattern axiom = new Pattern("T120 " + "V0 I[Flute] Rq C5q "
                    + "V1 I[Tubular_Bells] Rq Rq Rq G6i+D6i "
                    + "V2 I[Piano] Cmajw E6q "
                    + "V3 I[Warm] E6q G6i+D6i "
                    + "V4 I[Voice] C5q E6q");
        try {
            MidiFileManager m = new MidiFileManager();
            m.savePatternToMidi(axiom, new File("music-file.mid"));
        } catch (IOException e) {
            // Handle the exception
        }
    }

    // public static void main(String[] args) throws IOException {
    //     Pattern pattern = new ChordProgression("I IV V")
    //             .distribute("7%6")
    //             .allChordsAs("$0 $0 $0 $0 $1 $1 $0 $0 $2 $1 $0 $0")
    //             .eachChordAs("$0ia100 $1ia80 $2ia80 $3ia80 $4ia100 $3ia80 $2ia80 $1ia80")
    //             .getPattern()
    //             .setTempo(100);
    //     //new Player().play(pattern);
    //     try {
    //         MidiFileManager m = new MidiFileManager();
    //         m.savePatternToMidi(pattern, new File("music-file.mid"));
    //     } catch (IOException e) {
    //         // Handle the exception
    //     }
    // }
}

// public class HelloWorld {
//   public static void main(String[] args) {
//     // Player player = new Player();
//     // player.play("C D E F G A B");
//     try {
//         Player player = new Player();
//         Pattern pattern = new Pattern("C D E F G A B");
//         MidiFileManager m = new MidiFileManager();
//         m.savePatternToMidi(pattern, new File("music-file.mid"));
//     } catch (IOException e) {
//         // Handle the exception
//     }
//   }
// }