namespace :redmine do
  namespace :plugins do
    namespace :issue_status_change do
      desc <<-END_DESC
Bla bla bla

  rake redmine:plugins:issue_status_change:close_issues_with_all_subtasks_closed RAILS_ENV=production
      END_DESC
      task close_issues_with_all_subtasks_closed: :environment do |_t, _args|
        IssueStatusChanger.close_issues_with_all_subtasks_closed
      end
    end
  end
end
