require 'socket'

Object.send(:remove_const, :UNIXSocket)

module UNIXSocketMethods
  attr_accessor :af,:path 

  def send_io(io)
		raise NotImplementedError
  end

  def recv_io
		raise NotImplementedError
  end

	#This method applies a condition that seems to return an empty string whenever the type of the object is a UNIXSocket and the path of the .sock
	#file whenever the object is a UNIXServer. The condition is in a method call unixpath not unix_path and it involves a condition testing pointers
	def path
		if self.instance_of?(UNIXServer)
			@path
		else
			""
		end
	end

  #This method uses the path method so it does almost the same thing with adding the string containing the protocol family of the socket.
	def addr
		[@af, path]
	end

  #I tried this method with UNIXServer raises the exception I am raising here.
	def peeraddr
		if self.instance_of?(UNIXServer) 
			raise Errno::ENOTCONN, "Transport endpoint is not connected - getpeername(2)", caller
		else
			[@af,@path]
		end
	end 

	def recvfrom(*args)
		recved_array = self.recvfrom_nonblock(*args)
		recved_array[1]=  ["AF_UNIX",@path]
		recved_array
	end  
	
end

class UNIXSocket < Socket

	include UNIXSocketMethods

	def initialize(path)
		super(AF_UNIX, SOCK_STREAM,0)
		@af = "AF_UNIX"
		@path = path
		self.connect(Socket.pack_sockaddr_un(path))
	end

	#This method is a singleton method that returns a pair of connected, anonymous sockets of the given domain, type, and protocol.
	#It is not in the documentation but it is in the C file
	#The following method is the same as this method
	def self.socketpair(*args)
		self.pair(*args)
	end

	def self.pair(*args)
		if args.length == 0
			first, second = Socket.pair(AF_UNIX, SOCK_STREAM,	0)
		elsif args.length == 1
			first, second = Socket.pair(AF_UNIX, args[0],0)
		else
			first, second = Socket.pair(AF_UNIX, args[0],args[1])	
		end
		first.extend UNIXSocketMethods
    second.extend UNIXSocketMethods 
		first.path,second.path = "",""
		first.af, second.af = "AF_UNIX","AF_UNIX"
		return first, second
	end

end

Object.send(:remove_const, :TCPSocket)

class TCPSocket < Socket
  
  alias_method :recv_blocking, :recv

	def initialize(*args)
    super(AF_INET, SOCK_STREAM, 0)
    self.connect(Socket.sockaddr_in(*(args.reverse)))
  end


	def recv_neverblock(*args)
		res = ""
		begin
			@immediate_result = recv_nonblock(*args)
			res << @immediate_result
		rescue Errno::EWOULDBLOCK, Errno::EAGAIN, Errno::EINTR
  		attach_to_reactor(:read)
  		retry
		end
		res
  end

	def recv(*args)
		if Fiber.current[:neverblock]
			res = recv_neverblock(*args)
    else
      res = recv_blocking(*args)
    end
		res
  end

end

class BasicSocket
  @@getaddress_method = IPSocket.method(:getaddress)
  def self.getaddress(*args)
    @@getaddress_method.call(*args)
  end
end
