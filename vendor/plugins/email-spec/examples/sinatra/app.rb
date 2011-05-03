require 'sinatra'
require 'pony'

get '/' do
  <<-EOHTML
  <form method="post" action="/signup">
      <label for="Name">Name</label>
      <input type="text" id="Name" name="user[name]">
      <label for="Email">Email</label>
      <input type="text" id="Email" name="user[email]">
      <input type="submit" value="Sign up">
  </form>
  EOHTML
end

post '/signup' do
  user = params[:user]
  body = <<-EOHTML
  Hello #{user['name']}!

  <a href="http://www.example.com/confirm">Click here to confirm your account!</a>
  EOHTML
  Pony.mail(:from => 'admin@example.com',
            :to => user['email'],
            :subject => 'Account confirmation',
            :body => body
  )
  'Thanks!  Go check your email!'
end

get '/confirm' do
  'Confirm your new account!'
end
