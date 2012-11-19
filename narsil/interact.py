# This software is distributed under the GNU Lesser General Public License.
#  See the root of this repository for details.
#  Copyright 2012 Daniel Powell 

from nutils import *
import os

class Action:
	# Abstract class representing an action to be carried out over the network.
	# Specific categories of action can be defined by inheriting from this class. 
	   
	# The Action class represents both the client and server-side ends of the protocol.
	# When inheriting from Action, methods containing appropriate logic should be
	# assigned to the Action.client_proc and Action.server_side pric. 
	# A unique string by which the action can be identified in a network 
	# request should be assigned to the Action.request field.

	def __init__(self, *args):
		self.request = None
		self.client_proc = None
		self.server_proc = None
		self.args = args
	def act(self, *remaining_args):
		self.client_proc(*(self.args + remaining_args))
	def response(self, *remaining_args):
		self.server_proc(*(self.args + remaining_args))
		
class ActionPost(Action):
	# Action for posting a file to the network.
	def __init__(self, *args):
		self.request = "post"
		self.client_proc = self.post
		self.server_proc = self.accept
		self.args = args
	def post(self, filename, chunknumber, chunk, sock, fragmentsize=FRAGMENT_SIZE):
		h = post_header(filename, chunknumber, chunk)
		sock.send(h)
		for f in fragments(chunk, fragmentsize):
			sock.send(f)
		sock.close()
	def accept(self, sock, locks, fragmentsize=FRAGMENT_SIZE):
		sock.send("ok")
		header = parse_post_header(sock.recv(fragmentsize))
		filename = header['filename'] + '.t'
		locks.acquire(filename)
		with open(filename, 'wb') as localfile:
			remaining_size = header['size']
			m = header['data']
			localfile.write(m)
			remaining_size -= len(m)
			while remaining_size > 0:
				m = sock.recv(fragmentsize)
				localfile.write(m)
				remaining_size -= len(m)
		locks.release(filename)
	
class ActionRecv(Action):
	# Action for downloading a file from the network.
	def __init__(self, *args):
		self.request = "recv"
		self.client_proc = self.recv
		self.server_proc = self.provide
		self.args = args
	def recv(self, filename, chunknumber, sock, fragmentsize=FRAGMENT_SIZE):
		with open(filename + ".rchunk" + str(chunknumber), 'wb') as localfile:
			sock.send(filename + ".chunk" + str(chunknumber))
			header = parse_supply_header(sock.recv(fragmentsize))
			remaining_size = header['size']
			localfile.write(header['data'])
			remaining_size -= len(header['data'])
			while remaining_size > 0:
				m = sock.recv(fragmentsize)
				localfile.write(m)
				remaining_size -= len(m)
	def provide(self, sock, fragmentsize=FRAGMENT_SIZE):
		sock.send("ok")
		filename = sock.recv(FILENAME_LENGTH)
		sock.send(supply_header(filename))
		with open(filename, 'rb') as localfile:
			m = localfile.read(fragmentsize)
			while m != '':
				sock.send(m)
				m = localfile.read(fragmentsize)

class ActionCommit(Action):
	# Action confirming to a peer that the previous transaction completed
	# successfully, and that the changes to the backup should be committed.
	def __init__(self, *args):
		self.request = "comt"
		self.client_proc = self.commit
		self.server_proc = self.do_commit
		self.args = args
	def commit(self, filename, sock):
		sock.send(filename)
	def do_commit(self, sock, locks):
		sock.send("ok")
		filename = sock.recv(FILENAME_LENGTH)
		files = os.listdir(os.getcwd())
		for q in filter(lambda f: f.startswith(filename + ".chunk") and f.endswith(".t"), files):
			locks.acquire(q)
			locks.acquire(q[:-2])
			if os.path.lexists(q[:-2]):
				os.remove(q[:-2])
			os.rename(q, q[:-2])
			locks.release(q)
			locks.release(q[:-2])

class ActionCancel(Action):
	# Action indicating to a peer that the previous transaction was aborted under
	# exceptional conditions, and that the changes to the backup should be discarded.
	def __init__(self, *args):
		self.request = "canc"
		self.client_proc = self.cancel
		self.server_proc = self.do_cancel
		self.args = args
	def cancel(self, filename, sock):
		sock.send(filename)
	def do_cancel(self, sock):
		sock.send("ok")
		filename = self.peer.recv(FILENAME_LENGTH)
		files = os.listdir(os.getcwd())
		for q in filter(lambda f: f.startswith(filename + ".chunk") and f.endswith(".t"), files):
			locks.acquire(q)
			os.remove(q)
			locks.release(q)

class Transaction(threading.Thread):
	# Represents a thread which manages a single client-server interaction.
    # It is initialized with a local Client object, the address of a remote peer, 
	# and an action to perform. The run() method carries out the 
	# transaction between the client and the peer.

	# Raises TransactError.
	def __init__(self, client, peer, action):
		self.semaphore = client.sema # we don't need to hang onto the client object itself
		self.peer = peer
		self.action = action
		threading.Thread.__init__(self)
	def transact(self, port=NARSIL_PORT):
		sock = socket(AF_INET, SOCK_STREAM)
		try:
			sock.connect((self.peer, port))
			if sock.recv(16) == "connected":
				sock.send(self.action.request)
				answer = sock.recv(2)
				if answer == "ok":
						self.action.act(sock)
				elif answer == "no": # the default Narsil server will never actually do this
					raise TransactError("Refusal from remote peer")
				else:
					raise TransactError("Malformed response from remote peer")
			elif sock.recv(16) == "host full":
				raise TransactError("Remote peer is full")
			else:
				raise TransactError("Malformed response from remote peer")
		finally:
			sock.close()
	def run(self):
		# stake our claim, do our thing, go away
		self.semaphore.acquire()
		self.transact()
		self.semaphore.release()
