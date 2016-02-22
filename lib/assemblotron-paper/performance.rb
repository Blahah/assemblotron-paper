module AssemblotronPaper

  class PerformanceTest

    def initialize(opts, gem_dir, atron, data)
      @opts, @gem_dir, @atron, @data = opts, gem_dir, atron, data
    end

    def measure

      puts "Running assemblotron on simulated data for sampled reads"
      sim = OptimiserSim.new(@opts, @gem_dir, @atron)
      species = %w[arabidopsis yeast]
      samplers = %w[graph stream]
      rates = [0.1]
      reps = [1, 2, 3]
      species.each do |sp|

        next if @opts.skip.include? sp

        samplers.each do |sampler|
          rates.each do |rate|
            reps.each do |rep|
              sim.run_optimisation_sim(sp, sampler, rate, rep)
            end
          end
        end
      end

      puts "All performance test simulations done"

    end

  end # OptimiserSim

end # AssemblotronPaper
