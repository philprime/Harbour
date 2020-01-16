import Darwin
import Cabinet

public class ServerSocket {
    
    private let MAX_CONNECTIONS: Int32 = SOMAXCONN
    private let socketfd: Int32
    
    public init(port: in_port_t) throws {
        // Create local socket file descriptor
        socketfd = Darwin.socket(AF_INET, SOCK_STREAM, 0);
        if (socketfd < 0) {
            close()
            throw SocketError.creatingSocketFailed(Errno.description)
        }
        
        // Set socket options
        var optval: Int32 = 1
        if Darwin.setsockopt(socketfd, SOL_SOCKET, SO_REUSEADDR, &optval, socklen_t(MemoryLayout<Int32>.size)) == -1 {
            close()
            throw SocketError.settingSocketOptionsFailed(Errno.description)
        }
        
        // Initialise socket address
        var addr = sockaddr_in(
            sin_len: UInt8(MemoryLayout<sockaddr_in>.stride),
            sin_family: UInt8(AF_INET),
            sin_port: port.bigEndian,
            sin_addr: in_addr(s_addr: INADDR_ANY),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        
        // Bind socket
        let addrPointer = withUnsafeMutablePointer(to: &addr) { pointer in
            OpaquePointer(pointer)
        }
        if Darwin.bind(socketfd, UnsafePointer<sockaddr>(addrPointer), socklen_t(MemoryLayout<sockaddr_in>.size)) == -1 {
            close()
            throw SocketError.bindingSocketFailed(Errno.description)
        }
        
        // Listen on socket for new connections
        if Darwin.listen(socketfd, MAX_CONNECTIONS) == -1 {
            close()
            throw SocketError.listeningOnSocketFailed(Errno.description)
        }
    }
    
    public func port() throws -> in_port_t {
        let sin_port = try getSocketAddr().sin_port
        return Int(OSHostByteOrder()) != OSLittleEndian ? sin_port.littleEndian : sin_port.bigEndian
    }
    
    private func getSocketAddr() throws -> sockaddr_in {
        var addr = sockaddr_in()
        return try withUnsafePointer(to: &addr) { pointer in
            var len = socklen_t(MemoryLayout<sockaddr_in>.size)
            if Darwin.getsockname(socketfd, UnsafeMutablePointer(OpaquePointer(pointer)), &len) != 0 {
                throw SocketError.getSocketAddrFailed(Errno.description)
            }
            return pointer.pointee
        }
    }
    
    public func accept() throws -> ClientSocket {
        var connAddr = sockaddr()
        var connAddrLen = socklen_t(MemoryLayout<Int32>.size)
        let connection = Darwin.accept(socketfd, &connAddr, &connAddrLen)
        if connection == -1 {
            throw SocketError.acceptingFailed(Errno.description)
        }
        return ClientSocket(socketFd: connection)
    }
    
    public func close() {
        Darwin.close(socketfd)
    }
 }
