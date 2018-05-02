class cron::devtest {
cron { devtest:
        command => "/root/testing.sh ",
        hour => '1',
        minute => '10',
        monthday => '*',
        month =>'*',
        weekday => '*',
    }
file {"/root/testing.sh":
        ensure=>file,
        owner=>'root',
        group=>'root',
        mode=>'755',
        source => 'puppet:///modules/cron/devtest/testing.sh',
        }
}

