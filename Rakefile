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
  app.deployment_target = '10.8'
  app.name = 'Butter'
  app.icon = 'icon.icns'
  app.identifier = 'jp.harukasan.butter'
  app.version = '0.1.2'
  app.frameworks << 'WebKit'
end

namespace :archive do
  desc "Create a .dmg archive"
  task :dmg do
    Rake::Task['build:release'].invoke

    config = Motion::Project::App.config
    dmg_name = "#{config.name}_#{config.version}"

    sh "rm -rf build/Release"
    sh "rm -f build/#{dmg_name}.dmg"
    sh "rsync -a build/MacOSX-#{config.deployment_target}-Release/#{config.name}.app build/Release"
    sh "ln -sf /Applications build/Release"

    sh "hdiutil create build/tmp.dmg -volname #{dmg_name} -srcfolder build/Release"
    sh "hdiutil convert -format UDBZ build/tmp.dmg -o build/#{dmg_name}.dmg"
    sh "rm -f build/tmp.dmg"
  end
end
