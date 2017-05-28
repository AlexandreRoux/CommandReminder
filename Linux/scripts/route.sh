#!/bin/sh
IPT=/sbin/iptables
WANIF=eth0
LANIF=eth1

firewall_start() { #Execute when routeur.sh start is call

                #==================== INPUT ===================
        #Rules that belong to incoming packets
        #All go out can go inside again
        $IPT -A INPUT -i $WANIF -m state --state ESTABLISHED,RELATED -j ACCEPT

        #Ports opening from WAN (22 and Samba)
        $IPT -A INPUT -i $WANIF -p tcp --dport 22 -j ACCEPT
        $IPT -A INPUT -i $WANIF -p tcp --match multiport --dports 137,138,139,445 -j ACCEPT
        #Protocols WAN
        $IPT -A INPUT -i $WANIF -p icmp -j ACCEPT

        #All open for incoming packets on LAN (Have to test, normally used for DHCP and DNS)
        $IPT -A INPUT -i $LANIF -j ACCEPT

                #All that does not MATCH the above rules are DROP
        $IPT -P INPUT DROP


                #==================== NAT ===================
        #Those rules are used to rewritting NAT address

                #All that crossed the router and go out by WAN will be NAT
        $IPT -A POSTROUTING -t nat -o $WANIF -j MASQUERADE


                #================== PORT FORWARD ================
        #Those rules are used to forward connexion based on port from WANeth0 to LAN IP machine
        $IPT -A PREROUTING -t nat -j DNAT -i $WANIF -p tcp -d 10.0.0.1 --dport 80 --to-destination 10.0.0.201:80
        $IPT -A PREROUTING -t nat -j DNAT -i $WANIF -p tcp -d 10.0.0.1 --dport 33891 --to-destination 10.0.0.202:3389
        $IPT -A PREROUTING -t nat -j DNAT -i $WANIF -p tcp -d 10.0.0.1 --dport 33892 --to-destination 10.0.0.203:3389
        $IPT -A PREROUTING -t nat -j DNAT -i $WANIF -p tcp -d 10.0.0.1 --dport 33893 --to-destination 10.0.0.204:3389

                #=================== FORWARD ===================
        #Those rules apply to the packet that cross the router

                #IF (GO IN from WAN) && (GO OUT from LAN) && (state == RESPONSE) IS ACCEPT to cross router
        $IPT -A FORWARD -i $WANIF -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

                #IF (GO OUT from LAN) IS ACCEPT to cross router
        $IPT -A FORWARD -i $LANIF -j ACCEPT

                #Rules for XenApp VDA on port 1494 and 2598 and StoreFront on 80
        $IPT -A FORWARD -i $WANIF -p tcp --match multiport --dport 2598,1494 -d 10.0.0.200 -j ACCEPT
        $IPT -A FORWARD -i $WANIF -p tcp --dport 80 -d 10.0.0.201 -j ACCEPT

                #Rules to remote connect to the servers
        $IPT -A FORWARD -i $WANIF -p tcp --dport 3389 -j ACCEPT

                #ALL that does not MATCH the above rules are DROP
        $IPT -P FORWARD DROP

}

firewall_stop() { #Execute when routeur.sh stop is call

                #Clear different iptables tables and RAZ of config
        $IPT -F
        $IPT -t nat -F
        $IPT -P INPUT ACCEPT
        $IPT -P FORWARD ACCEPT
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
