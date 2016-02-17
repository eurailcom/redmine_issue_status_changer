# Issue Status Changer #

This module defines three `rake` tasks for automatically changing the issue status.

## Available tasks ##

### Close issues with closed subtasks ###

When all subtasks are closed, you might want to change the status of the parent issue as well.
Actually, it doesn't check if all subtasks are closed, just if the issue has subtasks, and if
the %done is 100. If 'Calculate the issue done ratio with' is set to 'Use the issue field' this
should have the exact same effect.

`rake redmine:plugins:issue_status_change:close_issues_with_all_subtasks_closed RAILS_ENV=production`

### Open issues with new subtasks ###

Even if an issue was once closed, if new subtasks are created, you might want to reopen the issue.
Just as with the close task above, it checks if there are issues which are closed but have a %done of
less than 100.

`rake redmine:plugins:issue_status_change:open_issues_with_open_subtasks RAILS_ENV=production`

### Additional status change ###

If one of the subtasks have a certain status, you can change the status of the parent issue. For example,
if one of the subtasks has a status 'In progress', the parent issue can also be changed to 'In progress'.

`rake redmine:plugins:issue_status_change:change_issues_on_subtask_status RAILS_ENV=production`

## Configuration ##

Status changes can be configured per tracker. For each tracker, you can set if the task should change the
status, and if so, what the new status should be.

## Using the plugin ##

Just installing this plugin doesn't do much. You need to create a cron job that actually runs the `rake`
tasks at a regular interval.