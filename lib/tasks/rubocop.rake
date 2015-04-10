desc 'Run Rubocop on uncommitted changed files'
task :rubocop do
  RUBY_FILENAME_PATTERNS = %w(Rakefile .rb .rake)
  def ruby_file?(filename)
    RUBY_FILENAME_PATTERNS.each do |pattern|
      return true if filename.include? pattern
    end

    false
  end

  def deleted?(git_file)
    git_file.split(' ').first.include? 'D'
  end

  def filename_from(git_file)
    git_file.split(' ').last
  end

  git_files = `git status -uno --porcelain`
  filenames = git_files.split("\n")
              .reject { |git_file| deleted?(git_file) }
              .map { |git_file| filename_from(git_file) }
              .select { |filename| ruby_file?(filename) }
              .join(' ')

  sh "bundle exec rubocop -R #{filenames}" unless filenames.empty?
end
