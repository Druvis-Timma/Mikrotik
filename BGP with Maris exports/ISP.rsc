# 2024-01-24 16:05:32 by RouterOS 7.14alpha230
# software id = DIM9-S5F8
#
# model = CCR2116-12G-4S+
# serial number = HET09EQWJT1
/interface bridge
add name=dummy_isp
/interface ethernet
set [ find default-name=ether13 ] l2mtu=1584
set [ find default-name=sfp-sfpplus1 ] l2mtu=9000 mtu=9000
/disk
add slot=RAM tmpfs-max-size=4048000000 type=tmpfs
add slot=ram3 tmpfs-max-size=11000000000 type=tmpfs
#error exporting "/figman/peer"
#error exporting "/figman/store"
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
/ip pool
add name=dhcp_pool0 ranges=192.168.88.2-192.168.88.254
/ip dhcp-server
add address-pool=dhcp_pool0 interface=ether2 name=dhcp1
/ip smb smb-user
set [ find default=yes ] disabled=yes read-only=yes
/port
set 0 name=serial0
#error exporting "/figman/connect"
#error exporting "/figman/local"
#error exporting "/figman/provide"
#error exporting "/figman/remote"
/ip firewall connection tracking
set udp-timeout=10s
/ip neighbor discovery-settings
set discover-interface-list=!dynamic
/interface ethernet switch qos tx-manager queue
set 1 use-shared-buffers=no
set 2 use-shared-buffers=no
/ip address
add address=192.168.88.1/24 interface=ether2 network=192.168.88.0
add address=172.16.2.1/30 interface=sfp-sfpplus2 network=172.16.2.0
add address=172.16.1.1/30 interface=sfp-sfpplus1 network=172.16.1.0
add address=1.2.3.4 disabled=yes interface=dummy_isp network=1.2.3.4
add address=5.6.7.8 interface=dummy_isp network=5.6.7.8
add address=1.2.3.1/24 interface=dummy_isp network=1.2.3.0
/ip dhcp-client
add add-default-route=no interface=ether1
/ip dhcp-server network
add address=192.168.88.0/24 gateway=192.168.88.1
/ip firewall address-list
add address=1.2.3.4 list=isp2_nets
add address=5.6.7.8 list=isp2_nets
/ip firewall nat
add action=src-nat chain=srcnat out-interface=ether8 src-address=192.168.0.10 \
    to-addresses=8.8.8.8
add action=dst-nat chain=dstnat dst-address=8.8.8.8 to-addresses=192.168.0.10
add action=masquerade chain=srcnat out-interface=ether1 src-address=\
    192.168.88.0/24
add action=masquerade chain=srcnat out-interface=ether1 src-address=\
    172.16.0.0/16
/ip firewall raw
add action=accept chain=output protocol=tcp
add action=drop chain=output
/ip route
add disabled=no distance=220 dst-address=172.16.11.0/30 gateway=172.16.1.2 \
    pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add disabled=no distance=220 dst-address=172.16.20.0/30 gateway=172.16.1.2 \
    pref-src="" routing-table=main scope=30 suppress-hw-offload=no \
    target-scope=10
add dst-address=172.16.12.0/30 gateway=172.16.2.2
add blackhole dst-address=192.168.88.0/24
add disabled=no dst-address=10.0.0.0/8 gateway=10.155.0.1 routing-table=main \
    suppress-hw-offload=no
/ip smb smb-share
set [ find default=yes ] directory=/pub
/routing bgp connection
add as=123 disabled=no input.filter=feed_in local.address=10.155.0.207 .role=\
    ebgp multihop=yes name=feed remote.address=10.155.101.217 routing-table=\
    main
add as=123 disabled=no input.filter=isp1_in local.role=ebgp name=to_edge1 \
    output.default-originate=always .network=isp2_nets remote.address=\
    172.16.1.2 .as=1111
add as=123 disabled=no input.filter=isp1_in local.role=ebgp name=to_edge2 \
    output.default-originate=always .filter-chain=edge2_out .network=\
    isp2_nets remote.address=172.16.2.2 .as=1111
/routing filter rule
add chain=edge2_out rule="if (dst == 5.6.7.8/32) { reject } else {accept }"
add chain=isp1_in rule="set bgp-path-peer-prepend 1 "
add chain=isp1_in rule=\
    "if (bgp-communities includes 123:10) {set bgp-local-pref 222; accept }"
add chain=isp1_in rule="accept "
add chain=feed_in rule="set gw 1.2.3.4 ; accept "
/system clock
set time-zone-name=Europe/Riga
/system identity
set name=isp
/system note
set show-at-login=no
/system package update
set channel=development
/system routerboard settings
set enter-setup-on=delete-key
