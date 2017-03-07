#!/usr/bin/env ruby

require 'fileutils'

def main
  exit_status = 0
  begin
    a_gemfile_dir = specified_gemfile_dir

    gemfile_pattern = File.join('test', 'gemfiles', '*')
    gemfile_dirs = Dir.glob(gemfile_pattern)

    puts(gemfile_dirs)
    gemfile_dirs.each do |gemfile_dir|
      next if a_gemfile_dir && !gemfile_dir.include?(a_gemfile_dir)
      File.open("#{gemfile_dir}/scenarios") do |f|
        f.each_line do |scenario|
          scenario.chomp!
          next if scenario.empty?
          begin
            run_scenario(gemfile_dir, "test/scenarios/#{scenario}")
          rescue
            exit_status = 1
          end
        end
      end
    end
  rescue
    exit_status = 1
  end
  exit_status
end

def specified_gemfile_dir
  gemfile_dir = if !ARGV.empty?
                  ARGV[0]
                elsif ENV['GEMFILE_DIR']
                  ENV['GEMFILE_DIR']
                end
  gemfile_dir
end

def run_scenario(gemfile_dir, scenario)
  gemfile = File.join(gemfile_dir, 'Gemfile')
  puts ''
  puts "Testing scenario #{scenario} with #{gemfile}..."

  bundle_path_dir = File.join('vendor', 'bundle')
  FileUtils.rm_rf(bundle_path_dir) if Dir.exist?(bundle_path_dir)
  result_file = 'result.log'
  cmd = <<-EOF
    export BUNDLE_GEMFILE=#{gemfile} && \
    bundle install --path #{bundle_path_dir} && \
    bundle exec ruby -I lib #{scenario} > #{result_file}
  EOF
  run_cmd(cmd, result_file)
end

def run_cmd(cmd, result_file)
  puts cmd
  is_ok = system(cmd)
  result = File.read(result_file)
  if !result.empty?
    puts '=> FAIL: Expected empty output but was:'
    puts "--#{result}--"
    raise RuntimeError
  end
  unless is_ok
    puts '=> FAIL: Expected zero exit status'
    raise RuntimeError
  end
  puts '=> PASS'
end

exit_status = main
exit(exit_status)
