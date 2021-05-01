/**
 * @description Provides methods for connecting to Abra Flexi according to ABRA_Flexi_Data_Integration_Settings__c
 * and for data import and export
 *
 * @author  tomaschour
 * @date    2021-04-25
 */
public inherited sharing class AbraFlexiConnector {

    /**
    * @description url path to Abra Flexi REST API with company from custom settings
    */
    @TestVisible
    private static String apiUrlPath {
        get {
            if (apiUrlPath == null) {
                apiUrlPath = String.valueOf('/c/'
                        + (String) AbraFlexiDataIntegrationSettings.getAttributeValue(ABRA_Flexi_Data_Integration_Settings__c.Company_Name__c)
                        + '/'
                );
            }
            return apiUrlPath;
        }
        set;
    }

    /**
     * @description pulls selected invoice detail from ABRA Flexi by invoice id
     * @param body customer identification in SFCC
     * @return Map representing JSON response from ABRA Flexi
     */
    public static Map<String, Object> upsertEntities(String body, String abraEntityName) {
        HttpRequest req = RestIntegrationService.getHttpRequest(
                RestIntegrationService.HttpMethod.POST,
                body,
                null,
                'callout:ABRA_Flexi' + apiUrlPath + abraEntityName
        );
        HttpResponse res = RestIntegrationService.callWebService(req);
        Map<String, Object> customerDetailMap = RestIntegrationService.convertJsonStringUntyped(res.getBody());
        return customerDetailMap;

    }

    public static List<Dom.XmlNode> getImportSchema(String abraEntityName) {
        HttpRequest req = RestIntegrationService.getHttpRequest(
                RestIntegrationService.HttpMethod.GET,
                null,
                null,
                'callout:ABRA_Flexi' + apiUrlPath + abraEntityName + '/schema-import.xsd'
        );
        HttpResponse res = RestIntegrationService.callWebService(req);
        Dom.Document doc = res.getBodyDocument();
        String ns = XmlUtils.ABRA_XSD_NAMESPACE;
        //Retrieve the root element for this document.
        Dom.XmlNode root = doc.getRootElement();
        Map<String, String> tempMap = new Map<String, String>();
        Dom.XmlNode elementNode = root.getChildElement('element', ns).getChildElement('complexType', ns).getChildElement('sequence', ns);
        List<Dom.XmlNode> entitiesNodes = elementNode.getChildElements();
        return entitiesNodes;
    }
}