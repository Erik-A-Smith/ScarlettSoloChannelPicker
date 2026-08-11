Build me a small Linux desktop utility for PipeWire that exposes each capture channel of a multichannel USB audio interface as its own normal mono microphone source.

My immediate hardware target is a Focusrite Scarlett Solo 4th Gen on Pop!_OS 24.04 using PipeWire.

Current behavior:
- PipeWire exposes the Scarlett capture device as:
  "Scarlett Solo 4th Gen Analog Surround 4.0"
- It appears as a 4-channel capture source.
- Applications such as Steam/Arma Reforger open all 4 channels.
- My actual microphone is connected to one physical Scarlett input, but many games do not handle this multichannel source correctly.
- I want each individual capture channel exposed as a separate mono microphone that normal applications can select.

Desired result:
- Detect compatible multichannel PipeWire capture devices automatically.
- For each capture channel, create a virtual mono source.
- Use readable names like:
  "Scarlett-Solo-Channel-1"
  "Scarlett-Solo-Channel-2"
  "Scarlett-Solo-Channel-3"
  "Scarlett-Solo-Channel-4"
- Each virtual microphone must contain ONLY that corresponding hardware capture channel.
- Steam, Discord, games, browsers, etc. should see these as ordinary mono microphone devices.
- Audio must remain 48 kHz and should not be needlessly resampled.
- Keep latency low.
- Do not mix channels together.

The app should have a very simple GUI:
- List detected PipeWire capture devices.
- Show their channel count.
- Let me enable/disable exposing individual channels.
- Show the generated virtual microphone names.
- Allow renaming a generated source.
- Allow setting one generated source as the default system microphone.
- Include a simple input level meter for each channel if reasonably easy.
- Remember settings across reboots.
- Automatically recreate the virtual sources when the audio interface is unplugged/replugged or PipeWire restarts.

Important implementation requirements:
- Target modern PipeWire/WirePlumber on Linux.
- Do NOT depend on PulseAudio being the real audio server, though PipeWire Pulse compatibility is fine where useful.
- Prefer native PipeWire/WirePlumber mechanisms over shelling out to dozens of pactl commands.
- It is acceptable to use PipeWire loopback/filter-chain nodes if that is the correct architecture.
- The routing must be deterministic: Channel 2 of the physical device must always map to Channel 2 of the generated virtual source.
- Do not assume FL/FR/RL/RR represent real surround speakers. For USB audio interfaces these are simply capture-channel positions assigned by the Linux audio stack.
- Handle device hotplugging cleanly.
- Avoid feedback loops.
- Do not modify the original physical source.
- Generated virtual sources should disappear cleanly when disabled or when the app exits, unless persistence is intentionally handled by a WirePlumber config/service.

Architecture:
First investigate the cleanest PipeWire-native way to implement this before writing the GUI. I want a small maintainable app, not a giant framework.

I am comfortable with C++, C#, and general software development, but I am not very familiar with PipeWire internals.

Preferred stack:
- C++ if the PipeWire API is significantly easier/native there.
- Otherwise Rust is acceptable if it substantially improves safety or PipeWire integration.
- For GUI, use GTK4/libadwaita or Qt6, whichever results in the simplest maintainable Linux application.
- Avoid Electron.

Development phases:
1. Build a command-line proof of concept that:
   - discovers the Scarlett,
   - identifies its capture channels,
   - creates one mono virtual source from a selected channel,
   - verifies that `pactl list short sources` can see it.
2. Add support for all channels.
3. Add persistence/hotplug handling.
4. Add the GUI.
5. Add packaging/documentation for Pop!_OS/Ubuntu.

For the first milestone, do NOT build the full GUI yet. Prove that a virtual mono source named something like:

"Scarlett-Solo-Channel-2"

can be created from ONLY channel 2 of my Scarlett.

Include:
- build instructions,
- dependencies,
- commands to verify the routing,
- a way to record from the generated source for testing,
- useful debug logging,
- cleanup/uninstall instructions.

Before implementing, explain which PipeWire mechanism you intend to use for channel extraction and why. Then implement the smallest working proof of concept.