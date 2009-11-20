DEB_BUILD_OPTIONS := --disable-runtime-cpudetection --disable-vidix --disable-tga --disable-pnm --disable-ossaudio --disable-gui --disable-live --disable-directfb

all: build

update: update-mplayer update-ffmpeg update-dvdnav

copy: copy-ffmpeg copy-dvdnav

build: build-stamp
build-stamp: update copy
	cd mplayer && fakeroot debian/rules binary
	touch build-stamp

update-mplayer: update-mplayer-stamp
update-mplayer-stamp:
	cd mplayer && stg pop -a && git svn fetch -r HEAD && git svn rebase -l && stg push -a && git gc
	touch update-mplayer-stamp

update-ffmpeg: update-ffmpeg-stamp
update-ffmpeg-stamp:
	cd ffmpeg-mt && git pull && git gc
	touch update-ffmpeg-stamp

update-dvdnav: update-dvdnav-stamp
update-dvdnav-stamp:
	cd dvdnav && git svn fetch -r HEAD && git svn rebase -l && git gc
	touch update-dvdnav-stamp

copy-ffmpeg: copy-ffmpeg-stamp
copy-ffmpeg-stamp: update-ffmpeg-stamp
	cp -r  ffmpeg-mt/{libavcodec,libavformat,libavutil,libpostproc} mplayer
	touch copy-ffmpeg-stamp

copy-dvdnav: copy-dvdnav-stamp
copy-dvdnav-stamp: update-dvdnav-stamp
	cp -r  dvdnav/libdvdread/src/ mplayer/libdvdread4
	cp -r  dvdnav/libdvdnav/src/ mplayer/libdvdnav
	touch copy-dvdnav-stamp

source:
	git svn clone -r HEAD svn://svn.mplayerhq.hu/mplayer/trunk mplayer
	git svn clone -r HEAD svn://svn.mplayerhq.hu/dvdnav/trunk dvdnav
	git clone git://gitorious.org/~astrange/ffmpeg/ffmpeg-mt.git ffmpeg-mt

depend:
	sudo aptitude install libasound2-dev libxv-dev libfontconfig1-dev yasm libmad0-dev
	#libpng12-dev libungif4-dev liblame-dev libfaac-dev

debug:
	cd mplayer && ./configure $(DEB_BUILD_OPTIONS) --enable-debug --disable-liba52-internal && make

clean:
	cd mplayer && fakeroot debian/rules clean
	rm -rf mplayer/{libavcodec,libavformat,libavutil,libpostproc}
	rm -rf mplayer/{libdvdread4,libdvdnav}
	rm -f update-mplayer-stamp update-ffmpeg-stamp update-dvdnav-stamp
	rm -f copy-ffmpeg-stamp copy-dvdnav-stamp

.PHONY: all clean
