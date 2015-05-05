require 'rubygems'
require 'sinatra'
require 'base64'
require 'uri'
require 'find'
require_relative './analyze_midi'

# set :port, 80

set :sessions => true

get '/record' do

  # Look at all the lesson plan files
  @lesson_plan_files = []
  Find.find('lesson_plans') do |path|
    @lesson_plan_files << path if path =~ /.*\.rb$/
  end
  @lesson_plan_files.each { |path| path.slice!(".rb") }

  # If there is no saved lesson plan, choose the first one
  if(!session.has_key?('lesson_plan'))
    session['lesson_plan'] = @lesson_plan_files[0]
  end

  # Load the chosen lesson plan
  load session['lesson_plan']+".rb"
  print "\nrequiring" + session['lesson_plan'] + "\n"
  
  # Disposable user id generated each time the recording page loads
  # This will be the name of the performance midi file
  if(!session.has_key?('user_id'))
    session['user_id'] = SecureRandom.hex(10)
  end
  
  # Make target midi and png
  generate_target(session['user_id'])

  # Load the html page
  erb :record_metronome #, locals: {:lesson_plans => lesson_plan_files}
end

post "/upload/midi" do 
  
  # Decode the base64 string
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
  analyze_performance(session['user_id'])
  # compare_midi(session['target'], "uploads/" + filename)

  # Return image
  encoded_image = Base64.encode64(File.open("uploads/" + filename + "_comp.gif", "rb").read)
  return encoded_image
end

get '/lesson/:index' do |index|
  lesson_plan_files = []
  Find.find('lesson_plans') do |path|
    lesson_plan_files << path if path =~ /.*\.rb$/
  end
  lesson_plan_files.each { |path| path.slice!(".rb") }

  session.clear
  session['lesson_plan'] = lesson_plan_files[index.to_i]
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
