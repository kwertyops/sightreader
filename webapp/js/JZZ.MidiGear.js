/**
 *  JZZ.MidiGear.js
 *
 *  Retrieve MIDI instrument model info by its ID Response SysEx
 *
 *  This script is free to use, modify and distribute.
 *
 *  More information is available at http://jazz-soft.net
 *
 **/

var JZZ;
if(!JZZ) JZZ={};
else if(typeof JZZ!='object') throw new Error('JZZ namespace conflict');

JZZ.MidiGear=function(){
 var msg=JZZ.MIDI.apply(this,arguments).data();
 if(msg.charCodeAt(0)!=0xf0 || msg.charCodeAt(1)!=0x7e || msg.charCodeAt(3)!=6 || msg.charCodeAt(4)!=2) throw new Error('Invalid Model ID');
 var mnf;
 var mdl4;
 var mdl6;
 var mdl8;
 if(msg.charCodeAt(5)!=0){ mnf=msg.substr(5,1); mdl4=msg.substr(6,4); mdl6=msg.substr(6,6); mdl8=msg.substr(6,8);}
 else{ mnf=msg.substr(5,3); mdl4=msg.substr(8,4); mdl6=msg.substr(8,6); mdl8=msg.substr(8,8);}
 mnf=JZZ.MidiGear.All[mnf];
 if(!mnf) return {};
 var gear;
 if(mnf.data){
  gear=mnf.data[mdl4];
  if(!gear) gear=mnf.data[mdl6];
  if(!gear) gear=mnf.data[mdl8];
 }
 if(!gear) gear={};
 if(!gear.brand) gear.brand=mnf.name;
 return gear;
}

JZZ.MidiGear.DaveSmithInstruments={
'\x25\x01\x00\x00':{model:'Mopho',descr:'Synth Module'}
};

JZZ.MidiGear.Kurzweil={
'\x00\x40\x00\x0a':{model:'PC3LE8',descr:'Performance Controller'}
};

JZZ.MidiGear.EMU={
'\x02\x40\x01\x00':{model:'Xboard 49',descr:'USB MIDI Controller'}
};

