# Scarlett Solo Channel Picker

The command-line tool exposes individual channels of a multichannel PipeWire
capture device as normal mono microphones. A systemd user daemon supervises all
four Scarlett channels with persistent names and hotplug recovery.

Tested with a Focusrite Scarlett Solo 4th Gen on Pop!_OS 24.04. It should also
work with similarly exposed multichannel PipeWire capture sources when selected
explicitly with `--device`.

## Quick start

```sh
git clone https://github.com/Erik-A-Smith/ScarlettSoloChannelPicker.git
cd ScarlettSoloChannelPicker
./subscribe.sh
```

No root privileges are needed to install the user service. After subscription,
applications such as Discord, Steam, games, and browsers can select:

- `Scarlett-Solo-Channel-1`
- `Scarlett-Solo-Channel-2`
- `Scarlett-Solo-Channel-3`
- `Scarlett-Solo-Channel-4`

## Mechanism

The proof of concept runs one native PipeWire `pw-loopback` client. Its capture
stream targets the physical source and requests exactly one advertised channel
position with `stream.dont-remix=true`. Its playback stream is a virtual
`Audio/Source` with a single `MONO` port. PipeWire copies the selected capture
channel to that port without mixing it with the others.

Channel positions are selected by their order in the hardware node's
`audio.position` property. Thus channel 2 might currently be labelled `FR`, but
the program treats that as the second interface channel—not as a speaker role.
Both sides request 48 kHz. When the PipeWire graph and hardware are also at
48 kHz, no sample-rate conversion is needed.

This uses PipeWire's native loopback facility directly. `pactl` is used only as
an optional compatibility-layer verification tool.

## Dependencies

On Pop!_OS 24.04 or Ubuntu 24.04:

```sh
sudo apt install pipewire-bin jq pulseaudio-utils
```

`pipewire-bin` supplies `pw-dump`, `pw-loopback`, and `pw-record`.

## Run one channel manually

No compilation is required for this shell-based milestone:

```sh
chmod +x ./scarlett-channel-source
./scarlett-channel-source --list
./scarlett-channel-source --channel 2 --verbose
```

If automatic Scarlett selection is ambiguous, copy the exact node name shown by
`--list`:

```sh
./scarlett-channel-source --device 'alsa_input.example' --channel 2
```

Keep it running while testing. Override the application-visible name with
`--name My-Microphone`; names are limited to safe PipeWire identifier
characters. `--description` may contain spaces.

## Verify and record

In another terminal, confirm that PipeWire Pulse exposes the source:

```sh
pactl list short sources | grep Scarlett-Solo-Channel-2
```

Inspect its negotiated format and ports natively:

```sh
wpctl status
pw-dump | jq '.[] | select(.info.props["node.name"] == "Scarlett-Solo-Channel-2")'
```

Record five seconds directly through PipeWire, then play it back:

```sh
timeout 5 pw-record --target Scarlett-Solo-Channel-2 --rate 48000 --channels 1 channel-2.wav
pw-play channel-2.wav
```

To verify isolation, feed or tap only physical input 2 while recording. Input 1
must not appear. For graph-level confirmation, run `pw-link -l` and check that
the loopback capture port is linked only to the second port of the Scarlett
source.

## Debugging

Use `--verbose` for the chosen node, channel position, and loopback properties.
Additional PipeWire logging can be enabled for one run:

```sh
PIPEWIRE_DEBUG=3 ./scarlett-channel-source --channel 2 --verbose
```

If the script refuses a device without `audio.position`, that is intentional:
guessing a channel mapping would violate deterministic routing. Capture a
diagnostic with `pw-dump > pw-dump.json` for that case.

## Stop a manual source

Press Ctrl-C in the running process. Because the virtual source belongs to that
`pw-loopback` process, it disappears when the process exits or PipeWire stops.
The manual command does not modify system or user configuration. Delete
`channel-2.wav` if you created the test recording.

## Autostart all four channels

Install and start the user-session daemon (no `sudo`):

```sh
./subscribe.sh
```

It exposes all four channels, starts automatically at login, and recreates them
after device hotplug or a PipeWire restart. Running `subscribe.sh` again safely
refreshes the installed programs and preserves the configuration.

Names persist in `~/.config/scarlett-channel-picker/config`. Edit the four
`CHANNEL_N_NAME` values, then apply them with:

```sh
systemctl --user restart scarlett-channel-picker.service
```

Check operation and logs with:

```sh
systemctl --user status scarlett-channel-picker.service
journalctl --user -u scarlett-channel-picker.service -f
pactl list short sources | grep Scarlett-Solo-Channel
```

Disable and remove autostart with:

```sh
./unsubscribe.sh
```

Unsubscription deliberately retains the configuration, so customized names
return after a later subscription. Running `unsubscribe.sh` repeatedly is safe.
To remove the saved names as well, delete
`~/.config/scarlett-channel-picker/config` after unsubscribing.
