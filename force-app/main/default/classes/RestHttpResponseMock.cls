/**
 * @description Class to create MOCK for REST http calls.
 *
 * @author tomaschour
 * @date 2021-04-20
 */
@IsTest
public with sharing class RestHttpResponseMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected Map<String, String> responseHeaders;
    protected String exceptionMessage;
    protected Boolean testException;

    public static String bodySaved;

    /**
     * Universal archive with test data, should be structured inside.
     */
    private static final String UNIT_TESTS_DATA_RESOURCE_NAME = 'unitTestsResources';

    /**
     * @description Test exception class.
     */
    public with sharing class MockException extends Exception {
    }

    /**
     * @description Constructor for String body.
     *
     * @param code response status code
     * @param status response status string
     * @param body response body as string
     * @param responseHeaders response headers
     */
    public RestHttpResponseMock(Integer code, String status, String body, Map<String, String> responseHeaders) {
        this.testException = false;
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
        bodySaved = body;
    }

    /**
     * @description Constructor for Blob body.
     *
     * @param code response status code
     * @param status response status string
     * @param body response body as blob
     * @param responseHeaders response headers
     */
    public RestHttpResponseMock(Integer code, String status, Blob body, Map<String, String> responseHeaders) {
        this.testException = false;
        this.code = code;
        this.status = status;
        this.bodyAsBlob = body;
        this.bodyAsString = null;
        this.responseHeaders = responseHeaders;
    }

    /**
     * @description Constructor for static resource body.
     *
     * @param code response status code
     * @param status response status string
     * @param pathInTestDataResource path relative to our zip resource with test data
     */
    /*public RestHttpResponseMock(Integer code, String status, String pathInTestDataResource) {
        this.testException = false;
        this.code = code;
        this.status = status;
        this.bodyAsBlob = getBodyFromStaticResource(pathInTestDataResource);
        this.bodyAsString = this.bodyAsBlob.toString();
    }*/

    /**
     * @description Constructor to specify if throw exception.
     *
     * @param testException indicates scenario with exception
     * @param message for exception
     */
    public RestHttpResponseMock(Boolean testException, String message) {
        this.testException = testException;
        this.exceptionMessage = message;
    }

    /**
     * @description Respond to incoming request based on current setup.
     *
     * @param req incoming request
     *
     * @return response based on provided parameters
     */
    public HttpResponse respond(HttpRequest req) {
        if (testException) {
            throw new MockException(exceptionMessage);
        }

        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);

        if (bodyAsBlob != null) {
            resp.setBodyAsBlob(bodyAsBlob);
        } else {
            resp.setBody(bodyAsString);
        }

        if (responseHeaders != null) {
            for (String key : responseHeaders.keySet()) {
                resp.setHeader(key, responseHeaders.get(key));
            }
        }
        return resp;
    }

    /**
     * @description accepts path to file in unitTestsResources.zip file in static resources
     * throws exception if file is not found
     *
     * @param pathInZip path to final resource file in unitTestsResources zip
     * @return Blob - file from static resource as binary data
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    /*private Blob getBodyFromStaticResource(String pathInZip) {
        for (StaticResource sr : [SELECT Id, Body FROM StaticResource WHERE Name = :UNIT_TESTS_DATA_RESOURCE_NAME]) {
            Zippex mocksZip = new Zippex(sr.Body);
            if (!mocksZip.getFileNames().contains(pathInZip)) {
                throw new Exceptions.IllegalArgumentException(UNIT_TESTS_DATA_RESOURCE_NAME + ' static resource does not contain file: ' + pathInZip);
            }
            return mocksZip.getFile(pathInZip);
        }

        throw new Exceptions.BadDataException('No static resource for unit tests named ' + UNIT_TESTS_DATA_RESOURCE_NAME + ' found.');
    }*/
}