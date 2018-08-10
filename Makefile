SWIFTOMATIC=/Users/poupou/Downloads/swift-o-matic

SWIFT_BIN = $(SWIFTOMATIC)/bin/swift/bin
SWIFT_LIB = $(SWIFTOMATIC)/bin/swift/lib/swift/macosx/
SWIFT_DLL = $(SWIFTOMATIC)/lib/SwiftInterop/

XAMARIN_MAC = /Library/Frameworks/Xamarin.Mac.framework/Versions/Current/lib/reference/mobile/Xamarin.Mac.dll

SYSTEM_CSC = csc
MOBILE_BCL_DIR = /Library/Frameworks/Xamarin.Mac.framework/Versions/Current/lib/mono/Xamarin.Mac/
MAC_mobile_CSC = $(SYSTEM_CSC) -nostdlib -noconfig -r:$(MOBILE_BCL_DIR)/mscorlib.dll -r:$(MOBILE_BCL_DIR)/System.dll -r:$(XAMARIN_MAC)

SWIFTC = $(SWIFT_BIN)/swiftc
SWIFTARGS = -sdk `xcrun --show-sdk-path` -emit-module -emit-library

TOM_SWIFTY=$(SWIFTOMATIC)/lib/swift-o-matic/tom-swifty.exe
SWIFT_GLUE = $(SWIFTOMATIC)/lib/mac/XamGlue.framework

OUTPUT_MODULE=XamVersions
TOM_SWIFTY_OUTPUT=tsout

all: libXamVersions.dylib
	@rm -rf $(TOM_SWIFTY_OUTPUT)
	@mkdir $(TOM_SWIFTY_OUTPUT)
	mono --debug $(TOM_SWIFTY) --retain-swift-wrappers --swift-bin-path $(SWIFT_BIN) -o $(TOM_SWIFTY_OUTPUT) -C . -module-name $(OUTPUT_MODULE)
	$(MAC_mobile_CSC) -unsafe -lib:$(SWIFT_DLL) -r:SwiftRuntimeLibrary.Mac.dll -lib:. tsout/*.cs -t:library -out:$(OUTPUT_MODULE).dll

libXamVersions.dylib: Versions/*.swift
	$(SWIFTC) $(SWIFTARGS) -module-name $(OUTPUT_MODULE) Versions/*.swift

test: all
	@cp $(SWIFT_DLL)SwiftRuntimeLibrary.Mac.dll .
	@cp $(SWIFT_DLL)mac/XamGlue.Framework/XamGlue .
	@cp tsout/libXamWrapping.dylib .
	csc test.cs -r:XamVersions.dll -lib:$(SWIFT_DLL) -r:SwiftRuntimeLibrary.Mac.dll

run-test: test
	LD_LIBRARY_PATH=.:$(SWIFT_LIB) DYLD_LIBRARY_PATH=. MONO_PATH=/Library/Frameworks/Xamarin.Mac.framework/Versions/Current/lib/mono/Xamarin.Mac/ /Library/Frameworks/Xamarin.Mac.framework/Versions/Current//bin/bmac-mobile-mono --arch=64 test.exe 
	
clean:
	@rm -rf tsout
	@rm -rf libXamVersions.dylib
