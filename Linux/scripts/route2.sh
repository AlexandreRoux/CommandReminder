#!/bin/sh
IPT=/sbin/iptables
WANIF=eth0
LANIF=eth1

firewall_start() { #Execute when routeur.sh start is call

$IPT -P INPUT DROP
$IPT -P FORWARD DROP
$IPT -P OUTPUT DROP

$IPT -N DEFAULT_INPUT
$IPT -N DEFAULT_OUTPUT
$IPT -A INPUT -j DEFAULT_INPUT
$IPT -A OUTPUT -j DEFAULT_OUTPUT

$IPT -A DEFAULT_INPUT -i lo -j ACCEPT
$IPT -A DEFAULT_INPUT -p icmp -j ACCEPT
$IPT -A DEFAULT_INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 122 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 80 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 443 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 25 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 587 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 993 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 137 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 138 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 139 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 445 -j ACCEPT
$IPT -A DEFAULT_INPUT -p tcp -m tcp --dport 5001 -j ACCEPT

$IPT -A DEFAULT_OUTPUT -o lo -j ACCEPT
$IPT -A DEFAULT_OUTPUT -p icmp -j ACCEPT
$IPT -A DEFAULT_OUTPUT -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT

}

firewall_stop() { #Execute when routeur.sh stop is call

                #Clear different iptables tables and RAZ of config
        $IPT -F
        $IPT -t nat -F
        $IPT -P INPUT ACCEPT
        $IPT -P FORWARD ACCEPT
        $IPT -P OUTPUT ACCEPT
}

firewall_restart() { #Execute when routeur.sh restart is call
        firewall_stop
        sleep 2
        firewall_start
}

case $1 in 'start' )
firewall_start
;;
'stop' )
firewall_stop
;;
'restart' )
firewall_restart
;;
*)
echo "usage: -bash {start|stop|restart}"
;;
esac
