require 'sinatra'
require 'json'
require 'active_support/all'
require "active_support/core_ext"
require 'twilio-ruby'
# require 'sqlite3'
require 'shotgun'

require 'rake'

# configure :development do
# 	require 'pg'
# end

enable :sessions

configure :development do
	require 'dotenv'
	Dotenv.load
end

client = Twilio::REST::Client.new ENV['TWILIO_ACCOUNT_SID'], ENV['TWILIO_AUTH_TOKEN']

get '/' do
	"Basic Application working"
	#401
end

get '/from' do
	"This is from #{ENV['TWILIO_FROM']}"
end

get '/send_sms' do
	client.account.messages.create(
		:from => ENV['TWILIO_FROM'],
		:to=> "+16462580532",
		:body=> "You've just asked to send a message to yourself!"
	)
	"Sent message!"
end

get '/incoming_sms' do

	session['counter']||=0
	count=session['counter']

	sender=params[:From]||=''
	#receiver=params[:To]||=''
	body=params[:Body]||=''

	body=body.downcase.strip

	if count < 1
		message="So #{sender}, this is your first message. Woohoo!"
	else
		message="You said #{body} from your phone number #{sender}"
	end
	# client.account.Messages.create {
	# 	:from =>ENV["TWILIO_FROM"],
	# 	:to=>sender,
	# 	:body=>message
	# }
	session['counter'] += 1

	twiml= Twilio::TwiML::Response.new do |t|
		t.Message message	
	end

	content_type 'text/xml'

	twiml.text

end

error '401' do
	"Hola you made a mistake. But mistakes happen!"
end
