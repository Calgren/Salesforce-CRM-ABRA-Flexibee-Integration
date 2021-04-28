/**
 * @description This class defining main REST object to be used for all REST integrations.
 * This is an interface class parenting all objects to be sync via REST WS.
 *
 * @author tomaschour
 * @date 2021-04-20
 */
public interface RestMainObject {

    /**
     * @description For checking if all mandatory fields are set.
     *
     * @return String with errors
     */
    String checkMandatoryFields();

    /**
     * @description Validates length of input fields.
     *
     * @return String with errors
     */
    String validateInputs();

    /**
     * @description Gives the information out, if bulk-jobs are possible with this object.
     *
     * @return whether bulk jobs are enabled
     */
    Boolean isBulkPossible();

    /**
     * @description Return the Type of the object.
     *
     * @return Type of the object
     */
    Type getType();
}
