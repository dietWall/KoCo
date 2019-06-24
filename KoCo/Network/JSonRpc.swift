//
//  JSonRpc.swift
//  KoCo
//
//  Created by dietWall on 12.05.19.
//  Copyright © 2019 TH Rosenheim. All rights reserved.
//

import Foundation

//According to Specification from https://www.jsonrpc.org/specification#response_object

struct JsonRpcRequest<ParamType : Codable> : Codable{
	
    let jsonrpc         = "2.0"                 //MUST be "2.0"
    let id             : Int                    //MUST be String or Number(Int), can be freely choosen. We choose Int
    var method         : String                 //Describes the Server Method
    var params         : ParamType? = nil       //Depends on the Server Method
    
    func encode() -> Data{
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return data
        }catch let error{
            print("error: \(error)")
            return Data()
        }
    }
    
    init(id: Int, method: String, params: ParamType?){
        self.id = id
        self.method = method
        self.params = params
    }
    
    init(id: Int, method: String){
        self.init(id: id, method: method, params: nil)
    }
    
    
}

//Describes a Response from Json Rpc Server
struct JsonRpcResponse <ResultType : Codable> : Codable{
	let jsonrpc 	= "2,0"					//MUST be "2.0"
	let id 			: Int					//MUST be String or Number(Int), Must be same as in Request
	let result 		: ResultType			//Depends on the Server Method
}


//Describes an Error from Server
struct JsonRpcError<ErrorType: Codable> : Codable{
	var code 		: Int					//A Number that indicates the error type that occurred. This MUST be an integer.
	var message 	: String				// String providing a short description of the error. The message SHOULD be limited to a concise single sentence.
	var data 		: ErrorType?			//A Primitive or Structured value that contains additional information about the error. This may be omitted.
}


