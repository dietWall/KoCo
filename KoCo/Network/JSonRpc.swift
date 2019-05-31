//
//  JSonRpc.swift
//  KoCo
//
//  Created by dietWall on 12.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

//According to Specification from https://www.jsonrpc.org/specification#response_object


//Describes an Request from Client to Server
struct JsonRpcRequest<ParamType : Codable & Equatable> : Codable, Equatable{
	static func == (lhs: JsonRpcRequest<ParamType>, rhs: JsonRpcRequest<ParamType>) -> Bool {
		if lhs.id == rhs.id, lhs.method == rhs.method, lhs.param == rhs.param{
			return true
		}
		return false
	}
	
	let jsonrpc 	= "2.0"					//MUST be "2.0"
	let id 			: Int					//MUST be String or Number(Int), can be freely choosen. We choose Int
	var method 		: String				//Describes the Server Method
	var param 		: ParamType? = nil		//Depends on the Server Method
}

//Describes a Response from Json Rpc Server
struct JsonRpcResponse <ParamType : Codable> : Codable{
	let jsonrpc 	= "2,0"					//MUST be "2.0"
	let id 			: Int					//MUST be String or Number(Int), Must be same as in Request
	let result 		: ParamType				//Depends on the Server Method
}


//Describes an Error from Server
struct JsonRpcError<ResponseType: Codable> : Codable{
	var code 		: Int					//A Number that indicates the error type that occurred. This MUST be an integer.
	var message 	: String				// String providing a short description of the error. The message SHOULD be limited to a concise single sentence.
	var data 		: ResponseType?			//A Primitive or Structured value that contains additional information about the error. This may be omitted.
}


class JsonRpcCommunication{
	
	typealias RequestCompletionHandler = (Data?, HTTPURLResponse?, Error?)->Void

    //var hostName: String = ""
	var postRequest: URLRequest
	
	var nextRequestId = 1					//TODO: kann man da ein Autoinkrement bei Zugriff machen?
		
	
	enum JsonRpcError : Error{
		case EncodingError
		case DecodingError
		case HostNotAvailable
	}

    init(request: URLRequest){
        self.postRequest = request
    }
	
	/**
	Description: Sends a generic Request to Server,
	Requestparameters are set in Constructor
	- parameters:
	- requestBody: Data to send in http Body
	- completion: will be called if request is finished
	*/
	func request(requestBody: Data, completion: @escaping RequestCompletionHandler){
		let defaultsession = URLSession(configuration: .default)
		
		postRequest.httpBody = requestBody
		postRequest.setValue("\(requestBody.count)", forHTTPHeaderField: "Content-Length")
		
		defaultsession.dataTask(with: postRequest, completionHandler: {
			data, response, error in
            completion(data, response as? HTTPURLResponse, error)
		}).resume()
	}
	
	
	func encodeRequest<ParamType: Codable & Equatable>(request: JsonRpcRequest<ParamType>)throws ->Data {
		let encoder = JSONEncoder()
		do{
			let result = try encoder.encode(request)
			return result
		}
		catch let error{
			print("Tried to encode an invalid request: \(request); Error: \(error)")
			throw JsonRpcError.EncodingError
		}
	}
	
	
	func decodeResponse<ResponseType: Codable>(type: ResponseType.Type, response: Data)throws -> ResponseType{
		let decoder = JSONDecoder()
		do{
			let result = try decoder.decode(ResponseType.self, from: response)
			return result
		}
		catch let error{
			print("Could not decode \(response) into : \(ResponseType.self), Error: \(error)")
			throw JsonRpcError.DecodingError
		}
	}
	
	
	/**
	Description: Convinience Function
	with a given Method, this function does a Request from the Server and returns the Response via
	completion, no Parameters will be transmitted
	- parameters:
	method: The server Method to call
	*/
    func jsonRpcRequest<ResponseType: Codable>(responseType: ResponseType.Type, method: String, completion: @escaping (ResponseType?, HTTPURLResponse?, Error?)->Void){

        let requestBody = createRequestData(method: method)
		
		do {
			let encoded = try encodeRequest(request: requestBody)
			
			request(requestBody: encoded, completion: { data, response, error in
                guard let httpResponse = response else {
                    completion(nil, response, error)
                    return
                }
                
                do{
                    if(data != nil)
                    {
                        let responseData = try self.decodeResponse(type: ResponseType.self, response: data!)
                        completion(responseData, httpResponse, error)
                    }
                }catch let decodeError{
                    completion(nil, httpResponse, error)
                    print("DecodeError: \(decodeError)")
                }
            } )
		}
        catch let encodeError{
            print("EncodeError!!! : \(encodeError)")
        }
	}
	
	
	
	/**
	Description: Convinience Function
	with a given Paramtype and Method, this function does a Request from the Server and returns the Response via
	completion
	- parameters:
	param: Object to be sent in parameters of the function
	method: The server Method to call
	*/
	func jsonRpcRequest<ParamType: Codable & Equatable, ResponseType: Codable>(param: ParamType, method: String, completion: @escaping (ResponseType?, HTTPURLResponse?, Error?)->Void){
        let requestBody = createRequestData(param: param, method: method)
       
        do {
            let encoded = try encodeRequest(request: requestBody)
            
            request(requestBody: encoded, completion: { data, response, error in
                guard let httpResponse = response else {
                    completion(nil, response, error)
                    return
                }
                
                do{
                    if(data != nil)
                    {
                        let responseData = try self.decodeResponse(type: ResponseType.self, response: data!)
                        completion(responseData, httpResponse, error)
                    }
                }catch let decodeError{
                    completion(nil, httpResponse, error)
                    print("DecodeError: \(decodeError)")
                }
            } )
        }
        catch let encodeError{
            //Solving this depends on the developer
            print("EncodeError!!! : \(encodeError)")
        }
	}
	
    
	func createRequestData<ParamType: Codable & Equatable>(param: ParamType, method: String)-> JsonRpcRequest<ParamType>{
		let result = JsonRpcRequest<ParamType>(id: nextRequestId, method: method, param: param)
		nextRequestId += 1
		return result
	}
	
	//TODO: Parametrisierung wird hier nicht benötigt
	//Evtl mit Vererbung lösen: JsonRpcRequestWithParam : JsonRpcRequestWithNoParam
	//Kann man eigentlich die 2 Methoden zusammenlegen??
	func createRequestData(method: String)->JsonRpcRequest<Int>{
		let result = JsonRpcRequest<Int>(id: nextRequestId, method: method, param: nil)
		nextRequestId += 1
		return result
	}
}

