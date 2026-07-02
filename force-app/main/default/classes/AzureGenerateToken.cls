/*
 * Token necessary to send and receive messages between Salesforce and Azure Application.
 * This is the most important, all other classes should be seen more as a way to support this one. 
 * Helpful link: https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-sas
 */ 

public with sharing class AzureGenerateToken {
    // Given the nature of the token, these are private and require getters to obtain. 
    private static String sasSignatureName;
    private static String sha256DigAlg;
    private static String hmacSha256MacAlgo;
    private static String urlEncodingScheme;
    private static String queueName;
        
    public AzureGenerateToken(String queueNm) {
        // May need to update to SHA-512 in the future.
        sasSignatureName = 'SharedAccessSignature';
        sha256DigAlg = 'SHA-256';
        hmacSha256MacAlgo = 'hmacSHA256';
        urlEncodingScheme = 'UTF-8';
        queueName = queueNm;  
    }//end AzureGenerateToken
    
    public static String generateSasToken(String resourceUri, String keyName, String key) {
        String token = 'SharedAccessSignature';
        String stringToSign = '';
        String newLine = '\n';
        //sasToken should be generated in seconds. 
        Long expiry = getEpochTime();
        String encodedResourceUri = EncodingUtil.urlEncode(resourceUri, 'UTF-8');
        encodedResourceUri = encodedResourceUri.toLowerCase();
        stringToSign = encodedResourceUri + newLine + expiry;
        
        Blob encodedKey = Crypto.generateDigest('SHA-256', Blob.valueOf(key));
        String signature = EncodingUtil.base64Encode(Crypto.generateMac('HmacSHA256', Blob.valueOf(stringToSign), Blob.valueOf(key)));
        String encodedSignature = EncodingUtil.urlEncode(signature, 'UTF-8');
        
        token += ' sr=' + encodedResourceUri;
        token += '&sig=' + encodedSignature;
        token += '&se=' + expiry;
        token += '&skn=' + keyName;
        return token;
    }//end generateSasToken
    
    public static Long getEpochTime() {
        // If needed in seconds then divide by 1000. 
        DateTime curTime = System.now();
        Long currentGmtTime = null;
        curTime = curTime.addSeconds(3600);
        Long currentGmtInMillSecs = curTime.getTime()/1000;       
        return currentGmtInMillSecs;
    }//end getEpochTime
}//end AzureGenerateToken