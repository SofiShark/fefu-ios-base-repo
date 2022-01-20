import Foundation

class API {
    static let baseUrl = "https://fefu.t.feip.co/api"
    
    static let decoder: JSONDecoder = ({
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in

            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            let dateFormatter = ISO8601DateFormatter()
            guard let date = dateFormatter.date(from: dateString) else {
                throw DecodingError.dataCorruptedError(in: container,
                    debugDescription: "Cannot decode date string \(dateString)")
            }
            
            return date
        }

        return decoder
    })()
    static let encoder: JSONEncoder = ({
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        return encoder
    })()
    
    static func createRequest(_ url: URL) -> URLRequest {
        var request = URLRequest(url: url)

        if let token = UserDefaults.standard.string(forKey: "token") {
            request.addValue("Bearer " + token, forHTTPHeaderField: "Authorization")
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        return request
    }

    static func postRequest(url: URL, data: Data? = nil) -> URLRequest {
        var request = self.createRequest(url)

        request.httpMethod = "POST"
        request.httpBody = data

        return request
    }

    static func getRequest(url: URL, data: Data? = nil) -> URLRequest {
        var request = self.createRequest(url)

        request.httpMethod = "GET"
        request.httpBody = data

        return request
    }
    
    static func errorMessage(error: ErrorModel) -> String {
        return error.message
    }
}

extension API {
    static func register(_ data: Data,
                         resolve: @escaping((AuthResponseModel) -> Void),
                         reject: @escaping((FieldsErrorModel) -> Void)) {

        guard let url = URL(string: baseUrl + "/auth/register") else {
            return
        }

        let request = postRequest(url: url, data: data)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }

            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 201:
                do {
                    let authResponse = try decoder.decode(AuthResponseModel.self, from: data)
                    resolve(authResponse)
                } catch let e {
                    print("Decode error: \(e)")
                }

            case 422:
                do {
                    let error = try decoder.decode(FieldsErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }
    
    static func login(_ data: Data,
                      resolve: @escaping((AuthResponseModel) -> Void),
                      reject: @escaping((FieldsErrorModel) -> Void)) {

        guard let url = URL(string: baseUrl + "/auth/login") else {
            return
        }

        let request = postRequest(url: url, data: data)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }

            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 200:
                do {
                    let authResponse = try decoder.decode(AuthResponseModel.self, from: data)
                    resolve(authResponse)
                } catch let e {
                    print("Decode error: \(e)")
                }

            case 422:
                do {
                    let error = try decoder.decode(FieldsErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }
    
    static func logout(resolve: @escaping(() -> Void),
                       reject: @escaping((ErrorModel) -> Void)) {

        guard let url = URL(string: baseUrl + "/auth/logout") else {
            return
        }

        let request = postRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }

            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 200:
                resolve()

            case 401:
                do {
                    let error = try decoder.decode(ErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }
}

extension API {
    static func types(resolve: @escaping(([ActivityCollectionCellModel]) -> Void),
                      reject: @escaping((ErrorModel) -> Void)) {

        guard let url = URL(string: baseUrl + "/activity_types") else {
            return
        }

        let request = getRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 200:
                do {
                    let types = try decoder.decode([ActivityCollectionCellModel].self, from: data)
                    resolve(types)
                } catch let e {
                    print("Decode error: \(e)")
                }

            case 422:
                do {
                    let error = try decoder.decode(ErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }

    static func activities(resolve: @escaping((SocialActivitiesResponseModel) -> Void),
                           reject: @escaping((FieldsErrorModel?) -> Void)) {

        guard let url = URL(string: baseUrl + "/activities") else {
            return
        }

        let request = getRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 200:
                do {
                    let types = try decoder.decode(SocialActivitiesResponseModel.self, from: data)
                    resolve(types)
                } catch let e {
                    print("Decode error: \(e)")
                }

            case 422:
                do {
                    let error = try decoder.decode(FieldsErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }
}

extension API {
    static func profile(resolve: @escaping((UserModel) -> Void),
                        reject: @escaping((ErrorModel) -> Void)) {

        guard let url = URL(string: baseUrl + "/user/profile") else {
            return
        }

        let request = getRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 200:
                do {
                    let user = try decoder.decode(UserModel.self, from: data)
                    resolve(user)
                } catch let e {
                    print("Decode error: \(e)")
                }

            case 401:
                do {
                    let error = try decoder.decode(ErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }
    
    static func saveActivity(_ data: ActivityRequestModel,
                             resolve: @escaping((ActivitiesResponseModel) -> Void),
                             reject: @escaping((FieldsErrorModel?) -> Void)) {

        guard let url = URL(string: baseUrl + "/user/activities") else {
            return
        }

        let reqData: Data
        do {
            reqData = try encoder.encode(data)
        } catch {
            print("Encode error: \(error)")
            return
        }

        let request = postRequest(url: url, data: reqData)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                return
            }
            guard let res = response as? HTTPURLResponse else {
                return
            }

            switch res.statusCode {
            case 201:
                do {
                    let activities = try decoder.decode(ActivitiesResponseModel.self, from: data)
                    
                    resolve(activities)
                } catch let e {
                    print("Decode error: \(e)")
                }

            case 422:
                do {
                    let error = try decoder.decode(FieldsErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }
                
            case 401:
                do {
                    let error = try decoder.decode(FieldsErrorModel.self, from: data)
                    reject(error)
                } catch {
                    print("Decode error: \(error)")
                }

            default:
                break
            }
        }
        task.resume()
    }
}
