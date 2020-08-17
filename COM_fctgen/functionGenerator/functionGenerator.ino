
/*  JK 25 Feb 2020
 *     
 *     
 *  Waveform generator using Adafruit Feather M4 Express (SAMD51)
 * 
 *     required libraries: MegunoLink (for CommandHandler) and SAMD51_InterruptTimer
 *     required board : Adafruit Feather M4 Express (SAMD51)
 * 
 *     pins:  A0, A1 are 12-bit, analog output channels 0 & 1. Digital out syncPin is 10.  
 *            LED active, pin 13 (built-in)
 *            
 *     Serial port: 1000000 baud, NL & CR
 *     
 *  7 July 2020 ver 1 - single channel, 5 waveforms
 *  
 *  Units: Amplitudes in volts, freqs in Hz, phase in rads, dutyCycle as integral percentage e.g. 50
 */

#include <stdlib.h>
#include <Arduino.h>
#include "CommandHandler.h"                 // The serial command handler is defined in here. 
#include "SAMD51_InterruptTimer.h"  
#include "MBI_Waveform.h"
#include "MBI_Sine.h"
#include "MBI_Triangle.h"
#include "MBI_Square.h"
#include "MBI_Sawtooth.h"
#include "MBI_RampAndHold.h"

#define  Chan0  A0
#define  Chan1  A1

const double Fs = 10000.0;                  // 10k Hz sample frequency
const double Dt = 1.0 / Fs;                 // timer period
const double MaxFreq = 1000.0;              // max freq
const double MinFreq = 1.0;                 // min freq
const double DacRes = (3.3 / 4096);         // DAC resolution: range = 3.3 V, over 12-bits
const double MaxAmp = 4095;                 // max amplitude : 12 bits
const int LEDPin = 13;
const int syncPin = 10;
const int pixelPin = 8;
const int Baud = 1000000;

double amp = 640;             
double freq = 1;              
double period = 1 / freq;      
double dutyCycle = 50;         
double dcOffset = 0;         
double phase = 0;              
volatile double t = 0; 
volatile bool toggle = true;
volatile bool isActive = false;   
volatile bool shouldUpdate = false;
bool shouldStartTimer = true;
int bytesAvail = 0;
double val = 0;
int count;
int targetCount;

/*
  All commands start with a ! character E.G.:
     !Set sin 0.5 4 0 0
     !Start
     !Stop
     !Get
*/

// The serial command handler. Receives serial data and dispatches 
// recognised commands to functions registered during setup. 
CommandHandler<20, 40> SerialCommandHandler;

// waveforms
MBI_Waveform* pWave1;   // base class pointer
MBI_Sine sine;            
MBI_Triangle triangle;
MBI_Square square;
MBI_Sawtooth sawtooth;
MBI_RampAndHold ramp;


// timer, TC, runs at 10 kHz (declared as const double Fs)
void timerHandler() {
  if(isActive)
  {
    t = t + Dt;  
    shouldUpdate = true;
  }
}


void setup() 
{  
  Serial.begin(Baud);

  while (!Serial) {
    delay(10); 
  }
  
  pinMode(LEDPin, OUTPUT);
  pinMode(syncPin, OUTPUT);
  pinMode(pixelPin, OUTPUT);

  SerialCommandHandler.AddCommand(F("Get"), Cmd_GetParams);
  SerialCommandHandler.AddCommand(F("Set"), Cmd_SetParams);
  SerialCommandHandler.AddCommand(F("Start"), Cmd_Start);
  SerialCommandHandler.AddCommand(F("Stop"), Cmd_Stop);
  SerialCommandHandler.AddCommand(F("LED"), Cmd_LED);  
  SerialCommandHandler.AddCommand(F("Timer"), Cmd_Timer);  
  SerialCommandHandler.AddCommand(F("SetAmp"), Cmd_SetAmp);  
  SerialCommandHandler.AddCommand(F("SetFreq"), Cmd_SetFreq);  
  SerialCommandHandler.AddCommand(F("SetWaveform"), Cmd_SetWaveform);  
  SerialCommandHandler.AddCommand(F("Test"), Cmd_Test);  
  SerialCommandHandler.SetDefaultHandler(Cmd_Unknown);

  // initialize the waveforms
  sine.init(Dt);
  sine.setParams(amp, freq, phase, dutyCycle);
  triangle.init(Dt);
  triangle.setParams(amp, freq, phase, dutyCycle);
  sawtooth.init(Dt);
  sawtooth.setParams(amp, freq, 0.900, 0.100);
  square.init(Dt);
  square.setParams(amp, freq, phase, dutyCycle);
  ramp.init(Dt);
  ramp.setParams(amp, .9, .4, .9);
 
  // set the pointer to something 'useful'
   pWave1 = &sine; // &ramp;  //  &sawtooth;  //   &square; //  &triangle; //  &sawtooth;

  // start the 10kHz timer (period in microseconds)
  TC.startTimer((unsigned long)(Dt * 1000000.0), timerHandler);

  targetCount = period / Dt;   
  count = 0;
    
  // start at 0
  analogWrite(Chan0, 0);
  analogWrite(Chan1, 0);
  digitalWrite(syncPin, LOW);
}


