#!/bin/sh
# ---------------------------------------------------------------------------
# oauth_rest_client - Bash shell script that calls REST APIs (both GET and POST)
# while signing requests headers with OAUTH 1.0a.
#
# Copyright 2015, Francois Duquette <francois.duquette@appdirect.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.
#
#
#
# USAGE: simply call 'api.sh' for more info. on how to use. 
#
# DEPENDENCIES: One must install node 'oauth-proxy' package via npm in order for this script to work (..and sign request headers using oauth 1.0a). 
#               Of course 'npm' tool (node package manager) must first be available prior of doing the following oauth-proxy install command.
#               Npm now comes bundled with 'node' (https://nodejs.org/).
#
#               $ npm install -g oauth-proxy
#               (https://www.npmjs.com/package/oauth-proxy)
# ---------------------------------------------------------------------------


# Default variables values
DEFAULT_HOSTNAME=http://localhost:8080
DEFAULT_OAUTH_KEY=appdirect-22
DEFAULT_OAUTH_SECRET=IHxwo6vKErYs2Suk
DEFAULT_CONTENT=application/json
DEFAULT_ACCEPT=application/json

HOSTNAME=$DEFAULT_HOSTNAME
OAUTH_KEY=$DEFAULT_OAUTH_KEY
OAUTH_SECRET=$DEFAULT_OAUTH_SECRET
CONTENT=$DEFAULT_CONTENT
ACCEPT=$DEFAULT_ACCEPT

PROGRAM_NAME=`basename "$0"`


# Functions
printUsage () {
        echo >&2
	echo >&2 "Usage: $PROGRAM_NAME [-h hostname] [-p api_path] [-u full_api_url] [-k oauth_key] [-s oauth_secret] [-a accept] [-c content_type] [-d post_data]"
	echo >&2
	echo >&2 "Default values for omitted/optionnal parameters:"
	echo >&2 "------------------------------------------------"
	echo >&2 "Hostname (-h):     $DEFAULT_HOSTNAME"
	echo >&2 "Oauth key (-k):    $DEFAULT_OAUTH_KEY"
	echo >&2 "Oauth secret (-s): $DEFAULT_OAUTH_SECRET"
	echo >&2 "Accept (-a):       $DEFAULT_ACCEPT"
	echo >&2 "Content-type (-c): $DEFAULT_CONTENT"
	echo >&2 
	echo >&2 "GET example:"; echo >&2 "$PROGRAM_NAME -p /api/billing/v1/paymentInstruments/746d627d-931c-4a16-9f62-34b2b4efe278"; echo >&2
	echo >&2 "GET example:"; echo >&2 "$PROGRAM_NAME -u https://dev11-clouds.devappdirect.me/api/billing/v1/paymentInstruments/1eae4581-b65c-4595-b25f-30f8dd131397 -k clouds-519 -s 123 -a application/xml"; echo >&2
        echo >&2 "GET example:"; echo >&2 "$PROGRAM_NAME -h http://localhost:8080 -p /api/hostedcheckout/transactions -k abc -s 123 -a application/xml"; echo >&2
	echo >&2 "POST (json) example:"; echo >&2 "$PROGRAM_NAME -p /api/hostedCheckout/v1/companies/a3bbfe79-074a-4dd4-97fb-2bdfe040fd25/users/82732925-6504-4581-a727-414e7b2e75af/transactions -c application/json -d '{ \"token\": \"abc\", \"productId\": \"27\", \"type\": \"PURCHASE\", \"returnUrl\": \"http://appdirect.com\" }'" 
	echo >&2
}


# Parse input parameters
while [ $# -gt 0 ]
do
    case "$1" in
        -h)  HOSTNAME="$2"; shift;;
	-p)  API_PATH="$2"; shift;;
	-u)  API_REQUEST_URL="$2"; shift;;
        -c)  CONTENT="$2"; shift;;
        -a)  ACCEPT="$2"; shift;;
        -k)  OAUTH_KEY="$2"; shift;;
        -s)  OAUTH_SECRET="$2"; shift;;
        -d)  POST_DATA="$2"; shift;;
	-*)  clear; echo; echo "*** Unrecognized option \"$1\". ***"; echo;
	     printUsage
	     exit 1;;
	*)  break;;	# terminate while loop
    esac
    shift
