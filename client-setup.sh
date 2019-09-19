#!/usr/bin/env sh
set -e

LOG_SERVER_HOSTNAME=$1

main () {
    check_args
    rsyslog_setup

    write_log "INFO" "rsyslog configured successfully"
}

rsyslog_setup () {
    write_log "INFO" "Installing rsyslog"
    sudo yum install -y rsyslog rsyslog-gnutls

    write_log "INFO" "Copying config to /etc/rsyslog.conf"
    cat << 'EOF' | sudo tee /etc/rsyslog.conf 1> /dev/null
#### MODULES ####

$ModLoad imuxsock # provides support for local system logging (e.g. via logger command)
$ModLoad imjournal # provides access to the systemd journal

#### GLOBAL DIRECTIVES ####

$WorkDirectory /var/lib/rsyslog

$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat
$IncludeConfig /etc/rsyslog.d/*.conf
$OmitLocalLogging on
$IMJournalStateFile imjournal.state

#### RULES ####

*.info;mail.none;authpriv.none;cron.none                /var/log/messages
authpriv.*                                              /var/log/secure
mail.*                                                  -/var/log/maillog
cron.*                                                  /var/log/cron
*.emerg                                                 :omusrmsg:*
uucp,news.crit                                          /var/log/spooler
local7.*                                                /var/log/boot.log

# ### begin forwarding rule ###
$ActionQueueSaveOnShutdown on # save messages to disk on shutdown
$ActionQueueType LinkedList   # run asynchronously
$ActionResumeRetryCount -1    # infinite retries if host is down

$DefaultNetstreamDriverCAFile /etc/ssl/ca-cert.pem
$ActionSendStreamDriverMode 1
$ActionSendStreamDriverAuthMode anon
$DefaultNetstreamDriver gtls

*.* @@REMOTE_HOST:6514
# ### end of the forwarding rule ###
EOF

    write_log "INFO" "Setting $LOG_SERVER_HOSTNAME as log server in rsyslog config"
    sudo sed -i "s/REMOTE_HOST/$LOG_SERVER_HOSTNAME/g" /etc/rsyslog.conf

    write_log "INFO" "Starting and enabling rsyslog"
    sudo systemctl restart rsyslog
    sudo systemctl enable rsyslog
}

check_args() {
    if test -z "$LOG_SERVER_HOSTNAME"; then
        write_log "ERROR" "No hostname or IP provided for log server"
    fi
}

write_log(){
    LOGGING="$1"
    MESSAGE="$2"
    TIMESTAMP="[$(date)]"

    echo "$TIMESTAMP - $LOGGING - $MESSAGE"

    if [ "$LOGGING" = "ERROR" ]; then
        exit 1;
    fi
}

main
