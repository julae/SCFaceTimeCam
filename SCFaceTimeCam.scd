// SC file to access and play back webcam image

s.boot;
NetAddr.localAddr;

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

//play back image Buffer
~imBuf.play(true);

// check buffer input
~imBuf.plot();