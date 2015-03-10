var Jazz = document.getElementById("Jazz1"); 
if(!Jazz || !Jazz.isJazz) Jazz = document.getElementById("Jazz2");
var player;
var midiIn;
var midiOut;
var recording;
var playing;
var selIn = document.getElementById('selectin');
var selOut = document.getElementById('selectout');
var btnRec = document.getElementById('rec');
var btnPlay = document.getElementById('play');
var btnStop = document.getElementById('stop');
var dwnld = document.getElementById('dwnld');
var start;

function onPlayerEvent(e){
 if(e.midi instanceof JZZ.Midi){
  Jazz.MidiOutRaw(e.midi.array());
 }
 else if(e.control=='stop'){
  for(var i=0;i<16;i++) Jazz.MidiOut(0xb0+i,123,0);
  playing = false;
  update();
 }
}
function rec(){
 player = undefined;
 recording = true;
 Jazz.ClearMidiIn();
 start = Jazz.Time();
 update();
}
function play(){
 playing = true;
 update();
 player.play();
}
function stop(){
 if(playing) player.stop();
 else if(recording){
  // MIDI file type 0 - all channels in one track; 100 ppq; default tempo 120 bpm is 5 ms per tick;
  var mf = new JZZ.MidiFile(0,100);
  var tr = new JZZ.MidiFile.MTrk; mf.push(tr);
  var a;
  while(a=Jazz.QueryMidiIn()){
   if(!a.length || a[1]==0xf8 || a[1]==0xfe || a[1]==0xff) continue;
   var t=(a[0]-start)/5; // convert ms to ticks
   a.shift();
   var len=JZZ.Midi.len(a[0]);
   if(len!=undefined) a=a.slice(0,len);
   tr.addMidi(t,a);
  }
  tr.setTime((Jazz.Time()-start)/5);
  player = mf.player();
  player.onEvent = onPlayerEvent;
  recording = false;
  update();
  var uri = 'data:audio/midi;base64,' + JZZ.MidiFile.toBase64(mf.dump());
  dwnld.innerHTML='MIDI file: <a href=' + uri + '>DOWNLOAD</a> <embed src=' + uri + ' autostart=false>';
 }
}
function changein(){
 if(!Jazz || !Jazz.isJazz) return;
 midiIn = Jazz.MidiInOpen(selIn.options[selIn.selectedIndex].value);
 for(var i in selIn){
  if(midiIn==selIn.options[i].value){ selIn[i].selected=1; break;}
 }
}
function changeout(){
 if(!Jazz || !Jazz.isJazz) return;
 midiOut = Jazz.MidiOutOpen(selOut.options[selOut.selectedIndex].value);
 for(var i in selOut){
  if(midiOut==selOut.options[i].value){ selOut[i].selected=1; break;}
 }
}
function update(){
 btnRec.disabled = recording || playing || !midiIn;
 btnPlay.disabled = playing || !player || !midiOut;
 btnStop.disabled = !playing && !recording;
 selOut.disabled = playing;
 selIn.disabled = recording;
}
try{
 var list=Jazz.MidiOutList();
 for(var i in list){
  selOut[i]=new Option(list[i],list[i],0,0);
 }
 for(var i in list){
  midiOut=Jazz.MidiOutOpen(i);
  if(midiOut){ selOut[i].selected=1; break;}
 }
 list=Jazz.MidiInList();
 for(var i in list){
  selIn[i]=new Option(list[i],list[i],0,0);
 }
 for(var i in list){
  midiIn=Jazz.MidiInOpen(i);
  if(midiIn){ selIn[i].selected=1; break;}
 }
 update();
}
catch(err){}