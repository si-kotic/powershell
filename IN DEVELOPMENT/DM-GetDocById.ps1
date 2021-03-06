Function DM-GetDocByID {
Param (
$dmServer = 'vmdev2k3gold1',
$dmPort = '80',
$dmUser = 'admin',
$dmPassword = 'password',
$docID = '631360195075'
)
<#
$soapReq = [xml]@"
<soapenv:Envelope xmlns:doc='http://efstech.com/integration_v2_1/endpoint/document' xmlns:dow='http://efstech.com/integration_v2_1/model/download' xmlns:soapenv='http://schemas.xmlsoap.org/soap/envelope/'>
   <soapenv:Header><wsse:Security soapenv:mustUnderstand='1' xmlns:wsse='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd' xmlns:wsu='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd'><wsse:UsernameToken wsu:Id='UsernameToken-5'><wsse:Username></wsse:Username><wsse:Password Type='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText'>$dmPassword</wsse:Password><wsse:Nonce EncodingType='http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary'>rztIkME5/SPywVtnIgR4ug==</wsse:Nonce><wsu:Created>2014-12-19T20:18:21.559Z</wsu:Created></wsse:UsernameToken></wsse:Security></soapenv:Header>
   <soapenv:Body>
      <doc:GetById>
         <doc:id>631360195075</doc:id>
      </doc:GetById>
   </soapenv:Body>
</soapenv:Envelope>
"@
#>
$soapReq = [xml]@'
<soapenv:Envelope xmlns:doc="http://efstech.com/integration_v2_1/endpoint/document" xmlns:dow="http://efstech.com/integration_v2_1/model/download" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
   <soapenv:Header><wsse:Security soapenv:mustUnderstand="1" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><wsse:UsernameToken wsu:Id="UsernameToken-1"><wsse:Username>admin</wsse:Username><wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">password</wsse:Password><wsse:Nonce EncodingType="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary">g26F49EWlU85UFyUMCAJnw==</wsse:Nonce><wsu:Created>2014-12-19T21:46:12.465Z</wsu:Created></wsse:UsernameToken></wsse:Security></soapenv:Header>
   <soapenv:Body>
      <doc:GetById>
         <doc:id>631360195075</doc:id>
      </doc:GetById>
   </soapenv:Body>
</soapenv:Envelope>
'@

$soapReq.Envelope.Body.GetById.id = $docID
$soapReq.Envelope.Header.Security.UsernameToken.Username = 'admin'

$dmUrl = 'http://' + $dmServer + ':' + $dmPort + '/pdmwebsvc-v2.1/document'

<#
POST http://vmdev2k3gold1/pdmwebsvc-v2.1/document HTTP/1.1
Accept-Encoding: gzip,deflate
Content-Type: multipart/related; type='application/xop+xml'; start='<rootpart@soapui.org>'; start-info='text/xml'; boundary='----=_Part_4_18493329.1419016851719'
SOAPAction: 'http://efstech.com/integration_v2_1/document/read/byId'
MIME-Version: 1.0
Content-Length: 1302
Host: vmdev2k3gold1
Connection: Keep-Alive
User-Agent: Apache-HttpClient/4.1.1 (java 1.5)
#>

$soapWebRequest = [System.Net.WebRequest]::Create($dmUrl)
$soapWebRequest.Headers.Add("SOAPAction","`"http://efstech.com/integration_v2_1/document/read/byId`"")
$soapWebRequest.UserAgent = "Apache-HttpClient/4.1.1 (java 1.5)"
$soapWebRequest.ContentType = "multipart/related; type='application/xop+xml'; start='<rootpart@soapui.org>'; start-info='text/xml'; boundary='----=_Part_4_18493329.1419016851719'"
$soapWebRequest.Accept = "gzip,deflate" #"text/xml" 
$soapWebRequest.Method = "POST" 
#$soapWebRequest.ContentLength = "1302"

$requestStream = $soapWebRequest.GetRequestStream() 
$soapReq.Save($requestStream) 
$requestStream.Close()

Try {
	$resp = $soapWebRequest.GetResponse()
	}
Catch [System.Net.WebException] {
	$resp = $_.Exception
	Return $resp
}
$responseStream = $resp.GetResponseStream()
$soapReader = [System.IO.StreamReader]($responseStream)
$ReturnXml = [Xml] $soapReader.ReadToEnd()
$responseStream.Close()

return $ReturnXml


}