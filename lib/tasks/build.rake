namespace :build do
  desc 'Build the ember application using the RAILS_ENV variable'
  task :ember do
    puts 'building XML Builder'
    puts `cd ember/xml_builder; ember build -o ../../public/javascripts/xml_builder.js; cd ../..`
    # puts 'minifying xml_builder.js'
    # uglified = Uglifier.new.compile(File.read("#{Rails.root}/public/javascripts/xml_builder.js"))
    # rewrite_file('public/javascripts/xml_builder.dist.js') {|f| uglified }
  end

  def rewrite_file(file, &block)
    unless File.exist?(file)
      `touch #{file}`
    end
    source = File.read(file)
    File.write(file, block.call(source))
  end

end