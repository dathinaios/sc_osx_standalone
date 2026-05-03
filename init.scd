
// if you want to set a different port for your standalone.
// s = Server("standalone_name",NetAddr("localhost",57556));
// Server.default = s;

Server.default = s = Server.local;

s.waitForBoot{
  {WhiteNoise.ar * 0.1}.play;
  "hello world".postln;

  // Mic input test — scope only, no output to speakers
  // ~micBus = Bus.audio(s, 1);
  // { Out.ar(~micBus, SoundIn.ar(0)) }.play;
  // ~micBus.scope;
  // "Mic scope running — check the scope window for input signal.".postln;
};
