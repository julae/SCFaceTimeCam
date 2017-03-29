// SC file to access and play back webcam image

s.boot;
NetAddr.localAddr;
n = NetAddr("127.0.0.1", 12000);

(
// buffer play helper Synth
SynthDef(\playImBuf,{
	arg bufnum, amp = 0.001, out = 24;
	var signal;
	signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum), loop: 1);
	Out.ar([0,1], signal * amp);
}).add;

// input to pitch and amp buffer
SynthDef(\InputToBuf, {
	arg freqBufNum, ampBufNum, inBus = 0;
	var amp, freq, in;
	in = In.ar( inBus );
	freq = ZeroCrossing.ar( in );
	amp = Amplitude.kr( in );
	RecordBuf.kr( freq, freqBufNum );
	RecordBuf.kr( amp, ampBufNum );
}).add;
)


// buffer to which image data is written to
// sample size should be equal to buffer in Processing sketch (i.e. cam picture width)
~imBuf = Buffer.alloc(s, 1280);
// buffer for amp and freq values
~freqBuffer = Buffer.alloc(s, 1);
~ampBuffer = Buffer.alloc(s, 1);


// writes output 0 frequency to buffer
Synth.after(1, \InputToBuf, [\freqBufNum, ~freqBuffer.bufnum, \ampBufNum, ~ampBuffer.bufnum, \inBus, 0]);

// message to P5
(

// terrible spaghetticode begin
~sendMsgRoutine = Prout({
	loop
		{
		0.1.yield;
		~ampBuffer.get(0, action:
			{arg msgAmp;
				~freqBuffer.get(0, action:
					{arg msg, msgFloat;
						msgFloat = msg.asFloat;
						n.sendMsg("/adress", msgFloat, msgAmp.asFloat);
				})
			}
		);

		}
}).play();
)
~sendMsgRoutine.free();
~sendMsgRoutine.stop();
~sendMsgRoutine.play();


// msg from webcam: scaled pixel buffer from Processing
(
~p5toSc = OSCdef('webCamScan', {
	arg msg;
	~imBuf.setn(0, msg);
}, '\webcam')
)

~p5toSc.free;


//image buffer play back control
~imagePlay = Synth(\playImBuf, [\bufnum, ~imBuf.bufnum]);

~imagePlay.run(false);
~imagePlay.run(true);

~busImageVol = Bus.control(s, 1);
// set to 0.2 max
~busImageVol.set(0.5);
~imagePlay.map(\amp, ~busImageVol);



// check buffer input
~imBuf.plot();
~imBuf.play(true);