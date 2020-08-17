#include "MBI_Sine.h"
#include "Arduino.h"



void  MBI_Sine::init(double dt)
{
  this->dt = dt;
  waveName = "Sine";
}


void MBI_Sine::setParams(double amp, double freq, double phase, double dutyCycle)
{
  this->amp = amp;
  this->freq = freq;
  this->phase = phase;
  this->dutyCycle = dutyCycle;
  this->offset = amp / 1.0; 
}


void MBI_Sine::setAmp(double amp)
{
  this->amp = amp;
  this->offset = amp / 1.0;
}


double MBI_Sine::evaluate(double t)
{
  return (amp * sin(TWO_PI * freq * t + phase)) + offset;
}
