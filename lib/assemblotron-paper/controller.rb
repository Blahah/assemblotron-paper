
module AssemblotronPaper

  class Controller

    def initialize opts
      @opts = opts
      spec = Gem.loaded_specs['assemblotron-paper']
      @gem_dir = spec.full_gem_path
      load_metadata
      @reads_got = false
      check_assemblotron
    end

    def load_metadata
      input_files_yaml = File.join(@gem_dir,
                                   'metadata',
                                   'input_files.yaml')

      @data = YAML.load_file input_files_yaml

      @opts.skip.each do |sp|
        if !(@data[:reads].keys.include? sp.to_sym)
          puts "Error: you have asked to skip a species (#{sp})" +
               " that isn't in the data"
          puts "Please choose one of: #{@data[:reads].keys.join(', ')}"
          exit
        end
        
        puts "Dropping #{sp} from analysis"
        @data[:reads].delete(sp.to_sym)
      end
    end

    def run_full_sweeps
      sweep = Sweep.new(@opts, @gem_dir, @atron, @data)
      sweep.run_all
    end # run_full_sweeps

    def measure_performance
      perf = PerformanceTest.new(@opts, @gem_dir, @atron, @data)
      perf.measure
    end

    def maybe_get_read_data
      data = Data.new(@opts, @gem_dir, @data)
      data.maybe_get_read_data
    end # maybe_get_read_data

    def check_assemblotron
      deps = Deps.new(@opts, @gem_dir, @data)
      @atron = deps.check_assemblotron
    end

  end

end # module
