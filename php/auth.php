<?php
require_once './database/redis.php';
header('Content-Type: application/json');

function authenticate() {
    global $redisClient;

    $headers = getallheaders();
    $authToken = $headers['Authorization'] ?? '';

    if (!$authToken) {
        echo json_encode(['status' => 'error', 'message' => 'Unauthorized: Token missing']);
        http_response_code(401);
        exit;
    }

    $userId = null;
    foreach ($redisClient->keys("session:user:*") as $key) {
        if ($redisClient->get($key) === $authToken) {
            $userId = str_replace("session:user:", "", $key);
            break;
        }
    }

    if (!$userId) {
        echo json_encode(['status' => 'error', 'message' => 'Unauthorized: Invalid token']);
        http_response_code(401);
        exit;
    }

    return (int)$userId;
}
