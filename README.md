# SuperCollider OSX Standalone

Modified from [the linux version](https://github.com/miguel-negrao/scStandalone).

[SuperCollider](http://supercollider.sourceforge.net/) version `3.12.2`

## Usage

1. Navigate to the downloaded folder from the terminal with `cd location_path_of_sc-osx-standalone-master`.
2. Unzip the `Frameworks` folder and delete the `zip` file.
3. Run the standalone with `sh run.sh` script. You should hear some white noise. This is the default sound as defined in `init.scd`.
4. To modify `init.scd` replace the code inside the curly brackets after `waitForBoot` with your own code:

          s.waitForBoot{
            // your own code here
          };

5. Include your extensions in the `SCClassLibrary` folder.
6. [Platypus ](http://sveinbjorn.org/platypus) can be used to convert the script based structure into a "native" OSX application.
  - Open Platypus
  - Fill in the App name
  - Click the `Select Script` button and choose the `run.sh` file.
  - Drag all the files from the `sc_osx_standalone-master` to the `Bundled Files` field.
  - Optional: to hide the post window change the interface option from `Text Window` to `None`.
  - Click `Create` and choose the location for your app. 

## FAQ

Q: Where do I put soundfiles and how do i access them?

A: Put your files in the `Resources` directory. You can then access them using `Platform.resourceDir ++ "/path/to/your/file.wav");`
