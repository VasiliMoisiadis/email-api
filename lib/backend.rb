require 'backend/api/api_parser'
require 'backend/email/client/email_client'
require 'sinatra/base'
require 'json'
require 'date'

# Main class of Email Backend Project
class Backend < Sinatra::Base
  # Ping with current time
  get '/ping' do
    { time: DateTime.now }.to_json
  end

  # Send Email (Supports calling through a web browser)
  get '/send' do
    backend_send(params).to_json
  end

  # Send Email (Proper usage, as a POST request)
  post '/send' do
    backend_send(params).to_json
  end

  def backend_send(api_params)
    puts "Received new Email Send Request from #{request.ip}"
    email_obj = ApiParser.parse_email(api_params)
    status 200
    EmailClient.send_email(email_obj)
  rescue StandardError => e
    puts "Error: #{e.class}: #{e.message}"
    status 400
    e.message
  end
end

