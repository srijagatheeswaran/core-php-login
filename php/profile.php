<?php
require_once './database/mysql.php';
require_once './database/redis.php';
require_once './database/mongodb.php';
require_once './auth.php';

$userId = authenticate();
loadEnv();

header('Content-Type: application/json');

$matchedUserId = $userId; 

// Fetch user info
$stmt = $conn->prepare("SELECT id, username, email, created_at FROM users WHERE id = :id");
$stmt->execute(['id' => $matchedUserId]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if ($user) {
    // Fetch additional user details from MongoDB
    $mongoUser = $db->user->findOne(['user_id' => (int)$matchedUserId]);

    if ($mongoUser) {
        // Convert MongoDB object to array and merge with MySQL user data
        $user['phone'] = $mongoUser['phone'] ?? null;
        $user['location'] = $mongoUser['location'] ?? null;
        $user['profile_image'] = $mongoUser['profile_image'] ?? null;
    }

    echo json_encode(['status' => 'success', 'message' => 'Profile data fetched', 'user' => $user]);
} else {
    echo json_encode(['status' => 'error', 'message' => 'User not found']);
}
