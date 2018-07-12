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
    
    router.get("/jwt", handler: getJWT)

    router.all("/", middleware: BodyParser())

    router.post("/verify", handler: verifyJWT)
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

    public func verifyJWT(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        guard let jwtBody = request.body else {
            return try response.status(.badRequest).send("No body\n").end()
        }
        guard let jwtData = jwtBody.asText else {
            return try response.status(.badRequest).send("Body not text\n").end()
        }
        let key =
        """
-----BEGIN PUBLIC KEY-----
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEA1TZ9oVphRAa+HoHRCxon
oERuwQJSuzYsv9jqaY5shjRu02IhR0jg/enifARKpHVxx/VFAqdaiUYbyS4a1y/m
XE1lDWXfsFS0BcGBYp8Dv9OinWanUofma3G27OWMaH0z1nLQR7uqFTP3f79hiCbT
+vDBmGNUiGo+npgKf8euQA/1ngxXV75JNmt5lsYlwVC3YX4peO2aSuGTUXq6bDdv
Mo94J5yP+xgwnB/TgXELYuakMiBvJla+beZz3E0MHr0hUZwsttTvf+4NrquJC0tW
0L4ELUHy+BelOcy0/uh7PtWBOmDRgCrZ4EDfeLhhOU0i2IO9zUjEvughtSPVWDmD
moAImmHcf9hO31ZB+85igLGGRXP7Y2+b6g/DHFmTqKXM0EU5vaMW7vP0rjfvK9nG
3xhqoZ1/c2cA+sJqMmpNrNYWZN7lDj+pB/w92FT5Xhy93r8qhUDSGk6Ov/2I0EkL
D7QtOi8CgmO0x1gFdLyVqdWS9uw/vH3Sz+ctQieqXoWVRwezDVZTuQi+oZqqxnEe
pG3fgIC7/lBQcjim/2lpilEhWpTrKEUU+nMZ0h1up92NtlQus11vn6leVPye5I6m
6QCZbj22vh3OMq81vy/NlUZZc1H8fH7hYTUfcRkCZJa9UxTMxTRVd6sanaKF3gXU
GAw+lzVWZopnycNmHi9YW98CAwEAAQ==
-----END PUBLIC KEY-----

""".data(using: .utf8)!
        if try JWT.verify(jwtData, using: .rs256(key, .publicKey)) {
            response.status(.OK).send("JWT verified\n")
            if let jwt = try JWT.decode(jwtData) {
                response.send(String(describing: jwt))
                response.send("\n")
            }
            try response.end()
        } else {
            try response.status(.badRequest).send("JWT did not verify\n").end()
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
