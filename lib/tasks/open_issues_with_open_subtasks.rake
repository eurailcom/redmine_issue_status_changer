namespace :redmine do
  namespace :plugins do
    namespace :issue_status_change do
      desc <<-END_DESC
Bla bla bla

  rake redmine:plugins:issue_status_change:open_issues_with_open_subtasks RAILS_ENV=production
      END_DESC
      task open_issues_with_open_subtasks: :environment do |_t, _args|
        IssueStatusChanger.open_issues_with_open_subtasks
      end
    end
  end
end
