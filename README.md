# luteprograms

## by techhog

TARGET LUTE VERSION: https://github.com/luau-lang/lute/releases/tag/0.1.0-nightly.20250722

### SETUP:
The files and folders inside this repo (like this README) must be placed in a subdirectory inside the lute source code (or a folder with a directory structure matching what's needed in the .luaurc aliases and helper.sh).

#### EXAMPLE:
```sh
git clone https://github.com/luau-lang/lute
cd lute
git checkout c046d54
git clone https://github.com/TechHog8984/luteprograms
```

#### LUTE EXECUTABLE
To obtain a lute executable, either download the corresponding asset from the above release or build manually. Unfortunately, the easiest way to build lute is with luthier (a tool now exclusively written in lute), so you will likely end up needing to download a release anyway (if you're using an unsupported platform, read luthier and manually execute commands, I guess!).

```sh
# inside lute
mkdir bootstrap
cd bootstrap
# example for 64bit linux; adjust for your platform
wget https://github.com/luau-lang/lute/releases/download/0.1.0-nightly.20250722/lute-linux-x86_64.zip
unzip ./lute*.zip
chmod +x ./lute
cd ..
# stop here unless you want to build lute
./bootstrap/lute tools/luthier.luau fetch lute # download dependencies
./bootstrap/lute tools/luthier.luau build lute --config=release # build
```

### DEPENDENCIES:
The only runtime dependency of luteprograms (besides lute) is [darklua](https://github.com/seaofvoices/darklua).

I'd recommend installing through `cargo install darklua`.

If you don't have cargo installed, see https://rust-lang.org/learn/get-started/

### USAGE:
The helper script (in bash) allows you to easily build a desired luteprogram. Note that it finds the target lute directory based on where the script itself is located on the file system.

#### EXAMPLE:
```sh
cd luteprograms # if you're not here already
./helper.sh program1 bundle # bundle program1 with darklua to ./build/program1.luau
# OR
./helper.sh programdemo build # bundle programdemo like above, but then build the bundle to a native application at ./build/programdemo
```

If you don't have bash, you can just use darklua and lute like so:
```sh
darklua process -c darkluabundle.json program1/main.luau build/program1.luau # bundle program1 with darklua to ./build/program1.luau
# optionally use ../build/release/lute/cli/lute
../bootstrap/lute compile build/programdemo.luau build/programdemo.exe # build programdemo to ./build/programdemo.exe
```

When developing a project, it is often better to just run the code pre-bundle for better error handling and less overhead, which you can do like so:
```sh
./helper.sh program1 run [arguments]
```
