# SCFaceTimeCam

Sonifies MacBook's FaceTime camera input using SuperCollider and Processing. Uses [oscP5](http://www.sojamo.de/libraries/oscP5/) library for communication between SC and P3. 

Intended for live performances, to sonify objects, images, your face or whatever else you hold in front of your camera.

### Buffer size
The size of the ˜imBuf buffer in SCFaceTimeCam.scd implies a ground frequency which can be heard for most camera input. Changing the size will change this note, however it has to be the same as bufferSize in SCFaceTimeCam.pde