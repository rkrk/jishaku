
require 'socket'
require 'logger'
require 'thread'
# require 'timeout'

# require './model/telegram'

class Jisha

	class TcpServerInitError < RuntimeError
	end

	class WrongTelegramError < RuntimeError
	end
	
	class SocketTimeoutError < RuntimeError
	end

	attr_reader :status,:jnl_c,:error_c
	attr_accessor :jisha_code,:host,:port,:send_q,:mode
	
	RETRY_MAX = 5 
	
	def initialize(jisha_code,port,ip="localhost")
		 @jisha_code = jisha_code
		 @host = ip
		 @port = port
		 @mode = "normal"
		 @status = "no ready"
		 
		 @sock = nil
		 
		 @receive_q = Array.new
		 @send_q = Array.new
		 
		 @jnl_c = Array.new
		 @error_c = Array.new
		 
		 # @thread_count = 0
		 
		 # @logger = Logger.new(STDOUT)
		 # @logger.level = Logger::DEBUG

	end

	def run
		threads = []
		server = tcp_server_init
		p "Normal jisha Startup!".center(60,"*")
		if server.nil?
			print("Coundn't open jisha at port ",@port," . Try another port, plz.\n")
		return
		end
		while true
			Thread.start(@sock = server.accept) do 
				@status = "Connected"
				print(@sock," from ",@sock.addr.join(":")," is connected.\n")

				# t1 = Thread.new { @sock.synchronize{tcp_in} } 
				# t2 = Thread.new { @sock.synchronize{tcp_out} } 
				while true
				
############################################IMPORTANT !!!!!!!!!!!!    ##################################################
#######################################THE <sleep> after <Thread.new{}> ################################################
				Thread.new { tcp_in }.run ;sleep(0.00001)
				# t2 = 
				# while t1
					 # Thread.list {|t| p t};sleep(10)
					 Thread.new{ tcp_out }.run;sleep(0.00001)
					 Thread.new{ receive }.run;sleep(0.00001)
					 # 3.times {|n|threads[n].run}
					 # threads.each {|t| t.join}
				# end
				# sleep
				end
				@sock.close
            @status = "Inited"
            print(@sock," is gone.\n")
				
			end
			
			
		end
	end

	def run_as_receiver_only
		 server = tcp_server_init
		 p "Receive only jisha Startup!".center(60,"*")
		 if server.nil?
			 print("Coundn't open jisha at port ",@port," . Try another port, plz.\n")
			 return
		 end
		 @mode = "receiver only"
		 while true
			 Thread.start(@sock = server.accept) do 
				 @status = "Connected"
				 print(@sock," from ",@sock.addr.join(":")," is connected.\n")
				 while @sock.gets
					 @sock.write simple_reply($_)
				 end
				 @sock.close
				 @status = "Inited"
				 print(@sock," is gone.\n")
			 end
		 end
	end
	
	# def stop
		 # @status = "Inited"
		 # @sock = nil
	# end
	
	def is_alive?
		 "#{@status}"
	end

	def to_s
		 "#{@jisha_code} on ip:#{@host} & port: #{@port}"
		 # "test"
	end
	
	private

	def tcp_in
		 # p "TCP Incoming thread".center(50,"-")
		 while true
			t = @sock.gets
			# Timeout::timeout(2) do
			# p "Get an incoming telegram ..."
			# p "->[#{t[0,63].to_s} ...]"
			@receive_q.push t
			# p "Push incoming telegram into receive_q..."
			# end
			sleep(0.001)
		 end
	end

	def tcp_out
		 while true
			# p "TCP Outgoing thread".center(50,"-")
			# Timeout::timeout(2) do
			# p "Nothing for send...";
			return if @send_q.size == 0
			t = @send_q.shift 
			# p "Shift outgoing telegram from send_q"
			# p "<-[#{t[0,63].to_s}]"
			@sock.puts t #@send_q.shift #timeout handle??
			@jnl_c << "sen" + t.to_s
			# @thread_count -= 1
			# p "Sent an outgoing telegram ......"
			# end
			sleep(0.005)
		 end
	end

	def receive
		# retry_count = 0 
		 while true
			# Thread.stop #if @thread_count > 10
			# p "Telegram receive thread".center(50,"-")
			if @receive_q.size == 0
				# p "Nothing in receive_q."
				sleep(0.001)
				return 
			end
			
			t = @receive_q.shift
			
			# p "->->[#{t[0,63].to_s} ...]"
			# p "mt [#{t.to_s[43,4]}]"
			# p is_req? t
			# p is_res? t
			if is_req? t
				# p "@Get a request telegram.Message type: [#{t.to_s[43,4]}]"
				reply_t = reply t
				# p "@Reply incoming telegram with :\n"
				# p "<-<-[#{reply_t[0,63]} ...]"
				@send_q.push reply_t
				@jnl_c << "req" + reply_t.to_s
				# p "@Push reply-telegram into send_q." 
			elsif is_res? t
				# p "@Get a respond telegram.Message type: [#{t.to_s[43,4]}]"
				@jnl_c << "res" + t.to_s
			else
				# p "WrongTelegramError"
				# @error_c << t;sleep(1)
				@send_q << "error telegram!!!!!!"
				@error_c << "error telegram!!!!!!"
				Thread.pass
				receive
			end
			sleep(0.001)
		 end
	end
	
	def is_req?(telegram)
		message_type = telegram.to_s.chomp[43,4]
		message_type =~ /\d\d[135]0/ ? true : false
	end

	def is_res?(telegram)
		message_type = telegram.to_s.chomp[43,4]
		message_type =~ /\d\d[246]0/ ? true : false
	end
	
	# def send(telegram)
		 # sousin
		 # p "soushin".center(20,"-")
		 # @send_q.push telegram
		 # p @send_q
		 # return 0
	# end

	# def sender(telegram)
		 # if @sock
			 # @sock.write telegram
			 # puts @sock.gets
		 # else
			 # puts "Havn't any usable socket connection."
		 # end
	# end

	def tcp_server_init
		 begin
			 sv = TCPServer.open(@port)
			 puts "Jisha : [#{@jisha_code}] is listening on port [#{@port}] at [#{@host}] !"
			 # sv.@status="Inited"
			 sv
		 rescue TcpServerInitError => e
			 p e
		 end
	end

	def read_telegram(sock)
		 # read Header & telegram(from trailer length of header)
		 # header = sock[0..63]
		 # ranges = sock[60,3].to_i
		 # data = sock[63,ranges]
		 # header + data
		 sock
	end

	def reply(telegram)
		 simple_reply(telegram)
	end

	def simple_reply(telegram)
		 return telegram if telegram.size < 63
		 message_type = telegram[43,4]
		 reply_mt = case
						 when message_type =~ /^89[12]0/ 		then "8950"
						 when message_type =~ /^89[34]0/ 		then "8960"
						 when message_type =~ /^([0-7|9]\d)10/ 	then "#{$1}20"
						 else message_type
					end
		 telegram[43,4] = reply_mt
		 telegram
	end

end

class Object
	def synchronize
		 mutex.synchronize { yield self }
	end

	def mutex
		 @mutex ||= Mutex.new
	end
end


# j = Jisha.new("2a961",12345)
# 5.times {|n|j.send_q << "test"*n}
# sleep(1)
# j.run
# j.run_as_receiver_only


