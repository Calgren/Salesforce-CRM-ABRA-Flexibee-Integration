/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-28
 */
public with sharing class Exceptions {

    /**
     * @description Thrown to indicate there is an incorrect value set in settings.
     *
     * @author tomaschour
     * @date 2018-04-22
     */
    public with sharing class BadConfigurationException extends Exception {
    }

    /**
     * @description Thrown to indicate that received data are in an incorrect state or format.
     *
     * @author tomaschour
     * @date 2018-04-22
     */
    public with sharing class BadDataException extends Exception {
    }

    /**
     * @description REST integration exception to be thrown in case of errors.
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public with sharing class RestIntegrationServiceException extends Exception {
    }
}