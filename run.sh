# Absolute path to this script
SCRIPT=$(readlink -f "$0")
# Absolute path this script is in
SCRIPTPATH=$(dirname "$SCRIPT")
# Link the QT PlugIns
export QT_PLUGIN_PATH="./QT_PlugIns"

# Generate scsynth settings
# Relative paths are not allowed when running scsynth
echo "
+ OSXPlatform {

	startupFiles {
		^[];
	}

	startup {

		helpDir = this.systemAppSupportDir++\"/Help\";

		// Server setup
		Server.program = \"$SCRIPTPATH/Resources/scsynth -U $SCRIPTPATH/Resources/plugins -D 0\";

		// Score setup
		Score.program = Server.program;

		// load user startup file
		// this.loadStartupFiles;
	}

}" > SystemOverwrites/plusOSX.sc;

# Generate the langconf file
echo "includePaths:
    - SystemOverwrites
    - SCClassLibrary
    - plugins
excludePaths:
    - $HOME/Library/Application Support/SuperCollider/Extensions
    - /Library/Application Support/SuperCollider/Extensions
    - /Applications/SuperCollider.app/Contents/Resources/SCClassLibrary
postInlineWarnings: false" > langconf.yaml;
./Resources/sclang -l langconf.yaml init.scd
