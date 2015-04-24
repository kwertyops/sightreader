require 'rubygems'
require 'sinatra'
require "sinatra/cookies"
require 'base64'
require 'uri'
require 'find'
require './analyze_midi'

# set :port, 80

set :sessions => true

# The main page
get '/record' do

  # This is for scrolling through a folder full of midi lessons
  if(!session.has_key?('target_num'))
    session['target_num'] = 0
  end
  
  target_files = []
  Find.find('targets') do |path|
    target_files << path if path =~ /.*\.mid$/
  end
  session['target_num'] = (session['target_num'] + 1) % target_files.length
  session['target'] = target_files[session['target_num']]
  session['target'].slice!(".mid")
  
  # Disposable user id generated each time the recording page loads
  # This will be the name of the performance midi file
  session['user_id'] = SecureRandom.hex(10)
  
  # Load the html page
  erb :record_metronome
end

# Handle POST-request (Receive and save the uploaded file)
post "/upload/midi" do 
  
  base64 = URI.unescape(request.body.read.split('=', 2)[1])
  decode_base64_content = Base64.decode64(base64)

  # Generate filename
  filename = session['user_id']

  # Write file
  filepath = "uploads/" + filename + ".mid"
  File.open(filepath, "wb+") do |f|
    f.write(decode_base64_content)
  end

  # Analyze midi
  compare_midi(session['target'], "uploads/" + filename)

  # Tell the client what the id of the files are
  # IF YOU FIND THIS AND EVERYTHING IS WORKING, THEN DELETE IT ALL
  #
  # cookies['upload_id'] = filename
  # response.set_cookie 'upload_id', filename

  # Return image
  encoded_image = Base64.encode64(File.open("uploads/" + filename + "_comp.gif", "rb").read)
  return encoded_image
end

get '/logout' do
  session.clear
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

get '/performance' do
  session['user_id']
end
