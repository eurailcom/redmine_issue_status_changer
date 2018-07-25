namespace :redmine do
  namespace :plugins do
    namespace :issue_status_change do
      desc <<-END_DESC
Change the target version to the target version of the parent task

  rake redmine:plugins:issue_status_change:change_target_version RAILS_ENV=production
      END_DESC
      task change_target_version: :environment do |_t, _args|
        IssueStatusChanger.change_target_version
      end
    end
  end
end