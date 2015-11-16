module AssemblotronPaper

  class OptimiserSim

    def initialize(opts, gem_dir, atron)
      @opts, @gem_dir, @atron = opts, gem_dir, atron
    end

    # Using the yeast dataset, run the various optimisation algorithms
    # 100 times each.
    def run_optimisation_sim
      # TODO: expand to include SPEA2
      simdata_path = File.join(@gem_dir, 'data',
                               'yeast', 'yeast_stream_100pc_1.csv')
      if File.exist?(simdata_path) && !@opts.force
        puts "Skipping optimisation simulation - output file already exists"
        return
      end
      cmdstr =
        @atron +
        " --simulation #{simdata_path}"
        " --optimiser tabu"
      cmd = Cmd.new(cmdstr)
      start = Time.now
      cmd.run
      puts "Optimisation simulation ran in #{Time.now - start} seconds"

      unless cmd.status.success?
        raise "Assemblotron failed: \n#{cmd.stderr}"
      end
    end


  end # OptimiserSim

end # AssemblotronPaper
