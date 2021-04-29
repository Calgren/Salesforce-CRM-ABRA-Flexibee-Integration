/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-29
 */
public with sharing class XmlUtils {
    public static final String ABRA_XSD_NAMESPACE = 'http://www.w3.org/2001/XMLSchema';

    public static AbraEntityDefinitionDto getEntityDefinitionFromXsd(List<Dom.XmlNode> entitiesNodes, String abraEntityName) {
        AbraEntityDefinitionDto dto = new AbraEntityDefinitionDto(abraEntityName);
        for(Dom.XmlNode entityNode : entitiesNodes) {
            if(entityNode.getAttribute('name', null) == abraEntityName){
                Dom.XmlNode sequenceNode = entityNode.getChildElement('complexType', ABRA_XSD_NAMESPACE).getChildElement('sequence', ABRA_XSD_NAMESPACE);
                List<Dom.XmlNode> attributeNodes = sequenceNode.getChildElements();
                for(Dom.XmlNode xnv : attributeNodes){
                    if (xnv.getChildElement('annotation', ABRA_XSD_NAMESPACE) != null
                            && xnv.getChildElement('annotation', ABRA_XSD_NAMESPACE)
                            .getChildElement('documentation', ABRA_XSD_NAMESPACE) != null) {
                        dto.abraEntityAttributes.put(xnv.getAttribute('name', null),
                                xnv.getChildElement('annotation', ABRA_XSD_NAMESPACE)
                                        .getChildElement('documentation', ABRA_XSD_NAMESPACE)
                                        .getText());
                    }
                }
                break;
            }
        }
        return dto;
    }


    public class AbraEntityDefinitionDto {
        @AuraEnabled public String abraEntityName;
        @AuraEnabled public Map<String, String> abraEntityAttributes;

        public AbraEntityDefinitionDto(String abraEntityName) {
            this.abraEntityName = abraEntityName;
            abraEntityAttributes = new Map<String, String>();
        }
    }

}