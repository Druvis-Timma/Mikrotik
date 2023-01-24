/system script add name=telegram source={
:local lastUpdateID 0;
:local botToken "0000000000:OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO";
:local userID 0000000000
:local SEND do={
    :put $3
    /tool fetch url="https://api.telegram.org/bot$1/sendmessage?chat_id=$2&text=$3" output=user
}
$SEND $botToken $userID "Telegram script initiated."
:local loops 0
:while (true) do={
    :put ("Loop nr ".$loops)
    :local data ([/tool fetch url="https://api.telegram.org/bot$botToken/getUpdates?offset=$lastUpdateID" output=user as-value;]->"data")
    :local start 0
    :local end 0
    :set start ([:find $data "["]+1)
    :set end ([:len $data]-2)
    :set data [:pick $data $start $end]
    :local updates [:toarray ($data)];
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
            :local trusted false;
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
        :local fun ([:system ssh-exec 0.0.0.0 $command as-value]->"output");
        :local loop true
        :while ($loop) do={
            :local hash [:find $fun "#"]
            :if ($hash !=0 && $hash<1) do={
                :set loop false
                } else={
                    :set $fun ("$[:pick $fun 0 $hash]"."$[:pick $fun ($hash+1) ([:len $fun])]")
                    :put "Hashtag removed!"
                    :put $fun
                }
        }
        :while ([:len $fun]>3) do={
            :local lenght [:len $fun]
            :local newline [:find $fun "\n"]
            :local line [:pick $fun 0 ($newline-1)]
            :set fun [:pick $fun ($newline+1) $lenght]
            $SEND $botToken $userID $line
        }
    }
    :set loops (loops+1)
    :delay 5;
}
}