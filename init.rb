require 'redmine'

Redmine::Plugin.register :redmine_issue_status_changer do
  name 'Redmine Issue Status Changer'
  author 'Daniel Vijge'
  description 'Automatically change status of issues based on status of subtasks'
  version '0.0.1'
  url 'https://github.com/danielvijge/redmine_issue_status_changer'
  author_url 'https://github.com/danielvijge'
  requires_redmine version_or_higher: '2.1.0'

  settings :default => {
    "change_status" => 1,
    "new_status" => 1
  }, :partial => 'settings/issue_status_change'

  settings[:default]["change_status"] = Hash.new
  settings[:default]["new_status"] = Hash.new

end
