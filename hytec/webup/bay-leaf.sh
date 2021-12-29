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

# salutations function
get_greeting() {
  local greet_moment
  if (( "${DayGreet:-$(date +%H)}" >= 18 )); then
    greet_moment="evening"
  elif (( "${DayGreet:-$(date +%H)}" >= 12 )); then
    greet_moment="afternoon"
  else
    greet_moment="morning"
  fi
  printf -- 'Good %s!\n' "${greet_moment}"
}

# message body case statement
get_message_body() {

  case "${GetDEADfile}" in
    (2)
      message_body="$LINE is confirmed as down/offline at this time.
      This looks more than a glitch and is an IOA (Indicator of Activity)/possibly IOC, please fully check the $DEPLoy USM deployment as well as the above website, as soon as you can for signs of IOA/IOC, also update #mssaware with your findings.
      Strongly consider an investigation and/or escalation of this issue (suggest HIGH) with the client, they may or maybe not be aware their web site is off line..."
    ;;
    (13)
      message_body="$LINE Reports as still down at this time.
        Its been down for four hours now, fully check the $DEPLoy USM deployment again as well as the above website, as soon as you can for signs of IOA/IOC, also update #mssaware with your findings.
        Consider chasing this for an update from the client (at least via email), if we have not heard anything on this matter."
    ;;
    (37)
      message_body="$LINE Remains down at this time.
        Please fully check the $DEPLoy USM deployment again, for signs of IOA/IOC, also update #mssaware with your findings.
        Consider chasing this for an update from the client if we have not heard anything on this matter."
    ;;
    (73)
      message_body="$LINE Remains down at this time.
        Its been down for twenty four hours now, keep checking the $DEPLoy USM deployment for IOCs, also update #mssaware with your findings.
        Consider chasing this for an update from the client if we have not heard anything on this matter."
    ;;
    (145)
      message_body="$LINE Still reports as down at this time.
      Please keep checking the $DEPLoy USM deployment IOCs, also update #mssaware with your findings."
    ;;
    (217)
      message_body="$LINE Still reports as down at this time.
      Its been down a while now, keep checking the $DEPLoy USM deployment for IOCs, also update #mssaware with any observations.

      NOTE: There will be no further HyBox Bay-Leaf messages on this matter, until the confirmation that the site is back up."
    ;;
    (1)
      message_body="$LINE Reports as down at this time.
      This alarm is an IOA (Indicator of Activity)/possibly an IOC, please do a quick check the $DEPLoy USM deployment as well as the above website, as soon as you can for signs of IOA/IOC, also update #mssaware / #msswatch with your findings.
      To note: sometimes a web site can report off line, and be fine (ie just busy), please await the next check in 20 mins, for confirmation prior to any escalation of this issue."
  esac
  printf "$message_body"
}

# print message heredoc
print_message() {
cat << EOF
$(get_greeting)
$(get_message_body)

Regards


Bay-Leaf
(in beta)


Software Version: $SetVersion


EOF
}

# Write logfile function
write_logfile() {
  printf -- 'W,%s,,Website down,%s\n' "${ScanTIME}" "${1}" >> "${LogFile1}"
}

IFS='|' && while read -r LINE DEPLoy; do

  # if LINE https then 12 else 11
  HSecure=${LINE:0:5}
  if echo "$HSecure" | grep -i -l -q "https"; then
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
    echo "W,$ScanTIME,$ELAPSETime,Website Up" >> "$LogFile1"

    if [ -f "$OUTputFileName" ]; then								# Check if the site is off line
      AlertSub="Hytec Labs: $LINE is back up!"
      printf 
      "$(get_greeting)
      $LINE Reports as back up.\n
      This appears to be fixed, however, check back in on the USM deployment over the next few hours even if no more of these website down messages are received.\n\n
      Regards\n\n\n
      Bay-Leaf\n
      (in beta)\n\n\n
      Software Version: $SetVersion\n\n\n" >> "$SiteReport1"
      #mutt -s "$AlertSub" -- "service@1uglycrazyrobot.co.uk" < $SiteReport1
      mutt -s "$AlertSub" -- "test@test.com" <"$SiteReport1"
      rm -f "$OUTputFileName"
    fi
    rm -f "$SiteReport1"
  else
    if [ -f "$OUTputFileName" ]; then

      # Check again if the site is off line

      echo "Down IF route"
      GetDEADfile=$( cat "$OUTputFileName" )								# Read an open .dead file
      ((GetDEADfile=GetDEADfile + 1))
      echo $GetDEADfile > "$OUTputFileName"
      case "${GetDEADfile}" in                             # Send Mail
          (2)
            write_logfile "${GetDEADfile}"						   	# Write to dead logfile
            AlertSub="20 mins now"
            #mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            ;;
          (13)
            write_logfile "${GetDEADfile}"						   	# Write to dead logfile
            AlertSub="4 Hrs now"            
            #mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            ;;
          (37)
            write_logfile "${GetDEADfile}"						   	# Write to dead logfile
            AlertSub="12 Hrs now"
            #mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            ;;
          (73)
            write_logfile "${GetDEADfile}"						   	# Write to dead logfile
            AlertSub="1 day now"
            #mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            ;;
          (145)
            write_logfile "${GetDEADfile}"						   	# Write to dead logfile
            AlertSub="2 days now"
            #mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            ;;
          (217)
            write_logfile "${GetDEADfile}"						   	# Write to dead logfile
            AlertSub="3 days now"
            #mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            mutt -s "Hytec Labs: ${line} is down (${AlertSub})" -- "test@test.com" < <(print_message)
            ;;
      esac
    else
      echo "1" > "$OUTputFileName"
      write_logfile "${GetDEADfile}"                      # Write to dead logfile
      curl -Is "$LINE" | head -n 1 >> "$LogFile1"								# Debug code.....
      AlertSub="$LINE part of the $DEPLoy USM deployment is reporting as DOWN"
      #mutt -s "Hytec Labs: (${$AlertSub})" -- "test@test.com" < <(print_message)
      mutt -s "Hytec Labs: (${$AlertSub})" -- "test@test.com" < <(print_message)
    fi
  fi


# DEBUG #############################################################					Checking of wget maybe better than curl

if wget --spider -S "$LINE" 2>&1 | grep -w "200\|301" ; then
  echo "DEBUG WGET says $LINE is up" >> "$LogFile1"
else
  echo "DEBUG WGET says $LINE is down" >> "$LogFile1"
  curl -Is "$LINE" | head -n 1 >> "$LogFile1"
fi

######################################################################

done < $ActiveFolder/webup/bay-leaf.db
