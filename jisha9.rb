require 'sinatra'
require './model/jisha'

JISHA_MAX_NUMBER = 9

@@jisha = {}
@@jisha_num = 0

# JISHA_MAX_NUMBER.times do |n|
 # uri = 'druby://localhost:' + (78910+n).to_s
 # @@jisha << DRbObject.new(nil, uri)
# end



['/','/home'].each do |home|
	get home do
		request.env.map { |e| e.to_s + "\n" }
		erb :home
	end
end

['/jishas','/jisha/list'].each do |jisha|
	get jisha do
		request.env.map { |e| e.to_s + "\n" }
		erb :jisha_list
	end
end

get '/jisha/add' do
	request.env.map { |e| e.to_s + "\n" }
	erb :jisha_add
end

post '/jisha/new' do
	 request.env.map { |e| e.to_s + "\n" }
	 redirect back unless get_usable_jisha?
 
	 # @@jisha[get_usable_jisha? + 1]
 
	 if format_check_jishacode(params[:jisha_code]) && format_check_port(params[:port])
		 js = Jisha.new(params[:jisha_code],params[:port])
	 else
		 body "some error"
		 redirect back
	 end

	 if params[:option] == "receiver_only"
		 js_thread = Thread.start{js.run_as_receiver_only};sleep(0.1)
	 else 
		 js_thread = Thread.start{js.run};sleep(0.1)
	 end
	 
	 @@jisha_num+=1
	 @@jisha.store(@@jisha_num,[js,js_thread]) 
	 redirect to('/jisha/list')
 
end

get '/jisha/:no/send/config' do 
	 request.env.map { |e| e.to_s + "\n" }
	 @jisha_no = params[:no]
	 erb :send_config
end

get '/jisha/rtlog' do 
	 request.env.map { |e| e.to_s + "\n" }
	 erb :rtlog
end

get '/jisha/jnl' do 
	 request.env.map { |e| e.to_s + "\n" }
	 erb :jnl_search
end

get '/jisha/stop/:no' do 
	 request.env.map { |e| e.to_s + "\n" }
	 # p params[:no]
	 # p @@jisha
	 # p @@jisha[1]
	 
	 Thread.kill(@@jisha[params[:no].to_i][1])
	 @@jisha[params[:no]] = nil
	 @@jisha_num -= 1
	 redirect to('/jisha/list')
	 # erb :jisha_stop
end	

get '/about' do
	 request.env.map { |e| e.to_s + "\n" }
	 erb :about_me
end

get '/test1' do
	 j = Jisha.new("2a961",12345)
	 p j
	 Thread.new{j.run_as_receiver_only};sleep(0.1)
	 # redirect to('/jisha/list')
	 @t = Thread.list
	 erb :test
end

get '/test2' do
	 9.times do |n|
		 j = Jisha.new("No#{n}",78910+n)
		 Thread.new{j.run};sleep(0.1)
	 end
	 erb :test
	 # p j
	 # p Thread.list.each {|t| p t}
end

#helper method
 
 def get_usable_jisha?
	@@jisha_num <= JISHA_MAX_NUMBER ? true : false
 end
 
 def format_check_jishacode(jisha_code)
	 true
	 # ((7..11).include? jisha_code.size && jisha_code =~ /\w+/) ? true : nil
 end

 def format_check_port(port)
	 true
	 # ((4..5).include? port.size && port.to_s =~ /[1-9]\d+/) ? true : nil
 end
 
 