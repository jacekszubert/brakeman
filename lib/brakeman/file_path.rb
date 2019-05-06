require 'pathname'

module Brakeman
  # Class to represent file paths within Brakeman.
  # FilePath objects track both the relative and absolute paths
  # to make it easier to manage paths.
  class FilePath
    attr_reader :absolute, :relative
    @cache = {}

    # Create a new FilePath using a Tracker object.
    #
    # Note that if the path is already a FilePath, that path will
    # be returned unaltered.
    #
    # Additionally, paths are cached. If the absolute path already has
    # a FilePath in the cache, that existing FilePath will be returned. 
    def self.from_tracker tracker, path
      return path if path.is_a? Brakeman::FilePath
      self.from_app_tree tracker.app_tree, path
    end

    # Create a new FilePath using an AppTree object.
    #
    # Note that if the path is already a FilePath, that path will
    # be returned unaltered.
    #
    # Additionally, paths are cached. If the absolute path already has
    # a FilePath in the cache, that existing FilePath will be returned.
    def self.from_app_tree app_tree, path
      return path if path.is_a? Brakeman::FilePath

      absolute = app_tree.expand_path(path).freeze

      if fp = @cache[absolute]
        return fp 
      end

      relative = app_tree.relative_path(path).freeze

      self.new(absolute, relative).tap { |fp| @cache[absolute] = fp }
    end

    # Create a new FilePath with the given absolute and relative paths.
    def initialize absolute_path, relative_path
      @absolute = absolute_path
      @relative = relative_path
    end

    def read
      File.read self.absolute
    end

    # Compare FilePaths. Raises an ArgumentError unless both objects are FilePaths.
    def <=> rhs
      raise ArgumentError unless rhs.is_a? Brakeman::FilePath
      self.relative <=> rhs.relative
    end

    # Compare FilePaths. Raises an ArgumentError unless both objects are FilePaths.
    def == rhs
      return false unless rhs.is_a? Brakeman::FilePath

      self.absolute == rhs.absolute
    end

    # Returns a string with the absolute path.
    def to_str
      self.absolute
    end

    # Returns a string with the absolute path.
    def to_s
      self.to_str
    end
  end
end
