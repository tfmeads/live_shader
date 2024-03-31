import ddf.minim.*;
import ddf.minim.analysis.*;

class LogFreqAnalyzer{
  AudioInput input;
  AudioPlayer music;
  FFT fft;
  float[] freqLevels;
  int numBands;
  float sampleRate = 44100;
  
  LogFreqAnalyzer(AudioInput in,int bands){
    
    input = in;
    numBands = bands;
    
    fft = new FFT( getInputBufferSize(), getInputSampleRate() ); // make a new fft
    sampleRate = getInputSampleRate();
    // split each octave into bands
    fft.logAverages(numBands -1, 1); 
    freqLevels = new float[99]; 
  }
  
  LogFreqAnalyzer(AudioPlayer ap,int bands){
    
    music = ap;
    numBands = bands;
    
    fft = new FFT( getInputBufferSize(), getInputSampleRate() ); // make a new fft
  
    // split each octave into bands
    fft.logAverages(numBands -1, 1); 
    freqLevels = new float[99]; 
  }
  
  



  void onDraw(int bands) {
    numBands = bands;
    fft.forward(getInputMix()); // perform forward FFT on inputs mix buffer
  
    for (int i = 0; i < numBands; i++) {  // numBands is the number of bands 
      int lowFreq;
  
      if ( i == 0 ) {
        lowFreq = 0;
      } 
      else {
        lowFreq = (int)((sampleRate/2) / (float)Math.pow(2, numBands - i));
      }
  
      int hiFreq = (int)((sampleRate/2) / (float)Math.pow(2, numBands -1 - i));
  
      // we're asking for the index of lowFreq & hiFreq
      int lowBound = fft.freqToIndex(lowFreq); // freqToIndex returns the index of the frequency band that contains the requested frequency
      int hiBound = fft.freqToIndex(hiFreq); 
  
  
      // calculate the average amplitude of the frequency band
      float avg = fft.calcAvg(lowBound, hiBound);

      //println("range " + i + " = " + "Freq: " + lowFreq + " Hz - " + hiFreq + " Hz " + " : " + avg);


       freqLevels[i] = avg;
      
    }
  }
  
  
  int getInputBufferSize(){
    if(input != null){return input.bufferSize();}
    if(music != null){return music.bufferSize();}
    
    return 0;
  }
  float getInputSampleRate(){
    if(input != null){return input.sampleRate();}
    if(music != null){return music.sampleRate();}
    
    return 0;
  }
  AudioBuffer getInputMix(){
    if(input != null){return input.mix;}
    if(music != null){return music.mix;}
    
    return null;
  }
  
  float getFreq(int band){
    return freqLevels[band];
  }
  
}
