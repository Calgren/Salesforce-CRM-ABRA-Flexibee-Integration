/**
 * 
 *
 * @author  tomaschour - Aspectworks
 * @date    2021-04-28
 */
public interface AbraSynchronizationInterface {

    /**
     * @description TODO
     *
     * @param objId Id of object to synchronize
     */
    void exportRecords(List<SObject> records, Map<String, Object> params);
}