/**
 * Description: This Apex Class exposes method(s) that can be utilized by
 * other Apex Classes to create Persistent Logs of type Error or
 * Information as opposed to native Debug Logs.
 *
 * Created By: Mayank S.
 *
 * Created Date: Oct 30, 2015
 *
 * Revisions: NIL
*/
global class ApexDebugLog {
    private static List<Apex_Debug_Log__c> logsToCommit = new List<Apex_Debug_Log__c>();
    /**
        A Virtual Class that Defines the
        Structure of a Log
    */
    public virtual class Log {
        public String Type;
        public String ApexClass;
        public String Method;

        public String RecordId;
        public String Message;
        public String StackTrace;
    }

    /**
        A Class that Extends the Virtual Class - Log
        to define a log of type - Error
    */
    public class Error extends Log {
        public Error(String cls, String routine, String recId, Exception ex) {
            this.Type = 'Error';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = ex.getMessage();
            this.StackTrace = ex.getStackTraceString();
        }
    }

    /**
        A Class that Extends the Virtual Class - Log
        to define a log of type - Information
    */
    public class Information extends Log {
        public Information(String cls, String routine, String recId, String msg) {
            this.Type = 'Information';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = msg;
            this.StackTrace = NULL;
        }
    }

    /**
        A Public Method that can be utilized by
        other Apex Classes to create a record into
        the Apex Debug Log object stating the Error
        or Information.
    */
    public void createLog(Log logToCreate) {
        try {
            /**
                Ensure that we're well within the Governor Limits.
                The creation of the Log shouldn't disturb the execution
                of that Apex Class that utilizes this method to
                create a log.
            */
            if (
                    (Limits.getDMLRows() < Limits.getLimitDMLRows()) &&
                            (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
                    ) {
                Apex_Debug_Log__c apexDebuglog = new Apex_Debug_Log__c(
                        Type__c = logToCreate.Type,
                        Apex_Class__c = logToCreate.ApexClass,
                        Method__c = logToCreate.Method,
                        Record_Id__c = logToCreate.RecordId,
                        Message__c = logToCreate.Message,
                        Stack_Trace__c = logToCreate.StackTrace
                );
                logsToCommit.add(apexDebuglog);
            } else {
                System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
            }
        } catch (DMLException ex) {
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }

    /**
     * @description commits all logs from into database
     *
     * @author tomaschour
     * @date 2021-04-29
     */
    public static void commitLogs() {
        Database.insert(logsToCommit, false);
    }
}