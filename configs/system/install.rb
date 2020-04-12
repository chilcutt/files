#!/usr/bin/env ruby

require "logger"

LOGGER = Logger.new(STDOUT)

FILES = %w[
  aliases
  bash_logout
  bash_profile
  bashrc
  gitconfig
  gitignore
  inputrc
  profile
  pryrc
  tmux.conf
  vimrc
]

FILES.each do |file|
  dotfile_path = "#{ENV["HOME"]}/.#{file}"
  repo_path = "#{__dir__}/#{file}"

  if !File.exist?(dotfile_path) && !File.symlink?(dotfile_path)
    File.symlink(repo_path, dotfile_path)
    LOGGER.info("Installed #{dotfile_path} => #{repo_path}")
  else
    LOGGER.warn("Detected #{dotfile_path}, skipping...")
  end
end
