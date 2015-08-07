require "./config/enviornment"
require "./app/models/snap"
require "./app/models/user"

class ApplicationController < Sinatra::Base
  
  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
		enable :sessions
		set :session_secret, 'admin123'
  end
  
  get '/' do
		erb :index
  end
	
	post '/register' do
		username = params[:username]
		password = params[:password]
		email = params[:email]
		if (username == "")
			@error = "USERNAME"
			@link = "/register"
			erb :noPic
		elsif (password == "")
			@error = "PASSWORD"
			@link = "/register"
			erb :noPic
		elsif (email == "")
			@error = "EMAIL"
			@link = "/register"
			erb :noPic
		else
		user = User.new(:username => username, :password => password, :email => email, :friends => "")
		user.save
		puts User.all
		@snaps = Snap.all
		redirect '/snaps'
		end
	end
	
	get '/new' do
	if session[:user_id] != nil
		erb :snapchat
	else
			redirect '/'
		end
	end
	
	post '/new' do
				if session[:user_id] != nil
    time  = Time.new
		if (params[:url] == "") || (params[:url][0..3].downcase != "http")
			@error = "URL"
			@link = "/new"
			erb :noPic
		elsif (params[:to] == "")
			@error = "RECIPIENT"
			@link = "/new"
			erb :noPic
		elsif (params[:time] == "none")  
			@error = "TIME LIMIT"
			@link = "/new"
			erb :noPic
		else
			# 			need to add from user here and in erb when u log in
      @user = User.find_by(:username => params[:to])
      @snap = Snap.new(:user_id => @id, :caption => params[:cap], :timer => params[:time], :time => "#{time.hour}:#{time.min}",:format => "png", :link => params[:url], :read => "false")
      @snap.save
      @snaps = Snap.all
      redirect '/snaps'
		end
				else
			redirect '/'
		end
		
	end
	
	get '/snaps' do
		if session[:user_id] != nil
		@username = User.find_by(session[:user_id]).username.capitalize
		@snaps = Snap.all
			erb :snaps
		else
			redirect '/'
		end
	end

	get '/register' do
		erb :register
	end

	get '/login' do
		erb :login
	end

	post '/login' do
		username = params[:username]
		password = params[:password]
		if (username == "")
			@error = "USERNAME"
			@link = "/login"
			erb :noPic
		elsif (password == "")
			@error = "PASSWORD"
			@link = "/login"
			erb :noPic
		else
			if (username.include? "@")
			user_by_email = User.find_by(:email => username)
			puts "else in post login"
			if (password == user_by_email.password)
				if user_by_email
					@username = user_by_email.username
					session[:user_id] = user_by_email.id
					redirect '/snaps'
				else
					redirect '/register'
				end
			else
				@error = "PASSWORD"
				@link = "/login"
				erb :noPic
			end
			else
			user_by_name = User.find_by(:username => username)
			if (password == user_by_name.password)
				if user_by_name
					@username = user_by_name.username
					puts @username
					session[:user_id] = user_by_name.id
					redirect '/snaps'
				else
					redirect '/register'
				end
			else
				@error = "PASSWORD"
				@link = "/login"
				erb :noPic
			end
			end
		end
	end
	
	get '/logout' do
		session[:user_id] = nil
		redirect '/'
	end
	
end