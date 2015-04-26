import org.jfugue.player.Player;
import org.jfugue.pattern.Pattern;
import org.jfugue.midi.MidiFileManager;
import java.io.File;
import java.io.IOException;

public class StaccatoToMidi {
    public static void main(String[] args) {
        Pattern pattern = new Pattern(args[1]);           
        try {
            MidiFileManager m = new MidiFileManager();
            m.savePatternToMidi(pattern, new File("targets/" + args[0] + ".mid"));
        } catch (IOException e) {
            // Handle the exception
        }
    }
}