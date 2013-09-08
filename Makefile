MXMLC = "/Applications/Adobe Flash Builder 4.6/sdks/4.6.0/bin/mxmlc"

build:
	$(MXMLC) --library-path=./libs -strict=false -debug=false -static-link-runtime-shared-libraries=true -optimize=true -o recorder.swf -file-specs ./flash/FlashRecorder.as

clean:
	rm recorder.swf