void loop() {
  if(isActive & shouldUpdate)
  {
    val = dcOffset + pWave1->evaluate(t);
    // prevent negative values
    if(val < 0)                                     
    {
      val = 0;
    }

    analogWrite(Chan0, val);

    // is it time to toggle the sync?
    if(count >= targetCount)
    {
      digitalWrite(syncPin, toggle);
      toggle = not(toggle);
      count = 0;
    }

    // modifying a volatile variable 
    noInterrupts();
    shouldUpdate = false;
    interrupts();
    
    count++;
  } 
  SerialCommandHandler.Process();
}


// -----------------------------------------------------------------------
// Command handlers. 
// These functions are called when a serial command is received although 
//  SetParams() is the main one.  
//  Not all these commands are fully implemented ....

void Cmd_SetParams(CommandParameter &Parameters)  //  waveName, amp, freq, phase, dutyCycle
{  
  const char * waveform = Parameters.NextParameter();
  amp = Parameters.NextParameterAsDouble();
  amp = round(amp / DacRes);  // convert & round to D/A units
  double param1 = Parameters.NextParameterAsDouble();
  double param2 = Parameters.NextParameterAsDouble();
  double param3 = Parameters.NextParameterAsDouble();      

  // validate
  // waveform waveName is validate by the if-else
  //
  if(amp < 0 || amp > MaxAmp)
  {
    reportError("Invalid amp ");
    return;
  }
  if(param1 > 0)
  {
    freq = param1;
    period = 1/param1;
    targetCount = period / Dt;  
  } 
  else if(param1 <= 0)
  {
    reportError("Invalid frequency ");
    return;
  }  
  if(param2 < 0)
  {
    reportError("Invalid phase ");
    return;
  }
  if(param3 < 0)
  {
    reportError("Invalid dutyCycle ");
    return;
  }    
  phase = param2;
  dutyCycle = param3;

  // set the waveform
  if(strcmp(waveform, "sin") == 0)
  {
    pWave1 = &sine;
  }
  else if(strcmp(waveform, "tri") == 0)
  {
    pWave1 = &triangle;
    dcOffset = 0;
  }
  else if(strcmp(waveform, "sqr") == 0)
  {
    pWave1 = &square;    
    dcOffset = 0;
  }
  // ramp params are interpreted as : amp, rampDur1, holdDur, rampDur2
  else if(strcmp(waveform, "ramp") == 0)
  {
    pWave1 = &ramp;    
    dcOffset = 0;
    count = 0;
    targetCount = (freq + phase + dutyCycle) / Dt; 
  }
  // sawtooth params are interpreted as : amp, freq, rampDur1, rampDur2
  else if(strcmp(waveform, "saw") == 0)
  {
    pWave1 = &sawtooth;    
    dcOffset = 0;
  }
  else 
  {
    Serial.print("\n\n*** cannot create ");
    Serial.print(waveform);
    Serial.println("! Must match 1 of sin, tri, sqr, ramp, saw ***\n"); 
    return;
  }
  pWave1->setParams(amp, freq, phase, dutyCycle);
}


void Cmd_Test(CommandParameter &Parameters)
{  
  const int numTests = 5;
  char* testStr = "pfjiawe eofaewfoijaf";
  
  Serial.println("\n**Test");
//
  for(int i = 0 ; i < numTests; i++)
  {
    sprintf(testStr, "hello %d\n", i);
    Serial.println(testStr);
    reportError(testStr);
    delay(1000);
  }
  Serial.println("Test done**\n");
  return;
}


void Cmd_SetFreq(CommandParameter &Parameters)
{
  freq = Parameters.NextParameterAsDouble();
  period = 1/freq;
  targetCount = period / Dt;   

  pWave1->setFreq(freq);
}


void Cmd_SetWaveform(CommandParameter &Parameters)
{
  const char * waveform = Parameters.NextParameter();
  Serial.println(waveform);  
}


void Cmd_GetParams(CommandParameter &Parameters)
{
  reportParams();  
}


void Cmd_SetAmp(CommandParameter &Parameters)
{
  amp = Parameters.NextParameterAsDouble();
  pWave1->setAmp(amp);
}


void Cmd_Timer(CommandParameter &Parameters)
{
  int n =  Parameters.NextParameterAsInteger();
  if(n == 1)
  { 
    Serial.println("starting timer");
  } 
  else 
  {
    Serial.println("stopping timer");
  }
}


void Cmd_Start(CommandParameter &Parameters)
{  
  Serial.println("Start");  
  count = 0;
  t = 0;
  isActive = true;
  toggle = false;
  digitalWrite(LEDPin, HIGH);
  digitalWrite(syncPin, HIGH);
}


void Cmd_Stop(CommandParameter &Parameters)
{
  isActive = false;
  count = 0;
  t = 0;
  toggle = false;
  pWave1->stop();
  
  // set everyone LOW
  digitalWrite(syncPin, LOW);
  analogWrite(Chan0, 0);
  digitalWrite(LEDPin, LOW);
}



void Cmd_LED(CommandParameter &Parameters)
{
  const char *State = Parameters.NextParameter();
  Serial.println(F("LED toggle"));
  
  if (strcmp(State, "on") == 0)
  {
    digitalWrite(LEDPin, HIGH);
  }
  else
  {
    digitalWrite(LEDPin, LOW);
  }
}


void Cmd_Unknown()
{
  Serial.println(F("\n**** Unknown command! ****"));
}


void reportParams()
{  
  pWave1->getParams();
}


void reportError(const char* pErrStr)
{
  Serial.print("\n\n*** Error: ");
  Serial.print(pErrStr);
  Serial.println("  ***\n\n");
}
