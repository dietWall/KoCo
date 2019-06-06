//
//  JsonRpcTest.swift
//  KoCoTests
//
//  Created by admin on 25.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import XCTest
@testable import KoCo

class JsonRpcTest: XCTestCase {
    
    let ipstring = "127.0.0.1:8080"
    let prefix = "http://"
    let suffix = "/jsonrpc"
    
    let playerName = "testPlayer"
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testConnection() {
        
       
    }
    
    
    func testEncoding() {
        let server = createServer()
        let body = server.createRequestData(method: "testWithNoParams")
        print("Encoded Body with no Params: \(body)")
        XCTAssert(body.id == 1)
        XCTAssert(body.jsonrpc == "2.0")
        XCTAssert(body.method == "testWithNoParams")
        XCTAssert(body.params == nil)
        
        server.nextRequestId = 5        //define RequestId
        let body2 = server.createRequestDataWithParam(param: 1, method: "testWithParams")
        print("Encoded Body with Params(int) = 1: \(body2)")
        XCTAssert(body2.id == 5)
        XCTAssert(body2.jsonrpc == "2.0")
        XCTAssert(body2.method == "testWithParams")
        XCTAssert(body2.params == 1)
        
    }
    
    func testDecode(){
        let decode = "{\"id\":1,\"jsonrpc\":\"2.0\",\"result\":{\"version\":{\"major\":10,\"minor\":1,\"patch\":2}}}"
        
        let server = createServer()
        
        do{
            let result = try server.decodeResponse(type: JsonRpcResponse<VersionObj>.self, response: decode.data(using: .utf8)!)
            
            XCTAssert(result.id == 1)
            XCTAssert(result.result.version.major == 10)
            XCTAssert(result.result.version.minor == 1)
            XCTAssert(result.result.version.patch == 2)
            
        }
        catch let error{
            XCTFail("DecodeError: \(error)")
        }
    }
    
    
    func testRequestNoParam(){
        let expectation = self.expectation(description: "response from Kodi")
        let server = createServer()
        let request = "{\"jsonrpc\": \"2.0\",\"id\": 1, \"method\": \"JSONRPC.Version\"}"
        
        server.request(requestBody: request.data(using: .utf8)!, completion: {data, response, error in
            
            if(data != nil){
                let returnedString = String(data: data!, encoding: .utf8)    //Presence checked
                
                print("Request completed, Response: " + returnedString!)
                
                //Ok, this is somekind brute force,
                //but better not to depend on decodeResponse or
                //other functions that may fail in other tests:
                if((returnedString?.contains("error"))!){
                    XCTFail("Error received")
                }
                else if((returnedString?.contains("version"))!) {
                    expectation.fulfill()
                }
                
            }
            else if(error != nil){
                print("Error: \(error!)")
                XCTFail("Error Received")
            }else{
                
                XCTFail("Error Received")
            }
        })
        waitForExpectations(timeout: 10, handler: nil)
    }

    
    func testParameters(){
        let server = createServer()
        
        //create parameters
        //call function with: parameter, no param type? response type
        
        let actionParam = ActionParam(action: Action(rawValue: "left")!)
        
        let expectation = self.expectation(description: "Response from Kodi")
        
        server.jsonRpcRequest(paramType: ActionParam.self,
                              param: actionParam,
                              responseType: String.self,
                              method: "Input.ExecuteAction",
                              completion:
            {responseData, response, error in
                print(responseData!)
                                
                XCTAssert(responseData == "OK")
                expectation.fulfill()
        })
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    

    func createServer() ->JsonRpcCommunication{
        let url = URL(string: self.prefix + self.ipstring + self.suffix)!
        
        var request = URLRequest(url: url)
        
        //configure Request
        request.httpMethod = "POST"
        request.setValue("gzip", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let server = JsonRpcCommunication(request: request)
        
        return server
        
    }

}

