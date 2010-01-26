require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "fastory"
    gem.summary = %Q{Make FactoryGirl faster by caching SQL on frequently used factories}
    gem.description = %Q{Sits on top of FactoryGirl and, when appropriate, caches SQL for later playback}
    gem.email = "ryan@angilly.com"
    gem.homepage = "http://github.com/mypunchbowl/fastory"
    gem.authors = ["Ryan Angilly"]
    gem.add_development_dependency "thoughtbot-shoulda"
    gem.add_dependency "activesupport", '>=2.3.5'
    gem.add_dependency "activerecord", '>=2.3.5'
    gem.add_dependency "factory_girl", '>=1.2.3'

    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/*_test.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "fastory #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
