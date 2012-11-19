# This software is distributed under the GNU Lesser General Public License.
#  See the root of this repository for details.
#  Copyright 2012 Daniel Powell 

import sys
import os
import threading
from struct import pack, unpack
from socket import *
from nutils import *
from interact import *

class Server(threading.Thread):
	# Class representing a thread which listens for narsil peers over the network.
	# It is initialized with the number of concurrent connections it supports,
	# the maximum number of connections that should be queued, and the port
	# and host on which it should listen. The run() method starts the server.

	# (In practice, no more than one concurrent connection makes sense if Narsil is
	# being run under CPython, because of the global interpreter lock. Until this changes,
	# or unless you're using an alternative implementation of Python that supports true concurrency,
	# it will not be beneficial to set Server.max_concurrent to anything other than 1.)
		
	# When a peer connects, it spawns a ServerSession thread to carry out the transaction.
	# Server is a daemon, and terminates concurrently with the main thread.
	def __init__(self, max_concurrent, max_pending, port=NARSIL_PORT, host=ALL_INTERFACES):
		self.port = port
		self.host = host
		self.csema = threading.BoundedSemaphore(max_concurrent)
		self.psema = threading.BoundedSemaphore(max_pending)
		self.locks = LockDict() # dictionary for storing file locks
		threading.Thread.__init__(self)
		self.daemon = True
	def run(self):
		servsock = socket(AF_INET, SOCK_STREAM)
		servsock.bind((self.host, self.port))
		while True:
			servsock.listen(5)
			client,addr = servsock.accept()
			ServerSession(self.csema, self.psema, self.locks, client, addr).start()

class ServerSession(threading.Thread):
	# A thread spawned by a Server to carry out a transaction with a remote peer.
	# It is initialized with references to the server's semaphores for current and pending
	# connections, the server's dictionary of file locks, the peer address,
	# and the length of each fragment to be transmitted over the network.
		
	# ServerSession is a daemon, and terminates concurrently with the main thread.
	def __init__(self, concurrent_semaphore, pending_semaphore, locks, client, peer_addr, fragmentsize=FRAGMENT_SIZE):
		self.csema = concurrent_semaphore
		self.psema = pending_semaphore
		self.locks = locks
		self.client = client
		self.peer_addr = paddr
		self.fragmentsize = fragmentsize
		threading.Thread.__init__(self)
		self.daemon = True
	def run(self):
		if self.psema.acquire(False): # try to get a "pending" spot but don't block on it
			self.csema.acquire(True)  # block until a connection slot is available
			self.psema.release()      # we're not pending anymore
			self.client.send("connected")
			request = self.client.recv(4)
			if request == ActionPost().request:
				ActionPost().response(self.client, self.locks)
			elif request == ActionRecv().request:
				ActionRecv().response(self.client)
			elif request == ActionCancel().request:
				ActionCancel().response(self.client, self.locks)
			elif request == ActionCommit().request:
				ActionCommit().response(self.client, self.locks)
			self.client.close()
			self.csema.release()
		else: # our non-blocking request on the pending semaphore failed, so the host is full
			self.client.send("host full") # raises a TransactError at the client
			self.client.close()
