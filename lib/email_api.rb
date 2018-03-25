require 'sinatra/base'
require 'json'
require 'date'
require './lib/email_api/api/api_parser'
require './lib/email_api/email/client/email_client'
require './lib/email_api/email/data/email_object'

# Main class of Email API Project
class EmailApi < Sinatra::Base

  # Ping with current time
  get '/ping' do
    puts "Received new Ping Request from #{request.ip}"
    { time: Time.now.utc }.to_json
  end

  # Send Email (Supports calling through a web browser)
  get '/send' do
    puts "Received new Email Send GET Request from #{request.ip}"
    handle_api(params).to_hash.to_json
  end

  # Send Email (Proper usage, as a POST request)
  post '/send' do
    puts "Received new Email Send POST Request from #{request.ip}"
    handle_api(params).to_hash.to_json
  end

  # Handle request received through API
  def handle_api(api_params)
    return nil if !api_params.respond_to?(:[]) && !api_params.is_a?(Hash)
    from      = api_params['from']
    to        = api_params['to']
    cc        = api_params['cc']
    bcc       = api_params['bcc']
    subject   = api_params['subject']
    content   = api_params['content']
    email_obj = ApiParser.parse_email(from, to, cc, bcc, subject, content)
    EmailClient.send_email(email_obj)
  rescue StandardError => e
    puts "Error: #{e.class}: #{e.message}"
    response = ClientResponse.new
    response.set_internal_err
    response
  end
end

