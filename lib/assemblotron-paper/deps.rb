module AssemblotronPaper

  class Deps

    attr_accessor :atron

    def initialize(opts, gem_dir, data)
      @opts, @gem_dir, @data = opts, gem_dir, data
    end

    # check assemblotron bin is installed
    def check_assemblotron

      binstubs_dir = File.join(@gem_dir, 'binstubs')
      @atron = File.join(binstubs_dir, 'atron')

      unless File.exists? @atron

        puts "Assemblotron binaries not found - installing"
        `bundle install`
        `bundle install --binstubs #{binstubs_dir}`

      end

      return @atron

    end # check_assemblotron

  end # Deps

end # AssemblotronPaper
