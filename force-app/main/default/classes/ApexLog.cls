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
global class ApexLog {
    private static List<Application_Log__c> logsToCommit = new List<Application_Log__c>();
    /**
        A Virtual Class that Defines the
        Structure of a Log
    */
    public virtual class Log {
        public String severity;
        public String apexClass;
        public String method;

        public String recordId;
        public String message;
        public String stackTrace;
    }

    /**
        A Class that Extends the Virtual Class - Log
        to define a log of type - Error
    */
    public class Error extends Log {
        public Error(String cls, String method, String recId, Exception ex) {
            this.severity = 'ERROR';
            this.apexClass = cls;
            this.method = method;
            this.recordId = recId;
            this.message = ex.getMessage();
            this.stackTrace = ex.getStackTraceString();
        }
    }

    /**
        A Class that Extends the Virtual Class - Log
        to define a log of type - Information
    */
    public class Information extends Log {
        public Information(String cls, String method, String recId, String msg) {
            this.severity = 'INFO';
            this.apexClass = cls;
            this.method = method;
            this.recordId = recId;
            this.message = msg;
            this.stackTrace = null;
        }
    }

    /**
        A Class that Extends the Virtual Class - Log
        to define a log of type - Warning
    */
    public class Warning extends Log {
        public Warning(String cls, String method, String recId, String msg) {
            this.severity = 'WARNING';
            this.apexClass = cls;
            this.method = method;
            this.recordId = recId;
            this.message = msg;
            this.stackTrace = null;
        }
    }

    /**
        A Class that Extends the Virtual Class - Log
        to define a log of type - Debug
    */
    public class Debug extends Log {
        public Debug(String cls, String method, String recId, String msg) {
            this.severity = 'DEBUG';
            this.apexClass = cls;
            this.method = method;
            this.recordId = recId;
            this.message = msg;
            this.stackTrace = null;
        }
    }

    /**
        A Public method that can be utilized by
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
                    (Limits.getDmlRows() + logsToCommit.size() < Limits.getLimitDmlRows()) &&
                            (Limits.getDmlStatements() < Limits.getLimitDmlStatements())
                    ) {
                Application_Log__c apexDebuglog = new Application_Log__c(
                        Severity__c = logToCreate.severity,
                        Apex_Class__c = logToCreate.apexClass,
                        method__c = logToCreate.method,
                        Record_Id__c = logToCreate.recordId,
                        message__c = logToCreate.message,
                        Stack_Trace__c = logToCreate.stackTrace
                );
                logsToCommit.add(apexDebuglog);
            } else {
                System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
            }
        } catch (DmlException ex) {
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