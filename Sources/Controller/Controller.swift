/**
* Copyright IBM Corporation 2016, 2017, 2018
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

import Kitura
import Foundation
import LoggerAPI
import CloudEnvironment
import Health
import SwiftJWT

struct Project: Codable {
    let framework: String
    let applicationName: String
    let company: String
    let organization: String
    let location: String
}

public class Controller {

  public let router: Router
  let cloudEnv: CloudEnv
  let health: Health

  public var port: Int {
    get { return cloudEnv.port }
  }

  public var url: String {
    get { return cloudEnv.url }
  }

  public init() {
    // Create CloudEnv instance
    cloudEnv = CloudEnv()

    // All web apps need a Router instance to define routes
    router = Router()

    // Instance of health for reporting heath check values
    health = Health()

    // Serve static content from "public"
    router.all("/", middleware: StaticFileServer())

    // Basic GET request
    router.get("/hello", handler: getHello)

    // Basic POST request
    router.post("/hello", handler: postHello)

    // JSON Get request
    router.get("/json", handler: getJSON)

    // Basic application health check
    router.get("/health", handler: getHealthCheck)
    
    router.get("jwt", handler: getJWT)
  }

  /**
  * Handler for getting a text/plain response.
  */
  public func getHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send("Hello from Kitura-Starter!").end()
  }
    
    public func getJWT(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("GET - /hello route handler...")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        let key =
            """
-----BEGIN RSA PRIVATE KEY-----
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
-----END RSA PRIVATE KEY-----

""".data(using: .utf8)!
        var jwt = JWT(header: Header([.alg:"rs256"]), claims: Claims([.name:"Kitura"]))
        jwt.claims[.name] = "Kitura-JWT"
        jwt.claims[.iss] = "issuer"
        jwt.claims[.aud] = ["clientID"]
        jwt.claims[.iat] = "1485949565.58463"
        jwt.claims[.exp] = "2485949565.58463"
        jwt.claims[.nbf] = "1485949565.58463"
        
        if let signed = try jwt.sign(using: .rs256(key, .privateKey)) {
            response.send(signed)
        } else {
            Log.error("Nope...")
        }
    }

  /**
  * Handler for posting the name of the entity to say hello to (a text/plain response).
  */
  public func postHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("POST - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    if let name = try request.readString() {
      try response.status(.OK).send("Hello \(name), from Kitura-Starter!").end()
    } else {
      try response.status(.OK).send("Kitura-Starter received a POST request!").end()
    }
  }

  /**
  * Handler for getting an application/json response.
  */
  public func getJSON(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /json route handler...")
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    let project = Project(framework: "Kitura", applicationName: "Kitura-Starter",
      company: "IBM", organization: "Swift @ IBM", location: "Austin, Texas")
    // Send codable object as response
    try response.status(.OK).send(project).end()
  }

  /**
   * Handler for getting a text/plain response of application health status.
   */
  public func getHealthCheck(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /health route handler...")
    let status = health.status
    if health.status.state == .UP {
      try response.status(.OK).send(status).end()
    } else {
      try response.status(.serviceUnavailable).send(status).end()
    }
  }

}
