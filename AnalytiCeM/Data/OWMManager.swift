//
//  OWMManager.swift
//  AnalytiCeM
//
//  Created by Gaël on 07/05/2017.
//  Copyright © 2017 Polytech. All rights reserved.
//

import Foundation
import MapKit

import Alamofire
import AlamofireSwiftyJSON
import SwiftyJSON

public enum TemperatureFormat: String {
    case Celsius = "metric"
    case Fahrenheit = "imperial"
    case Kelvin = ""
}

public enum Language : String {
    case English = "en",
    French = "fr"
}

public enum WeatherResult {
    case Success(JSON)
    case Error(String)
    
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Error:
            return false
        }
    }
}

enum Router: URLRequestConvertible {
    
    // the static values
    static let baseURLString = "http://api.openweathermap.org/data/"
    static let apiVersion = "2.5"
    
    // only one possibility so far
    case Weather([String: AnyObject])
    
    // the method to retrieve the data
    var method: HTTPMethod {
        return .get
    }
    
    // the path of the
    var path: String {
        switch self {
        case .Weather:
            return "/weather"
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {

        // build URL
        let url = try (Router.baseURLString + Router.apiVersion).asURL()
        var uRLRequest = URLRequest(url: url.appendingPathComponent(path))
        uRLRequest.httpMethod = method.rawValue
        
        func encode(params: [String: AnyObject]) throws -> URLRequest {
            return try URLEncoding.default.encode(uRLRequest, with: params)
        }
        
        switch self {
        case .Weather(let parameters):
            return try encode(params: parameters)
        }
    }
}

public class OWMManager {
    
    // parameters of the call
    private var params = [String : AnyObject]()
    
    public var temperatureFormat: TemperatureFormat = .Celsius {
        didSet {
            params["units"] = temperatureFormat.rawValue as AnyObject
        }
    }
    
    public var language: Language = .English {
        didSet {
            params["lang"] = language.rawValue as AnyObject
        }
    }
    
    // MARK: - Init
    
    public init(apiKey: String) {
        params["APPID"] = apiKey as AnyObject
        params["units"] = temperatureFormat.rawValue as AnyObject
        params["lang"] = language.rawValue as AnyObject
    }
    
    public convenience init(apiKey: String, temperatureFormat: TemperatureFormat) {
        self.init(apiKey: apiKey)
        self.temperatureFormat = temperatureFormat
        self.params["units"] = temperatureFormat.rawValue as AnyObject
        
    }
    
    public convenience init(apiKey: String, temperatureFormat: TemperatureFormat, lang: Language) {
        self.init(apiKey: apiKey, temperatureFormat: temperatureFormat)
        
        self.language = lang
        self.temperatureFormat = temperatureFormat
        
        params["units"] = temperatureFormat.rawValue as AnyObject
        params["lang"] = lang.rawValue as AnyObject
    }
    
    // MARK: - Current weather
    
    private func currentWeather(params: [String:AnyObject], data: @escaping (WeatherResult) -> Void) {
        apiCall(method: Router.Weather(params),
                response: { response in
                    data(response)
                }
        )
    }
    
    public func currentWeatherByCoordinatesAsJson(latitude: CLLocationDegrees, longitude: CLLocationDegrees, data: @escaping (WeatherResult) -> Void) {
        
        params["lat"] = String(stringInterpolationSegment: latitude) as AnyObject
        params["lon"] = String(stringInterpolationSegment: longitude) as AnyObject
        
        currentWeather(params: params,
                       data: { response in
                            data(response)
                        }
        )
    }
    
    // MARK: - API call
    
    private func apiCall(method: Router, response: @escaping (WeatherResult) -> Void) {
        
        // perform request
        Alamofire.request(method).responseSwiftyJSON(completionHandler: { data in
            
            // check error
            guard let value = data.result.value, data.result.isSuccess else {
                
                response(WeatherResult.Error(data.error?.localizedDescription ?? data.error.debugDescription))
                return
                
            }
            
            // success
            response(WeatherResult.Success(value))
            
        })

    }
}
