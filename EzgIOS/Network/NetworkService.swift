import Foundation
import Moya

public enum NetworkService {
    
    // MARK: - User
    
    case register(params: [String: Any])
    
    case login(params: [String: Any])
    
}

extension NetworkService: TargetType {
    
    public var baseURL: URL { return URL(string: Global.sharedInstance.baseUrl)! }
    
    public var headers: [String: String]? {
        switch self {
            
        case .login, .register:
        return [
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "application/json"
        ]
            
        default: return [
                "Authorization": "Bearer \(Global.sharedInstance.token)",
                "Content-Type": "application/x-www-form-urlencoded",
                "Accept": "application/json"
            ]
            
    }

    }
    
    public var path: String {
        switch self {
        
            // MARK: - User
        
            case .register:
                return "user/reg"
            
            case .login:
                return "user/login"
             
            
        }
    }
    
    public var method: Moya.Method {
        switch self {
        
        case .register, .login:
                return .post
                
            default:
                return .get
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {

        switch self {
        
        
        
        // MARK: - Form + one image
        
      
        // MARK: - Form
            
        case let .login(params: params),
             let .register(params: params):
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
            
        // MARK: - Form + list of images
        
        default :
            return .requestPlain
            
        }
    }
}
