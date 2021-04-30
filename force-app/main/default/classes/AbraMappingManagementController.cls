/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-30
 */
public with sharing class AbraMappingManagementController {

    @AuraEnabled
    public static List<MappingDto> getCurrentMappings(String abraEntityName) {
        List<MappingDto> dtos = new List<MappingDto>();
        Map<String, ABRA_Flexi_Data_Mapping__mdt> mappings = IntegrationSObjectUtils.getAllMappingsByAbraAttributeName(abraEntityName);
        for(ABRA_Flexi_Data_Mapping__mdt mapping : mappings.values()) {
            dtos.add(new MappingDto(mapping));
        }
        return dtos;
    }

    public class MappingDto{
        @AuraEnabled public Id recordId;
        @AuraEnabled public String sfscSObjectName;
        @AuraEnabled public String abraEntityApiName;
        @AuraEnabled public String sfscFieldName;
        @AuraEnabled public String abraFieldName;
        @AuraEnabled public Boolean sfscToAbraSync;
        @AuraEnabled public Boolean abraToSfscSync;
        @AuraEnabled public String ident;

        public MappingDto(ABRA_Flexi_Data_Mapping__mdt mapping) {
            this.recordId = mapping.Id;
            this.sfscSObjectName = mapping.SFSC_SObject_Name__c;
            this.abraEntityApiName = mapping.ABRA_Flexi_Entity_Name__c;
            this.sfscFieldName = mapping.SFSC_Field_Name__c;
            this.abraFieldName = mapping.ABRA_Flexi_Field_Name__c;
            this.sfscToAbraSync = mapping.SFSC_To_ABRA_Flexi_Sync__c;
            this.abraToSfscSync = mapping.ABRA_Flexi_To_SFSC_Sync__c;
            this.ident = mapping.Id;
        }
    }

}