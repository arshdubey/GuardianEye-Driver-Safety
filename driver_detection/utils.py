import cv2
import numpy as np
import math

# Eye landmark indices from MediaPipe Face Mesh
LEFT_EYE = [33, 160, 158, 133, 153, 144]
RIGHT_EYE = [362, 385, 387, 263, 373, 380]

def euclidean_distance(point1, point2):
    return math.dist((point1.x, point1.y), (point2.x, point2.y))

def calculate_ear(landmarks, eye_indices):
    """
    Calculate the Eye Aspect Ratio (EAR).
    """
    # Vertical eye landmarks
    v1 = euclidean_distance(landmarks[eye_indices[1]], landmarks[eye_indices[5]])
    v2 = euclidean_distance(landmarks[eye_indices[2]], landmarks[eye_indices[4]])
    
    # Horizontal eye landmarks
    h = euclidean_distance(landmarks[eye_indices[0]], landmarks[eye_indices[3]])
    
    # Calculate EAR
    ear = (v1 + v2) / (2.0 * h)
    return ear

def matrix_to_euler(matrix):
    """
    Convert a 4x4 transformation matrix into pitch, yaw, roll Euler angles in degrees.
    """
    R = matrix[:3, :3]
    sy = math.sqrt(R[0,0] * R[0,0] + R[1,0] * R[1,0])
    
    singular = sy < 1e-6
    
    if not singular:
        x = math.atan2(R[2,1], R[2,2]) # pitch
        y = math.atan2(-R[2,0], sy)    # yaw
        z = math.atan2(R[1,0], R[0,0]) # roll
    else:
        x = math.atan2(-R[1,2], R[1,1])
        y = math.atan2(-R[2,0], sy)
        z = 0
        
    return np.degrees(x), np.degrees(y), np.degrees(z)

def draw_styled_rect(img, pt1, pt2, color, thickness=2, r=10):
    """
    Draw a rectangle with rounded corners (neon style).
    """
    x1, y1 = pt1
    x2, y2 = pt2
    
    # Top left
    cv2.line(img, (x1 + r, y1), (x2 - r, y1), color, thickness)
    cv2.line(img, (x1, y1 + r), (x1, y2 - r), color, thickness)
    cv2.ellipse(img, (x1 + r, y1 + r), (r, r), 180, 0, 90, color, thickness)
    
    # Top right
    cv2.line(img, (x2, y1 + r), (x2, y2 - r), color, thickness)
    cv2.ellipse(img, (x2 - r, y1 + r), (r, r), 270, 0, 90, color, thickness)
    
    # Bottom left
    cv2.line(img, (x1 + r, y2), (x2 - r, y2), color, thickness)
    cv2.ellipse(img, (x1 + r, y2 - r), (r, r), 90, 0, 90, color, thickness)
    
    # Bottom right
    cv2.ellipse(img, (x2 - r, y2 - r), (r, r), 0, 0, 90, color, thickness)
    
    return img
