# luteprograms

## by techhog

TARGET LUTE VERSION: https://github.com/luau-lang/lute/releases/tag/0.1.0-nightly.20250722

### SETUP:
The current files and folders you see (like this README) must be placed in a subdirectory inside the lute source code (or a folder with a directory structure matching what's needed in the .luaurc aliases).

#### EXAMPLE:
```sh
git clone https://github.com/luau-lang/lute
cd lute
git checkout c046d54
git clone https://github.com/TechHog8984/luteprograms
```

#### LUTE EXECUTABLE
To obtain a lute executable, either download the corresponding asset from the above release, or build manually. Unfortunately, the easiest way to build lute is with luthier (a tool now exclusively written in lute), so you will likely end up needing to download a release anyway (if you're using an unsupported platform, read luthier and manually execute commands, I guess!).

```sh
# inside lute
mkdir bootstrap
cd bootstrap
# example for 64bit linux; adjust for your platform
wget https://github.com/luau-lang/lute/releases/download/0.1.0-nightly.20250722/lute-linux-x86_64.zip
unizip ./lute*.zip
chmod +x ./lute
cd ..
# stop here unless you want to build lute
./bootstrap/lute tools/luthier.luau fetch lute # download dependencies
./bootstrap/lute tools/luthier.luau build lute --config=release # build
```

### USAGE:
The helper script (in bash) allows you to easily run a desired luteprogram. Note that it finds the target lute directory based on where the script itself is located on the file system.

#### EXAMPLE:
```sh
cd luteprograms # if you're not here already
./helper.sh program1 - args here # run program1 with passed arguments
# OR
./helper.sh programdemo build # build programdemo to ./build/programdemo
```

If you don't have bash, you can just use lute like so:
```sh
# optionally use ../build/release/lute/cli/lute
../bootstrap/lute program1/main.luau args here # run program1 with passed arguments
# OR
../bootstrap/lute compile programdemo/main.luau build/programdemo # build programdemo to ./build/programdemo
```

### Building is WIP!
If you build and run a lute program and get an error saying `require is not supported in this context` that is because built scripts don't automatically bundle require targets. Support for additional requires is coming soon.
