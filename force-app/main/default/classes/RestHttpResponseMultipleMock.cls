/**
 * @description Class to hold and perform multiple various mocks for REST HTTP calls.
 *
 * @author tomaschour
 * @date 2021-04-20
 */
@IsTest
public with sharing class RestHttpResponseMultipleMock implements HttpCalloutMock {

    private List<RestHttpResponseMock> mockList;
    private Integer callNumber;

    /**
     * @description Constructor assigns default values.
     */
    public RestHttpResponseMultipleMock() {
        mockList = new List<RestHttpResponseMock>();
        callNumber = 0;
    }

    /**
     * @description Adds given mock to the list.
     *
     * @param mock to add
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public void addMock(final RestHttpResponseMock mock) {
        mockList.add(mock);
    }

    /**
     * @description Every time returns different mock response. if the number of calls is bigger that number of held mocks.
     *
     * @param req request to get response for
     *
     * @return the last HttpResponse mock in the list
     *
     * @author tomaschour
     * @date 2021-04-20
     */
    public HttpResponse respond(HttpRequest req) {
        if (callNumber < mockList.size()) {
            return mockList.get(callNumber++).respond(req);
        } else {
            return mockList.get(mockList.size() - 1).respond(req);
        }
    }
}
