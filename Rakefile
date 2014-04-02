require 'rake'

env = %(PKG_BUILD="#{ENV['PKG_BUILD']}") if ENV['PKG_BUILD']

PROJECTS = %w(activesupport activemodel actionpack actionmailer activeresource activerecord railties)

Dir["#{File.dirname(__FILE__)}/*/lib/*/version.rb"].each do |version_path|
  require version_path
end

desc 'Run all tests by default'
task :default => %w(test test:isolated)

%w(test test:isolated package gem).each do |task_name|
  desc "Run #{task_name} task for all projects"
  task task_name do
    errors = []
    PROJECTS.each do |project|
      warn 'When running tests for Rails LTS, prefer running the "railslts:test" task.'
      system(%(cd #{project} && #{$0} #{task_name})) || errors << project
    end
    fail("Errors in #{errors.join(', ')}") unless errors.empty?
  end
end

namespace :railslts do

  desc 'Run tests for Rails LTS compatibility'
  task :test do

    puts '', "\033[44m#{'activesupport'}\033[0m", ''
    system('cd activesupport && rake test') or raise 'failed'

    puts '', "\033[44m#{'actionmailer'}\033[0m", ''
    system('cd actionmailer && rake test') or raise 'failed'

    puts '', "\033[44m#{'actionpack'}\033[0m", ''
    system('cd actionpack && rake test') or raise 'failed'

    puts '', "\033[44m#{'activemodel'}\033[0m", ''
    system('cd activemodel && rake test') or raise 'failed'

    puts '', "\033[44m#{'activerecord (mysql)'}\033[0m", ''
    system('cd activerecord && rake test_mysql') or raise 'failed'


    db_path = '/tmp/lts-test-db'
    FileUtils.mkdir_p(db_path)
    puts '', "\033[44m#{'activerecord (sqlite3)'}\033[0m", ''
    system("cd activerecord && DB_PATH=#{db_path} rake test_sqlite3") or raise 'failed'

    puts '', "\033[44m#{'activerecord (postgres)'}\033[0m", ''
    system('cd activerecord && rake test_postgresql') or raise 'failed'

    puts '', "\033[44m#{'activeresource'}\033[0m", ''
    system('cd activeresource && rake test') or raise 'failed'

    puts '', "\033[44m#{'railties'}\033[0m", ''
    system('cd railties && TMP_PATH=/tmp/lts-test-app rake test') or raise 'failed'

  end

  task :clean_gems do
    PROJECTS.each do |project|
      pkg_folder = "#{project}/pkg"
      puts "Emptying packages folder #{pkg_folder}..."
      FileUtils.mkdir_p(pkg_folder)
      system("rm -rf #{pkg_folder}/*") or raise "failed"
    end
  end

  task :clean_building_artifacts do
    PROJECTS.each do |project|
      pkg_folder = "#{project}/pkg"
      puts "Deleting building artifacts from #{pkg_folder}..."
      system("rm -rf #{pkg_folder}/*.tgz") or raise "failed" # TGZ
      system("rm -rf #{pkg_folder}/*.zip") or raise "failed" # ZIP
      system("rm -rf #{pkg_folder}/*/") or raise "failed"    # Folder
    end
  end

  task :zip_gems do
    puts "Zipping archive for manual installation..."
    archive_name = "railslts.tar.gz"
    system("cd dist && rm -f #{archive_name} && tar -czvhf #{archive_name} railslts/ && cd ..") or raise "failed"
  end

  desc 'Builds *.gem packages for static distribution without Git'
  task :build_gems => [:clean_gems, :package, :clean_building_artifacts, :zip_gems] do
    puts "Done."
  end

  desc 'Updates the LICENSE file in individual sub-projects'
  task :update_license do
    require 'date'
    last_change = Date.parse(`git log -1 --format=%cd`)
    PROJECTS.each do |project|
      license_path = "#{project}/LICENSE"
      puts "Updating license #{license_path}..."
      File.exists?(license_path) or raise "Could not find license: #{license_path}"
      license = File.read(license_path)
      license.sub!(/ before(.*?)\./ , " before #{last_change.strftime("%B %d, %Y")}.") or raise "Couldn't find timestamp."
      File.open(license_path, "w") { |w| w.write(license) }
    end
  end

  namespace :release do

    task :ensure_ready do
      jobs = [
        'Did you release a new version of https://github.com/makandra/railslts-version ?',
        'Did you bump the required "railslts-version" dependency in railties.gemspec?',
        'Did you update the LICENSE files using `rake railslts:update_license`?',
        'Did you build static gems using `rake railslts:build_gems`?',
        'Did you commit and push your changes, as well as the changes by the Rake tasks mentioned above?',
      ]

      puts

      jobs.each do |job|
        print "#{job} [y/n] "
        answer = STDIN.gets
        puts
        unless answer.strip == 'y'
          $stderr.puts "Aborting. Nothing was released."
          puts
          exit
        end
      end
    end


    desc "Publish new Rails LTS customer release on gems.makandra.de/railslts"
    task :customer => :ensure_ready do
      for hostname in %w[c23 c42]
        fqdn = "#{hostname}.gems.makandra.de"
        puts "\033[1mUpdating #{fqdn}...\033[0m"
        command = '/opt/update_railslts.sh'
        system "ssh deploy-gems_p@#{fqdn} '#{command}'" or fail
        puts "done."
      end

      puts "Deployment done."
      puts "Check https://gem.makandra.de/railtslts"
    end

    desc "Publish new Rails LTS community release on github.com/makandra/rails"
    task :community => :ensure_ready do
      existing_remotes = `git remote`
      unless existing_remotes.include?('community')
        system('git remote add community git@github.com:makandra/rails.git') or raise "Couldn't add remote'"
      end
      system('git fetch community && git push community 3-0-lts') or raise 'Error while publishing'
      puts "Deployment done."
      puts "Check https://github.com/makandra/rails/tree/3-0-lts"
    end

  end

end
