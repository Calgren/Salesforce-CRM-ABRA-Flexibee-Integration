@IsTest
public class ApexLogTest {
    @IsTest
    private static void createErrorLog(){
        Test.startTest();
        try{
            Integer result = 1 / 0;
        }
        catch(Exception ex){
            new ApexLog().createLog(
                    new ApexLog.Error(
                            'ApexLogTest',
                            'createErrorLog',
                            null,
                            ex
                    )
            );

        } finally {
            ApexLog.commitLogs();
        }
        Test.stopTest();

        List<Application_Log__c> lstLogsCreated = [
                SELECT  Id, Severity__c, Apex_Class__c, Method__c
                FROM    Application_Log__c
                WHERE   Method__c = 'createErrorLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('ERROR', lstLogsCreated.get(0).Severity__c);
        System.assertEquals('ApexLogTest', lstLogsCreated.get(0).Apex_Class__c);
    }

    @IsTest
    private static void createInformationLog(){
        new ApexLog().createLog(
                new ApexLog.Information(
                        'ApexLogTest',
                        'createInformationLog',
                        null,
                        'Logging Information from an Apex Class - ApexLogTest'
                )
        );

        Test.startTest();
        ApexLog.commitLogs();
        Test.stopTest();

        List<Application_Log__c> lstLogsCreated = [
                SELECT  Id, Severity__c, Apex_Class__c, Method__c, Message__c
                FROM    Application_Log__c
                WHERE   Method__c = 'createInformationLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('INFO', lstLogsCreated.get(0).Severity__c);
        System.assertEquals('ApexLogTest', lstLogsCreated.get(0).Apex_Class__c);
        System.assertEquals('Logging Information from an Apex Class - ApexLogTest', lstLogsCreated.get(0).Message__c);
    }


    @IsTest
    private static void createDebugLog(){
        new ApexLog().createLog(
                new ApexLog.Debug(
                        'ApexLogTest',
                        'createDebugLog',
                        null,
                        'Logging Debug from an Apex Class - ApexLogTest'
                )
        );

        Test.startTest();
        ApexLog.commitLogs();
        Test.stopTest();

        List<Application_Log__c> lstLogsCreated = [
                SELECT  Id, Severity__c, Apex_Class__c, Method__c, Message__c
                FROM    Application_Log__c
                WHERE   Method__c = 'createDebugLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('DEBUG', lstLogsCreated.get(0).Severity__c);
        System.assertEquals('ApexLogTest', lstLogsCreated.get(0).Apex_Class__c);
        System.assertEquals('Logging Debug from an Apex Class - ApexLogTest', lstLogsCreated.get(0).Message__c);
    }

    @IsTest
    private static void createWarningLog(){
        new ApexLog().createLog(
                new ApexLog.Warning(
                        'ApexLogTest',
                        'createWarningLog',
                        null,
                        'Logging Warning from an Apex Class - ApexLogTest'
                )
        );

        Test.startTest();
        ApexLog.commitLogs();
        Test.stopTest();

        List<Application_Log__c> lstLogsCreated = [
                SELECT  Id, Severity__c, Apex_Class__c, Method__c, Message__c
                FROM    Application_Log__c
                WHERE   Method__c = 'createWarningLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('WARNING', lstLogsCreated.get(0).Severity__c);
        System.assertEquals('ApexLogTest', lstLogsCreated.get(0).Apex_Class__c);
        System.assertEquals('Logging Warning from an Apex Class - ApexLogTest', lstLogsCreated.get(0).Message__c);
    }
}