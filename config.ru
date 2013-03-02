require 'rubygems'
require 'bundler/setup'

require 'sinatra'
require 'em-http'
require './streamer'

run Sinatra::Application