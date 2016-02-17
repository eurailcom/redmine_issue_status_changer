namespace :redmine do
  namespace :plugins do
    namespace :issue_status_change do
      desc <<-END_DESC
Bla bla bla

  rake redmine:plugins:issue_status_change:change_issues_on_subtask_status RAILS_ENV=production
      END_DESC
      task change_issues_on_subtask_status: :environment do |_t, _args|
        IssueStatusChanger.change_issues_on_subtask_status
      end
    end
  end
end
