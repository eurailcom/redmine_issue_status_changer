# encoding: utf-8
module IssueStatusChanger

    def self.get_open_status
        IssueStatus.select( :id ).where("is_closed=0").collect {|s| s.id}.join(",")
    end

    def self.get_closed_status
        IssueStatus.select( :id ).where("is_closed=1").collect {|s| s.id}.join(",")
    end

    def self.get_enabled_trackers
        settings = Setting['plugin_redmine_issue_status_changer'] || {}
        if settings['status_change'] != nil then
            settings['status_change'].keys.join(',')
        else
            false
        end
    end

    def self.get_next_state(tracker_id)
        settings = Setting['plugin_redmine_issue_status_changer'] || {}
        settings['new_status'][tracker_id.to_s].to_i
    end


    def self.close_issues_with_all_subtasks_closed
        settings = Setting['plugin_redmine_issue_status_changer'] || {}

        status_message = settings['status_message']

        enabled_trackers = get_enabled_trackers()
        if enabled_trackers then
            open_state = get_open_status()
            closed_state = get_closed_status()

            # Get all issues that have a done ratio of 100% (meaning all subtask closed) but the status is not closed
            Issue.where("done_ratio=100 AND tracker_id IN (#{enabled_trackers}) AND status_id IN (#{open_state})").each do |issue|
                i = Issue.find issue.id
                new_status = IssueStatus.find get_next_state(i.tracker_id)

                #puts i.id.to_s + " " + i.subject + ": " + (IssueStatus.find i.status_id).name + " --> " + new_status.name
                i.init_journal(User.anonymous, status_message)
                i.update_attribute :status,  new_status
            end
        end
    end
end