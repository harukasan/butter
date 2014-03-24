# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/osx'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

require 'bubble-wrap'
require 'ib'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.codesign_for_release = true
  app.codesign_certificate = 'Developer ID Application: Shunsuke Michii (VNS7H9UXPP)'
  app.name = 'Butter'
  app.icon = 'icon.icns'
  app.identifier = 'jp.harukasan.butter'
  app.version = '0.0.1'
  app.frameworks << 'WebKit'
end
