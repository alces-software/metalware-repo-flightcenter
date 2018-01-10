#!/bin/bash
#(c)2017 Alces Software Ltd. HPC Consulting Build Suite
#Job ID: <%= config.jobid %>
#Cluster: <%= config.cluster %>

yum -y install chrony
<% if config.ntp.is_server -%>
cat << EOF > /etc/chrony.conf
server 0.centos.pool.ntp.org iburst
server 1.centos.pool.ntp.org iburst
server 2.centos.pool.ntp.org iburst
server 3.centos.pool.ntp.org iburst

stratumweight 0

driftfile /var/lib/chrony/drift

rtcsync

makestep 10 3

bindcmdaddress 127.0.0.1
bindcmdaddress ::1

keyfile /etc/chrony.keys

commandkey 1

generatecommandkey

noclientlog

logchange 0.5

logdir /var/log/chrony

allow <%= config.networks.pri.network %>/<% require 'ipaddr'; netmask=IPAddr.new(config.networks.pri.netmask.to_s).to_i.to_s(2).count('1') %><%= netmask %>
EOF
<% else -%>
cat << EOF > /etc/chrony.conf
server <%= config.ntp.server %> iburst

makestep 360 10

driftfile /var/lib/ntp/drift
EOF
<% end -%>
systemctl start chronyd
systemctl enable chronyd

# Firstrun script to correct time at system start
cat << EOF > /var/lib/firstrun/scripts/chronyfix.bash
systemctl stop chronyd
ntpdate <%= config.ntp.server %>
systemctl start chronyd
hwclock --systohc
EOF
