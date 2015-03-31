require 'rubygems'
require 'sinatra'
require "sinatra/cookies"
require 'base64'
require 'uri'
require './analyze_midi'

# set :port, 80

set :sessions => true

get '/record' do
  session['target'] = 'invent1_chunk_short'
  send_file 'public_html/record_metronome.html'
end

get '/js/:filename' do |filename|
  send_file "js/" + filename
end

get '/public_html/:filename' do |filename|
  send_file "public_html/" + filename
end

get '/uploads/:filename' do |filename|
  send_file "uploads/" + filename
end

get '/targets/:filename' do |filename|
  send_file "targets/" + filename
end

# Handle POST-request (Receive and save the uploaded file)
post "/upload/midi" do 
  base64 = URI.unescape(request.body.read.split('=', 2)[1])
  decode_base64_content = Base64.decode64(base64)

  # Generate filename
  random = SecureRandom.hex(10)

  # Write file
  filepath = "uploads/" + random + ".mid"
  File.open(filepath, "wb+") do |f|
    f.write(decode_base64_content)
  end

  # Analyze midi
  compare_midi("targets/" + session['target'], "uploads/" + random)

  # Tell the client what the id of the files are
  cookies['upload_id'] = random
  response.set_cookie 'upload_id', random

  # Return image
  encoded_image = Base64.encode64(File.open("uploads/" + random + "_comp.gif", "rb").read)
  return encoded_image
end
