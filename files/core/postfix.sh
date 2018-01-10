#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

yum -y install postfix
<% unless node.name == 'local' -%>
sed -n -e '/^relayhost\s*=/!p' -e '$arelayhost=[<%=config.postfix.relayhost%>]' /etc/postfix/main.cf -i
<% end -%>
systemctl enable postfix
systemctl restart postfix
