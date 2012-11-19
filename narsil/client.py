# This software is distributed under the GNU Lesser General Public License.
#  See the root of this repository for details.
#  Copyright 2012 Daniel Powell 

import threading
from nutils import *
from struct import pack, unpack
from socket import *
from interact import *

class Client(threading.Thread):
	# Represents a local client thread. It is initialized with the maximum number
	# of connections it can support.
	def __init__(self, max_connections):
		self.sema = threading.BoundedSemaphore(max_connections)
		self.locks = LockDict()
		threading.Thread.__init__(self)
	def __assemble_file(self, filename, n, k, fragment_size=FRAGMENT_SIZE):
		#  Private method that assembles a file from chunks downloaded from the network.
		#  It is called only from Client.recover().
		numchunks = choose(n, k)
		with open(filename, 'wb') as wholefile:
			for i in xrange(numchunks):
				with open(filename + ".rchunk" + str(i), 'rb') as chunkfile:
					m = chunkfile.read(fragment_size)
					while m != '':
						wholefile.write(m)
						m = chunkfile.read(fragment_size)
				os.remove(filename + ".rchunk" + str(i))
	def backup(self, addresslist, filename, n, k):
		#  Backs up a file to the network, given a list of peers,
		#  the name of the file to be stored, and the network's N and K
		#  parameters.
		numchunks = choose(n, k)
		try:
			for chunk, shard, index in zip(chunks(filename, numchunks), shards(n,k), range(numchunks)):
				for s in shard:
					Transaction(self.sema, addresslist[s], ActionPost(filename, index, chunk)).start()
		except Exception as e: # it's usually bad to catch all exceptions.
                               # we'll let it crash (as we should), but 
			                   # first we have to revert any changes
                               # made by the failed action
			for a in addresslist:
				Transaction(self,sema, a, ActionCancel(filename)).start() # revert
			raise e            # and we make sure to pass the exception up the stack
		else:
			for a in addresslist:
				Transaction(self.sema, a, ActionCommit(filename)).start()
	def recover(self, addresslist, filename, n, k):
		# Recovers a file from the network, given a list of peers,
		# the name of the file to be stored, and the network's N and K
		# parameters.
		numchunks = choose(n, k)
		tasks = []
		for i in range(numchunks):
			for s in shards(n,k)[i]:
				if self.locks.acquire(filename + ".rchunk" + str(i), False):
					thread = Transaction(self.sema, addresslist[s], ActionRecv(filename, i))
					tasks.append(thread)
					thread.start()
		for t in tasks:
			t.join()
		self.locks.release_all()
		self.__assemble_file(filename, n, k)
	def run(self):
		# The run method does nothing by default,
		# but may be overridden in classes inheriting from 
		# Client to provide a UI.
		pass
