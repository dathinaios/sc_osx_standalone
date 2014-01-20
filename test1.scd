s.boot;
s.doWhenBooted{
	{WhiteNoise.ar * 0.1}.play;
  "hello world".postln;
};
