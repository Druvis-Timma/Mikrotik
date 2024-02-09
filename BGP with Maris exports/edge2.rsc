# 2024-01-24 16:14:35 by RouterOS 7.14alpha236
# software id = EVB5-C4FJ
#
# model = CCR2216-1G-12XS-2XQ
# serial number = HE508VRGDB7
/interface bridge
add name=loopback
/interface ethernet
set [ find default-name=qsfp28-1-2 ] auto-negotiation=no fec-mode=fec91
set [ find default-name=qsfp28-1-3 ] auto-negotiation=no fec-mode=fec91 \
    speed=25G-baseCR
set [ find default-name=qsfp28-1-4 ] auto-negotiation=no fec-mode=fec91
set [ find default-name=qsfp28-2-2 ] auto-negotiation=no fec-mode=fec91
set [ find default-name=qsfp28-2-3 ] auto-negotiation=no fec-mode=fec91 \
    speed=25G-baseCR
set [ find default-name=qsfp28-2-4 ] auto-negotiation=no fec-mode=fec91
set [ find default-name=sfp28-1 ] auto-negotiation=no fec-mode=fec91 speed=\
    10G-baseCR
set [ find default-name=sfp28-2 ] auto-negotiation=no fec-mode=fec91 speed=\
    10G-baseCR
set [ find default-name=sfp28-3 ] fec-mode=fec91
set [ find default-name=sfp28-4 ] fec-mode=fec91
set [ find default-name=sfp28-5 ] fec-mode=fec91
set [ find default-name=sfp28-6 ] fec-mode=fec91
set [ find default-name=sfp28-7 ] fec-mode=fec91
set [ find default-name=sfp28-8 ] fec-mode=fec91
set [ find default-name=sfp28-9 ] fec-mode=fec91
set [ find default-name=sfp28-10 ] fec-mode=fec91
set [ find default-name=sfp28-11 ] fec-mode=fec91
set [ find default-name=sfp28-12 ] fec-mode=fec91
#error exporting "/figman/peer"
#error exporting "/figman/store"
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip smb smb-user
set [ find default=yes ] read-only=yes
/port
set 0 name=serial0
/routing bgp template
set default as=1111 router-id=10.155.255.2
/routing ospf instance
add disabled=no name=ospf-instance-1 originate-default=if-installed
/routing ospf area
add disabled=no instance=ospf-instance-1 name=backbone
#error exporting "/figman/connect"
#error exporting "/figman/local"
#error exporting "/figman/provide"
#error exporting "/figman/remote"
/interface bridge settings
set use-ip-firewall=yes
/ip firewall connection tracking
set udp-timeout=10s
/ip address
add address=172.16.2.2/30 interface=sfp28-1 network=172.16.2.0
add address=172.16.12.1/30 interface=qsfp28-1-1 network=172.16.12.0
add address=10.155.255.2 interface=loopback network=10.155.255.2
add address=172.16.30.2/30 interface=qsfp28-2-1 network=172.16.30.0
/ip dns
set servers=10.155.0.1
/ip firewall address-list
add address=10.1.2.0/24 list=bgp_net
add address=10.1.3.0/24 list=bgp_net
/ip route
add distance=210 gateway=172.16.2.1
add blackhole dst-address=10.1.2.0/24
add blackhole dst-address=10.1.3.0/24
/routing bgp connection
add disabled=no input.filter=isp1_in local.role=ebgp name=to_isp2 \
    output.filter-chain=isp1_out .network=bgp_net remote.address=172.16.2.1 \
    templates=default
add local.role=ibgp name=to_edge1 remote.address=10.155.255.1 templates=\
    default
/routing filter rule
add chain=isp1_out rule="if (dst == 10.1.2.0/24) { accept }"
add chain=isp1_out rule=\
    "if (dst == 10.1.3.0/24) { set bgp-communities 123:10; accept }"
add chain=isp1_in rule="if (dst in 1.0.0.0/1) { accept } else { set bgp-local-\
    pref 200; accept }"
/routing ospf interface-template
add area=backbone disabled=no networks=172.16.12.1/30
add area=backbone disabled=no networks=10.155.255.2
add area=backbone disabled=no networks=172.16.2.0/24 passive
add area=backbone disabled=no networks=172.16.30.0/30
/system clock
set time-zone-name=Europe/Riga
/system identity
set name=edge2
/system note
set show-at-login=no
/system ntp client
set enabled=yes
/system ntp client servers
add address=10.155.0.1
/system package update
set channel=development
/system routerboard settings
set enter-setup-on=delete-key
