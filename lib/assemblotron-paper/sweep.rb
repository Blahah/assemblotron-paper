module AssemblotronPaper

  class Sweep

    def initialize(opts, gem_dir, atron, data)
      @opts, @gem_dir, @atron, @data = opts, gem_dir, atron, data
    end


    # For each dataset, run a full parameter sweep at a variety of sampling
    # rates, including with no sampling (i.e. the full dataset).
    #
    # For the sampled runs, do both stream sampling and graph sampling.
    def run_all

      Dir.chdir File.join(@gem_dir, 'data') do

        @data[:reads].each_pair do |species, dataset|

          puts "Running full sweeps for #{species.to_s}"

          Dir.chdir species.to_s do

            [1.0, 0.2, 0.1, 0.05].each do |rate|

              run_sweep(species, dataset, rate)

            end

          end

        end

      end

    end # run_all

    def run_sweep(species, dataset, rate)

      samplers = rate == 1.0 ? ['stream'] : ['graph', 'stream']

      samplers.each do |sampler|

        3.times do |n|

          rep_no = n + 1

          ratestr = "#{(rate * 100).to_i}pc"
          params = [species.to_s, sampler, ratestr, rep_no]
          csvfile = File.expand_path "#{params.join '_'}.csv"
          if File.exists?(csvfile) && !@opts.force
            puts "Skipping sweep [sampler: #{sampler}" +
                 " rate: #{rate} rep: #{rep_no}] -" +
                 " output file exists"
            next
          end

          puts "Running full sweep using sampler #{sampler}" +
               " at sample rate #{rate} (rep #{rep_no})"

          # run assemblotron with the specified sampling method
          # and the rep_no as seed
          cmdstr =
            @atron +
            " --left #{dataset[:left][:filename]}" +
            " --right #{dataset[:right][:filename]}" +
            " --threads #{@opts.threads}" +
            "#{rate == 1.0 ? '' : ' --skip-subsample'}" +
            " --sampler #{sampler}" +
            " --skip-final" +
            " --optimiser sweep" +
            " --seed #{rep_no}"
          cmd = Cmd.new(cmdstr)
          start = Time.now
          cmd.run
          puts "Assemblotron command ran in #{Time.now - start} seconds"

          unless cmd.status.success?
            raise "Assemblotron failed: \n#{cmd.stderr}"
          end

          save_logs(cmd.stdout, species.to_s, sampler, ratestr, rep_no)
          save_csv(cmd.stdout, species.to_s, sampler, ratestr, rep_no)

        end

      end
    end # run_sweep


    # Save the log output of an Assemblotron run
    def save_logs(stdout, *args)

      logfile = "#{args.join '_'}.log"
      logfile = File.expand_path logfile

      File.open(logfile, 'w') do |f|

        f.write stdout
        puts "Assemblotron sweep log saved to #{logfile}"

      end

    end # save_logs


    # Save the results of an assemblotron run as a CSV file
    # by parsing the logs
    def save_csv(stdout, *args)

      lineregex = /parameters: K:(\d+), d:(\d+), e:(\d+) \| score: (\S+)/

      csvfile = "#{args.join '_'}.csv"
      csvfile = File.expand_path csvfile

      CSV.open(csvfile, 'w') do |out|

        out << ['K', 'd', 'e', 'score']

        stdout.split("\n").each do |line|

          next unless line =~ /^run/

          k, d, e, score = line.match(lineregex).captures
          score = score.to_f.round(6)
          score = 0.0 if score < 0.0001

          out << [k, d, e, score]

        end

        puts "Assemblotron sweep data saved to #{csvfile}"

      end

    end # save_csv



  end # Sweep

end # AssemblotronPaper
