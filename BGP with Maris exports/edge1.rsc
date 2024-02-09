# 2024-01-24 16:08:10 by RouterOS 7.14alpha236
# software id = S6B3-MBED
#
# model = CCR2216-1G-12XS-2XQ
# serial number = HE508HP77N0
#error exporting "/figman/peer"
#error exporting "/figman/store"
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=sfp28-1 ] auto-negotiation=no speed=10G-baseCR
/ip smb smb-user
set [ find default=yes ] disabled=yes read-only=yes
/port
set 0 name=serial0
/routing bgp template
set default as=1111 router-id=10.155.255.1
/routing ospf instance
add disabled=no name=ospf-instance-1 originate-default=if-installed
/routing ospf area
add disabled=no instance=ospf-instance-1 name=backbone
#error exporting "/figman/connect"
#error exporting "/figman/local"
#error exporting "/figman/provide"
#error exporting "/figman/remote"
/ip firewall connection tracking
set udp-timeout=10s
/ip address
add address=172.16.1.2/30 interface=sfp28-1 network=172.16.1.0
add address=172.16.11.1/30 interface=qsfp28-1-1 network=172.16.11.0
add address=10.155.255.1 interface=loopback network=10.155.255.1
add address=172.16.30.1/30 interface=qsfp28-2-1 network=172.16.30.0
/ip dns
set servers=10.155.0.1
/ip firewall address-list
add address=10.1.2.0/24 list=bgp_net
add address=10.1.3.0/24 list=bgp_net
/ip route
add distance=210 gateway=172.16.1.1
add blackhole dst-address=10.1.2.0/24
add blackhole dst-address=10.1.3.0/24
/ip smb smb-share
set [ find default=yes ] directory=/pub
/routing bgp connection
add disabled=no input.filter=isp1_in local.role=ebgp name=to_isp1 \
    output.filter-chain=isp1_out .network=bgp_net remote.address=172.16.1.1 \
    templates=default
add disabled=no local.role=ibgp name=to_edge2 remote.address=10.155.255.2 \
    templates=default
/routing filter rule
add chain=isp1_out rule=\
    "if (dst == 10.1.2.0/24) { set bgp-communities 123:10; accept }"
add chain=isp1_out rule="if (dst == 10.1.3.0/24) {accept }"
add chain=isp1_in rule=\
    "if (dst in 1.0.0.0/1) { set bgp-local-pref 200; accept }"
add chain=isp1_in rule=accept
/routing ospf interface-template
add area=backbone disabled=no networks=172.16.11.0/30
add area=backbone disabled=no networks=10.155.255.1
add area=backbone disabled=no networks=172.16.1.0/30 passive
add area=backbone disabled=no networks=172.16.30.0/30
/system clock
set time-zone-name=Europe/Riga
/system identity
set name=edge1
/system note
set show-at-login=no
/system routerboard settings
set enter-setup-on=delete-key
