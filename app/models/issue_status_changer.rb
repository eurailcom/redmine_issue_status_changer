# encoding: utf-8
module IssueStatusChanger

    def self.get_open_status
        IssueStatus.select( :id ).where("is_closed=0").collect {|s| s.id}.join(",")
    end

    def self.get_closed_status
        IssueStatus.select( :id ).where("is_closed=1").collect {|s| s.id}.join(",")
    end

    def self.get_enabled_trackers(state = 'open')
        state = 'close' if (state != 'close' and state != 'open' and state != 'additional')
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

    def self.is_higher_status(old_status, new_status)
        if (IssueStatus.find new_status).position > (IssueStatus.find old_status).position then
            true
        else
            false
        end
    end

    def self.close_issues_with_all_subtasks_closed
        issue_change_state('close')
    end

    def self.open_issues_with_open_subtasks
        issue_change_state('open')
    end

    def self.change_issues_on_subtask_status
        __change_issues_on_subtask_status()
    end

    def self.change_target_version
        __change_target_version()
    end

    def self.issue_change_state(state)
        settings = Setting['plugin_redmine_issue_status_changer'] || {}

        # TODO: do not close issues that have related issues blocked by
        enabled_trackers = get_enabled_trackers(state)
        enabled_trackers.split(',').each { |tracker|
            if state == 'close' then
                change_state = get_open_status()
                test = "="
                status_message = settings['status_message_closed']
            elsif state == 'open' then
                change_state = get_closed_status()
                test = "<"
                status_message = settings['status_message_open']
            end
            protected_trackers = settings['new_status']['protected_status'][tracker] || ['999']
            protected_status = protected_trackers.join(",")

            # TODO: Do not rely on SQL query any more
            Issue.where("done_ratio#{test}100 AND tracker_id=#{tracker} AND status_id IN (#{change_state}) AND status_id NOT IN (#{protected_status}) AND id IN (SELECT parent_id FROM issues)").each do |issue|
                i = Issue.find issue.id
                if i.relations_to.where(:relation_type => 'blocks').count > 0 then
                    # TODO: add skipped issues to an array and process again. A later iteration might close the blocking issue
                    next
                end
                new_status = IssueStatus.find get_next_state(i.tracker_id, state)

                puts i.id.to_s + " " + i.subject + ": " + (IssueStatus.find i.status_id).name + " --> " + new_status.name
                i.init_journal(User.anonymous, status_message)
                i.update_attribute :status,  new_status
            end
        }
    end

    def self.__change_issues_on_subtask_status()
        settings = Setting['plugin_redmine_issue_status_changer'] || {}
        enabled_trackers = get_enabled_trackers('additional')

        status_message = settings['status_message_additional']
        
        enabled_trackers.split(',').each { |tracker|

            old_status = settings['new_status']['additional_from'][tracker]
            new_status = settings['new_status']['additional_to'][tracker]
            protected_status = settings['new_status']['protected_status'][tracker].join(",")

            Issue.where("tracker_id=#{tracker} AND id IN (SELECT subtasks.parent_id from issues AS subtasks WHERE subtasks.status_id IN (#{new_status}) AND status_id NOT IN (#{protected_status}) AND subtasks.parent_id=`issues`.id)").each do |issue|
                i = Issue.find issue.id
                if is_higher_status(i.status_id, new_status) then
                    

                    puts i.id.to_s + " " + i.subject + ": " + (IssueStatus.find i.status_id).name + " --> " + (IssueStatus.find new_status).name
                    i.init_journal(User.anonymous, status_message)
                    i.update_attribute :status, (IssueStatus.find new_status)
                end
            end
        }
    end

    def self.__change_target_version()
        settings = Setting['plugin_redmine_issue_status_changer'] || {}
        enabled_trackers =  settings['change_target_version'].keys.join(',')

        status_message = settings['status_message_target_version']

        enabled_trackers.split(',').each { |tracker|

            Issue.joins(:status).joins('INNER JOIN `issues` AS parent ON parent.id=`issues`.parent_id').where(:tracker_id => 3).where('issue_statuses.is_closed=0').where('`issues`.fixed_version_id!=parent.fixed_version_id OR (parent.fixed_version_id IS NULL AND `issues`.fixed_version_id IS NOT NULL) OR (parent.fixed_version_id IS NOT NULL and `issues`.fixed_version_id IS NULL)').each do |issue|
                i = Issue.find issue.id

                if i.fixed_version_id? then
                    current_version = Version.find(i.fixed_version_id).name
                else
                    current_version = 'None'
                end 

                if i.parent.fixed_version_id? then
                    new_version = Version.find(i.parent.fixed_version_id).name
                    new_version_id = i.parent.fixed_version_id
                else
                    new_version = 'None'
                    new_version_id = nil
                end 

                puts i.id.to_s + " " + i.subject + ": " + current_version + " --> " + new_version
                i.init_journal(User.anonymous, status_message)
                i.update_attribute :fixed_version_id, new_version_id
            end
        }
    end
end

