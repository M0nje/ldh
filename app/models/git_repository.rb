require 'git'

class GitRepository < ApplicationRecord
  # The state of a git repository at a specific commit.
  # Provides methods for listing/reading files.
  class Version
    include ActiveModel::Model
    include GitSupport

    attr_accessor :git_repository, :ref, :commit
  end

  belongs_to :resource, polymorphic: true, optional: true
  has_many :git_versions
  after_create :initialize_repository
  after_create :setup_remote, if: -> { remote.present? }

  acts_as_uniquely_identifiable

  has_task :remote_git_fetch

  def local_path
    File.join(Seek::Config.git_filestore_path, remote.present? ? uuid : "#{resource_type}-#{resource_id}")
  end

  def git_base
    return unless persisted?
    @git_base ||= Seek::Git::Base.base_class.new(local_path)
  end

  def fetch
    git_base.remotes['origin'].fetch
  end

  def fetching?
    remote_git_fetch_task && !remote_git_fetch_task.completed?
  end

  def remote_refs
    @remote_refs ||= if remote.present?
                       refs = { branches: [], tags: [] }
                       hash = Seek::Git::Base.base_class.ls_remote(remote)
                       head = hash['head'][:sha]
                       hash['branches'].each do |name, info|
                         h = { name: name, ref: "refs/heads/#{name}", sha: info[:sha], default: info[:sha] == head }
                         refs[:branches] << h
                       end
                       hash['tags'].each do |name, info|
                         h = { name: name, ref: "refs/tags/#{name}", sha: info[:sha] }
                         refs[:tags] << h
                       end

                       refs[:branches] = refs[:branches].sort_by { |x| [x[:default] ? 0 : 1, x[:name]] }
                       refs[:tags] = refs[:tags].sort_by { |x| x[:name] }

                       refs
                     end
  end

  # Return the commit SHA for the given ref.
  def resolve_ref(ref)
    git_base.ref(ref)&.target&.oid
  end

  def remote?
    remote.present?
  end

  def queue_fetch
    RemoteGitFetchJob.perform_later(self)
  end

  def at_ref(ref)
    commit = resolve_ref(ref)
    GitRepository::Version.new(git_repository: self, commit: commit, ref: ref)
  end

  def at_commit(commit)
    GitRepository::Version.new(git_repository: self, commit: commit)
  end

  private

  def initialize_repository
    Seek::Git::Base.base_class.init(local_path)
  end

  def setup_remote
    git_base.add_remote('origin', remote)
    queue_fetch
  end
end