done


# Input validation
if [[ "$API_PATH" == "" && "$API_REQUEST_URL" == "" ]]; then
        clear; echo
	echo "*** Either one of 'API PATH' (-p) or 'FULL API URL' (-u) must be provided. ***"
	echo
	printUsage
	exit 1;
fi


# Main
if [[ "$API_REQUEST_URL" == "" ]]; then
	API_REQUEST_URL=$HOSTNAME$API_PATH;
fi
HTTP_METHOD="GET"
if [[ "$POST_DATA" != "" ]]; then
        HTTP_METHOD="POST";
fi
SSL_REQUEST=no;
if [[ `echo $API_REQUEST_URL | tr '[:upper:]' '[:lower:]'` == https* ]]; then
	SSL_FLAG="--ssl";
	SSL_REQUEST=yes;
fi
API_REQUEST_PROTOCOL=`echo $API_REQUEST_URL | cut -d":" -f1 | tr '[:upper:]' '[:lower:]' | sed -e "s/https/http/"`;
API_REQUEST_URL_WITHOUT_PROTOCOL=`echo $API_REQUEST_URL | cut -d":" -f2-99`
API_REQUEST_URL=$API_REQUEST_PROTOCOL:$API_REQUEST_URL_WITHOUT_PROTOCOL

clear
echo
echo
echo "SUMMARY:"
echo "--------------------------------------------"
if [[ "$API_PATH" != "" ]]; then
	echo hostname:              $HOSTNAME
	echo api path:              $API_PATH
fi
echo effective request url: $API_REQUEST_URL
echo request over ssl:      $SSL_REQUEST
echo http-method:           $HTTP_METHOD
echo oauth key:             $OAUTH_KEY
echo oauth secret:          $OAUTH_SECRET
echo accept:                $ACCEPT
if [[ "$POST_DATA" != "" ]]; then
	echo content-type:          $CONTENT
	echo post data:             $POST_DATA
fi
echo
echo
echo "PRESS ANY KEY TO CONTINUE, or 'q' to QUIT."
read -n 1 KEY_PRESS
if [[ "$KEY_PRESS" == "q" ]]; then echo; echo "Program aborded."; echo; exit 1; fi


# FORMAT 'JSON' POST DATA
if [[ ${POST_DATA:0:1} == "{" ]]; then
	# Removes spaces between attributes, and escapes double-quotes (this is needed otherwise CURL will complains and won't send the right thing to the server..)
	POST_DATA=`echo $POST_DATA | sed -e 's/{ /{/g' | sed -e 's/: /:/g' | sed -e 's/ }/}/g' | sed -e 's/, /,/g' | sed -e 's/"/\\"/g'`
fi


# Start Oauth proxy service
# -------------------------
echo
echo "--> Starting OAUTH proxy service with 'consumer-key' = [$OAUTH_KEY] and 'consumer-secret' = [$OAUTH_SECRET]..."
oauth-proxy --consumer-key $OAUTH_KEY --consumer-secret $OAUTH_SECRET $SSL_FLAG &
OAUTH_PROXY_PID=$!
sleep 1



# CALL API through oauth proxy service
# ------------------------------------
echo
echo "--> Calling $HTTP_METHOD '$API_REQUEST_URL $POST_DATA'..."
echo "Response:"
echo
if [[ "$HTTP_METHOD" == "GET" ]]; then
	XML_OUTPUT=`curl -vsSx localhost:8001 -H "Accept: $ACCEPT" $API_REQUEST_URL`
else
	XML_OUTPUT=`curl -vsSx localhost:8001 -H "Accept: $ACCEPT" -H "Content-Type: $CONTENT" -d "$POST_DATA" $API_REQUEST_URL`
fi
echo "$XML_OUTPUT" | xmllint --format - 2>/dev/null
if [ "$?" != "0" ]; then
    if [[ ${XML_OUTPUT:0:1} == "{" ]]; then
        echo $XML_OUTPUT | python -m json.tool
    else
        echo $XML_OUTPUT
    fi
fi
echo; echo



# Kill Oauth proxy
# ----------------
kill $OAUTH_PROXY_PID

