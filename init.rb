require 'redmine'

Redmine::Plugin.register :redmine_issue_status_changer do
  name 'Redmine Issue Status Changer'
  author 'Daniel Vijge'
  description 'Automatically change status of issues based on status of subtasks'
  version '0.0.1'
  url 'https://github.com/danielvijge/redmine_issue_status_changer'
  author_url 'https://github.com/luismaia'
  requires_redmine version_or_higher: '2.1.0'

  settings :default => {
  }, :partial => 'settings/issue_status_change'


  # puts 'This plugin works with the current Ruby, Rails and Redmine versions'
end
