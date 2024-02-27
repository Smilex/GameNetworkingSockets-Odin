# GameNetworkingSockets-Odin
Odin bindings for Valve's GameNetworkingSockets - https://github.com/ValveSoftware/GameNetworkingSockets


These are hand written bindings, so beware that stuff is missing, that there are errors and that I didn't name stuff consistently
I hope to generate these in the future

I wrote some examples for non-P2P connections and for P2P connections, with a signaling project. 

## Usage
You'll need the small changes I made to GameNetworkingSockets. My fork is here - https://github.com/Smilex/GameNetworkingSockets/tree/master - and the pull request I made for it is here, in case the official repo has included them - https://github.com/ValveSoftware/GameNetworkingSockets/pull/310

Keep in mind that you'll need to compile GameNetworkingSockets with WebRTC support, if you want P2P support

After you've compiled GameNetworkingSockets, copy the .lib into the "GameNetworkingSockets-Odin" top directory, and the necessary .DLLs need to be present with the executable

## Platforms
Currently I've only tested this on Windows
I expect the only necessary change for other platforms, is to load the correct library in the Odin foreign interface, that this project uses

## Building examples
The examples in this project were just built with "odin build ."
