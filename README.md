# SuperCollider OSX Standalone

Modified from [the linux version](https://github.com/miguel-negrao/scStandalone).

[SuperCollider](http://supercollider.sourceforge.net/) version `3.14.1`

## Setup

1. Download both the source code and `Frameworks.zip` from the [latest release](https://github.com/dathinaios/sc_osx_standalone/releases/latest).
2. Navigate to the downloaded folder from the terminal with `cd path/to/sc_osx_standalone`.
3. Move `Frameworks.zip` into this directory, unzip it to extract the `Frameworks` folder, then delete the zip file.
4. Run `sh run.sh` to test the standalone. You should hear some white noise. This is the default sound defined in `init.scd`.
5. Replace the code inside the `waitForBoot` block in `init.scd` with your own:

          s.waitForBoot{
            // your own code here
          };

6. Add any extensions you need to the `SCClassLibrary` folder.

## Building a distributable app (for composers)

Install [Platypus](https://sveinbjorn.org/platypus) (drag it to `/Applications/`). Then open Platypus, go to **Settings**, and click **Install** next to the command-line tool option. Once it shows "Command line tool is installed", run from the terminal:

```
./build_app.sh SC_Custom
```

This produces `build/SC_Custom.app`, signed and ready to distribute. You can optionally specify a custom init script and output directory:

```
./build_app.sh SC_Custom path/to/init.scd ./output_dir
```

To pass extra flags to Platypus (custom icon, hide post window, etc.) use `--`:

```
./build_app.sh SC_Custom -- --interface-type None --app-icon my.icns
```

See `platypus_clt --help` for the full list of available flags.

## Running the app (for performers)

1. Download the `.app`.
2. Right-click the app and choose **Open**. Click **Open** in the Gatekeeper dialog that appears.
3. Allow microphone access if prompted.
4. From then on the app launches normally with no extra steps.

No admin password or terminal commands required.

## FAQ

Q: Where do I put soundfiles and how do I access them?

A: Put your files in the `Resources` directory. You can then access them using `Platform.resourceDir ++ "/path/to/your/file.wav"`.
