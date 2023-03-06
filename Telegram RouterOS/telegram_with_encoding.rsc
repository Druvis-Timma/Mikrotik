:global GoDaddyRootCA "-----BEGIN CERTIFICATE-----\nMIIDxTCCAq2gAwIBAgIBADANBgkqhkiG9w0BAQsFADCBgzELMAkGA1UEBhMCVVMx\nEDAOBgNVBAgTB0FyaXpvbmExEzARBgNVBAcTClNjb3R0c2RhbGUxGjAYBgNVBAoT\nEUdvRGFkZHkuY29tLCBJbmMuMTEwLwYDVQQDEyhHbyBEYWRkeSBSb290IENlcnRp\nZmljYXRlIEF1dGhvcml0eSAtIEcyMB4XDTA5MDkwMTAwMDAwMFoXDTM3MTIzMTIz\nNTk1OVowgYMxCzAJBgNVBAYTAlVTMRAwDgYDVQQIEwdBcml6b25hMRMwEQYDVQQH\nEwpTY290dHNkYWxlMRowGAYDVQQKExFHb0RhZGR5LmNvbSwgSW5jLjExMC8GA1UE\nAxMoR28gRGFkZHkgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgLSBHMjCCASIw\nDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL9xYgjx+lk09xvJGKP3gElY6SKD\nE6bFIEMBO4Tx5oVJnyfq9oQbTqC023CYxzIBsQU+B07u9PpPL1kwIuerGVZr4oAH\n/PMWdYA5UXvl+TW2dE6pjYIT5LY/qQOD+qK+ihVqf94Lw7YZFAXK6sOoBJQ7Rnwy\nDfMAZiLIjWltNowRGLfTshxgtDj6AozO091GB94KPutdfMh8+7ArU6SSYmlRJQVh\nGkSBjCypQ5Yj36w6gZoOKcUcqeldHraenjAKOc7xiID7S13MMuyFYkMlNAJWJwGR\ntDtwKj9useiciAF9n9T521NtYJ2/LOdYq7hfRvzOxBsDPAnrSTFcaUaz4EcCAwEA\nAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYE\nFDqahQcQZyi27/a9BUFuIMGU2g/eMA0GCSqGSIb3DQEBCwUAA4IBAQCZ21151fmX\nWWcDYfF+OwYxdS2hII5PZYe096acvNjpL9DbWu7PdIxztDhC2gV7+AJ1uP2lsdeu\n9tfeE8tTEH6KRtGX+rcuKxGrkLAngPnon1rpN5+r5N9ss4UXnT3ZJE95kTXWXwTr\ngIOrmgIttRD02JDHBHNA7XIloKmf7J6raBKZV8aPEjoJpL1E/QYVN8Gb5DKj7Tjo\n2GTzLH4U/ALqn83/B2gX2yKQOC16jdFU8WnjXzPKej17CuPKf1855eJ1usV2GDPO\nLPAvTK33sefOT6jEm0pUBsV/fdUID+Ic/n4XuKxe9tQWskMJDE32p2u0mYRlynqI\n4uJEvlz36hz1\n-----END CERTIFICATE-----"
/file print file=GoDaddyRootCA
:delay 1
/file set GoDaddyRootCA.txt contents=$GoDaddyRootCA
/certificate import file-name=GoDaddyRootCA.txt passphrase=""
/system script add name=telegram3 source={
:local lastUpdateID 0
:local botToken "0000000000:OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
:local userID "0000000000"
:local SEND do={
    :put $3
    /tool fetch url="https://api.telegram.org/bot$1/sendmessage?chat_id=$2&text=$3" output=user check-certificate=yes
    }
$SEND $botToken $userID "Telegram script initiated."
:local loops 0
:while (true) do={
  :put ("Loop nr ".$loops)
  :local data ([/tool fetch url="https://api.telegram.org/bot$botToken/getUpdates?offset=$lastUpdateID" output=user check-certificate=yes as-value]->"data")
  :local start 0
  :local end 0
  :set start ([:find $data "["]+1)
  :set end ([:len $data]-2)
  :set data [:pick $data $start $end]
  :local updates [:toarray ($data)]
  :local command ""
  :foreach update in=$updates do={
      :set $update ([:toarray $update])
      :local thisUpdateID [:pick ($update->1) 1 [:len ($update->1)]]
      :if ($thisUpdateID > $lastUpdateID) do={
          :put "New update!"
          :put ("ID: ".$thisUpdateID)
          :set lastUpdateID $thisUpdateID
          :local message ($update->5)
          :put $message
          :local marray [:toarray $message]
          :local trusted false
          :if (loops != 0) do={
              :for i from=0 to=([:len $marray]-1) do={
                  :if (($marray->$i) = "from") do={
                      :local sender ([:toarr ($marray->([:tonum $i]+2))]->1)
                      :set sender [:pick $sender 1 [:len $sender]]
                      :if (sender = $userID) do={:set trusted true;}
                  }
                  :if (($marray->$i) = "text") do={
                      :local val ($marray->([:tonum $i]+2))
                      :if ($trusted = true) do={
                          :set command $val
                      }
                  }
              }
          }
      }
  }
  :if ([:len $command] > 0) do={
      $SEND $botToken $userID ("Received: $command")
      :local fun ([:execute $command as-string])
      #The as-string parameter has been introduced from v7.8
      :local funlength ([:len $fun]-1)
      :local encodedOutput ""
      :for i from= 0 to= $funlength do={
          :local char [:pick $fun $i]
          :if ($char = " " || $char = "#" || $char = "\r") do={:set char "%20"}
          :if ($char = "\n") do={:set char "%0A%0D"}
          :set encodedOutput ($encodedOutput.$char)
      }
      $SEND $botToken $userID $encodedOutput
  }
  :set loops (loops+1)
  :delay 5;
}
}
