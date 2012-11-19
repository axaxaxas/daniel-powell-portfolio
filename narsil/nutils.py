# This software is distributed under the GNU Lesser General Public License.
#  See the root of this repository for details.
#  Copyright 2012 Daniel Powell 

import threading
import math
import os
from struct import pack, unpack

### some default global parameters ###
FRAGMENT_SIZE = 4096
NARSIL_PORT = 28657 # it's the eighth Fibonacci prime
ALL_INTERFACES = '0.0.0.0' # for ipv6, change to '::'
FILENAME_LENGTH = 256

class LockDict:
	# Dictionary mapping strings to lock objects.
	
	# Used to manage locks for an arbitrary number of files
	# while creating lock objects only as necessary.

	# The acquire() and release() methods acquire and release locks.
	# The release_all() method releases all locks at once.

	# Lock objects can be safely removed from the 
	# dictionary instead of being released, allowing the lock
	# to be GC'd if you aren't hanging on to a reference 
	# elsewhere. The free() and free_all() methods supply 
	# this functionality.

	def __init__(self):
		self.dict = {}
	def acquire(self, name, blocking=True):
		if filename not in self.dict:
			self.dict[name] = threading.Lock()
		return self.dict[name].acquire(blocking)
	def release(self, name):
		self.dict[name].release()
	def release_all(self):
		for f in self.dict:
			self.release(f)
	def free(self, name):
		# in practice, it's probably best not to use free() or free_all()
		# unless you're really sure you won't be needing the lock again
		# and memory footprint is actually an issue. The default Narsil
		# server doesn't free locks at all.
		del self.dict[name]
	def free_all(self):
		for f in self.dict:
			del self.dict[f]

class TransactError(Exception):
	# Exception for failed narsil network transactions.
	def __init__(self, description):
		self.description = description
	def __str__(self): # gracefully stringify ourself
		return repr(self.description)

def choose(n, k):
	# Returns n choose k. 
	if (k > n): return 0
	return math.factorial(n)/(math.factorial(k)*math.factorial(n-k))

def min_src(hosts, n, k):
	# Finds the minimum number of sources needed to reconstruct a file, given
	# N and K parameters.
	return choose(n-1,k) - choose(n,k) + hosts + 1

def find_parameters(hosts):
	# Returns a dictionary mapping n,k pairs to tuples of
	# an m-value and a k/n ratio for a given number of hosts.
	results = {}
	for n in xrange(1,hosts+1):
		for k in xrange(2,n):
			if choose(n,k) > hosts: break
			if min_src(hosts, n, k) > hosts: break
			if min_src(hosts, n, k) < 0: break
			results[(n,k)] = (min_src(hosts,n,k), float(k)/float(n))
	return results

def increment(L, n):
	# Given a combination L (as a list) of integers on the interval [0, n),
	# returns the next combination in left-handed ascending sequence 
	# if possible, or else returns False.
	k = len(L)
	car = L[0]
	cdr = L[1:]
	if L == [j for j in xrange(n-k,n)]:
		return False
	if k == 1:
		return [car+1]
	if cdr == [j for j in xrange(n-(k-1),n)]:
		return [car+1+j for j in xrange(0,k)]
	return [car] + increment(cdr,n)

def chunks(filename, numchunks):
	# A generator that splits a file into a specified number of substrings in a
	# lazy fashion.

	# This is preferable to the eager method of reading the file into a list before splitting it
	# because it does not require the entire file to be held in memory at once.
	size = os.path.getsize(filename)
	interval = (size/numchunks) + 1 	# Adding 1 means the last chunk will be shorter, but ensures that
								     	# the file will fit in numchunks total chunks with no spillover.
	f = open(filename, 'rb')
	chunk = f.read(interval)
	for i in range(numchunks):
		yield chunk
		chunk = f.read(interval)

def shards(n, k):
	# Given parameters n and k, returns an ordered list of all combinations.
	shardlist = []
	shard = [j for j in xrange(0,k)]
	while shard:
		shardlist = shardlist + [shard]
		shard = increment(shard, n) # will become False when it can no longer be incremented
	return shardlist

def fragments(string, fragmentsize):
	# Generator that yields successive fragments of a string.
    # Unlike chunks(str,int), the entire string is held in memory.
	i = 0
	while string[i:i+fragmentsize] != '':
		yield string[i:i+fragmentsize]
		i += fragmentsize

def fragment_count(string, fragmentsize):
	# Calculates the number of fragments into which a string will be split.
	if len(string)*(fragmentsize//len(string)) == fragmentsize: # if fragmentsize evenly divides len(string)
		return fragmentsize//len(string)
	else:
		return fragmentsize//len(string) + 1

def post_header(filename, chunknumber, chunk):
	# Generates a header for a "post" transaction.
	remotename = filename + ".chunk" + str(chunknumber)
	if len(remotename) > 255:
		raise TransactError("Remote filename would be too long!")
	else:
		return (remotename + "**" + pack('!Q', len(chunk)) + "**")

def supply_header(filename):
	# Generates a header for the reply to a "recv" request.
	return pack('!Q', os.path.getsize(filename)) + "**"

def parse_post_header(header):
	# Parses a file post header and returns the results in a dictionary.

	# The keys are 'filename', 'size', and 'data'.
	# 'data' is for payload bytes that got scooped up along with the header; parse_post_header can
	# safely accept any substring of the transfer data beginning at byte 0 provided that
	# it is at least as long as the header.
	result = {}
	result['filename'] = header.partition("**")[0]
	result['size'] = unpack('!Q', header.partition("**")[2].partition("**")[0])[0]
	result['data'] = header.partition("**")[2].partition("**")[2]
	return result

def parse_supply_header(header):
	# Parses a file supply header and returns the results in a dictionary.

	# The two keys are 'size' and 'data'.
	# 'data' is for payload bytes that got scooped up along with the header; parse_supply_header can
	# safely accept any substring of the transfer data beginning at byte 0 provided that
	# it is at least as long as the header.
	result = {}
	result['size'] = unpack('!Q', header.partition("**")[0])[0]
	result['data'] = header.partition("**")[2]
	return result
	
