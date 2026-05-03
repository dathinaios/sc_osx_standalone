TARGET=$0
cd $(dirname "$TARGET")
TARGET=$(basename "$TARGET")
# Iterate down a (possible) chain of symlinks
while [ -L "$TARGET" ]
do
    TARGET=$(readlink "$TARGET")
    cd $(dirname "$TARGET")
    TARGET=$(basename "$TARGET")
done
# Compute the canonicalized name by finding the physical path
# for the directory we're in and appending the target file.
DIR=`pwd -P`
SCRIPTPATH="$DIR"

# Pick a name to namespace the per-app temp dir. When wrapped in a Platypus
# .app, $SCRIPTPATH points at MyApp.app/Contents/Resources, so we walk up two
# levels to derive the app name from the bundle.
POTENTIAL_BUNDLE=$(cd "$SCRIPTPATH/../.." 2>/dev/null && pwd -P)
if [[ "$POTENTIAL_BUNDLE" == *.app ]]; then
    APPNAME=$(basename "$POTENTIAL_BUNDLE" .app)
else
    APPNAME=$(basename "$SCRIPTPATH")
fi

export QT_PLUGIN_PATH="$SCRIPTPATH/QT_PlugIns"

# Write generated config files to a per-user, per-app temp dir. The app
# bundle/project directory is not writable when handed to a different user.
TMPWORKDIR="$TMPDIR/sc_standalone_$APPNAME"
mkdir -p "$TMPWORKDIR/SystemOverwrites"

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
		Server.program = \"'$SCRIPTPATH/Resources/scsynth' -U '$SCRIPTPATH/Resources/plugins' -D 0\";

		// Score setup
		Score.program = Server.program;

		// load user startup file
		// this.loadStartupFiles;
	}

}" > "$TMPWORKDIR/SystemOverwrites/plusOSX.sc"

# Generate the langconf file
echo "includePaths:
    - $TMPWORKDIR/SystemOverwrites
    - $SCRIPTPATH/SCClassLibrary
excludePaths:
    - $HOME/Library/Application Support/SuperCollider/Extensions
    - /Library/Application Support/SuperCollider/Extensions
    - /Applications/SuperCollider.app/Contents/Resources/SCClassLibrary
postInlineWarnings: false" > "$TMPWORKDIR/langconf.yaml"

"$SCRIPTPATH/Resources/sclang" -l "$TMPWORKDIR/langconf.yaml" "$SCRIPTPATH/init.scd"
