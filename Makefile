name=stormclouds_over_spudville
godot=godot

all: windows linux zip

clean:
	rm -rf build

windows:
	mkdir -p build/linux
	$(godot) -v --export "Linux/X11" ../build/linux/$(name).x86_64 project/project.godot

linux:
	mkdir -p build/windows
	$(godot) -v --export "Windows Desktop" ../build/windows/$(name).exe project/project.godot

zip: windows linux
	mkdir -p build/zip
	mkdir -p build/zip/src
	rsync -av --progress project build/zip/src --exclude .import
	echo "This project was built using [Godot Engine](https://godotengine.org)." > build/zip/src/README.md
	mkdir -p build/zip/release/linux
	mkdir -p build/zip/release/windows
	cp -r build/windows/* build/zip/release/windows
	cp -r build/linux/* build/zip/release/linux
	cp LICENSE build/zip
	mkdir -p build/zip/press
	cp raw_assets/press/*png build/zip/press
	cd build/zip;	zip $(name).zip -r .
