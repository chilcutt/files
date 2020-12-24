#!/usr/bin/env ruby

require 'open3'

module Linter
  Result = Struct.new(:success, :errors, keyword_init: true)

  class Rubocop
    def self.filename_extensions
      %w[rb]
    end

    def self.perform(filenames)
      target_filenames = filenames.select { |f| f.match(/.rb$/) }

      return Result.new(success: true, errors: []) if target_filenames.empty?

      output, status =
        Open3.capture2e(
          "rubocop --format simple --fail-level autocorrect --auto-correct #{
            target_filenames.join(' ')
          }",
          chdir: Dir.pwd,
        )

      Result.new(success: status.success?, errors: output)
    end
  end

  class Prettier
    def self.filename_extensions
      %w[rb js jsx ts]
    end

    def self.perform(filenames)
      target_filenames = filenames.select { |f| f.match(/.(?:rb|js|jsx|ts)$/) }

      return Result.new(success: true, errors: []) if target_filenames.empty?

      output, status =
        Open3.capture2e(
          "yarn run --silent prettier --list-different --write #{
            target_filenames.join(' ')
          }",
          chdir: Dir.pwd,
        )

      Result.new(success: status.success? && output.empty?, errors: output)
    end
  end

  class ESLint
    def self.filename_extensions
      %w[js jsx ts]
    end

    def self.perform(filenames)
      target_filenames = filenames.select { |f| f.match(/.(?:rb|js|jsx|ts)$/) }

      return Result.new(success: true, errors: []) if target_filenames.empty?

      targets = target_filenames.join(' ')

      output, status =
        Open3.capture2e("yarn run --silent eslint #{targets}", chdir: Dir.pwd)

      system("yarn run --silent eslint --fix #{targets}") unless status.success?

      Result.new(success: status.success?, errors: output)
    end
  end

  class Runner
    def self.perform(enabled_linters)
      filename_extensions =
        enabled_linters
          .flat_map(&:filename_extensions)
          .uniq
          .map { |ext| "'*.#{ext}'" }
          .join(' ')

      out, status =
        Open3.capture2e(
          "git diff --cached --name-only --diff-filter=ACM -- #{
            filename_extensions
          }",
          chdir: Dir.pwd,
        )

      raise 'Unable to retrieve git status.' unless status.success?

      filenames = out.split("\n")

      exit(0) if filenames.empty?

      results =
        enabled_linters.each_with_object({}) do |linter, results|
          name = linter.name.split("::").last
          puts "Checking #{name}..."
          results[name] = linter.perform(filenames)
        end

      unless results.values.all?(&:success)
        puts
        results.each do |type, result|
          next if result.success
          puts('=' * 50)
          puts red("#{type} errors:")
          puts result.errors
          puts('=' * 50)
          puts
        end
        exit(1)
      end

      exit(0)
    end

    private_class_method def self.red(string)
      "\e[31m#{string}\e[0m"
    end
  end
end
