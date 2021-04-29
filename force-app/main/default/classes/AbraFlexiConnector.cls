/**
 * @description Provides methods for connecting to Abra Flexi according to ABRA_Flexi_Data_Integration_Settings__c
 * and for data import and export
 *
 * @author  tomaschour
 * @date    2021-04-25
 */
public inherited sharing class AbraFlexiConnector {

    /**
    * @description url path to Commerce Cloud data OCAPI with version from custom settings
    */
    @TestVisible
    private static String apiUrlPath {
        get {
            return String.valueOf('/c/'
                    + (String) AbraFlexiDataIntegrationSettings.getAttributeValue(ABRA_Flexi_Data_Integration_Settings__c.Company_Name__c)
                    + '/'
            );
        }
        set;
    }

    /**
     * @description pulls selected invoice detail from ABRA Flexi by invoice id
     * @param invoiceId customer identification in SFCC
     * @return Map representing JSON response from ABRA Flexi
     */
    public static Map<String, Object> getEntityDetailById(String invoiceId) {
        HttpRequest req = RestIntegrationService.getHttpRequest(
                RestIntegrationService.HttpMethod.GET,
                null,
                null,
                'callout:ABRA_Flexi' + '/c/demo/faktura-vydana/' + invoiceId +'.json'
        );
        HttpResponse res = RestIntegrationService.callWebService(req);
        System.debug('TTT xD1 ' + res.getBody());
        Map<String, Object> customerDetailMap = RestIntegrationService.convertJsonStringUntyped(res.getBody());
        System.debug('TTT xD2 ' + customerDetailMap);
        return customerDetailMap;

    }

    /**
     * @description pulls selected invoice detail from ABRA Flexi by invoice id
     * @param invoiceId customer identification in SFCC
     * @return Map representing JSON response from ABRA Flexi
     */
    public static Map<String, Object> upsertEntities(String json, String abraEntityName) {
        HttpRequest req = RestIntegrationService.getHttpRequest(
                RestIntegrationService.HttpMethod.POST,
                json,
                null,
                'callout:ABRA_Flexi' + apiUrlPath + abraEntityName
        );
        HttpResponse res = RestIntegrationService.callWebService(req);
        System.debug('TTT xD1 ' + res.getBody());
        Map<String, Object> customerDetailMap = RestIntegrationService.convertJsonStringUntyped(res.getBody());
        System.debug('TTT xD2 ' + customerDetailMap);
        return customerDetailMap;

    }
}