# encoding: utf-8
module IssueStatusChanger

    def self.get_open_status
        IssueStatus.select( :id ).where("is_closed=0").collect {|s| s.id}.join(",")
    end

    def self.get_closed_status
        IssueStatus.select( :id ).where("is_closed=1").collect {|s| s.id}.join(",")
    end

    def self.get_enabled_trackers(state = 'open')
        state = 'close' if (state != 'close' and state != 'open')
        settings = Setting['plugin_redmine_issue_status_changer'] || {}
        if settings['status_change'][state] != nil then
            settings['status_change'][state].keys.join(',')
        else
            false
        end
    end

    def self.get_next_state(tracker_id, state = 'close')
        state = 'close' if (state != 'close' and state != 'open')
        settings = Setting['plugin_redmine_issue_status_changer'] || {}
        settings['new_status'][state][tracker_id.to_s].to_i
    end

    def self.close_issues_with_all_subtasks_closed
        issue_change_state('close')
    end

    def self.open_issues_with_open_subtasks
        issue_change_state('open')
    end

    def self.issue_change_state(state)
        settings = Setting['plugin_redmine_issue_status_changer'] || {}

        

        enabled_trackers = get_enabled_trackers(state)
        if enabled_trackers then
            if state == 'close' then
                change_state = get_open_status()
                test = "="
                status_message = settings['status_message_closed']
            elsif state == 'open' then
                change_state = get_closed_status()
                test = "<"
                status_message = settings['status_message_open']
            end

            Issue.where("done_ratio#{test}100 AND tracker_id IN (#{enabled_trackers}) AND status_id IN (#{change_state}) AND id IN (SELECT parent_id FROM issues)").each do |issue|
                i = Issue.find issue.id
                new_status = IssueStatus.find get_next_state(i.tracker_id, state)

                puts i.id.to_s + " " + i.subject + ": " + (IssueStatus.find i.status_id).name + " --> " + new_status.name
                i.init_journal(User.anonymous, status_message)
                i.update_attribute :status,  new_status
            end
        end
    end
end