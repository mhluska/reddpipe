require 'tmpdir'

task default: :deploy

task :build do
    %x[ bundle install && jekyll build ]
end

desc 'Deploy to staging'
task deploy: :'deploy:staging'

namespace :deploy do
  desc 'Deploy to staging'
  task staging: :build do
    rsync 'staging.reddpipe.com'
  end

  desc 'Deploy to production'
  task production: :build do
    rsync 'reddpipe.com'
  end

  desc 'Deploy to staging and production'
  task all: [:staging, :production]

  def rsync(domain)
    %x[ rsync -rtz --delete _site/ mhluska@104.236.9.238:/home/mhluska/#{domain} ]
  end
end
