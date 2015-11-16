
module AssemblotronPaper

  class Controller

    def initialize opts
      @opts = opts
      spec = Gem.loaded_specs['assemblotron-paper']
      @gem_dir = spec.full_gem_path
      input_files_yaml = File.join(@gem_dir,
                                   'metadata',
                                   'input_files.yaml')
      @data = YAML.load_file input_files_yaml
      @reads_got = false
      check_assemblotron
    end

    def run_full_sweeps
      sweep = Sweep.new(@opts, @gem_dir, @atron, @data)
      sweep.run_all
    end # run_full_sweeps

    def maybe_get_read_data
      data = Data.new(@opts, @gem_dir, @data)
      data.maybe_get_read_data
    end # maybe_get_read_data

    def check_assemblotron
      deps = Deps.new(@opts, @gem_dir, @atron, @data)
      @atron = deps.check_assemblotron
    end

  end

end # module
