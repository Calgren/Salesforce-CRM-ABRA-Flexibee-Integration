/**
 * @description A class to handle REST API callouts.
 *
 * @author tomaschour
 * @date 2021-04-20
 */
public without sharing class RestIntegrationService {

    //private final static awsp.Logger LOG = awsp.LoggerFactory.getLogger(RestIntegrationService.class);

    private static final Integer CALLOUT_MAX_TIMEOUT_MS = 120000;
    @TestVisible
    private static final String INVALID_INFO = 'Can not generate a Request-Object with missing information.';
    @TestVisible
    private static final String UNSUPPORTED_HTTP_METHOD = 'Request-Method is not supported: ';
    @TestVisible
    private static final String POST_METHOD_NO_BODY = 'The Request-Method POST requires a Request-Body.';
    @TestVisible
    private static final String NO_REQUEST = 'No request found to send.';
    @TestVisible
    private static final String NO_OBJECT_OR_JSON = 'Object Type or String to parse not found!';
    @TestVisible
    private static final String MALFORMED_JSON = 'The JSON string is malformed: ';
    @TestVisible
    private static final Map<String, String> DEFAULT_HEADERS = new Map<String, String>{
            'Content-Type' => 'application/json;charset=UTF-8',
            'Connection' => 'keep-alive'
    };
    public enum HttpMethod {
        POST, GET
    }

    /**
     * @description REST integration exception to be thrown in case of errors.
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public with sharing class RestIntegrationServiceException extends Exception {
    }

    /**
     * @description A method to convert Objects to JSON string.
     *
     * @param apiObjects to be converted
     *
     * @return String with JSON
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static String convertObjectsToJsonString(List<RestMainObject> apiObjects) {
        // Checking first if the list contains only one object
        if (apiObjects == null || apiObjects.isEmpty() || (apiObjects.size() > 1 && !apiObjects.get(0).isBulkPossible())) {
            throw new RestIntegrationServiceException('List of RestMainObject is not allowed. The size is: '
                    + (apiObjects == null ? 0 : apiObjects.size()));
        }

        // If the size is ok, than we must check, if the mandatory fields are set
        for (Integer i = 0; i < apiObjects.size(); i++) {
            String missingMandatoryInformation = apiObjects.get(i).checkMandatoryFields();
            if (String.isNotBlank(missingMandatoryInformation)) {
                throw new RestIntegrationServiceException('Missing mandatory information: ' + missingMandatoryInformation + ' on record ' + i);
            }
        }

        // We need to check for validity of data types.
        for (Integer i = 0; i < apiObjects.size(); i++) {
            String validationOutput = apiObjects.get(i).validateInputs();
            if (String.isNotBlank(validationOutput)) {
                throw new RestIntegrationServiceException(validationOutput + ' on record ' + i);
            }
        }

        // Generate the JSON-String.
        return JSON.serialize(apiObjects);
    }

    /**
     * @description A method to convert Single record of an Object to JSON string.
     *
     * @param apiObject to be converted
     *
     * @return String with JSON
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static String convertSingleObjectToJsonString(RestMainObject apiObject) {
        // Checking first if null.
        if (apiObject == null) {
            throw new RestIntegrationServiceException('Null cannot be converted.');
        }

        // Check for mandatory fields.
        String missingMandatoryInformation = apiObject.checkMandatoryFields();
        if (String.isNotBlank(missingMandatoryInformation)) {
            throw new RestIntegrationServiceException('Missing mandatory information: ' + missingMandatoryInformation);
        }

        // Check for validity of data types.
        String validationOutput = apiObject.validateInputs();
        if (String.isNotBlank(validationOutput)) {
            throw new RestIntegrationServiceException(validationOutput);
        }

        // Generate the JSON-String.
        return JSON.serialize(apiObject);
    }

    /**
     * @description A method to convert JSON string to objects.
     *
     * @param objectType of target Object
     * @param innerJsonString to be parsed
     *
     * @return List<RestMainObject> created from JSON
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static List<RestMainObject> convertJsonStringIntoObjects(Type objectType, String innerJsonString) {
        // Check if all data is given.
        if (String.isBlank(innerJsonString) || objectType == null) {
            throw new RestIntegrationServiceException(NO_OBJECT_OR_JSON);
        }

        try {
            return (List<RestMainObject>) JSON.deserialize(innerJsonString, objectType);
        } catch (Exception e) {
            // It seems, that there are some problems converting the json-string.
            //LOG.debug(MALFORMED_JSON, innerJsonString);
            throw new RestIntegrationServiceException(MALFORMED_JSON + e.getMessage());
        }
    }

    /**
     * @description A method to convert JSON string to single record of an object.
     *
     * @param objectType of target Object
     * @param innerJsonString to be converted
     *
     * @return RestMainObject created from JSON
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static RestMainObject convertJsonStringIntoSingleObject(Type objectType, String innerJsonString) {
        // Check if all data is given.
        if (String.isBlank(innerJsonString) || objectType == null) {
            throw new RestIntegrationServiceException(NO_OBJECT_OR_JSON);
        }

        try {
            return (RestMainObject) JSON.deserialize(innerJsonString, objectType);
        } catch (Exception e) {
            // It seems, that there are some problems converting the json-string.
            //LOG.debug(MALFORMED_JSON, innerJsonString);
            throw new RestIntegrationServiceException(MALFORMED_JSON + e.getMessage());
        }
    }

    /**
     * @description A method to convert JSON string to single record of an untyped object.
     *
     * @param innerJsonString to be converted in untyped map
     *
     * @return Map<String, Object> created from JSON
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static Map<String, Object> convertJsonStringUntyped(String innerJsonString) {
        try {
            return (Map<String, Object>) JSON.deserializeUntyped(innerJsonString);
        } catch (Exception e) {
            throw new RestIntegrationServiceException(MALFORMED_JSON + e.getMessage()
                    + '\n\nJSON Body:\n' + innerJsonString);
        }
    }

    /**
     * @description A method to create HTTP request to be send to REST API.
     *
     * @param requestMethod to be used
     * @param endpoint to be used
     *
     * @return HttpRequest
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static HttpRequest getHttpRequest(final HttpMethod requestMethod, final String endpoint) {
        return getHttpRequest(DEFAULT_HEADERS, requestMethod, null, null, endpoint);
    }

    /**
     * @description A method to create HTTP request to be send to REST API.
     *
     * @param headers map of headers to be used in request
     * @param requestMethod to be used
     * @param endpoint to be used
     *
     * @return HttpRequest
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static HttpRequest getHttpRequest(final Map<String, String> headers, final HttpMethod requestMethod, final String endpoint) {
        return getHttpRequest(headers, requestMethod, null, null, endpoint);
    }

    /**
     * @description A method to create HTTP request to be send to REST API.
     *
     * @param headers map of headers to be used in request
     * @param requestMethod to be used
     * @param requestBody to be sent
     * @param endpoint to be used
     *
     * @return HttpRequest
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static HttpRequest getHttpRequest(final Map<String, String> headers, final HttpMethod requestMethod,
            final String requestBody, final String endpoint) {
        return getHttpRequest(headers, requestMethod, requestBody, null, endpoint);
    }

    /**
     * @description A method to create HTTP request to be send to REST API.
     *
     * @param requestMethod to be used
     * @param requestBody to be sent
     * @param endpoint to be used
     *
     * @return HttpRequest
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static HttpRequest getHttpRequest(final HttpMethod requestMethod, final String requestBody, final String endpoint) {
        return getHttpRequest(DEFAULT_HEADERS, requestMethod, requestBody, null, endpoint);
    }

    /**
     * @description A method to create HTTP request to be send to REST API.
     *
     * @param requestMethod to be used
     * @param requestBody to be sent
     * @param certificateName to be used
     * @param endpoint to be used
     *
     * @return HttpRequest
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static HttpRequest getHttpRequest(final HttpMethod requestMethod, final String requestBody,
            final String certificateName, final String endpoint) {
        return getHttpRequest(DEFAULT_HEADERS, requestMethod, requestBody, certificateName, endpoint);
    }


    /**
     * @description A method to create HTTP request to be send to REST API.
     *
     * @param headers map of headers to be used in request
     * @param requestMethod to be used
     * @param requestBody to be sent
     * @param certificateName to be used
     * @param endpoint to be used
     *
     * @return HttpRequest
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static HttpRequest getHttpRequest(final Map<String, String> headers, final HttpMethod requestMethod,
            final String requestBody, final String certificateName, final String endpoint) {
        checkValidityOfRequest(requestMethod, requestBody, endpoint);
        HttpRequest req = new HttpRequest();
        // Setting the information for the request.
        for (String headerGroup : headers.keySet()) {
            req.setHeader(headerGroup, headers.get(headerGroup));
        }
        req.setEndpoint(endpoint);
        req.setMethod(requestMethod.name());

        // Do we have body?
        if (String.isNotBlank(requestBody)) {
            req.setBody(requestBody);
        }

        // Are we using certificate?
        if (String.isNotBlank(certificateName)) {
            req.setClientCertificateName(certificateName);
        }

        return req;
    }


    /**
     * @description Check if obtained information is valid for creating a request.
     *
     * @param requestMethod to be used
     * @param requestBody to be sent
     * @param url as endpoint
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    private static void checkValidityOfRequest(final HttpMethod requestMethod, final String requestBody, final String url) {
        if (String.isBlank(url)) {
            throw new RestIntegrationServiceException(INVALID_INFO + '\nEndpoint URL: ' + url);
        } else if (requestMethod == null) {
            throw new RestIntegrationServiceException(INVALID_INFO + '\nRequest_method: ' + requestMethod);
            // Check for supported methods.
        } else if (requestMethod == HttpMethod.POST && (String.isBlank(requestBody))) {
            throw new RestIntegrationServiceException(POST_METHOD_NO_BODY);
        }
    }

    /**
     * @description A method to call Rest web service.
     *
     * @param request to be sent
     *
     * @return HttpResponse
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public static HttpResponse callWebService(HttpRequest request) {
        // Checking, if the data is valid.
        if (request == null) {
            throw new RestIntegrationServiceException(NO_REQUEST);
        }
        // Setting the Request-Timeout to MAX.
        request.setTimeout(CALLOUT_MAX_TIMEOUT_MS);
        // log final request.
        //LOG.debug('The request body be send to: ' + request.getEndpoint(), request.getBody());
        try {
            // Sending the request and storing response.
            Http http = new Http();
            HttpResponse res = http.send(request);
            //LOG.debug('The response body with HTTP status code: ' + res.getStatusCode() + ' - ' + res.getStatus(), res.getBody());
            return res;
        } catch (CalloutException e) {
            throw new RestIntegrationServiceException('Callout failure: ' + e.getMessage());
        }
    }
}