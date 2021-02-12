import SceneKit

extension SCNVector3 {
    
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    func normalized() -> SCNVector3 {
        return self / length()
    }
    
    mutating func normalize() -> SCNVector3 {
        self = normalized()
        return self
    }
}

public func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x * scalar, vector.y * scalar, vector.z * scalar)
}

public func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}
