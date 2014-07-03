require 'sinatra'
require 'dotenv'
Dotenv.load

get '/' do
  '<h1>Wait for it…</h1>'
end
