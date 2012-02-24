class Telegram

 attr_accessor :telegram_in,:telegram_out

 def initialize(telegram_in,telegram_out)
 @telegram_in = telegram_in
 @telegram_out = telegram_out
 end

 def ping(sock_out,sock_in)
 sock_out.write @telegram_in
 @telegram_out = sock_in.gets
 end

 def pong(sock_in,sock_out)
 @telegram_out = sock_in.gets
 sock_out.write
 end

 def simple_reply
 @telegram_out = @telegram_in.dup

 return if @telegram_in.size < 63

 message_type = @telegram_in[43,4]
 reply_mt = case
 when message_type =~ /^89[12]0/ then "8950"
 when message_type =~ /^89[34]0/ then "8960"
 when message_type =~ /^([0-7|9]\d)10/ then "#{$1}20"
 else message_type
 end
 @telegram_out[43,4] = reply_mt
 end

 def to_hex()
 end

 def ascii?
 end

end