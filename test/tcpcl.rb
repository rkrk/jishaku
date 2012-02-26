require "socket"

host,port = "localhost", ARGV[0].nil? ? 78910 : ARGV[0]

TELEGRAM 	=	"00020000             ORANGE20000APPLE01000032100812012000000267 000000002 999995600000100001020606200@131234567444454901=33156990253000000000 12341234567000056780000000@10@0701A0000000041010 9004a2000100004a00007000012342001100213300000 00000000000000000000000000B0 00000@"
T_89120 	=	"00020000             ORANGE20000APPLE01000089100812012000000267 000000002 999995600000100001020606200@"
T_89340 	=	"00020000             ORANGE20000APPLE01000089100812012000000267 000000002 999995600000100001020606200@"

t = [TELEGRAM,T_89120,T_89340]

# 9.times do |n|

puts at = Time.now
1.times do |n|
	puts "------------#{n}-------------"
	# p port = port.to_i+n
	TCPSocket.open(host,port) do |s|
	# Thread.new do 
	# sleep(100)
		 # p "->#{Thread.current}"
		 10.times do |num|
			 s.puts t[rand(3)]
			 s.gets
		 end
	# end
	# sleep(0.1)
	end
	puts "------------#{n}-------------"
end
# end

puts Time.now-at