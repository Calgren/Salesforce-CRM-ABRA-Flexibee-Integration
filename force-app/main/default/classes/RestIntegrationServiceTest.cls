/**
 * @description Unit Tests for RestIntegrationService class.
 *
 * @author tomaschour
 * @date 2021-04-20
 */
@IsTest
private with sharing class RestIntegrationServiceTest {

    private static final String END_POINT_URL = 'https://google.com';
    private static final String COMPLETE = 'Complete';
    private static final String UNEXPECTED_RESPONSE = 'Unexpected response';

    private static final String VALID_JSON = '{"name": "test", "age": 14}';
    private static final String BAD_JSON = '[{{]';

    /**
     * @description Checks if the serialization of unknown type of object to JSON string works as intended
     */
    @IsTest
    private static void testConvertJsonStringUntyped() {
        Map<String, Object> parsedJsonMap = RestIntegrationService.convertJsonStringUntyped(VALID_JSON);
        System.assertEquals('test', parsedJsonMap.get('name'));
        System.assertEquals(14, parsedJsonMap.get('age'));
    }

    /**
     * @description Checks if the serialization of unknown type of object to JSON string is getting correct arguments
     * - malformed Json
     */
    @IsTest
    private static void testConvertJsonStringUntyped_MalformedJsonString() {
        Boolean exceptionThrown = false;
        try {
            RestIntegrationService.convertJsonStringUntyped(BAD_JSON);
            System.assert(false);
        } catch (Exception e) {
            exceptionThrown = e.getMessage().contains('JSON string is malformed');
        }
        System.assert(exceptionThrown);
    }

    /**
     * @description Checks that  we cant get http request without specifying method.
     */
    @IsTest
    private static void testGetHttpRequest_EmptyRequestMethod() {
        Test.startTest();
        try {
            RestIntegrationService.getHttpRequest(null, null, BAD_JSON, null, END_POINT_URL);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof Exceptions.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.INVALID_INFO));
        }
        Test.stopTest();
    }

    /**
     * @description Checks that we cant get http request without providing an endpoint.
     */
    @IsTest
    private static void testGetHttpRequest_EmptyCredentials() {
        Test.startTest();
        try {
            RestIntegrationService.getHttpRequest(null, null, '{}', null, null);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof Exceptions.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.INVALID_INFO));
        }
        Test.stopTest();
    }

    /**
     * @description Checks that we need to provide body, if we are creating POST http request.
     */
    @IsTest
    private static void testGetHttpRequest_EmptyBodyPost() {
        Test.startTest();
        try {
            RestIntegrationService.getHttpRequest(null, RestIntegrationService.HttpMethod.POST, null, null, END_POINT_URL);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof Exceptions.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.POST_METHOD_NO_BODY));
        }
        Test.stopTest();
    }


    /**
     * @description Checks that we can call a web service and receive and parse the answer
     */
    @IsTest
    private static void testCallWebService() {
        String requestBody = VALID_JSON;

        HttpRequest request = RestIntegrationService.getHttpRequest(RestIntegrationService.HttpMethod.GET, requestBody, null, END_POINT_URL);
        RestHttpResponseMock fakeResponse = new RestHttpResponseMock(200, COMPLETE, VALID_JSON, null);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        HttpResponse response = RestIntegrationService.callWebService(request);
        Test.stopTest();

        System.assert(response != null);
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals(COMPLETE, response.getStatus());
        System.assertEquals(VALID_JSON, response.getBody());
    }

    /**
     * @description Checks that we can handle trying to send request without providing request
     */
    @IsTest
    private static void testCallWebService_NoRequest() {
        RestHttpResponseMock fakeResponse = new RestHttpResponseMock(200, COMPLETE, VALID_JSON, null);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        try {
            RestIntegrationService.callWebService(null);
            System.assert(false);
        } catch (Exception e) {
            System.assert(e instanceof Exceptions.RestIntegrationServiceException);
            System.assert(e.getMessage().contains(RestIntegrationService.NO_REQUEST));
        }
        Test.stopTest();
    }

    /**
     * @description Checks that we can handle wrong status code during the call
     */
    @IsTest
    private static void testCallWebService_WrongStatusCode() {
        HttpRequest request = RestIntegrationService.getHttpRequest(RestIntegrationService.HttpMethod.GET, '{}', null, END_POINT_URL);
        RestHttpResponseMock fakeResponse = new RestHttpResponseMock(400, UNEXPECTED_RESPONSE, VALID_JSON, null);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        HttpResponse res = RestIntegrationService.callWebService(request);

        System.assert(res != null);
        System.assertEquals(400, res.getStatusCode());
        System.assertEquals(UNEXPECTED_RESPONSE, res.getStatus());
        System.assertEquals(VALID_JSON, res.getBody());
        Test.stopTest();
    }


    /**
    * @description Tests creating http request with specified method and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_methodEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(RestIntegrationService.HttpMethod.GET, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
    }

    /**
    * @description Tests creating http request with specified headers, method and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_headersMethodEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(new Map<String, String>{
                'Content-Type' => 'multipart/form-data; boundary=something',
                'Connection' => 'close'
        },
                RestIntegrationService.HttpMethod.GET, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
        System.assertEquals('multipart/form-data; boundary=something', request.getHeader('Content-Type'));
        System.assertEquals('close', request.getHeader('Connection'));
    }


    /**
    * @description Tests creating http request with specified headers, method, body and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_headersMethodBodyEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(new Map<String, String>{
                'Content-Type' => 'multipart/form-data; boundary=something',
                'Connection' => 'close'
        },
                RestIntegrationService.HttpMethod.GET, VALID_JSON, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
        System.assertEquals(VALID_JSON, request.getBody());
        System.assertEquals('multipart/form-data; boundary=something', request.getHeader('Content-Type'));
        System.assertEquals('close', request.getHeader('Connection'));
    }


    /**
    * @description Tests creating http request with specified method, body and endpoint
    */
    @IsTest
    private static void testGetHttpRequest_methodBodyEndpoint() {
        Test.startTest();
        HttpRequest request = RestIntegrationService.getHttpRequest(
                RestIntegrationService.HttpMethod.GET, VALID_JSON, END_POINT_URL);
        Test.stopTest();
        System.assertEquals(END_POINT_URL, request.getEndpoint());
        System.assertEquals(RestIntegrationService.HttpMethod.GET.name(), request.getMethod());
        System.assertEquals(VALID_JSON, request.getBody());
        System.assertEquals(RestIntegrationService.DEFAULT_HEADERS.get('Content-Type'), request.getHeader('Content-Type'));
        System.assertEquals(RestIntegrationService.DEFAULT_HEADERS.get('Connection'), request.getHeader('Connection'));
    }
}
