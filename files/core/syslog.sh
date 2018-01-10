#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

yum -y install rsyslog
<% if config.rsyslog.is_server -%>
cat << EOF > /etc/rsyslog.d/metalware.conf
\$template remoteMessage, "/var/log/slave/%FROMHOST%/messages.log"
:fromhost-ip, !isequal, "127.0.0.1" ?remoteMessage
& ~
EOF

sed -i -e "s/^#\$ModLoad imudp.*$/\$ModLoad imudp/g" /etc/rsyslog.conf
sed -i -e "s/^#\$UDPServerRun 514.*$/\$UDPServerRun 514/g" /etc/rsyslog.conf
sed -i -e "s/^#\$ModLoad imtcp.*$/\$ModLoad imtcp/g" /etc/rsyslog.conf
sed -i -e "s/^#\$InputTCPServerRun 514.*$/\$InputTCPServerRun 514/g" /etc/rsyslog.conf

cat << EOF > /etc/logrotate.d/rsyslog-remote
/var/log/slave/*/*.log {
    sharedscripts
    compress
    rotate 2
    postrotate
        /bin/kill -HUP \`cat /var/run/syslogd.pid 2> /dev/null\` 2> /dev/null || true
        /bin/kill -HUP \`cat /var/run/rsyslogd.pid 2> /dev/null\` 2> /dev/null || true
    endscript
}
EOF
cat << EOF > /var/lib/firstrun/scripts/firewall_rsyslog.bash
firewall-cmd --add-port 514/udp --zone internal --permanent
firewall-cmd --add-port 514/tcp --zone internal --permanent
firewall-cmd --reload
EOF
<% else -%>
echo '*.* @<%= config.rsyslog.server %>:514' >> /etc/rsyslog.conf
<% end -%>

systemctl enable rsyslog
systemctl restart rsyslog
