module AssemblotronPaper

  class OptimiserSim

    require 'fileutils'

    def initialize(opts, gem_dir, atron)
      @opts, @gem_dir, @atron = opts, gem_dir, atron
    end

    # Using the yeast dataset, run the various optimisation algorithms
    # 100 times each.
    def run_optimisation_sim(species, sampler, rate, rep)
      return if @opts.skip.include? species

      puts "Running simulation for #{species} sampler:#{sampler} rate:#{rate} rep:#{rep}"

      # TODO: expand to include SPEA2
      simdata_path = get_csv_path(species, sampler, rate, rep)
      outdir = get_outdir(species, sampler, rate, rep)
      run_sim(simdata_path, outdir)

      if File.exist?(File.join(outdir, '99_scores.csv')) && !@opts.force
        puts "Skipping optimisation simulation - output file already exists"
        return
      end

    end

    def run_sim(simdata_path, outdir)
      Dir.chdir(outdir) do
        cmdstr =
          @atron +
          " --simulate #{simdata_path}"
          " --optimiser tabu"
        cmd = Cmd.new(cmdstr)
        start = Time.now
        cmd.run
        puts "Optimisation simulation ran in #{Time.now - start} seconds"

        unless cmd.status.success?
          raise "Assemblotron failed: \n#{cmd.stderr}"
        end
      end
    end

    def get_csv_path(species, sampler, rate, rep)
      filename = "#{species}_#{sampler}_#{(rate * 100).to_i}pc_#{rep}.csv"
      File.join(@gem_dir, 'data', species, filename)
    end

    def get_outdir(species, sampler, rate, rep)
      dir = File.join(@gem_dir, 'data', 'sim', species,
                      sampler, "#{(rate * 100).to_i}", rep.to_s)
      FileUtils.mkdir_p dir
      dir
    end


  end # OptimiserSim

end # AssemblotronPaper
