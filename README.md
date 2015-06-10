# oauth-rest-client

#### DESCRIPTION:
REST client helpful for submitting GET and POST queries that need to be secured using OAUTH 1.0a (by signing the http request header).


#### DEPENDENCIES: 
One must install node 'oauth-proxy' package via npm in order for this script to work (..and sign request headers using oauth 1.0a).
               Of course 'npm' tool (node package manager) must first be available prior of doing the following oauth-proxy install command.
               Npm now comes bundled with 'node' (https://nodejs.org/).

               $ npm install -g oauth-proxy
               (https://www.npmjs.com/package/oauth-proxy)




#### Usage: 
`api_rest_client.sh [-h hostname] [-p api_path] [-u full_api_url] [-k oauth_key] [-s oauth_secret] [-a accept] [-c content_type] [-d post_data]`

##### Default values for omitted/optionnal parameters:

|PARAMETER     |DEFAULT VALUE          |
|--------------|-----------------------|
|Hostname (-h) | http://localhost:8080 |
|Oauth key (-k) | appdirect-22 |
|Oauth secret (-s) | IHxwo6vKErYs2Suk |
|Accept (-a) | application/json |
|Content-type (-c) | application/json |

<br/>
###### EXAMPLES:
_______________________________________________________________________
GET example:<br/>
`api_rest_client.sh -p /api/billing/v1/paymentInstruments/746d627d-931c-4a16-9f62-34b2b4efe278`
_______________________________________________________________________
GET example:<br/>
`api_rest_client.sh -u https://dev11-clouds.devappdirect.me/api/billing/v1/paymentInstruments/1eae4581-b65c-4595-b25f-30f8dd131397 -k clouds-519 -s 123 -a application/xml`
_______________________________________________________________________
GET example:<br/>
`api_rest_client.sh -h http://localhost:8080 -p /api/hostedcheckout/transactions -k abc -s 123 -a application/xml`
_______________________________________________________________________
POST (json) example:<br/>
`api_rest_client.sh -p /api/hostedCheckout/v1/companies/a3bbfe79-074a-4dd4-97fb-2bdfe040fd25/users/82732925-6504-4581-a727-414e7b2e75af/transactions -c application/json -d '{ "token": "abc", "productId": "27", "type": "PURCHASE", "returnUrl": "http://appdirect.com" }'`