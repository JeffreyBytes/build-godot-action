#!/bin/sh
set -e

# Move godot templates already installed from the docker image to home
mkdir -v -p ~/.local/share/godot/export_templates
# Check if ~ and /root are the same (CI runner is running as root)
if [ "$(realpath ~)" = "/root" ]; then
    echo "Home directory and /root are the same. Skipping copy."
else
    cp -a /root/.local/share/godot/export_templates/. ~/.local/share/godot/export_templates/


if [ "$3" != "" ]
then
    SubDirectoryLocation="$3/"
fi

mode="export-release"
if [ "$6" = "true" ]
then
    echo "Exporting in debug mode!"
    mode="export-debug"
fi

# Export for project
echo "Building $1 for $2"
mkdir -p $GITHUB_WORKSPACE/build/${SubDirectoryLocation:-""}
cd "$GITHUB_WORKSPACE/$5"
godot --headless --${mode} "$2" $GITHUB_WORKSPACE/build/${SubDirectoryLocation:-""}$1
echo "Build Done"

echo ::set-output name=build::build/${SubDirectoryLocation:-""}


if [ "$4" = "true" ]
then
    echo "Packing Build"
    mkdir -p $GITHUB_WORKSPACE/package
    cd $GITHUB_WORKSPACE/build
    zip $GITHUB_WORKSPACE/package/artifact.zip ${SubDirectoryLocation:-"."} -r
    echo ::set-output name=artifact::package/artifact.zip
    echo "Done"
fi
