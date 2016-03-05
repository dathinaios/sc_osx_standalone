
// if you want to set a different port for your standalone.
// s = Server("standalone_name",NetAddr("localhost",57556));
// Server.default = s;

s.boot;
s.doWhenBooted{
  {WhiteNoise.ar * 0.1}.play;
  "hello world".postln;
};
