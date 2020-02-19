echo "includePaths:
    - SystemOverwrites
    - SCClassLibrary
excludePaths:
    - $HOME/Library/Application Support/SuperCollider/Extensions
    - /Library/Application Support/SuperCollider/Extensions
    - /Applications/SuperCollider.app/Contents/Resources/SCClassLibrary
postInlineWarnings: false" > langconf.yaml;
./Resources/sclang -llangconf.yaml init.scd
