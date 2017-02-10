ARCH ?= lin
FLAGS = -g -Wall -O3 -msse -mfpmath=sse -ffast-math \
	-I./ext -I./include
CXXFLAGS = -fno-exceptions

SOURCES = $(wildcard src/*.cpp src/*/*.cpp) \
	ext/nanovg/src/nanovg.c


ifeq ($(ARCH), lin)
SOURCES += ext/noc/noc_file_dialog.c
CFLAGS += -DNOC_FILE_DIALOG_GTK $(shell pkg-config --cflags gtk+-2.0)
LDFLAGS += -rdynamic \
	-lpthread -lGL -lGLEW -lglfw -ldl -ljansson -lportaudio -lportmidi -lsamplerate \
	$(shell pkg-config --libs gtk+-2.0)
TARGET = Rack
endif

ifeq ($(ARCH), mac)
SOURCES += ext/noc/noc_file_dialog.m
CFLAGS += -DNOC_FILE_DIALOG_OSX
CXXFLAGS += -DAPPLE -stdlib=libc++ -I$(HOME)/local/include
LDFLAGS += -stdlib=libc++ -L$(HOME)/local/lib -lpthread -lglew -lglfw3 -framework Cocoa -framework OpenGL -framework IOKit -framework CoreVideo -ldl -ljansson -lportaudio -lportmidi -lsamplerate
TARGET = Rack
endif

ifeq ($(ARCH), win)
SOURCES += ext/noc/noc_file_dialog.c
CFLAGS += -DNOC_FILE_DIALOG_WIN32
CXXFLAGS += -DGLEW_STATIC \
	-I$(HOME)/pkg/portaudio-r1891-build/include
LDFLAGS += \
	-Wl,-Bstatic,--whole-archive \
	-lglfw3 -lgdi32 -lglew32 -ljansson -lsamplerate \
	-Wl,-Bdynamic,--no-whole-archive \
	-lpthread -lopengl32 -lcomdlg32 -lole32 \
	-lportmidi \
	-L$(HOME)/pkg/portaudio-r1891-build/lib/x64/ReleaseMinDependency -lportaudio_x64 \
	-Wl,--export-all-symbols,--out-implib,libRack.a -mwindows
TARGET = Rack.exe
# OBJECTS = Rack.res

%.res: %.rc
	windres $^ -O coff -o $@
endif


all: $(TARGET)

clean:
	rm -rf $(TARGET) build

include Makefile.inc