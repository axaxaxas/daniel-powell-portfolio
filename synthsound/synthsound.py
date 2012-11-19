# This software is distributed under the GNU Lesser General Public License.
#  See the root of this repository for details.
#  Copyright 2011, 2012 Daniel Powell 

from math import sin
import alsaaudio
import audiopack

PI     = 3.14159265359
TWO_PI = 6.28318530718

def add_lists(LL):
	# takes a list of lists and adds the lists together element-wise
	if len(LL) == 2:
		return [LL[0][i] + LL[1][i] for i in xrange(len(LL[0]))]
	else:
		return listadd([LL[0], listadd(LL[1:])])

def interleave(L1, L2):
	# interleaves two lists
   r = []
   for k in xrange(len(L1)):
      r.append([L1[k], L2[k]])
   return r

def initsynth(channels=2, bitrate=44100, format=alsaaudio.PCM_FORMAT_S16_LE, periodsize=128):
	# retrieves a new ALSA context for output
	r = alsaaudio.PCM()
	r.setchannels(channels)
	r.setrate(bitrate)
	r.setformat(format)
	r.setperiodsize(periodsize)
	return r

def wavefunction(frequency, amplitude, shape, samplerate=44100):
	# generate a new function corresponding to a waveform of a given
	# frequency, amplitude, and shape
	#
	# frequency is specified in hertz.
	#
	# amplitude is a unitless linear scaling factor applied
	# to the waveform. for well-behaved wave shapes,
	# the maximum loudness that can be achieved without
	# clipping is when amplitude is equal to 2^n, where n
	# is the sampling bit depth. that's probably
	# louder than you really want.
	#
	# shape is a function corresponding to a wave shape
	#
	sample_frequency = (TWO_PI*frequency)/samplerate
	return lambda L: [amplitude*p for p in map(shape, [sample_frequency*o for o in L])]

def zeroframes(duration=128):
	# returns a list of completely silent audio frames
	# of a given duration.
	pack = audiopack.monopack
	return ''.join([pack(k)
			for k in map(lambda o: 0, xrange(duration))])

def monoframes(wave_function, start=0, duration=128):
	# returns a list of audio frames, given a 
	# wave function, a starting point, and a duration. 
	#
	# start is the sample count at which to begin
	# generating the list.
	#
	# duration is the length of the list to be generated.
	pack = audiopack.monopack
	return ''.join([pack(k)
		for k in map(int, wave_function(xrange(start, start+duration)))])

def polyframes(wave_functions, start=0, duration=128):
	# returns a list of audio frames, given a list of
	# waveforms, a starting point, and a duration.
	#
	# polyframes additively combines each wave function
	# in the list and generates a new list of monaural
	# frames.
	pack = audiopack.stereopack
	pack = audiopack.monopack
	return ''.join([pack(k)
		for k in listadd([map(int, function(xrange(start, start+duration))) for function in wave_functions])])

def stereoframes(lfun, rfun, start=0, duration=128):
	# returns a list of stereo audio frames, given 
	# two waveforms, a starting point, and a
	# duration.
	#
	# lfun and rfun are wave functions for the left
	# and right audio channels, respectively.
	pack = audiopack.stereopack
	return ''.join([pack(k[0], k[1])
	  for k in interleave(map(int, rfun(xrange(start, start+duration))), map(int, lfun(xrange(start, start+duration))))])
