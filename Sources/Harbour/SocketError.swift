public enum SocketError: Error {
    
    case creatingSocketFailed(_ description: String)
    case settingSocketOptionsFailed(_ description: String)
    case bindingSocketFailed(_ description: String)
    case listeningOnSocketFailed(_ description: String)
    case acceptingFailed(_ description: String)
    
    case getSocketAddrFailed(_ description: String)
    
    case readFailed(_ description: String)
    
    case closed
}
