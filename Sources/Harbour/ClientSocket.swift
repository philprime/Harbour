import Darwin
import Cabinet

public class ClientSocket {
    
    private var socketFd: Int32
    private var isClosed = false

    init(socketFd: Int32) {
        self.socketFd = socketFd
    }
    
    deinit {
        close()
    }
    
    private static let CR: UInt8 = 13
    private static let NL: UInt8 = 10

    public func readLine() throws -> String {
        var characters: String = ""
        var byte: UInt8 = 0
        repeat {
            byte = try self.readSingleByte()
            if byte > ClientSocket.CR {
                characters.append(Character(UnicodeScalar(byte)))
            }
        } while byte != ClientSocket.NL
        return characters
    }
    
    public func read(length: Int) throws -> [UInt8] {
        var buffer = [UInt8](repeating: 0, count: length)
        guard Darwin.read(socketFd, &buffer, length) >= 0 else {
            throw SocketError.readFailed(Errno.description)
        }
        return buffer
    }
    
    public func readSingleByte() throws -> UInt8 {
        var byte: UInt8 = 0
        let result = Darwin.read(self.socketFd, &byte, 1)
        guard result >= 0 else {
            throw SocketError.readFailed(Errno.description)
        }
        if result == 0 {
            throw SocketError.closed
        }
        
        return byte
    }
    
    public func write(data: [UInt8]) {
        Darwin.write(socketFd, data, data.count)
    }
    
    public func send(data: [UInt8]) {
        Darwin.send(socketFd, data, data.count, 0)
    }
    
    public func close() {
        if isClosed {
            return
        }
        Darwin.close(socketFd)
        isClosed = true
    }
}

extension ClientSocket: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(socketFd)
    }
    
    public static func == (lhs: ClientSocket, rhs: ClientSocket) -> Bool {
        return lhs.socketFd == rhs.socketFd
    }
}
