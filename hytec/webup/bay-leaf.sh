#!/bin/bash
#
# Current version:      This is set below in the version - V year mmdd
#
#
#
# Project:              Monitor and report on deployment web sites

# This:			https://everything.curl.dev/usingcurl/timeouts
#                       https://reqbin.com/req/c-70cqyayb/curl-timeout

SetSeq="Vallis-Way"
SetItt="V21.1128"
SetVersion="$SetSeq/$SetItt"

#-----------------------------------------------------------------------------------------------------------------------------------------------

#ActiveFolder="/opt/synapse/HyBox/opt/hytec"							# Dev
ActiveFolder="/opt/hytec"									# Live

ScanTIME=$(date +%Y-%m-%d:%H:%M)
DayGreet=$(date +%H)


IFS='|' && while read LINE DEPLoy; do

  # if LINE https then 12 else 11
  HSecure=${LINE:0:5}
  if echo $HSecure | grep -i -l -q "https"; then
    LINEx="${LINE:12}"										# Make https .USM/Dead domain name
  else
    LINEx="${LINE:11}"										# Make http .USM/Dead domain name
  fi
#  LINEx="${LINEx%.*}"

  OUTputFileName="$ActiveFolder/webup/$LINEx.DEAD"						# Set file name if site is down
#  LogFile1="$ActiveFolder/logs/$LINEx-logfile-$(date +'%Y-%m').csv"				# Set the logfile name for checks
#  LogFile2="$ActiveFolder/logs/$LINEx-WEB-DOWN-$(date +'%Y-%m').txt"
  LogFile1="$ActiveFolder/logs/$LINEx-logfile-$(date +'%Y-%m').csv"				# Set the logfile name for checks
  LogFile2="$ActiveFolder/logs/$LINEx-WEB-DOWN-$(date +'%Y-%m').txt"

  LINEx="${LINEx%.*}"										# Is this needed it shortens the domain name 10/25th
  SiteReport1="$ActiveFolder/logs/$LINEx-Website-email-body-$ScanTIME.txt"			# Email Attachment to report that is emailed

  STARTTime=$(date +%s.%3N)									# Start check time counter


  if curl --connect-timeout 7.00 --max-time 10 --retry 6 -I "$LINE" 2>&1| grep -w "200\|301" ; then
  # The above based on https://stackoverflow.com/questions/42873285/curl-retry-mechanism

    ENDTime=$(date +%s.%3N)									# End check time counter
    ELAPSETime=$(echo "scale=3; $ENDTime - $STARTTime" | bc)
    echo "W,$ScanTIME,$ELAPSETime,Website Up" >> $LogFile1

    if [ -f "$OUTputFileName" ]; then								# Check if the site is off line
      AlertSub="Hytec Labs: $LINE is back up!"
      source $ActiveFolder/webup/bay-leaf-em-header.sh
      echo " "
      echo "$LINE Reports as back up." >> $SiteReport1
      echo " " >> $SiteReport1
      echo "This appears to be fixed, however checking back in on the USM deployment, over the next few hours even if no more of these website down messages are received." >> $SiteReport1
      cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
      echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
      #mutt -s "$AlertSub" -- "service@1uglycrazyrobot.co.uk" < $SiteReport1
      mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
      rm -f $OUTputFileName
    fi
    rm -f $SiteReport1
  else
    if [ -f "$OUTputFileName" ]; then

      # Check again if the site is off line

      echo "Down IF route"
      GetDEADfile=$( cat $OUTputFileName )								# Read an open .dead file
      ((GetDEADfile=GetDEADfile + 1))
      echo $GetDEADfile > $OUTputFileName
      if [ $GetDEADfile -eq 2 ]; then		#send email
        echo "W,$ScanTIME,,Website down,2" >> $LogFile1							# Write to dead logfile
        AlertSub="Hytec Labs: $LINE has been down for 20 mins now"
        source $ActiveFolder/webup/bay-leaf-em-header.sh
        echo " "
        echo "$LINE is confirmed as down/offline at this time" >> $SiteReport1
        echo " " >> $SiteReport1
        echo "This looks more than a glitch and an is an IOA (Indicator of Activity)/possibly IOC, please fully check the $DEPLoy USM deployment as well as the above website, as soon as you can for signs of IOA/IOC, also update #mssaware with your findings." >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Strongly consider an investigation and/or escalation of this issue (suggest HIGH) with the client, they may or maybe not be aware their web site is off line.." >> $SiteReport1
        cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
        echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
        #mutt -s "$AlertSub" -- "test@test.com" < $SiteReport1
        mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
      elif [ $GetDEADfile -eq 13 ];then		#send email
        echo "W,$ScanTIME,,Website down,13" >> $LogFile1							# Write to dead logfile
        AlertSub="Hytec Labs: $LINE is down (4 Hrs now)"
        source $ActiveFolder/webup/bay-leaf-em-header.sh
        echo " "
        echo "$LINE Reports as still down at this time" >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Its been down four hours now, fully check the $DEPLoy USM deployment again as well as the above website, as soon as you can for signs of IOA/IOC, also update #mssaware with your findings." >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Consider chasing this for an update from the client (at least via email), if we have not heard anything this on matter." >> $SiteReport1
        cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
        echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
        #mutt -s "$AlertSub" -- "test@test.com" < $SiteReport1
        mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
      elif [ $GetDEADfile -eq 37 ];then		#send email
        echo "W,$ScanTIME,,Website down,37" >> $LogFile1							# Write to dead logfile
        AlertSub="Hytec Labs: $LINE is down (12 Hrs now)"
        source $ActiveFolder/webup/bay-leaf-em-header.sh
        echo " "
        echo "$LINE Remains down at this time" >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Please fully check the $DEPLoy USM deployment again, for signs of IOA/IOC, also update #mssaware with your findings." >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Consider chasing this for an update from the client, if we have not heard anything this on matter." >> $SiteReport1
        cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
        echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
        #mutt -s "$AlertSub" -- "test@test.com" < $SiteReport1
        mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
      elif [ $GetDEADfile -eq 73 ];then		#send email
        echo "W,$ScanTIME,,Website down,73" >> $LogFile1							# Write to dead logfile
        AlertSub="Hytec Labs: $LINE is down (its been a day now)"
        source $ActiveFolder/webup/bay-leaf-em-header.sh
        echo " "
        echo "$LINE Remains down at this time" >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Its been down for twenty four hours now, keep checking the $DEPLoy USM deployment for IOCs, also update #mssaware with your findings." >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Consider chasing for an update if we have not heard anything on matter from the client." >> $SiteReport1
        cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
        echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
        #mutt -s "$AlertSub" -- "test@test.com" < $SiteReport1
        mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
      elif [ $GetDEADfile -eq 145 ];then
        echo "W,$ScanTIME,,Website down,145" >> $LogFile1							# Write to dead logfile
        AlertSub="Hytec Labs: $LINE still down (for two days now)"
        source $ActiveFolder/webup/bay-leaf-em-header.sh
        echo " "
        echo "$LINE Reports as down at this time" >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Please keep checking the $DEPLoy USM deployment IOCs, also update #mssaware with your findings." >> $SiteReport1
        echo " " >> $SiteReport1
        cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
        echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
        #mutt -s "$AlertSub" -- "test@test.com" < $SiteReport1
        mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
      elif [ $GetDEADfile -eq 217 ];then
        echo "W,$ScanTIME,,Website down,217" >> $LogFile1							# Write to dead logfile
        AlertSub="Hytec Labs: $LINE is still down (its three days now)"
        source $ActiveFolder/webup/bay-leaf-em-header.sh
        echo " "
        echo "$LINE Reports as down at this time" >> $SiteReport1
        echo " " >> $SiteReport1
        echo "Its been down a while now, keep checking the $DEPLoy USM deployment for IOCs, also update #mssaware with any observations." >> $SiteReport1
        echo " " >> $SiteReport1
        echo "NOTE: There will be no further HyBox Bay-Leaf messages on this matter, until the confirmation that the site is back up." >> $SiteReport1
        cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
        echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
        #mutt -s "$AlertSub" -- "test@test.com" < $SiteReport1
        mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
      fi
    else
      echo "1" > $OUTputFileName
      echo "W,$ScanTIME,,Website down,1" >> $LogFile1							# Write to dead logfile


      curl -Is $LINE | head -n 1 >> $LogFile1								# Debug code.....


      AlertSub="Hytec Labs: $LINE part of the $DEPLoy USM deployment is reporting as DOWN"
      source $ActiveFolder/webup/bay-leaf-em-header.sh
      echo " "
      echo "$LINE Reports as down at this time" >> $SiteReport1
      echo " " >> $SiteReport1
      echo "This alarm is an IOA (Indicator of Activity)/possibly an IOC, please do a quick check the $DEPLoy USM deployment as well as the above website, as soon as you can for signs of IOA/IOC, also update #mssaware / #msswatch with your findings." >> $SiteReport1
      echo " " >> $SiteReport1
      echo "To note: sometimes a web site can report off line, and be fine (ie just busy), please await the next check in 20 mins, for confirmation prior to any escalation of this issue." >> $SiteReport1
      cat $ActiveFolder/webup/bay-leaf-em-footer.text >> $SiteReport1
      echo "Software Version: $SetVersion" >> $SiteReport1 && echo " " >> $SiteReport1 && echo " " >> $SiteReport1
      mutt -s "$AlertSub" -- "test@test.com" < $SiteReport1
      mutt -s "$AlertSub" -- "test@test.com" <$SiteReport1
    fi
    rm -f $SiteReport1
  fi


# DEBUG #############################################################					Checking of wget maybe better than curl

if wget --spider -S "$LINE" 2>&1 | grep -w "200\|301" ; then
  echo "DEBUG WGET says $LINE is up" >> $LogFile1
else
  echo "DEBUG WGET says $LINE is down" >> $Logfile1
  curl -Is $LINE | head -n 1 >> $LogFile1
fi

######################################################################

done < $ActiveFolder/webup/bay-leaf.db
