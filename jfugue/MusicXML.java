import org.jfugue.player.Player;
import org.jfugue.pattern.Pattern;
import org.jfugue.midi.MidiFileManager;
import org.jfugue.integration.LilyPondParserListener;
import org.jfugue.integration.MusicXmlParserListener;
import org.jfugue.theory.ChordProgression;

import org.staccato.ReplacementMapPreprocessor;
import org.staccato.StaccatoParser;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

public class MusicXML {
    public static void main(String[] args) {

        try
        {
            System.out.println(args[0] + " " + args[1] + " " + args[2]);
            Pattern pattern = new Pattern(args[0]);           

            try {
                MidiFileManager m = new MidiFileManager();
                m.savePatternToMidi(pattern, new File("music-file.mid"));
            } catch (IOException e) {
                // Handle the exception
            }
        }
        catch(IOException e)
        {
            System.out.println(e.toString());
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