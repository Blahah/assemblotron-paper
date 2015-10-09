require 'bindeps'
require 'yaml'
require 'open3'
require 'fixwhich'
require 'fileutils'

module AssemblotronPaper

  class AssemblotronPaper

    def initialize
      @data = {} # description and location of the data
      @gem_dir = Gem.loaded_specs['assemblotron-paper'].full_gem_path
    end

  end

end