JZZ.MidiGear.Roland={
'\x02\x02\x00\x00':{model:'DR-880',descr:'Drum Machine',brand:'BOSS'},
'\x04\x02\x00\x00':{model:'RD-300SX',descr:'Digital Piano'},
'\x06\x02\x00\x00':{model:'GT-8',descr:'Guitar Effects Processor',brand:'BOSS'},
'\x09\x02\x00\x00':{model:'TD-12',descr:'Percussion Sound Module'},
'\x0b\x02\x00\x00':{model:'GT-PRO',descr:'Guitar Effects Processor',brand:'BOSS'},
'\x10\x01\x00\x00':{model:'XV-3080',descr:'Synth Module'},
'\x10\x01\x02\x02':{model:'FANTOM',descr:'Synthesizer'},
'\x14\x02\x00\x00':{model:'MC-808',descr:'sampling groovebox'},
'\x16\x02\x00\x00':{model:'SH-201',descr:'Synthesizer'},
'\x18\x02\x00\x00':{model:'VP-550',descr:'Vocal & Ensemble Keyboard'},
'\x1a\x00\x00\x02\x00\x01':{model:'HP-330/245',descr:'Digital Piano'},
'\x1a\x00\x00\x02\x01\x01':{model:'HP-530',descr:'Digital Piano'},
'\x1a\x00\x00\x03':{model:'C-80',descr:'Digital Harpsichord'},
'\x1a\x00\x00\x04':{model:'FP-9',descr:'Digital Piano'},
'\x1a\x00\x00\x06\x00\x01':{model:'HP-2',descr:'Digital Piano'},
'\x1a\x00\x00\x06\x02\x01':{model:'DP-900',descr:'Digital Piano'},
'\x1a\x00\x01\x02':{model:'HP-147',descr:'Digital Piano'},
'\x1a\x00\x01\x06':{model:'HP-3',descr:'Digital Piano'},
'\x1a\x00\x02\x02\x00\x01':{model:'EP-70',descr:'Digital Piano'},
'\x1a\x00\x02\x02\x01\x01':{model:'EP-90',descr:'Digital Piano'},
'\x1a\x00\x02\x06':{model:'HP-7',descr:'Digital Piano'},
'\x1a\x00\x03\x02':{model:'HP-237',descr:'Digital Piano'},
'\x1a\x00\x04\x02':{model:'HP-147R',descr:'Digital Piano'},
'\x1a\x00\x05\x02':{model:'F-90',descr:'Digital Piano'},
'\x1a\x00\x06\x02\x00\x01':{model:'F-100',descr:'Digital Piano'},
'\x1a\x00\x06\x02\x01\x01':{model:'F-30',descr:'Digital Piano'},
'\x1a\x00\x06\x02\x02\x01':{model:'F-50',descr:'Digital Piano'},
'\x1a\x00\x06\x06':{model:'HP-101',descr:'Digital Piano'},
'\x1c\x01\x00\x00':{model:'DR-770',descr:'Drum Machine',brand:'BOSS'},
'\x1c\x02\x00\x00':{model:'VG-99',descr:'V-Guitar System'},
'\x20\x01\x00\x00':{model:'TD-8',descr:'Percussion Sound Module'},
'\x21\x02\x00\x00':{model:'V-Synth GT',descr:'Synthesizer Keyboard'},
'\x27\x02\x00\x00\x00\x03':{model:'Fantom-G6',descr:'Music Workstation'},
'\x27\x02\x00\x00\x01\x03':{model:'Fantom-G7',descr:'Music Workstation'},
'\x27\x02\x00\x00\x02\x03':{model:'Fantom-G8',descr:'Music Workstation'},
'\x2b\x02\x00\x00':{model:'RD-700GX',descr:'Digital Stage Piano'},
'\x2c\x02\x00\x00':{model:'RD-300GX',descr:'Digital Piano'},
'\x2f\x02\x00\x00':{model:'GT-10',descr:'Guitar Effects Processor',brand:'BOSS'},
'\x33\x02\x00\x00':{model:'VS-700R',descr:'Digital Audio Workstation'},
'\x36\x02\x00\x00':{model:'GW-8',descr:'Workstation'},
'\x39\x02\x00\x00':{model:'V-Piano',descr:'Digital Piano'},
'\x39\x02\x02\x00':{model:'V-Piano Grand (GP-7)',descr:'Digital Piano'},
'\x3a\x01\x00\x00':{model:'FP-3',descr:'Digital Piano'},
'\x3a\x02\x00\x00':{model:'JUNO-Di',descr:'Synthesizer'},
'\x3b\x02\x00\x00':{model:'VP-770',descr:'Vocal & Ensemble Keyboard'},
'\x41\x01\x00\x00':{model:'DR-670',descr:'Drum Machine',brand:'BOSS'},
'\x41\x02\x00\x00':{model:'GAIA SH-01',descr:'Synthesizer'},
'\x42\x00\x00\x07':{model:'SC-8820',descr:'Sound Module'},
'\x42\x00\x00\x08':{model:'KR-577/977/1077',descr:'Digital Piano'},
'\x42\x00\x00\x0d':{model:'KR-5',descr:'Digital Piano'},
'\x42\x00\x00\x0e\x00\x01':{model:'KR-7',descr:'Digital Piano'},
'\x42\x00\x00\x0e\x01\x01':{model:'KF-7',descr:'Digital Piano'},
'\x42\x00\x00\x0f\x00\x01':{model:'KR-15',descr:'Digital Piano'},
'\x42\x00\x00\x0f\x01\x01':{model:'KR-15/17',descr:'Digital Piano'},
'\x42\x00\x00\x11\x00\x01':{model:'RG-7',descr:'Digital Piano'},
'\x42\x00\x00\x11\x01\x01':{model:'RG-3',descr:'Digital Piano'},
'\x42\x00\x00\x12':{model:'KR-107',descr:'Digital Piano'},
'\x42\x00\x00\x16\x02\x01':{model:'HP-205',descr:'Digital Piano'},
'\x42\x00\x00\x16\x03\x01':{model:'HP-203',descr:'Digital Piano'},
'\x42\x00\x00\x16\x04\x01':{model:'FP-7',descr:'Digital Piano'},
'\x42\x00\x00\x16\x05\x01':{model:'FP-4',descr:'Digital Piano'},
'\x42\x00\x00\x16\x06\x01':{model:'HP-201',descr:'Digital Piano'},
'\x42\x00\x00\x17\x00\x01':{model:'AT-800',descr:'Organ'},
'\x42\x00\x00\x17\x01\x01':{model:'AT-900',descr:'Organ'},
'\x42\x00\x00\x17\x02\x01':{model:'AT-900C',descr:'Organ'},
'\x42\x00\x00\x18\x00\x01':{model:'AT-100',descr:'Organ'},
'\x42\x00\x00\x18\x01\x01':{model:'AT-300',descr:'Organ'},
'\x42\x00\x00\x18\x02\x01':{model:'AT-500',descr:'Organ'},
'\x42\x00\x00\x18\x03\x01':{model:'AT-75',descr:'Organ'},
'\x42\x00\x00\x19':{model:'RK-300',descr:'Keyboard'},
'\x42\x00\x00\x1a':{model:'RM-700',descr:'Digital Piano'},
'\x42\x00\x00\x1e\x01\x01':{model:'HP-507',descr:'Digital Piano'},
'\x42\x00\x00\x1e\x02\x01':{model:'HP-505',descr:'Digital Piano'},
'\x42\x00\x00\x1e\x03\x01':{model:'HP-503',descr:'Digital Piano'},
'\x42\x00\x00\x1e\x04\x01':{model:'DP90/DP90S',descr:'Digital Piano'},
'\x42\x00\x00\x1e\x05\x01':{model:'HPi-50',descr:'Digital Piano'},
'\x42\x00\x01\x03':{model:'E-500(OR)/E-500/E-300/KR-75',descr:'Intelligent Keyboard'},
'\x42\x00\x01\x09':{model:'HP-557R',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x00\x01':{model:'HP302/HP305',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x01\x01':{model:'HP307',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x02\x01':{model:'RG-1F/RG-3F',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x03\x01':{model:'LX-10F',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x04\x01':{model:'DP990F',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x05\x01':{model:'HPi-7F',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x06\x01':{model:'HPi-6F',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x07\x01':{model:'FP-7F',descr:'Digital Piano'},
'\x42\x00\x01\x1b\x08\x01':{model:'FP-4F',descr:'Digital Piano'},
'\x42\x00\x02\x03\x02\x01':{model:'HP-555G',descr:'Digital Piano'},
'\x42\x00\x02\x03\x03\x01':{model:'KR375',descr:'Digital Piano'},
'\x42\x00\x02\x09\x00\x01':{model:'KR-377',descr:'Digital Piano'},
'\x42\x00\x02\x09\x01\x01':{model:'KF-90',descr:'Digital Piano'},
'\x42\x00\x04\x03':{model:'E-600',descr:'Intelligent Keyboard'},
'\x42\x00\x05\x03':{model:'AT-30R',descr:'Organ'},
'\x42\x00\x06\x03':{model:'KR-277',descr:'Digital Piano'},
'\x42\x00\x07\x03':{model:'HPi-5',descr:'Digital Piano'},
'\x42\x02\x00\x00':{model:'VR-700',descr:'Combo Keyboard'},
'\x48\x01\x00\x00':{model:'SD-90',descr:'Studio Canvas',brand:'Edirol'},
'\x4a\x01\x00\x00':{model:'SH-32',descr:'Synthesizer Module'},
'\x4c\x02\x00\x00':{model:'JUNO-Gi',descr:'Mobile Synthesizer with Digital Recorder'},
'\x4d\x01\x00\x00':{model:'VK-8',descr:'Combo Organ'},
'\x50\x02\x00\x00':{model:'RD-700NX',descr:'Digital Piano'},
'\x51\x02\x00\x00':{model:'RD-300NX',descr:'Digital Piano'},
'\x55\x02\x00\x00':{model:'JUPITER-80',descr:'Synthesizer'},
'\x59\x01\x00\x00':{model:'MC-909',descr:'Sampling Groovebox'},
'\x59\x02\x00\x00':{model:'BR-80',descr:'Digital Recorder',brand:'BOSS'},
'\x60\x01\x00\x00':{model:'FP-5',descr:'Digital Piano'},
'\x60\x02\x00\x00':{model:'GT-100',descr:'Amp Effects Processor',brand:'BOSS'},
'\x62\x00\x00\x00\x00\x01':{model:'AT-20R',descr:'Organ'},
'\x62\x00\x00\x00\x01\x01':{model:'AT-30R',descr:'Organ'},
'\x62\x00\x00\x04\x00\x01':{model:'AT-800',descr:'Organ'},
'\x62\x00\x00\x04\x01\x01':{model:'AT-900',descr:'Organ'},
'\x62\x00\x00\x04\x02\x01':{model:'AT-900C',descr:'Organ'},
'\x62\x00\x00\x05\x00\x01':{model:'AT-100',descr:'Organ'},
'\x62\x00\x00\x05\x01\x01':{model:'AT-300',descr:'Organ'},
'\x62\x00\x00\x05\x02\x01':{model:'AT-500',descr:'Organ'},
'\x62\x00\x00\x05\x03\x01':{model:'AT-75',descr:'Organ'},
'\x63\x02\x00\x00':{model:'JUPITER-50',descr:'Synthesizer'},
'\x64\x01\x00\x00':{model:'RS-70',descr:'Synthesizer'},
'\x64\x01\x01\x00\x00\x01\x00\x00':{model:'RS-50',descr:'Synthesizer'},
'\x64\x01\x01\x00\x00\x01\x00\x01':{model:'JUNO-D',descr:'Synthesizer'},
'\x64\x02\x00\x00':{model:'INTEGRA-7',descr:'Sound Module'},
'\x6f\x01\x00\x00':{model:'FP-2',descr:'Digital Piano'},
'\x7a\x01\x00\x00':{model:'TD-20',descr:'Percussion Sound Module'}
};

JZZ.MidiGear.Korg={
'\x15\x01\x17\x00':{model:'Krome',descr:'Music Workstation'},
'\x68\x00\x17\x00':{model:'Kronos 61',descr:'Music Workstation'},
'\x7d\x00\x00\x00':{model:'R3',descr:'Synthesizer Vocoder'},
'\x7e\x00\x00\x00':{model:'microKORG XL',descr:'Synthesizer'}
};

JZZ.MidiGear.Yamaha={
'\x00\x41\x00\x03':{model:'MU100/MU100R/MU128',descr:'Tone Generator'},
'\x00\x41\x02\x05':{model:'AN200',descr:'Synthesizer'},
'\x00\x41\x02\x55':{model:'QY70',descr:'Sequencer'},
'\x00\x41\x03\x05':{model:'DX200',descr:'Synthesizer'},
'\x00\x41\x04\x34':{model:'QY100',descr:'Sequencer'},
'\x00\x41\x05\x2a':{model:'S90',descr:'Synthesizer'},
'\x00\x41\x19\x06':{model:'MOTIF-RACK ES',descr:'Tone Generator'},
'\x00\x41\x1a\x02':{model:'AN1x',descr:'Synthesizer'},
'\x00\x41\x1b\x04':{model:'MU2000',descr:'Tone Generator'},
'\x00\x41\x1c\x04':{model:'MU1000',descr:'Tone Generator'},
'\x00\x41\x1d\x03':{model:'RM1x',descr:'Sequence Remixer'},
'\x00\x41\x23\x04':{model:'S30',descr:'Synthesizer'},
'\x00\x41\x32\x06':{model:'S90ES',descr:'Synthesizer'},
'\x00\x41\x33\x06':{model:'MO6',descr:'Synthesizer'},
'\x00\x41\x34\x06':{model:'MO8',descr:'Synthesizer'},
'\x00\x41\x35\x06':{model:'MOTIF XS6',descr:'Synthesizer'},
'\x00\x41\x36\x06':{model:'MOTIF XS7',descr:'Synthesizer'},
'\x00\x41\x37\x02':{model:'MU90',descr:'Tone Generator'},
'\x00\x41\x37\x06':{model:'MOTIF XS8',descr:'Synthesizer'},
'\x00\x41\x3f\x06':{model:'CP5',descr:'Stage Piano'},
'\x00\x41\x40\x06':{model:'CP50',descr:'Stage Piano'},
'\x00\x41\x44\x06':{model:'MOX6',descr:'Synthesizer'},
'\x00\x41\x45\x06':{model:'MOX8',descr:'Synthesizer'},
'\x00\x41\x46\x01':{model:'MU50',descr:'Tone Generator'},
'\x00\x41\x47\x06':{model:'MX49',descr:'Synthesizer'},
'\x00\x41\x48\x01':{model:'QS300',descr:'Synthesizer'},
'\x00\x41\x4c\x01':{model:'EOS B900',descr:'Keyboard'},
'\x00\x41\x4f\x03':{model:'CS2x',descr:'Synthesizer'},
'\x00\x41\x51\x03':{model:'MU15',descr:'Tone Generator'},
'\x00\x41\x52\x02':{model:'MU90R',descr:'Tone Generator'},
'\x00\x41\x58\x04':{model:'MOTIF-RACK',descr:'Tone Generator'},
'\x00\x41\x62\x01':{model:'SDX3000',descr:'Keyboard'},
'\x00\x41\x6b\x01':{model:'CBX-K1XG',descr:'Keyboard'},
'\x00\x41\x77\x04':{model:'S03',descr:'Synthesizer'},
'\x00\x41\x7c\x04':{model:'MOTIF6',descr:'Synthesizer'},
'\x00\x41\x7d\x04':{model:'MOTIF7',descr:'Synthesizer'},
'\x00\x41\x7e\x04':{model:'MOTIF8',descr:'Synthesizer'},
'\x00\x43\x2c\x17':{model:'CP33',descr:'Stage Piano'},
'\x00\x43\x66\x19':{model:'P-155',descr:'Digital Piano '},
'\x00\x44\x2b\x19':{model:'NP-31',descr:'Portable Keyboard'},
'\x00\x44\x45\x17':{model:'MM6',descr:'Synthesizer'},
'\x00\x4c\x73\x07':{model:'DTXTREME',descr:'Drum Module'}
};

JZZ.MidiGear.Livid={
'\x01\x00\x01\x00':{model:'Brain v1',descr:'Do-It-Yourself Kit'},
'\x01\x00\x02\x00':{model:'Ohm64',descr:'MIDI Controller'},
'\x01\x00\x03\x00':{model:'block',descr:'MIDI Controller'},
'\x01\x00\x04\x00':{model:'Code',descr:'MIDI Controller'},
'\x01\x00\x07\x00':{model:'OhmRGB',descr:'MIDI Controller'},
'\x01\x00\x08\x00':{model:'CNTRL:R',descr:'MIDI Controller'},
'\x01\x00\x09\x00':{model:'Brain v2',descr:'Do-It-Yourself Kit'},
'\x01\x00\x0b\x00':{model:'Alias8',descr:'MIDI Controller'},
'\x01\x00\x0c\x00':{model:'Base',descr:'MIDI Controller'},
'\x01\x00\x0d\x00':{model:'Brain Jr',descr:'Do-It-Yourself Kit'}
};

JZZ.MidiGear.Fishman={
'\x00\x01\x00\x01':{model:'TriplePlay',descr:'Guitar Controller *'},
'\x00\x01\x00\x02':{model:'TriplePlay',descr:'Guitar Controller'}
};

JZZ.MidiGear.MegaLite={
'\x01\x00\x10\x00':{model:'Enlighten',descr:'DMX Control'}
};

JZZ.MidiGear.MusicComputing={
'\x01\x00\x05\x00':{model:'DAW',descr:'MIDI Controller'}
};

JZZ.MidiGear.DJTechTools={
'\x03\x00\x01\x00':{model:'Midi Fighter 3D',descr:'MIDI Controller'},
'\x04\x00\x01\x00':{model:'Midi Fighter Spectra',descr:'MIDI Controller'},
'\x05\x00\x01\x00':{model:'Midi Fighter Twister',descr:'MIDI Controller'}
};

JZZ.MidiGear.MAudio={
'\x63\x0e\x1a\x03':{model:'Axiom 61',descr:'MIDI Controller'}
};

JZZ.MidiGear.Novation={
'\x01\x00\x21\x00':{model:'Nova',descr:'Synth Module'}
};

JZZ.MidiGear.All={
'\x01':{name:'Dave Smith Instruments',data:JZZ.MidiGear.DaveSmithInstruments},
'\x07':{name:'Kurzweil',data:JZZ.MidiGear.Kurzweil},
'\x18':{name:'E-MU',data:JZZ.MidiGear.EMU},
'\x41':{name:'Roland',data:JZZ.MidiGear.Roland},
'\x42':{name:'Korg',data:JZZ.MidiGear.Korg},
'\x43':{name:'Yamaha',data:JZZ.MidiGear.Yamaha},
'\x00\x01\x61':{name:'Livid',data:JZZ.MidiGear.Livid},
'\x00\x01\x6e':{name:'Fishman',data:JZZ.MidiGear.Fishman},
'\x00\x01\x71':{name:'Mega Lite',data:JZZ.MidiGear.MegaLite},
'\x00\x01\x76':{name:'Music Computing',data:JZZ.MidiGear.MusicComputing},
'\x00\x01\x79':{name:'DJ TechTools',data:JZZ.MidiGear.DJTechTools},
'\x00\x20\x08':{name:'M-Audio',data:JZZ.MidiGear.MAudio},
'\x00\x20\x29':{name:'Novation',data:JZZ.MidiGear.Novation}
}
