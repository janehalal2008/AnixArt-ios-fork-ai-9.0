.PHONY: all project build archive clean lint

all: project

project:
	xcodegen generate

build: project
	xcodebuild build \
		-project Anixart.xcodeproj \
		-scheme Anixart \
		-configuration Debug \
		-sdk iphonesimulator \
		-destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
		CODE_SIGNING_ALLOWED=NO \
		-derivedDataPath build/DerivedData \
		| xcbeautify

archive: project
	xcodebuild archive \
		-project Anixart.xcodeproj \
		-scheme Anixart \
		-configuration Release \
		-archivePath build/Anixart.xcarchive \
		CODE_SIGNING_ALLOWED=NO \
		-derivedDataPath build/DerivedData

lint:
	swiftlint --strict 2>&1 || true

clean:
	rm -rf build/
	rm -rf Anixart.xcodeproj/
	rm -rf ~/Library/Caches/com.apple.dt.Xcode/SourcePackages

reset: clean
	rm -rf DerivedData/
	rm -rf .build/
