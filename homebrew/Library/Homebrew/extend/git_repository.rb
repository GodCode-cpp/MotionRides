# typed: strict
# frozen_string_literal: true

require "utils/git"
require "utils/popen"

# Extensions to {Pathname} for querying Git repository information.
# @see Utils::Git
# @api private
module GitRepositoryExtension
  extend T::Sig

  sig { returns(T::Boolean) }
  def git?
    join(".git").exist?
  end

  # Gets the URL of the Git origin remote.
  sig { returns(T.nilable(String)) }
  def git_origin
    popen_git("config", "--get", "remote.origin.url")
  end

  # Sets the URL of the Git origin remote.
  sig { params(origin: String).returns(T.nilable(T::Boolean)) }
  def git_origin=(origin)
    return if !git? || !Utils::Git.available?

    safe_system Utils::Git.git, "remote", "set-url", "origin", origin, chdir: self
  end

  # Gets the full commit hash of the HEAD commit.
  sig { params(safe: T::Boolean).returns(T.nilable(String)) }
  def git_head(safe: false)
    popen_git("rev-parse", "--verify", "--quiet", "HEAD", safe: safe)
  end

  # Gets a short commit hash of the HEAD commit.
  sig { params(length: T.nilable(Integer), safe: T::Boolean).returns(T.nilable(String)) }
  def git_short_head(length: nil, safe: false)
    short_arg = length.present? ? "--short=#{length}" : "--short"
    popen_git("rev-parse", short_arg, "--verify", "--quiet", "HEAD", safe: safe)
  end

  # Gets the relative date of the last commit, e.g. "1 hour ago"
  sig { returns(T.nilable(String)) }
  def git_last_commit
    popen_git("show", "-s", "--format=%cr", "HEAD")
  end

  # Gets the name of the currently checked-out branch, or HEAD if the repository is in a detached HEAD state.
  sig { params(safe: T::Boolean).returns(T.nilable(String)) }
  def git_branch(safe: false)
    popen_git("rev-parse", "--abbrev-ref", "HEAD", safe: safe)
  end

  # Change the name of a local branch
  sig { params(old: String, new: String).void }
  def git_rename_branch(old:, new:)
    popen_git("branch", "-m", old, new)
  end

  # Set an upstream branch for a local branch to track
  sig { params(local: String, origin: String).void }
  def git_branch_set_upstream(local:, origin:)
    popen_git("branch", "-u", "origin/#{origin}", local)
  end

  # Gets the name of the default origin HEAD branch.
  sig { returns(T.nilable(String)) }
  def git_origin_branch
    popen_git("symbolic-ref", "-q", "--short", "refs/remotes/origin/HEAD")&.split("/")&.last
  end

  # Returns true if the repository's current branch matches the default origin branch.
  sig { returns(T.nilable(T::Boolean)) }
  def git_default_origin_branch?
    git_origin_branch == git_branch
  end

  #                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    