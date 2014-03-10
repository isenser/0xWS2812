# 0xWS2812 STM32 driver for WS2812(B) RGB LEDs

0xWS2812 pronounced "hex-WS2812"

This code aims at providing a basic interface to the WS2812(B) individually addressable RGB LEDs by WorldSemi. 

The code outputs 16 parallel data streams to 16 parallel strings of LEDs. This allows the MCU to drive a large
number of LEDs rather memory efficient, although RAM size is still the limiting factor for the number of LEDs that can be driven.

The number of LEDs that can be driven by this library can be approximated by the following formula (it won't be exactly that many as the library needs some RAM, too):
Number of LEDs = (RAM size in bytes / 48) * 16

### Whaaa? This code is crap and incomplete! WTF did you think calling this a library?!

Calm your finite state machines.

This code is a work in progress and I admit that in it's current form it's a bit of a hassle adapting it to different MCUs.
I will get around to working more on this when I have time as I'm also busy with school finals. 
If you find a bug please report it and if you can and are willing to, provide a fix.

At some point this might actually become a full grown library that supports STM32F100, STM32F4 etc.

### Why does this library exist?

Due to the non-standard NRZ protocol used to control these LEDs the correct timing of the data stream is very important 
and is not easily achievable with standard MCU peripherals like SPI/USART/I2C.  

### How does it work? 

The approach used here is similar to the approach of the [OctoWS2812](http://www.pjrc.com/teensy/td_libs_OctoWS2811.html) library for the Teensy.

This library makes use of the output compare features of the STM32s General Purpose Timer and the DMA (Direct Memory Access) controller.
The DMA allows to transfer data from memory to a peripheral register in this case a GPIO port quickly without the CPU being involved.
Therefore the CPU can already prepare the next frame to be sent while the current frame is still being transmitted.

The idea to create 16 parallel 800kBit/s data streams is the following:
* Use a Timer to create an 800kHz time base and a DMA request every 1.25us.
* Use 2 compare modules to create DMA requests at the low bit time (350ns) and the high bit time (700ns)

1. The 1.25us DMA request sets all bits of the GPIO port high
2. The 350ns DMA request transfers the data from the frame buffer to the GPIO port. If the bit is a 0, the GPIO pin will go low, otherwise it will stay high.
3. The 700ns DMA request sets all GPIO pins low.
4. Repeat steps 1 to 3 until all bits have been transmitted.

This creates a stream of pulses with a pulse period of 1.25us and a pulse width of either 350ns or 700ns depending on the bit value the pulse represents.

Transferring the data via DMA to the GPIO port means that per 16 LEDs one half word (two bytes) is needed per bit. At 24 bits per LED that makes 24 half words (48 bytes) per 16 LEDs.

The frame buffer is transmitted MSBit first in the order G-R-B.

### How do I use it?

Currently you have to fill the frame buffer with 24 bytes per 16 LEDs and then call the WS2812_sendbuf(24*#LEDs).

### Licensing

This code is licensed under the MIT License, see LICENSE for more info.