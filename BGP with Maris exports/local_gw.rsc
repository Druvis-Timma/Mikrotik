# 2024-01-24 16:15:34 by RouterOS 7.14alpha236
# software id = QD8D-QJ2D
#
# model = CCR2216-1G-12XS-2XQ
# serial number = HE508ZHZSHB
/interface bridge
add name=dummy
#error exporting "/figman/peer"
#error exporting "/figman/store"
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip smb smb-user
set [ find default=yes ] disabled=yes read-only=yes
/port
set 0 name=serial0
/routing ospf instance
add disabled=no name=ospf-instance-1
/routing ospf area
add disabled=no instance=ospf-instance-1 name=backbone
#error exporting "/figman/connect"
#error exporting "/figman/local"
#error exporting "/figman/provide"
#error exporting "/figman/remote"
/ip firewall connection tracking
set udp-timeout=10s
/ip address
add address=172.16.11.2/30 interface=qsfp28-2-1 network=172.16.11.0
add address=172.16.12.2/30 interface=qsfp28-1-1 network=172.16.12.0
add address=172.16.20.1/30 interface=sfp28-1 network=172.16.20.0
add address=10.1.2.100/25 interface=dummy network=10.1.2.0
add address=10.1.3.200 interface=dummy network=10.1.3.200
/ip dns
set servers=10.155.0.1
/ip route
add distance=220 gateway=172.16.11.1
/ip smb smb-share
set [ find default=yes ] directory=/pub
/routing ospf interface-template
add area=backbone disabled=no networks=172.16.11.0/30
add area=backbone disabled=no networks=172.16.12.0/30
add area=backbone disabled=no networks=10.1.2.0/24
add area=backbone disabled=no networks=10.1.3.0/24
/system clock
set time-zone-name=Europe/Riga
/system identity
set name=local_gw
/system note
set show-at-login=no
/system package update
set channel=development
/system routerboard settings
set enter-setup-on=delete-key
