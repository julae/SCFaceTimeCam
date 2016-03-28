// SC file to access and play back webcam image

s.boot;
NetAddr.localAddr;

// buffer play helper Synth
(
SynthDef(\playBuf,{
	arg out = 0, bufnum, amp = 1;
	var signal;
	signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 1);
	Out.ar(out, signal * amp);
}).add;
)


// buffer to which image data is written to
// sample size should be equal to buffer in Processing sketch (i.e. cam picture width)
~imBuf = Buffer.alloc(s, 1280);


// msg from webcam: scaled pixel buffer from Processing
(
OSCdef('webCamScan', {
	arg msg;
	~imBuf.setn(0, msg);
}, '\webcam')
)

//image buffer play back control
~imagePlay = Synth(\playBuf, [\bufnum, ~imBuf.bufnum]);

~imagePlay.run(false);
~imagePlay.run(true);

~busImageVol = Bus.control(s, 1);
~busImageVol.set(0.8);
~imagePlay.map(\amp, ~busImageVol);



// check buffer input
~imBuf.plot();
~imBuf.play(true);