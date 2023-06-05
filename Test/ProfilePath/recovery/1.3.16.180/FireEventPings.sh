#!/bin/bash

# Copyright 2014 Google Inc. All rights reserved.
# The script sends event pings with the installation result back to
# the update server. Usage:
# FireEventPings.sh <installation archive> <ticketVersion> <isMachine> \
#     <installation return code> <extra event code> <serverURL>
# Example:
# FireEventPings.sh "/Volumes/GoogleUpdater-1.2.0.125/Keystone.tbz" \
#     1.2.0.1200 0 4 2 https://tools.google.com
# Note that in the installation image files, the script is renamed to
# .fireEventPings
if [[ $# -lt 8 ]]; then
  echo "Event pings helper called with wrong " \
       "number of arguments: $#"
  exit 1
fi
KS_INSTALLATION_ARCHIVE="${1}"
KS_TICKET_VERSION="${2}"
KS_IS_MACHINE="${3}"
KS_INSTALLATION_RETURN_CODE="${4}"
KS_EVENT_EXTRA_CODE="${5}"
KS_TICKET_SERVER_URL="${6}"
KS_INSTALLATION_STARTTIME="${7}"
KS_PING_TYPE="${8}"
# Optional arguments
KS_SESSION_ID="${9}"
KS_COHORT="${10}"
KS_COHORT_NAME="${11}"

KS_FULL_OS_VERSION=$(/usr/bin/sw_vers -productVersion)
# Extract useful version, e.g. 10.10
KS_SHORT_OS_VERSION=$(echo "${KS_FULL_OS_VERSION}" | /usr/bin/awk -F"." \
    '{print $1"."$2}')
KS_MACHINE_ARCHITECTURE=$(machine)

KS_REQUEST_ID=$(/usr/bin/uuidgen)

# Extract the archived package version. Note that awk returns 0 even if the pattern is not
# found. So we change it to return a different number after the match
KS_INSTALLING_VERSION=$(/usr/bin/tar Oxjf "${KS_INSTALLATION_ARCHIVE}" \
    GoogleSoftwareUpdate.bundle/Contents/Info.plist | \
    /usr/bin/awk -F"<|>" '/CFBundleVersion/ {getline; print $3; exit 199}')
if [[ $? -ne 199 ]]; then
  echo "Installation failed to extract the archive " \
       "version. Empty version will be reported in the event ping."
  KS_INSTALLING_VERSION="0.0.0.0"
fi

# Map the installation result to the Omaha server expectations (1 == SUCCESS)
# Also, the script does some assumptions on the version that the system
# ends up with. This logic will be improved in future iterations.
if [[ "${KS_INSTALLATION_RETURN_CODE}" -eq 0 ]]; then
  KS_INSTALLATION_RESULT=1
  KS_FINAL_VERSION="$KS_INSTALLING_VERSION"
else
  KS_INSTALLATION_RESULT=0
  KS_FINAL_VERSION="$KS_TICKET_VERSION"
fi

# Only for internal Google machines, for testing/diagnostic purposes.
# This plist file is not present on real user machines.
KS_MACHINE_INFO=/Library/Preferences/com.google.corp.machineinfo.plist
if [[ -e $KS_MACHINE_INFO ]]; then
  # Send the information below only on Google corp networks
  KS_NETWORK_DETECT=/usr/local/bin/network_detect
  if [[ -e $KS_NETWORK_DETECT ]] && \
     ( $KS_NETWORK_DETECT -p -g GNET | grep -i true ); then
    KS_USER=$(/usr/bin/defaults read $KS_MACHINE_INFO Owner)
    KS_MACHINE=$(/usr/bin/defaults read $KS_MACHINE_INFO MachineUUID)
    KS_DIAG_HEADER="X-MID: $KS_USER-{$KS_MACHINE}"
    echo "Sending Googler diagnostic information: $KS_DIAG_HEADER" | \
        /usr/bin/logger -t "GoogleSoftwareUpdate self-update"
  fi
fi

KS_INSTALLATION_ENDTIME=$(date +%s)
# This is not very reliable and may result in stderr output. Padded to milliseconds.
KS_INSTALLATION_DURATION=$((KS_INSTALLATION_ENDTIME - KS_INSTALLATION_STARTTIME))000

KS_PING_BODY="<?xml version=\"1.0\" encoding=\"UTF-8\"?> \
    <request protocol=\"3.0\" \
        version=\"KeystoneInstallScript-$KS_INSTALLING_VERSION\" \
        ismachine=\"$KS_IS_MACHINE\" requestid=\"{$KS_REQUEST_ID}\" \
        sessionid=\"{$KS_SESSION_ID}\"> \
      <os platform=\"mac\" version=\"$KS_SHORT_OS_VERSION\" \
          sp=\"$KS_FULL_OS_VERSION\" arch=\"$KS_MACHINE_ARCHITECTURE\"/> \
          <app appid=\"com.google.Keystone\" version=\"$KS_FINAL_VERSION\" \
               cohort=\"$KS_COHORT\" cohortname=\"$KS_COHORT_NAME\"> \
          <event eventtype=\"$KS_PING_TYPE\" \
            eventresult=\"$KS_INSTALLATION_RESULT\" \
            errorcode=\"$KS_INSTALLATION_RETURN_CODE\" \
            extracode1=\"$KS_EVENT_EXTRA_CODE\" \
            previousversion=\"$KS_TICKET_VERSION\" \
            nextversion=\"$KS_INSTALLING_VERSION\" \
            install_time_ms=\"$KS_INSTALLATION_DURATION\"/> \
      </app> \
    </request>"

# Log the ping request
echo "${KS_PING_BODY}" | \
    /usr/bin/logger -t "GoogleSoftwareUpdate self-update"

# Find the fallback URL: HTTP<-->HTTPS
KS_URL1=$(echo "${KS_TICKET_SERVER_URL}" | tr '[:upper:]' '[:lower:]')
if echo "${KS_URL1}" | grep "https://" > /dev/null; then
  KS_URL2=$(echo "${KS_URL1}" | /usr/bin/sed 's/https:\/\//http:\/\//')
else
  KS_URL2=$(echo "${KS_URL1}" | /usr/bin/sed 's/http:\/\//https:\/\//')
fi

# (...)& creates a fire and forget subprocess, as we ignore the return code.
# Important: ((..)) has different meaning, hence the extra spaces.
( (echo "${KS_PING_BODY}" | /usr/bin/curl -k -H "$KS_DIAG_HEADER" -d @- "${KS_URL1}" ||
   echo "${KS_PING_BODY}" | /usr/bin/curl -k -H "$KS_DIAG_HEADER" -d @- "${KS_URL2}") \
  2>&1 | /usr/bin/logger -t "GoogleSoftwareUpdate self-update" )&
