### BeamSim

This repository is a small project showing the interferences obtained when emitting a sinusoidal signal from an array of emitters.

The current project allows for a linear phase shift phi between the emitters, phi can be editted while the simulation is running with the slider in the top left. The update only occurs after you've relased the slider.

The next objective is to optimise the computation of the beam as it currently takes around 700ms for a 500 by 500 image on my computer. 



## Details

- The code is in [Odin](https://odin-lang.org/), Running it is a simple as installing the compiler, navigating to the folder containing main.odin and calling the command "odin run ."
 
- Display done with [Raylib](https://www.raylib.com/)

