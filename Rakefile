# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'
require 'bubble-wrap'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.codesign_for_release = false
  app.name = 'Butter'
  app.icon = 'icon.icns'
  app.identifier = 'jp.harukasan.butter'
  app.version = '0.0.1'
  app.frameworks << 'WebKit'
end
