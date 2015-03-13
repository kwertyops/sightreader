var Jazz = document.getElementById("Jazz1"); 
if(!Jazz || !Jazz.isJazz) Jazz = document.getElementById("Jazz2");
var metronome_playing=0;
var metronome_interval=500;
var metronome_timeout;
var timesignature=4;
var metronome_count;

function play(){
 if(!(Jazz && Jazz.isJazz)) return;
 if(metronome_playing==1){
  metronome_playing=0;
  document.getElementById('play').innerHTML='Play';
  clearTimeout(metronome_timeout);
 } else {
  metronome_playing=1;
  document.getElementById('play').innerHTML='Stop';
  metronome_count=0; tick();
 }
}
function tick(){
 Jazz.MidiOut(0x99,metronome_count?33:34,127);
 metronome_count++; if(metronome_count>=timesignature) metronome_count=0;
 metronome_timeout=setTimeout(tick,metronome_interval);
}
function changemidi(){
 Jazz.MidiOutOpen(select_out.options[select_out.selectedIndex].value);
}
function changetimesignature(){
 timesignature=select_timesignature.options[select_timesignature.selectedIndex].value;
}
function changetempo(){
 metronome_interval=60000./select_tempo.options[select_tempo.selectedIndex].value;
}

var select_timesignature=document.getElementById('timesignature');
for(var i=1;i<=8;i++){ select_timesignature[i-1]=new Option(i,i,i==4,i==4);}
var select_tempo=document.getElementById('tempo');
for(var i=40;i<=240;i++){ select_tempo[i-40]=new Option(i,i,i==120,i==120);}
var select_out=document.getElementById('selectmidi');
try{
 var list=Jazz.MidiOutList();
 for(var i in list){
  select_out[i]=new Option(list[i],list[i],i==0,i==0);
 }
 document.getElementById('selectmididiv').className='';
}
catch(err){}